li t2,0x400c0000
li t1,0
start:
bne t0,t1 end
addi t1,t1,2
jal x1,start 
end:
addi t1,t1,3
sw t1,0x10(t2)
nop