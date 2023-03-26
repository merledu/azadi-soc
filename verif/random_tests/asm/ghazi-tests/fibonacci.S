li s0, 0x400c0000  # gpio base address
li x10,1 # i
li x11,6 # n
li x12,0 # t1
li x13,1 # t2
li x14,0 # result
li x15, 0x0000000F
sw x15, 0x1c(s0)
loop:
beq x10,x11,end
add x14,x13,x12
sw x14,0x10(s0) # writing on GPIOs
mv x12,x13
mv x13,x14
addi x10,x10,1
jal loop
end:
jal end
