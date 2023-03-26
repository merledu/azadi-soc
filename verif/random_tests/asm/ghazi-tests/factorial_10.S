li s0, 0x400c0000
li x10, 0xff
li x11,1
li x12,1
li x13,10  # factorial num 
loop:
bgt x12,x13,end
mul x11,x11,x12
addi x12,x12,1
jal loop
end:
sw x10,0x1c(s0)
sw x11, 0x10(s0) 
