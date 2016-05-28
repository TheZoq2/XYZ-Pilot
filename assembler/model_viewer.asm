#Make sure asteroids don't spawn with 0 velocity
NOP

model1_start = 0
model2_start = 7A
model3_start = BE
model4_start = 203

obj_start = 100
LOAD 1 obj_start

LOAD 0 model1_start
STORE.R 0 obj_start 0

LOAD 0 model2_start
STORE.R 0 obj_start 1

LOAD 0 model3_start
STORE.R 0 obj_start 2

LOAD 0 model4_start
STORE.R 0 obj_start 3

current_obj = 0

pos = 00A0007800000000 
LOAD 0 pos
STOREOBJ pos 0

angle = 0
add_angle =  0001000200030000 

xangle = 0
yangle = 0
zangle = 0

ITER:
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
  TEST_SWITCH:
    BTST F 2
    BEQ DO_SWITCH
    DONE_INPUT:

  LOAD 0 current_obj
  LOAD.R 1 current_obj 100
  ALIAS 1 current_model


  STOREOBJ current_model 3
  #STOREOBJ current_model 3
  LOAD 0 pos
  STOREOBJ current_obj 0

  MOVLO 2 0
  MOVLO 2 FFFF

  #LOAD 0 angle
  #LOAD 1 add_angle
  LOAD 0 zangle 
  ALIAS 0 angle
  AND zangle zangle 2
  LSLI 0 0 10

  LOAD 1 yangle 
  AND yangle yangle 2
  LSLI 1 1 20
  VECADD 0 0 1

  LOAD 1 xangle 
  AND xangle xangle 2
  LSLI 1 1 30
  VECADD 0 0 1
  
  #ADD angle angle add_angle

  STORE angle angle
  STOREOBJ angle 1
  WAITFRAME

  BRA ITER


DO_SWITCH:
  LOAD 0 current_obj
  
  ADDI current_obj current_obj 1
  
  MOVHI 1 00000000
  MOVLO 1 00000004
  ALIAS 1 MAX_OBJ
  IF current_obj >= MAX_OBJ
    MOVHI current_obj 0
    MOVLO current_obj 0
  ENDIF

  STORE current_obj current_obj
  BRA DONE_INPUT


#Movement 'subroutines'
GORIGHT:
  LOAD 0 zangle
  ADDI 0 0 2
  STORE 0 zangle
  BRA TEST_TURN_LEFT
GOLEFT:
  LOAD 0 yangle
  SUBI 0 0 2
  STORE 0 zangle
  BRA TESTUP
GOUP:
  LOAD 0 xangle
  ADDI 0 0 2
  STORE 0 xangle
  BRA TESTRIGHT
TURN_LEFT:
  LOAD 0 yangle
  ADDI 0 0 2
  STORE 0 yangle
  BRA TEST_TURN_RIGHT
TURN_RIGHT:
  LOAD 0 yangle
  SUBI 0 0 2
  STORE 0 yangle
  BRA TEST_SWITCH
