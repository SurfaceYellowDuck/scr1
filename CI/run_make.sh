#!/bin/bash
path_=$(find /etc/ -name "riscv64-unknown-elf-gcc" | head -n 1)
if [ -e $path_ ];
	then 
	dir_path=$(dirname "$path_")
	export PATH="$PATH:$dir_path"
	cd ..
	git submodule update --init --recursive
	make
else echo "You don't have a toolchain"; fi;


