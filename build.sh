#!/bin/bash
mkdir -p ./sha3-c/build/Debug
pushd .
cd ./sha3-c/build/Debug
cmake -DCMAKE_BUILD_TYPE=Debug ../../
cmake --build .
popd
mkdir -p ./test_instances
mkdir -p ./test_results
rm ./test_results/*.txt
./sha3-c/build/Debug/verifier/verifier theta ./test_instances/raw_state_arrays.txt ./test_results/theta.txt
./sha3-c/build/Debug/verifier/verifier rho ./test_instances/raw_state_arrays.txt ./test_results/rho.txt
pushd .
cd ./sha3-vhdl
make -f ./theta_test.make run
make -f ./rho_test.make run
popd
