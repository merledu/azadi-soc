.option norelax
.option norvc

li s0, 0x40001000

li x12, 0x00000002
sw x12, 0x30(s0)	#gpio intr lvl high
sw x12, 0x4(s0)		#gpio intr en

li s1, 0x50000000	#plic base address

li x13, 0x3	
sw x13, 0x1c(s1)	#plic priority

li x14, 0x2
sw x14, 0xdc(s1)	#plic threshold

li x15, 0x4
sw x15, 0xd4(s1) 	#plic interrupt enable

sw x12, 0x8(s0)		#gpio intr test register

ISR:
li x12, 0xffffffff
sw x12, 0x1c(s0)
sw x12, 0x10(s0)
li x12, 0
sw x12, 0x1c(s0)

li t0, 8
csrrs  x0, mstatus, t0

li t0, 0x800
csrrs x0, mie, t0

la t0, ISR
slli t0, t0, 2
csrrw x0, mtvec, t0

