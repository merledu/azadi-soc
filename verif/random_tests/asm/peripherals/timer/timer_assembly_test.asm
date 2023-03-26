jal delay
nop
nop
nop
nop
nop
nop
lui	s0,0x40000
li	t0,0
sw	zero,272(s0) # 40000110 <_etext+0x1ffffd64>
sw	a1,256(s0)
sw	t0,276(s0)
sw	t0,0(s0)
csrrw x0, 0x300, t0 # mstatus
csrrw x0, 0x304, t0 # mie
mret


delay:
li s0, 0x40000000
li x10,1
li x13, 0x80
li  x14, 8
csrrw x0, 0x300, x14 # mstatus
csrrw x0, 0x304, x13 # mie
sw x10, 0x0(s0)
li x11, 0x00020002
sw x11, 0x100(s0)
li x12, 7
sw x12, 0x10(s0)
sw x0, 0x110(s0)
sw x10, 0x114(s0)
wfi
nop
nop