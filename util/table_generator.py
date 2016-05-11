import math;

for i in range(1, 255):
    val = math.cos(i/255 * math.pi * 2)
    
    int_val = int(val * 2**8);

    first_pos = "8" if int_val < 0 else "0"
    print("x\"{1}{2:03x}\" when x\"{0:02x}\",".format(i, first_pos, abs(int_val)));
