# NOP a little
NOP
NOP
NOP
NOP

# Variable test
X = FF
Y = 1337
Z = Y

# Finite loop with excessive memory access
i = 0
len = 10
ITER:
    # Increase i by 1
    LOAD 0 i
    ADDI 0 0 1
    STORE 0 i

    # Compare i to len
    LOAD 1 len
    CMP 0 1

    # Continue iterating if i != len
    BNE ITER

# Infinite loop
LOOP:
    BRA LOOP