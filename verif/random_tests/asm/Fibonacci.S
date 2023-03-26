li t6,0x400c0000
li t0,0 		#constant 
li t1,0 		#constant 
li t2,1			#constant 
li t3,0			#loop counter
li t4,11        #max fibonacci series limit   
loop :
beq t3,t4,else
add t5,t2,t1
add t1,t0,t2
add t2,t0,t5
addi t3,t3,1
beq t0 ,t0 loop
else:
sw t5,0x1(t6)
nop