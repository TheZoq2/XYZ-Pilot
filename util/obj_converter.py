import sys

points = [];
obj_lines = []

#Read coords from stdin
input_file = sys.stdin.read();

input_lines = input_file.split("\n");

current_index = 0;
for line in input_lines:
    coords = line.split(" ");

    if coords[0] == "v":
        x_coord = int(round(float(coords[1])))
        y_coord = int(round(float(coords[2])))
        z_coord = int(round(float(coords[3])))
        points.append((x_coord, y_coord, z_coord));
    
    elif coords[0] == "l":
        obj_lines.append((points[int(coords[1])-1],  points[int(coords[2])-1]))

for line in obj_lines:
    for point in line:
        for coord in point:
            print(coord, end=" ");
        print(0)
