li x8, 0x400c0000 # gpio address
li x7, 0xff
sw x7, 0x1c(x8)
li x5, 6
li x6, 8
mul x7, x5, x6    # 30
sw x7, 0x10(x8)
li x5, 0x00600000
li x6, 0x00800000
mulh x7, x5, x6   # 0
sw x7, 0x10(x8)
li x5, 65
li x6, 32
div x7, x5, x6    # 2
sw x7, 0x10(x8)
li x5, 65
li x6, 32
rem x7, x5, x6    # 1
sw x7, 0x10(x8)
