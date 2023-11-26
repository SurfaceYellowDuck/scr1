#!/bin/sh
set -e
./CI/verilator_install.sh
./CI/run_make.sh
./CI/run_verilator_lint.sh
./CI/run_lint_shell_scripts.sh
