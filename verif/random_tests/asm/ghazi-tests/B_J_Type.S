li x8, 0x400c0000 # gpio address
li x7, 0xff
sw x7, 0x1c(x8)
j B1
sw x7, 0x10(x8)   # ff

B3:
li x7, 44
sw x7, 0x10(x8)   # 2C
ret

B1:
li x5, 10
li x6, 20
add x7, x5, x6
sw x7, 0x10(x8)  # 1E
bne x5, x6, B2

B2:
sw x0, 0x10(x8)  # 0
li x5, 15
li x6, 25
sub x7, x6, x5
sw x7, 0x10(x8)  # A
jal x1, B3
sw x0, 0x10(x8)  # 0
j B4

B4:
beqz x7, end
sub x7, x7, x7
j B4

end:
bnez x7, B4
li x7, 77
sw x7, 0x10(x8)  # 4D 

exit:
jal exit
