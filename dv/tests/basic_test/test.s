# basic test

   .option norelax
   .global _start
_start:
   j start
start:
   # Init GPR
   addi x1, x0, 1
   addi x2, x0, 2
   addi x3, x0, 3
