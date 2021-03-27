cmake_minimum_required(VERSION 3.10)

project(zig_hello NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")
enable_language(ZIG)

add_executable(zig_hello zig_hello.zig)

# add_custom_command(
#    OUTPUT "${CMAKE_PROJECT_NAME}.o"
#    COMMAND ${CMAKE_ZIG_COMPILER} "build-obj" "${PROJECT_SOURCE_DIR}/${CMAKE_PROJECT_NAME}.zig"
#    )

# add_executable(zig_hello "empty.c" "${CMAKE_PROJECT_NAME}.o")
