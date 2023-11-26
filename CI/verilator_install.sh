#!/bin/bash
set -e
if [[ ! -x "$(command -v verilator)" ]]; then
	git clone https://github.com/verilator/verilator
	unset VERILATOR_ROOT
	cd verilator
	git pull
	git checkout v5.014
	autoconf
	./configure
	make
	sudo make install
	cd ..
	rm -rf verilator
fi

