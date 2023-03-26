li x9, 0x400c0000 # gpio address

li x5, 0xff
sw x5, 0x1c(x9)
li x5, 5
li x6, 6
add x7, x5, x6   # B
sw x7, 0x10(x9)
li x5, 15
li x6, 20
sub x7, x6, x5   # 5
sw x7, 0x10(x9)
li x5, 25
li x6, 01
sll x7, x5, x6   # 32
sw x7, 0x10(x9)
slt x7, x6, x5   # 1
sw x7, 0x10(x9)
li x5, 50
li x6, 30
xor x7, x5, x6   # 2C
sw x7, 0x10(x9)
li x5, 5
li x6, 30
srl x7, x6, x5   # 0
sw x7, 0x10(x9)
sra x7, x6, x5   # 0
sw x7, 0x10(x9)
li x5, 18
li x6, 35
or x7, x5, x6    # 33
sw x7, 0x10(x9)
li x5, 14
li x6, 63
and x7, x5, x6   # E
sw x7, 0x10(x9) 
