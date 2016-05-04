import sys

def twos_comp(val, bits):
    if val < 0:
        val = abs(val)*2
    return val                         # return positive value as is

#Read coords from stdin
input_file = sys.stdin.read();

input_lines = input_file.split("\n");

current_index = 0;
for line in input_lines:
    coords = line.split(" ");

    result_line = "";
    failed = False;

    result_line += "{} => x\"".format(current_index)
    for coord in coords:
        try:
            result_line += ("{:04x}".format(twos_comp(int(coord), 16)));
        except(ValueError):
            pass
    
    result_line += ("\",");

    if len(line) != 0:
        print(result_line);
        current_index += 1;


print("{} => x\"ffffffffffffffff\",".format(current_index));
print("{} => x\"ffffffffffffffff\",".format(current_index + 1));
    

