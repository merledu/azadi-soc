 
# pwm channel 2(pwm_o_2)
li s0 , 0x400b0000
#/*duty cycle*/
li x4, 35
sw x4, 28(s0)
#/*divisor*/
li x5 , 0xF
sw x5 , 20(s0)
#/* period */
li x6 , 50
sw x6 , 24(s0)
#/* CONTROL REGISTER */
li x7 , 7
sw x7 , 16(s0)

end:
jal end
