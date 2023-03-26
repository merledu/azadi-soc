li t0,0x400c0000
li t1,10
li t2,20
sub t4,t2,t1
sw t4,0x10(t0)
and t5,t2,t1
sw t5,0x10(t0)
or t6,t2,t1
sw t6,0x10(t0)
xor t3,t2,t1
sw t3,0x10(t0)
nop