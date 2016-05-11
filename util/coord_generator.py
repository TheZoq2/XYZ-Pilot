import math;

centerX = 0;
centerY = 0;
length = 20;

line_amount = 16
for i in range(0,line_amount):
    print("{} ".format(centerX + int(length * math.cos((math.pi * 2 / (line_amount)) * i))), end = '')
    print("{} ".format(centerX + int(length * math.sin((math.pi * 2 / (line_amount)) * i))), end = '')
    print("0 ", end = '')
    print("0")
