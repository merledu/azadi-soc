li s0 , 40050000 #base address of plic
li s1 , 400c0000 #base address of gpio
#level edge trigger

li x5, 1
sw x5 , 0x18(s0)

#configure priority

li x6 , 3
sw x6 , 0x30(s0)

#threshold

li x7 , 2
sw x7 , 0x318(s0)

#enable plic
sw x5 , 0x300(s0)

#gpio interrupt enable 
li x8 , 8 
sw x8 , 0x30(s1)

# gpio intr
sw x8 , 0x4(s1)