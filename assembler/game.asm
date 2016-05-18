NOP

NULL = 0000000000000000
MANYF = FFFFFFFFFFFFFFFF

#AND with a vector to remove all but the last element
LAST_VEC_ELEMENT = FFFF

ARRAYSTART = 0000000000000100
ARRAYEND = 0000000000000100
ARRAYSIZE = 0 

SHIPPOS = 00f000f000000000
SHIPVEL = 0000000000000000

FORWARD_ACCEL = 3

VISUAL_ADD = 0020000000000000

SHIP_ANGLE = 0000000000000000
TURN_SPEED = 0000000000050000
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
  LSRI 9 9 4
  #Shift back 48 bits
  LSLI 9 9 30 
  VECADD FINAL_POS FINAL_POS 9

  #Shift 32 bits
  LSRI 9 SHIPPOS 20
  AND 9 9 LAST_VEC_ELEMENT
  #Divide speed by 8
  LSRI 9 9 4
  #Shift back 32 bits
  LSLI 9 9 20 
  VECADD FINAL_POS FINAL_POS 9

  #Update the visual position
  STOREOBJ FINAL_POS 0


  #Spin the asteroid
  LOAD 2 SLOW_TURN_ADD
  LOAD 5 SLOW_TURN

  VECADD 5 5 2
  #LSLI 5 5 1
  STOREOBJ 5 5

  STORE 5 SLOW_TURN

  WAITFRAME
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

