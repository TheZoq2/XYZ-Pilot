#!/bin/bash
cd ../vhdl/
make lab.prog
cd -
python assembler.py $1 && cat ${1}.out > /dev/ttyUSB0
