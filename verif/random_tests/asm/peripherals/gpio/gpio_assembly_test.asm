li s0, 0x400c0000
li x10, 1
li x12, 31
li x13, 0
shift:
beq x12,x13, exit
sw x10, 0x10(s0)
slli x10,x10,1
addi x13, x13,1
jal shift
exit:
