#!/bin/bash
set -e
./CI/verilator_install.sh
./CI/load_toolchain.sh
path=$(pwd)
export PATH="$PATH:$path/riscv-gcc/bin"
./CI/run_make.sh
./CI/run_verilator_lint.sh
./CI/run_lint_shell_scripts.sh
