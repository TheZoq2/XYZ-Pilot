# NOP a little
NOP

i = 0
END = 60
VEC = 0000000000000000
VEC2 = 0000000000000000
POSXADD = 0001000000000000
POSYADD = 0000000100000000
POSZADD = 0000000000010000

LOAD 0 VEC
LOAD 1 VEC2

LOOP:

    #LOAD 1 i
    LOAD 2 END
    LOAD 3 POSYADD
    LOAD 4 POSZADD


    #ADDI 1 1 1

    VECADD 0 0 3
    VECADD 1 1 3

    VECADD 0 0 4
    VECADD 1 1 4

    STOREOBJ 0 1
    STOREOBJ 1 5

    WAITFRAME
BRA LOOP
