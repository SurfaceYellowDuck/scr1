#!/bin/bash
set -e
./verilator_install.sh
./load_toolchain.sh
./run_make.sh
./run_verilator_lint.sh
