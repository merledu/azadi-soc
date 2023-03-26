li s0, 0x10000000
li t0, 91
li t1, 22
sw t0, 0x4(s0)
sw t1, 0x8(s0)
flw f1,0x4(s0)
flw f2,0x8(s0)
fsqrt.s t2,f2
fadd.s f6,f2,f2
fsgnj.s f3,f2,f1
fsgnjn.s f4,f3,f2
fsgnjx.s f5,f2,f4
fmin.s f7, f5,f6
fmax.s f7, f5,f6