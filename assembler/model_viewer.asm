#Make sure asteroids don't spawn with 0 velocity
NOP

model1_start = 0
model2_start = 7A
model3_start = BE

obj_start = 100
LOAD 1 obj_start

LOAD 0 model1_start
STORE.R 0 obj_start 0

LOAD 0 model2_start
STORE.R 0 obj_start 1

LOAD 0 model3_start
STORE.R 0 obj_start 2

current_obj = 0

pos = 00A0007800000000 
LOAD 0 pos
STOREOBJ pos 0

angle = 0
add_angle =  0001000200030000 

ITER:
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

  LOAD 0 angle
  LOAD 1 add_angle
  ADD angle angle add_angle

  STORE angle angle
  STOREOBJ angle 1
  WAITFRAME
  WAITFRAME

  BRA ITER


DO_SWITCH:
    LOAD 0 current_obj
    
    ADDI current_obj current_obj 1
    
    MOVHI 1 00000000
    MOVLO 1 00000003
    ALIAS 1 MAX_OBJ
    IF current_obj >= MAX_OBJ
        MOVHI current_obj 0
        MOVLO current_obj 0
    ENDIF

    STORE current_obj current_obj
    BRA DONE_INPUT
