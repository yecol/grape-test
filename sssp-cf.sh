#!/bin/bash
yhrun -N 5 -n 5 -p MEM_128 -c 1 ./grape-engine --command_file ./sssp-cf.gql --v 2 --deserialize true
