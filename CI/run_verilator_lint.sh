#!/bin/bash

names=$(find ./ -name "*.sv")
root_dir=$(pwd)
verilator --lint-only -Wall -Wno-fatal $names -I"$root_dir/src/includes" -I"$root_dir/src/tb"
