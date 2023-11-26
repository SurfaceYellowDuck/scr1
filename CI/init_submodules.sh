#!/bin/bash
if [ -z "$(ls -A dependencies/coremark)" ]; then
    git submodule update --init --recursive
    
fi
