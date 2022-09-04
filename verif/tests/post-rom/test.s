# This is a startup program which will get execute at Power on Reset.
# This program will
#   1.  glow the  soc-alive led located at address 0x2000_2001
#   2.  print the string through UART-0

  .option norelax
  .option norvc
  .global _start

_start:
  nop
  nop
  nop

  # constant 1
  li t0, 1

  # soc-alive led
  li a0, 0x20002004

  # UART 0 base address
  li a1, 0x40002300

  # Boot reg base address
  li a2, 0x20002000
  li t1, 0x42524F4D # ROM  value in boot reg
  li t2, 0x51535049 # QSPI value in boot reg
  li t3, 0x4943434D # ICCM value in boot reg
  li t4, 0x80000008 # QSPI address
  li t5, 0x10000000 # ICCM address

  # configure uart clocks per bit
  li a3, 2604 # frq 25 MHz
  sw a3, 0(a1)

  #################################
  #        String to print
  #################################
  li s0, 0x48     # H
  sw s0, 4(a1)
  li s0, 0x65     # e
  sw s0, 4(a1)
  li s0, 0x6C     # l
  sw s0, 4(a1)
  li s0, 0x6C     # l
  sw s0, 4(a1)
  li s0, 0x6F     # o
  sw s0, 4(a1)
  li s0, 0x20
  sw s0, 4(a1)
  li s0, 0x57     # W
  sw s0, 4(a1)
  li s0, 0x6F     # o
  sw s0, 4(a1)
  li s0, 0x72     # r
  sw s0, 4(a1)
  li s0, 0x6C     # l
  sw s0, 4(a1)
  li s0, 0x64     # d
  sw s0, 4(a1)
  li s0, 0x20
  li s0, 0x66     # f
  sw s0, 4(a1)
  li s0, 0x72     # r
  sw s0, 4(a1)
  li s0, 0x6F     # o
  sw s0, 4(a1)
  li s0, 0x6D     # m
  sw s0, 4(a1)
  li s0, 0x20
  sw s0, 4(a1)
  li s0, 0x41     # A
  sw s0, 4(a1)
  li s0, 0x7A     # z
  sw s0, 4(a1)
  li s0, 0x61     # a
  sw s0, 4(a1)
  li s0, 0x64     # d
  sw s0, 4(a1)
  li s0, 0x69     # i
  sw s0, 4(a1)
  li s0, 0x2D     # -
  sw s0, 4(a1)
  li s0, 0x53     # S
  sw s0, 4(a1)
  li s0, 0x6F     # o
  sw s0, 4(a1)
  li s0, 0x43     # C
  sw s0, 4(a1)

  sw t0, 28(a1) # UART FIFO enable
  sw t0, 16(a1) # UART TX enable

  sw t0, 0(a0) # led alive

wait:
  nop
  lw  s1, 0(a2) # load boot select register value
  beq s1, t1, wait
  beq s1, t2, load_qspi
  beq s1, t3, load_iccm

load_qspi:
  nop
  jal clean
  li ra, 0
  jalr x0, t4, 0
  nop

load_iccm:
  nop
  jal clean
  li ra, 0
  jalr x0, t5, 0
  nop

clean:
  li t0, 0
  li t1, 0
  li t2, 0
  li t3, 0
  li s0, 0
  li s1, 0
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret
