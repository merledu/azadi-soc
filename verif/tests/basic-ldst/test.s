# basic-ldst-test
# x30 will store the reference value and x31 will store the pass/fail status
# when x31 contains value equals to 1 means test is pass, 2 means fail

  .option norelax
  .option norvc
  .global _start
_start:
  j start
start:
  # Init GPR
  li   x1, 0x20000000
  addi x2, x0, 2
  sw   x2, 0(x1)
  addi x3, x0, 3
  lw   x4, 0(x1)
  add  x5, x3, x4 # 5 = 3 + 2

  li x30, 5
  beq x5, x30, pass

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

end:
  j end
