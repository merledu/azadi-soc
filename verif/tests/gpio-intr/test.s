.option norelax
.option norvc

li s0, 0x40001000
li x12, 0x00000002
sw x12, 0x30(s0)
sw x12, 0x4(s0)
sw x12, 0x8(s0)
sw x12, 0x1c(s0)
sw x12, 0x10(s0)
sw x12, 0x1c(s0)
