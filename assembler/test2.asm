NOP

W = 8
A = 4
D = 2
SPACE = 1

VEC = 0080008000000000
VECADDRIGHT = 0002000000000000
VECADDDOWN = 0000000200000000 

LOAD 0 VEC
LOAD 1 VEC
LOAD 3 VEC
LOAD 5 VEC
LOAD 6 VEC
LOAD 2 VECADDRIGHT
LOAD 4 VECADDDOWN

ITER:
  #CMP 2 4 TILLS VIDARE
  # Obj 1 åker 
  TESTLEFT:
    BTST F 2
    BEQ GOLEFT
  TESTDOWN:
    BTST F 0
    BEQ GODOWN
  TESTUP:
    BTST F 3
    BEQ GOUP
  TESTRIGHT:
    BTST F 1
    BEQ GORIGHT

  BRA MOVED
  
  GORIGHT:
    ADD 0 0 2
    SUB 1 1 2
    ADD 3 3 2
    ADD 3 3 2
    SUB 5 5 2
    SUB 5 5 2
    BRA MOVED
  GOLEFT:
    SUB 0 0 2
    ADD 1 1 2
    SUB 3 3 2
    SUB 3 3 2
    ADD 5 5 2
    ADD 5 5 2
    BRA TESTDOWN
  GODOWN:
    ADD 0 0 4
    SUB 1 1 4
    ADD 3 3 4
    ADD 3 3 4
    SUB 5 5 4
    SUB 5 5 4
    BRA TESTUP
  GOUP:
    SUB 0 0 4
    ADD 1 1 4
    SUB 3 3 4
    SUB 3 3 4
    ADD 5 5 4
    ADD 5 5 4
    BRA TESTRIGHT

  MOVED:

  STOREOBJ 0 0
  STOREOBJ 1 4
  STOREOBJ 3 8
  STOREOBJ 5 12
  WAITFRAME
  WAITFRAME
  BRA ITER
