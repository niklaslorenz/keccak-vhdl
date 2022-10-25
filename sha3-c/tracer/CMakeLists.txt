CMAKE_MINIMUM_REQUIRED(VERSION 3.10)

add_executable(tracer src/tracer.cpp)
target_link_libraries(tracer PUBLIC keccak)