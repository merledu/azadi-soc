# Test gpio pins and turn all pins on.

  .option norelax
  .option norvc
  .global _start
_start:
  j start
start:

# GPIO 10, 11
  li x8,  0x40001000
  li x12, 0x00000c00 # gpio pin 10, 11
  sw x12, 0x1c(x8)
  sw x12, 0x10(x8)
  li x11, 11
  loop1:
  addi x11, x11, -1
  bne x0, x11, loop1
  sw x0,  0x1c(x8)
  sw x0,  0x10(x8)

# PWM 
  li x8, 0x40004000
  # Channel 1
  li x12, 1
  sw x12, 12(x8)	#DC
  li x15, 3
  sw x15, 8(x8)	#Period	
  li x14, 0x2
  sw x14, 4(x8)	#Divisor
  li x13, 7
  sw x13, 0(x8)	#Ctrl
  # Channel 2
  li x12, 1
  sw x12, 28(x8)	#DC
  li x15, 3
  sw x15, 24(x8)	#Period	
  li x14, 0x2
  sw x14, 20(x8)	#Divisor
  li x13, 63
  sw x13, 0(x8)	#Ctrl

# UART 0
  li x8,  0x40002000
  li x14, 1
  li x12, 217
  sw x12, 0(x8)
  li x13, 3
  sw x13, 4(x8)
  sw x14, 28(x8)
  sw x14, 16(x8)

  # GPIO 0,1
  li x8,  0x40001000
  li x12, 0x00000003 # gpio pin 0,1
  sw x12, 0x1c(x8)   # output enable
  sw x12, 0x10(x8)   # direct out
  li x11, 11
  loop2:
  addi x11, x11, -1
  bne x0, x11, loop2
  sw x0,  0x1c(x8)
  sw x0,  0x10(x8) 


  # GPIO 2,3,4,5,8,9
  li x8,  0x40001000
  li x12, 0x000002FC # gpio pin 2,3,4,5,8,9
  sw x12, 0x1c(x8)   # output enable
  sw x12, 0x10(x8)   # direct out
  li x11, 11
  loop3:
  addi x11, x11, -1
  bne x0, x11, loop3
  sw x0,  0x1c(x8)
  sw x0,  0x10(x8) 

end:
  j end
  nop

.data
  .section .tohost, "aw",@progbits
  .align 1
  .global tohost
tohost:
  .word 0