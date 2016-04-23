#!/bin/bash

WAVE_PATH=wave.ghw

ghdl -m $1
ghdl -r $1 --stop-time=$2 --wave=$WAVE_PATH
#gtkwave $WAVE_PATH

