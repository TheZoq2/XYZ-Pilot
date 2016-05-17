NOP

i = 0
num = A
offset = 0

LOAD 0 i
LOAD 1 num
LOAD 5 offset

POSVEC = 010001000000000
ADDVEC = 010001000000000
NULLVEC = 0000000000000000

LOAD 2 POSVEC
LOAD 3 ADDVEC
LOAD 4 NULLVEC

# Following statement logic is reveresed (i <= num)
WHILE num <= i
  VECADD POSVEC POSVEC ADDVEC
  STOREOBJ.R POSVEC offset 0
  STOREOBJ.R NULLVEC offset 1
  STOREOBJ.R NULLVEC offset 2
  STOREOBJ.R NULLVEC offset 3
  ADDI offset offset 4
	
  ADDI i i 1
ENDWHILE

LOOP:
  BRA LOOP