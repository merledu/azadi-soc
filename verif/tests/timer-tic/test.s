.option norelax
.option norvc
_start:
  j start
start:
  li  x10, 1
  li  x13, 0x80
  li  x14, 8
  li  x31, 0xf
  li  x8,  0x30002000
  li 	x7, 0x30003000
	li 	x9, 0x40001000

	li 	x12, 1
	sw 	x12, 4(x7)					# interrupt enable
	jal delay

delay:
  csrrw x0,  0x300, x14 # mstatus
  csrrw x0,  0x304, x13 # mie
	la 		t0, INTERRUPT
	#slli 	t0, t0, 2
	csrrw x0, mtvec, t0
  li    x11, 0x00020002 # pre-scale & step
  sw    x11, 0x100(x8)  # config pre-scale
  sw    x10, 0x0(x8)    # enable timer
  sw    x10, 0x114(x8)  # enable timer intr
  sw    x31, 0x10c(x8)  # set comp. value lower
  sw    x0,  0x110(x8)  # set comp. value uper
  wfi

INTERRUPT:
	lw 	x13, 8(x7)					# claiming interrupt id
	li 	x14, 2
	beq x13, x14, TIMER1
	li 	x14, 4
	beq x13, x14, TIMER2
	li 	x14, 8
	beq x13, x14, TIMER3

COMPLETE:
	sw 	x0, 8(x7)					# writing 1 to complete
  sw	x10,  0x118(x8) 	# intr state
  sw	zero, 0x114(x8) 	# dis timer intr
  mret

TIMER1:
	li x12, 1
	sw x12, 0x1c(x9)
	sw x12, 0x10(x9)
	li x12, 0
	sw x12, 0x1c(x9)
	j COMPLETE

TIMER2:
	li x12, 2
	sw x12, 0x1c(x9)
	sw x12, 0x10(x9)
	li x12, 0
	sw x12, 0x1c(x9)
	j COMPLETE

TIMER3:
	li x12, 4
	sw x12, 0x1c(x9)
	sw x12, 0x10(x9)
	li x12, 0
	sw x12, 0x1c(x9)
	j COMPLETE
