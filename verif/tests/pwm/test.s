#pwm 0 0x40004000
#pwm 1 0x40004100
#pwm 2 0x40004200
#pwm 3 0x40004300

  .option norelax
  .option norvc
  .global _start
_start:
  j start
start:
  li s0, 0x40004000

  # Channel 1
  li x12, 1
  sw x12, 12(s0)	#DC
  li x15, 3
  sw x15, 8(s0)	#Period	
  li x14, 0x2
  sw x14, 4(s0)	#Divisor
  li x13, 7
  sw x13, 0(s0)	#Ctrl

  # Channel 2
  li x12, 1
  sw x12, 28(s0)	#DC
  li x15, 3
  sw x15, 24(s0)	#Period	
  li x14, 0x2
  sw x14, 20(s0)	#Divisor
  li x13, 7
  sw x13, 16(s0)	#Ctrl

end:
  j end
  nop

.data
  .section .tohost, "aw",@progbits
  .align 1
  .global tohost
tohost:
  .word 0