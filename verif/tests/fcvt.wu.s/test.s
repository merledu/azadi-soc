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
  li x2, 0x7fc00000
  li x3, 0x000000ff

  fmv.w.x f7, x2
  fmv.w.x f8, x3

  fcvt.wu.s x7, f7
  fcvt.wu.s x8, f8

  li x9, 0xffffffff

  beq x7, x9, pass

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

  la x9, tohost
  sw x31, 0(x9)

end:
  j end
  nop

.data
  .section .tohost, "aw",@progbits
  .align 1
  .global tohost
tohost:
  .word 0
