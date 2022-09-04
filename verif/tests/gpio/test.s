# 1 "/home/uzain/projects/azadi-tsmc/verif/tests/gpio/test.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "/home/uzain/projects/azadi-tsmc/verif/tests/gpio/test.S"
li s0, 0x40001000
li x12, 0xffffffff
sw x12, 0x1c(s0)
sw x12, 0x10(s0)
li x12, 0
sw x12, 0x1c(s0)
