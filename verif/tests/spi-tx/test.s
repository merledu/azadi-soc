.option norelax
.option norvc

nop
li s0, 0x40003000	#SPIO Base Address

li a0, 0x104020
sw a0, 0x0(s0)

li a1, 0x03000008
#slli a1, a1, 24
sw a1, 0xc(s0)

li a2, 0x7
sw a2, 0x4(s0)

li a3, 1
sw a3, 0x18(s0)

SPIN:
j SPIN
nop