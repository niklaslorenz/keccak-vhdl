cmake_minimum_required(VERSION 3.20)

project(keccak)

add_library(keccak src/keccak.cpp)
target_include_directories(keccak PUBLIC include)