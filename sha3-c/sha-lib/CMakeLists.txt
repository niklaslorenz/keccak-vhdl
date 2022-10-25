cmake_minimum_required(VERSION 3.10)

enable_testing()

add_library(keccak src/keccak_p.cpp src/sha3.cpp)
target_include_directories(keccak PUBLIC include)

add_subdirectory(test)