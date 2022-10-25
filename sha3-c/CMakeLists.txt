cmake_minimum_required(VERSION 3.10)

project(keccak)
set(CMAKE_CXX_STANDARD 14)

include(FetchContent)
FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG release-1.12.1
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_library(keccak src/keccak_p.cpp src/sha3.cpp)
target_include_directories(keccak PUBLIC include)

add_subdirectory(calculator)
add_subdirectory(tracer)
add_subdirectory(test)
