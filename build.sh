#!/bin/bash
echo build sha3-c
cmake --build ./build/sha3-c/Debug/
passed_build_sha3c=$?
if [ $passed_build_sha3c -ne 0 ]; then
echo -e "\e[31mFailed to build sha3-c\e[0m"
fi

echo build sha3-vhdl
pushd . > /dev/null
cd ./sha3-vhdl
./build.sh
passed_build_sha3vhdl=$?
popd > /dev/null
if [ $passed_build_sha3vhdl -ne 0 ]; then
echo -e "\e[31mFailed to build sha3-vhdl\e[0m"
fi

echo build sha3-icore
pushd . > /dev/null
cd ./sha3-icore
./build.sh
passed_build_sha3icore=$?
popd > /dev/null
if [ $passed_build_sha3icore -ne 0 ]; then
echo -e "\e[31mFailed to build sha3-icore\e[0m"
fi

echo "+--------- Summary ----------"
echo -e "|sha3-c:     $([ $passed_build_sha3c -eq 0 ]     && echo -e "\e[32mbuilt\e[0m" || echo -e "\e[31mfailed\e[0m")"
echo -e "|sha3-vhdl:  $([ $passed_build_sha3vhdl -eq 0 ]  && echo -e "\e[32mbuilt\e[0m" || echo -e "\e[31mfailed\e[0m")"
echo -e "|sha3-icore: $([ $passed_build_sha3icore -eq 0 ] && echo -e "\e[32mbuilt\e[0m" || echo -e "\e[31mfailed\e[0m")"
echo "+----------------------------"

exit $([ $(($passed_build_sha3c + $passed_build_sha3vhdl + $passed_build_sha3icore)) -ne 0 ] && echo 1 || echo 0 )
