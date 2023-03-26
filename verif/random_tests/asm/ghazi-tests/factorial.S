li s0, 0x400c0000  # gpio base address
li x10,0xff
li x11,1
li x12,1
li x13,4			# the number whose factorial needs to be calculated
loop:
bgt x12,x13,gpio_write
mul x11,x11,x12
addi x12,x12,1
jal loop
gpio_write:
sw x10,0x1c(s0)		
sw x11, 0x10(s0)	# should write 4! = 24 on GPIO
end:
jal end
