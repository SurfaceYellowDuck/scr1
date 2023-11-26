#!/bin/sh
set -e
if [ ! -e "./riscv-gcc/bin" ]; then
	wget https://se.math.spbu.ru/riscv-public/sc-dt-2023.08/riscv-gcc.tar.xz
	tar -xf riscv-gcc.tar.xz
	rm riscv-gcc.tar.xz
fi
