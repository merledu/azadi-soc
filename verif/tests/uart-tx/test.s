.option norelax
.option norvc

li s0, 0x40002100
li x14, 1
li x12, 217
sw x12, 0(s0)
li x13, 3
sw x13, 4(s0)
sw x14, 28(s0)
sw x14, 16(s0)
