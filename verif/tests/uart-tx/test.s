.option norelax
.option norvc

li s0, 0x40002100
li x15, 0x40002000
li x14, 1
li x12, 217
sw x12, 0(s0)
sw x12, 0(x15)
li x16, 0xffff
sw x16, 40(x15)
sw x14, 12(x15)
li x10, 0
li x11, 128
li x13, 3
loop:
bne x10, x11, load
sw x14, 28(s0)
sw x14, 16(s0)
jal w_loop
load:
addi x10, x10, 1
sw x13, 4(s0)
addi x13, x13, 1
jal loop
w_loop:
bne x14, x17, wait
jal exit2
wait:
lw x17, 20(x15)
jal w_loop
exit2:
lw x18, 52(x15)
r_loop:
bne x0, x18, read
jal exit
read:
sub x18, x18, x14
lw x19, 8(x15)
jal r_loop
exit:
jal exit
