#!/bin/sh

rm -rf build/*
cmake -S . -B build/
cd build && make
