#!/bin/bash

WAVE_PATH=wave.ghw

ghdl -m  --ieee=synopsys -fexplicit $1 

ANAL_STATUS=$?
echo "Exit with code: $?"
echo "#######################################################"

ghdl -r $1 --stop-time=$2 --wave=$WAVE_PATH
#gtkwave $WAVE_PATH

