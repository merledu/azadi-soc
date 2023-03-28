# Timer test to check timer interrupt
.option norelax
.option norvc
_start:
  j start
start:
  li  x10, 1
  li  x13, 0x80
  li  x14, 8
  li  x31, 0xfffff
  li  x30, 0xffffffff
  li  x8,  0x30000000
  li 	x7, 0x30003000
	li 	x9, 0x40001000

	jal LED_ON

INTERRUPT:
	lw 	x13, 8(x7)				# claiming interrupt id
	
  sw	zero, 0x114(x8) 	# disable timer intr
  sw	x10,  0x118(x8) 	# intr state
  sw  zero, 0x100(x8)
  sw  zero, 0x104(x8)
  sw  zero, 0x108(x8)
  sw    x0, 0x10c(x8)  # set comp. value lower
  sw    x30,  0x110(x8)  # set comp. value uper
  sw 	x0, 8(x7)					# writing 1 to complete
  mret

DELAY:
  csrrs x0,  0x300, x14 # mstatus
  csrrs x0,  0x304, x13 # mie
  li 	x12, 1
	sw 	x12, 4(x7)					# interrupt enable
	la 		t0, INTERRUPT
	csrrw x0, mtvec, t0
  li    x11, 0x00020002 # pre-scale & step
  sw    x11, 0x100(x8)  # config pre-scale
  sw    x10, 0x114(x8)  # enable timer intr
  sw    x31, 0x10c(x8)  # set comp. value lower
  sw    x0,  0x110(x8)  # set comp. value uper
  sw    x10, 0x0(x8)    # enable timer
  wfi
  jalr ra

LED_ON:
	li x12, 1
  sw x12, 0x10(x9)
	sw x12, 0x1c(x9)
	jal DELAY
  nop
  nop

#LED_OFF:
	sw x0, 0x1c(x9)
  sw x0, 0x10(x9)
  jal DELAY
  j LED_ON

end:
  j end
  nop

.data
  .section .tohost, "aw",@progbits
  .align 1
  .global tohost
tohost:
  .word 0
