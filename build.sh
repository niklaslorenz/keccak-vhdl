#!/bin/bash
echo build sha3-c
cmake --build ./build/sha3-c/Debug/
passed_cmake_build=$?
if [ $passed_cmake_build -ne 0 ]; then
echo -e "\e[31mFailed cmake build\e[0m"
exit $passed_cmake_build
fi

echo build sha3-vhdl
pushd . > /dev/null
cd ./sha3-vhdl
./build.sh
popd > /dev/null
