NOP

i = 0
num = A

LOAD 0 i
LOAD 1 num

POSVEC = 001001000000000
ADDVEC = 001001000000000
NULLVEC = 0000000000000000

LOAD 2 POSVEC
LOAD 3 ADDVEC
LOAD 4 NULLVEC

ALIAS 5 offset
	
WHILE i <= num
  VECADD POSVEC POSVEC ADDVEC
  STOREOBJ.R POSVEC offset 0
  STOREOBJ.R NULLVEC offset 1
  STOREOBJ.R NULLVEC offset 2
  STOREOBJ.R NULLVEC offset 3
  ADDI offset offset 1
	
  SUBI i i 1

LOOP:
  BRA LOOP