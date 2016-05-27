#!/bin/python
import sys

def tohex(val, nbits):
    return "{:04x}".format((val + (1 << nbits)) % (1 << nbits))

#Read coords from stdin
input_file = sys.stdin.read();

input_lines = input_file.split("\n");

current_index = 0;

if len(sys.argv) == 2:
    current_index = int(sys.argv[1])

for line in input_lines:
    coords = line.split(" ");

    result_line = "";
    failed = False;

    result_line += "{} => x\"".format(current_index)
    for coord in coords:
        try:
            #result_line += ("{:04x}".format(twos_comp(int(coord), 16)));
            result_line += ("{}".format(tohex(int(coord), 16)));
        except(ValueError):
            pass
    
    result_line += ("\",");

    if len(line) != 0:
        print(result_line);
        current_index += 1;


print("{} => x\"ffffffffffffffff\",".format(current_index));
print("{} => x\"ffffffffffffffff\",".format(current_index + 1));
    

