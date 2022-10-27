#!/bin/bash

echo run cmake tests

pushd . > /dev/null
cd ./build/sha3-c/Debug
ctest
passed_cmake_tests=$?
popd > /dev/null
if [ $passed_cmake_tests -ne 0 ]; then
echo -e "\e[31mFailed\e[0m cmake tests"
exit $passed_cmake_tests
fi

cp -r ./test_instances ./build
mkdir -p ./build/test_solutions/
rm -f ./build/test_solutions/*.txt

pushd . > /dev/null
cd ./build
echo generate test solutions
tracer="./sha3-c/Debug/tracer/tracer"
$tracer theta ./test_instances/raw_state_arrays.txt ./test_solutions/theta.txt
$tracer rho ./test_instances/raw_state_arrays.txt ./test_solutions/rho.txt
$tracer pi ./test_instances/raw_state_arrays.txt ./test_solutions/pi.txt
$tracer chi ./test_instances/raw_state_arrays.txt ./test_solutions/chi.txt
$tracer iota 0 ./test_instances/raw_state_arrays.txt ./test_solutions/iota_0.txt
$tracer iota 11 ./test_instances/raw_state_arrays.txt ./test_solutions/iota_11.txt
$tracer iota 23 ./test_instances/raw_state_arrays.txt ./test_solutions/iota_23.txt
$tracer keccak-p 0 ./test_instances/raw_state_arrays.txt ./test_solutions/keccak_p.txt
$tracer keccak-f ./test_instances/raw_state_arrays.txt ./test_solutions/keccak_f.txt
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
