NOP

RESTART:
NULL = 0000000000000000
MANYF = FFFFFFFFFFFFFFFF
ONE = 1

ASTEROID_GRAVEYARD = 7FFF7FFF7FFF7FFF

#AND with a vector to remove all but the last element
LAST_VEC_ELEMENT = FFFF

ARRAYSTART = 0000000000000100
#ARRAYSIZE = 0 => 1 ASTEROID IN ARRAY, ARRAYSIZE = 1 => 2 ASTEROIDS IN ARRAY AND SO ON..
ARRAYSIZE = 3
OFFSET = 8 


AST_MODEL_START = 7A

SHIPPOS = 20001f0000000000
SHIPVEL = 0000000000000000
SHIP_REAL_POS = 0

FORWARD_ACCEL = 2

VISUAL_ADD = 0000000000000004
VISUAL_MAX = 0000000000000020
VISUAL_TARGET = 0
VISUAL_ANGLE = 0

SHIP_ANGLE = 0000000000000000
TURN_SPEED = 0000000000030000
ANGLE_MASK = 0000000000FF0000

SLOW_TURN_ADD = 0002000000020000
SLOW_TURN = 0000000000000000

TIMER = 0
LAST_SHOT = 0
RELOAD_TIME = 10
SHOT_TIME = 0
SHOT_LIFE = 5

#Shot  stuff
CURRENT_SHOT = 0
SHOT_AMOUNT = 9
#Remember that  this is HEX
SHOT_OFFSET = 18
SHOT_ARRAY_START = 300
SHOT_MEM_SIZE = 4
#Modify the model memory
LINE_START = 1FC
#LINE_START = 7E
LOAD 0 LINE_START
STOREOBJ 0 7
STOREOBJ 0 4

BRA INIT
FINISHED_INIT:

ITER:
  # ------------ UPDATING SHIP ------------
  LOAD 0 SHIPPOS
  LOAD 1 SHIPVEL

  LOAD 2 NULL

  LOAD 7 SHIP_ANGLE
  LOAD 3 TURN_SPEED

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

  STORE 2 VISUAL_TARGET

  BRA UPDATE_VISUAL
  DONE_UPDATE_VISUAL:
  LOAD 2 VISUAL_ANGLE
  LOAD C LAST_VEC_ELEMENT
  AND VISUAL_ANGLE VISUAL_ANGLE LAST_VEC_ELEMENT
  LSLI VISUAL_ANGLE VISUAL_ANGLE 30

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
  STORE FINAL_POS SHIP_REAL_POS

  BRA BORDERCONTROL
  FINISHED_BORDER_CONTROL:

  LOAD 8 SHIP_REAL_POS
  STOREOBJ SHIP_REAL_POS 0

  #Do shooting stuff
  BTST F 2
  BEQ SHOOT
  HAS_SHOT:

  BRA UPDATE_SHOT
  SHOT_UPDATE_DONE:

  #End of shooting stuff
  
  BRA UPDATE_ASTEROIDS
  DONE_UPDATE_ASTEROIDS:
  
  WAITFRAME

  LOAD 0 TIMER
  ADDI TIMER TIMER 1
  STORE TIMER TIMER

  BRA ITER
#Initialisation
INIT:
  BOX = 19

  LOAD 0 NULL
  ALIAS 0 i
  LOAD 1 ARRAYSIZE
  LOAD 2 AST_MODEL_START
  LOAD 3 ARRAYSTART
  ALIAS 3 CURRENT_ASTEROID
  LOAD 6 BOX

  WHILE i <= ARRAYSIZE
    #Random position
    RANDOM 4 
    MOVHI 5 01FF00FF
    MOVLO 5 00000000
    AND 4 4 5
    STORE.R 4 CURRENT_ASTEROID 0

    #No velocity
    MOVHI 4 00000000
    MOVLO 4 00000000
    STORE.R 4 CURRENT_ASTEROID 1

    #Random rotation
    RANDOM 4
    STORE.R 4 CURRENT_ASTEROID 2
    
    #Small angular velocity
    RANDOM 4
    MOVHI 5 00030003
    MOVLO 5 00030000
    AND 4 5 4
    STORE.R 4 CURRENT_ASTEROID 3

    STORE.R AST_MODEL_START CURRENT_ASTEROID 4
    STORE.R BOX CURRENT_ASTEROID 5
    
    ADDI CURRENT_ASTEROID  CURRENT_ASTEROID 6
    ADDI i i 1
  ENDWHILE
  
  BRA FINISHED_INIT
#Movement 'subroutines'
GORIGHT:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT

  LSRI SHIP_ANGLE SHIP_ANGLE 10

  ADDI SHIP_ANGLE SHIP_ANGLE 80
  #Y add
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 20
  VECADD A A 8

  #X add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 30
  VECADD A A 8

  #Visual turning
  LOAD E VISUAL_MAX
  SUB 2 2 E
  
  VECSUB 1 1 A
  BRA TEST_TURN_LEFT
GOLEFT:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT

  LSRI SHIP_ANGLE SHIP_ANGLE 10

  ADDI SHIP_ANGLE SHIP_ANGLE 80
  #Y add
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 20
  VECADD A A 8

  #X add
  ADDI SHIP_ANGLE SHIP_ANGLE 40
  MULCOS 8 SHIP_ANGLE FORWARD_ACCEL
  LSLI 8 8 30
  VECADD A A 8

  #Visual turning
  LOAD E VISUAL_MAX
  ADD 2 2 E
  
  VECADD 1 1 A
  BRA TESTUP
GOUP:
  LOAD B SHIP_ANGLE
  LOAD C FORWARD_ACCEL
  LOAD A NULL
  LOAD E LAST_VEC_ELEMENT
  #ALIAS A FINAL_VEC

  LSRI SHIP_ANGLE SHIP_ANGLE 10


  ADDI SHIP_ANGLE SHIP_ANGLE 80
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
  ADD 7 7 3

  #Make sure overflow doesn't cause weird issues
  LOAD E ANGLE_MASK
  AND 7 7 E

  BRA TEST_TURN_RIGHT
TURN_RIGHT:
  SUB 7 7 3
  
  #Make sure overflow doesn't gause weird issues
  LOAD E ANGLE_MASK
  AND 7 7 E

  BRA MOVED

UPDATE_VISUAL:
  LOAD A VISUAL_ANGLE
  LOAD B VISUAL_TARGET
  LOAD C VISUAL_ADD

  IF VISUAL_ANGLE <= VISUAL_TARGET
    ADD VISUAL_ANGLE VISUAL_ANGLE VISUAL_ADD
  ENDIF
  IF VISUAL_ANGLE >= VISUAL_TARGET
    SUB VISUAL_ANGLE VISUAL_ANGLE VISUAL_ADD
  ENDIF

  #Save the resulting angle
  STORE VISUAL_ANGLE VISUAL_ANGLE
  BRA  DONE_UPDATE_VISUAL

SHOOT:
  #Set the position  of the shot
  LOAD 0 SHIPPOS 
  LOAD 1 SHIPVEL
  LOAD 7 SHIP_ANGLE

  LOAD 2 TIMER
  LOAD 3 LAST_SHOT

  DBG TIMER

  IF TIMER >= LAST_SHOT
    #Update the reload time
    LOAD 4 RELOAD_TIME

    ADD LAST_SHOT TIMER RELOAD_TIME
    STORE LAST_SHOT LAST_SHOT

    #Create a new  shot
    LOAD 5 CURRENT_SHOT
    LOAD 6 SHOT_MEM_SIZE
    MULT 5 CURRENT_SHOT SHOT_MEM_SIZE
    ALIAS 5 SHOT_OFFSET

    LOAD 6 SHOT_ARRAY_START
    ADD 6 SHOT_ARRAY_START SHOT_OFFSET
    ALIAS 6 SHOT_START

    MOVHI 9 00000000
    MOVLO 9 000000F0
    ALIAS 9 SHOT_VEL
    
    #Store the angle before we mess with it
    STORE.R SHIP_ANGLE SHOT_START 3

    #Calculate the velocity of the shot
    LSRI 7 SHIP_ANGLE 10
    ALIAS 7 ANGLE
    ADDI ANGLE ANGLE 80
    ADDI ANGLE ANGLE 40
    MULCOS 8 ANGLE SHOT_VEL
    LSLI 8 8 20
    VECADD SHIPVEL SHIPVEL 8

    ADDI ANGLE  ANGLE 40
    MULCOS 8 ANGLE SHOT_VEL
    LSLI 8 8 30
    VECADD SHIPVEL SHIPVEL 8

    #Store shot info
    STORE.R SHIPPOS SHOT_START 0
    STORE.R SHIPVEL SHOT_START 1

    #Change to the next shot
    LOAD 5 CURRENT_SHOT
    ADDI CURRENT_SHOT CURRENT_SHOT 1
    MOVHI 6 00000000
    MOVLO 6 0000000a
    ALIAS 6 MAX_SHOT
    IF CURRENT_SHOT >= MAX_SHOT
      MOVHI CURRENT_SHOT 0
      MOVLO CURRENT_SHOT 0
    ENDIF
    STORE CURRENT_SHOT CURRENT_SHOT

    LSLI CURRENT_SHOT CURRENT_SHOT 30
    STOREOBJ CURRENT_SHOT 4


    LOAD 0 SHOT_LIFE
    ADD 4 TIMER SHOT_LIFE
    STORE 4 SHOT_TIME
  ENDIF

  BRA HAS_SHOT

UPDATE_SHOT:
  LOAD 0 NULL
  ALIAS 0 i
  LOAD 1 SHOT_AMOUNT
  LOAD 2 SHOT_ARRAY_START
  ALIAS 2 CURRENT_SHOT_START
  LOAD 3 SHOT_MEM_SIZE
  LOAD E SHOT_OFFSET
  LOAD D LINE_START

  WHILE  i <= SHOT_AMOUNT
    LOAD.R 4 CURRENT_SHOT_START 0
    ALIAS 4 SHOT_POS
    LOAD.R 5 CURRENT_SHOT_START 3
    ALIAS 5 SHOT_ANGLE
    LOAD.R 6 CURRENT_SHOT_START 1
    ALIAS 6 SHOT_VEL

    #Calculate the big position of the shot
    ADD SHOT_POS SHOT_POS SHOT_VEL
    STORE.R SHOT_POS CURRENT_SHOT_START 0

    ALIAS 7 REAL_POS
    LSRI REAL_POS SHOT_POS 30
    #Divide the position
    LSRI REAL_POS REAL_POS 6
    LSLI REAL_POS REAL_POS 30

    MOVHI 9 0
    MOVLO 9 0000FFFF
    LSRI 8 SHOT_POS 20
    AND 8 8 9
    LSRI 8 8 6
    LSLI 8 8 20
    VECADD REAL_POS REAL_POS 8

    STORE.R REAL_POS CURRENT_SHOT_START 2
  
    #Draw  the positions
    STOREOBJ.R REAL_POS SHOT_OFFSET 0
    STOREOBJ.R SHOT_ANGLE SHOT_OFFSET 1
    STOREOBJ.R 0 SHOT_OFFSET 2
    STOREOBJ.R LINE_START SHOT_OFFSET 3
    
    ADD CURRENT_SHOT_START CURRENT_SHOT_START SHOT_MEM_SIZE
    ADDI SHOT_OFFSET SHOT_OFFSET 4
    ADDI i i 1
  ENDWHILE

  BRA SHOT_UPDATE_DONE

UPDATE_ASTEROIDS:
  # ------------ UPDATING ASTEROIDS ------------
  i = 0
  LOAD 0 i
  LOAD 1 ARRAYSIZE
  LOAD 2 OFFSET
  LOAD 3 ARRAYSTART
  WHILE i <= ARRAYSIZE
    #---------------------------------
    #Respawning broken asteroids
    LOAD.R 4 ARRAYSTART 0
    ALIAS 4 POS

    LOAD 5 ASTEROID_GRAVEYARD
    IF POS == ASTEROID_GRAVEYARD
      #Random position
      RANDOM 4 
      MOVHI 5 014000F0
      MOVLO 5 00000000
      AND 4 4 5
      STORE.R 4 CURRENT_ASTEROID 0

      #No velocity
      MOVHI 4 00000000
      MOVLO 4 00000000
      STORE.R 4 CURRENT_ASTEROID 1

      #Random rotation
      RANDOM 4
      STORE.R 4 CURRENT_ASTEROID 2
      
      #Small angular velocity
      RANDOM 4
      MOVHI 5 00030003
      MOVLO 5 00030000
      AND 4 5 4
      STORE.R 4 CURRENT_ASTEROID 3

      LOAD 4 AST_MODEL_START
      STORE.R AST_MODEL_START CURRENT_ASTEROID 4
      LOAD 4 BOX
      STORE.R BOX CURRENT_ASTEROID 5
    ENDIF

    #---------------------------------
	#Update position
    LOAD.R 4 ARRAYSTART 0
    ALIAS 4 POS
    LOAD.R 5 ARRAYSTART 1
    ALIAS 5 VEL
    VECADD POS POS VEL
    STORE.R POS ARRAYSTART 0
    STOREOBJ.R POS OFFSET 0
    
    #Update rotation
    LOAD.R 4 ARRAYSTART 2
    ALIAS 4 ROT
    LOAD.R 5 ARRAYSTART 3
    ALIAS 5 ROTVEL
    VECADD ROT ROT ROTVEL
    STORE.R ROT ARRAYSTART 2
    STOREOBJ.R ROT OFFSET 1
    
    #Scale is never used
    STOREOBJ.R NULL OFFSET 2

    #Give the asteroid a model
    LOAD.R 4 ARRAYSTART 4
    ALIAS 4 MODEL
    STOREOBJ.R MODEL OFFSET 3

    #Collision detection
    LOAD 4 SHIP_REAL_POS
    LOAD.R 5 ARRAYSTART 0
    VECSUB 5 5 4
    LEN 5 5
    ALIAS 5 DISTANCE
    LOAD.R 7 ARRAYSTART 5
    ALIAS 7 HITBOX
    IF DISTANCE <= HITBOX
      BRA GAME_OVER
    ENDIF
    
    #------------------------------
    #Shot collision 
    LOAD 4 NULL
    ALIAS 4 n
    LOAD 6 SHOT_AMOUNT
    LOAD 7 SHOT_ARRAY_START
    ALIAS 7 CURRENT_SHOT_START
    WHILE n <= SHOT_AMOUNT
      #Load the real pos
      LOAD.R 8 CURRENT_SHOT_START 2
      ALIAS 8 SHOT_POS
      
      #Load the asteroid pos
      LOAD.R 9 ARRAYSTART 0

      VECSUB 8 9 8
      LEN 8 8
      ALIAS 8 DISTANCE
    

      LOAD.R 9 ARRAYSTART 5
      ALIAS 9 HITBOX

      IF DISTANCE <= HITBOX
        LOAD 9 ASTEROID_GRAVEYARD
        STORE.R ASTEROID_GRAVEYARD ARRAYSTART 0

        STORE.R 9 CURRENT_SHOT_START 0
        MOVHI 9 00000000
        MOVLO 9 00000000
        STORE.R 9 CURRENT_SHOT_START 1
      ENDIF

      
      LOAD 8 SHOT_MEM_SIZE
      ADD CURRENT_SHOT_START CURRENT_SHOT_START SHOT_MEM_SIZE
      ADDI n n 1
    ENDWHILE
    
    ADDI ARRAYSTART ARRAYSTART 6
    ADDI OFFSET OFFSET 4
    ADDI i i 1
  ENDWHILE

  BRA DONE_UPDATE_ASTEROIDS


BORDERCONTROL:
    LOAD 0 SHIPPOS
    LSRI 1 SHIPPOS 30
    ALIAS 1 SHIPX
    LSRI 2 SHIPPOS 20
    MOVLO 3 0000FFFF
    MOVHI 3 00000000
    AND 2 2 3
    ALIAS 2 SHIPY

    # Check right border
    MOVHI 3 00000000
    MOVLO 3 00005000
    ALIAS 3 XBORDERHI
    IF SHIPX >= XBORDERHI
      #BRA GAME_OVER
      # Clear velocity
      LOAD 8 SHIPVEL
      MOVHI 9 0000FFFF
      MOVLO 9 FFFFFFFF
      AND SHIPVEL SHIPVEL 9
      STORE SHIPVEL SHIPVEL
      #Set pos = border -1
      AND SHIPPOS SHIPPOS 9
      LOAD A ONE
      VECSUB XBORDERHI XBORDERHI ONE
      LSLI XBORDERHI XBORDERHI 30
      VECADD SHIPPOS SHIPPOS XBORDERHI
      STORE SHIPPOS SHIPPOS
    ENDIF

    # Check bottom border
    MOVHI 3 00000000
    MOVLO 3 00003C00
    ALIAS 3 YBORDERHI
    IF SHIPY >= YBORDERHI
      #BRA GAME_OVER
      # Clear velocity
      LOAD 8 SHIPVEL
      MOVHI 9 FFFF0000
      MOVLO 9 FFFFFFFF
      AND SHIPVEL SHIPVEL 9
      STORE SHIPVEL SHIPVEL
      #Set pos = border -1
      AND SHIPPOS SHIPPOS 9
      LOAD A ONE
      VECSUB YBORDERHI YBORDERHI ONE
      LSLI YBORDERHI YBORDERHI 20
      VECADD SHIPPOS SHIPPOS YBORDERHI
      STORE SHIPPOS SHIPPOS
      ENDIF

    # Check left border
    MOVHI 3 00000000
    MOVLO 3 000000F0
    ALIAS 3 XBORDERLO
    IF SHIPX <= XBORDERLO
      #BRA GAME_OVER
      # Clear velocity
      LOAD 8 SHIPVEL
      MOVHI 9 0000FFFF
      MOVLO 9 FFFFFFFF
      AND SHIPVEL SHIPVEL 9
      STORE SHIPVEL SHIPVEL
      #Set pos = border + 1
      AND SHIPPOS SHIPPOS 9
      LOAD A ONE
      VECADD XBORDERLO XBORDERLO ONE
      LSLI XBORDERLO XBORDERLO 30
      VECADD SHIPPOS SHIPPOS XBORDERHI
      STORE SHIPPOS SHIPPOS
    ENDIF
    
    # Check top border
    MOVHI 3 00000000
    MOVLO 3 000000A0
    ALIAS 3 YBORDERLO
    IF SHIPY <= YBORDERLO
      #BRA GAME_OVER
      # Clear velocity
      LOAD 8 SHIPVEL
      MOVHI 9 FFFF0000
      MOVLO 9 FFFFFFFF
      AND SHIPVEL SHIPVEL 9
      STORE SHIPVEL SHIPVEL
      #Set pos = border + 1
      AND SHIPPOS SHIPPOS 9
      LOAD A ONE
      VECADD YBORDERLO YBORDERLO ONE
      LSLI YBORDERLO YBORDERLO 20
      VECADD SHIPPOS SHIPPOS YBORDERLO
      STORE SHIPPOS SHIPPOS
      ENDIF

  BRA FINISHED_BORDER_CONTROL

GAME_OVER:
  # GAME OVER!
  BRA RESTART
