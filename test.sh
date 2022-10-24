#!/bin/bash

cp -r ./test_instances ./build
mkdir -p ./build/test_solutions/
rm -f ./build/test_solutions/*.txt

echo generate test solutions
pushd . > /dev/null
cd ./build
./sha3-c/Debug/calculator/calculator theta ./test_instances/raw_state_arrays.txt ./test_solutions/theta.txt
./sha3-c/Debug/calculator/calculator rho ./test_instances/raw_state_arrays.txt ./test_solutions/rho.txt
./sha3-c/Debug/calculator/calculator pi ./test_instances/raw_state_arrays.txt ./test_solutions/pi.txt
./sha3-c/Debug/calculator/calculator chi ./test_instances/raw_state_arrays.txt ./test_solutions/chi.txt
./sha3-c/Debug/calculator/calculator iota ./test_instances/raw_state_arrays.txt ./test_solutions/iota.txt
./sha3-c/Debug/calculator/calculator keccak-p ./test_instances/raw_state_arrays.txt ./test_solutions/keccak_p.txt
./sha3-c/Debug/calculator/calculator keccak-f ./test_instances/raw_state_arrays.txt ./test_solutions/keccak_f.txt
popd > /dev/null

echo read test instances
test_instances=$(<./build/sha3-vhdl/test_instances)

echo run vhdl tests
failed_tests=0
passed_tests=0
total_tests=0
pushd . > /dev/null
cd ./build/sha3-vhdl
for f in ${test_instances[@]}; do
((total_tests++))
echo -n [${f}]
nvc -r ${f}
failed=$?
if [ $failed -ne 0 ]; then
((failed_tests++))
echo failed
else
((passed_tests++))
echo ok
fi
done
echo executed ${total_tests} tests
echo passed: ${passed_tests}
echo failed: ${failed_tests}
popd > /dev/null
exit $failed
