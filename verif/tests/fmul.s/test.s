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
  li x2, 0x46802c00
  li x3, 0x00000000

  fmv.w.x f8, x2
  fmv.w.x f17, x3

  fmul.s f6, f8, f17

  fmv.x.w x30, f6

  beqz x30, pass

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

end:
  j end
