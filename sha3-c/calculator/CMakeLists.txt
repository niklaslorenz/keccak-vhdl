cmake_minimum_required(VERSION 3.10)

add_executable(calculator src/calculator.cpp)
target_link_libraries(calculator PUBLIC keccak)
