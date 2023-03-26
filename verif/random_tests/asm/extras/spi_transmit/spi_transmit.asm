 
li s0 , 0x40080000 #spi base address
# tx_en in ctrl
li x10, 1
slli x10, x10, 14
sw x10, 0x10(s0)

li x5, 0x24
sw x5 , 0x14(s0) #setting the divider value

li x6, 0x77
sw x6 , 0x0(s0) #writing 'w' on tx

sw x0 , 0x18(s0) #selecting slave

li x7 , 6408
or x7 , x7 , x10 #configuring control register
sw x7 , 0x10(s0)
end:
jal end
