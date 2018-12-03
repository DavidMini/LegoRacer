.equ PS2_BASE, 0xFF200100
.equ PS2_CONTROL, 0xFF200104
.equ JP2_BASE, 0xFF200060

.text
.global _start
_start:

movia r8, JP2_BASE
movia  r9, 0x07f557ff         # set direction for motors to all output 
stwio  r9, 4(r8)
movia  r9, 0xffffffff         # disable motors
stwio  r9, 0(r8)

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
  andi r12, r12, 0x8000       # check if valid field is set
  beq r12, r0, stop           # valid bit is not 0
  ldwio r12,0(r14)
  
  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  movia r15, KeyPressArray1
  stw r18, 0(r15)

  movia r14, KeyPressArray3
  ldw r18, 0(r14)
  movia r15, KeyPressArray2
  stw r18, 0(r15)
  
  
  andi r12, r12, 0xff         # isolate data
  movia r14, KeyPressArray3
  stw r12, 0(r14)

  
  movi r13, 0x75
  beq r12, r13, forward
  
  movia r14, KeyPressArray2
  ldw r18, 0(r14)
  beq r18, r13, forward
  
  movia r14, KeyPressArray1
  ldw r18, 0(r14)
  beq r18, r13, forward

  
  
  # beq r12, r13, turn_left
  # beq r12, r13, turn_right
  # beq r12, r13, backward
  br stop
 
turn_left:
  movia  r11, 0xffdfffa
  stwio  r11, 0(r8) 
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0xff
  movia r13, 0xF0
  beq r12, r13, main
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0x8000       # check if valid field is set
  beq r12, r0, stop           # valid bit is not 0
  
  br turn_left

turn_right:
  movia  r11, 0xffdfff0
  stwio  r11, 0(r8)
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0xff
  movia r13, 0xF0
  beq r12, r13, main
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0x8000       # check if valid field is set
  beq r12, r0, stop           # valid bit is not 0
  
  br turn_right

forward:
  # CHECK FOR VALID BIT!!!!!

  br main

backward:
  movia  r11, 0xffffffa
  stwio  r11, 0(r8)
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0xff
  movia r13, 0xF0
  beq r12, r13, main
  
  movia r14, PS2_BASE
  ldwio r12, 0(r14)
  andi r12, r12, 0x8000       # check if valid field is set
  beq r12, r0, stop           # valid bit is not 0
  
  br backward
  
stop: 
  # stop occurs when key is released
  
  movia  r11, 0xffdffff
  stwio  r11, 0(r8)
  br main
 
.data
.align 2

KeyPressArray1:
.word 0

KeyPressArray2:
.word 0

KeyPressArray3:
.word 0