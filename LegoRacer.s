.equ PS2_BASE, 0xFF200100
.equ PS2_CONTROL, 0xFF200104
.equ JP2_BASE, 0xFF200060
.equ TIMER0_BASE, 0xFF202000
.equ TIMER0_STATUS, 0
.equ TIMER0_CONTROL, 4
.equ TIMER0_PERIODL, 8
.equ TIMER0_PERIODH, 12
.equ TIMER0_SNAPL, 16
.equ TIMER0_SNAPH, 20
.equ TICKS_PER_SEC, 1250000

.text
.global _start

_start:
  movia sp, 0x03FFFFFC
  movia r8, JP2_BASE
  movia r9, 0x07f557ff        # set direction for motors to all output
  stwio r9, 4(r8)
  movia r9, 0xffffffff        # disable motors
  stwio r9, 0(r8)

  # --------------------------------
  # merge here ---------------------
  
  
  
  movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
  movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
  stwio  r9, 4(r8)


  # load sensors 0-3 setting their thresholds and enabling the sensor
  # sensor 0
  movia  r9,  0xffbffbff       # set motors off and enable threshold load sensor 0
  stwio  r9,  0(r8)            
  movia  r9,  0xfafffff       # disable threshold register and enable state mode
  stwio  r9,  0(r8)

  # sensor 1
  movia  r9,  0xffbfefff       
  stwio  r9,  0(r8)            
  movia  r9,  0xfaffffff       
  stwio  r9,  0(r8)

  # sensor 2
  movia  r9,  0xfabfbfff       
  stwio  r9,  0(r8)            
  movia  r9,  0xfaffffff       
  stwio  r9,  0(r8)

  # sensor 3
  movia  r9,  0xfabeffff       
  stwio  r9,  0(r8)            
  movia  r9,  0xfaffffff       
  stwio  r9,  0(r8)

  # enable interrupts

  movia  r12, 0x78000000       # enable interrupts on sensor (3) - 0x40000000 originally
  stwio  r12, 8(r8)

  movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12) 
  wrctl  ctl3, r8

  movia  r8, 1
  wrctl  ctl0, r8            # enable global interrupts



  # -------------------------------------
  # merge here -------------------------


  # enable interrupts
  movi r9, 0x1
  wrctl status, r9

  movia r14, KeyPressArray3
  stw r0, 0(r14)
  movia r14, KeyPressArray2
  stw r0, 0(r14)
  movia r14, KeyPressArray1
  stw r0, 0(r14)

main:
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r16, r12, 0x00ff
  andi r12, r12, 0x08000      # check if valid field is set
  beq r12, r0, stop #valid bit is not 0

  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  movia r15, KeyPressArray1
  stw r18, 0(r15)
  movia r14, KeyPressArray3
  ldw r18, 0(r14)
  movia r15, KeyPressArray2
  stw r18, 0(r15)

  movia r14, KeyPressArray3
  stw r16, 0(r14)
  movui r13, 0x075
  beq r16, r13, forward

  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  beq r18, r13, forward

  movia r14, KeyPressArray1
  ldw r18, 0(r14)
  beq r18, r13, forward

  movui r13, 0x072
  beq r16, r13, backward

  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  beq r18, r13, backward

  movia r14, KeyPressArray1
  ldw r18, 0(r14)
  beq r18, r13, backward
  movui r13, 0x074
  beq r16, r13, turn_right

  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  beq r18, r13, turn_right

  movia r14, KeyPressArray1
  ldw r18, 0(r14)
  beq r18, r13, turn_right

  movui r13, 0x06B
  beq r16, r13, turn_left

  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  beq r18, r13, turn_left

  movia r14, KeyPressArray1
  ldw r18, 0(r14)
  beq r18, r13, turn_left
  # beq r12, r13, turn_left
  # beq r12, r13, turn_right
  # beq r12, r13, backward
  br stop

turn_left:
  movia r11, 0xffdfff2
  stwio r11, 0(r8)
  call pwm

  # CHECK FOR VALID BIT!!!!!
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r16, r12, 0x00ff
  # andi r12, r12, 0x08000 # check if valid field is set
  # beq r12, r0, stop # valid bit is not 1

  movia r14, KeyPressArray5
  ldw r18, 0(r14)

  movia r15, KeyPressArray4
  stw r18, 0(r15)

  movia r14, KeyPressArray5
  ldw r18, 0(r14)

  movia r15, KeyPressArray5
  stw r18, 0(r15)

  movia r14, KeyPressArray6
  stw r16, 0(r14)

  movui r13, 0xF0
  beq r16, r13, readonemore

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  movia r14, KeyPressArray4
  ldw r18, 0(r14)
  beq r18, r13, readonemore
  br turn_left


turn_right:
  movia r11, 0xffdfff8
  stwio r11, 0(r8)
  call pwm

  # CHECK FOR VALID BIT!!!!!
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r16, r12, 0x00ff
  #andi r12, r12, 0x08000     # check if valid field is set
  #beq r12, r0, stop          # valid bit is not 1

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray4
  stw r18, 0(r15)
  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray5
  stw r18, 0(r15)

  movia r14, KeyPressArray6
  stw r16, 0(r14)
  movui r13, 0xF0
  beq r16, r13, readonemore

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  movia r14, KeyPressArray4
  ldw r18, 0(r14)
  beq r18, r13, readonemore
  br turn_right


forward:
  movia r11, 0xffdfff0
  stwio r11, 0(r8)
  call pwm
  #CHECK FOR VALID BIT!!!!!
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r16, r12, 0x00ff
  #andi r12, r12, 0x08000     # check if valid field is set
  #beq r12, r0, stop          # valid bit is not 1

  # Document what is going ON HERE?! 4 and 5 whaat?
  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray4
  stw r18, 0(r15)
  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray5
  stw r18, 0(r15)
  movia r14, KeyPressArray6
  stw r16, 0(r14)

  movui r13, 0xF0
  beq r16, r13, readonemore

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  movia r14, KeyPressArray4
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  br forward

backward:
  movia r11, 0xffdfffa
  stwio r11, 0(r8)
  call pwm
  
  # CHECK FOR VALID BIT!!!!!
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r16, r12, 0x00ff
  #andi r12, r12, 0x08000     # check if valid field is set
  #beq r12, r0, stop          # valid bit is not 1

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray4
  stw r18, 0(r15)
  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  movia r15, KeyPressArray5
  stw r18, 0(r15)

  movia r14, KeyPressArray6
  stw r16, 0(r14)
  movui r13, 0xF0
  beq r16, r13, readonemore

  movia r14, KeyPressArray5
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  movia r14, KeyPressArray4
  ldw r18, 0(r14)
  beq r18, r13, readonemore

  br backward

stop:
  # stop occurs when a movement key is released
  movia r11, 0xffdffff
  stwio r11, 0(r8)
  br main

readonemore:
  # needs to read one more [ADD COMMENT HERE]
  movia r14, KeyPressArray1
  stw r0, 0(r14)
  stw r0, 4(r14)
  stw r0, 8(r14)
  stw r0, 12(r14)
  stw r0, 16(r14)
  stw r0, 20(r14)
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  br stop

initialize_timer:
  # DOCUMENT THIS
  movia r8, TIMER0_BASE # Lower 16 bits
  addi r9, r0, %lo(TICKS_PER_SEC)
  stwio r9, TIMER0_PERIODL(r8)# Upper 16 bits
  addi r9, r0, %hi(TICKS_PER_SEC)
  stwio r9, TIMER0_PERIODH(r8)
  ret


stop_timer:
  movia r8, TIMER0_BASE
  # 8 means bit 3 is high
  
  movi r9, 0x8
  
  # Bit 3 is the control register's "stop" bit.
  # By writing 1 at Bit 3, we stop the timer.
  stwio r9, TIMER0_CONTROL(r8)
  ret


start_timer_once:
  movia r8, TIMER0_BASE
  
  # 4 means bit 2 is high
  movi r9, 0x4
  
  # Bit 2 is the control register's "start" bit.
  # By writing 1 at Bit 2, we start the timer.
  # This also sets Bit 1 to 0, which means the timer will run once.
  stwio r9, TIMER0_CONTROL(r8)
  ret


read_timer:
  movia r8, TIMER0_BASE
  
  # First we take a snapshot of the period registers
  stwio r0, TIMER0_SNAPL(r8)

  # Read the snapshot
  ldwio r9, TIMER0_SNAPL(r8)
  ldwio r10, TIMER0_SNAPH(r8)

  # Combine the lo and hi bits
  slli r10, r10, 16       # Shift r10's bits to the upper-half
  or r2, r9, r10          # Combine r9 and r10 into the return value

  ret

pwm:
  addi sp, sp, -16
  stw ra, 0(sp)
  stw r8, 4(sp)
  stw r9, 8(sp)
  stw r10, 12(sp)
  call stop_timer
  call initialize_timer
  call start_timer_once


onesec:
  # runs a timer for one second [ADD COMMENT HERE]
  movia r8, TIMER0_BASE
  ldwio r17, TIMER0_STATUS(r8)
  andi r17, r17, 0x1

  beq r17, r0, onesec
  movi r17, 0x0
  stwio r17, TIMER0_STATUS(r8)

  ldw ra, 0(sp)
  ldw r8, 4(sp)
  ldw r9, 8(sp)
  ldw r10, 12(sp)
  addi sp, sp, 16
  ret


.data
.align 2

KeyPressArray1:
.word 0

KeyPressArray2:
.word 0

KeyPressArray3:
.word 0

KeyPressArray4:
.word 0

KeyPressArray5:
.word 0

KeyPressArray6:
.word 