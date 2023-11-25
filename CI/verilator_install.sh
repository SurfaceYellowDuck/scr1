#!/bin/bash
set -e
./check_verilator_deps.sh
git clone https://github.com/verilator/verilator
unset VERILATOR_ROOT
cd verilator
git pull
git checkout v5.014
autoconf
./configure
make -j "$(nproc)" 
sudo make install
rm -rf verilator
