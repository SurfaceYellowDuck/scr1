#!/bin/bash
names=$(find ./CI -name "*.sh")
shellcheck $names

