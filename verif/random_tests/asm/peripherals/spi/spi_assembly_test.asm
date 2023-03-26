li s0, 0x40080000
li x10, 0x3920
li x11, 4
sw x11, 0x14(s0)
li x12, 2
sw x12, 0x18(s0)
li x13, 181 # 10110101
sw x13, 0x0(s0)
sw x10, 0x10(s0)