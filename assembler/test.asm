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

# Alias functionality demo
x = 10
y = 20
z = 0

# Implicit generation of 'ALIAS 0 x' and 'ALIAS 1 y'
LOAD 0 x
LOAD 1 y

ALIAS 2 z

# Perform artitmetics x + y and store in register z
ADD z x y

# Store z register in z variable
STORE z z

# Infinite loop
LOOP:
    BRA LOOP