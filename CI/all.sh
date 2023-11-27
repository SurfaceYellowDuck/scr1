#!/bin/bash
set -e
./CI/load_toolchain.sh
path=$(pwd)
export PATH="$PATH:$path/riscv-gcc/bin"
export PATH="$PATH:$path"
./CI/run_make.sh
./CI/run_verilator_lint.sh
./CI/run_lint_shell_scripts.sh
