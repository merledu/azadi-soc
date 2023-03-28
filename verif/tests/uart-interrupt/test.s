.option norelax
.option norvc
_start:
  j start
start:
  li s0, 0x50000000 # plic base address
  li s1, 0x40002000 # uart 0 base address
  li s2, 0x40002100 # uart 1 base address
  li s3, 0x40001000 # gpio base address

  li t0, 8
  csrrs  x0, mstatus, t0

  li t0, 0x800
  csrrs x0, mie, t0

  la t0, ISR
  csrrw x0, mtvec, t0

  jal MAIN

ISR:

  lw a5, 0xe0(s0) # claim interrupt
  lw a6, 8(s0)
  sw x0, 0xdc(s0) # interrupt thershold
  sw x0, 0xb4(s0) # interrupt priority for source 41
  sw x0, 0xd8(s0) # interrupt enable for source 41
  sw a5, 0xe0(s0)
  lw a7, 0x8(s1)
  sw t2, 48(s1)
  mret

MAIN:
  sw x0, 0x1c(s3)
  sw x0, 0x10(s3)
  li a0, 1
  slli a0, a0, 9 
  li a1, 0x3 
  li a2, 0x2
  sw a2, 0xdc(s0) # interrupt thershold
  sw a1, 0xb4(s0) # interrupt priority for source 41
  sw a0, 0xd8(s0) # interrupt enable for source 41

  li t0, 217
  sw t0, 0x0(s1)
  sw t0, 0x0(s2)
  li t1, 0x77
  sw t1, 0x4(s2)
  li t2, 1
  sw t2, 12(s1)
  sw t2, 28(s2) # UART FIFO enable
  sw t2, 16(s2) # UART TX enable

  sw t2, 56(s1)
  wfi
  nop
  sw a7, 0x1c(s3)
  sw a7, 0x10(s3)
  jal MAIN

end:
  j end
  nop

.data
  .section .tohost, "aw",@progbits
  .align 1
  .global tohost
tohost:
  .word 0
