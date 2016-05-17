#!/bin/bash
if [ -z $1 ]; then
    echo "missing asm script"
    exit -1
fi

python assembler.py $1 

ASM_STATUS=$?
if [ $ASM_STATUS -eq 0 ]; then
    cd ../vhdl/
    make lab.prog
    cd -

    cat ${1}.out > /dev/ttyUSB0
else
    echo "Assembler failed"
    exit -1
fi



