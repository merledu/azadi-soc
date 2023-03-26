li x8, 0x400c0000		# gpio base address
li x9, 0x10000000		# dccm base address
addi x15, x0, 4			# any number that needs to be squared
sw x15, 0(x9)
jal square
lw x17, 4(x9)
li x18, 0xff
sw x18, 0x1c(x8)
sw x17, 0x10(x8)
jal end
square:
	lw x16, 0(x9)
    mul x16, x16, x16
    sw x16, 4(x9)
    ret
end:
jal end
