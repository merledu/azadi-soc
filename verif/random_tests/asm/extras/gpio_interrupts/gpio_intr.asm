 
li sp 0x100000ff
li s0, 0x40050000 # plic base address
li s1, 0x400c0000 # gpio base address
jal main

nop
nop

li a0, 5
lw a1, 0xac(s0) # plic claim
beq a0, a1, handle_trap
nop # replace this nop with mret
#mret
# 0x30200073
nop
nop


handle_trap:
li a0, 1
slli a0, a0, 4
sw a0, 0x0(s1) # clear gpio interrupts
sw x0, 0x4(s1)
lw x5, 0xc(s1) # read value 
ret


main:
loop:
addi sp,sp,-32
sw s0, 0x0(sp)
sw s1, 0x4(sp)
li a0, 0x2000001c
csrrw x0, 0x305, a0 # trap base address in mtvec 
li a0, 0x8
csrrs x0, 0x300, a0 # global interrupt enable in mstatus
li a0, 0x800
csrrs x0, 0x304, a0 # external interrupt enable in mie
jal plic_init
jal gpio_read
srli x6, x5, 4
li x7, 1
li x8, 4
beq x6, x7, write_gpio
slli x8, x8, 1
jal write_gpio
endif:
nop
jal loop


plic_init:
li a1, 2
sw a1, 0xa8(s0) # plic thershold
li a2, 1
sw x0,0x8(s0) 	#	plic set as level trigger interrupts
slli a2, a2, 5
sw a2, 0xa0(s0) # plic interrupt enable for	source 5
li a3, 3
sw a3, 0x24(s0) # interrupt priority for source 5
ret

gpio_read:
li a3, 1
slli a4, a3, 4
sw a4, 0x30(s1) # gpio interrupt level high 
sw a4, 0x4(s1) # gpio interrupt enable for pin 4
nop # replace this nop with wfi given below
#0x10500073
nop
ret

write_gpio:
sw x8, 0x10(s1)
jal endif
