#Dicriminant: D=(b^2 - 4ac)
#If D < 0, then the quadratic equation has no real solutions(it has 2 complex solutions).
#If D = 0, then the quadratic equation has 1 solution
#If D > 0, then the quadratic equation has 2 distinct solutions.

li a0,0x400c0000
li t1,0                     #value of c
sw t1,0x10(a0)
li t2,1                     #Value of b
sw t2,0x10(a0)
li t3,1                     #Value of a
sw t3,0x10(a0)
li s8,-4                    #constant (-4)
sw s8,0x10(a0)
mul t4,t2,t2                #b^2
mul t5,t1,t3                #a*c
mul t6,t5,s8                #-4*a*c
add s7,t4,t6                #b^2 + (-4) a*c
blt s7,t0,norealsol 
beq s7,t0,onesolution
bge s7,t0,twosolutions
norealsol: 
addi s7,t0,-2
sw s7,0x10(a0)
lw s6,0xc(a0)
beq t0,t0,end
onesolution:
addi s7,t0,1
sw s7,0x10(a0)
lw s6,0xc(a0)
beq t0,t0,end
twosolutions:
addi s7,t0,2
sw s7,0x10(a0)
lw s6,0xc(a0)
end:
nop