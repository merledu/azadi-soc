 
li s0 , 0x40000000
jal main

li x6 , 0xffffffff
li x7 , 0x1      
sw x6 , 0x10C(s0)
sw x6 , 0x110(s0)
sw x0 , 0x104(s0)
sw x0 , 0x108(s0)
sw x11, 0x100(s0)
sw x0 , 0x114(s0)
sw x7 , 0x118(s0)
sw x0 , 0x0(s0)
nop
nop

main:
up:
li a0, 0x2000000c
csrrw x0, 0x305, a0

li x5 , 0x80
li x6 , 8

csrrs x0 , 0x300, x6
csrrs x0 , 0x304, x5

li x15 , 100
#timer cmp_offset
sw x15 , 0x10c(s0)
#timer compare upper 
sw x0 , 0x110(s0)

li x11, 0x00020002

#configuration for hart 0
sw x11, 0x100(s0)
#interrupt enable

li x5, 1
sw x5 , 0x114(s0)

#control register
sw x5 , 0x0(s0)
nop
nop
nop
jal up
