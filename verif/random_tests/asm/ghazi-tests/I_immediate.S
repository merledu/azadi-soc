li x8, 0x400c0000 # gpio base address
li x7, 0xfff
sw x7, 0x1c(x8)
li x5, 50
li x6, 62
addi x7, x5, 62   # 70
sw x7, 0x10(x8)
slti x7, x6, 2    # 0
sw x7, 0x10(x8)
xori x7, x5, 64   # 72
sw x7, 0x10(x8)
ori x7, x6, 14    # 3E
sw x7, 0x10(x8)
andi x7, x5, 32   # 20
sw x7, 0x10(x8)
slli x7, x6, 6    # F80
sw x7, 0x10(x8)
srli x7, x5, 15   # 0
sw x7, 0x10(x8)
srai x7, x6, 1    # 1F
sw x7, 0x10(x8)
