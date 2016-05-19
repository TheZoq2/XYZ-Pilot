NOP

NULL = 0000000000000000
MANYF = FFFFFFFFFFFFFFFF

#AND with a vector to remove all but the last element
LAST_VEC_ELEMENT = FFFF

ARRAYSTART = 0000000000000100
ARRAYEND = 0000000000000100
#ARRAYSIZE = 0 => 1 ASTEROID IN ARRAY, ARRAYSIZE = 1 => 2 ASTEROIDS IN ARRAY AND SO ON..
ARRAYSIZE = 1
OFFSET = 4

SHIPPOS = 25001f0000000000
SHIPVEL = 0000000000000000

FORWARD_ACCEL = 2

VISUAL_ADD = 0020000000000000

SHIP_ANGLE = 0000000000000000
TURN_SPEED = 0000000000030000
ANGLE_MASK = 0000000000FF0000

SLOW_TURN_ADD = 0002000000020000
SLOW_TURN = 0000000000000000

COUNTER = 0
COUNTMAX = 2


#Modify the model memory
ASTEROID_START = 7A
LOAD 0 ASTEROID_START
STOREOBJ 0 7

ITER:
  # ------------ UPDATING SHIP ------------
  LOAD 0 SHIPPOS
  LOAD 1 SHIPVEL

  LOAD 2 NULL
  ALIAS 2 VISUAL_ANGLE

  LOAD 7 SHIP_ANGLE
  LOAD 8 TURN_SPEED


  TESTLEFT:
    BTST F 5
    BEQ GOLEFT
  TESTUP:
    BTST F 6
    BEQ GOUP
  TESTRIGHT:
    BTST F 3
    BEQ GORIGHT
  
  TEST_TURN_LEFT:
    BTST F 0
    BEQ TURN_LEFT
  TEST_TURN_RIGHT:
    BTST F 1
    BEQ TURN_RIGHT
  

  MOVED:

  #Update ship position and angle
  #Add the velocity of the ship
  ADD 0 0 1
  STORE 0 SHIPPOS
  STORE 1 SHIPVEL
  STORE 7 SHIP_ANGLE
  #Rotate the ship
  VECADD SHIP_ANGLE VISUAL_ANGLE SHIP_ANGLE
  STOREOBJ SHIP_ANGLE 1

  #Divide the actual position to get the visual position
  LOAD C LAST_VEC_ELEMENT
  LOAD 8 NULL
  ALIAS 8 FINAL_POS

  #Shift 48 bits
  LSRI 9 SHIPPOS 30
  AND 9 9 LAST_VEC_ELEMENT
  #Divide speed by 8
  LSRI 9 9 6
  #Shift back 48 bits
  LSLI 9 9 30 
  VECADD FINAL_POS FINAL_POS 9

  #Shift 32 bits
  LSRI 9 SHIPPOS 20
  AND 9 9 LAST_VEC_ELEMENT
  #Divide speed by 8
  LSRI 9 9 6
  #Shift back 32 bits
  LSLI 9 9 20 
  VECADD FINAL_POS FINAL_POS 9

  #Update the visual position
  STOREOBJ FINAL_POS 0

  # ------------ UPDATING ASTEROIDS ------------
  LOAD 3 ARRAYSTART
  MOVHI 0 00010000
  MOVLO 0 0
  STORE.R 0 ARRAYSTART 1
  MOVHI 0 00000001
  STORE.R 0 ARRAYSTART 7
  i = 0
  LOAD 0 i
  LOAD 1 ARRAYSIZE
  LOAD 2 OFFSET
  LOAD 3 ARRAYSTART
  LOAD 6 ASTEROID_START
  WHILE i <= ARRAYSIZE
	#Move the asteroid
    LOAD.R 4 ARRAYSTART 0
    ALIAS 4 POS
    LOAD.R 5 ARRAYSTART 1
    ALIAS 5 VEL
    VECADD POS POS VEL
    STORE.R POS ARRAYSTART 0
    STOREOBJ.R POS OFFSET 0
    STOREOBJ.R NULL OFFSET 1
    STOREOBJ.R NULL OFFSET 2
    STOREOBJ.R ASTEROID_START OFFSET 3
    #Spin the asteroid
    
    ADDI ARRAYSTART ARRAYSTART 6
    ADDI OFFSET OFFSET 4
    ADDI i i 1
  ENDWHILE

  WAITFRAME

  BRA ITER

#Movement 'subroutines'
GORIGHT:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT

  LSRI SHIP_ANGLE SHIP_ANGLE 10

  #Y add
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 20
  VECADD A A 8

  #X add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 30
  VECADD A A 8

  LOAD E VISUAL_ADD
  VECADD 2 2 E
  
  VECSUB 1 1 A
  BRA TEST_TURN_LEFT
GOLEFT:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT

  LSRI SHIP_ANGLE SHIP_ANGLE 10

  #Y add
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 20
  VECADD A A 8

  #X add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 30
  VECADD A A 8

  LOAD E VISUAL_ADD
  VECSUB 2 2 E
  
  VECADD 1 1 A
  BRA TESTUP
GOUP:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT
  #ALIAS A FINAL_VEC

  LSRI SHIP_ANGLE SHIP_ANGLE 10


  #Y add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 20
  VECADD A A 8

  #X add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 30
  VECADD A A 8
  
  VECADD 1 1 A
  BRA TESTRIGHT
TURN_LEFT:
  ADD 7 7 8

  #Make sure overflow doesn't gause weird issues
  LOAD E ANGLE_MASK
  AND 7 7 E

  BRA TEST_TURN_RIGHT
TURN_RIGHT:
  SUB 7 7 8
  
  #Make sure overflow doesn't gause weird issues
  LOAD E ANGLE_MASK
  AND 7 7 E

  BRA MOVED

