#!/bin/bash

WAVE_PATH=wave.ghw

ghdl -m  --ieee=synopsys -fexplicit $1

ANAL_STATUS=$?
echo "Exit with code: $ANAL_STATUS"

if [ $ANAL_STATUS -eq 0 ]; then
    echo "##############################################################"
    ghdl -r $1 --stop-time=$2 --wave=$WAVE_PATH
    #gtkwave $WAVE_PATH
fi

