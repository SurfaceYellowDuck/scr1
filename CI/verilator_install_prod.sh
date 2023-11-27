#!/bin/bash
set -e
path=$(pwd)
export PATH="$PATH:$pwd/verilator_build"
if [[ ! -x "$(command -v verilator)" ]]; then
	wget --load-cookies /tmp/cookies.txt \
 "https://docs.google.com/uc?export=download&confirm=\
$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies \
--no-check-certificate 'https://docs.google.com/uc?export=download&id=1M0mMx17I3bMi-3t-eNHsU5G9MjiTI9ww' -O- | sed -rn \
 's/.*confirm=([0-9A-Za-z_]+).*/\n/p')&id=1M0mMx17I3bMi-3t-eNHsU5G9MjiTI9ww"\
 -O verilator_build.zip&& rm -rf /tmp/cookies.txt
	unzip verilator_build.zip
	rm -rf verilator_build.zip
fi

