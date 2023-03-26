li t0, 55
li t1, 210
li s0, 0x10000000

fcvt.s.w f0,t0
fcvt.s.w f1,t1
fsw f0, 08(s0)
fsw f1, 12(s0)

fcvt.w.s t2,f0
fcvt.w.s t3,f1
sw t2, 08(s0)
sw t3, 12(s0)

add t3, t0,t1
sw t3, 80(s0)

flw f0, 08(s0)
flw f1, 12(s0)

fadd.s f2,f0,f1
fsw f2, 16(s0)

fmadd.s f4,f0,f1,f2
fsw f4, 20(s0)

flw f5, 08(s0)
flw f6, 12(s0)

fsub.s f2,f1,f0
fsw f2, 24(s0)

fmsub.s f4,f0,f1,f2
fsw f4, 28(s0)

fdiv.s f9,f5,f6
fsw f9, 32(s0)

fsgnj.s f10,f8,f9 
fsw f10, 36(s0)

fmul.s f9,f5,f6
fsw f9, 40(s0)

fsgnjn.s f10,f8,f9 
fsw f10, 44(s0)

fsqrt.s t5,f9
fsw f5, 48(s0)

fsgnjx.s f10,f8,f9 
fsw f10, 52(s0)

fmv.s f11,f10
fsw f11, 56(s0)

fclass.s t6,f9
sw t6, 60(s0)

flt.s t2, f10,f11
sw t6, 64(s0)

fmv.s.x f15,t6
fmv.x.s t6,f15

fmin.s f16,f17,f18
fmax.s f16,f17,f18