# basic-test
# x30 will store the reference value and x31 will store the pass/fail status
# when x31 contains value equals to 1 means test is pass, 2 means fail

  .option norelax
  .option norvc
  .global _start
_start:
  j start
start:
  # Init GPR
  addi x1, x0, 1
  addi x2, x0, 2
  addi x3, x0, 3

  j pass

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

end:
  j end

nop