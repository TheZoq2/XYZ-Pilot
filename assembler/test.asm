# NOP a little
NOP
NOP
NOP
NOP

# Variable test
X = FF
Y = 1337
Z = 0123456789ABCDEF

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

WHILE i != len
    LOAD 0 i
    ADDI 0 0 1
    STORE 0 i

    IF X == Y
        Z = 10
    ENDIF
ENDWHILE

# Infinite loop
LOOP:
    BRA LOOP