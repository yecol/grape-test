#!/bin/bash
yhrun -N 4 -n 64 -p MEM_128 -c 1 ./grape-engine --command_file ./sim-t.gql --v 2 # --deserialize true

