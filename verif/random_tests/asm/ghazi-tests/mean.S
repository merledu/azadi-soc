li x8, 0x400c0000 	# gpio base address
li x9, 0x10000000 	# dccm base address for ibtida  # for ghazi change it to 0x18000000
addi x16, x0, 6		# first number
addi x17, x0, 8		# second number
addi x18, x0, 10		# third number
sw x16, 0(x9)		# storing numbers in dccm
sw x17, 4(x9)		# storing numbers in dccm
sw x18, 8(x9)		# storing numbers in dccm
jal average
lw x7, 0xc(x9)
li x6, 0xff
sw x6, 0x1c(x8)
sw x7, 0x10(x8)	# expected output in gpio is 8
jal end
average:
	lw x14, 0(x9)
    lw x13, 4(x9)
    lw x12, 8(x9)
    add x13, x14, x13
    add x12, x13, x12
    li x11, 3
    div x10, x12, x11
    sw x10, 0xc(x9)	#saving the average
    ret
end:
jal end
