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
  li x2, 0x7f800000 # Inf
  li x3, 0x7fc00000 # NaN

  fmv.w.x f7, x2
  fmv.w.x f8, x3

  fle.s x9, f8, f7

  beq x2, x9, pass

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

end:
  j end
