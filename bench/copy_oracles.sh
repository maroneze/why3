#!/bin/bash

# This script can be used when upgrading the prover versions in the
# bench/ce-bench and bench/check-ce-bench scripts.

# This script copies the oracle files in the folders bench/ce/oracles
# and bench/check-ce/oracles and rename the files in replacing the older
# version of a prover by a newer one.

for file in bench/ce/oracles/*_CVC4,1.7_*.oracle; do
  cp "$file" "${file//CVC4,1.7/CVC4,1.8}"
done

for file in bench/check-ce/oracles/*_CVC4,1.7_*.oracle; do
  cp "$file" "${file//CVC4,1.7/CVC4,1.8}"
done

for file in bench/check-ce/petiot2018/oracles/*_CVC4,1.7.oracle; do
  cp "$file" "${file//CVC4,1.7/CVC4,1.8}"
done
