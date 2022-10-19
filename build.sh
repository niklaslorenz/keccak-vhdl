#!/bin/bash
echo build sha3-c
cmake --build ./build/sha3-c/Debug/

echo build sha3-vhdl
pushd . > /dev/null
cd ./sha3-vhdl
./build.sh
popd > /dev/null
