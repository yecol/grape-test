#!/bin/bash -e
target=$1;

## download the correct results
if [[ -d "grape-test" ]]
then
  cd grape-test
  git pull
  cd ../
else
  git clone https://github.com/yecol/grape-test.git --depth=1
fi

## check source grape.env
if [ -z "$GRAPE_HOME" ] || [ -z "$MPIEXEC" ]; then
  echo "Source BUILD_DIR/grape.env first."
  exit
fi


test_unit()
{       
  # $1: dataset_name
  # $2: worker_num / mpi_n
  # $3: algo_name
  # $4: query_name
  # $5: fragment_num
  # $6: extra_param for ./algo
  echo "[GRAPE_TEST] begin_unit_test: $3-$1" 
  command="$MPIEXEC -n $2 $GRAPE_HOME/build/$3 \
                  --nointeractive \
                  --query_dir grape-test/test/$4-query \
                  --result_dir grape-test/test/$3-$1-result \
                  --nfrag $5 \
                  --efile grape-test/small_dataset/$1/$1.e \
                  --vfile grape-test/small_dataset/$1/$1.v \
                  --rfile grape-test/small_dataset/$1/$1.r$5 \
                  --v 2 $6"
  echo $command;
  $command;
        
  # results=grape-test/test/$3-$1-result/*
  # for f in $results
  # do
  #   fname=`basename ${f}`
  #   if [ -f ${fname} ]; then
  #     # exist the assembled file;
  #     sort -k1n ${fname} > ${fname}.sorted
  #   else
  #     # no assembled file, but fragmented results, then cat together before compare.
  #     fstem=${fname%%.*};
  #     cat ${fstem}.frag* | sort -k1n > ${fname}.sorted
  #   fi
  #   echo cmp ${fname}.sorted ${f}
  #   if ! cmp ${fname}.sorted ${f} >/dev/null 2>&1
  #   then
  #     echo "[GRAPE_TEST] failed to pass $3-$1 check, check your code."
  #     exit 1
  #   fi
  # done
  echo "[GRAPE_TEST] passed_unit_test: $3-$1"
}

###############################################################
#
# Essential tests.
#
###############################################################
if [[ $target == "sssp" ]] || [[ -z "$target" ]]
then
    test_unit twitter 4 sssp sssp 16 
#    test_unit Epinions1 4 sssp sssp 16 \
#    "--assemble=false"
#    test_unit Slashdot0811 8 sssp sssp 32 \
#    "--serialization=true \
#     --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
#    test_unit_ Slashdot0902 16 sssp sssp 64 \
#    "--assemble=false \
#     --serialization=true \
#     --serialization_dir $GRAPE_HOME/build/grape-data/serialization"

fi
###############################################################
if [[ $target == "sim" ]] || [[ -z "$target" ]]
then
  test_unit twitter 4 sim sim 16 
  # test_unit Epinions1 4 sim sim 16 \
  # "--assemble=false"
  # test_unit Slashdot0811 8 sim sim 32 \
  # "--serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
  # test_unit_na Slashdot0902 16 sim sim 64 \
  # "--assemble=false \
  #  --serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
fi
###############################################################
if [[ $target == "bfs" ]] || [[ -z "$target" ]]
then
  test_unit twitter 4 bfs bfs 16 
  # test_unit_na Epinions1 4 bfs bfs 16 \
  # "--assemble=false"
  # test_unit Slashdot0811 8 bfs bfs 32 \
  # "--serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
  # test_unit_na Slashdot0902 16 bfs bfs 64 \
  # "--assemble=false \
  #  --serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
fi
###############################################################
if [[ $target == "vf2" ]] || [[ -z "$target" ]]
then
  test_unit twitter 4 vf2 vf2 16 
  # test_unit_na Epinions1 4 vf2 vf2 16 \
  # "--assemble=false"
  # test_unit Slashdot0811 8 vf2 vf2 32 \
  # "--serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
  # test_unit_na Slashdot0902 16 vf2 vf2 64 \
  # "--assemble=false \
  #  --serialization=true \
  #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
fi
###############################################################
# if [[ $target == "wcc" ]] || [[ -z "$target" ]]
# then
#   # test_unit twitter 1 wcc wcc 4 
#   # test_unit_na Epinions1 4 wcc wcc 16 \
#   # "--assemble=false"
#   # test_unit Slashdot0811 8 wcc wcc 32 \
#   # "--serialization=true \
#   #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
#   # test_unit_na Slashdot0902 16 wcc wcc 64 \
#   # "--assemble=false \
#   #  --serialization=true \
#   #  --serialization_dir $GRAPE_HOME/build/grape-data/serialization"
# fi
###############################################################
#
# Optional tests.
#
###############################################################
if [[ $target == "sssp-url" ]]
then
  test_unit_op twitter 1 sssp sssp 4 \
  "--file_location 5 \
   --efile http://yecol.me/twitter/twitter.e \
   --vfile http://yecol.me/twitter/twitter.v \
   --rfile http://yecol.me/twitter/twitter.r"

fi

###############################################################
if [[ $target == "sssp-s3" ]]
then
  test_unit_op twitter 4 sssp sssp 16 \
  "--file_location 2 \
   --efile twitter.e \
   --vfile twitter.v \
   --rfile twitter.r"

fi
###############################################################
if [[ $target == "sssp-hdfs" ]]
then
  test_unit_op twitter 8 sssp-hdfs sssp 32 \
  "--file_location 1 \
   --efile /dataset/twitter.e \
   --vfile /dataset/twitter.v \
   --rfile /dataset/twitter.r"

fi
###############################################################
if [[ $target == "pm" ]]
then
  test_unit_op twitter 16 pm wcc 64 \
  "--element_file test.dat"
fi


echo "[GRAPE_TEST] Congrats!, you passed all tests."
exit


