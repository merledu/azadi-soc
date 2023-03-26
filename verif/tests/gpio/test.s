# gpio
# x30 will store the reference value and x31 will store the pass/fail status
# when x31 contains value equals to 1 means test is pass, 2 means fail

  .option norelax
  .option norvc
  .global _start
_start:
  j start
start:
  li s0, 0x40001000
  li x12, 0xffffffff
  sw x12, 0x1c(s0)
  sw x12, 0x10(s0)
  li x12, 0
  sw x12, 0x1c(s0)

  # fail
  li x31, 2
  jal end

pass:
  li x31, 1

end:
  j end
