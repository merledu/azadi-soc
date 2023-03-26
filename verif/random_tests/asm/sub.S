li t1,0x400c0000
li t2,0x2
mul t3,t2,t2
addi t4,t3,2
sw t4,0x10(t1)
add t5,t4,t4
sw t5,0x10(t1)
sub t6,t5,t2
sw t6,0x10(t1)
nop