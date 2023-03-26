
softwares/hello/output/hello.merl:     file format elf32-littleriscv


Disassembly of section .init:

20000000 <_start>:
20000000:	00000297          	auipc	t0,0x0
20000004:	02828293          	addi	t0,t0,40 # 20000028 <_stext>
20000008:	30529073          	csrw	mtvec,t0
2000000c:	f0000197          	auipc	gp,0xf0000
20000010:	ff418193          	addi	gp,gp,-12 # 10000000 <mcause_trap_table>
20000014:	f0001117          	auipc	sp,0xf0001
20000018:	fec10113          	addi	sp,sp,-20 # 10001000 <__stack_top>
2000001c:	00010433          	add	s0,sp,zero
20000020:	35c0006f          	j	2000037c <main>

Disassembly of section .text:

20000028 <_stext>:
20000028:	f8010113          	addi	sp,sp,-128
2000002c:	00000013          	nop
20000030:	00112223          	sw	ra,4(sp)
20000034:	00212423          	sw	sp,8(sp)
20000038:	00312623          	sw	gp,12(sp)
2000003c:	00412823          	sw	tp,16(sp)
20000040:	00512a23          	sw	t0,20(sp)
20000044:	00612c23          	sw	t1,24(sp)
20000048:	00712e23          	sw	t2,28(sp)
2000004c:	02812023          	sw	s0,32(sp)
20000050:	02912223          	sw	s1,36(sp)
20000054:	02a12423          	sw	a0,40(sp)
20000058:	02b12623          	sw	a1,44(sp)
2000005c:	02c12823          	sw	a2,48(sp)
20000060:	02d12a23          	sw	a3,52(sp)
20000064:	02e12c23          	sw	a4,56(sp)
20000068:	02f12e23          	sw	a5,60(sp)
2000006c:	05012023          	sw	a6,64(sp)
20000070:	05112223          	sw	a7,68(sp)
20000074:	05212423          	sw	s2,72(sp)
20000078:	05312623          	sw	s3,76(sp)
2000007c:	05412823          	sw	s4,80(sp)
20000080:	05512a23          	sw	s5,84(sp)
20000084:	05612c23          	sw	s6,88(sp)
20000088:	05712e23          	sw	s7,92(sp)
2000008c:	07812023          	sw	s8,96(sp)
20000090:	07912223          	sw	s9,100(sp)
20000094:	07a12423          	sw	s10,104(sp)
20000098:	07b12623          	sw	s11,108(sp)
2000009c:	07c12823          	sw	t3,112(sp)
200000a0:	07d12a23          	sw	t4,116(sp)
200000a4:	07e12c23          	sw	t5,120(sp)
200000a8:	07f12e23          	sw	t6,124(sp)
200000ac:	34202573          	csrr	a0,mcause
200000b0:	341025f3          	csrr	a1,mepc
200000b4:	00010613          	mv	a2,sp
200000b8:	218000ef          	jal	ra,200002d0 <handle_trap>
200000bc:	34151073          	csrw	mepc,a0
200000c0:	00412083          	lw	ra,4(sp)
200000c4:	00812103          	lw	sp,8(sp)
200000c8:	00c12183          	lw	gp,12(sp)
200000cc:	01012203          	lw	tp,16(sp)
200000d0:	01412283          	lw	t0,20(sp)
200000d4:	01812303          	lw	t1,24(sp)
200000d8:	01c12383          	lw	t2,28(sp)
200000dc:	02012403          	lw	s0,32(sp)
200000e0:	02412483          	lw	s1,36(sp)
200000e4:	02812503          	lw	a0,40(sp)
200000e8:	02c12583          	lw	a1,44(sp)
200000ec:	03012603          	lw	a2,48(sp)
200000f0:	03412683          	lw	a3,52(sp)
200000f4:	03812703          	lw	a4,56(sp)
200000f8:	03c12783          	lw	a5,60(sp)
200000fc:	04012803          	lw	a6,64(sp)
20000100:	04412883          	lw	a7,68(sp)
20000104:	04812903          	lw	s2,72(sp)
20000108:	04c12983          	lw	s3,76(sp)
2000010c:	05012a03          	lw	s4,80(sp)
20000110:	05412a83          	lw	s5,84(sp)
20000114:	05812b03          	lw	s6,88(sp)
20000118:	05c12b83          	lw	s7,92(sp)
2000011c:	06012c03          	lw	s8,96(sp)
20000120:	06412c83          	lw	s9,100(sp)
20000124:	06812d03          	lw	s10,104(sp)
20000128:	06c12d83          	lw	s11,108(sp)
2000012c:	07012e03          	lw	t3,112(sp)
20000130:	07412e83          	lw	t4,116(sp)
20000134:	07812f03          	lw	t5,120(sp)
20000138:	07c12f83          	lw	t6,124(sp)
2000013c:	08010113          	addi	sp,sp,128
20000140:	30200073          	mret
20000144:	0000                	unimp
20000146:	0000                	unimp

20000148 <__timer_handler>:
20000148:	40000437          	lui	s0,0x40000
2000014c:	00000293          	li	t0,0
20000150:	10042823          	sw	zero,272(s0) # 40000110 <_etext+0x1ffffd64>
20000154:	10b42023          	sw	a1,256(s0)
20000158:	10542a23          	sw	t0,276(s0)
2000015c:	00542023          	sw	t0,0(s0)
20000160:	30029073          	csrw	mstatus,t0
20000164:	30429073          	csrw	mie,t0
20000168:	30200073          	mret

2000016c <delay>:
2000016c:	fd010113          	addi	sp,sp,-48
20000170:	02812623          	sw	s0,44(sp)
20000174:	03010413          	addi	s0,sp,48
20000178:	fca42e23          	sw	a0,-36(s0)
2000017c:	400007b7          	lui	a5,0x40000
20000180:	10c78793          	addi	a5,a5,268 # 4000010c <_etext+0x1ffffd60>
20000184:	fef42623          	sw	a5,-20(s0)
20000188:	fec42783          	lw	a5,-20(s0)
2000018c:	fdc42703          	lw	a4,-36(s0)
20000190:	00e7a023          	sw	a4,0(a5)
20000194:	40000437          	lui	s0,0x40000
20000198:	10042823          	sw	zero,272(s0) # 40000110 <_etext+0x1ffffd64>
2000019c:	08000293          	li	t0,128
200001a0:	00800313          	li	t1,8
200001a4:	30031073          	csrw	mstatus,t1
200001a8:	30429073          	csrw	mie,t0
200001ac:	000205b7          	lui	a1,0x20
200001b0:	00258593          	addi	a1,a1,2 # 20002 <mcause_trap_table-0xffdfffe>
200001b4:	10b42023          	sw	a1,256(s0)
200001b8:	00100293          	li	t0,1
200001bc:	10542a23          	sw	t0,276(s0)
200001c0:	00542023          	sw	t0,0(s0)
200001c4:	200002b7          	lui	t0,0x20000
200001c8:	50028293          	addi	t0,t0,1280 # 20000500 <_etext+0x154>
200001cc:	30529073          	csrw	mtvec,t0
200001d0:	10500073          	wfi
200001d4:	00000013          	nop
200001d8:	02c12403          	lw	s0,44(sp)
200001dc:	03010113          	addi	sp,sp,48
200001e0:	00008067          	ret

200001e4 <PWM_DUTYCYCLE>:
200001e4:	fd010113          	addi	sp,sp,-48
200001e8:	02812623          	sw	s0,44(sp)
200001ec:	03010413          	addi	s0,sp,48
200001f0:	fca42e23          	sw	a0,-36(s0)
200001f4:	fcb42c23          	sw	a1,-40(s0)
200001f8:	fdc42703          	lw	a4,-36(s0)
200001fc:	00100793          	li	a5,1
20000200:	02f71e63          	bne	a4,a5,2000023c <PWM_DUTYCYCLE+0x58>
20000204:	400b07b7          	lui	a5,0x400b0
20000208:	00c78793          	addi	a5,a5,12 # 400b000c <_etext+0x200afc60>
2000020c:	fef42423          	sw	a5,-24(s0)
20000210:	fe842783          	lw	a5,-24(s0)
20000214:	fd842703          	lw	a4,-40(s0)
20000218:	00e7a023          	sw	a4,0(a5)
2000021c:	400b0437          	lui	s0,0x400b0
20000220:	01400313          	li	t1,20
20000224:	00642023          	sw	t1,0(s0) # 400b0000 <_etext+0x200afc54>
20000228:	00200313          	li	t1,2
2000022c:	00642223          	sw	t1,4(s0)
20000230:	00300313          	li	t1,3
20000234:	00642423          	sw	t1,8(s0)
20000238:	0380006f          	j	20000270 <PWM_DUTYCYCLE+0x8c>
2000023c:	400b07b7          	lui	a5,0x400b0
20000240:	01c78793          	addi	a5,a5,28 # 400b001c <_etext+0x200afc70>
20000244:	fef42623          	sw	a5,-20(s0)
20000248:	fec42783          	lw	a5,-20(s0)
2000024c:	fd842703          	lw	a4,-40(s0)
20000250:	00e7a023          	sw	a4,0(a5)
20000254:	400b0437          	lui	s0,0x400b0
20000258:	01400313          	li	t1,20
2000025c:	00642823          	sw	t1,16(s0) # 400b0010 <_etext+0x200afc64>
20000260:	00200313          	li	t1,2
20000264:	00642a23          	sw	t1,20(s0)
20000268:	00300313          	li	t1,3
2000026c:	00642c23          	sw	t1,24(s0)
20000270:	00000013          	nop
20000274:	02c12403          	lw	s0,44(sp)
20000278:	03010113          	addi	sp,sp,48
2000027c:	00008067          	ret

20000280 <extract_ie_code>:
20000280:	fd010113          	addi	sp,sp,-48
20000284:	02812623          	sw	s0,44(sp)
20000288:	03010413          	addi	s0,sp,48
2000028c:	fca42e23          	sw	a0,-36(s0)
20000290:	fdc42703          	lw	a4,-36(s0)
20000294:	800007b7          	lui	a5,0x80000
20000298:	fff7c793          	not	a5,a5
2000029c:	00f777b3          	and	a5,a4,a5
200002a0:	fef42623          	sw	a5,-20(s0)
200002a4:	fec42783          	lw	a5,-20(s0)
200002a8:	00078513          	mv	a0,a5
200002ac:	02c12403          	lw	s0,44(sp)
200002b0:	03010113          	addi	sp,sp,48
200002b4:	00008067          	ret

200002b8 <default_handler>:
200002b8:	fe010113          	addi	sp,sp,-32
200002bc:	00812e23          	sw	s0,28(sp)
200002c0:	02010413          	addi	s0,sp,32
200002c4:	fea42623          	sw	a0,-20(s0)
200002c8:	feb42423          	sw	a1,-24(s0)
200002cc:	0000006f          	j	200002cc <default_handler+0x14>

200002d0 <handle_trap>:
200002d0:	fd010113          	addi	sp,sp,-48
200002d4:	02112623          	sw	ra,44(sp)
200002d8:	02812423          	sw	s0,40(sp)
200002dc:	03010413          	addi	s0,sp,48
200002e0:	fca42e23          	sw	a0,-36(s0)
200002e4:	fcb42c23          	sw	a1,-40(s0)
200002e8:	fe042623          	sw	zero,-20(s0)
200002ec:	fe042423          	sw	zero,-24(s0)
200002f0:	01f00793          	li	a5,31
200002f4:	fef42423          	sw	a5,-24(s0)
200002f8:	fe842783          	lw	a5,-24(s0)
200002fc:	00100713          	li	a4,1
20000300:	00f717b3          	sll	a5,a4,a5
20000304:	00078713          	mv	a4,a5
20000308:	fdc42783          	lw	a5,-36(s0)
2000030c:	00f777b3          	and	a5,a4,a5
20000310:	02078a63          	beqz	a5,20000344 <handle_trap+0x74>
20000314:	fdc42503          	lw	a0,-36(s0)
20000318:	f69ff0ef          	jal	ra,20000280 <extract_ie_code>
2000031c:	fea42623          	sw	a0,-20(s0)
20000320:	00818713          	addi	a4,gp,8 # 10000008 <mcause_interrupt_table>
20000324:	fec42783          	lw	a5,-20(s0)
20000328:	00279793          	slli	a5,a5,0x2
2000032c:	00f707b3          	add	a5,a4,a5
20000330:	0007a783          	lw	a5,0(a5) # 80000000 <_etext+0x5ffffc54>
20000334:	fd842583          	lw	a1,-40(s0)
20000338:	fdc42503          	lw	a0,-36(s0)
2000033c:	000780e7          	jalr	a5
20000340:	0240006f          	j	20000364 <handle_trap+0x94>
20000344:	00018713          	mv	a4,gp
20000348:	fdc42783          	lw	a5,-36(s0)
2000034c:	00279793          	slli	a5,a5,0x2
20000350:	00f707b3          	add	a5,a4,a5
20000354:	0007a783          	lw	a5,0(a5)
20000358:	fd842583          	lw	a1,-40(s0)
2000035c:	fdc42503          	lw	a0,-36(s0)
20000360:	000780e7          	jalr	a5
20000364:	fd842783          	lw	a5,-40(s0)
20000368:	00078513          	mv	a0,a5
2000036c:	02c12083          	lw	ra,44(sp)
20000370:	02812403          	lw	s0,40(sp)
20000374:	03010113          	addi	sp,sp,48
20000378:	00008067          	ret

2000037c <main>:
2000037c:	ff010113          	addi	sp,sp,-16
20000380:	00112623          	sw	ra,12(sp)
20000384:	00812423          	sw	s0,8(sp)
20000388:	01010413          	addi	s0,sp,16
2000038c:	00500513          	li	a0,5
20000390:	dddff0ef          	jal	ra,2000016c <delay>
20000394:	00000793          	li	a5,0
20000398:	00078513          	mv	a0,a5
2000039c:	00c12083          	lw	ra,12(sp)
200003a0:	00812403          	lw	s0,8(sp)
200003a4:	01010113          	addi	sp,sp,16
200003a8:	00008067          	ret

Disassembly of section .eh_frame:

200003ac <__global_pointer$+0x100003ac>:
200003ac:	0014                	0x14
200003ae:	0000                	unimp
200003b0:	0000                	unimp
200003b2:	0000                	unimp
200003b4:	00527a03          	0x527a03
200003b8:	7c01                	lui	s8,0xfffe0
200003ba:	0101                	addi	sp,sp,0
200003bc:	07020d1b          	0x7020d1b
200003c0:	0001                	nop
200003c2:	0000                	unimp
200003c4:	0010                	0x10
200003c6:	0000                	unimp
200003c8:	001c                	0x1c
200003ca:	0000                	unimp
200003cc:	fc40                	fsw	fs0,60(s0)
200003ce:	ffff                	0xffff
200003d0:	0018                	0x18
200003d2:	0000                	unimp
200003d4:	0000                	unimp
200003d6:	0000                	unimp

Disassembly of section .sbss:

10000000 <mcause_trap_table>:
10000000:	0000                	unimp
10000002:	0000                	unimp
10000004:	0000                	unimp
10000006:	0000                	unimp

10000008 <mcause_interrupt_table>:
10000008:	0000                	unimp
1000000a:	0000                	unimp
1000000c:	0000                	unimp
1000000e:	0000                	unimp

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	1f41                	addi	t5,t5,-16
   2:	0000                	unimp
   4:	7200                	flw	fs0,32(a2)
   6:	7369                	lui	t1,0xffffa
   8:	01007663          	bgeu	zero,a6,14 <mcause_trap_table-0xfffffec>
   c:	0015                	c.nop	5
   e:	0000                	unimp
  10:	1004                	addi	s1,sp,32
  12:	7205                	lui	tp,0xfffe1
  14:	3376                	fld	ft6,376(sp)
  16:	6932                	flw	fs2,12(sp)
  18:	7032                	flw	ft0,44(sp)
  1a:	0030                	addi	a2,sp,8
  1c:	0108                	addi	a0,sp,128
  1e:	0b0a                	slli	s6,s6,0x2

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	fmsub.d	ft6,ft6,ft4,ft7,rmm
   4:	2820                	fld	fs0,80(s0)
   6:	29554e47          	fmsub.s	ft8,fa0,fs5,ft5,rmm
   a:	3120                	fld	fs0,96(a0)
   c:	2e30                	fld	fa2,88(a2)
   e:	2e32                	fld	ft8,264(sp)
  10:	0030                	addi	a2,sp,8
