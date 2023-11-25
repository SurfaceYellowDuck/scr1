#!/bin/bash
set -e
./verilator_install.sh
./run_make.sh
./run_verilator_lint.sh
