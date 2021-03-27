cmake_minimum_required(VERSION 3.10)
project(app_project)
add_executable(myapp main.c)
install(TARGETS myapp DESTINATION bin)
