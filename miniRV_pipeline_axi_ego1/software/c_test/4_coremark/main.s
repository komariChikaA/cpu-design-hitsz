
E:\?????\????\cpu\cpu-design-hitsz\outputs\coremark_build_20260729_v5\coremark.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
       0:	00026137          	lui	sp,0x26
       4:	80010113          	addi	sp,sp,-2048 # 25800 <_stack_top>
       8:	ffff32b7          	lui	t0,0xffff3
       c:	00306313          	ori	t1,zero,3
      10:	0062a623          	sw	t1,12(t0) # ffff300c <_stack_top+0xfffcd80c>
      14:	31d040ef          	jal	ra,4b30 <main>
      18:	0000006f          	j	18 <_start+0x18>

0000001c <get_time>:
      1c:	0000d7b7          	lui	a5,0xd
      20:	0000d737          	lui	a4,0xd
      24:	1987a283          	lw	t0,408(a5) # d198 <timer_high>
      28:	19c72683          	lw	a3,412(a4) # d19c <timer_low>
      2c:	0002a583          	lw	a1,0(t0)
      30:	0006a503          	lw	a0,0(a3)
      34:	0002a303          	lw	t1,0(t0)
      38:	fe659ae3          	bne	a1,t1,2c <get_time+0x10>
      3c:	00008067          	ret

00000040 <start_time>:
      40:	0000d7b7          	lui	a5,0xd
      44:	0000d2b7          	lui	t0,0xd
      48:	1987a703          	lw	a4,408(a5) # d198 <timer_high>
      4c:	19c2a583          	lw	a1,412(t0) # d19c <timer_low>
      50:	00072303          	lw	t1,0(a4)
      54:	0005a603          	lw	a2,0(a1)
      58:	00072683          	lw	a3,0(a4)
      5c:	fed31ae3          	bne	t1,a3,50 <start_time+0x10>
      60:	0000e3b7          	lui	t2,0xe
      64:	98c3a823          	sw	a2,-1648(t2) # d990 <start_time_val>
      68:	9863aa23          	sw	t1,-1644(t2)
      6c:	00008067          	ret

00000070 <stop_time>:
      70:	0000d7b7          	lui	a5,0xd
      74:	0000d2b7          	lui	t0,0xd
      78:	1987a703          	lw	a4,408(a5) # d198 <timer_high>
      7c:	19c2a583          	lw	a1,412(t0) # d19c <timer_low>
      80:	00072303          	lw	t1,0(a4)
      84:	0005a603          	lw	a2,0(a1)
      88:	00072683          	lw	a3,0(a4)
      8c:	fed31ae3          	bne	t1,a3,80 <stop_time+0x10>
      90:	0000e3b7          	lui	t2,0xe
      94:	98c3a423          	sw	a2,-1656(t2) # d988 <stop_time_val>
      98:	9863a623          	sw	t1,-1652(t2)
      9c:	00008067          	ret

000000a0 <get_time_elasped>:
      a0:	0000e6b7          	lui	a3,0xe
      a4:	0000e737          	lui	a4,0xe
      a8:	9886a783          	lw	a5,-1656(a3) # d988 <stop_time_val>
      ac:	99072503          	lw	a0,-1648(a4) # d990 <start_time_val>
      b0:	98c6a583          	lw	a1,-1652(a3)
      b4:	99472283          	lw	t0,-1644(a4)
      b8:	40a78533          	sub	a0,a5,a0
      bc:	00a7b333          	sltu	t1,a5,a0
      c0:	405583b3          	sub	t2,a1,t0
      c4:	406385b3          	sub	a1,t2,t1
      c8:	00008067          	ret

000000cc <time_in_secs>:
      cc:	02faf7b7          	lui	a5,0x2faf
      d0:	08078293          	addi	t0,a5,128 # 2faf080 <_stack_top+0x2f89880>
      d4:	02555533          	divu	a0,a0,t0
      d8:	00008067          	ret

000000dc <delay_ms>:
      dc:	fe010113          	addi	sp,sp,-32
      e0:	00112e23          	sw	ra,28(sp)
      e4:	0000d7b7          	lui	a5,0xd
      e8:	0000d0b7          	lui	ra,0xd
      ec:	00812c23          	sw	s0,24(sp)
      f0:	00912a23          	sw	s1,20(sp)
      f4:	1987a403          	lw	s0,408(a5) # d198 <timer_high>
      f8:	19c0a483          	lw	s1,412(ra) # d19c <timer_low>
      fc:	01212823          	sw	s2,16(sp)
     100:	01312623          	sw	s3,12(sp)
     104:	00042903          	lw	s2,0(s0)
     108:	0004a983          	lw	s3,0(s1)
     10c:	00042283          	lw	t0,0(s0)
     110:	fe591ae3          	bne	s2,t0,104 <delay_ms+0x28>
     114:	02faf337          	lui	t1,0x2faf
     118:	08030393          	addi	t2,t1,128 # 2faf080 <_stack_top+0x2f89880>
     11c:	027515b3          	mulh	a1,a0,t2
     120:	3e800613          	li	a2,1000
     124:	00000693          	li	a3,0
     128:	02750533          	mul	a0,a0,t2
     12c:	1bc060ef          	jal	ra,62e8 <__udivdi3>
     130:	00042603          	lw	a2,0(s0)
     134:	0004a683          	lw	a3,0(s1)
     138:	00042703          	lw	a4,0(s0)
     13c:	fee61ae3          	bne	a2,a4,130 <delay_ms+0x54>
     140:	41368833          	sub	a6,a3,s3
     144:	0106b8b3          	sltu	a7,a3,a6
     148:	41260e33          	sub	t3,a2,s2
     14c:	411e0eb3          	sub	t4,t3,a7
     150:	febee0e3          	bltu	t4,a1,130 <delay_ms+0x54>
     154:	01d59463          	bne	a1,t4,15c <delay_ms+0x80>
     158:	fca86ce3          	bltu	a6,a0,130 <delay_ms+0x54>
     15c:	01c12083          	lw	ra,28(sp)
     160:	01812403          	lw	s0,24(sp)
     164:	01412483          	lw	s1,20(sp)
     168:	01012903          	lw	s2,16(sp)
     16c:	00c12983          	lw	s3,12(sp)
     170:	02010113          	addi	sp,sp,32
     174:	00008067          	ret

00000178 <portable_init>:
     178:	ff010113          	addi	sp,sp,-16
     17c:	0000d7b7          	lui	a5,0xd
     180:	00112623          	sw	ra,12(sp)
     184:	1947a683          	lw	a3,404(a5) # d194 <board_led>
     188:	0000d0b7          	lui	ra,0xd
     18c:	1900a703          	lw	a4,400(ra) # d190 <board_dig>
     190:	0000c2b7          	lui	t0,0xc
     194:	00812423          	sw	s0,8(sp)
     198:	00128313          	addi	t1,t0,1 # c001 <_etext+0x3735>
     19c:	0066a023          	sw	t1,0(a3)
     1a0:	c00103b7          	lui	t2,0xc0010
     1a4:	00772023          	sw	t2,0(a4)
     1a8:	00050413          	mv	s0,a0
     1ac:	06400513          	li	a0,100
     1b0:	f2dff0ef          	jal	ra,dc <delay_ms>
     1b4:	0000d537          	lui	a0,0xd
     1b8:	9d450513          	addi	a0,a0,-1580 # c9d4 <errpat+0x10>
     1bc:	1cc000ef          	jal	ra,388 <sc_printf>
     1c0:	0000d637          	lui	a2,0xd
     1c4:	0000d5b7          	lui	a1,0xd
     1c8:	a1060513          	addi	a0,a2,-1520 # ca10 <errpat+0x4c>
     1cc:	9f858593          	addi	a1,a1,-1544 # c9f8 <errpat+0x34>
     1d0:	1b8000ef          	jal	ra,388 <sc_printf>
     1d4:	0000d837          	lui	a6,0xd
     1d8:	03200593          	li	a1,50
     1dc:	a2480513          	addi	a0,a6,-1500 # ca24 <errpat+0x60>
     1e0:	1a8000ef          	jal	ra,388 <sc_printf>
     1e4:	0000d8b7          	lui	a7,0xd
     1e8:	a3888513          	addi	a0,a7,-1480 # ca38 <errpat+0x74>
     1ec:	19c000ef          	jal	ra,388 <sc_printf>
     1f0:	00100e13          	li	t3,1
     1f4:	01c40023          	sb	t3,0(s0)
     1f8:	00c12083          	lw	ra,12(sp)
     1fc:	00812403          	lw	s0,8(sp)
     200:	01010113          	addi	sp,sp,16
     204:	00008067          	ret

00000208 <board_result>:
     208:	0000d7b7          	lui	a5,0xd
     20c:	0000d2b7          	lui	t0,0xd
     210:	1947a703          	lw	a4,404(a5) # d194 <board_led>
     214:	1902a303          	lw	t1,400(t0) # d190 <board_dig>
     218:	02051063          	bnez	a0,238 <board_result+0x30>
     21c:	0000ceb7          	lui	t4,0xc
     220:	0a5e8f13          	addi	t5,t4,165 # c0a5 <_etext+0x37d9>
     224:	c0de6fb7          	lui	t6,0xc0de6
     228:	01e72023          	sw	t5,0(a4)
     22c:	00df8793          	addi	a5,t6,13 # c0de600d <_stack_top+0xc0dc080d>
     230:	00f32023          	sw	a5,0(t1)
     234:	00008067          	ret
     238:	02a05263          	blez	a0,25c <board_result+0x54>
     23c:	0ff57593          	zext.b	a1,a0
     240:	0000e637          	lui	a2,0xe
     244:	00c5e833          	or	a6,a1,a2
     248:	e00008b7          	lui	a7,0xe0000
     24c:	01072023          	sw	a6,0(a4)
     250:	01156e33          	or	t3,a0,a7
     254:	01c32023          	sw	t3,0(t1)
     258:	00008067          	ret
     25c:	0000e6b7          	lui	a3,0xe
     260:	0ff68393          	addi	t2,a3,255 # e0ff <seed1_volatile+0x75f>
     264:	00772023          	sw	t2,0(a4)
     268:	e0ff0537          	lui	a0,0xe0ff0
     26c:	00a32023          	sw	a0,0(t1)
     270:	00008067          	ret

00000274 <portable_fini>:
     274:	0000e737          	lui	a4,0xe
     278:	0000e6b7          	lui	a3,0xe
     27c:	ff010113          	addi	sp,sp,-16
     280:	9886a783          	lw	a5,-1656(a3) # d988 <stop_time_val>
     284:	99072503          	lw	a0,-1648(a4) # d990 <start_time_val>
     288:	98c6a583          	lw	a1,-1652(a3)
     28c:	00112623          	sw	ra,12(sp)
     290:	99472083          	lw	ra,-1644(a4)
     294:	40a78533          	sub	a0,a5,a0
     298:	00a7b2b3          	sltu	t0,a5,a0
     29c:	40158333          	sub	t1,a1,ra
     2a0:	405305b3          	sub	a1,t1,t0
     2a4:	00812423          	sw	s0,8(sp)
     2a8:	2ec080ef          	jal	ra,8594 <__floatundisf>
     2ac:	0000d3b7          	lui	t2,0xd
     2b0:	00050593          	mv	a1,a0
     2b4:	1203a503          	lw	a0,288(t2) # d120 <__clz_tab+0x100>
     2b8:	0000d437          	lui	s0,0xd
     2bc:	2d1070ef          	jal	ra,7d8c <__divsf3>
     2c0:	12442583          	lw	a1,292(s0) # d124 <__clz_tab+0x104>
     2c4:	00050413          	mv	s0,a0
     2c8:	6cd070ef          	jal	ra,8194 <__mulsf3>
     2cc:	480080ef          	jal	ra,874c <__extendsfdf2>
     2d0:	0000d837          	lui	a6,0xd
     2d4:	00050613          	mv	a2,a0
     2d8:	00058693          	mv	a3,a1
     2dc:	a4880513          	addi	a0,a6,-1464 # ca48 <errpat+0x84>
     2e0:	0a8000ef          	jal	ra,388 <sc_printf>
     2e4:	00040513          	mv	a0,s0
     2e8:	464080ef          	jal	ra,874c <__extendsfdf2>
     2ec:	0000d8b7          	lui	a7,0xd
     2f0:	00050613          	mv	a2,a0
     2f4:	00058693          	mv	a3,a1
     2f8:	a5c88513          	addi	a0,a7,-1444 # ca5c <errpat+0x98>
     2fc:	08c000ef          	jal	ra,388 <sc_printf>
     300:	00812403          	lw	s0,8(sp)
     304:	00c12083          	lw	ra,12(sp)
     308:	0000d637          	lui	a2,0xd
     30c:	a7060513          	addi	a0,a2,-1424 # ca70 <errpat+0xac>
     310:	01010113          	addi	sp,sp,16
     314:	0740006f          	j	388 <sc_printf>

00000318 <printf_putch>:
     318:	0000d7b7          	lui	a5,0xd
     31c:	1ac7a703          	lw	a4,428(a5) # d1ac <uart_stat_reg>
     320:	0ff57613          	zext.b	a2,a0
     324:	00072283          	lw	t0,0(a4)
     328:	0082f313          	andi	t1,t0,8
     32c:	fe031ce3          	bnez	t1,324 <printf_putch+0xc>
     330:	0000d3b7          	lui	t2,0xd
     334:	1b03a683          	lw	a3,432(t2) # d1b0 <uart_tx_fifo>
     338:	0ff57513          	zext.b	a0,a0
     33c:	00a00593          	li	a1,10
     340:	00a6a023          	sw	a0,0(a3)
     344:	00b60463          	beq	a2,a1,34c <printf_putch+0x34>
     348:	00008067          	ret
     34c:	00072803          	lw	a6,0(a4)
     350:	00887893          	andi	a7,a6,8
     354:	fe089ce3          	bnez	a7,34c <printf_putch+0x34>
     358:	00d00e13          	li	t3,13
     35c:	01c6a023          	sw	t3,0(a3)
     360:	00008067          	ret

00000364 <uart_putc>:
     364:	0000d7b7          	lui	a5,0xd
     368:	1ac7a703          	lw	a4,428(a5) # d1ac <uart_stat_reg>
     36c:	00072283          	lw	t0,0(a4)
     370:	0082f313          	andi	t1,t0,8
     374:	fe031ce3          	bnez	t1,36c <uart_putc+0x8>
     378:	0000d3b7          	lui	t2,0xd
     37c:	1b03a583          	lw	a1,432(t2) # d1b0 <uart_tx_fifo>
     380:	00a5a023          	sw	a0,0(a1)
     384:	00008067          	ret

00000388 <sc_printf>:
     388:	fc010113          	addi	sp,sp,-64
     38c:	02410313          	addi	t1,sp,36
     390:	02b12223          	sw	a1,36(sp)
     394:	00030593          	mv	a1,t1
     398:	00112e23          	sw	ra,28(sp)
     39c:	02c12423          	sw	a2,40(sp)
     3a0:	02d12623          	sw	a3,44(sp)
     3a4:	02e12823          	sw	a4,48(sp)
     3a8:	02f12a23          	sw	a5,52(sp)
     3ac:	03012c23          	sw	a6,56(sp)
     3b0:	03112e23          	sw	a7,60(sp)
     3b4:	00612623          	sw	t1,12(sp)
     3b8:	014000ef          	jal	ra,3cc <vprintfmt.constprop.0>
     3bc:	01c12083          	lw	ra,28(sp)
     3c0:	00000513          	li	a0,0
     3c4:	04010113          	addi	sp,sp,64
     3c8:	00008067          	ret

000003cc <vprintfmt.constprop.0>:
     3cc:	eb010113          	addi	sp,sp,-336
     3d0:	13412c23          	sw	s4,312(sp)
     3d4:	0000da37          	lui	s4,0xd
     3d8:	14112623          	sw	ra,332(sp)
     3dc:	06100793          	li	a5,97
     3e0:	800a0093          	addi	ra,s4,-2048 # c800 <_etext+0x3f34>
     3e4:	14812423          	sw	s0,328(sp)
     3e8:	13612823          	sw	s6,304(sp)
     3ec:	14912223          	sw	s1,324(sp)
     3f0:	15212023          	sw	s2,320(sp)
     3f4:	13312e23          	sw	s3,316(sp)
     3f8:	13512a23          	sw	s5,308(sp)
     3fc:	13712623          	sw	s7,300(sp)
     400:	13812423          	sw	s8,296(sp)
     404:	13912223          	sw	s9,292(sp)
     408:	13a12023          	sw	s10,288(sp)
     40c:	11b12e23          	sw	s11,284(sp)
     410:	00050b13          	mv	s6,a0
     414:	00b12223          	sw	a1,4(sp)
     418:	00f12623          	sw	a5,12(sp)
     41c:	02500413          	li	s0,37
     420:	00112423          	sw	ra,8(sp)
     424:	000b4683          	lbu	a3,0(s6)
     428:	02868e63          	beq	a3,s0,464 <vprintfmt.constprop.0+0x98>
     42c:	08068c63          	beqz	a3,4c4 <vprintfmt.constprop.0+0xf8>
     430:	0000dbb7          	lui	s7,0xd
     434:	1acba983          	lw	s3,428(s7) # d1ac <uart_stat_reg>
     438:	0009af83          	lw	t6,0(s3)
     43c:	008ff313          	andi	t1,t6,8
     440:	fe031ce3          	bnez	t1,438 <vprintfmt.constprop.0+0x6c>
     444:	0000d537          	lui	a0,0xd
     448:	1b052a03          	lw	s4,432(a0) # d1b0 <uart_tx_fifo>
     44c:	00a00a93          	li	s5,10
     450:	00da2023          	sw	a3,0(s4)
     454:	05568a63          	beq	a3,s5,4a8 <vprintfmt.constprop.0+0xdc>
     458:	001b0b13          	addi	s6,s6,1
     45c:	000b4683          	lbu	a3,0(s6)
     460:	fc8696e3          	bne	a3,s0,42c <vprintfmt.constprop.0+0x60>
     464:	001b4a03          	lbu	s4,1(s6)
     468:	001b0513          	addi	a0,s6,1
     46c:	00050713          	mv	a4,a0
     470:	02000c93          	li	s9,32
     474:	fff00b93          	li	s7,-1
     478:	fff00d13          	li	s10,-1
     47c:	00000593          	li	a1,0
     480:	fdda0293          	addi	t0,s4,-35
     484:	0ff2f313          	zext.b	t1,t0
     488:	05500613          	li	a2,85
     48c:	00170b13          	addi	s6,a4,1
     490:	08666863          	bltu	a2,t1,520 <vprintfmt.constprop.0+0x154>
     494:	00812483          	lw	s1,8(sp)
     498:	00231393          	slli	t2,t1,0x2
     49c:	00938833          	add	a6,t2,s1
     4a0:	00082883          	lw	a7,0(a6)
     4a4:	00088067          	jr	a7
     4a8:	0009ae03          	lw	t3,0(s3)
     4ac:	008e7e93          	andi	t4,t3,8
     4b0:	fe0e9ce3          	bnez	t4,4a8 <vprintfmt.constprop.0+0xdc>
     4b4:	00d00f13          	li	t5,13
     4b8:	01ea2023          	sw	t5,0(s4)
     4bc:	001b0b13          	addi	s6,s6,1
     4c0:	f9dff06f          	j	45c <vprintfmt.constprop.0+0x90>
     4c4:	14c12083          	lw	ra,332(sp)
     4c8:	14812403          	lw	s0,328(sp)
     4cc:	14412483          	lw	s1,324(sp)
     4d0:	14012903          	lw	s2,320(sp)
     4d4:	13c12983          	lw	s3,316(sp)
     4d8:	13812a03          	lw	s4,312(sp)
     4dc:	13412a83          	lw	s5,308(sp)
     4e0:	13012b03          	lw	s6,304(sp)
     4e4:	12c12b83          	lw	s7,300(sp)
     4e8:	12812c03          	lw	s8,296(sp)
     4ec:	12412c83          	lw	s9,292(sp)
     4f0:	12012d03          	lw	s10,288(sp)
     4f4:	11c12d83          	lw	s11,284(sp)
     4f8:	15010113          	addi	sp,sp,336
     4fc:	00008067          	ret
     500:	000a0c93          	mv	s9,s4
     504:	00174a03          	lbu	s4,1(a4)
     508:	05500613          	li	a2,85
     50c:	000b0713          	mv	a4,s6
     510:	fdda0293          	addi	t0,s4,-35
     514:	0ff2f313          	zext.b	t1,t0
     518:	00170b13          	addi	s6,a4,1
     51c:	f6667ce3          	bgeu	a2,t1,494 <vprintfmt.constprop.0+0xc8>
     520:	0000db37          	lui	s6,0xd
     524:	1acb2d83          	lw	s11,428(s6) # d1ac <uart_stat_reg>
     528:	000da703          	lw	a4,0(s11)
     52c:	00877393          	andi	t2,a4,8
     530:	fe039ce3          	bnez	t2,528 <vprintfmt.constprop.0+0x15c>
     534:	0000d5b7          	lui	a1,0xd
     538:	1b05a803          	lw	a6,432(a1) # d1b0 <uart_tx_fifo>
     53c:	02500893          	li	a7,37
     540:	00050b13          	mv	s6,a0
     544:	01182023          	sw	a7,0(a6)
     548:	eddff06f          	j	424 <vprintfmt.constprop.0+0x58>
     54c:	00174483          	lbu	s1,1(a4)
     550:	00900f93          	li	t6,9
     554:	fd0a0b93          	addi	s7,s4,-48
     558:	fd048793          	addi	a5,s1,-48
     55c:	00048a13          	mv	s4,s1
     560:	56ffec63          	bltu	t6,a5,ad8 <vprintfmt.constprop.0+0x70c>
     564:	000b0713          	mv	a4,s6
     568:	00900b13          	li	s6,9
     56c:	002b9093          	slli	ra,s7,0x2
     570:	017086b3          	add	a3,ra,s7
     574:	00170713          	addi	a4,a4,1
     578:	00169293          	slli	t0,a3,0x1
     57c:	00928333          	add	t1,t0,s1
     580:	00074483          	lbu	s1,0(a4)
     584:	fd030b93          	addi	s7,t1,-48
     588:	fd048913          	addi	s2,s1,-48
     58c:	00048a13          	mv	s4,s1
     590:	fd2b7ee3          	bgeu	s6,s2,56c <vprintfmt.constprop.0+0x1a0>
     594:	ee0d56e3          	bgez	s10,480 <vprintfmt.constprop.0+0xb4>
     598:	000b8d13          	mv	s10,s7
     59c:	fff00b93          	li	s7,-1
     5a0:	ee1ff06f          	j	480 <vprintfmt.constprop.0+0xb4>
     5a4:	00412d03          	lw	s10,4(sp)
     5a8:	0000dcb7          	lui	s9,0xd
     5ac:	1acca483          	lw	s1,428(s9) # d1ac <uart_stat_reg>
     5b0:	000d2a03          	lw	s4,0(s10)
     5b4:	0ffa7913          	zext.b	s2,s4
     5b8:	0004a603          	lw	a2,0(s1)
     5bc:	00867b93          	andi	s7,a2,8
     5c0:	fe0b9ce3          	bnez	s7,5b8 <vprintfmt.constprop.0+0x1ec>
     5c4:	0000d3b7          	lui	t2,0xd
     5c8:	1b03a803          	lw	a6,432(t2) # d1b0 <uart_tx_fifo>
     5cc:	0ffa7893          	zext.b	a7,s4
     5d0:	00a00993          	li	s3,10
     5d4:	01182023          	sw	a7,0(a6)
     5d8:	01390a63          	beq	s2,s3,5ec <vprintfmt.constprop.0+0x220>
     5dc:	00412e03          	lw	t3,4(sp)
     5e0:	004e0e93          	addi	t4,t3,4
     5e4:	01d12223          	sw	t4,4(sp)
     5e8:	e3dff06f          	j	424 <vprintfmt.constprop.0+0x58>
     5ec:	0004aa83          	lw	s5,0(s1)
     5f0:	008afc13          	andi	s8,s5,8
     5f4:	fe0c1ce3          	bnez	s8,5ec <vprintfmt.constprop.0+0x220>
     5f8:	00d00d93          	li	s11,13
     5fc:	01b82023          	sw	s11,0(a6)
     600:	fddff06f          	j	5dc <vprintfmt.constprop.0+0x210>
     604:	00100a93          	li	s5,1
     608:	3ebacc63          	blt	s5,a1,a00 <vprintfmt.constprop.0+0x634>
     60c:	00412c03          	lw	s8,4(sp)
     610:	000c2b83          	lw	s7,0(s8)
     614:	004c0d93          	addi	s11,s8,4
     618:	01b12223          	sw	s11,4(sp)
     61c:	41fbde13          	srai	t3,s7,0x1f
     620:	0000d0b7          	lui	ra,0xd
     624:	0000d6b7          	lui	a3,0xd
     628:	1ac0aa83          	lw	s5,428(ra) # d1ac <uart_stat_reg>
     62c:	1b06aa03          	lw	s4,432(a3) # d1b0 <uart_tx_fifo>
     630:	100e4663          	bltz	t3,73c <vprintfmt.constprop.0+0x370>
     634:	000e0993          	mv	s3,t3
     638:	00a00c13          	li	s8,10
     63c:	00000d93          	li	s11,0
     640:	000c0613          	mv	a2,s8
     644:	00000693          	li	a3,0
     648:	000b8513          	mv	a0,s7
     64c:	00098593          	mv	a1,s3
     650:	150060ef          	jal	ra,67a0 <__umoddi3>
     654:	00a12823          	sw	a0,16(sp)
     658:	1f3d8a63          	beq	s11,s3,84c <vprintfmt.constprop.0+0x480>
     65c:	01410913          	addi	s2,sp,20
     660:	00100493          	li	s1,1
     664:	000c0613          	mv	a2,s8
     668:	00000693          	li	a3,0
     66c:	000b8513          	mv	a0,s7
     670:	00098593          	mv	a1,s3
     674:	475050ef          	jal	ra,62e8 <__udivdi3>
     678:	000c0613          	mv	a2,s8
     67c:	00000693          	li	a3,0
     680:	00050b93          	mv	s7,a0
     684:	00058993          	mv	s3,a1
     688:	118060ef          	jal	ra,67a0 <__umoddi3>
     68c:	00a92023          	sw	a0,0(s2)
     690:	00048f93          	mv	t6,s1
     694:	00490913          	addi	s2,s2,4
     698:	00148493          	addi	s1,s1,1
     69c:	fd3d94e3          	bne	s11,s3,664 <vprintfmt.constprop.0+0x298>
     6a0:	fd8bf2e3          	bgeu	s7,s8,664 <vprintfmt.constprop.0+0x298>
     6a4:	fffd0693          	addi	a3,s10,-1
     6a8:	fff48093          	addi	ra,s1,-1
     6ac:	01a4de63          	bge	s1,s10,6c8 <vprintfmt.constprop.0+0x2fc>
     6b0:	000aad03          	lw	s10,0(s5)
     6b4:	008d7793          	andi	a5,s10,8
     6b8:	fe079ce3          	bnez	a5,6b0 <vprintfmt.constprop.0+0x2e4>
     6bc:	019a2023          	sw	s9,0(s4)
     6c0:	fff68693          	addi	a3,a3,-1
     6c4:	fed096e3          	bne	ra,a3,6b0 <vprintfmt.constprop.0+0x2e4>
     6c8:	00c12283          	lw	t0,12(sp)
     6cc:	01010513          	addi	a0,sp,16
     6d0:	002f9c93          	slli	s9,t6,0x2
     6d4:	019507b3          	add	a5,a0,s9
     6d8:	00900e13          	li	t3,9
     6dc:	ff628e93          	addi	t4,t0,-10
     6e0:	00a00313          	li	t1,10
     6e4:	00d00f13          	li	t5,13
     6e8:	0007ac03          	lw	s8,0(a5)
     6ec:	03000d93          	li	s11,48
     6f0:	018e7463          	bgeu	t3,s8,6f8 <vprintfmt.constprop.0+0x32c>
     6f4:	000e8d93          	mv	s11,t4
     6f8:	01bc0733          	add	a4,s8,s11
     6fc:	0ff77393          	zext.b	t2,a4
     700:	000aa583          	lw	a1,0(s5)
     704:	0085f813          	andi	a6,a1,8
     708:	fe081ce3          	bnez	a6,700 <vprintfmt.constprop.0+0x334>
     70c:	0ff77893          	zext.b	a7,a4
     710:	011a2023          	sw	a7,0(s4)
     714:	00638a63          	beq	t2,t1,728 <vprintfmt.constprop.0+0x35c>
     718:	ffc78f93          	addi	t6,a5,-4
     71c:	d0f504e3          	beq	a0,a5,424 <vprintfmt.constprop.0+0x58>
     720:	000f8793          	mv	a5,t6
     724:	fc5ff06f          	j	6e8 <vprintfmt.constprop.0+0x31c>
     728:	000aab83          	lw	s7,0(s5)
     72c:	008bf993          	andi	s3,s7,8
     730:	fe099ce3          	bnez	s3,728 <vprintfmt.constprop.0+0x35c>
     734:	01ea2023          	sw	t5,0(s4)
     738:	fe1ff06f          	j	718 <vprintfmt.constprop.0+0x34c>
     73c:	000aa503          	lw	a0,0(s5)
     740:	00857593          	andi	a1,a0,8
     744:	fe059ce3          	bnez	a1,73c <vprintfmt.constprop.0+0x370>
     748:	01703733          	snez	a4,s7
     74c:	41c002b3          	neg	t0,t3
     750:	02d00313          	li	t1,45
     754:	006a2023          	sw	t1,0(s4)
     758:	41700bb3          	neg	s7,s7
     75c:	40e289b3          	sub	s3,t0,a4
     760:	00a00c13          	li	s8,10
     764:	00000d93          	li	s11,0
     768:	ed9ff06f          	j	640 <vprintfmt.constprop.0+0x274>
     76c:	00412c83          	lw	s9,4(sp)
     770:	0000d9b7          	lui	s3,0xd
     774:	007c8293          	addi	t0,s9,7
     778:	ff82f313          	andi	t1,t0,-8
     77c:	00032483          	lw	s1,0(t1)
     780:	00432903          	lw	s2,4(t1)
     784:	00830613          	addi	a2,t1,8
     788:	00048513          	mv	a0,s1
     78c:	00090593          	mv	a1,s2
     790:	00c12223          	sw	a2,4(sp)
     794:	4bc070ef          	jal	ra,7c50 <__fixdfsi>
     798:	00050b93          	mv	s7,a0
     79c:	538070ef          	jal	ra,7cd4 <__floatsidf>
     7a0:	00050613          	mv	a2,a0
     7a4:	00058693          	mv	a3,a1
     7a8:	00048513          	mv	a0,s1
     7ac:	00090593          	mv	a1,s2
     7b0:	38d060ef          	jal	ra,733c <__subdf3>
     7b4:	0000d3b7          	lui	t2,0xd
     7b8:	1283a603          	lw	a2,296(t2) # d128 <__clz_tab+0x108>
     7bc:	12c3a683          	lw	a3,300(t2)
     7c0:	458060ef          	jal	ra,6c18 <__muldf3>
     7c4:	48c070ef          	jal	ra,7c50 <__fixdfsi>
     7c8:	41f55813          	srai	a6,a0,0x1f
     7cc:	00a848b3          	xor	a7,a6,a0
     7d0:	41088633          	sub	a2,a7,a6
     7d4:	000b8593          	mv	a1,s7
     7d8:	a8098513          	addi	a0,s3,-1408 # ca80 <errpat+0xbc>
     7dc:	badff0ef          	jal	ra,388 <sc_printf>
     7e0:	c45ff06f          	j	424 <vprintfmt.constprop.0+0x58>
     7e4:	00174a03          	lbu	s4,1(a4)
     7e8:	00158593          	addi	a1,a1,1
     7ec:	000b0713          	mv	a4,s6
     7f0:	c91ff06f          	j	480 <vprintfmt.constprop.0+0xb4>
     7f4:	00800c13          	li	s8,8
     7f8:	00000d93          	li	s11,0
     7fc:	0000d737          	lui	a4,0xd
     800:	0000d3b7          	lui	t2,0xd
     804:	00100b93          	li	s7,1
     808:	1ac72a83          	lw	s5,428(a4) # d1ac <uart_stat_reg>
     80c:	1b03aa03          	lw	s4,432(t2) # d1b0 <uart_tx_fifo>
     810:	06bbda63          	bge	s7,a1,884 <vprintfmt.constprop.0+0x4b8>
     814:	00412983          	lw	s3,4(sp)
     818:	000c0613          	mv	a2,s8
     81c:	00000693          	li	a3,0
     820:	00798e13          	addi	t3,s3,7
     824:	ff8e7e93          	andi	t4,t3,-8
     828:	000eab83          	lw	s7,0(t4)
     82c:	004ea983          	lw	s3,4(t4)
     830:	008e8f13          	addi	t5,t4,8
     834:	000b8513          	mv	a0,s7
     838:	00098593          	mv	a1,s3
     83c:	01e12223          	sw	t5,4(sp)
     840:	761050ef          	jal	ra,67a0 <__umoddi3>
     844:	00a12823          	sw	a0,16(sp)
     848:	e13d9ae3          	bne	s11,s3,65c <vprintfmt.constprop.0+0x290>
     84c:	e18bf8e3          	bgeu	s7,s8,65c <vprintfmt.constprop.0+0x290>
     850:	00000f93          	li	t6,0
     854:	00100493          	li	s1,1
     858:	e4dff06f          	j	6a4 <vprintfmt.constprop.0+0x2d8>
     85c:	04100f13          	li	t5,65
     860:	0000d737          	lui	a4,0xd
     864:	0000d3b7          	lui	t2,0xd
     868:	01e12623          	sw	t5,12(sp)
     86c:	00100b93          	li	s7,1
     870:	1ac72a83          	lw	s5,428(a4) # d1ac <uart_stat_reg>
     874:	1b03aa03          	lw	s4,432(t2) # d1b0 <uart_tx_fifo>
     878:	01000c13          	li	s8,16
     87c:	00000d93          	li	s11,0
     880:	f8bbcae3          	blt	s7,a1,814 <vprintfmt.constprop.0+0x448>
     884:	00412583          	lw	a1,4(sp)
     888:	00458813          	addi	a6,a1,4
     88c:	0540006f          	j	8e0 <vprintfmt.constprop.0+0x514>
     890:	0000dc37          	lui	s8,0xd
     894:	1acc2a83          	lw	s5,428(s8) # d1ac <uart_stat_reg>
     898:	000aad83          	lw	s11,0(s5)
     89c:	008dfe13          	andi	t3,s11,8
     8a0:	fe0e1ce3          	bnez	t3,898 <vprintfmt.constprop.0+0x4cc>
     8a4:	0000deb7          	lui	t4,0xd
     8a8:	1b0eaa03          	lw	s4,432(t4) # d1b0 <uart_tx_fifo>
     8ac:	03000f13          	li	t5,48
     8b0:	01ea2023          	sw	t5,0(s4)
     8b4:	000aaf83          	lw	t6,0(s5)
     8b8:	008ff793          	andi	a5,t6,8
     8bc:	fe079ce3          	bnez	a5,8b4 <vprintfmt.constprop.0+0x4e8>
     8c0:	00412503          	lw	a0,4(sp)
     8c4:	07800093          	li	ra,120
     8c8:	06100693          	li	a3,97
     8cc:	001a2023          	sw	ra,0(s4)
     8d0:	01000c13          	li	s8,16
     8d4:	00000d93          	li	s11,0
     8d8:	00d12623          	sw	a3,12(sp)
     8dc:	00450813          	addi	a6,a0,4
     8e0:	00412883          	lw	a7,4(sp)
     8e4:	00000993          	li	s3,0
     8e8:	0008ab83          	lw	s7,0(a7)
     8ec:	01012223          	sw	a6,4(sp)
     8f0:	d51ff06f          	j	640 <vprintfmt.constprop.0+0x274>
     8f4:	00412583          	lw	a1,4(sp)
     8f8:	0005aa03          	lw	s4,0(a1)
     8fc:	1a0a0863          	beqz	s4,aac <vprintfmt.constprop.0+0x6e0>
     900:	19a05863          	blez	s10,a90 <vprintfmt.constprop.0+0x6c4>
     904:	02d00713          	li	a4,45
     908:	12ec9a63          	bne	s9,a4,a3c <vprintfmt.constprop.0+0x670>
     90c:	000a4f03          	lbu	t5,0(s4)
     910:	0000d937          	lui	s2,0xd
     914:	0000d9b7          	lui	s3,0xd
     918:	1ac92d83          	lw	s11,428(s2) # d1ac <uart_stat_reg>
     91c:	1b09ae03          	lw	t3,432(s3) # d1b0 <uart_tx_fifo>
     920:	040f0263          	beqz	t5,964 <vprintfmt.constprop.0+0x598>
     924:	fff00613          	li	a2,-1
     928:	00a00393          	li	t2,10
     92c:	00d00493          	li	s1,13
     930:	000bc663          	bltz	s7,93c <vprintfmt.constprop.0+0x570>
     934:	fffb8b93          	addi	s7,s7,-1
     938:	02cb8463          	beq	s7,a2,960 <vprintfmt.constprop.0+0x594>
     93c:	000da803          	lw	a6,0(s11)
     940:	00887893          	andi	a7,a6,8
     944:	fe089ce3          	bnez	a7,93c <vprintfmt.constprop.0+0x570>
     948:	01ee2023          	sw	t5,0(t3)
     94c:	0c7f0a63          	beq	t5,t2,a20 <vprintfmt.constprop.0+0x654>
     950:	001a4f03          	lbu	t5,1(s4)
     954:	fffd0d13          	addi	s10,s10,-1
     958:	001a0a13          	addi	s4,s4,1
     95c:	fc0f1ae3          	bnez	t5,930 <vprintfmt.constprop.0+0x564>
     960:	c7a05ee3          	blez	s10,5dc <vprintfmt.constprop.0+0x210>
     964:	02000913          	li	s2,32
     968:	000da983          	lw	s3,0(s11)
     96c:	0089fa93          	andi	s5,s3,8
     970:	fe0a9ce3          	bnez	s5,968 <vprintfmt.constprop.0+0x59c>
     974:	012e2023          	sw	s2,0(t3)
     978:	fffd0d13          	addi	s10,s10,-1
     97c:	fe0d16e3          	bnez	s10,968 <vprintfmt.constprop.0+0x59c>
     980:	c5dff06f          	j	5dc <vprintfmt.constprop.0+0x210>
     984:	00174a03          	lbu	s4,1(a4)
     988:	000b0713          	mv	a4,s6
     98c:	af5ff06f          	j	480 <vprintfmt.constprop.0+0xb4>
     990:	0000d4b7          	lui	s1,0xd
     994:	1ac4a083          	lw	ra,428(s1) # d1ac <uart_stat_reg>
     998:	0000ad03          	lw	s10,0(ra)
     99c:	008d7693          	andi	a3,s10,8
     9a0:	fe069ce3          	bnez	a3,998 <vprintfmt.constprop.0+0x5cc>
     9a4:	0000dcb7          	lui	s9,0xd
     9a8:	1b0ca283          	lw	t0,432(s9) # d1b0 <uart_tx_fifo>
     9ac:	02500c13          	li	s8,37
     9b0:	0182a023          	sw	s8,0(t0)
     9b4:	a71ff06f          	j	424 <vprintfmt.constprop.0+0x58>
     9b8:	00412603          	lw	a2,4(sp)
     9bc:	00174a03          	lbu	s4,1(a4)
     9c0:	000b0713          	mv	a4,s6
     9c4:	00460913          	addi	s2,a2,4
     9c8:	00062b83          	lw	s7,0(a2)
     9cc:	01212223          	sw	s2,4(sp)
     9d0:	bc5ff06f          	j	594 <vprintfmt.constprop.0+0x1c8>
     9d4:	fffd4a13          	not	s4,s10
     9d8:	41fa5613          	srai	a2,s4,0x1f
     9dc:	00cd7d33          	and	s10,s10,a2
     9e0:	00174a03          	lbu	s4,1(a4)
     9e4:	000b0713          	mv	a4,s6
     9e8:	a99ff06f          	j	480 <vprintfmt.constprop.0+0xb4>
     9ec:	06100513          	li	a0,97
     9f0:	01000c13          	li	s8,16
     9f4:	00000d93          	li	s11,0
     9f8:	00a12623          	sw	a0,12(sp)
     9fc:	e01ff06f          	j	7fc <vprintfmt.constprop.0+0x430>
     a00:	00412e83          	lw	t4,4(sp)
     a04:	007e8f13          	addi	t5,t4,7
     a08:	ff8f7f93          	andi	t6,t5,-8
     a0c:	008f8793          	addi	a5,t6,8
     a10:	000fab83          	lw	s7,0(t6)
     a14:	004fae03          	lw	t3,4(t6)
     a18:	00f12223          	sw	a5,4(sp)
     a1c:	c05ff06f          	j	620 <vprintfmt.constprop.0+0x254>
     a20:	000da583          	lw	a1,0(s11)
     a24:	0085f713          	andi	a4,a1,8
     a28:	fe071ce3          	bnez	a4,a20 <vprintfmt.constprop.0+0x654>
     a2c:	009e2023          	sw	s1,0(t3)
     a30:	f21ff06f          	j	950 <vprintfmt.constprop.0+0x584>
     a34:	0000dfb7          	lui	t6,0xd
     a38:	a78f8a13          	addi	s4,t6,-1416 # ca78 <errpat+0xb4>
     a3c:	000b8593          	mv	a1,s7
     a40:	000a0513          	mv	a0,s4
     a44:	3c4050ef          	jal	ra,5e08 <strnlen>
     a48:	40ad0d33          	sub	s10,s10,a0
     a4c:	05a05263          	blez	s10,a90 <vprintfmt.constprop.0+0x6c4>
     a50:	0000d6b7          	lui	a3,0xd
     a54:	0000d537          	lui	a0,0xd
     a58:	1ac6ad83          	lw	s11,428(a3) # d1ac <uart_stat_reg>
     a5c:	1b052e03          	lw	t3,432(a0) # d1b0 <uart_tx_fifo>
     a60:	000da283          	lw	t0,0(s11)
     a64:	0082f313          	andi	t1,t0,8
     a68:	fe031ce3          	bnez	t1,a60 <vprintfmt.constprop.0+0x694>
     a6c:	019e2023          	sw	s9,0(t3)
     a70:	fffd0d13          	addi	s10,s10,-1
     a74:	fe0d16e3          	bnez	s10,a60 <vprintfmt.constprop.0+0x694>
     a78:	000a4f03          	lbu	t5,0(s4)
     a7c:	ea0f14e3          	bnez	t5,924 <vprintfmt.constprop.0+0x558>
     a80:	b5dff06f          	j	5dc <vprintfmt.constprop.0+0x210>
     a84:	00a00c13          	li	s8,10
     a88:	00000d93          	li	s11,0
     a8c:	d71ff06f          	j	7fc <vprintfmt.constprop.0+0x430>
     a90:	000a4f03          	lbu	t5,0(s4)
     a94:	b40f04e3          	beqz	t5,5dc <vprintfmt.constprop.0+0x210>
     a98:	0000d7b7          	lui	a5,0xd
     a9c:	0000d0b7          	lui	ra,0xd
     aa0:	1ac7ad83          	lw	s11,428(a5) # d1ac <uart_stat_reg>
     aa4:	1b00ae03          	lw	t3,432(ra) # d1b0 <uart_tx_fifo>
     aa8:	e7dff06f          	j	924 <vprintfmt.constprop.0+0x558>
     aac:	01a05663          	blez	s10,ab8 <vprintfmt.constprop.0+0x6ec>
     ab0:	02d00a93          	li	s5,45
     ab4:	f95c90e3          	bne	s9,s5,a34 <vprintfmt.constprop.0+0x668>
     ab8:	0000dc37          	lui	s8,0xd
     abc:	0000dcb7          	lui	s9,0xd
     ac0:	0000deb7          	lui	t4,0xd
     ac4:	1acc2d83          	lw	s11,428(s8) # d1ac <uart_stat_reg>
     ac8:	1b0cae03          	lw	t3,432(s9) # d1b0 <uart_tx_fifo>
     acc:	a78e8a13          	addi	s4,t4,-1416 # ca78 <errpat+0xb4>
     ad0:	02800f13          	li	t5,40
     ad4:	e51ff06f          	j	924 <vprintfmt.constprop.0+0x558>
     ad8:	000b0713          	mv	a4,s6
     adc:	ab9ff06f          	j	594 <vprintfmt.constprop.0+0x1c8>

00000ae0 <cmp_idx>:
     ae0:	00060a63          	beqz	a2,af4 <cmp_idx+0x14>
     ae4:	00251503          	lh	a0,2(a0)
     ae8:	00259583          	lh	a1,2(a1)
     aec:	40b50533          	sub	a0,a0,a1
     af0:	00008067          	ret
     af4:	00051783          	lh	a5,0(a0)
     af8:	01079713          	slli	a4,a5,0x10
     afc:	01075293          	srli	t0,a4,0x10
     b00:	f007f313          	andi	t1,a5,-256
     b04:	0082d393          	srli	t2,t0,0x8
     b08:	00736633          	or	a2,t1,t2
     b0c:	00c51023          	sh	a2,0(a0)
     b10:	00059683          	lh	a3,0(a1)
     b14:	00251503          	lh	a0,2(a0)
     b18:	01069813          	slli	a6,a3,0x10
     b1c:	01085893          	srli	a7,a6,0x10
     b20:	f006fe13          	andi	t3,a3,-256
     b24:	0088de93          	srli	t4,a7,0x8
     b28:	01de6f33          	or	t5,t3,t4
     b2c:	01e59023          	sh	t5,0(a1)
     b30:	00259583          	lh	a1,2(a1)
     b34:	40b50533          	sub	a0,a0,a1
     b38:	00008067          	ret

00000b3c <calc_func>:
     b3c:	fe010113          	addi	sp,sp,-32
     b40:	00812c23          	sw	s0,24(sp)
     b44:	00051403          	lh	s0,0(a0)
     b48:	00112e23          	sw	ra,28(sp)
     b4c:	00912a23          	sw	s1,20(sp)
     b50:	40745793          	srai	a5,s0,0x7
     b54:	01212823          	sw	s2,16(sp)
     b58:	01312623          	sw	s3,12(sp)
     b5c:	0017f093          	andi	ra,a5,1
     b60:	02008263          	beqz	ra,b84 <calc_func+0x48>
     b64:	01c12083          	lw	ra,28(sp)
     b68:	07f47513          	andi	a0,s0,127
     b6c:	01812403          	lw	s0,24(sp)
     b70:	01412483          	lw	s1,20(sp)
     b74:	01012903          	lw	s2,16(sp)
     b78:	00c12983          	lw	s3,12(sp)
     b7c:	02010113          	addi	sp,sp,32
     b80:	00008067          	ret
     b84:	40345713          	srai	a4,s0,0x3
     b88:	00f77293          	andi	t0,a4,15
     b8c:	00058493          	mv	s1,a1
     b90:	00747693          	andi	a3,s0,7
     b94:	00429593          	slli	a1,t0,0x4
     b98:	0384d783          	lhu	a5,56(s1)
     b9c:	00050993          	mv	s3,a0
     ba0:	0055e5b3          	or	a1,a1,t0
     ba4:	04068c63          	beqz	a3,bfc <calc_func+0xc0>
     ba8:	00100513          	li	a0,1
     bac:	08a68a63          	beq	a3,a0,c40 <calc_func+0x104>
     bb0:	01041893          	slli	a7,s0,0x10
     bb4:	0108d513          	srli	a0,a7,0x10
     bb8:	00040913          	mv	s2,s0
     bbc:	00078593          	mv	a1,a5
     bc0:	029040ef          	jal	ra,53e8 <crcu16>
     bc4:	00050e13          	mv	t3,a0
     bc8:	f0047e93          	andi	t4,s0,-256
     bcc:	07f97513          	andi	a0,s2,127
     bd0:	01c12083          	lw	ra,28(sp)
     bd4:	01812403          	lw	s0,24(sp)
     bd8:	01d56f33          	or	t5,a0,t4
     bdc:	03c49c23          	sh	t3,56(s1)
     be0:	080f6f93          	ori	t6,t5,128
     be4:	01f99023          	sh	t6,0(s3)
     be8:	01412483          	lw	s1,20(sp)
     bec:	01012903          	lw	s2,16(sp)
     bf0:	00c12983          	lw	s3,12(sp)
     bf4:	02010113          	addi	sp,sp,32
     bf8:	00008067          	ret
     bfc:	02200313          	li	t1,34
     c00:	00058393          	mv	t2,a1
     c04:	0065d463          	bge	a1,t1,c0c <calc_func+0xd0>
     c08:	02200393          	li	t2,34
     c0c:	00049603          	lh	a2,0(s1)
     c10:	00249683          	lh	a3,2(s1)
     c14:	0144a583          	lw	a1,20(s1)
     c18:	0184a503          	lw	a0,24(s1)
     c1c:	0ff3f713          	zext.b	a4,t2
     c20:	529020ef          	jal	ra,3948 <core_bench_state>
     c24:	03e4d603          	lhu	a2,62(s1)
     c28:	00061463          	bnez	a2,c30 <calc_func+0xf4>
     c2c:	02a49f23          	sh	a0,62(s1)
     c30:	01051913          	slli	s2,a0,0x10
     c34:	0384d783          	lhu	a5,56(s1)
     c38:	41095913          	srai	s2,s2,0x10
     c3c:	f81ff06f          	j	bbc <calc_func+0x80>
     c40:	00078613          	mv	a2,a5
     c44:	02848513          	addi	a0,s1,40
     c48:	514020ef          	jal	ra,315c <core_bench_matrix>
     c4c:	03c4d803          	lhu	a6,60(s1)
     c50:	fe0810e3          	bnez	a6,c30 <calc_func+0xf4>
     c54:	02a49e23          	sh	a0,60(s1)
     c58:	fd9ff06f          	j	c30 <calc_func+0xf4>

00000c5c <cmp_complex>:
     c5c:	ff010113          	addi	sp,sp,-16
     c60:	00912223          	sw	s1,4(sp)
     c64:	00058493          	mv	s1,a1
     c68:	00060593          	mv	a1,a2
     c6c:	00112623          	sw	ra,12(sp)
     c70:	00812423          	sw	s0,8(sp)
     c74:	00060413          	mv	s0,a2
     c78:	ec5ff0ef          	jal	ra,b3c <calc_func>
     c7c:	00050793          	mv	a5,a0
     c80:	00040593          	mv	a1,s0
     c84:	00048513          	mv	a0,s1
     c88:	00078413          	mv	s0,a5
     c8c:	eb1ff0ef          	jal	ra,b3c <calc_func>
     c90:	00c12083          	lw	ra,12(sp)
     c94:	40a40533          	sub	a0,s0,a0
     c98:	00812403          	lw	s0,8(sp)
     c9c:	00412483          	lw	s1,4(sp)
     ca0:	01010113          	addi	sp,sp,16
     ca4:	00008067          	ret

00000ca8 <copy_info>:
     ca8:	00059703          	lh	a4,0(a1)
     cac:	00259783          	lh	a5,2(a1)
     cb0:	00e51023          	sh	a4,0(a0)
     cb4:	00f51123          	sh	a5,2(a0)
     cb8:	00008067          	ret

00000cbc <core_list_insert_new>:
     cbc:	00062803          	lw	a6,0(a2)
     cc0:	00880893          	addi	a7,a6,8
     cc4:	04e8f663          	bgeu	a7,a4,d10 <core_list_insert_new+0x54>
     cc8:	0006a703          	lw	a4,0(a3)
     ccc:	00470313          	addi	t1,a4,4
     cd0:	04f37063          	bgeu	t1,a5,d10 <core_list_insert_new+0x54>
     cd4:	01162023          	sw	a7,0(a2)
     cd8:	00052783          	lw	a5,0(a0)
     cdc:	00059283          	lh	t0,0(a1)
     ce0:	00259603          	lh	a2,2(a1)
     ce4:	00f82023          	sw	a5,0(a6)
     ce8:	01052023          	sw	a6,0(a0)
     cec:	00e82223          	sw	a4,4(a6)
     cf0:	0006a383          	lw	t2,0(a3)
     cf4:	00438513          	addi	a0,t2,4
     cf8:	00a6a023          	sw	a0,0(a3)
     cfc:	00482583          	lw	a1,4(a6)
     d00:	00080513          	mv	a0,a6
     d04:	00559023          	sh	t0,0(a1)
     d08:	00c59123          	sh	a2,2(a1)
     d0c:	00008067          	ret
     d10:	00000813          	li	a6,0
     d14:	00080513          	mv	a0,a6
     d18:	00008067          	ret

00000d1c <core_list_remove>:
     d1c:	00050793          	mv	a5,a0
     d20:	00052503          	lw	a0,0(a0)
     d24:	0047a683          	lw	a3,4(a5)
     d28:	00452603          	lw	a2,4(a0)
     d2c:	00052703          	lw	a4,0(a0)
     d30:	00c7a223          	sw	a2,4(a5)
     d34:	00d52223          	sw	a3,4(a0)
     d38:	00e7a023          	sw	a4,0(a5)
     d3c:	00052023          	sw	zero,0(a0)
     d40:	00008067          	ret

00000d44 <core_list_undo_remove>:
     d44:	0045a603          	lw	a2,4(a1)
     d48:	00452683          	lw	a3,4(a0)
     d4c:	0005a703          	lw	a4,0(a1)
     d50:	00c52223          	sw	a2,4(a0)
     d54:	00d5a223          	sw	a3,4(a1)
     d58:	00e52023          	sw	a4,0(a0)
     d5c:	00a5a023          	sw	a0,0(a1)
     d60:	00008067          	ret

00000d64 <core_list_find>:
     d64:	00259603          	lh	a2,2(a1)
     d68:	02064263          	bltz	a2,d8c <core_list_find+0x28>
     d6c:	00051863          	bnez	a0,d7c <core_list_find+0x18>
     d70:	0480006f          	j	db8 <core_list_find+0x54>
     d74:	00052503          	lw	a0,0(a0)
     d78:	02050c63          	beqz	a0,db0 <core_list_find+0x4c>
     d7c:	00452303          	lw	t1,4(a0)
     d80:	00231383          	lh	t2,2(t1)
     d84:	fec398e3          	bne	t2,a2,d74 <core_list_find+0x10>
     d88:	00008067          	ret
     d8c:	02050263          	beqz	a0,db0 <core_list_find+0x4c>
     d90:	00059703          	lh	a4,0(a1)
     d94:	00c0006f          	j	da0 <core_list_find+0x3c>
     d98:	00052503          	lw	a0,0(a0)
     d9c:	00050c63          	beqz	a0,db4 <core_list_find+0x50>
     da0:	00452783          	lw	a5,4(a0)
     da4:	0007c283          	lbu	t0,0(a5)
     da8:	fee298e3          	bne	t0,a4,d98 <core_list_find+0x34>
     dac:	00008067          	ret
     db0:	00000513          	li	a0,0
     db4:	00008067          	ret
     db8:	00008067          	ret

00000dbc <core_list_reverse>:
     dbc:	02050063          	beqz	a0,ddc <core_list_reverse+0x20>
     dc0:	00000713          	li	a4,0
     dc4:	0080006f          	j	dcc <core_list_reverse+0x10>
     dc8:	00078513          	mv	a0,a5
     dcc:	00052783          	lw	a5,0(a0)
     dd0:	00e52023          	sw	a4,0(a0)
     dd4:	00050713          	mv	a4,a0
     dd8:	fe0798e3          	bnez	a5,dc8 <core_list_reverse+0xc>
     ddc:	00008067          	ret

00000de0 <core_list_mergesort>:
     de0:	fd010113          	addi	sp,sp,-48
     de4:	01312e23          	sw	s3,28(sp)
     de8:	01612823          	sw	s6,16(sp)
     dec:	01712623          	sw	s7,12(sp)
     df0:	01812423          	sw	s8,8(sp)
     df4:	01a12023          	sw	s10,0(sp)
     df8:	02112623          	sw	ra,44(sp)
     dfc:	02812423          	sw	s0,40(sp)
     e00:	02912223          	sw	s1,36(sp)
     e04:	03212023          	sw	s2,32(sp)
     e08:	01412c23          	sw	s4,24(sp)
     e0c:	01512a23          	sw	s5,20(sp)
     e10:	01912223          	sw	s9,4(sp)
     e14:	00050993          	mv	s3,a0
     e18:	00058b93          	mv	s7,a1
     e1c:	00060b13          	mv	s6,a2
     e20:	00100c13          	li	s8,1
     e24:	00100d13          	li	s10,1
     e28:	1a098463          	beqz	s3,fd0 <core_list_mergesort+0x1f0>
     e2c:	00000c93          	li	s9,0
     e30:	00000493          	li	s1,0
     e34:	00000a93          	li	s5,0
     e38:	007c7713          	andi	a4,s8,7
     e3c:	001c8c93          	addi	s9,s9,1
     e40:	00098793          	mv	a5,s3
     e44:	00000413          	li	s0,0
     e48:	08070663          	beqz	a4,ed4 <core_list_mergesort+0xf4>
     e4c:	00100693          	li	a3,1
     e50:	06d70a63          	beq	a4,a3,ec4 <core_list_mergesort+0xe4>
     e54:	00200093          	li	ra,2
     e58:	06170063          	beq	a4,ra,eb8 <core_list_mergesort+0xd8>
     e5c:	00300293          	li	t0,3
     e60:	04570663          	beq	a4,t0,eac <core_list_mergesort+0xcc>
     e64:	00400313          	li	t1,4
     e68:	02670c63          	beq	a4,t1,ea0 <core_list_mergesort+0xc0>
     e6c:	00500393          	li	t2,5
     e70:	02770263          	beq	a4,t2,e94 <core_list_mergesort+0xb4>
     e74:	00600513          	li	a0,6
     e78:	00a70863          	beq	a4,a0,e88 <core_list_mergesort+0xa8>
     e7c:	0009a783          	lw	a5,0(s3)
     e80:	00100413          	li	s0,1
     e84:	0a078a63          	beqz	a5,f38 <core_list_mergesort+0x158>
     e88:	0007a783          	lw	a5,0(a5)
     e8c:	00140413          	addi	s0,s0,1
     e90:	0a078463          	beqz	a5,f38 <core_list_mergesort+0x158>
     e94:	0007a783          	lw	a5,0(a5)
     e98:	00140413          	addi	s0,s0,1
     e9c:	08078e63          	beqz	a5,f38 <core_list_mergesort+0x158>
     ea0:	0007a783          	lw	a5,0(a5)
     ea4:	00140413          	addi	s0,s0,1
     ea8:	08078863          	beqz	a5,f38 <core_list_mergesort+0x158>
     eac:	0007a783          	lw	a5,0(a5)
     eb0:	00140413          	addi	s0,s0,1
     eb4:	08078263          	beqz	a5,f38 <core_list_mergesort+0x158>
     eb8:	0007a783          	lw	a5,0(a5)
     ebc:	00140413          	addi	s0,s0,1
     ec0:	06078c63          	beqz	a5,f38 <core_list_mergesort+0x158>
     ec4:	0007a783          	lw	a5,0(a5)
     ec8:	00140413          	addi	s0,s0,1
     ecc:	06078663          	beqz	a5,f38 <core_list_mergesort+0x158>
     ed0:	068c0463          	beq	s8,s0,f38 <core_list_mergesort+0x158>
     ed4:	0007a783          	lw	a5,0(a5)
     ed8:	00140413          	addi	s0,s0,1
     edc:	00040593          	mv	a1,s0
     ee0:	04078c63          	beqz	a5,f38 <core_list_mergesort+0x158>
     ee4:	0007a783          	lw	a5,0(a5)
     ee8:	00140413          	addi	s0,s0,1
     eec:	04078663          	beqz	a5,f38 <core_list_mergesort+0x158>
     ef0:	0007a783          	lw	a5,0(a5)
     ef4:	00258413          	addi	s0,a1,2
     ef8:	04078063          	beqz	a5,f38 <core_list_mergesort+0x158>
     efc:	0007a783          	lw	a5,0(a5)
     f00:	00358413          	addi	s0,a1,3
     f04:	02078a63          	beqz	a5,f38 <core_list_mergesort+0x158>
     f08:	0007a783          	lw	a5,0(a5)
     f0c:	00458413          	addi	s0,a1,4
     f10:	02078463          	beqz	a5,f38 <core_list_mergesort+0x158>
     f14:	0007a783          	lw	a5,0(a5)
     f18:	00558413          	addi	s0,a1,5
     f1c:	00078e63          	beqz	a5,f38 <core_list_mergesort+0x158>
     f20:	0007a783          	lw	a5,0(a5)
     f24:	00658413          	addi	s0,a1,6
     f28:	00078863          	beqz	a5,f38 <core_list_mergesort+0x158>
     f2c:	0007a783          	lw	a5,0(a5)
     f30:	00758413          	addi	s0,a1,7
     f34:	f8079ee3          	bnez	a5,ed0 <core_list_mergesort+0xf0>
     f38:	00098913          	mv	s2,s3
     f3c:	000c0a13          	mv	s4,s8
     f40:	00078993          	mv	s3,a5
     f44:	02805263          	blez	s0,f68 <core_list_mergesort+0x188>
     f48:	040a1463          	bnez	s4,f90 <core_list_mergesort+0x1b0>
     f4c:	00090613          	mv	a2,s2
     f50:	00092903          	lw	s2,0(s2)
     f54:	fff40413          	addi	s0,s0,-1
     f58:	02048663          	beqz	s1,f84 <core_list_mergesort+0x1a4>
     f5c:	00c4a023          	sw	a2,0(s1)
     f60:	00060493          	mv	s1,a2
     f64:	fe8042e3          	bgtz	s0,f48 <core_list_mergesort+0x168>
     f68:	05405863          	blez	s4,fb8 <core_list_mergesort+0x1d8>
     f6c:	04098863          	beqz	s3,fbc <core_list_mergesort+0x1dc>
     f70:	02041263          	bnez	s0,f94 <core_list_mergesort+0x1b4>
     f74:	00098613          	mv	a2,s3
     f78:	fffa0a13          	addi	s4,s4,-1
     f7c:	0009a983          	lw	s3,0(s3)
     f80:	fc049ee3          	bnez	s1,f5c <core_list_mergesort+0x17c>
     f84:	00060a93          	mv	s5,a2
     f88:	00060493          	mv	s1,a2
     f8c:	fd9ff06f          	j	f64 <core_list_mergesort+0x184>
     f90:	fa098ee3          	beqz	s3,f4c <core_list_mergesort+0x16c>
     f94:	0049a583          	lw	a1,4(s3)
     f98:	00492503          	lw	a0,4(s2)
     f9c:	000b0613          	mv	a2,s6
     fa0:	000b80e7          	jalr	s7
     fa4:	faa054e3          	blez	a0,f4c <core_list_mergesort+0x16c>
     fa8:	00098613          	mv	a2,s3
     fac:	fffa0a13          	addi	s4,s4,-1
     fb0:	0009a983          	lw	s3,0(s3)
     fb4:	fa5ff06f          	j	f58 <core_list_mergesort+0x178>
     fb8:	e80990e3          	bnez	s3,e38 <core_list_mergesort+0x58>
     fbc:	0004a023          	sw	zero,0(s1)
     fc0:	01ac8c63          	beq	s9,s10,fd8 <core_list_mergesort+0x1f8>
     fc4:	000a8993          	mv	s3,s5
     fc8:	001c1c13          	slli	s8,s8,0x1
     fcc:	e60990e3          	bnez	s3,e2c <core_list_mergesort+0x4c>
     fd0:	00002023          	sw	zero,0(zero) # 0 <_start>
     fd4:	00100073          	ebreak
     fd8:	02c12083          	lw	ra,44(sp)
     fdc:	02812403          	lw	s0,40(sp)
     fe0:	02412483          	lw	s1,36(sp)
     fe4:	02012903          	lw	s2,32(sp)
     fe8:	01c12983          	lw	s3,28(sp)
     fec:	01812a03          	lw	s4,24(sp)
     ff0:	01012b03          	lw	s6,16(sp)
     ff4:	00c12b83          	lw	s7,12(sp)
     ff8:	00812c03          	lw	s8,8(sp)
     ffc:	00412c83          	lw	s9,4(sp)
    1000:	00012d03          	lw	s10,0(sp)
    1004:	000a8513          	mv	a0,s5
    1008:	01412a83          	lw	s5,20(sp)
    100c:	03010113          	addi	sp,sp,48
    1010:	00008067          	ret

00001014 <core_bench_list>:
    1014:	00050613          	mv	a2,a0
    1018:	00451503          	lh	a0,4(a0)
    101c:	fe010113          	addi	sp,sp,-32
    1020:	00812c23          	sw	s0,24(sp)
    1024:	00112e23          	sw	ra,28(sp)
    1028:	00912a23          	sw	s1,20(sp)
    102c:	01212823          	sw	s2,16(sp)
    1030:	01312623          	sw	s3,12(sp)
    1034:	01412423          	sw	s4,8(sp)
    1038:	01512223          	sw	s5,4(sp)
    103c:	02462403          	lw	s0,36(a2)
    1040:	26a05663          	blez	a0,12ac <core_bench_list+0x298>
    1044:	00058493          	mv	s1,a1
    1048:	00000313          	li	t1,0
    104c:	00000e93          	li	t4,0
    1050:	00000e13          	li	t3,0
    1054:	00000893          	li	a7,0
    1058:	0ff37a13          	zext.b	s4,t1
    105c:	1c04ce63          	bltz	s1,1238 <core_bench_list+0x224>
    1060:	24040e63          	beqz	s0,12bc <core_bench_list+0x2a8>
    1064:	00040793          	mv	a5,s0
    1068:	00c0006f          	j	1074 <core_bench_list+0x60>
    106c:	0007a783          	lw	a5,0(a5)
    1070:	00078863          	beqz	a5,1080 <core_bench_list+0x6c>
    1074:	0047a283          	lw	t0,4(a5)
    1078:	00229383          	lh	t2,2(t0)
    107c:	fe9398e3          	bne	t2,s1,106c <core_bench_list+0x58>
    1080:	00000913          	li	s2,0
    1084:	0080006f          	j	108c <core_bench_list+0x78>
    1088:	00068413          	mv	s0,a3
    108c:	00042683          	lw	a3,0(s0)
    1090:	01242023          	sw	s2,0(s0)
    1094:	00090713          	mv	a4,s2
    1098:	00040913          	mv	s2,s0
    109c:	fe0696e3          	bnez	a3,1088 <core_bench_list+0x74>
    10a0:	1a078e63          	beqz	a5,125c <core_bench_list+0x248>
    10a4:	0047a803          	lw	a6,4(a5)
    10a8:	00081983          	lh	s3,0(a6)
    10ac:	0019fa93          	andi	s5,s3,1
    10b0:	000a8c63          	beqz	s5,10c8 <core_bench_list+0xb4>
    10b4:	4099df13          	srai	t5,s3,0x9
    10b8:	001f7f93          	andi	t6,t5,1
    10bc:	01f888b3          	add	a7,a7,t6
    10c0:	01089093          	slli	ra,a7,0x10
    10c4:	0100d893          	srli	a7,ra,0x10
    10c8:	0007a283          	lw	t0,0(a5)
    10cc:	00028c63          	beqz	t0,10e4 <core_bench_list+0xd0>
    10d0:	0002a383          	lw	t2,0(t0)
    10d4:	0077a023          	sw	t2,0(a5)
    10d8:	00042783          	lw	a5,0(s0)
    10dc:	00f2a023          	sw	a5,0(t0)
    10e0:	00542023          	sw	t0,0(s0)
    10e4:	001e0e13          	addi	t3,t3,1
    10e8:	010e1913          	slli	s2,t3,0x10
    10ec:	01095e13          	srli	t3,s2,0x10
    10f0:	0004c863          	bltz	s1,1100 <core_bench_list+0xec>
    10f4:	00148493          	addi	s1,s1,1
    10f8:	01049f93          	slli	t6,s1,0x10
    10fc:	410fd493          	srai	s1,t6,0x10
    1100:	00130313          	addi	t1,t1,1
    1104:	01031093          	slli	ra,t1,0x10
    1108:	4100d313          	srai	t1,ra,0x10
    110c:	f46516e3          	bne	a0,t1,1058 <core_bench_list+0x44>
    1110:	002e1513          	slli	a0,t3,0x2
    1114:	41d502b3          	sub	t0,a0,t4
    1118:	005888b3          	add	a7,a7,t0
    111c:	01089393          	slli	t2,a7,0x10
    1120:	0103d913          	srli	s2,t2,0x10
    1124:	00b05c63          	blez	a1,113c <core_bench_list+0x128>
    1128:	000015b7          	lui	a1,0x1
    112c:	00040513          	mv	a0,s0
    1130:	c5c58593          	addi	a1,a1,-932 # c5c <cmp_complex>
    1134:	cadff0ef          	jal	ra,de0 <core_list_mergesort>
    1138:	00050413          	mv	s0,a0
    113c:	00042783          	lw	a5,0(s0)
    1140:	00040993          	mv	s3,s0
    1144:	0007aa83          	lw	s5,0(a5)
    1148:	0047a703          	lw	a4,4(a5)
    114c:	004aa603          	lw	a2,4(s5)
    1150:	000aae03          	lw	t3,0(s5)
    1154:	00c7a223          	sw	a2,4(a5)
    1158:	00eaa223          	sw	a4,4(s5)
    115c:	01c7a023          	sw	t3,0(a5)
    1160:	000aa023          	sw	zero,0(s5)
    1164:	0004d863          	bgez	s1,1174 <core_bench_list+0x160>
    1168:	0c00006f          	j	1228 <core_bench_list+0x214>
    116c:	0009a983          	lw	s3,0(s3)
    1170:	10098a63          	beqz	s3,1284 <core_bench_list+0x270>
    1174:	0049aa03          	lw	s4,4(s3)
    1178:	002a1803          	lh	a6,2(s4)
    117c:	fe9818e3          	bne	a6,s1,116c <core_bench_list+0x158>
    1180:	00442f03          	lw	t5,4(s0)
    1184:	00090593          	mv	a1,s2
    1188:	000f1503          	lh	a0,0(t5)
    118c:	1f5040ef          	jal	ra,5b80 <crc16>
    1190:	0009a983          	lw	s3,0(s3)
    1194:	00050913          	mv	s2,a0
    1198:	fe0994e3          	bnez	s3,1180 <core_bench_list+0x16c>
    119c:	00042983          	lw	s3,0(s0)
    11a0:	004aa703          	lw	a4,4(s5)
    11a4:	0049af83          	lw	t6,4(s3)
    11a8:	0009a083          	lw	ra,0(s3)
    11ac:	00001337          	lui	t1,0x1
    11b0:	01faa223          	sw	t6,4(s5)
    11b4:	00e9a223          	sw	a4,4(s3)
    11b8:	001aa023          	sw	ra,0(s5)
    11bc:	0159a023          	sw	s5,0(s3)
    11c0:	00040513          	mv	a0,s0
    11c4:	00000613          	li	a2,0
    11c8:	ae030593          	addi	a1,t1,-1312 # ae0 <cmp_idx>
    11cc:	c15ff0ef          	jal	ra,de0 <core_list_mergesort>
    11d0:	00052403          	lw	s0,0(a0)
    11d4:	00050a93          	mv	s5,a0
    11d8:	02040063          	beqz	s0,11f8 <core_bench_list+0x1e4>
    11dc:	004aa503          	lw	a0,4(s5)
    11e0:	00090593          	mv	a1,s2
    11e4:	00051503          	lh	a0,0(a0)
    11e8:	199040ef          	jal	ra,5b80 <crc16>
    11ec:	00042403          	lw	s0,0(s0)
    11f0:	00050913          	mv	s2,a0
    11f4:	fe0414e3          	bnez	s0,11dc <core_bench_list+0x1c8>
    11f8:	01c12083          	lw	ra,28(sp)
    11fc:	01812403          	lw	s0,24(sp)
    1200:	01412483          	lw	s1,20(sp)
    1204:	00c12983          	lw	s3,12(sp)
    1208:	00812a03          	lw	s4,8(sp)
    120c:	00412a83          	lw	s5,4(sp)
    1210:	00090513          	mv	a0,s2
    1214:	01012903          	lw	s2,16(sp)
    1218:	02010113          	addi	sp,sp,32
    121c:	00008067          	ret
    1220:	0009a983          	lw	s3,0(s3)
    1224:	06098063          	beqz	s3,1284 <core_bench_list+0x270>
    1228:	0049a683          	lw	a3,4(s3)
    122c:	0006ce83          	lbu	t4,0(a3)
    1230:	ffda18e3          	bne	s4,t4,1220 <core_bench_list+0x20c>
    1234:	f4dff06f          	j	1180 <core_bench_list+0x16c>
    1238:	08040263          	beqz	s0,12bc <core_bench_list+0x2a8>
    123c:	00040793          	mv	a5,s0
    1240:	00c0006f          	j	124c <core_bench_list+0x238>
    1244:	0007a783          	lw	a5,0(a5)
    1248:	e2078ce3          	beqz	a5,1080 <core_bench_list+0x6c>
    124c:	0047a703          	lw	a4,4(a5)
    1250:	00074083          	lbu	ra,0(a4)
    1254:	fe1a18e3          	bne	s4,ra,1244 <core_bench_list+0x230>
    1258:	e29ff06f          	j	1080 <core_bench_list+0x6c>
    125c:	00472683          	lw	a3,4(a4)
    1260:	001e8e93          	addi	t4,t4,1
    1264:	010e9713          	slli	a4,t4,0x10
    1268:	00168803          	lb	a6,1(a3)
    126c:	01075e93          	srli	t4,a4,0x10
    1270:	00187993          	andi	s3,a6,1
    1274:	01388ab3          	add	s5,a7,s3
    1278:	010a9f13          	slli	t5,s5,0x10
    127c:	010f5893          	srli	a7,t5,0x10
    1280:	e71ff06f          	j	10f0 <core_bench_list+0xdc>
    1284:	00042983          	lw	s3,0(s0)
    1288:	f0098ee3          	beqz	s3,11a4 <core_bench_list+0x190>
    128c:	00442f03          	lw	t5,4(s0)
    1290:	00090593          	mv	a1,s2
    1294:	000f1503          	lh	a0,0(t5)
    1298:	0e9040ef          	jal	ra,5b80 <crc16>
    129c:	0009a983          	lw	s3,0(s3)
    12a0:	00050913          	mv	s2,a0
    12a4:	ec099ee3          	bnez	s3,1180 <core_bench_list+0x16c>
    12a8:	ef5ff06f          	j	119c <core_bench_list+0x188>
    12ac:	00000a13          	li	s4,0
    12b0:	00058493          	mv	s1,a1
    12b4:	00000913          	li	s2,0
    12b8:	e6dff06f          	j	1124 <core_bench_list+0x110>
    12bc:	00002783          	lw	a5,0(zero) # 0 <_start>
    12c0:	00100073          	ebreak

000012c4 <core_list_init>:
    12c4:	01400793          	li	a5,20
    12c8:	02f55733          	divu	a4,a0,a5
    12cc:	0005a023          	sw	zero,0(a1)
    12d0:	00058513          	mv	a0,a1
    12d4:	01058793          	addi	a5,a1,16
    12d8:	00858813          	addi	a6,a1,8
    12dc:	ffff86b7          	lui	a3,0xffff8
    12e0:	08068313          	addi	t1,a3,128 # ffff8080 <_stack_top+0xfffd2880>
    12e4:	ffe70593          	addi	a1,a4,-2
    12e8:	00359893          	slli	a7,a1,0x3
    12ec:	011508b3          	add	a7,a0,a7
    12f0:	01152223          	sw	a7,4(a0)
    12f4:	00259e13          	slli	t3,a1,0x2
    12f8:	00089123          	sh	zero,2(a7)
    12fc:	00689023          	sh	t1,0(a7)
    1300:	01c88e33          	add	t3,a7,t3
    1304:	00488293          	addi	t0,a7,4
    1308:	3517fa63          	bgeu	a5,a7,165c <core_list_init+0x398>
    130c:	00888713          	addi	a4,a7,8
    1310:	35c77663          	bgeu	a4,t3,165c <core_list_init+0x398>
    1314:	00052423          	sw	zero,8(a0)
    1318:	01052023          	sw	a6,0(a0)
    131c:	00552623          	sw	t0,12(a0)
    1320:	fff6c393          	not	t2,a3
    1324:	fff00e93          	li	t4,-1
    1328:	01d89223          	sh	t4,4(a7)
    132c:	00789323          	sh	t2,6(a7)
    1330:	28058663          	beqz	a1,15bc <core_list_init+0x2f8>
    1334:	01061f13          	slli	t5,a2,0x10
    1338:	ffff8fb7          	lui	t6,0xffff8
    133c:	0035f313          	andi	t1,a1,3
    1340:	010f5f13          	srli	t5,t5,0x10
    1344:	00000693          	li	a3,0
    1348:	ffffce93          	not	t4,t6
    134c:	10030663          	beqz	t1,1458 <core_list_init+0x194>
    1350:	00100293          	li	t0,1
    1354:	0a530463          	beq	t1,t0,13fc <core_list_init+0x138>
    1358:	00200393          	li	t2,2
    135c:	04730463          	beq	t1,t2,13a4 <core_list_init+0xe0>
    1360:	00878313          	addi	t1,a5,8
    1364:	03137e63          	bgeu	t1,a7,13a0 <core_list_init+0xdc>
    1368:	00470f93          	addi	t6,a4,4
    136c:	03cffa63          	bgeu	t6,t3,13a0 <core_list_init+0xdc>
    1370:	003f1693          	slli	a3,t5,0x3
    1374:	0107a023          	sw	a6,0(a5)
    1378:	0786f293          	andi	t0,a3,120
    137c:	00f52023          	sw	a5,0(a0)
    1380:	00829813          	slli	a6,t0,0x8
    1384:	00e7a223          	sw	a4,4(a5)
    1388:	005863b3          	or	t2,a6,t0
    138c:	00771023          	sh	t2,0(a4)
    1390:	01d71123          	sh	t4,2(a4)
    1394:	00078813          	mv	a6,a5
    1398:	000f8713          	mv	a4,t6
    139c:	00030793          	mv	a5,t1
    13a0:	00100693          	li	a3,1
    13a4:	00878293          	addi	t0,a5,8
    13a8:	0512f863          	bgeu	t0,a7,13f8 <core_list_init+0x134>
    13ac:	00470393          	addi	t2,a4,4
    13b0:	05c3f463          	bgeu	t2,t3,13f8 <core_list_init+0x134>
    13b4:	01069313          	slli	t1,a3,0x10
    13b8:	01035f93          	srli	t6,t1,0x10
    13bc:	01ff4333          	xor	t1,t5,t6
    13c0:	00331313          	slli	t1,t1,0x3
    13c4:	07837313          	andi	t1,t1,120
    13c8:	007fff93          	andi	t6,t6,7
    13cc:	0107a023          	sw	a6,0(a5)
    13d0:	01f36833          	or	a6,t1,t6
    13d4:	00f52023          	sw	a5,0(a0)
    13d8:	00881313          	slli	t1,a6,0x8
    13dc:	00e7a223          	sw	a4,4(a5)
    13e0:	01036fb3          	or	t6,t1,a6
    13e4:	01f71023          	sh	t6,0(a4)
    13e8:	01d71123          	sh	t4,2(a4)
    13ec:	00078813          	mv	a6,a5
    13f0:	00038713          	mv	a4,t2
    13f4:	00028793          	mv	a5,t0
    13f8:	00168693          	addi	a3,a3,1
    13fc:	00878293          	addi	t0,a5,8
    1400:	0512f863          	bgeu	t0,a7,1450 <core_list_init+0x18c>
    1404:	00470393          	addi	t2,a4,4
    1408:	05c3f463          	bgeu	t2,t3,1450 <core_list_init+0x18c>
    140c:	01069313          	slli	t1,a3,0x10
    1410:	01035f93          	srli	t6,t1,0x10
    1414:	01ff4333          	xor	t1,t5,t6
    1418:	00331313          	slli	t1,t1,0x3
    141c:	07837313          	andi	t1,t1,120
    1420:	007fff93          	andi	t6,t6,7
    1424:	0107a023          	sw	a6,0(a5)
    1428:	01f36833          	or	a6,t1,t6
    142c:	00f52023          	sw	a5,0(a0)
    1430:	00881313          	slli	t1,a6,0x8
    1434:	00e7a223          	sw	a4,4(a5)
    1438:	01036fb3          	or	t6,t1,a6
    143c:	01f71023          	sh	t6,0(a4)
    1440:	01d71123          	sh	t4,2(a4)
    1444:	00078813          	mv	a6,a5
    1448:	00038713          	mv	a4,t2
    144c:	00028793          	mv	a5,t0
    1450:	00168693          	addi	a3,a3,1
    1454:	16d58463          	beq	a1,a3,15bc <core_list_init+0x2f8>
    1458:	00878293          	addi	t0,a5,8
    145c:	0512f863          	bgeu	t0,a7,14ac <core_list_init+0x1e8>
    1460:	00470393          	addi	t2,a4,4
    1464:	05c3f463          	bgeu	t2,t3,14ac <core_list_init+0x1e8>
    1468:	01069313          	slli	t1,a3,0x10
    146c:	01035f93          	srli	t6,t1,0x10
    1470:	01ff4333          	xor	t1,t5,t6
    1474:	00331313          	slli	t1,t1,0x3
    1478:	07837313          	andi	t1,t1,120
    147c:	007fff93          	andi	t6,t6,7
    1480:	0107a023          	sw	a6,0(a5)
    1484:	01f36833          	or	a6,t1,t6
    1488:	00f52023          	sw	a5,0(a0)
    148c:	00881313          	slli	t1,a6,0x8
    1490:	00e7a223          	sw	a4,4(a5)
    1494:	01036fb3          	or	t6,t1,a6
    1498:	01f71023          	sh	t6,0(a4)
    149c:	01d71123          	sh	t4,2(a4)
    14a0:	00078813          	mv	a6,a5
    14a4:	00038713          	mv	a4,t2
    14a8:	00028793          	mv	a5,t0
    14ac:	00878293          	addi	t0,a5,8
    14b0:	00168693          	addi	a3,a3,1
    14b4:	0512f863          	bgeu	t0,a7,1504 <core_list_init+0x240>
    14b8:	00470393          	addi	t2,a4,4
    14bc:	05c3f463          	bgeu	t2,t3,1504 <core_list_init+0x240>
    14c0:	01069313          	slli	t1,a3,0x10
    14c4:	01035f93          	srli	t6,t1,0x10
    14c8:	01ff4333          	xor	t1,t5,t6
    14cc:	00331313          	slli	t1,t1,0x3
    14d0:	07837313          	andi	t1,t1,120
    14d4:	007fff93          	andi	t6,t6,7
    14d8:	0107a023          	sw	a6,0(a5)
    14dc:	01f36833          	or	a6,t1,t6
    14e0:	00f52023          	sw	a5,0(a0)
    14e4:	00881313          	slli	t1,a6,0x8
    14e8:	00e7a223          	sw	a4,4(a5)
    14ec:	01036fb3          	or	t6,t1,a6
    14f0:	01f71023          	sh	t6,0(a4)
    14f4:	01d71123          	sh	t4,2(a4)
    14f8:	00078813          	mv	a6,a5
    14fc:	00038713          	mv	a4,t2
    1500:	00028793          	mv	a5,t0
    1504:	00878293          	addi	t0,a5,8
    1508:	00168313          	addi	t1,a3,1
    150c:	0512f863          	bgeu	t0,a7,155c <core_list_init+0x298>
    1510:	00470393          	addi	t2,a4,4
    1514:	05c3f463          	bgeu	t2,t3,155c <core_list_init+0x298>
    1518:	01031f93          	slli	t6,t1,0x10
    151c:	010fdf93          	srli	t6,t6,0x10
    1520:	01ff4333          	xor	t1,t5,t6
    1524:	00331313          	slli	t1,t1,0x3
    1528:	07837313          	andi	t1,t1,120
    152c:	007fff93          	andi	t6,t6,7
    1530:	0107a023          	sw	a6,0(a5)
    1534:	01f36833          	or	a6,t1,t6
    1538:	00f52023          	sw	a5,0(a0)
    153c:	00881313          	slli	t1,a6,0x8
    1540:	00e7a223          	sw	a4,4(a5)
    1544:	01036fb3          	or	t6,t1,a6
    1548:	01f71023          	sh	t6,0(a4)
    154c:	01d71123          	sh	t4,2(a4)
    1550:	00078813          	mv	a6,a5
    1554:	00038713          	mv	a4,t2
    1558:	00028793          	mv	a5,t0
    155c:	00878293          	addi	t0,a5,8
    1560:	00268313          	addi	t1,a3,2
    1564:	0512f863          	bgeu	t0,a7,15b4 <core_list_init+0x2f0>
    1568:	00470393          	addi	t2,a4,4
    156c:	05c3f463          	bgeu	t2,t3,15b4 <core_list_init+0x2f0>
    1570:	01031f93          	slli	t6,t1,0x10
    1574:	010fdf93          	srli	t6,t6,0x10
    1578:	01ff4333          	xor	t1,t5,t6
    157c:	00331313          	slli	t1,t1,0x3
    1580:	07837313          	andi	t1,t1,120
    1584:	007fff93          	andi	t6,t6,7
    1588:	0107a023          	sw	a6,0(a5)
    158c:	01f36833          	or	a6,t1,t6
    1590:	00f52023          	sw	a5,0(a0)
    1594:	00881313          	slli	t1,a6,0x8
    1598:	00e7a223          	sw	a4,4(a5)
    159c:	01036fb3          	or	t6,t1,a6
    15a0:	01f71023          	sh	t6,0(a4)
    15a4:	01d71123          	sh	t4,2(a4)
    15a8:	00078813          	mv	a6,a5
    15ac:	00038713          	mv	a4,t2
    15b0:	00028793          	mv	a5,t0
    15b4:	00368693          	addi	a3,a3,3
    15b8:	ead590e3          	bne	a1,a3,1458 <core_list_init+0x194>
    15bc:	00082883          	lw	a7,0(a6)
    15c0:	08088663          	beqz	a7,164c <core_list_init+0x388>
    15c4:	00500e13          	li	t3,5
    15c8:	03c5de33          	divu	t3,a1,t3
    15cc:	000045b7          	lui	a1,0x4
    15d0:	20000713          	li	a4,512
    15d4:	00100693          	li	a3,1
    15d8:	fff58593          	addi	a1,a1,-1 # 3fff <matrix_sum+0x413>
    15dc:	0300006f          	j	160c <core_list_init+0x348>
    15e0:	0008af03          	lw	t5,0(a7)
    15e4:	01069793          	slli	a5,a3,0x10
    15e8:	4107d813          	srai	a6,a5,0x10
    15ec:	10070713          	addi	a4,a4,256
    15f0:	010f9123          	sh	a6,2(t6) # ffff8002 <_stack_top+0xfffd2802>
    15f4:	00088813          	mv	a6,a7
    15f8:	01071893          	slli	a7,a4,0x10
    15fc:	00168693          	addi	a3,a3,1
    1600:	0108d713          	srli	a4,a7,0x10
    1604:	040f0463          	beqz	t5,164c <core_list_init+0x388>
    1608:	000f0893          	mv	a7,t5
    160c:	70077f13          	andi	t5,a4,1792
    1610:	00c6ceb3          	xor	t4,a3,a2
    1614:	01df62b3          	or	t0,t5,t4
    1618:	00482f83          	lw	t6,4(a6)
    161c:	00b2f3b3          	and	t2,t0,a1
    1620:	fdc6e0e3          	bltu	a3,t3,15e0 <core_list_init+0x31c>
    1624:	0008af03          	lw	t5,0(a7)
    1628:	01039313          	slli	t1,t2,0x10
    162c:	41035813          	srai	a6,t1,0x10
    1630:	10070713          	addi	a4,a4,256
    1634:	010f9123          	sh	a6,2(t6)
    1638:	00088813          	mv	a6,a7
    163c:	01071893          	slli	a7,a4,0x10
    1640:	00168693          	addi	a3,a3,1
    1644:	0108d713          	srli	a4,a7,0x10
    1648:	fc0f10e3          	bnez	t5,1608 <core_list_init+0x344>
    164c:	00001e37          	lui	t3,0x1
    1650:	00000613          	li	a2,0
    1654:	ae0e0593          	addi	a1,t3,-1312 # ae0 <cmp_idx>
    1658:	f88ff06f          	j	de0 <core_list_mergesort>
    165c:	00080793          	mv	a5,a6
    1660:	00028713          	mv	a4,t0
    1664:	00000813          	li	a6,0
    1668:	cc9ff06f          	j	1330 <core_list_init+0x6c>

0000166c <core_init_matrix>:
    166c:	fd010113          	addi	sp,sp,-48
    1670:	03312023          	sw	s3,32(sp)
    1674:	02812623          	sw	s0,44(sp)
    1678:	02912423          	sw	s1,40(sp)
    167c:	03212223          	sw	s2,36(sp)
    1680:	01412e23          	sw	s4,28(sp)
    1684:	01512c23          	sw	s5,24(sp)
    1688:	01612a23          	sw	s6,20(sp)
    168c:	01712823          	sw	s7,16(sp)
    1690:	01812623          	sw	s8,12(sp)
    1694:	01912423          	sw	s9,8(sp)
    1698:	01a12223          	sw	s10,4(sp)
    169c:	00050813          	mv	a6,a0
    16a0:	00068993          	mv	s3,a3
    16a4:	00061463          	bnez	a2,16ac <core_init_matrix+0x40>
    16a8:	00100613          	li	a2,1
    16ac:	00000793          	li	a5,0
    16b0:	2c080e63          	beqz	a6,198c <core_init_matrix+0x320>
    16b4:	00078513          	mv	a0,a5
    16b8:	00178793          	addi	a5,a5,1
    16bc:	02f78733          	mul	a4,a5,a5
    16c0:	00371293          	slli	t0,a4,0x3
    16c4:	ff02e8e3          	bltu	t0,a6,16b4 <core_init_matrix+0x48>
    16c8:	02a50433          	mul	s0,a0,a0
    16cc:	fff58313          	addi	t1,a1,-1
    16d0:	ffc37393          	andi	t2,t1,-4
    16d4:	00438a13          	addi	s4,t2,4
    16d8:	00050a93          	mv	s5,a0
    16dc:	000a0e13          	mv	t3,s4
    16e0:	00141413          	slli	s0,s0,0x1
    16e4:	008a04b3          	add	s1,s4,s0
    16e8:	24050863          	beqz	a0,1938 <core_init_matrix+0x2cc>
    16ec:	00010eb7          	lui	t4,0x10
    16f0:	00150f13          	addi	t5,a0,1
    16f4:	00151913          	slli	s2,a0,0x1
    16f8:	00048f93          	mv	t6,s1
    16fc:	00000393          	li	t2,0
    1700:	00100813          	li	a6,1
    1704:	409e0e33          	sub	t3,t3,s1
    1708:	fffe8e93          	addi	t4,t4,-1 # ffff <seed1_volatile+0x265f>
    170c:	410f06b3          	sub	a3,t5,a6
    1710:	0036f893          	andi	a7,a3,3
    1714:	000f8593          	mv	a1,t6
    1718:	00080693          	mv	a3,a6
    171c:	0e088863          	beqz	a7,180c <core_init_matrix+0x1a0>
    1720:	00100b13          	li	s6,1
    1724:	09688e63          	beq	a7,s6,17c0 <core_init_matrix+0x154>
    1728:	00200b93          	li	s7,2
    172c:	05788663          	beq	a7,s7,1778 <core_init_matrix+0x10c>
    1730:	03060633          	mul	a2,a2,a6
    1734:	01081c13          	slli	s8,a6,0x10
    1738:	010c5c93          	srli	s9,s8,0x10
    173c:	01fe0d33          	add	s10,t3,t6
    1740:	002f8593          	addi	a1,t6,2
    1744:	00180813          	addi	a6,a6,1
    1748:	41f65793          	srai	a5,a2,0x1f
    174c:	0107d713          	srli	a4,a5,0x10
    1750:	00e602b3          	add	t0,a2,a4
    1754:	01d2f333          	and	t1,t0,t4
    1758:	40e30633          	sub	a2,t1,a4
    175c:	00cc88b3          	add	a7,s9,a2
    1760:	01089b13          	slli	s6,a7,0x10
    1764:	010b5b93          	srli	s7,s6,0x10
    1768:	019b8c33          	add	s8,s7,s9
    176c:	017f9023          	sh	s7,0(t6)
    1770:	0ffc7c93          	zext.b	s9,s8
    1774:	019d1023          	sh	s9,0(s10)
    1778:	03060633          	mul	a2,a2,a6
    177c:	01081d13          	slli	s10,a6,0x10
    1780:	010d5793          	srli	a5,s10,0x10
    1784:	00be02b3          	add	t0,t3,a1
    1788:	00180813          	addi	a6,a6,1
    178c:	00258593          	addi	a1,a1,2
    1790:	41f65713          	srai	a4,a2,0x1f
    1794:	01075313          	srli	t1,a4,0x10
    1798:	006608b3          	add	a7,a2,t1
    179c:	01d8fb33          	and	s6,a7,t4
    17a0:	406b0633          	sub	a2,s6,t1
    17a4:	00c78bb3          	add	s7,a5,a2
    17a8:	010b9c13          	slli	s8,s7,0x10
    17ac:	010c5c93          	srli	s9,s8,0x10
    17b0:	00fc8d33          	add	s10,s9,a5
    17b4:	ff959f23          	sh	s9,-2(a1)
    17b8:	0ffd7793          	zext.b	a5,s10
    17bc:	00f29023          	sh	a5,0(t0)
    17c0:	03060633          	mul	a2,a2,a6
    17c4:	01081293          	slli	t0,a6,0x10
    17c8:	0102d313          	srli	t1,t0,0x10
    17cc:	00be08b3          	add	a7,t3,a1
    17d0:	00258593          	addi	a1,a1,2
    17d4:	00180813          	addi	a6,a6,1
    17d8:	41f65713          	srai	a4,a2,0x1f
    17dc:	01075b13          	srli	s6,a4,0x10
    17e0:	01660bb3          	add	s7,a2,s6
    17e4:	01dbfc33          	and	s8,s7,t4
    17e8:	416c0633          	sub	a2,s8,s6
    17ec:	00c30cb3          	add	s9,t1,a2
    17f0:	010c9d13          	slli	s10,s9,0x10
    17f4:	010d5293          	srli	t0,s10,0x10
    17f8:	006287b3          	add	a5,t0,t1
    17fc:	fe559f23          	sh	t0,-2(a1)
    1800:	0ff7f313          	zext.b	t1,a5
    1804:	00689023          	sh	t1,0(a7)
    1808:	11e80e63          	beq	a6,t5,1924 <core_init_matrix+0x2b8>
    180c:	03060633          	mul	a2,a2,a6
    1810:	00380b13          	addi	s6,a6,3
    1814:	01081893          	slli	a7,a6,0x10
    1818:	010b1d13          	slli	s10,s6,0x10
    181c:	0108d293          	srli	t0,a7,0x10
    1820:	010d5893          	srli	a7,s10,0x10
    1824:	00180713          	addi	a4,a6,1
    1828:	01071b93          	slli	s7,a4,0x10
    182c:	00280793          	addi	a5,a6,2
    1830:	00be0cb3          	add	s9,t3,a1
    1834:	41f65d13          	srai	s10,a2,0x1f
    1838:	010d5d13          	srli	s10,s10,0x10
    183c:	01a60633          	add	a2,a2,s10
    1840:	01d67633          	and	a2,a2,t4
    1844:	41a60d33          	sub	s10,a2,s10
    1848:	02ed0733          	mul	a4,s10,a4
    184c:	01a28633          	add	a2,t0,s10
    1850:	01061d13          	slli	s10,a2,0x10
    1854:	010d5613          	srli	a2,s10,0x10
    1858:	005602b3          	add	t0,a2,t0
    185c:	00c59023          	sh	a2,0(a1)
    1860:	01079c13          	slli	s8,a5,0x10
    1864:	0ff2fd13          	zext.b	s10,t0
    1868:	01ac9023          	sh	s10,0(s9)
    186c:	010c5313          	srli	t1,s8,0x10
    1870:	000c8613          	mv	a2,s9
    1874:	000c8c13          	mv	s8,s9
    1878:	000c8293          	mv	t0,s9
    187c:	41f75c93          	srai	s9,a4,0x1f
    1880:	010cdd13          	srli	s10,s9,0x10
    1884:	01a70733          	add	a4,a4,s10
    1888:	01d77cb3          	and	s9,a4,t4
    188c:	41ac8d33          	sub	s10,s9,s10
    1890:	02fd07b3          	mul	a5,s10,a5
    1894:	010bdb93          	srli	s7,s7,0x10
    1898:	01ab8733          	add	a4,s7,s10
    189c:	01071c93          	slli	s9,a4,0x10
    18a0:	010cdd13          	srli	s10,s9,0x10
    18a4:	017d0bb3          	add	s7,s10,s7
    18a8:	01a59123          	sh	s10,2(a1)
    18ac:	0ffbf713          	zext.b	a4,s7
    18b0:	00ec1123          	sh	a4,2(s8)
    18b4:	00858593          	addi	a1,a1,8
    18b8:	41f7dc13          	srai	s8,a5,0x1f
    18bc:	010c5c93          	srli	s9,s8,0x10
    18c0:	019787b3          	add	a5,a5,s9
    18c4:	01d7fd33          	and	s10,a5,t4
    18c8:	419d0bb3          	sub	s7,s10,s9
    18cc:	036b8b33          	mul	s6,s7,s6
    18d0:	01730733          	add	a4,t1,s7
    18d4:	01071c13          	slli	s8,a4,0x10
    18d8:	010c5c93          	srli	s9,s8,0x10
    18dc:	006c8333          	add	t1,s9,t1
    18e0:	ff959e23          	sh	s9,-4(a1)
    18e4:	0ff37793          	zext.b	a5,t1
    18e8:	00f61223          	sh	a5,4(a2)
    18ec:	00480813          	addi	a6,a6,4
    18f0:	41fb5613          	srai	a2,s6,0x1f
    18f4:	01065d13          	srli	s10,a2,0x10
    18f8:	01ab0bb3          	add	s7,s6,s10
    18fc:	01dbfb33          	and	s6,s7,t4
    1900:	41ab0633          	sub	a2,s6,s10
    1904:	00c88733          	add	a4,a7,a2
    1908:	01071c13          	slli	s8,a4,0x10
    190c:	010c5c93          	srli	s9,s8,0x10
    1910:	011c88b3          	add	a7,s9,a7
    1914:	ff959f23          	sh	s9,-2(a1)
    1918:	0ff8f313          	zext.b	t1,a7
    191c:	00629323          	sh	t1,6(t0)
    1920:	efe816e3          	bne	a6,t5,180c <core_init_matrix+0x1a0>
    1924:	00138393          	addi	t2,t2,1
    1928:	00d50833          	add	a6,a0,a3
    192c:	00af0f33          	add	t5,t5,a0
    1930:	012f8fb3          	add	t6,t6,s2
    1934:	dca39ce3          	bne	t2,a0,170c <core_init_matrix+0xa0>
    1938:	008486b3          	add	a3,s1,s0
    193c:	fff68813          	addi	a6,a3,-1
    1940:	ffc87593          	andi	a1,a6,-4
    1944:	00458413          	addi	s0,a1,4
    1948:	0089a623          	sw	s0,12(s3)
    194c:	02c12403          	lw	s0,44(sp)
    1950:	0149a223          	sw	s4,4(s3)
    1954:	0099a423          	sw	s1,8(s3)
    1958:	0159a023          	sw	s5,0(s3)
    195c:	02812483          	lw	s1,40(sp)
    1960:	02412903          	lw	s2,36(sp)
    1964:	02012983          	lw	s3,32(sp)
    1968:	01c12a03          	lw	s4,28(sp)
    196c:	01812a83          	lw	s5,24(sp)
    1970:	01412b03          	lw	s6,20(sp)
    1974:	01012b83          	lw	s7,16(sp)
    1978:	00c12c03          	lw	s8,12(sp)
    197c:	00812c83          	lw	s9,8(sp)
    1980:	00412d03          	lw	s10,4(sp)
    1984:	03010113          	addi	sp,sp,48
    1988:	00008067          	ret
    198c:	fff58593          	addi	a1,a1,-1
    1990:	ffc5f493          	andi	s1,a1,-4
    1994:	00448e13          	addi	t3,s1,4
    1998:	000e0a13          	mv	s4,t3
    199c:	00648493          	addi	s1,s1,6
    19a0:	fff00a93          	li	s5,-1
    19a4:	00200413          	li	s0,2
    19a8:	fff00513          	li	a0,-1
    19ac:	d41ff06f          	j	16ec <core_init_matrix+0x80>

000019b0 <matrix_test>:
    19b0:	fc010113          	addi	sp,sp,-64
    19b4:	02812c23          	sw	s0,56(sp)
    19b8:	01912a23          	sw	s9,20(sp)
    19bc:	01a12823          	sw	s10,16(sp)
    19c0:	02112e23          	sw	ra,60(sp)
    19c4:	02912a23          	sw	s1,52(sp)
    19c8:	03212823          	sw	s2,48(sp)
    19cc:	03312623          	sw	s3,44(sp)
    19d0:	03412423          	sw	s4,40(sp)
    19d4:	03512223          	sw	s5,36(sp)
    19d8:	03612023          	sw	s6,32(sp)
    19dc:	01712e23          	sw	s7,28(sp)
    19e0:	01812c23          	sw	s8,24(sp)
    19e4:	01b12623          	sw	s11,12(sp)
    19e8:	00058d13          	mv	s10,a1
    19ec:	00060413          	mv	s0,a2
    19f0:	00068c93          	mv	s9,a3
    19f4:	00051463          	bnez	a0,19fc <matrix_test+0x4c>
    19f8:	6580106f          	j	3050 <matrix_test+0x16a0>
    19fc:	00050d93          	mv	s11,a0
    1a00:	00151313          	slli	t1,a0,0x1
    1a04:	00660533          	add	a0,a2,t1
    1a08:	41b00c33          	neg	s8,s11
    1a0c:	01071993          	slli	s3,a4,0x10
    1a10:	0109d993          	srli	s3,s3,0x10
    1a14:	00050693          	mv	a3,a0
    1a18:	00000593          	li	a1,0
    1a1c:	002c1813          	slli	a6,s8,0x2
    1a20:	40668633          	sub	a2,a3,t1
    1a24:	40c680b3          	sub	ra,a3,a2
    1a28:	ffe08293          	addi	t0,ra,-2
    1a2c:	0012d393          	srli	t2,t0,0x1
    1a30:	00138893          	addi	a7,t2,1
    1a34:	0078fa13          	andi	s4,a7,7
    1a38:	00060393          	mv	t2,a2
    1a3c:	0a0a0463          	beqz	s4,1ae4 <matrix_test+0x134>
    1a40:	00100a93          	li	s5,1
    1a44:	095a0663          	beq	s4,s5,1ad0 <matrix_test+0x120>
    1a48:	00200b13          	li	s6,2
    1a4c:	076a0a63          	beq	s4,s6,1ac0 <matrix_test+0x110>
    1a50:	00300b93          	li	s7,3
    1a54:	057a0e63          	beq	s4,s7,1ab0 <matrix_test+0x100>
    1a58:	00400e13          	li	t3,4
    1a5c:	05ca0263          	beq	s4,t3,1aa0 <matrix_test+0xf0>
    1a60:	00500e93          	li	t4,5
    1a64:	03da0663          	beq	s4,t4,1a90 <matrix_test+0xe0>
    1a68:	00600f13          	li	t5,6
    1a6c:	01ea0a63          	beq	s4,t5,1a80 <matrix_test+0xd0>
    1a70:	00065f83          	lhu	t6,0(a2)
    1a74:	00260393          	addi	t2,a2,2
    1a78:	01f984b3          	add	s1,s3,t6
    1a7c:	00961023          	sh	s1,0(a2)
    1a80:	0003d903          	lhu	s2,0(t2)
    1a84:	00238393          	addi	t2,t2,2
    1a88:	012987b3          	add	a5,s3,s2
    1a8c:	fef39f23          	sh	a5,-2(t2)
    1a90:	0003d083          	lhu	ra,0(t2)
    1a94:	00238393          	addi	t2,t2,2
    1a98:	001982b3          	add	t0,s3,ra
    1a9c:	fe539f23          	sh	t0,-2(t2)
    1aa0:	0003d883          	lhu	a7,0(t2)
    1aa4:	00238393          	addi	t2,t2,2
    1aa8:	01198a33          	add	s4,s3,a7
    1aac:	ff439f23          	sh	s4,-2(t2)
    1ab0:	0003da83          	lhu	s5,0(t2)
    1ab4:	00238393          	addi	t2,t2,2
    1ab8:	01598b33          	add	s6,s3,s5
    1abc:	ff639f23          	sh	s6,-2(t2)
    1ac0:	0003db83          	lhu	s7,0(t2)
    1ac4:	00238393          	addi	t2,t2,2
    1ac8:	01798e33          	add	t3,s3,s7
    1acc:	ffc39f23          	sh	t3,-2(t2)
    1ad0:	0003de83          	lhu	t4,0(t2)
    1ad4:	00238393          	addi	t2,t2,2
    1ad8:	01d98f33          	add	t5,s3,t4
    1adc:	ffe39f23          	sh	t5,-2(t2)
    1ae0:	06d38663          	beq	t2,a3,1b4c <matrix_test+0x19c>
    1ae4:	0003d483          	lhu	s1,0(t2)
    1ae8:	0023d903          	lhu	s2,2(t2)
    1aec:	0043df83          	lhu	t6,4(t2)
    1af0:	0063d083          	lhu	ra,6(t2)
    1af4:	0083da03          	lhu	s4,8(t2)
    1af8:	00a3da83          	lhu	s5,10(t2)
    1afc:	00c3d883          	lhu	a7,12(t2)
    1b00:	00e3d783          	lhu	a5,14(t2)
    1b04:	00998b33          	add	s6,s3,s1
    1b08:	012982b3          	add	t0,s3,s2
    1b0c:	01f98bb3          	add	s7,s3,t6
    1b10:	00198f33          	add	t5,s3,ra
    1b14:	01498eb3          	add	t4,s3,s4
    1b18:	01598e33          	add	t3,s3,s5
    1b1c:	011984b3          	add	s1,s3,a7
    1b20:	00f98933          	add	s2,s3,a5
    1b24:	01639023          	sh	s6,0(t2)
    1b28:	00539123          	sh	t0,2(t2)
    1b2c:	01739223          	sh	s7,4(t2)
    1b30:	01e39323          	sh	t5,6(t2)
    1b34:	01d39423          	sh	t4,8(t2)
    1b38:	01c39523          	sh	t3,10(t2)
    1b3c:	00939623          	sh	s1,12(t2)
    1b40:	01239723          	sh	s2,14(t2)
    1b44:	01038393          	addi	t2,t2,16
    1b48:	f8d39ee3          	bne	t2,a3,1ae4 <matrix_test+0x134>
    1b4c:	00158e93          	addi	t4,a1,1
    1b50:	410606b3          	sub	a3,a2,a6
    1b54:	01dd8663          	beq	s11,t4,1b60 <matrix_test+0x1b0>
    1b58:	000e8593          	mv	a1,t4
    1b5c:	ec5ff06f          	j	1a20 <matrix_test+0x70>
    1b60:	00000f13          	li	t5,0
    1b64:	00000f93          	li	t6,0
    1b68:	406500b3          	sub	ra,a0,t1
    1b6c:	40150633          	sub	a2,a0,ra
    1b70:	ffe60393          	addi	t2,a2,-2
    1b74:	0013da13          	srli	s4,t2,0x1
    1b78:	001a0a93          	addi	s5,s4,1
    1b7c:	002f1893          	slli	a7,t5,0x2
    1b80:	007afb13          	andi	s6,s5,7
    1b84:	01a887b3          	add	a5,a7,s10
    1b88:	00008693          	mv	a3,ra
    1b8c:	0c0b0263          	beqz	s6,1c50 <matrix_test+0x2a0>
    1b90:	00100293          	li	t0,1
    1b94:	0a5b0263          	beq	s6,t0,1c38 <matrix_test+0x288>
    1b98:	00200b93          	li	s7,2
    1b9c:	097b0463          	beq	s6,s7,1c24 <matrix_test+0x274>
    1ba0:	00300e13          	li	t3,3
    1ba4:	07cb0663          	beq	s6,t3,1c10 <matrix_test+0x260>
    1ba8:	00400493          	li	s1,4
    1bac:	049b0863          	beq	s6,s1,1bfc <matrix_test+0x24c>
    1bb0:	00500913          	li	s2,5
    1bb4:	032b0a63          	beq	s6,s2,1be8 <matrix_test+0x238>
    1bb8:	00600613          	li	a2,6
    1bbc:	00cb0c63          	beq	s6,a2,1bd4 <matrix_test+0x224>
    1bc0:	00009383          	lh	t2,0(ra)
    1bc4:	00208693          	addi	a3,ra,2
    1bc8:	00478793          	addi	a5,a5,4
    1bcc:	02e38a33          	mul	s4,t2,a4
    1bd0:	ff47ae23          	sw	s4,-4(a5)
    1bd4:	00069a83          	lh	s5,0(a3)
    1bd8:	00478793          	addi	a5,a5,4
    1bdc:	00268693          	addi	a3,a3,2
    1be0:	02ea88b3          	mul	a7,s5,a4
    1be4:	ff17ae23          	sw	a7,-4(a5)
    1be8:	00069b03          	lh	s6,0(a3)
    1bec:	00478793          	addi	a5,a5,4
    1bf0:	00268693          	addi	a3,a3,2
    1bf4:	02eb02b3          	mul	t0,s6,a4
    1bf8:	fe57ae23          	sw	t0,-4(a5)
    1bfc:	00069b83          	lh	s7,0(a3)
    1c00:	00478793          	addi	a5,a5,4
    1c04:	00268693          	addi	a3,a3,2
    1c08:	02eb8e33          	mul	t3,s7,a4
    1c0c:	ffc7ae23          	sw	t3,-4(a5)
    1c10:	00069483          	lh	s1,0(a3)
    1c14:	00478793          	addi	a5,a5,4
    1c18:	00268693          	addi	a3,a3,2
    1c1c:	02e48933          	mul	s2,s1,a4
    1c20:	ff27ae23          	sw	s2,-4(a5)
    1c24:	00069603          	lh	a2,0(a3)
    1c28:	00478793          	addi	a5,a5,4
    1c2c:	00268693          	addi	a3,a3,2
    1c30:	02e603b3          	mul	t2,a2,a4
    1c34:	fe77ae23          	sw	t2,-4(a5)
    1c38:	00069a03          	lh	s4,0(a3)
    1c3c:	00478793          	addi	a5,a5,4
    1c40:	00268693          	addi	a3,a3,2
    1c44:	02ea0ab3          	mul	s5,s4,a4
    1c48:	ff57ae23          	sw	s5,-4(a5)
    1c4c:	06d50863          	beq	a0,a3,1cbc <matrix_test+0x30c>
    1c50:	00069883          	lh	a7,0(a3)
    1c54:	00269b03          	lh	s6,2(a3)
    1c58:	00469b83          	lh	s7,4(a3)
    1c5c:	00669483          	lh	s1,6(a3)
    1c60:	00869383          	lh	t2,8(a3)
    1c64:	00a69283          	lh	t0,10(a3)
    1c68:	00c69e03          	lh	t3,12(a3)
    1c6c:	00e69603          	lh	a2,14(a3)
    1c70:	02e88933          	mul	s2,a7,a4
    1c74:	01068693          	addi	a3,a3,16
    1c78:	02078793          	addi	a5,a5,32
    1c7c:	02eb0a33          	mul	s4,s6,a4
    1c80:	ff27a023          	sw	s2,-32(a5)
    1c84:	02eb8ab3          	mul	s5,s7,a4
    1c88:	ff47a223          	sw	s4,-28(a5)
    1c8c:	02e488b3          	mul	a7,s1,a4
    1c90:	ff57a423          	sw	s5,-24(a5)
    1c94:	02e38b33          	mul	s6,t2,a4
    1c98:	ff17a623          	sw	a7,-20(a5)
    1c9c:	02e28bb3          	mul	s7,t0,a4
    1ca0:	ff67a823          	sw	s6,-16(a5)
    1ca4:	02ee04b3          	mul	s1,t3,a4
    1ca8:	ff77aa23          	sw	s7,-12(a5)
    1cac:	02e603b3          	mul	t2,a2,a4
    1cb0:	fe97ac23          	sw	s1,-8(a5)
    1cb4:	fe77ae23          	sw	t2,-4(a5)
    1cb8:	f8d51ce3          	bne	a0,a3,1c50 <matrix_test+0x2a0>
    1cbc:	001f8693          	addi	a3,t6,1
    1cc0:	01df0f33          	add	t5,t5,t4
    1cc4:	41008533          	sub	a0,ra,a6
    1cc8:	00bf8663          	beq	t6,a1,1cd4 <matrix_test+0x324>
    1ccc:	00068f93          	mv	t6,a3
    1cd0:	e99ff06f          	j	1b68 <matrix_test+0x1b8>
    1cd4:	41d00fb3          	neg	t6,t4
    1cd8:	fffff0b7          	lui	ra,0xfffff
    1cdc:	00176933          	or	s2,a4,ra
    1ce0:	00000793          	li	a5,0
    1ce4:	410d0733          	sub	a4,s10,a6
    1ce8:	00000e13          	li	t3,0
    1cec:	00000513          	li	a0,0
    1cf0:	00000893          	li	a7,0
    1cf4:	003f9693          	slli	a3,t6,0x3
    1cf8:	010702b3          	add	t0,a4,a6
    1cfc:	40570333          	sub	t1,a4,t0
    1d00:	ffc30e93          	addi	t4,t1,-4
    1d04:	002ed613          	srli	a2,t4,0x2
    1d08:	00160a13          	addi	s4,a2,1
    1d0c:	007a7a93          	andi	s5,s4,7
    1d10:	00028313          	mv	t1,t0
    1d14:	280a8e63          	beqz	s5,1fb0 <matrix_test+0x600>
    1d18:	00100b13          	li	s6,1
    1d1c:	136a8c63          	beq	s5,s6,1e54 <matrix_test+0x4a4>
    1d20:	00200b93          	li	s7,2
    1d24:	117a8263          	beq	s5,s7,1e28 <matrix_test+0x478>
    1d28:	00300493          	li	s1,3
    1d2c:	0c9a8863          	beq	s5,s1,1dfc <matrix_test+0x44c>
    1d30:	00400393          	li	t2,4
    1d34:	087a8e63          	beq	s5,t2,1dd0 <matrix_test+0x420>
    1d38:	00500f13          	li	t5,5
    1d3c:	07ea8463          	beq	s5,t5,1da4 <matrix_test+0x3f4>
    1d40:	00600f93          	li	t6,6
    1d44:	03fa8a63          	beq	s5,t6,1d78 <matrix_test+0x3c8>
    1d48:	000e0093          	mv	ra,t3
    1d4c:	0002ae03          	lw	t3,0(t0)
    1d50:	01079793          	slli	a5,a5,0x10
    1d54:	0107de93          	srli	t4,a5,0x10
    1d58:	01c50533          	add	a0,a0,t3
    1d5c:	00a94463          	blt	s2,a0,1d64 <matrix_test+0x3b4>
    1d60:	3c00106f          	j	3120 <matrix_test+0x1770>
    1d64:	00ae8513          	addi	a0,t4,10
    1d68:	01051a93          	slli	s5,a0,0x10
    1d6c:	410ad793          	srai	a5,s5,0x10
    1d70:	00000513          	li	a0,0
    1d74:	00428313          	addi	t1,t0,4
    1d78:	000e0b13          	mv	s6,t3
    1d7c:	00032e03          	lw	t3,0(t1)
    1d80:	01079b93          	slli	s7,a5,0x10
    1d84:	010bd493          	srli	s1,s7,0x10
    1d88:	01c50533          	add	a0,a0,t3
    1d8c:	3aa95863          	bge	s2,a0,213c <matrix_test+0x78c>
    1d90:	00a48093          	addi	ra,s1,10
    1d94:	01009793          	slli	a5,ra,0x10
    1d98:	4107d793          	srai	a5,a5,0x10
    1d9c:	00000513          	li	a0,0
    1da0:	00430313          	addi	t1,t1,4
    1da4:	000e0e93          	mv	t4,t3
    1da8:	00032e03          	lw	t3,0(t1)
    1dac:	01079613          	slli	a2,a5,0x10
    1db0:	01065a13          	srli	s4,a2,0x10
    1db4:	01c50533          	add	a0,a0,t3
    1db8:	36a95863          	bge	s2,a0,2128 <matrix_test+0x778>
    1dbc:	00aa0513          	addi	a0,s4,10
    1dc0:	01051493          	slli	s1,a0,0x10
    1dc4:	4104d793          	srai	a5,s1,0x10
    1dc8:	00000513          	li	a0,0
    1dcc:	00430313          	addi	t1,t1,4
    1dd0:	000e0393          	mv	t2,t3
    1dd4:	00032e03          	lw	t3,0(t1)
    1dd8:	01079f13          	slli	t5,a5,0x10
    1ddc:	010f5f93          	srli	t6,t5,0x10
    1de0:	01c50533          	add	a0,a0,t3
    1de4:	32a95863          	bge	s2,a0,2114 <matrix_test+0x764>
    1de8:	00af8613          	addi	a2,t6,10
    1dec:	01061a13          	slli	s4,a2,0x10
    1df0:	410a5793          	srai	a5,s4,0x10
    1df4:	00000513          	li	a0,0
    1df8:	00430313          	addi	t1,t1,4
    1dfc:	000e0a93          	mv	s5,t3
    1e00:	00032e03          	lw	t3,0(t1)
    1e04:	01079b13          	slli	s6,a5,0x10
    1e08:	010b5b93          	srli	s7,s6,0x10
    1e0c:	01c50533          	add	a0,a0,t3
    1e10:	2ea95863          	bge	s2,a0,2100 <matrix_test+0x750>
    1e14:	00ab8513          	addi	a0,s7,10
    1e18:	01051f93          	slli	t6,a0,0x10
    1e1c:	410fd793          	srai	a5,t6,0x10
    1e20:	00000513          	li	a0,0
    1e24:	00430313          	addi	t1,t1,4
    1e28:	000e0093          	mv	ra,t3
    1e2c:	00032e03          	lw	t3,0(t1)
    1e30:	01079793          	slli	a5,a5,0x10
    1e34:	0107d613          	srli	a2,a5,0x10
    1e38:	01c50533          	add	a0,a0,t3
    1e3c:	2aa95863          	bge	s2,a0,20ec <matrix_test+0x73c>
    1e40:	00a60b13          	addi	s6,a2,10
    1e44:	010b1b93          	slli	s7,s6,0x10
    1e48:	410bd793          	srai	a5,s7,0x10
    1e4c:	00000513          	li	a0,0
    1e50:	00430313          	addi	t1,t1,4
    1e54:	000e0493          	mv	s1,t3
    1e58:	00032e03          	lw	t3,0(t1)
    1e5c:	01079393          	slli	t2,a5,0x10
    1e60:	0103df13          	srli	t5,t2,0x10
    1e64:	01c50533          	add	a0,a0,t3
    1e68:	26a95863          	bge	s2,a0,20d8 <matrix_test+0x728>
    1e6c:	00af0513          	addi	a0,t5,10
    1e70:	01051613          	slli	a2,a0,0x10
    1e74:	41065793          	srai	a5,a2,0x10
    1e78:	00000513          	li	a0,0
    1e7c:	00430313          	addi	t1,t1,4
    1e80:	12e31863          	bne	t1,a4,1fb0 <matrix_test+0x600>
    1e84:	00188f13          	addi	t5,a7,1
    1e88:	40d28733          	sub	a4,t0,a3
    1e8c:	2d158263          	beq	a1,a7,2150 <matrix_test+0x7a0>
    1e90:	000f0893          	mv	a7,t5
    1e94:	e65ff06f          	j	1cf8 <matrix_test+0x348>
    1e98:	01de2e33          	slt	t3,t3,t4
    1e9c:	00432083          	lw	ra,4(t1)
    1ea0:	01ca8b33          	add	s6,s5,t3
    1ea4:	010b1b93          	slli	s7,s6,0x10
    1ea8:	410bdf13          	srai	t5,s7,0x10
    1eac:	010f1793          	slli	a5,t5,0x10
    1eb0:	001f8533          	add	a0,t6,ra
    1eb4:	00430313          	addi	t1,t1,4
    1eb8:	0107d613          	srli	a2,a5,0x10
    1ebc:	12a95863          	bge	s2,a0,1fec <matrix_test+0x63c>
    1ec0:	00432483          	lw	s1,4(t1)
    1ec4:	00a60b13          	addi	s6,a2,10
    1ec8:	010b1b93          	slli	s7,s6,0x10
    1ecc:	410bde13          	srai	t3,s7,0x10
    1ed0:	00000513          	li	a0,0
    1ed4:	010e1393          	slli	t2,t3,0x10
    1ed8:	00950fb3          	add	t6,a0,s1
    1edc:	0103df13          	srli	t5,t2,0x10
    1ee0:	13f95863          	bge	s2,t6,2010 <matrix_test+0x660>
    1ee4:	00832a83          	lw	s5,8(t1)
    1ee8:	00af0e93          	addi	t4,t5,10
    1eec:	010e9a13          	slli	s4,t4,0x10
    1ef0:	410a5513          	srai	a0,s4,0x10
    1ef4:	00000f93          	li	t6,0
    1ef8:	01051e13          	slli	t3,a0,0x10
    1efc:	015f8bb3          	add	s7,t6,s5
    1f00:	010e5b13          	srli	s6,t3,0x10
    1f04:	13795863          	bge	s2,s7,2034 <matrix_test+0x684>
    1f08:	00c32603          	lw	a2,12(t1)
    1f0c:	00ab0093          	addi	ra,s6,10
    1f10:	01009793          	slli	a5,ra,0x10
    1f14:	4107df93          	srai	t6,a5,0x10
    1f18:	00000b93          	li	s7,0
    1f1c:	010f9513          	slli	a0,t6,0x10
    1f20:	00cb8a33          	add	s4,s7,a2
    1f24:	01055e93          	srli	t4,a0,0x10
    1f28:	13495863          	bge	s2,s4,2058 <matrix_test+0x6a8>
    1f2c:	01032f03          	lw	t5,16(t1)
    1f30:	00ae8493          	addi	s1,t4,10
    1f34:	01049393          	slli	t2,s1,0x10
    1f38:	4103db93          	srai	s7,t2,0x10
    1f3c:	00000a13          	li	s4,0
    1f40:	010b9f93          	slli	t6,s7,0x10
    1f44:	01ea0533          	add	a0,s4,t5
    1f48:	010fd093          	srli	ra,t6,0x10
    1f4c:	12a95863          	bge	s2,a0,207c <matrix_test+0x6cc>
    1f50:	01432b03          	lw	s6,20(t1)
    1f54:	00a08a93          	addi	s5,ra,10 # fffff00a <_stack_top+0xfffd980a>
    1f58:	010a9e13          	slli	t3,s5,0x10
    1f5c:	410e5a13          	srai	s4,t3,0x10
    1f60:	00000513          	li	a0,0
    1f64:	010a1b93          	slli	s7,s4,0x10
    1f68:	016503b3          	add	t2,a0,s6
    1f6c:	010bd493          	srli	s1,s7,0x10
    1f70:	12795863          	bge	s2,t2,20a0 <matrix_test+0x6f0>
    1f74:	01832e03          	lw	t3,24(t1)
    1f78:	00a48793          	addi	a5,s1,10
    1f7c:	01079613          	slli	a2,a5,0x10
    1f80:	41065513          	srai	a0,a2,0x10
    1f84:	00000393          	li	t2,0
    1f88:	01051e93          	slli	t4,a0,0x10
    1f8c:	01c38533          	add	a0,t2,t3
    1f90:	010eda13          	srli	s4,t4,0x10
    1f94:	12a95863          	bge	s2,a0,20c4 <matrix_test+0x714>
    1f98:	00aa0493          	addi	s1,s4,10
    1f9c:	01049393          	slli	t2,s1,0x10
    1fa0:	4103d793          	srai	a5,t2,0x10
    1fa4:	00000513          	li	a0,0
    1fa8:	01c30313          	addi	t1,t1,28
    1fac:	ece30ce3          	beq	t1,a4,1e84 <matrix_test+0x4d4>
    1fb0:	00032e83          	lw	t4,0(t1)
    1fb4:	01079a13          	slli	s4,a5,0x10
    1fb8:	010a5a93          	srli	s5,s4,0x10
    1fbc:	01d50fb3          	add	t6,a0,t4
    1fc0:	edf95ce3          	bge	s2,t6,1e98 <matrix_test+0x4e8>
    1fc4:	00432083          	lw	ra,4(t1)
    1fc8:	00aa8493          	addi	s1,s5,10
    1fcc:	01049393          	slli	t2,s1,0x10
    1fd0:	4103df13          	srai	t5,t2,0x10
    1fd4:	00000f93          	li	t6,0
    1fd8:	010f1793          	slli	a5,t5,0x10
    1fdc:	001f8533          	add	a0,t6,ra
    1fe0:	00430313          	addi	t1,t1,4
    1fe4:	0107d613          	srli	a2,a5,0x10
    1fe8:	eca94ce3          	blt	s2,a0,1ec0 <matrix_test+0x510>
    1fec:	001eaeb3          	slt	t4,t4,ra
    1ff0:	00432483          	lw	s1,4(t1)
    1ff4:	01d60a33          	add	s4,a2,t4
    1ff8:	010a1a93          	slli	s5,s4,0x10
    1ffc:	410ade13          	srai	t3,s5,0x10
    2000:	010e1393          	slli	t2,t3,0x10
    2004:	00950fb3          	add	t6,a0,s1
    2008:	0103df13          	srli	t5,t2,0x10
    200c:	edf94ce3          	blt	s2,t6,1ee4 <matrix_test+0x534>
    2010:	0090a0b3          	slt	ra,ra,s1
    2014:	00832a83          	lw	s5,8(t1)
    2018:	001f07b3          	add	a5,t5,ra
    201c:	01079613          	slli	a2,a5,0x10
    2020:	41065513          	srai	a0,a2,0x10
    2024:	01051e13          	slli	t3,a0,0x10
    2028:	015f8bb3          	add	s7,t6,s5
    202c:	010e5b13          	srli	s6,t3,0x10
    2030:	ed794ce3          	blt	s2,s7,1f08 <matrix_test+0x558>
    2034:	0154a4b3          	slt	s1,s1,s5
    2038:	00c32603          	lw	a2,12(t1)
    203c:	009b03b3          	add	t2,s6,s1
    2040:	01039f13          	slli	t5,t2,0x10
    2044:	410f5f93          	srai	t6,t5,0x10
    2048:	010f9513          	slli	a0,t6,0x10
    204c:	00cb8a33          	add	s4,s7,a2
    2050:	01055e93          	srli	t4,a0,0x10
    2054:	ed494ce3          	blt	s2,s4,1f2c <matrix_test+0x57c>
    2058:	00caaab3          	slt	s5,s5,a2
    205c:	01032f03          	lw	t5,16(t1)
    2060:	015e8e33          	add	t3,t4,s5
    2064:	010e1b13          	slli	s6,t3,0x10
    2068:	410b5b93          	srai	s7,s6,0x10
    206c:	010b9f93          	slli	t6,s7,0x10
    2070:	01ea0533          	add	a0,s4,t5
    2074:	010fd093          	srli	ra,t6,0x10
    2078:	eca94ce3          	blt	s2,a0,1f50 <matrix_test+0x5a0>
    207c:	01e627b3          	slt	a5,a2,t5
    2080:	01432b03          	lw	s6,20(t1)
    2084:	00f08633          	add	a2,ra,a5
    2088:	01061e93          	slli	t4,a2,0x10
    208c:	410eda13          	srai	s4,t4,0x10
    2090:	010a1b93          	slli	s7,s4,0x10
    2094:	016503b3          	add	t2,a0,s6
    2098:	010bd493          	srli	s1,s7,0x10
    209c:	ec794ce3          	blt	s2,t2,1f74 <matrix_test+0x5c4>
    20a0:	016f2f33          	slt	t5,t5,s6
    20a4:	01832e03          	lw	t3,24(t1)
    20a8:	01e48fb3          	add	t6,s1,t5
    20ac:	010f9093          	slli	ra,t6,0x10
    20b0:	4100d513          	srai	a0,ra,0x10
    20b4:	01051e93          	slli	t4,a0,0x10
    20b8:	01c38533          	add	a0,t2,t3
    20bc:	010eda13          	srli	s4,t4,0x10
    20c0:	eca94ce3          	blt	s2,a0,1f98 <matrix_test+0x5e8>
    20c4:	01cb2ab3          	slt	s5,s6,t3
    20c8:	015a0b33          	add	s6,s4,s5
    20cc:	010b1b93          	slli	s7,s6,0x10
    20d0:	410bd793          	srai	a5,s7,0x10
    20d4:	ed5ff06f          	j	1fa8 <matrix_test+0x5f8>
    20d8:	01c4afb3          	slt	t6,s1,t3
    20dc:	01ff00b3          	add	ra,t5,t6
    20e0:	01009793          	slli	a5,ra,0x10
    20e4:	4107d793          	srai	a5,a5,0x10
    20e8:	d95ff06f          	j	1e7c <matrix_test+0x4cc>
    20ec:	01c0aeb3          	slt	t4,ra,t3
    20f0:	01d60a33          	add	s4,a2,t4
    20f4:	010a1a93          	slli	s5,s4,0x10
    20f8:	410ad793          	srai	a5,s5,0x10
    20fc:	d55ff06f          	j	1e50 <matrix_test+0x4a0>
    2100:	01caa4b3          	slt	s1,s5,t3
    2104:	009b83b3          	add	t2,s7,s1
    2108:	01039f13          	slli	t5,t2,0x10
    210c:	410f5793          	srai	a5,t5,0x10
    2110:	d15ff06f          	j	1e24 <matrix_test+0x474>
    2114:	01c3a0b3          	slt	ra,t2,t3
    2118:	001f87b3          	add	a5,t6,ra
    211c:	01079e93          	slli	t4,a5,0x10
    2120:	410ed793          	srai	a5,t4,0x10
    2124:	cd5ff06f          	j	1df8 <matrix_test+0x448>
    2128:	01ceaab3          	slt	s5,t4,t3
    212c:	015a0b33          	add	s6,s4,s5
    2130:	010b1b93          	slli	s7,s6,0x10
    2134:	410bd793          	srai	a5,s7,0x10
    2138:	c95ff06f          	j	1dcc <matrix_test+0x41c>
    213c:	01cb23b3          	slt	t2,s6,t3
    2140:	00748f33          	add	t5,s1,t2
    2144:	010f1f93          	slli	t6,t5,0x10
    2148:	410fd793          	srai	a5,t6,0x10
    214c:	c55ff06f          	j	1da0 <matrix_test+0x3f0>
    2150:	00000593          	li	a1,0
    2154:	00078513          	mv	a0,a5
    2158:	229030ef          	jal	ra,5b80 <crc16>
    215c:	00040613          	mv	a2,s0
    2160:	000d0593          	mv	a1,s10
    2164:	00050493          	mv	s1,a0
    2168:	000c8693          	mv	a3,s9
    216c:	000d8513          	mv	a0,s11
    2170:	310020ef          	jal	ra,4480 <matrix_mul_vect>
    2174:	002d9893          	slli	a7,s11,0x2
    2178:	011d0a33          	add	s4,s10,a7
    217c:	002c1b93          	slli	s7,s8,0x2
    2180:	000a0293          	mv	t0,s4
    2184:	00000513          	li	a0,0
    2188:	00000593          	li	a1,0
    218c:	00000613          	li	a2,0
    2190:	00000a93          	li	s5,0
    2194:	003c1c13          	slli	s8,s8,0x3
    2198:	005b8fb3          	add	t6,s7,t0
    219c:	41f280b3          	sub	ra,t0,t6
    21a0:	ffc08e13          	addi	t3,ra,-4
    21a4:	002e5e93          	srli	t4,t3,0x2
    21a8:	001e8b13          	addi	s6,t4,1
    21ac:	007b7793          	andi	a5,s6,7
    21b0:	000f8693          	mv	a3,t6
    21b4:	28078c63          	beqz	a5,244c <matrix_test+0xa9c>
    21b8:	00100393          	li	t2,1
    21bc:	12778a63          	beq	a5,t2,22f0 <matrix_test+0x940>
    21c0:	00200313          	li	t1,2
    21c4:	10678063          	beq	a5,t1,22c4 <matrix_test+0x914>
    21c8:	00300813          	li	a6,3
    21cc:	0d078663          	beq	a5,a6,2298 <matrix_test+0x8e8>
    21d0:	00400f13          	li	t5,4
    21d4:	09e78c63          	beq	a5,t5,226c <matrix_test+0x8bc>
    21d8:	00500713          	li	a4,5
    21dc:	06e78263          	beq	a5,a4,2240 <matrix_test+0x890>
    21e0:	00600893          	li	a7,6
    21e4:	03178863          	beq	a5,a7,2214 <matrix_test+0x864>
    21e8:	00058693          	mv	a3,a1
    21ec:	000fa583          	lw	a1,0(t6)
    21f0:	01051513          	slli	a0,a0,0x10
    21f4:	01055093          	srli	ra,a0,0x10
    21f8:	00b60633          	add	a2,a2,a1
    21fc:	72c95ce3          	bge	s2,a2,3134 <matrix_test+0x1784>
    2200:	00a08613          	addi	a2,ra,10
    2204:	01061793          	slli	a5,a2,0x10
    2208:	4107d513          	srai	a0,a5,0x10
    220c:	00000613          	li	a2,0
    2210:	004f8693          	addi	a3,t6,4
    2214:	00058393          	mv	t2,a1
    2218:	0006a583          	lw	a1,0(a3)
    221c:	01051313          	slli	t1,a0,0x10
    2220:	01035f13          	srli	t5,t1,0x10
    2224:	00b60633          	add	a2,a2,a1
    2228:	3ac95863          	bge	s2,a2,25d8 <matrix_test+0xc28>
    222c:	00af0513          	addi	a0,t5,10
    2230:	01051093          	slli	ra,a0,0x10
    2234:	4100d513          	srai	a0,ra,0x10
    2238:	00000613          	li	a2,0
    223c:	00468693          	addi	a3,a3,4
    2240:	00058e13          	mv	t3,a1
    2244:	0006a583          	lw	a1,0(a3)
    2248:	01051e93          	slli	t4,a0,0x10
    224c:	010edb13          	srli	s6,t4,0x10
    2250:	00b60633          	add	a2,a2,a1
    2254:	36c95863          	bge	s2,a2,25c4 <matrix_test+0xc14>
    2258:	00ab0613          	addi	a2,s6,10
    225c:	01061f13          	slli	t5,a2,0x10
    2260:	410f5513          	srai	a0,t5,0x10
    2264:	00000613          	li	a2,0
    2268:	00468693          	addi	a3,a3,4
    226c:	00058813          	mv	a6,a1
    2270:	0006a583          	lw	a1,0(a3)
    2274:	01051713          	slli	a4,a0,0x10
    2278:	01075893          	srli	a7,a4,0x10
    227c:	00b60633          	add	a2,a2,a1
    2280:	32c95863          	bge	s2,a2,25b0 <matrix_test+0xc00>
    2284:	00a88e93          	addi	t4,a7,10
    2288:	010e9b13          	slli	s6,t4,0x10
    228c:	410b5513          	srai	a0,s6,0x10
    2290:	00000613          	li	a2,0
    2294:	00468693          	addi	a3,a3,4
    2298:	00058793          	mv	a5,a1
    229c:	0006a583          	lw	a1,0(a3)
    22a0:	01051393          	slli	t2,a0,0x10
    22a4:	0103d313          	srli	t1,t2,0x10
    22a8:	00b60633          	add	a2,a2,a1
    22ac:	2ec95863          	bge	s2,a2,259c <matrix_test+0xbec>
    22b0:	00a30613          	addi	a2,t1,10
    22b4:	01061893          	slli	a7,a2,0x10
    22b8:	4108d513          	srai	a0,a7,0x10
    22bc:	00000613          	li	a2,0
    22c0:	00468693          	addi	a3,a3,4
    22c4:	00058093          	mv	ra,a1
    22c8:	0006a583          	lw	a1,0(a3)
    22cc:	01051513          	slli	a0,a0,0x10
    22d0:	01055e13          	srli	t3,a0,0x10
    22d4:	00b60633          	add	a2,a2,a1
    22d8:	2ac95863          	bge	s2,a2,2588 <matrix_test+0xbd8>
    22dc:	00ae0393          	addi	t2,t3,10
    22e0:	01039313          	slli	t1,t2,0x10
    22e4:	41035513          	srai	a0,t1,0x10
    22e8:	00000613          	li	a2,0
    22ec:	00468693          	addi	a3,a3,4
    22f0:	00058f13          	mv	t5,a1
    22f4:	0006a583          	lw	a1,0(a3)
    22f8:	01051813          	slli	a6,a0,0x10
    22fc:	01085713          	srli	a4,a6,0x10
    2300:	00b60633          	add	a2,a2,a1
    2304:	26c95863          	bge	s2,a2,2574 <matrix_test+0xbc4>
    2308:	00a70613          	addi	a2,a4,10
    230c:	01061e13          	slli	t3,a2,0x10
    2310:	410e5513          	srai	a0,t3,0x10
    2314:	00000613          	li	a2,0
    2318:	00468693          	addi	a3,a3,4
    231c:	12569863          	bne	a3,t0,244c <matrix_test+0xa9c>
    2320:	001a8b13          	addi	s6,s5,1
    2324:	418f82b3          	sub	t0,t6,s8
    2328:	2d6d8263          	beq	s11,s6,25ec <matrix_test+0xc3c>
    232c:	000b0a93          	mv	s5,s6
    2330:	e69ff06f          	j	2198 <matrix_test+0x7e8>
    2334:	01d5a5b3          	slt	a1,a1,t4
    2338:	0046a083          	lw	ra,4(a3)
    233c:	00b783b3          	add	t2,a5,a1
    2340:	01039313          	slli	t1,t2,0x10
    2344:	41035713          	srai	a4,t1,0x10
    2348:	01071513          	slli	a0,a4,0x10
    234c:	00188633          	add	a2,a7,ra
    2350:	00468693          	addi	a3,a3,4
    2354:	01055e13          	srli	t3,a0,0x10
    2358:	12c95863          	bge	s2,a2,2488 <matrix_test+0xad8>
    235c:	0046af03          	lw	t5,4(a3)
    2360:	00ae0393          	addi	t2,t3,10
    2364:	01039313          	slli	t1,t2,0x10
    2368:	41035593          	srai	a1,t1,0x10
    236c:	00000613          	li	a2,0
    2370:	01059813          	slli	a6,a1,0x10
    2374:	01e608b3          	add	a7,a2,t5
    2378:	01085713          	srli	a4,a6,0x10
    237c:	13195863          	bge	s2,a7,24ac <matrix_test+0xafc>
    2380:	0086a783          	lw	a5,8(a3)
    2384:	00a70e93          	addi	t4,a4,10
    2388:	010e9b13          	slli	s6,t4,0x10
    238c:	410b5613          	srai	a2,s6,0x10
    2390:	00000893          	li	a7,0
    2394:	01061593          	slli	a1,a2,0x10
    2398:	00f88333          	add	t1,a7,a5
    239c:	0105d393          	srli	t2,a1,0x10
    23a0:	12695863          	bge	s2,t1,24d0 <matrix_test+0xb20>
    23a4:	00c6ae03          	lw	t3,12(a3)
    23a8:	00a38093          	addi	ra,t2,10
    23ac:	01009513          	slli	a0,ra,0x10
    23b0:	41055893          	srai	a7,a0,0x10
    23b4:	00000313          	li	t1,0
    23b8:	01089613          	slli	a2,a7,0x10
    23bc:	01c30b33          	add	s6,t1,t3
    23c0:	01065e93          	srli	t4,a2,0x10
    23c4:	13695863          	bge	s2,s6,24f4 <matrix_test+0xb44>
    23c8:	0106a703          	lw	a4,16(a3)
    23cc:	00ae8f13          	addi	t5,t4,10
    23d0:	010f1813          	slli	a6,t5,0x10
    23d4:	41085313          	srai	t1,a6,0x10
    23d8:	00000b13          	li	s6,0
    23dc:	01031893          	slli	a7,t1,0x10
    23e0:	00eb0633          	add	a2,s6,a4
    23e4:	0108d093          	srli	ra,a7,0x10
    23e8:	12c95863          	bge	s2,a2,2518 <matrix_test+0xb68>
    23ec:	0146a383          	lw	t2,20(a3)
    23f0:	00a08793          	addi	a5,ra,10
    23f4:	01079593          	slli	a1,a5,0x10
    23f8:	4105db13          	srai	s6,a1,0x10
    23fc:	00000613          	li	a2,0
    2400:	010b1313          	slli	t1,s6,0x10
    2404:	00760833          	add	a6,a2,t2
    2408:	01035f13          	srli	t5,t1,0x10
    240c:	13095863          	bge	s2,a6,253c <matrix_test+0xb8c>
    2410:	0186a583          	lw	a1,24(a3)
    2414:	00af0513          	addi	a0,t5,10
    2418:	01051e13          	slli	t3,a0,0x10
    241c:	410e5613          	srai	a2,t3,0x10
    2420:	00000813          	li	a6,0
    2424:	01061e93          	slli	t4,a2,0x10
    2428:	00b80633          	add	a2,a6,a1
    242c:	010edb13          	srli	s6,t4,0x10
    2430:	12c95863          	bge	s2,a2,2560 <matrix_test+0xbb0>
    2434:	00ab0f13          	addi	t5,s6,10
    2438:	010f1813          	slli	a6,t5,0x10
    243c:	41085513          	srai	a0,a6,0x10
    2440:	00000613          	li	a2,0
    2444:	01c68693          	addi	a3,a3,28
    2448:	ec568ce3          	beq	a3,t0,2320 <matrix_test+0x970>
    244c:	0006ae83          	lw	t4,0(a3)
    2450:	01051b13          	slli	s6,a0,0x10
    2454:	010b5793          	srli	a5,s6,0x10
    2458:	01d608b3          	add	a7,a2,t4
    245c:	ed195ce3          	bge	s2,a7,2334 <matrix_test+0x984>
    2460:	0046a083          	lw	ra,4(a3)
    2464:	00a78f13          	addi	t5,a5,10
    2468:	010f1813          	slli	a6,t5,0x10
    246c:	41085713          	srai	a4,a6,0x10
    2470:	00000893          	li	a7,0
    2474:	01071513          	slli	a0,a4,0x10
    2478:	00188633          	add	a2,a7,ra
    247c:	00468693          	addi	a3,a3,4
    2480:	01055e13          	srli	t3,a0,0x10
    2484:	ecc94ce3          	blt	s2,a2,235c <matrix_test+0x9ac>
    2488:	001eaeb3          	slt	t4,t4,ra
    248c:	0046af03          	lw	t5,4(a3)
    2490:	01de0b33          	add	s6,t3,t4
    2494:	010b1793          	slli	a5,s6,0x10
    2498:	4107d593          	srai	a1,a5,0x10
    249c:	01059813          	slli	a6,a1,0x10
    24a0:	01e608b3          	add	a7,a2,t5
    24a4:	01085713          	srli	a4,a6,0x10
    24a8:	ed194ce3          	blt	s2,a7,2380 <matrix_test+0x9d0>
    24ac:	01e0a0b3          	slt	ra,ra,t5
    24b0:	0086a783          	lw	a5,8(a3)
    24b4:	00170533          	add	a0,a4,ra
    24b8:	01051e13          	slli	t3,a0,0x10
    24bc:	410e5613          	srai	a2,t3,0x10
    24c0:	01061593          	slli	a1,a2,0x10
    24c4:	00f88333          	add	t1,a7,a5
    24c8:	0105d393          	srli	t2,a1,0x10
    24cc:	ec694ce3          	blt	s2,t1,23a4 <matrix_test+0x9f4>
    24d0:	00ff2f33          	slt	t5,t5,a5
    24d4:	00c6ae03          	lw	t3,12(a3)
    24d8:	01e38833          	add	a6,t2,t5
    24dc:	01081713          	slli	a4,a6,0x10
    24e0:	41075893          	srai	a7,a4,0x10
    24e4:	01089613          	slli	a2,a7,0x10
    24e8:	01c30b33          	add	s6,t1,t3
    24ec:	01065e93          	srli	t4,a2,0x10
    24f0:	ed694ce3          	blt	s2,s6,23c8 <matrix_test+0xa18>
    24f4:	01c7a7b3          	slt	a5,a5,t3
    24f8:	0106a703          	lw	a4,16(a3)
    24fc:	00fe85b3          	add	a1,t4,a5
    2500:	01059393          	slli	t2,a1,0x10
    2504:	4103d313          	srai	t1,t2,0x10
    2508:	01031893          	slli	a7,t1,0x10
    250c:	00eb0633          	add	a2,s6,a4
    2510:	0108d093          	srli	ra,a7,0x10
    2514:	ecc94ce3          	blt	s2,a2,23ec <matrix_test+0xa3c>
    2518:	00ee2533          	slt	a0,t3,a4
    251c:	0146a383          	lw	t2,20(a3)
    2520:	00a08e33          	add	t3,ra,a0
    2524:	010e1e93          	slli	t4,t3,0x10
    2528:	410edb13          	srai	s6,t4,0x10
    252c:	010b1313          	slli	t1,s6,0x10
    2530:	00760833          	add	a6,a2,t2
    2534:	01035f13          	srli	t5,t1,0x10
    2538:	ed094ce3          	blt	s2,a6,2410 <matrix_test+0xa60>
    253c:	00772733          	slt	a4,a4,t2
    2540:	0186a583          	lw	a1,24(a3)
    2544:	00ef08b3          	add	a7,t5,a4
    2548:	01089093          	slli	ra,a7,0x10
    254c:	4100d613          	srai	a2,ra,0x10
    2550:	01061e93          	slli	t4,a2,0x10
    2554:	00b80633          	add	a2,a6,a1
    2558:	010edb13          	srli	s6,t4,0x10
    255c:	ecc94ce3          	blt	s2,a2,2434 <matrix_test+0xa84>
    2560:	00b3a7b3          	slt	a5,t2,a1
    2564:	00fb03b3          	add	t2,s6,a5
    2568:	01039313          	slli	t1,t2,0x10
    256c:	41035513          	srai	a0,t1,0x10
    2570:	ed5ff06f          	j	2444 <matrix_test+0xa94>
    2574:	00bf28b3          	slt	a7,t5,a1
    2578:	011700b3          	add	ra,a4,a7
    257c:	01009513          	slli	a0,ra,0x10
    2580:	41055513          	srai	a0,a0,0x10
    2584:	d95ff06f          	j	2318 <matrix_test+0x968>
    2588:	00b0aeb3          	slt	t4,ra,a1
    258c:	01de0b33          	add	s6,t3,t4
    2590:	010b1793          	slli	a5,s6,0x10
    2594:	4107d513          	srai	a0,a5,0x10
    2598:	d55ff06f          	j	22ec <matrix_test+0x93c>
    259c:	00b7af33          	slt	t5,a5,a1
    25a0:	01e30833          	add	a6,t1,t5
    25a4:	01081713          	slli	a4,a6,0x10
    25a8:	41075513          	srai	a0,a4,0x10
    25ac:	d15ff06f          	j	22c0 <matrix_test+0x910>
    25b0:	00b82533          	slt	a0,a6,a1
    25b4:	00a880b3          	add	ra,a7,a0
    25b8:	01009e13          	slli	t3,ra,0x10
    25bc:	410e5513          	srai	a0,t3,0x10
    25c0:	cd5ff06f          	j	2294 <matrix_test+0x8e4>
    25c4:	00be27b3          	slt	a5,t3,a1
    25c8:	00fb03b3          	add	t2,s6,a5
    25cc:	01039313          	slli	t1,t2,0x10
    25d0:	41035513          	srai	a0,t1,0x10
    25d4:	c95ff06f          	j	2268 <matrix_test+0x8b8>
    25d8:	00b3a833          	slt	a6,t2,a1
    25dc:	010f0733          	add	a4,t5,a6
    25e0:	01071893          	slli	a7,a4,0x10
    25e4:	4108d513          	srai	a0,a7,0x10
    25e8:	c55ff06f          	j	223c <matrix_test+0x88c>
    25ec:	00048593          	mv	a1,s1
    25f0:	590030ef          	jal	ra,5b80 <crc16>
    25f4:	000c8693          	mv	a3,s9
    25f8:	000d0593          	mv	a1,s10
    25fc:	00050493          	mv	s1,a0
    2600:	00040613          	mv	a2,s0
    2604:	000b0513          	mv	a0,s6
    2608:	090020ef          	jal	ra,4698 <matrix_mul_matrix>
    260c:	000a0693          	mv	a3,s4
    2610:	00000793          	li	a5,0
    2614:	00000813          	li	a6,0
    2618:	00000513          	li	a0,0
    261c:	00000593          	li	a1,0
    2620:	01768db3          	add	s11,a3,s7
    2624:	41b682b3          	sub	t0,a3,s11
    2628:	ffc28f93          	addi	t6,t0,-4
    262c:	002fd713          	srli	a4,t6,0x2
    2630:	00170893          	addi	a7,a4,1
    2634:	0078f093          	andi	ra,a7,7
    2638:	000d8713          	mv	a4,s11
    263c:	28008c63          	beqz	ra,28d4 <matrix_test+0xf24>
    2640:	00100e13          	li	t3,1
    2644:	13c08a63          	beq	ra,t3,2778 <matrix_test+0xdc8>
    2648:	00200e93          	li	t4,2
    264c:	11d08063          	beq	ra,t4,274c <matrix_test+0xd9c>
    2650:	00300613          	li	a2,3
    2654:	0cc08663          	beq	ra,a2,2720 <matrix_test+0xd70>
    2658:	00400393          	li	t2,4
    265c:	08708c63          	beq	ra,t2,26f4 <matrix_test+0xd44>
    2660:	00500313          	li	t1,5
    2664:	06608263          	beq	ra,t1,26c8 <matrix_test+0xd18>
    2668:	00600f13          	li	t5,6
    266c:	03e08863          	beq	ra,t5,269c <matrix_test+0xcec>
    2670:	00080293          	mv	t0,a6
    2674:	000da803          	lw	a6,0(s11)
    2678:	01079793          	slli	a5,a5,0x10
    267c:	0107df93          	srli	t6,a5,0x10
    2680:	01050533          	add	a0,a0,a6
    2684:	2ca952e3          	bge	s2,a0,3148 <matrix_test+0x1798>
    2688:	00af8513          	addi	a0,t6,10
    268c:	01051e13          	slli	t3,a0,0x10
    2690:	410e5793          	srai	a5,t3,0x10
    2694:	00000513          	li	a0,0
    2698:	004d8713          	addi	a4,s11,4
    269c:	00080e93          	mv	t4,a6
    26a0:	00072803          	lw	a6,0(a4)
    26a4:	01079613          	slli	a2,a5,0x10
    26a8:	01065393          	srli	t2,a2,0x10
    26ac:	01050533          	add	a0,a0,a6
    26b0:	3aa95863          	bge	s2,a0,2a60 <matrix_test+0x10b0>
    26b4:	00a38793          	addi	a5,t2,10
    26b8:	01079f93          	slli	t6,a5,0x10
    26bc:	410fd793          	srai	a5,t6,0x10
    26c0:	00000513          	li	a0,0
    26c4:	00470713          	addi	a4,a4,4
    26c8:	00080893          	mv	a7,a6
    26cc:	00072803          	lw	a6,0(a4)
    26d0:	01079093          	slli	ra,a5,0x10
    26d4:	0100de13          	srli	t3,ra,0x10
    26d8:	01050533          	add	a0,a0,a6
    26dc:	36a95863          	bge	s2,a0,2a4c <matrix_test+0x109c>
    26e0:	00ae0513          	addi	a0,t3,10
    26e4:	01051313          	slli	t1,a0,0x10
    26e8:	41035793          	srai	a5,t1,0x10
    26ec:	00000513          	li	a0,0
    26f0:	00470713          	addi	a4,a4,4
    26f4:	00080f13          	mv	t5,a6
    26f8:	00072803          	lw	a6,0(a4)
    26fc:	01079293          	slli	t0,a5,0x10
    2700:	0102d793          	srli	a5,t0,0x10
    2704:	01050533          	add	a0,a0,a6
    2708:	32a95863          	bge	s2,a0,2a38 <matrix_test+0x1088>
    270c:	00a78e13          	addi	t3,a5,10
    2710:	010e1e93          	slli	t4,t3,0x10
    2714:	410ed793          	srai	a5,t4,0x10
    2718:	00000513          	li	a0,0
    271c:	00470713          	addi	a4,a4,4
    2720:	00080613          	mv	a2,a6
    2724:	00072803          	lw	a6,0(a4)
    2728:	01079393          	slli	t2,a5,0x10
    272c:	0103d313          	srli	t1,t2,0x10
    2730:	01050533          	add	a0,a0,a6
    2734:	2ea95863          	bge	s2,a0,2a24 <matrix_test+0x1074>
    2738:	00a30513          	addi	a0,t1,10
    273c:	01051f93          	slli	t6,a0,0x10
    2740:	410fd793          	srai	a5,t6,0x10
    2744:	00000513          	li	a0,0
    2748:	00470713          	addi	a4,a4,4
    274c:	00080893          	mv	a7,a6
    2750:	00072803          	lw	a6,0(a4)
    2754:	01079093          	slli	ra,a5,0x10
    2758:	0100de13          	srli	t3,ra,0x10
    275c:	01050533          	add	a0,a0,a6
    2760:	2aa95863          	bge	s2,a0,2a10 <matrix_test+0x1060>
    2764:	00ae0313          	addi	t1,t3,10
    2768:	01031f13          	slli	t5,t1,0x10
    276c:	410f5793          	srai	a5,t5,0x10
    2770:	00000513          	li	a0,0
    2774:	00470713          	addi	a4,a4,4
    2778:	00080293          	mv	t0,a6
    277c:	00072803          	lw	a6,0(a4)
    2780:	01079793          	slli	a5,a5,0x10
    2784:	0107df93          	srli	t6,a5,0x10
    2788:	01050533          	add	a0,a0,a6
    278c:	26a95863          	bge	s2,a0,29fc <matrix_test+0x104c>
    2790:	00af8513          	addi	a0,t6,10
    2794:	01051e93          	slli	t4,a0,0x10
    2798:	410ed793          	srai	a5,t4,0x10
    279c:	00000513          	li	a0,0
    27a0:	00470713          	addi	a4,a4,4
    27a4:	12e69863          	bne	a3,a4,28d4 <matrix_test+0xf24>
    27a8:	00158313          	addi	t1,a1,1
    27ac:	418d86b3          	sub	a3,s11,s8
    27b0:	2d558263          	beq	a1,s5,2a74 <matrix_test+0x10c4>
    27b4:	00030593          	mv	a1,t1
    27b8:	e69ff06f          	j	2620 <matrix_test+0xc70>
    27bc:	00c82833          	slt	a6,a6,a2
    27c0:	00472e03          	lw	t3,4(a4)
    27c4:	01030f33          	add	t5,t1,a6
    27c8:	010f1293          	slli	t0,t5,0x10
    27cc:	4102d893          	srai	a7,t0,0x10
    27d0:	01089513          	slli	a0,a7,0x10
    27d4:	01c083b3          	add	t2,ra,t3
    27d8:	00470713          	addi	a4,a4,4
    27dc:	01055e93          	srli	t4,a0,0x10
    27e0:	12795863          	bge	s2,t2,2910 <matrix_test+0xf60>
    27e4:	00472f83          	lw	t6,4(a4)
    27e8:	00ae8293          	addi	t0,t4,10
    27ec:	01029793          	slli	a5,t0,0x10
    27f0:	4107df13          	srai	t5,a5,0x10
    27f4:	00000393          	li	t2,0
    27f8:	010f1893          	slli	a7,t5,0x10
    27fc:	01f38533          	add	a0,t2,t6
    2800:	0108d093          	srli	ra,a7,0x10
    2804:	12a95863          	bge	s2,a0,2934 <matrix_test+0xf84>
    2808:	00a08313          	addi	t1,ra,10
    280c:	00872f03          	lw	t5,8(a4)
    2810:	01031813          	slli	a6,t1,0x10
    2814:	41085613          	srai	a2,a6,0x10
    2818:	00000513          	li	a0,0
    281c:	01061293          	slli	t0,a2,0x10
    2820:	01e500b3          	add	ra,a0,t5
    2824:	0102d793          	srli	a5,t0,0x10
    2828:	12195863          	bge	s2,ra,2958 <matrix_test+0xfa8>
    282c:	00c72603          	lw	a2,12(a4)
    2830:	00a78e93          	addi	t4,a5,10
    2834:	010e9393          	slli	t2,t4,0x10
    2838:	4103de13          	srai	t3,t2,0x10
    283c:	00000093          	li	ra,0
    2840:	010e1313          	slli	t1,t3,0x10
    2844:	00c080b3          	add	ra,ra,a2
    2848:	01035293          	srli	t0,t1,0x10
    284c:	12195863          	bge	s2,ra,297c <matrix_test+0xfcc>
    2850:	01072e03          	lw	t3,16(a4)
    2854:	00a28893          	addi	a7,t0,10
    2858:	01089513          	slli	a0,a7,0x10
    285c:	41055f93          	srai	t6,a0,0x10
    2860:	00000093          	li	ra,0
    2864:	010f9e93          	slli	t4,t6,0x10
    2868:	01c08333          	add	t1,ra,t3
    286c:	010ed393          	srli	t2,t4,0x10
    2870:	12695863          	bge	s2,t1,29a0 <matrix_test+0xff0>
    2874:	01472f83          	lw	t6,20(a4)
    2878:	00a38f13          	addi	t5,t2,10
    287c:	010f1793          	slli	a5,t5,0x10
    2880:	4107d813          	srai	a6,a5,0x10
    2884:	00000313          	li	t1,0
    2888:	01081893          	slli	a7,a6,0x10
    288c:	01f30533          	add	a0,t1,t6
    2890:	0108de93          	srli	t4,a7,0x10
    2894:	12a95863          	bge	s2,a0,29c4 <matrix_test+0x1014>
    2898:	01872803          	lw	a6,24(a4)
    289c:	00ae8293          	addi	t0,t4,10
    28a0:	01029093          	slli	ra,t0,0x10
    28a4:	4100d613          	srai	a2,ra,0x10
    28a8:	00000513          	li	a0,0
    28ac:	01061f13          	slli	t5,a2,0x10
    28b0:	01050533          	add	a0,a0,a6
    28b4:	010f5793          	srli	a5,t5,0x10
    28b8:	12a95863          	bge	s2,a0,29e8 <matrix_test+0x1038>
    28bc:	00a78e13          	addi	t3,a5,10
    28c0:	010e1393          	slli	t2,t3,0x10
    28c4:	4103d793          	srai	a5,t2,0x10
    28c8:	00000513          	li	a0,0
    28cc:	01c70713          	addi	a4,a4,28
    28d0:	ece68ce3          	beq	a3,a4,27a8 <matrix_test+0xdf8>
    28d4:	00072603          	lw	a2,0(a4)
    28d8:	01079393          	slli	t2,a5,0x10
    28dc:	0103d313          	srli	t1,t2,0x10
    28e0:	00c500b3          	add	ra,a0,a2
    28e4:	ec195ce3          	bge	s2,ra,27bc <matrix_test+0xe0c>
    28e8:	00472e03          	lw	t3,4(a4)
    28ec:	00a30793          	addi	a5,t1,10
    28f0:	01079f93          	slli	t6,a5,0x10
    28f4:	410fd893          	srai	a7,t6,0x10
    28f8:	00000093          	li	ra,0
    28fc:	01089513          	slli	a0,a7,0x10
    2900:	01c083b3          	add	t2,ra,t3
    2904:	00470713          	addi	a4,a4,4
    2908:	01055e93          	srli	t4,a0,0x10
    290c:	ec794ce3          	blt	s2,t2,27e4 <matrix_test+0xe34>
    2910:	01c62633          	slt	a2,a2,t3
    2914:	00472f83          	lw	t6,4(a4)
    2918:	00ce8333          	add	t1,t4,a2
    291c:	01031813          	slli	a6,t1,0x10
    2920:	41085f13          	srai	t5,a6,0x10
    2924:	010f1893          	slli	a7,t5,0x10
    2928:	01f38533          	add	a0,t2,t6
    292c:	0108d093          	srli	ra,a7,0x10
    2930:	eca94ce3          	blt	s2,a0,2808 <matrix_test+0xe58>
    2934:	01fe2e33          	slt	t3,t3,t6
    2938:	01c08eb3          	add	t4,ra,t3
    293c:	00872f03          	lw	t5,8(a4)
    2940:	010e9393          	slli	t2,t4,0x10
    2944:	4103d613          	srai	a2,t2,0x10
    2948:	01061293          	slli	t0,a2,0x10
    294c:	01e500b3          	add	ra,a0,t5
    2950:	0102d793          	srli	a5,t0,0x10
    2954:	ec194ce3          	blt	s2,ra,282c <matrix_test+0xe7c>
    2958:	01efafb3          	slt	t6,t6,t5
    295c:	00c72603          	lw	a2,12(a4)
    2960:	01f788b3          	add	a7,a5,t6
    2964:	01089513          	slli	a0,a7,0x10
    2968:	41055e13          	srai	t3,a0,0x10
    296c:	010e1313          	slli	t1,t3,0x10
    2970:	00c080b3          	add	ra,ra,a2
    2974:	01035293          	srli	t0,t1,0x10
    2978:	ec194ce3          	blt	s2,ra,2850 <matrix_test+0xea0>
    297c:	00cf2833          	slt	a6,t5,a2
    2980:	01072e03          	lw	t3,16(a4)
    2984:	01028f33          	add	t5,t0,a6
    2988:	010f1793          	slli	a5,t5,0x10
    298c:	4107df93          	srai	t6,a5,0x10
    2990:	010f9e93          	slli	t4,t6,0x10
    2994:	01c08333          	add	t1,ra,t3
    2998:	010ed393          	srli	t2,t4,0x10
    299c:	ec694ce3          	blt	s2,t1,2874 <matrix_test+0xec4>
    29a0:	01c62633          	slt	a2,a2,t3
    29a4:	01472f83          	lw	t6,20(a4)
    29a8:	00c382b3          	add	t0,t2,a2
    29ac:	01029093          	slli	ra,t0,0x10
    29b0:	4100d813          	srai	a6,ra,0x10
    29b4:	01081893          	slli	a7,a6,0x10
    29b8:	01f30533          	add	a0,t1,t6
    29bc:	0108de93          	srli	t4,a7,0x10
    29c0:	eca94ce3          	blt	s2,a0,2898 <matrix_test+0xee8>
    29c4:	01fe2e33          	slt	t3,t3,t6
    29c8:	01872803          	lw	a6,24(a4)
    29cc:	01ce83b3          	add	t2,t4,t3
    29d0:	01039313          	slli	t1,t2,0x10
    29d4:	41035613          	srai	a2,t1,0x10
    29d8:	01061f13          	slli	t5,a2,0x10
    29dc:	01050533          	add	a0,a0,a6
    29e0:	010f5793          	srli	a5,t5,0x10
    29e4:	eca94ce3          	blt	s2,a0,28bc <matrix_test+0xf0c>
    29e8:	010fafb3          	slt	t6,t6,a6
    29ec:	01f788b3          	add	a7,a5,t6
    29f0:	01089e93          	slli	t4,a7,0x10
    29f4:	410ed793          	srai	a5,t4,0x10
    29f8:	ed5ff06f          	j	28cc <matrix_test+0xf1c>
    29fc:	0102a8b3          	slt	a7,t0,a6
    2a00:	011f80b3          	add	ra,t6,a7
    2a04:	01009e13          	slli	t3,ra,0x10
    2a08:	410e5793          	srai	a5,t3,0x10
    2a0c:	d95ff06f          	j	27a0 <matrix_test+0xdf0>
    2a10:	0108aeb3          	slt	t4,a7,a6
    2a14:	01de0633          	add	a2,t3,t4
    2a18:	01061393          	slli	t2,a2,0x10
    2a1c:	4103d793          	srai	a5,t2,0x10
    2a20:	d55ff06f          	j	2774 <matrix_test+0xdc4>
    2a24:	01062f33          	slt	t5,a2,a6
    2a28:	01e302b3          	add	t0,t1,t5
    2a2c:	01029793          	slli	a5,t0,0x10
    2a30:	4107d793          	srai	a5,a5,0x10
    2a34:	d15ff06f          	j	2748 <matrix_test+0xd98>
    2a38:	010f2fb3          	slt	t6,t5,a6
    2a3c:	01f788b3          	add	a7,a5,t6
    2a40:	01089093          	slli	ra,a7,0x10
    2a44:	4100d793          	srai	a5,ra,0x10
    2a48:	cd5ff06f          	j	271c <matrix_test+0xd6c>
    2a4c:	0108aeb3          	slt	t4,a7,a6
    2a50:	01de0633          	add	a2,t3,t4
    2a54:	01061393          	slli	t2,a2,0x10
    2a58:	4103d793          	srai	a5,t2,0x10
    2a5c:	c95ff06f          	j	26f0 <matrix_test+0xd40>
    2a60:	010ea333          	slt	t1,t4,a6
    2a64:	00638f33          	add	t5,t2,t1
    2a68:	010f1293          	slli	t0,t5,0x10
    2a6c:	4102d793          	srai	a5,t0,0x10
    2a70:	c55ff06f          	j	26c4 <matrix_test+0xd14>
    2a74:	00048593          	mv	a1,s1
    2a78:	00078513          	mv	a0,a5
    2a7c:	104030ef          	jal	ra,5b80 <crc16>
    2a80:	000c8693          	mv	a3,s9
    2a84:	000d0593          	mv	a1,s10
    2a88:	00050493          	mv	s1,a0
    2a8c:	00040613          	mv	a2,s0
    2a90:	000b0513          	mv	a0,s6
    2a94:	689010ef          	jal	ra,491c <matrix_mul_matrix_bitextract>
    2a98:	00000513          	li	a0,0
    2a9c:	00000813          	li	a6,0
    2aa0:	00000593          	li	a1,0
    2aa4:	00000693          	li	a3,0
    2aa8:	017a0cb3          	add	s9,s4,s7
    2aac:	419a0d33          	sub	s10,s4,s9
    2ab0:	ffcd0d93          	addi	s11,s10,-4
    2ab4:	002dd613          	srli	a2,s11,0x2
    2ab8:	00160293          	addi	t0,a2,1
    2abc:	0072f093          	andi	ra,t0,7
    2ac0:	000c8613          	mv	a2,s9
    2ac4:	28008c63          	beqz	ra,2d5c <matrix_test+0x13ac>
    2ac8:	00100f13          	li	t5,1
    2acc:	13e08a63          	beq	ra,t5,2c00 <matrix_test+0x1250>
    2ad0:	00200f93          	li	t6,2
    2ad4:	11f08063          	beq	ra,t6,2bd4 <matrix_test+0x1224>
    2ad8:	00300893          	li	a7,3
    2adc:	0d108663          	beq	ra,a7,2ba8 <matrix_test+0x11f8>
    2ae0:	00400e93          	li	t4,4
    2ae4:	09d08c63          	beq	ra,t4,2b7c <matrix_test+0x11cc>
    2ae8:	00500793          	li	a5,5
    2aec:	06f08263          	beq	ra,a5,2b50 <matrix_test+0x11a0>
    2af0:	00600e13          	li	t3,6
    2af4:	03c08863          	beq	ra,t3,2b24 <matrix_test+0x1174>
    2af8:	00080393          	mv	t2,a6
    2afc:	000ca803          	lw	a6,0(s9)
    2b00:	01051513          	slli	a0,a0,0x10
    2b04:	01055713          	srli	a4,a0,0x10
    2b08:	010585b3          	add	a1,a1,a6
    2b0c:	60b95063          	bge	s2,a1,310c <matrix_test+0x175c>
    2b10:	00a70593          	addi	a1,a4,10
    2b14:	01059613          	slli	a2,a1,0x10
    2b18:	41065513          	srai	a0,a2,0x10
    2b1c:	00000593          	li	a1,0
    2b20:	004c8613          	addi	a2,s9,4
    2b24:	00080293          	mv	t0,a6
    2b28:	00062803          	lw	a6,0(a2)
    2b2c:	01051093          	slli	ra,a0,0x10
    2b30:	0100df13          	srli	t5,ra,0x10
    2b34:	010585b3          	add	a1,a1,a6
    2b38:	3ab95863          	bge	s2,a1,2ee8 <matrix_test+0x1538>
    2b3c:	00af0793          	addi	a5,t5,10
    2b40:	01079e13          	slli	t3,a5,0x10
    2b44:	410e5513          	srai	a0,t3,0x10
    2b48:	00000593          	li	a1,0
    2b4c:	00460613          	addi	a2,a2,4
    2b50:	00080393          	mv	t2,a6
    2b54:	00062803          	lw	a6,0(a2)
    2b58:	01051513          	slli	a0,a0,0x10
    2b5c:	01055713          	srli	a4,a0,0x10
    2b60:	010585b3          	add	a1,a1,a6
    2b64:	36b95863          	bge	s2,a1,2ed4 <matrix_test+0x1524>
    2b68:	00a70593          	addi	a1,a4,10
    2b6c:	01059293          	slli	t0,a1,0x10
    2b70:	4102d513          	srai	a0,t0,0x10
    2b74:	00000593          	li	a1,0
    2b78:	00460613          	addi	a2,a2,4
    2b7c:	00080093          	mv	ra,a6
    2b80:	00062803          	lw	a6,0(a2)
    2b84:	01051f13          	slli	t5,a0,0x10
    2b88:	010f5f93          	srli	t6,t5,0x10
    2b8c:	010585b3          	add	a1,a1,a6
    2b90:	32b95863          	bge	s2,a1,2ec0 <matrix_test+0x1510>
    2b94:	00af8e13          	addi	t3,t6,10
    2b98:	010e1393          	slli	t2,t3,0x10
    2b9c:	4103d513          	srai	a0,t2,0x10
    2ba0:	00000593          	li	a1,0
    2ba4:	00460613          	addi	a2,a2,4
    2ba8:	00080713          	mv	a4,a6
    2bac:	00062803          	lw	a6,0(a2)
    2bb0:	01051513          	slli	a0,a0,0x10
    2bb4:	01055313          	srli	t1,a0,0x10
    2bb8:	010585b3          	add	a1,a1,a6
    2bbc:	2eb95863          	bge	s2,a1,2eac <matrix_test+0x14fc>
    2bc0:	00a30593          	addi	a1,t1,10
    2bc4:	01059093          	slli	ra,a1,0x10
    2bc8:	4100d513          	srai	a0,ra,0x10
    2bcc:	00000593          	li	a1,0
    2bd0:	00460613          	addi	a2,a2,4
    2bd4:	00080f13          	mv	t5,a6
    2bd8:	00062803          	lw	a6,0(a2)
    2bdc:	01051f93          	slli	t6,a0,0x10
    2be0:	010fd893          	srli	a7,t6,0x10
    2be4:	010585b3          	add	a1,a1,a6
    2be8:	2ab95863          	bge	s2,a1,2e98 <matrix_test+0x14e8>
    2bec:	00a88393          	addi	t2,a7,10
    2bf0:	01039713          	slli	a4,t2,0x10
    2bf4:	41075513          	srai	a0,a4,0x10
    2bf8:	00000593          	li	a1,0
    2bfc:	00460613          	addi	a2,a2,4
    2c00:	00080313          	mv	t1,a6
    2c04:	00062803          	lw	a6,0(a2)
    2c08:	01051513          	slli	a0,a0,0x10
    2c0c:	01055d13          	srli	s10,a0,0x10
    2c10:	010585b3          	add	a1,a1,a6
    2c14:	26b95863          	bge	s2,a1,2e84 <matrix_test+0x14d4>
    2c18:	00ad0593          	addi	a1,s10,10
    2c1c:	01059f13          	slli	t5,a1,0x10
    2c20:	410f5513          	srai	a0,t5,0x10
    2c24:	00000593          	li	a1,0
    2c28:	00460613          	addi	a2,a2,4
    2c2c:	12ca1863          	bne	s4,a2,2d5c <matrix_test+0x13ac>
    2c30:	00168093          	addi	ra,a3,1
    2c34:	418c8a33          	sub	s4,s9,s8
    2c38:	2d568263          	beq	a3,s5,2efc <matrix_test+0x154c>
    2c3c:	00008693          	mv	a3,ra
    2c40:	e69ff06f          	j	2aa8 <matrix_test+0x10f8>
    2c44:	01f82833          	slt	a6,a6,t6
    2c48:	00462d03          	lw	s10,4(a2)
    2c4c:	010e87b3          	add	a5,t4,a6
    2c50:	01079e13          	slli	t3,a5,0x10
    2c54:	410e5313          	srai	t1,t3,0x10
    2c58:	01031d93          	slli	s11,t1,0x10
    2c5c:	01a500b3          	add	ra,a0,s10
    2c60:	00460613          	addi	a2,a2,4
    2c64:	010dd293          	srli	t0,s11,0x10
    2c68:	12195863          	bge	s2,ra,2d98 <matrix_test+0x13e8>
    2c6c:	00462e03          	lw	t3,4(a2)
    2c70:	00a28e93          	addi	t4,t0,10
    2c74:	010e9813          	slli	a6,t4,0x10
    2c78:	41085893          	srai	a7,a6,0x10
    2c7c:	00000093          	li	ra,0
    2c80:	01089793          	slli	a5,a7,0x10
    2c84:	01c08733          	add	a4,ra,t3
    2c88:	0107d393          	srli	t2,a5,0x10
    2c8c:	12e95863          	bge	s2,a4,2dbc <matrix_test+0x140c>
    2c90:	00862f03          	lw	t5,8(a2)
    2c94:	00a38293          	addi	t0,t2,10
    2c98:	01029093          	slli	ra,t0,0x10
    2c9c:	4100dd93          	srai	s11,ra,0x10
    2ca0:	00000713          	li	a4,0
    2ca4:	010d9593          	slli	a1,s11,0x10
    2ca8:	01e708b3          	add	a7,a4,t5
    2cac:	0105df93          	srli	t6,a1,0x10
    2cb0:	13195863          	bge	s2,a7,2de0 <matrix_test+0x1430>
    2cb4:	00c62303          	lw	t1,12(a2)
    2cb8:	00af8393          	addi	t2,t6,10
    2cbc:	01039713          	slli	a4,t2,0x10
    2cc0:	41075793          	srai	a5,a4,0x10
    2cc4:	00000893          	li	a7,0
    2cc8:	01079513          	slli	a0,a5,0x10
    2ccc:	00688db3          	add	s11,a7,t1
    2cd0:	01055d13          	srli	s10,a0,0x10
    2cd4:	13b95863          	bge	s2,s11,2e04 <matrix_test+0x1454>
    2cd8:	01062e83          	lw	t4,16(a2)
    2cdc:	00ad0f93          	addi	t6,s10,10
    2ce0:	010f9893          	slli	a7,t6,0x10
    2ce4:	4108d593          	srai	a1,a7,0x10
    2ce8:	00000d93          	li	s11,0
    2cec:	01059813          	slli	a6,a1,0x10
    2cf0:	01dd83b3          	add	t2,s11,t4
    2cf4:	01085e13          	srli	t3,a6,0x10
    2cf8:	12795863          	bge	s2,t2,2e28 <matrix_test+0x1478>
    2cfc:	01462283          	lw	t0,20(a2)
    2d00:	00ae0513          	addi	a0,t3,10
    2d04:	01051d93          	slli	s11,a0,0x10
    2d08:	410ddd13          	srai	s10,s11,0x10
    2d0c:	00000393          	li	t2,0
    2d10:	010d1093          	slli	ra,s10,0x10
    2d14:	005385b3          	add	a1,t2,t0
    2d18:	0100df13          	srli	t5,ra,0x10
    2d1c:	12b95863          	bge	s2,a1,2e4c <matrix_test+0x149c>
    2d20:	00af0813          	addi	a6,t5,10
    2d24:	01081393          	slli	t2,a6,0x10
    2d28:	01862803          	lw	a6,24(a2)
    2d2c:	4103de13          	srai	t3,t2,0x10
    2d30:	00000593          	li	a1,0
    2d34:	010e1793          	slli	a5,t3,0x10
    2d38:	010585b3          	add	a1,a1,a6
    2d3c:	0107d713          	srli	a4,a5,0x10
    2d40:	12b95863          	bge	s2,a1,2e70 <matrix_test+0x14c0>
    2d44:	00a70d93          	addi	s11,a4,10
    2d48:	010d9293          	slli	t0,s11,0x10
    2d4c:	4102d513          	srai	a0,t0,0x10
    2d50:	00000593          	li	a1,0
    2d54:	01c60613          	addi	a2,a2,28
    2d58:	ecca0ce3          	beq	s4,a2,2c30 <matrix_test+0x1280>
    2d5c:	00062f83          	lw	t6,0(a2)
    2d60:	01051893          	slli	a7,a0,0x10
    2d64:	0108de93          	srli	t4,a7,0x10
    2d68:	01f58533          	add	a0,a1,t6
    2d6c:	eca95ce3          	bge	s2,a0,2c44 <matrix_test+0x1294>
    2d70:	00462d03          	lw	s10,4(a2)
    2d74:	00ae8393          	addi	t2,t4,10
    2d78:	01039713          	slli	a4,t2,0x10
    2d7c:	41075313          	srai	t1,a4,0x10
    2d80:	00000513          	li	a0,0
    2d84:	01031d93          	slli	s11,t1,0x10
    2d88:	01a500b3          	add	ra,a0,s10
    2d8c:	00460613          	addi	a2,a2,4
    2d90:	010dd293          	srli	t0,s11,0x10
    2d94:	ec194ce3          	blt	s2,ra,2c6c <matrix_test+0x12bc>
    2d98:	01afa5b3          	slt	a1,t6,s10
    2d9c:	00462e03          	lw	t3,4(a2)
    2da0:	00b28f33          	add	t5,t0,a1
    2da4:	010f1f93          	slli	t6,t5,0x10
    2da8:	410fd893          	srai	a7,t6,0x10
    2dac:	01089793          	slli	a5,a7,0x10
    2db0:	01c08733          	add	a4,ra,t3
    2db4:	0107d393          	srli	t2,a5,0x10
    2db8:	ece94ce3          	blt	s2,a4,2c90 <matrix_test+0x12e0>
    2dbc:	01cd2333          	slt	t1,s10,t3
    2dc0:	00862f03          	lw	t5,8(a2)
    2dc4:	00638533          	add	a0,t2,t1
    2dc8:	01051d13          	slli	s10,a0,0x10
    2dcc:	410d5d93          	srai	s11,s10,0x10
    2dd0:	010d9593          	slli	a1,s11,0x10
    2dd4:	01e708b3          	add	a7,a4,t5
    2dd8:	0105df93          	srli	t6,a1,0x10
    2ddc:	ed194ce3          	blt	s2,a7,2cb4 <matrix_test+0x1304>
    2de0:	01ee2eb3          	slt	t4,t3,t5
    2de4:	00c62303          	lw	t1,12(a2)
    2de8:	01df8833          	add	a6,t6,t4
    2dec:	01081e13          	slli	t3,a6,0x10
    2df0:	410e5793          	srai	a5,t3,0x10
    2df4:	01079513          	slli	a0,a5,0x10
    2df8:	00688db3          	add	s11,a7,t1
    2dfc:	01055d13          	srli	s10,a0,0x10
    2e00:	edb94ce3          	blt	s2,s11,2cd8 <matrix_test+0x1328>
    2e04:	006f22b3          	slt	t0,t5,t1
    2e08:	01062e83          	lw	t4,16(a2)
    2e0c:	005d00b3          	add	ra,s10,t0
    2e10:	01009f13          	slli	t5,ra,0x10
    2e14:	410f5593          	srai	a1,t5,0x10
    2e18:	01059813          	slli	a6,a1,0x10
    2e1c:	01dd83b3          	add	t2,s11,t4
    2e20:	01085e13          	srli	t3,a6,0x10
    2e24:	ec794ce3          	blt	s2,t2,2cfc <matrix_test+0x134c>
    2e28:	01d327b3          	slt	a5,t1,t4
    2e2c:	01462283          	lw	t0,20(a2)
    2e30:	00fe0733          	add	a4,t3,a5
    2e34:	01071313          	slli	t1,a4,0x10
    2e38:	41035d13          	srai	s10,t1,0x10
    2e3c:	010d1093          	slli	ra,s10,0x10
    2e40:	005385b3          	add	a1,t2,t0
    2e44:	0100df13          	srli	t5,ra,0x10
    2e48:	ecb94ce3          	blt	s2,a1,2d20 <matrix_test+0x1370>
    2e4c:	005eafb3          	slt	t6,t4,t0
    2e50:	01862803          	lw	a6,24(a2)
    2e54:	01ff08b3          	add	a7,t5,t6
    2e58:	01089e93          	slli	t4,a7,0x10
    2e5c:	410ede13          	srai	t3,t4,0x10
    2e60:	010e1793          	slli	a5,t3,0x10
    2e64:	010585b3          	add	a1,a1,a6
    2e68:	0107d713          	srli	a4,a5,0x10
    2e6c:	ecb94ce3          	blt	s2,a1,2d44 <matrix_test+0x1394>
    2e70:	0102a333          	slt	t1,t0,a6
    2e74:	00670d33          	add	s10,a4,t1
    2e78:	010d1513          	slli	a0,s10,0x10
    2e7c:	41055513          	srai	a0,a0,0x10
    2e80:	ed5ff06f          	j	2d54 <matrix_test+0x13a4>
    2e84:	01032db3          	slt	s11,t1,a6
    2e88:	01bd02b3          	add	t0,s10,s11
    2e8c:	01029093          	slli	ra,t0,0x10
    2e90:	4100d513          	srai	a0,ra,0x10
    2e94:	d95ff06f          	j	2c28 <matrix_test+0x1278>
    2e98:	010f2eb3          	slt	t4,t5,a6
    2e9c:	01d887b3          	add	a5,a7,t4
    2ea0:	01079e13          	slli	t3,a5,0x10
    2ea4:	410e5513          	srai	a0,t3,0x10
    2ea8:	d55ff06f          	j	2bfc <matrix_test+0x124c>
    2eac:	01072d33          	slt	s10,a4,a6
    2eb0:	01a30db3          	add	s11,t1,s10
    2eb4:	010d9293          	slli	t0,s11,0x10
    2eb8:	4102d513          	srai	a0,t0,0x10
    2ebc:	d15ff06f          	j	2bd0 <matrix_test+0x1220>
    2ec0:	0100a8b3          	slt	a7,ra,a6
    2ec4:	011f8eb3          	add	t4,t6,a7
    2ec8:	010e9793          	slli	a5,t4,0x10
    2ecc:	4107d513          	srai	a0,a5,0x10
    2ed0:	cd5ff06f          	j	2ba4 <matrix_test+0x11f4>
    2ed4:	0103a333          	slt	t1,t2,a6
    2ed8:	00670d33          	add	s10,a4,t1
    2edc:	010d1d93          	slli	s11,s10,0x10
    2ee0:	410dd513          	srai	a0,s11,0x10
    2ee4:	c95ff06f          	j	2b78 <matrix_test+0x11c8>
    2ee8:	0102afb3          	slt	t6,t0,a6
    2eec:	01ff08b3          	add	a7,t5,t6
    2ef0:	01089e93          	slli	t4,a7,0x10
    2ef4:	410ed513          	srai	a0,t4,0x10
    2ef8:	c55ff06f          	j	2b4c <matrix_test+0x119c>
    2efc:	00048593          	mv	a1,s1
    2f00:	481020ef          	jal	ra,5b80 <crc16>
    2f04:	001b1b13          	slli	s6,s6,0x1
    2f08:	01640433          	add	s0,s0,s6
    2f0c:	00000e93          	li	t4,0
    2f10:	41640933          	sub	s2,s0,s6
    2f14:	41240a33          	sub	s4,s0,s2
    2f18:	ffea0c13          	addi	s8,s4,-2
    2f1c:	001c5693          	srli	a3,s8,0x1
    2f20:	00168c93          	addi	s9,a3,1
    2f24:	007cff13          	andi	t5,s9,7
    2f28:	00090793          	mv	a5,s2
    2f2c:	0a0f0463          	beqz	t5,2fd4 <matrix_test+0x1624>
    2f30:	00100f93          	li	t6,1
    2f34:	09ff0663          	beq	t5,t6,2fc0 <matrix_test+0x1610>
    2f38:	00200893          	li	a7,2
    2f3c:	071f0a63          	beq	t5,a7,2fb0 <matrix_test+0x1600>
    2f40:	00300e13          	li	t3,3
    2f44:	05cf0e63          	beq	t5,t3,2fa0 <matrix_test+0x15f0>
    2f48:	00400393          	li	t2,4
    2f4c:	047f0263          	beq	t5,t2,2f90 <matrix_test+0x15e0>
    2f50:	00500813          	li	a6,5
    2f54:	030f0663          	beq	t5,a6,2f80 <matrix_test+0x15d0>
    2f58:	00600713          	li	a4,6
    2f5c:	00ef0a63          	beq	t5,a4,2f70 <matrix_test+0x15c0>
    2f60:	00095583          	lhu	a1,0(s2)
    2f64:	00290793          	addi	a5,s2,2
    2f68:	41358333          	sub	t1,a1,s3
    2f6c:	00691023          	sh	t1,0(s2)
    2f70:	0007dd03          	lhu	s10,0(a5)
    2f74:	00278793          	addi	a5,a5,2
    2f78:	413d0db3          	sub	s11,s10,s3
    2f7c:	ffb79f23          	sh	s11,-2(a5)
    2f80:	0007d283          	lhu	t0,0(a5)
    2f84:	00278793          	addi	a5,a5,2
    2f88:	41328633          	sub	a2,t0,s3
    2f8c:	fec79f23          	sh	a2,-2(a5)
    2f90:	0007d483          	lhu	s1,0(a5)
    2f94:	00278793          	addi	a5,a5,2
    2f98:	413480b3          	sub	ra,s1,s3
    2f9c:	fe179f23          	sh	ra,-2(a5)
    2fa0:	0007da03          	lhu	s4,0(a5)
    2fa4:	00278793          	addi	a5,a5,2
    2fa8:	413a0c33          	sub	s8,s4,s3
    2fac:	ff879f23          	sh	s8,-2(a5)
    2fb0:	0007d683          	lhu	a3,0(a5)
    2fb4:	00278793          	addi	a5,a5,2
    2fb8:	41368cb3          	sub	s9,a3,s3
    2fbc:	ff979f23          	sh	s9,-2(a5)
    2fc0:	0007df03          	lhu	t5,0(a5)
    2fc4:	00278793          	addi	a5,a5,2
    2fc8:	413f0fb3          	sub	t6,t5,s3
    2fcc:	fff79f23          	sh	t6,-2(a5)
    2fd0:	06878663          	beq	a5,s0,303c <matrix_test+0x168c>
    2fd4:	0007d383          	lhu	t2,0(a5)
    2fd8:	0027de03          	lhu	t3,2(a5)
    2fdc:	0047d303          	lhu	t1,4(a5)
    2fe0:	0067d883          	lhu	a7,6(a5)
    2fe4:	0087d803          	lhu	a6,8(a5)
    2fe8:	00a7d583          	lhu	a1,10(a5)
    2fec:	00c7dd03          	lhu	s10,12(a5)
    2ff0:	00e7d703          	lhu	a4,14(a5)
    2ff4:	41338db3          	sub	s11,t2,s3
    2ff8:	413e02b3          	sub	t0,t3,s3
    2ffc:	413304b3          	sub	s1,t1,s3
    3000:	413880b3          	sub	ra,a7,s3
    3004:	41380a33          	sub	s4,a6,s3
    3008:	41358c33          	sub	s8,a1,s3
    300c:	413d0633          	sub	a2,s10,s3
    3010:	413706b3          	sub	a3,a4,s3
    3014:	01b79023          	sh	s11,0(a5)
    3018:	00579123          	sh	t0,2(a5)
    301c:	00979223          	sh	s1,4(a5)
    3020:	00179323          	sh	ra,6(a5)
    3024:	01479423          	sh	s4,8(a5)
    3028:	01879523          	sh	s8,10(a5)
    302c:	00c79623          	sh	a2,12(a5)
    3030:	00d79723          	sh	a3,14(a5)
    3034:	01078793          	addi	a5,a5,16
    3038:	f8879ee3          	bne	a5,s0,2fd4 <matrix_test+0x1624>
    303c:	001e8c93          	addi	s9,t4,1
    3040:	41790433          	sub	s0,s2,s7
    3044:	095e8263          	beq	t4,s5,30c8 <matrix_test+0x1718>
    3048:	000c8e93          	mv	t4,s9
    304c:	ec5ff06f          	j	2f10 <matrix_test+0x1560>
    3050:	00000593          	li	a1,0
    3054:	32d020ef          	jal	ra,5b80 <crc16>
    3058:	00040613          	mv	a2,s0
    305c:	000c8693          	mv	a3,s9
    3060:	00050493          	mv	s1,a0
    3064:	000d0593          	mv	a1,s10
    3068:	00000513          	li	a0,0
    306c:	414010ef          	jal	ra,4480 <matrix_mul_vect>
    3070:	00048593          	mv	a1,s1
    3074:	00000513          	li	a0,0
    3078:	309020ef          	jal	ra,5b80 <crc16>
    307c:	00040613          	mv	a2,s0
    3080:	000c8693          	mv	a3,s9
    3084:	00050913          	mv	s2,a0
    3088:	000d0593          	mv	a1,s10
    308c:	00000513          	li	a0,0
    3090:	608010ef          	jal	ra,4698 <matrix_mul_matrix>
    3094:	00090593          	mv	a1,s2
    3098:	00000513          	li	a0,0
    309c:	2e5020ef          	jal	ra,5b80 <crc16>
    30a0:	00050793          	mv	a5,a0
    30a4:	00040613          	mv	a2,s0
    30a8:	00000513          	li	a0,0
    30ac:	000d0593          	mv	a1,s10
    30b0:	000c8693          	mv	a3,s9
    30b4:	00078413          	mv	s0,a5
    30b8:	065010ef          	jal	ra,491c <matrix_mul_matrix_bitextract>
    30bc:	00040593          	mv	a1,s0
    30c0:	00000513          	li	a0,0
    30c4:	2bd020ef          	jal	ra,5b80 <crc16>
    30c8:	03c12083          	lw	ra,60(sp)
    30cc:	03812403          	lw	s0,56(sp)
    30d0:	01051993          	slli	s3,a0,0x10
    30d4:	03412483          	lw	s1,52(sp)
    30d8:	03012903          	lw	s2,48(sp)
    30dc:	02812a03          	lw	s4,40(sp)
    30e0:	02412a83          	lw	s5,36(sp)
    30e4:	02012b03          	lw	s6,32(sp)
    30e8:	01c12b83          	lw	s7,28(sp)
    30ec:	01812c03          	lw	s8,24(sp)
    30f0:	01412c83          	lw	s9,20(sp)
    30f4:	01012d03          	lw	s10,16(sp)
    30f8:	00c12d83          	lw	s11,12(sp)
    30fc:	4109d513          	srai	a0,s3,0x10
    3100:	02c12983          	lw	s3,44(sp)
    3104:	04010113          	addi	sp,sp,64
    3108:	00008067          	ret
    310c:	0103a333          	slt	t1,t2,a6
    3110:	00670d33          	add	s10,a4,t1
    3114:	010d1d93          	slli	s11,s10,0x10
    3118:	410dd513          	srai	a0,s11,0x10
    311c:	a05ff06f          	j	2b20 <matrix_test+0x1170>
    3120:	01c0a333          	slt	t1,ra,t3
    3124:	006e8633          	add	a2,t4,t1
    3128:	01061a13          	slli	s4,a2,0x10
    312c:	410a5793          	srai	a5,s4,0x10
    3130:	c45fe06f          	j	1d74 <matrix_test+0x3c4>
    3134:	00b6ae33          	slt	t3,a3,a1
    3138:	01c08eb3          	add	t4,ra,t3
    313c:	010e9b13          	slli	s6,t4,0x10
    3140:	410b5513          	srai	a0,s6,0x10
    3144:	8ccff06f          	j	2210 <matrix_test+0x860>
    3148:	0102a733          	slt	a4,t0,a6
    314c:	00ef88b3          	add	a7,t6,a4
    3150:	01089093          	slli	ra,a7,0x10
    3154:	4100d793          	srai	a5,ra,0x10
    3158:	d40ff06f          	j	2698 <matrix_test+0xce8>

0000315c <core_bench_matrix>:
    315c:	ff010113          	addi	sp,sp,-16
    3160:	00812423          	sw	s0,8(sp)
    3164:	00852683          	lw	a3,8(a0)
    3168:	00060413          	mv	s0,a2
    316c:	00058713          	mv	a4,a1
    3170:	00452603          	lw	a2,4(a0)
    3174:	00c52583          	lw	a1,12(a0)
    3178:	00052503          	lw	a0,0(a0)
    317c:	00112623          	sw	ra,12(sp)
    3180:	831fe0ef          	jal	ra,19b0 <matrix_test>
    3184:	00040593          	mv	a1,s0
    3188:	00812403          	lw	s0,8(sp)
    318c:	00c12083          	lw	ra,12(sp)
    3190:	01010113          	addi	sp,sp,16
    3194:	1ed0206f          	j	5b80 <crc16>

00003198 <iterate>:
    3198:	fe010113          	addi	sp,sp,-32
    319c:	01312623          	sw	s3,12(sp)
    31a0:	01c52983          	lw	s3,28(a0)
    31a4:	00112e23          	sw	ra,28(sp)
    31a8:	00812c23          	sw	s0,24(sp)
    31ac:	00912a23          	sw	s1,20(sp)
    31b0:	01212823          	sw	s2,16(sp)
    31b4:	01412423          	sw	s4,8(sp)
    31b8:	01512223          	sw	s5,4(sp)
    31bc:	02052c23          	sw	zero,56(a0)
    31c0:	02052e23          	sw	zero,60(a0)
    31c4:	1c098263          	beqz	s3,3388 <iterate+0x1f0>
    31c8:	0039f793          	andi	a5,s3,3
    31cc:	00050413          	mv	s0,a0
    31d0:	00000493          	li	s1,0
    31d4:	0a078e63          	beqz	a5,3290 <iterate+0xf8>
    31d8:	00100713          	li	a4,1
    31dc:	06e78c63          	beq	a5,a4,3254 <iterate+0xbc>
    31e0:	00200093          	li	ra,2
    31e4:	02178c63          	beq	a5,ra,321c <iterate+0x84>
    31e8:	00100593          	li	a1,1
    31ec:	e29fd0ef          	jal	ra,1014 <core_bench_list>
    31f0:	03845583          	lhu	a1,56(s0)
    31f4:	00100493          	li	s1,1
    31f8:	1f0020ef          	jal	ra,53e8 <crcu16>
    31fc:	fff00593          	li	a1,-1
    3200:	02a41c23          	sh	a0,56(s0)
    3204:	00040513          	mv	a0,s0
    3208:	e0dfd0ef          	jal	ra,1014 <core_bench_list>
    320c:	03845583          	lhu	a1,56(s0)
    3210:	1d8020ef          	jal	ra,53e8 <crcu16>
    3214:	02a41c23          	sh	a0,56(s0)
    3218:	02a41d23          	sh	a0,58(s0)
    321c:	00100593          	li	a1,1
    3220:	00040513          	mv	a0,s0
    3224:	df1fd0ef          	jal	ra,1014 <core_bench_list>
    3228:	03845583          	lhu	a1,56(s0)
    322c:	1bc020ef          	jal	ra,53e8 <crcu16>
    3230:	fff00593          	li	a1,-1
    3234:	02a41c23          	sh	a0,56(s0)
    3238:	00040513          	mv	a0,s0
    323c:	dd9fd0ef          	jal	ra,1014 <core_bench_list>
    3240:	03845583          	lhu	a1,56(s0)
    3244:	1a4020ef          	jal	ra,53e8 <crcu16>
    3248:	02a41c23          	sh	a0,56(s0)
    324c:	18048063          	beqz	s1,33cc <iterate+0x234>
    3250:	00148493          	addi	s1,s1,1
    3254:	00100593          	li	a1,1
    3258:	00040513          	mv	a0,s0
    325c:	db9fd0ef          	jal	ra,1014 <core_bench_list>
    3260:	03845583          	lhu	a1,56(s0)
    3264:	184020ef          	jal	ra,53e8 <crcu16>
    3268:	fff00593          	li	a1,-1
    326c:	02a41c23          	sh	a0,56(s0)
    3270:	00040513          	mv	a0,s0
    3274:	da1fd0ef          	jal	ra,1014 <core_bench_list>
    3278:	03845583          	lhu	a1,56(s0)
    327c:	16c020ef          	jal	ra,53e8 <crcu16>
    3280:	02a41c23          	sh	a0,56(s0)
    3284:	12048c63          	beqz	s1,33bc <iterate+0x224>
    3288:	00148493          	addi	s1,s1,1
    328c:	0e998e63          	beq	s3,s1,3388 <iterate+0x1f0>
    3290:	00100593          	li	a1,1
    3294:	00040513          	mv	a0,s0
    3298:	d7dfd0ef          	jal	ra,1014 <core_bench_list>
    329c:	03845583          	lhu	a1,56(s0)
    32a0:	00148913          	addi	s2,s1,1
    32a4:	144020ef          	jal	ra,53e8 <crcu16>
    32a8:	02a41c23          	sh	a0,56(s0)
    32ac:	fff00593          	li	a1,-1
    32b0:	00040513          	mv	a0,s0
    32b4:	d61fd0ef          	jal	ra,1014 <core_bench_list>
    32b8:	03845583          	lhu	a1,56(s0)
    32bc:	12c020ef          	jal	ra,53e8 <crcu16>
    32c0:	00050293          	mv	t0,a0
    32c4:	02541c23          	sh	t0,56(s0)
    32c8:	00100593          	li	a1,1
    32cc:	00040513          	mv	a0,s0
    32d0:	00049463          	bnez	s1,32d8 <iterate+0x140>
    32d4:	02541d23          	sh	t0,58(s0)
    32d8:	d3dfd0ef          	jal	ra,1014 <core_bench_list>
    32dc:	03845583          	lhu	a1,56(s0)
    32e0:	108020ef          	jal	ra,53e8 <crcu16>
    32e4:	02a41c23          	sh	a0,56(s0)
    32e8:	fff00593          	li	a1,-1
    32ec:	00040513          	mv	a0,s0
    32f0:	d25fd0ef          	jal	ra,1014 <core_bench_list>
    32f4:	03845583          	lhu	a1,56(s0)
    32f8:	0f0020ef          	jal	ra,53e8 <crcu16>
    32fc:	02a41c23          	sh	a0,56(s0)
    3300:	00091463          	bnez	s2,3308 <iterate+0x170>
    3304:	02a41d23          	sh	a0,58(s0)
    3308:	00100593          	li	a1,1
    330c:	00040513          	mv	a0,s0
    3310:	d05fd0ef          	jal	ra,1014 <core_bench_list>
    3314:	03845583          	lhu	a1,56(s0)
    3318:	00190a93          	addi	s5,s2,1
    331c:	00290a13          	addi	s4,s2,2
    3320:	0c8020ef          	jal	ra,53e8 <crcu16>
    3324:	fff00593          	li	a1,-1
    3328:	02a41c23          	sh	a0,56(s0)
    332c:	00040513          	mv	a0,s0
    3330:	ce5fd0ef          	jal	ra,1014 <core_bench_list>
    3334:	03845583          	lhu	a1,56(s0)
    3338:	00390493          	addi	s1,s2,3
    333c:	0ac020ef          	jal	ra,53e8 <crcu16>
    3340:	00050313          	mv	t1,a0
    3344:	02641c23          	sh	t1,56(s0)
    3348:	00100593          	li	a1,1
    334c:	00040513          	mv	a0,s0
    3350:	000a9463          	bnez	s5,3358 <iterate+0x1c0>
    3354:	02641d23          	sh	t1,58(s0)
    3358:	cbdfd0ef          	jal	ra,1014 <core_bench_list>
    335c:	03845583          	lhu	a1,56(s0)
    3360:	088020ef          	jal	ra,53e8 <crcu16>
    3364:	fff00593          	li	a1,-1
    3368:	02a41c23          	sh	a0,56(s0)
    336c:	00040513          	mv	a0,s0
    3370:	ca5fd0ef          	jal	ra,1014 <core_bench_list>
    3374:	03845583          	lhu	a1,56(s0)
    3378:	070020ef          	jal	ra,53e8 <crcu16>
    337c:	02a41c23          	sh	a0,56(s0)
    3380:	020a0863          	beqz	s4,33b0 <iterate+0x218>
    3384:	f09996e3          	bne	s3,s1,3290 <iterate+0xf8>
    3388:	01c12083          	lw	ra,28(sp)
    338c:	01812403          	lw	s0,24(sp)
    3390:	01412483          	lw	s1,20(sp)
    3394:	01012903          	lw	s2,16(sp)
    3398:	00c12983          	lw	s3,12(sp)
    339c:	00812a03          	lw	s4,8(sp)
    33a0:	00412a83          	lw	s5,4(sp)
    33a4:	00000513          	li	a0,0
    33a8:	02010113          	addi	sp,sp,32
    33ac:	00008067          	ret
    33b0:	02a41d23          	sh	a0,58(s0)
    33b4:	ec999ee3          	bne	s3,s1,3290 <iterate+0xf8>
    33b8:	fd1ff06f          	j	3388 <iterate+0x1f0>
    33bc:	02a41d23          	sh	a0,58(s0)
    33c0:	00148493          	addi	s1,s1,1
    33c4:	ec9996e3          	bne	s3,s1,3290 <iterate+0xf8>
    33c8:	fc1ff06f          	j	3388 <iterate+0x1f0>
    33cc:	02a41d23          	sh	a0,58(s0)
    33d0:	00148493          	addi	s1,s1,1
    33d4:	e81ff06f          	j	3254 <iterate+0xbc>

000033d8 <get_seed_32>:
    33d8:	00500793          	li	a5,5
    33dc:	04a7ec63          	bltu	a5,a0,3434 <get_seed_32+0x5c>
    33e0:	0000d2b7          	lui	t0,0xd
    33e4:	00251513          	slli	a0,a0,0x2
    33e8:	97c28313          	addi	t1,t0,-1668 # c97c <state_known_crc+0xc>
    33ec:	006503b3          	add	t2,a0,t1
    33f0:	0003a583          	lw	a1,0(t2)
    33f4:	00058067          	jr	a1
    33f8:	0000e637          	lui	a2,0xe
    33fc:	99862503          	lw	a0,-1640(a2) # d998 <seed5_volatile>
    3400:	00008067          	ret
    3404:	0000e8b7          	lui	a7,0xe
    3408:	9a08a503          	lw	a0,-1632(a7) # d9a0 <seed1_volatile>
    340c:	00008067          	ret
    3410:	0000e837          	lui	a6,0xe
    3414:	99c82503          	lw	a0,-1636(a6) # d99c <seed2_volatile>
    3418:	00008067          	ret
    341c:	0000d737          	lui	a4,0xd
    3420:	1a472503          	lw	a0,420(a4) # d1a4 <seed3_volatile>
    3424:	00008067          	ret
    3428:	0000d6b7          	lui	a3,0xd
    342c:	1a06a503          	lw	a0,416(a3) # d1a0 <seed4_volatile>
    3430:	00008067          	ret
    3434:	00000513          	li	a0,0
    3438:	00008067          	ret

0000343c <check_data_types>:
    343c:	00000513          	li	a0,0
    3440:	00008067          	ret

00003444 <core_init_state>:
    3444:	fff50313          	addi	t1,a0,-1
    3448:	00100793          	li	a5,1
    344c:	00060813          	mv	a6,a2
    3450:	1c67f863          	bgeu	a5,t1,3620 <core_init_state+0x1dc>
    3454:	00158593          	addi	a1,a1,1
    3458:	01059293          	slli	t0,a1,0x10
    345c:	0102d593          	srli	a1,t0,0x10
    3460:	0000d8b7          	lui	a7,0xd
    3464:	0035d393          	srli	t2,a1,0x3
    3468:	00700e93          	li	t4,7
    346c:	0075f713          	andi	a4,a1,7
    3470:	00000693          	li	a3,0
    3474:	99488893          	addi	a7,a7,-1644 # c994 <intpat>
    3478:	00400613          	li	a2,4
    347c:	00100e13          	li	t3,1
    3480:	02c00f13          	li	t5,44
    3484:	0033ff93          	andi	t6,t2,3
    3488:	19d70263          	beq	a4,t4,360c <core_init_state+0x1c8>
    348c:	16e66663          	bltu	a2,a4,35f8 <core_init_state+0x1b4>
    3490:	ffd70793          	addi	a5,a4,-3
    3494:	01079293          	slli	t0,a5,0x10
    3498:	002f9f93          	slli	t6,t6,0x2
    349c:	0102d393          	srli	t2,t0,0x10
    34a0:	01f88733          	add	a4,a7,t6
    34a4:	147e6463          	bltu	t3,t2,35ec <core_init_state+0x1a8>
    34a8:	01072783          	lw	a5,16(a4)
    34ac:	00800293          	li	t0,8
    34b0:	00168f93          	addi	t6,a3,1
    34b4:	005f83b3          	add	t2,t6,t0
    34b8:	1863f263          	bgeu	t2,t1,363c <core_init_state+0x1f8>
    34bc:	ff010113          	addi	sp,sp,-16
    34c0:	00812623          	sw	s0,12(sp)
    34c4:	0180006f          	j	34dc <core_init_state+0x98>
    34c8:	01072783          	lw	a5,16(a4)
    34cc:	00800293          	li	t0,8
    34d0:	00168f93          	addi	t6,a3,1
    34d4:	005f83b3          	add	t2,t6,t0
    34d8:	0a63f463          	bgeu	t2,t1,3580 <core_init_state+0x13c>
    34dc:	0007c403          	lbu	s0,0(a5)
    34e0:	00d80733          	add	a4,a6,a3
    34e4:	01f80fb3          	add	t6,a6,t6
    34e8:	00870023          	sb	s0,0(a4)
    34ec:	0017c683          	lbu	a3,1(a5)
    34f0:	00df8023          	sb	a3,0(t6)
    34f4:	0027c403          	lbu	s0,2(a5)
    34f8:	00870123          	sb	s0,2(a4)
    34fc:	0037cf83          	lbu	t6,3(a5)
    3500:	01f701a3          	sb	t6,3(a4)
    3504:	02c28263          	beq	t0,a2,3528 <core_init_state+0xe4>
    3508:	0047c683          	lbu	a3,4(a5)
    350c:	00d70223          	sb	a3,4(a4)
    3510:	0057c403          	lbu	s0,5(a5)
    3514:	008702a3          	sb	s0,5(a4)
    3518:	0067cf83          	lbu	t6,6(a5)
    351c:	01f70323          	sb	t6,6(a4)
    3520:	0077c783          	lbu	a5,7(a5)
    3524:	00f703a3          	sb	a5,7(a4)
    3528:	00158593          	addi	a1,a1,1
    352c:	005702b3          	add	t0,a4,t0
    3530:	01059713          	slli	a4,a1,0x10
    3534:	01075593          	srli	a1,a4,0x10
    3538:	00038693          	mv	a3,t2
    353c:	01e28023          	sb	t5,0(t0)
    3540:	0035d393          	srli	t2,a1,0x3
    3544:	0075f413          	andi	s0,a1,7
    3548:	0033ff93          	andi	t6,t2,3
    354c:	07d40463          	beq	s0,t4,35b4 <core_init_state+0x170>
    3550:	04866863          	bltu	a2,s0,35a0 <core_init_state+0x15c>
    3554:	ffd40413          	addi	s0,s0,-3
    3558:	01041793          	slli	a5,s0,0x10
    355c:	002f9f93          	slli	t6,t6,0x2
    3560:	0107d293          	srli	t0,a5,0x10
    3564:	01f88733          	add	a4,a7,t6
    3568:	f65e70e3          	bgeu	t3,t0,34c8 <core_init_state+0x84>
    356c:	00400293          	li	t0,4
    3570:	00168f93          	addi	t6,a3,1
    3574:	005f83b3          	add	t2,t6,t0
    3578:	00072783          	lw	a5,0(a4)
    357c:	f663e0e3          	bltu	t2,t1,34dc <core_init_state+0x98>
    3580:	04a6f463          	bgeu	a3,a0,35c8 <core_init_state+0x184>
    3584:	00100613          	li	a2,1
    3588:	05f57663          	bgeu	a0,t6,35d4 <core_init_state+0x190>
    358c:	00c12403          	lw	s0,12(sp)
    3590:	00000593          	li	a1,0
    3594:	00d80533          	add	a0,a6,a3
    3598:	01010113          	addi	sp,sp,16
    359c:	5740006f          	j	3b10 <memset>
    35a0:	002f9713          	slli	a4,t6,0x2
    35a4:	00e883b3          	add	t2,a7,a4
    35a8:	0203a783          	lw	a5,32(t2)
    35ac:	00800293          	li	t0,8
    35b0:	f21ff06f          	j	34d0 <core_init_state+0x8c>
    35b4:	002f9793          	slli	a5,t6,0x2
    35b8:	00f882b3          	add	t0,a7,a5
    35bc:	0302a783          	lw	a5,48(t0)
    35c0:	00800293          	li	t0,8
    35c4:	f0dff06f          	j	34d0 <core_init_state+0x8c>
    35c8:	00c12403          	lw	s0,12(sp)
    35cc:	01010113          	addi	sp,sp,16
    35d0:	00008067          	ret
    35d4:	00c12403          	lw	s0,12(sp)
    35d8:	40d50633          	sub	a2,a0,a3
    35dc:	00000593          	li	a1,0
    35e0:	00d80533          	add	a0,a6,a3
    35e4:	01010113          	addi	sp,sp,16
    35e8:	5280006f          	j	3b10 <memset>
    35ec:	00072783          	lw	a5,0(a4)
    35f0:	00400293          	li	t0,4
    35f4:	ebdff06f          	j	34b0 <core_init_state+0x6c>
    35f8:	002f9393          	slli	t2,t6,0x2
    35fc:	00788733          	add	a4,a7,t2
    3600:	02072783          	lw	a5,32(a4)
    3604:	00800293          	li	t0,8
    3608:	ea9ff06f          	j	34b0 <core_init_state+0x6c>
    360c:	002f9793          	slli	a5,t6,0x2
    3610:	00f882b3          	add	t0,a7,a5
    3614:	0302a783          	lw	a5,48(t0)
    3618:	00800293          	li	t0,8
    361c:	e95ff06f          	j	34b0 <core_init_state+0x6c>
    3620:	00000693          	li	a3,0
    3624:	00100f93          	li	t6,1
    3628:	00100613          	li	a2,1
    362c:	01f57c63          	bgeu	a0,t6,3644 <core_init_state+0x200>
    3630:	00000593          	li	a1,0
    3634:	00d80533          	add	a0,a6,a3
    3638:	4d80006f          	j	3b10 <memset>
    363c:	fea6e6e3          	bltu	a3,a0,3628 <core_init_state+0x1e4>
    3640:	00008067          	ret
    3644:	40d50633          	sub	a2,a0,a3
    3648:	fe9ff06f          	j	3630 <core_init_state+0x1ec>

0000364c <core_state_transition>:
    364c:	00052703          	lw	a4,0(a0)
    3650:	00050613          	mv	a2,a0
    3654:	00074683          	lbu	a3,0(a4)
    3658:	28068063          	beqz	a3,38d8 <core_state_transition+0x28c>
    365c:	02c00793          	li	a5,44
    3660:	00000513          	li	a0,0
    3664:	1ef68063          	beq	a3,a5,3844 <core_state_transition+0x1f8>
    3668:	fd068513          	addi	a0,a3,-48
    366c:	0ff57293          	zext.b	t0,a0
    3670:	00900813          	li	a6,9
    3674:	04587263          	bgeu	a6,t0,36b8 <core_state_transition+0x6c>
    3678:	02d00313          	li	t1,45
    367c:	1e668463          	beq	a3,t1,3864 <core_state_transition+0x218>
    3680:	02e00393          	li	t2,46
    3684:	08768c63          	beq	a3,t2,371c <core_state_transition+0xd0>
    3688:	02b00e93          	li	t4,43
    368c:	1dd68c63          	beq	a3,t4,3864 <core_state_transition+0x218>
    3690:	0045a683          	lw	a3,4(a1)
    3694:	0005a883          	lw	a7,0(a1)
    3698:	00170713          	addi	a4,a4,1
    369c:	00168e13          	addi	t3,a3,1
    36a0:	00188e93          	addi	t4,a7,1
    36a4:	01c5a223          	sw	t3,4(a1)
    36a8:	01d5a023          	sw	t4,0(a1)
    36ac:	00100513          	li	a0,1
    36b0:	00e62023          	sw	a4,0(a2)
    36b4:	00008067          	ret
    36b8:	0005af03          	lw	t5,0(a1)
    36bc:	00170693          	addi	a3,a4,1
    36c0:	001f0f93          	addi	t6,t5,1
    36c4:	01f5a023          	sw	t6,0(a1)
    36c8:	00174503          	lbu	a0,1(a4)
    36cc:	1e050a63          	beqz	a0,38c0 <core_state_transition+0x274>
    36d0:	16f50663          	beq	a0,a5,383c <core_state_transition+0x1f0>
    36d4:	02e00293          	li	t0,46
    36d8:	14550a63          	beq	a0,t0,382c <core_state_transition+0x1e0>
    36dc:	fd050713          	addi	a4,a0,-48
    36e0:	0ff77813          	zext.b	a6,a4
    36e4:	00900793          	li	a5,9
    36e8:	0107ec63          	bltu	a5,a6,3700 <core_state_transition+0xb4>
    36ec:	0016c503          	lbu	a0,1(a3)
    36f0:	00168693          	addi	a3,a3,1
    36f4:	1c050663          	beqz	a0,38c0 <core_state_transition+0x274>
    36f8:	02c00793          	li	a5,44
    36fc:	fd5ff06f          	j	36d0 <core_state_transition+0x84>
    3700:	0105a303          	lw	t1,16(a1)
    3704:	00168713          	addi	a4,a3,1
    3708:	00100513          	li	a0,1
    370c:	00130393          	addi	t2,t1,1
    3710:	0075a823          	sw	t2,16(a1)
    3714:	00e62023          	sw	a4,0(a2)
    3718:	00008067          	ret
    371c:	0005a883          	lw	a7,0(a1)
    3720:	00170693          	addi	a3,a4,1
    3724:	00188e13          	addi	t3,a7,1
    3728:	01c5a023          	sw	t3,0(a1)
    372c:	00174e83          	lbu	t4,1(a4)
    3730:	180e8e63          	beqz	t4,38cc <core_state_transition+0x280>
    3734:	1efe8463          	beq	t4,a5,391c <core_state_transition+0x2d0>
    3738:	0dfeff13          	andi	t5,t4,223
    373c:	04500f93          	li	t6,69
    3740:	03ff0463          	beq	t5,t6,3768 <core_state_transition+0x11c>
    3744:	fd0e8293          	addi	t0,t4,-48
    3748:	0ff2f813          	zext.b	a6,t0
    374c:	00900313          	li	t1,9
    3750:	0f036e63          	bltu	t1,a6,384c <core_state_transition+0x200>
    3754:	0016ce83          	lbu	t4,1(a3)
    3758:	00168693          	addi	a3,a3,1
    375c:	160e8863          	beqz	t4,38cc <core_state_transition+0x280>
    3760:	02c00793          	li	a5,44
    3764:	fd1ff06f          	j	3734 <core_state_transition+0xe8>
    3768:	0145a503          	lw	a0,20(a1)
    376c:	00168713          	addi	a4,a3,1
    3770:	00150e13          	addi	t3,a0,1
    3774:	01c5aa23          	sw	t3,20(a1)
    3778:	0016ce83          	lbu	t4,1(a3)
    377c:	160e8663          	beqz	t4,38e8 <core_state_transition+0x29c>
    3780:	02c00f13          	li	t5,44
    3784:	17ee8663          	beq	t4,t5,38f0 <core_state_transition+0x2a4>
    3788:	00c5a703          	lw	a4,12(a1)
    378c:	fd5e8793          	addi	a5,t4,-43
    3790:	0fd7ff93          	andi	t6,a5,253
    3794:	00170293          	addi	t0,a4,1
    3798:	0055a623          	sw	t0,12(a1)
    379c:	000f8a63          	beqz	t6,37b0 <core_state_transition+0x164>
    37a0:	00268713          	addi	a4,a3,2
    37a4:	00100513          	li	a0,1
    37a8:	00e62023          	sw	a4,0(a2)
    37ac:	00008067          	ret
    37b0:	0026c803          	lbu	a6,2(a3)
    37b4:	00268713          	addi	a4,a3,2
    37b8:	12080463          	beqz	a6,38e0 <core_state_transition+0x294>
    37bc:	15e80063          	beq	a6,t5,38fc <core_state_transition+0x2b0>
    37c0:	0185a303          	lw	t1,24(a1)
    37c4:	fd080393          	addi	t2,a6,-48
    37c8:	0ff3f893          	zext.b	a7,t2
    37cc:	00130513          	addi	a0,t1,1
    37d0:	00900e13          	li	t3,9
    37d4:	00a5ac23          	sw	a0,24(a1)
    37d8:	011e7a63          	bgeu	t3,a7,37ec <core_state_transition+0x1a0>
    37dc:	00368713          	addi	a4,a3,3
    37e0:	00100513          	li	a0,1
    37e4:	00e62023          	sw	a4,0(a2)
    37e8:	00008067          	ret
    37ec:	00900293          	li	t0,9
    37f0:	00174683          	lbu	a3,1(a4)
    37f4:	00070e93          	mv	t4,a4
    37f8:	02c00f13          	li	t5,44
    37fc:	fd068793          	addi	a5,a3,-48
    3800:	00170713          	addi	a4,a4,1
    3804:	0ff7ff93          	zext.b	t6,a5
    3808:	10068663          	beqz	a3,3914 <core_state_transition+0x2c8>
    380c:	0fe68e63          	beq	a3,t5,3908 <core_state_transition+0x2bc>
    3810:	fff2f0e3          	bgeu	t0,t6,37f0 <core_state_transition+0x1a4>
    3814:	0045a803          	lw	a6,4(a1)
    3818:	002e8713          	addi	a4,t4,2
    381c:	00100513          	li	a0,1
    3820:	00180313          	addi	t1,a6,1
    3824:	0065a223          	sw	t1,4(a1)
    3828:	eedff06f          	j	3714 <core_state_transition+0xc8>
    382c:	0105a883          	lw	a7,16(a1)
    3830:	00188e13          	addi	t3,a7,1
    3834:	01c5a823          	sw	t3,16(a1)
    3838:	f1dff06f          	j	3754 <core_state_transition+0x108>
    383c:	00068713          	mv	a4,a3
    3840:	00400513          	li	a0,4
    3844:	00170713          	addi	a4,a4,1
    3848:	ecdff06f          	j	3714 <core_state_transition+0xc8>
    384c:	0145a383          	lw	t2,20(a1)
    3850:	00168713          	addi	a4,a3,1
    3854:	00100513          	li	a0,1
    3858:	00138893          	addi	a7,t2,1
    385c:	0115aa23          	sw	a7,20(a1)
    3860:	eb5ff06f          	j	3714 <core_state_transition+0xc8>
    3864:	0005af03          	lw	t5,0(a1)
    3868:	00170693          	addi	a3,a4,1
    386c:	001f0f93          	addi	t6,t5,1
    3870:	01f5a023          	sw	t6,0(a1)
    3874:	00174283          	lbu	t0,1(a4)
    3878:	0c028263          	beqz	t0,393c <core_state_transition+0x2f0>
    387c:	0af28863          	beq	t0,a5,392c <core_state_transition+0x2e0>
    3880:	0085a703          	lw	a4,8(a1)
    3884:	fd028793          	addi	a5,t0,-48
    3888:	0ff7f813          	zext.b	a6,a5
    388c:	00900513          	li	a0,9
    3890:	00170313          	addi	t1,a4,1
    3894:	01057e63          	bgeu	a0,a6,38b0 <core_state_transition+0x264>
    3898:	02e00393          	li	t2,46
    389c:	00728e63          	beq	t0,t2,38b8 <core_state_transition+0x26c>
    38a0:	0065a423          	sw	t1,8(a1)
    38a4:	00168713          	addi	a4,a3,1
    38a8:	00100513          	li	a0,1
    38ac:	e69ff06f          	j	3714 <core_state_transition+0xc8>
    38b0:	0065a423          	sw	t1,8(a1)
    38b4:	e39ff06f          	j	36ec <core_state_transition+0xa0>
    38b8:	0065a423          	sw	t1,8(a1)
    38bc:	e99ff06f          	j	3754 <core_state_transition+0x108>
    38c0:	00068713          	mv	a4,a3
    38c4:	00400513          	li	a0,4
    38c8:	e4dff06f          	j	3714 <core_state_transition+0xc8>
    38cc:	00068713          	mv	a4,a3
    38d0:	00500513          	li	a0,5
    38d4:	e41ff06f          	j	3714 <core_state_transition+0xc8>
    38d8:	00000513          	li	a0,0
    38dc:	e39ff06f          	j	3714 <core_state_transition+0xc8>
    38e0:	00600513          	li	a0,6
    38e4:	e31ff06f          	j	3714 <core_state_transition+0xc8>
    38e8:	00300513          	li	a0,3
    38ec:	e29ff06f          	j	3714 <core_state_transition+0xc8>
    38f0:	00300513          	li	a0,3
    38f4:	00170713          	addi	a4,a4,1
    38f8:	e1dff06f          	j	3714 <core_state_transition+0xc8>
    38fc:	00600513          	li	a0,6
    3900:	00170713          	addi	a4,a4,1
    3904:	e11ff06f          	j	3714 <core_state_transition+0xc8>
    3908:	00700513          	li	a0,7
    390c:	00170713          	addi	a4,a4,1
    3910:	e05ff06f          	j	3714 <core_state_transition+0xc8>
    3914:	00700513          	li	a0,7
    3918:	dfdff06f          	j	3714 <core_state_transition+0xc8>
    391c:	00068713          	mv	a4,a3
    3920:	00500513          	li	a0,5
    3924:	00170713          	addi	a4,a4,1
    3928:	dedff06f          	j	3714 <core_state_transition+0xc8>
    392c:	00068713          	mv	a4,a3
    3930:	00200513          	li	a0,2
    3934:	00170713          	addi	a4,a4,1
    3938:	dddff06f          	j	3714 <core_state_transition+0xc8>
    393c:	00068713          	mv	a4,a3
    3940:	00200513          	li	a0,2
    3944:	dd1ff06f          	j	3714 <core_state_transition+0xc8>

00003948 <core_bench_state>:
    3948:	f8010113          	addi	sp,sp,-128
    394c:	06812c23          	sw	s0,120(sp)
    3950:	06912a23          	sw	s1,116(sp)
    3954:	07212823          	sw	s2,112(sp)
    3958:	07312623          	sw	s3,108(sp)
    395c:	07412423          	sw	s4,104(sp)
    3960:	07612023          	sw	s6,96(sp)
    3964:	05712e23          	sw	s7,92(sp)
    3968:	06112e23          	sw	ra,124(sp)
    396c:	07512223          	sw	s5,100(sp)
    3970:	00058413          	mv	s0,a1
    3974:	0005c583          	lbu	a1,0(a1)
    3978:	02012823          	sw	zero,48(sp)
    397c:	00012823          	sw	zero,16(sp)
    3980:	02012a23          	sw	zero,52(sp)
    3984:	02012c23          	sw	zero,56(sp)
    3988:	02012e23          	sw	zero,60(sp)
    398c:	04012023          	sw	zero,64(sp)
    3990:	04012223          	sw	zero,68(sp)
    3994:	04012423          	sw	zero,72(sp)
    3998:	04012623          	sw	zero,76(sp)
    399c:	00012a23          	sw	zero,20(sp)
    39a0:	00012c23          	sw	zero,24(sp)
    39a4:	00012e23          	sw	zero,28(sp)
    39a8:	02012023          	sw	zero,32(sp)
    39ac:	02012223          	sw	zero,36(sp)
    39b0:	02012423          	sw	zero,40(sp)
    39b4:	02012623          	sw	zero,44(sp)
    39b8:	03010913          	addi	s2,sp,48
    39bc:	00050b93          	mv	s7,a0
    39c0:	00060b13          	mv	s6,a2
    39c4:	00068a13          	mv	s4,a3
    39c8:	00070993          	mv	s3,a4
    39cc:	00078493          	mv	s1,a5
    39d0:	12058463          	beqz	a1,3af8 <core_bench_state+0x1b0>
    39d4:	00812623          	sw	s0,12(sp)
    39d8:	00c10a93          	addi	s5,sp,12
    39dc:	00090593          	mv	a1,s2
    39e0:	000a8513          	mv	a0,s5
    39e4:	c69ff0ef          	jal	ra,364c <core_state_transition>
    39e8:	00251813          	slli	a6,a0,0x2
    39ec:	05080793          	addi	a5,a6,80
    39f0:	002782b3          	add	t0,a5,sp
    39f4:	00c12703          	lw	a4,12(sp)
    39f8:	fc02a303          	lw	t1,-64(t0)
    39fc:	00074383          	lbu	t2,0(a4)
    3a00:	00130513          	addi	a0,t1,1
    3a04:	fca2a023          	sw	a0,-64(t0)
    3a08:	fc039ae3          	bnez	t2,39dc <core_bench_state+0x94>
    3a0c:	01740bb3          	add	s7,s0,s7
    3a10:	0f747c63          	bgeu	s0,s7,3b08 <core_bench_state+0x1c0>
    3a14:	00040893          	mv	a7,s0
    3a18:	02c00613          	li	a2,44
    3a1c:	0008c083          	lbu	ra,0(a7)
    3a20:	0160c6b3          	xor	a3,ra,s6
    3a24:	00c08463          	beq	ra,a2,3a2c <core_bench_state+0xe4>
    3a28:	00d88023          	sb	a3,0(a7)
    3a2c:	013888b3          	add	a7,a7,s3
    3a30:	ff78e6e3          	bltu	a7,s7,3a1c <core_bench_state+0xd4>
    3a34:	00044a83          	lbu	s5,0(s0)
    3a38:	020a8e63          	beqz	s5,3a74 <core_bench_state+0x12c>
    3a3c:	00812623          	sw	s0,12(sp)
    3a40:	00c10a93          	addi	s5,sp,12
    3a44:	00090593          	mv	a1,s2
    3a48:	000a8513          	mv	a0,s5
    3a4c:	c01ff0ef          	jal	ra,364c <core_state_transition>
    3a50:	00251e13          	slli	t3,a0,0x2
    3a54:	050e0e93          	addi	t4,t3,80
    3a58:	002e8f33          	add	t5,t4,sp
    3a5c:	00c12583          	lw	a1,12(sp)
    3a60:	fc0f2f83          	lw	t6,-64(t5)
    3a64:	0005c803          	lbu	a6,0(a1)
    3a68:	001f8793          	addi	a5,t6,1
    3a6c:	fcff2023          	sw	a5,-64(t5)
    3a70:	fc081ae3          	bnez	a6,3a44 <core_bench_state+0xfc>
    3a74:	00812623          	sw	s0,12(sp)
    3a78:	00040393          	mv	t2,s0
    3a7c:	02c00293          	li	t0,44
    3a80:	01747e63          	bgeu	s0,s7,3a9c <core_bench_state+0x154>
    3a84:	0003c303          	lbu	t1,0(t2)
    3a88:	01434733          	xor	a4,t1,s4
    3a8c:	00530463          	beq	t1,t0,3a94 <core_bench_state+0x14c>
    3a90:	00e38023          	sb	a4,0(t2)
    3a94:	013383b3          	add	t2,t2,s3
    3a98:	ff73e6e3          	bltu	t2,s7,3a84 <core_bench_state+0x13c>
    3a9c:	01010413          	addi	s0,sp,16
    3aa0:	00090993          	mv	s3,s2
    3aa4:	00042503          	lw	a0,0(s0)
    3aa8:	00048593          	mv	a1,s1
    3aac:	00440413          	addi	s0,s0,4
    3ab0:	3bd010ef          	jal	ra,566c <crcu32>
    3ab4:	00050593          	mv	a1,a0
    3ab8:	0009a503          	lw	a0,0(s3)
    3abc:	00498993          	addi	s3,s3,4
    3ac0:	3ad010ef          	jal	ra,566c <crcu32>
    3ac4:	00050493          	mv	s1,a0
    3ac8:	fc891ee3          	bne	s2,s0,3aa4 <core_bench_state+0x15c>
    3acc:	07c12083          	lw	ra,124(sp)
    3ad0:	07812403          	lw	s0,120(sp)
    3ad4:	07412483          	lw	s1,116(sp)
    3ad8:	07012903          	lw	s2,112(sp)
    3adc:	06c12983          	lw	s3,108(sp)
    3ae0:	06812a03          	lw	s4,104(sp)
    3ae4:	06412a83          	lw	s5,100(sp)
    3ae8:	06012b03          	lw	s6,96(sp)
    3aec:	05c12b83          	lw	s7,92(sp)
    3af0:	08010113          	addi	sp,sp,128
    3af4:	00008067          	ret
    3af8:	00a40bb3          	add	s7,s0,a0
    3afc:	f1746ce3          	bltu	s0,s7,3a14 <core_bench_state+0xcc>
    3b00:	00812623          	sw	s0,12(sp)
    3b04:	f99ff06f          	j	3a9c <core_bench_state+0x154>
    3b08:	00812623          	sw	s0,12(sp)
    3b0c:	f39ff06f          	j	3a44 <core_bench_state+0xfc>

00003b10 <memset>:
    3b10:	00f00313          	li	t1,15
    3b14:	00050713          	mv	a4,a0
    3b18:	02c37e63          	bgeu	t1,a2,3b54 <memset+0x44>
    3b1c:	00f77793          	andi	a5,a4,15
    3b20:	0a079063          	bnez	a5,3bc0 <memset+0xb0>
    3b24:	08059263          	bnez	a1,3ba8 <memset+0x98>
    3b28:	ff067693          	andi	a3,a2,-16
    3b2c:	00f67613          	andi	a2,a2,15
    3b30:	00e686b3          	add	a3,a3,a4
    3b34:	00b72023          	sw	a1,0(a4)
    3b38:	00b72223          	sw	a1,4(a4)
    3b3c:	00b72423          	sw	a1,8(a4)
    3b40:	00b72623          	sw	a1,12(a4)
    3b44:	01070713          	addi	a4,a4,16
    3b48:	fed766e3          	bltu	a4,a3,3b34 <memset+0x24>
    3b4c:	00061463          	bnez	a2,3b54 <memset+0x44>
    3b50:	00008067          	ret
    3b54:	40c306b3          	sub	a3,t1,a2
    3b58:	00269693          	slli	a3,a3,0x2
    3b5c:	00000297          	auipc	t0,0x0
    3b60:	005686b3          	add	a3,a3,t0
    3b64:	00c68067          	jr	12(a3)
    3b68:	00b70723          	sb	a1,14(a4)
    3b6c:	00b706a3          	sb	a1,13(a4)
    3b70:	00b70623          	sb	a1,12(a4)
    3b74:	00b705a3          	sb	a1,11(a4)
    3b78:	00b70523          	sb	a1,10(a4)
    3b7c:	00b704a3          	sb	a1,9(a4)
    3b80:	00b70423          	sb	a1,8(a4)
    3b84:	00b703a3          	sb	a1,7(a4)
    3b88:	00b70323          	sb	a1,6(a4)
    3b8c:	00b702a3          	sb	a1,5(a4)
    3b90:	00b70223          	sb	a1,4(a4)
    3b94:	00b701a3          	sb	a1,3(a4)
    3b98:	00b70123          	sb	a1,2(a4)
    3b9c:	00b700a3          	sb	a1,1(a4)
    3ba0:	00b70023          	sb	a1,0(a4)
    3ba4:	00008067          	ret
    3ba8:	0ff5f593          	zext.b	a1,a1
    3bac:	00859693          	slli	a3,a1,0x8
    3bb0:	00d5e5b3          	or	a1,a1,a3
    3bb4:	01059693          	slli	a3,a1,0x10
    3bb8:	00d5e5b3          	or	a1,a1,a3
    3bbc:	f6dff06f          	j	3b28 <memset+0x18>
    3bc0:	00279693          	slli	a3,a5,0x2
    3bc4:	00000297          	auipc	t0,0x0
    3bc8:	005686b3          	add	a3,a3,t0
    3bcc:	00008293          	mv	t0,ra
    3bd0:	fa0680e7          	jalr	-96(a3)
    3bd4:	00028093          	mv	ra,t0
    3bd8:	ff078793          	addi	a5,a5,-16
    3bdc:	40f70733          	sub	a4,a4,a5
    3be0:	00f60633          	add	a2,a2,a5
    3be4:	f6c378e3          	bgeu	t1,a2,3b54 <memset+0x44>
    3be8:	f3dff06f          	j	3b24 <memset+0x14>

00003bec <matrix_sum>:
    3bec:	00050813          	mv	a6,a0
    3bf0:	48050463          	beqz	a0,4078 <matrix_sum+0x48c>
    3bf4:	00251313          	slli	t1,a0,0x2
    3bf8:	40a008b3          	neg	a7,a0
    3bfc:	00658733          	add	a4,a1,t1
    3c00:	00000513          	li	a0,0
    3c04:	00000593          	li	a1,0
    3c08:	00000f93          	li	t6,0
    3c0c:	00000e93          	li	t4,0
    3c10:	00389893          	slli	a7,a7,0x3
    3c14:	406706b3          	sub	a3,a4,t1
    3c18:	40d707b3          	sub	a5,a4,a3
    3c1c:	ffc78293          	addi	t0,a5,-4
    3c20:	0022d393          	srli	t2,t0,0x2
    3c24:	00138e13          	addi	t3,t2,1
    3c28:	007e7793          	andi	a5,t3,7
    3c2c:	00068e13          	mv	t3,a3
    3c30:	28078a63          	beqz	a5,3ec4 <matrix_sum+0x2d8>
    3c34:	00100f13          	li	t5,1
    3c38:	13e78a63          	beq	a5,t5,3d6c <matrix_sum+0x180>
    3c3c:	00200293          	li	t0,2
    3c40:	10578063          	beq	a5,t0,3d40 <matrix_sum+0x154>
    3c44:	00300393          	li	t2,3
    3c48:	0c778663          	beq	a5,t2,3d14 <matrix_sum+0x128>
    3c4c:	00400f13          	li	t5,4
    3c50:	09e78c63          	beq	a5,t5,3ce8 <matrix_sum+0xfc>
    3c54:	00500293          	li	t0,5
    3c58:	06578263          	beq	a5,t0,3cbc <matrix_sum+0xd0>
    3c5c:	00600393          	li	t2,6
    3c60:	02778863          	beq	a5,t2,3c90 <matrix_sum+0xa4>
    3c64:	000f8e13          	mv	t3,t6
    3c68:	0006af83          	lw	t6,0(a3)
    3c6c:	01051513          	slli	a0,a0,0x10
    3c70:	01055f13          	srli	t5,a0,0x10
    3c74:	01fe8eb3          	add	t4,t4,t6
    3c78:	3fd65663          	bge	a2,t4,4064 <matrix_sum+0x478>
    3c7c:	00af0e93          	addi	t4,t5,10
    3c80:	010e9e13          	slli	t3,t4,0x10
    3c84:	410e5513          	srai	a0,t3,0x10
    3c88:	00000e93          	li	t4,0
    3c8c:	00468e13          	addi	t3,a3,4
    3c90:	000f8f13          	mv	t5,t6
    3c94:	000e2f83          	lw	t6,0(t3)
    3c98:	01051513          	slli	a0,a0,0x10
    3c9c:	01055293          	srli	t0,a0,0x10
    3ca0:	01fe8eb3          	add	t4,t4,t6
    3ca4:	3bd65663          	bge	a2,t4,4050 <matrix_sum+0x464>
    3ca8:	00a28e93          	addi	t4,t0,10 # 3bce <memset+0xbe>
    3cac:	010e9513          	slli	a0,t4,0x10
    3cb0:	41055513          	srai	a0,a0,0x10
    3cb4:	00000e93          	li	t4,0
    3cb8:	004e0e13          	addi	t3,t3,4
    3cbc:	000f8293          	mv	t0,t6
    3cc0:	000e2f83          	lw	t6,0(t3)
    3cc4:	01051793          	slli	a5,a0,0x10
    3cc8:	0107d393          	srli	t2,a5,0x10
    3ccc:	01fe8eb3          	add	t4,t4,t6
    3cd0:	37d65663          	bge	a2,t4,403c <matrix_sum+0x450>
    3cd4:	00a38e93          	addi	t4,t2,10
    3cd8:	010e9793          	slli	a5,t4,0x10
    3cdc:	4107d513          	srai	a0,a5,0x10
    3ce0:	00000e93          	li	t4,0
    3ce4:	004e0e13          	addi	t3,t3,4
    3ce8:	000f8393          	mv	t2,t6
    3cec:	000e2f83          	lw	t6,0(t3)
    3cf0:	01051f13          	slli	t5,a0,0x10
    3cf4:	010f5513          	srli	a0,t5,0x10
    3cf8:	01fe8eb3          	add	t4,t4,t6
    3cfc:	33d65663          	bge	a2,t4,4028 <matrix_sum+0x43c>
    3d00:	00a50e93          	addi	t4,a0,10
    3d04:	010e9f13          	slli	t5,t4,0x10
    3d08:	410f5513          	srai	a0,t5,0x10
    3d0c:	00000e93          	li	t4,0
    3d10:	004e0e13          	addi	t3,t3,4
    3d14:	000f8293          	mv	t0,t6
    3d18:	000e2f83          	lw	t6,0(t3)
    3d1c:	01051513          	slli	a0,a0,0x10
    3d20:	01055793          	srli	a5,a0,0x10
    3d24:	01fe8eb3          	add	t4,t4,t6
    3d28:	2fd65663          	bge	a2,t4,4014 <matrix_sum+0x428>
    3d2c:	00a78e93          	addi	t4,a5,10
    3d30:	010e9513          	slli	a0,t4,0x10
    3d34:	41055513          	srai	a0,a0,0x10
    3d38:	00000e93          	li	t4,0
    3d3c:	004e0e13          	addi	t3,t3,4
    3d40:	000f8393          	mv	t2,t6
    3d44:	000e2f83          	lw	t6,0(t3)
    3d48:	01051793          	slli	a5,a0,0x10
    3d4c:	0107d293          	srli	t0,a5,0x10
    3d50:	01fe8eb3          	add	t4,t4,t6
    3d54:	2bd65663          	bge	a2,t4,4000 <matrix_sum+0x414>
    3d58:	00a28e93          	addi	t4,t0,10
    3d5c:	010e9793          	slli	a5,t4,0x10
    3d60:	4107d513          	srai	a0,a5,0x10
    3d64:	00000e93          	li	t4,0
    3d68:	004e0e13          	addi	t3,t3,4
    3d6c:	000f8293          	mv	t0,t6
    3d70:	000e2f83          	lw	t6,0(t3)
    3d74:	01051f13          	slli	t5,a0,0x10
    3d78:	010f5513          	srli	a0,t5,0x10
    3d7c:	01fe8eb3          	add	t4,t4,t6
    3d80:	27d65663          	bge	a2,t4,3fec <matrix_sum+0x400>
    3d84:	00a50e93          	addi	t4,a0,10
    3d88:	010e9f13          	slli	t5,t4,0x10
    3d8c:	410f5513          	srai	a0,t5,0x10
    3d90:	00000e93          	li	t4,0
    3d94:	004e0e13          	addi	t3,t3,4
    3d98:	13c71663          	bne	a4,t3,3ec4 <matrix_sum+0x2d8>
    3d9c:	00158593          	addi	a1,a1,1
    3da0:	41168733          	sub	a4,a3,a7
    3da4:	e6b818e3          	bne	a6,a1,3c14 <matrix_sum+0x28>
    3da8:	00008067          	ret
    3dac:	007fafb3          	slt	t6,t6,t2
    3db0:	01f782b3          	add	t0,a5,t6
    3db4:	004e2f83          	lw	t6,4(t3)
    3db8:	01029f13          	slli	t5,t0,0x10
    3dbc:	410f5793          	srai	a5,t5,0x10
    3dc0:	01079293          	slli	t0,a5,0x10
    3dc4:	01fe8533          	add	a0,t4,t6
    3dc8:	004e0e13          	addi	t3,t3,4
    3dcc:	0102d793          	srli	a5,t0,0x10
    3dd0:	12a65863          	bge	a2,a0,3f00 <matrix_sum+0x314>
    3dd4:	004e2383          	lw	t2,4(t3)
    3dd8:	00a78793          	addi	a5,a5,10
    3ddc:	01079513          	slli	a0,a5,0x10
    3de0:	41055293          	srai	t0,a0,0x10
    3de4:	00000513          	li	a0,0
    3de8:	01029f13          	slli	t5,t0,0x10
    3dec:	007502b3          	add	t0,a0,t2
    3df0:	010f5e93          	srli	t4,t5,0x10
    3df4:	12565863          	bge	a2,t0,3f24 <matrix_sum+0x338>
    3df8:	00ae8e93          	addi	t4,t4,10
    3dfc:	008e2f83          	lw	t6,8(t3)
    3e00:	010e9293          	slli	t0,t4,0x10
    3e04:	4102df13          	srai	t5,t0,0x10
    3e08:	00000293          	li	t0,0
    3e0c:	010f1793          	slli	a5,t5,0x10
    3e10:	01f28533          	add	a0,t0,t6
    3e14:	0107de93          	srli	t4,a5,0x10
    3e18:	12a65863          	bge	a2,a0,3f48 <matrix_sum+0x35c>
    3e1c:	00ce2383          	lw	t2,12(t3)
    3e20:	00ae8e93          	addi	t4,t4,10
    3e24:	010e9513          	slli	a0,t4,0x10
    3e28:	41055793          	srai	a5,a0,0x10
    3e2c:	00000513          	li	a0,0
    3e30:	01079f13          	slli	t5,a5,0x10
    3e34:	00750533          	add	a0,a0,t2
    3e38:	010f5293          	srli	t0,t5,0x10
    3e3c:	12a65863          	bge	a2,a0,3f6c <matrix_sum+0x380>
    3e40:	00a28293          	addi	t0,t0,10
    3e44:	010e2f83          	lw	t6,16(t3)
    3e48:	01029513          	slli	a0,t0,0x10
    3e4c:	41055f13          	srai	t5,a0,0x10
    3e50:	00000513          	li	a0,0
    3e54:	010f1793          	slli	a5,t5,0x10
    3e58:	01f502b3          	add	t0,a0,t6
    3e5c:	0107de93          	srli	t4,a5,0x10
    3e60:	12565863          	bge	a2,t0,3f90 <matrix_sum+0x3a4>
    3e64:	014e2383          	lw	t2,20(t3)
    3e68:	00ae8e93          	addi	t4,t4,10
    3e6c:	010e9293          	slli	t0,t4,0x10
    3e70:	4102d793          	srai	a5,t0,0x10
    3e74:	00000293          	li	t0,0
    3e78:	01079f13          	slli	t5,a5,0x10
    3e7c:	00728533          	add	a0,t0,t2
    3e80:	010f5793          	srli	a5,t5,0x10
    3e84:	12a65863          	bge	a2,a0,3fb4 <matrix_sum+0x3c8>
    3e88:	00a78793          	addi	a5,a5,10
    3e8c:	01079513          	slli	a0,a5,0x10
    3e90:	018e2f83          	lw	t6,24(t3)
    3e94:	41055f13          	srai	t5,a0,0x10
    3e98:	010f1e93          	slli	t4,t5,0x10
    3e9c:	00000513          	li	a0,0
    3ea0:	010ed293          	srli	t0,t4,0x10
    3ea4:	01f50eb3          	add	t4,a0,t6
    3ea8:	13d65863          	bge	a2,t4,3fd8 <matrix_sum+0x3ec>
    3eac:	00a28513          	addi	a0,t0,10
    3eb0:	01051293          	slli	t0,a0,0x10
    3eb4:	4102d513          	srai	a0,t0,0x10
    3eb8:	00000e93          	li	t4,0
    3ebc:	01ce0e13          	addi	t3,t3,28
    3ec0:	edc70ee3          	beq	a4,t3,3d9c <matrix_sum+0x1b0>
    3ec4:	000e2383          	lw	t2,0(t3)
    3ec8:	01051513          	slli	a0,a0,0x10
    3ecc:	01055793          	srli	a5,a0,0x10
    3ed0:	007e8eb3          	add	t4,t4,t2
    3ed4:	edd65ce3          	bge	a2,t4,3dac <matrix_sum+0x1c0>
    3ed8:	00a78e93          	addi	t4,a5,10
    3edc:	004e2f83          	lw	t6,4(t3)
    3ee0:	010e9513          	slli	a0,t4,0x10
    3ee4:	41055793          	srai	a5,a0,0x10
    3ee8:	00000e93          	li	t4,0
    3eec:	01079293          	slli	t0,a5,0x10
    3ef0:	01fe8533          	add	a0,t4,t6
    3ef4:	004e0e13          	addi	t3,t3,4
    3ef8:	0102d793          	srli	a5,t0,0x10
    3efc:	eca64ce3          	blt	a2,a0,3dd4 <matrix_sum+0x1e8>
    3f00:	01f3a3b3          	slt	t2,t2,t6
    3f04:	00778f33          	add	t5,a5,t2
    3f08:	004e2383          	lw	t2,4(t3)
    3f0c:	010f1e93          	slli	t4,t5,0x10
    3f10:	410ed293          	srai	t0,t4,0x10
    3f14:	01029f13          	slli	t5,t0,0x10
    3f18:	007502b3          	add	t0,a0,t2
    3f1c:	010f5e93          	srli	t4,t5,0x10
    3f20:	ec564ce3          	blt	a2,t0,3df8 <matrix_sum+0x20c>
    3f24:	007fafb3          	slt	t6,t6,t2
    3f28:	01fe87b3          	add	a5,t4,t6
    3f2c:	008e2f83          	lw	t6,8(t3)
    3f30:	01079513          	slli	a0,a5,0x10
    3f34:	41055f13          	srai	t5,a0,0x10
    3f38:	010f1793          	slli	a5,t5,0x10
    3f3c:	01f28533          	add	a0,t0,t6
    3f40:	0107de93          	srli	t4,a5,0x10
    3f44:	eca64ce3          	blt	a2,a0,3e1c <matrix_sum+0x230>
    3f48:	01f3a3b3          	slt	t2,t2,t6
    3f4c:	007e8f33          	add	t5,t4,t2
    3f50:	00ce2383          	lw	t2,12(t3)
    3f54:	010f1293          	slli	t0,t5,0x10
    3f58:	4102d793          	srai	a5,t0,0x10
    3f5c:	01079f13          	slli	t5,a5,0x10
    3f60:	00750533          	add	a0,a0,t2
    3f64:	010f5293          	srli	t0,t5,0x10
    3f68:	eca64ce3          	blt	a2,a0,3e40 <matrix_sum+0x254>
    3f6c:	007fafb3          	slt	t6,t6,t2
    3f70:	01f287b3          	add	a5,t0,t6
    3f74:	010e2f83          	lw	t6,16(t3)
    3f78:	01079e93          	slli	t4,a5,0x10
    3f7c:	410edf13          	srai	t5,t4,0x10
    3f80:	010f1793          	slli	a5,t5,0x10
    3f84:	01f502b3          	add	t0,a0,t6
    3f88:	0107de93          	srli	t4,a5,0x10
    3f8c:	ec564ce3          	blt	a2,t0,3e64 <matrix_sum+0x278>
    3f90:	01f3a3b3          	slt	t2,t2,t6
    3f94:	007e8f33          	add	t5,t4,t2
    3f98:	014e2383          	lw	t2,20(t3)
    3f9c:	010f1513          	slli	a0,t5,0x10
    3fa0:	41055793          	srai	a5,a0,0x10
    3fa4:	01079f13          	slli	t5,a5,0x10
    3fa8:	00728533          	add	a0,t0,t2
    3fac:	010f5793          	srli	a5,t5,0x10
    3fb0:	eca64ce3          	blt	a2,a0,3e88 <matrix_sum+0x29c>
    3fb4:	007fafb3          	slt	t6,t6,t2
    3fb8:	01f78eb3          	add	t4,a5,t6
    3fbc:	010e9293          	slli	t0,t4,0x10
    3fc0:	018e2f83          	lw	t6,24(t3)
    3fc4:	4102df13          	srai	t5,t0,0x10
    3fc8:	010f1e93          	slli	t4,t5,0x10
    3fcc:	010ed293          	srli	t0,t4,0x10
    3fd0:	01f50eb3          	add	t4,a0,t6
    3fd4:	edd64ce3          	blt	a2,t4,3eac <matrix_sum+0x2c0>
    3fd8:	01f3a3b3          	slt	t2,t2,t6
    3fdc:	00728f33          	add	t5,t0,t2
    3fe0:	010f1793          	slli	a5,t5,0x10
    3fe4:	4107d513          	srai	a0,a5,0x10
    3fe8:	ed5ff06f          	j	3ebc <matrix_sum+0x2d0>
    3fec:	01f2a3b3          	slt	t2,t0,t6
    3ff0:	007507b3          	add	a5,a0,t2
    3ff4:	01079293          	slli	t0,a5,0x10
    3ff8:	4102d513          	srai	a0,t0,0x10
    3ffc:	d99ff06f          	j	3d94 <matrix_sum+0x1a8>
    4000:	01f3af33          	slt	t5,t2,t6
    4004:	01e28533          	add	a0,t0,t5
    4008:	01051393          	slli	t2,a0,0x10
    400c:	4103d513          	srai	a0,t2,0x10
    4010:	d59ff06f          	j	3d68 <matrix_sum+0x17c>
    4014:	01f2a3b3          	slt	t2,t0,t6
    4018:	00778f33          	add	t5,a5,t2
    401c:	010f1293          	slli	t0,t5,0x10
    4020:	4102d513          	srai	a0,t0,0x10
    4024:	d19ff06f          	j	3d3c <matrix_sum+0x150>
    4028:	01f3a2b3          	slt	t0,t2,t6
    402c:	005507b3          	add	a5,a0,t0
    4030:	01079393          	slli	t2,a5,0x10
    4034:	4103d513          	srai	a0,t2,0x10
    4038:	cd9ff06f          	j	3d10 <matrix_sum+0x124>
    403c:	01f2af33          	slt	t5,t0,t6
    4040:	01e38533          	add	a0,t2,t5
    4044:	01051293          	slli	t0,a0,0x10
    4048:	4102d513          	srai	a0,t0,0x10
    404c:	c99ff06f          	j	3ce4 <matrix_sum+0xf8>
    4050:	01ff27b3          	slt	a5,t5,t6
    4054:	00f283b3          	add	t2,t0,a5
    4058:	01039f13          	slli	t5,t2,0x10
    405c:	410f5513          	srai	a0,t5,0x10
    4060:	c59ff06f          	j	3cb8 <matrix_sum+0xcc>
    4064:	01fe27b3          	slt	a5,t3,t6
    4068:	00ff02b3          	add	t0,t5,a5
    406c:	01029393          	slli	t2,t0,0x10
    4070:	4103d513          	srai	a0,t2,0x10
    4074:	c19ff06f          	j	3c8c <matrix_sum+0xa0>
    4078:	00000513          	li	a0,0
    407c:	00008067          	ret

00004080 <matrix_mul_const>:
    4080:	1a050663          	beqz	a0,422c <matrix_mul_const+0x1ac>
    4084:	ff010113          	addi	sp,sp,-16
    4088:	00812623          	sw	s0,12(sp)
    408c:	40a003b3          	neg	t2,a0
    4090:	00151413          	slli	s0,a0,0x1
    4094:	00912423          	sw	s1,8(sp)
    4098:	01212223          	sw	s2,4(sp)
    409c:	01312023          	sw	s3,0(sp)
    40a0:	00860833          	add	a6,a2,s0
    40a4:	00000f93          	li	t6,0
    40a8:	00000293          	li	t0,0
    40ac:	00239393          	slli	t2,t2,0x2
    40b0:	408808b3          	sub	a7,a6,s0
    40b4:	41180633          	sub	a2,a6,a7
    40b8:	ffe60313          	addi	t1,a2,-2
    40bc:	00135493          	srli	s1,t1,0x1
    40c0:	00148713          	addi	a4,s1,1
    40c4:	002f9793          	slli	a5,t6,0x2
    40c8:	00777913          	andi	s2,a4,7
    40cc:	00f587b3          	add	a5,a1,a5
    40d0:	00088713          	mv	a4,a7
    40d4:	0c090263          	beqz	s2,4198 <matrix_mul_const+0x118>
    40d8:	00100993          	li	s3,1
    40dc:	0b390263          	beq	s2,s3,4180 <matrix_mul_const+0x100>
    40e0:	00200e13          	li	t3,2
    40e4:	09c90463          	beq	s2,t3,416c <matrix_mul_const+0xec>
    40e8:	00300e93          	li	t4,3
    40ec:	07d90663          	beq	s2,t4,4158 <matrix_mul_const+0xd8>
    40f0:	00400f13          	li	t5,4
    40f4:	05e90863          	beq	s2,t5,4144 <matrix_mul_const+0xc4>
    40f8:	00500613          	li	a2,5
    40fc:	02c90a63          	beq	s2,a2,4130 <matrix_mul_const+0xb0>
    4100:	00600313          	li	t1,6
    4104:	00690c63          	beq	s2,t1,411c <matrix_mul_const+0x9c>
    4108:	00089483          	lh	s1,0(a7)
    410c:	00288713          	addi	a4,a7,2
    4110:	00478793          	addi	a5,a5,4
    4114:	02d48933          	mul	s2,s1,a3
    4118:	ff27ae23          	sw	s2,-4(a5)
    411c:	00071983          	lh	s3,0(a4)
    4120:	00478793          	addi	a5,a5,4
    4124:	00270713          	addi	a4,a4,2
    4128:	02d98e33          	mul	t3,s3,a3
    412c:	ffc7ae23          	sw	t3,-4(a5)
    4130:	00071e83          	lh	t4,0(a4)
    4134:	00478793          	addi	a5,a5,4
    4138:	00270713          	addi	a4,a4,2
    413c:	02de8f33          	mul	t5,t4,a3
    4140:	ffe7ae23          	sw	t5,-4(a5)
    4144:	00071603          	lh	a2,0(a4)
    4148:	00478793          	addi	a5,a5,4
    414c:	00270713          	addi	a4,a4,2
    4150:	02d60333          	mul	t1,a2,a3
    4154:	fe67ae23          	sw	t1,-4(a5)
    4158:	00071483          	lh	s1,0(a4)
    415c:	00478793          	addi	a5,a5,4
    4160:	00270713          	addi	a4,a4,2
    4164:	02d48933          	mul	s2,s1,a3
    4168:	ff27ae23          	sw	s2,-4(a5)
    416c:	00071983          	lh	s3,0(a4)
    4170:	00478793          	addi	a5,a5,4
    4174:	00270713          	addi	a4,a4,2
    4178:	02d98e33          	mul	t3,s3,a3
    417c:	ffc7ae23          	sw	t3,-4(a5)
    4180:	00071e83          	lh	t4,0(a4)
    4184:	00478793          	addi	a5,a5,4
    4188:	00270713          	addi	a4,a4,2
    418c:	02de8f33          	mul	t5,t4,a3
    4190:	ffe7ae23          	sw	t5,-4(a5)
    4194:	06e80863          	beq	a6,a4,4204 <matrix_mul_const+0x184>
    4198:	00071983          	lh	s3,0(a4)
    419c:	00271903          	lh	s2,2(a4)
    41a0:	00471483          	lh	s1,4(a4)
    41a4:	00671f03          	lh	t5,6(a4)
    41a8:	00871e83          	lh	t4,8(a4)
    41ac:	00a71e03          	lh	t3,10(a4)
    41b0:	00c71303          	lh	t1,12(a4)
    41b4:	00e71603          	lh	a2,14(a4)
    41b8:	02d989b3          	mul	s3,s3,a3
    41bc:	01070713          	addi	a4,a4,16
    41c0:	02078793          	addi	a5,a5,32
    41c4:	02d90933          	mul	s2,s2,a3
    41c8:	ff37a023          	sw	s3,-32(a5)
    41cc:	02d484b3          	mul	s1,s1,a3
    41d0:	ff27a223          	sw	s2,-28(a5)
    41d4:	02df0f33          	mul	t5,t5,a3
    41d8:	fe97a423          	sw	s1,-24(a5)
    41dc:	02de8eb3          	mul	t4,t4,a3
    41e0:	ffe7a623          	sw	t5,-20(a5)
    41e4:	02de0e33          	mul	t3,t3,a3
    41e8:	ffd7a823          	sw	t4,-16(a5)
    41ec:	02d30333          	mul	t1,t1,a3
    41f0:	ffc7aa23          	sw	t3,-12(a5)
    41f4:	02d60633          	mul	a2,a2,a3
    41f8:	fe67ac23          	sw	t1,-8(a5)
    41fc:	fec7ae23          	sw	a2,-4(a5)
    4200:	f8e81ce3          	bne	a6,a4,4198 <matrix_mul_const+0x118>
    4204:	00128293          	addi	t0,t0,1
    4208:	00af8fb3          	add	t6,t6,a0
    420c:	40788833          	sub	a6,a7,t2
    4210:	ea5510e3          	bne	a0,t0,40b0 <matrix_mul_const+0x30>
    4214:	00c12403          	lw	s0,12(sp)
    4218:	00812483          	lw	s1,8(sp)
    421c:	00412903          	lw	s2,4(sp)
    4220:	00012983          	lw	s3,0(sp)
    4224:	01010113          	addi	sp,sp,16
    4228:	00008067          	ret
    422c:	00008067          	ret

00004230 <matrix_add_const>:
    4230:	22050c63          	beqz	a0,4468 <matrix_add_const+0x238>
    4234:	01061693          	slli	a3,a2,0x10
    4238:	00151393          	slli	t2,a0,0x1
    423c:	40a002b3          	neg	t0,a0
    4240:	0106d693          	srli	a3,a3,0x10
    4244:	00758633          	add	a2,a1,t2
    4248:	00000f93          	li	t6,0
    424c:	00229293          	slli	t0,t0,0x2
    4250:	407605b3          	sub	a1,a2,t2
    4254:	40b60733          	sub	a4,a2,a1
    4258:	ffe70313          	addi	t1,a4,-2
    425c:	00135793          	srli	a5,t1,0x1
    4260:	00178813          	addi	a6,a5,1
    4264:	00787893          	andi	a7,a6,7
    4268:	00058793          	mv	a5,a1
    426c:	0a088463          	beqz	a7,4314 <matrix_add_const+0xe4>
    4270:	00100e13          	li	t3,1
    4274:	09c88663          	beq	a7,t3,4300 <matrix_add_const+0xd0>
    4278:	00200e93          	li	t4,2
    427c:	07d88a63          	beq	a7,t4,42f0 <matrix_add_const+0xc0>
    4280:	00300f13          	li	t5,3
    4284:	05e88e63          	beq	a7,t5,42e0 <matrix_add_const+0xb0>
    4288:	00400713          	li	a4,4
    428c:	04e88263          	beq	a7,a4,42d0 <matrix_add_const+0xa0>
    4290:	00500313          	li	t1,5
    4294:	02688663          	beq	a7,t1,42c0 <matrix_add_const+0x90>
    4298:	00600813          	li	a6,6
    429c:	01088a63          	beq	a7,a6,42b0 <matrix_add_const+0x80>
    42a0:	0005d883          	lhu	a7,0(a1)
    42a4:	00258793          	addi	a5,a1,2
    42a8:	01168e33          	add	t3,a3,a7
    42ac:	01c59023          	sh	t3,0(a1)
    42b0:	0007de83          	lhu	t4,0(a5)
    42b4:	00278793          	addi	a5,a5,2
    42b8:	01d68f33          	add	t5,a3,t4
    42bc:	ffe79f23          	sh	t5,-2(a5)
    42c0:	0007d703          	lhu	a4,0(a5)
    42c4:	00278793          	addi	a5,a5,2
    42c8:	00e68333          	add	t1,a3,a4
    42cc:	fe679f23          	sh	t1,-2(a5)
    42d0:	0007d803          	lhu	a6,0(a5)
    42d4:	00278793          	addi	a5,a5,2
    42d8:	010688b3          	add	a7,a3,a6
    42dc:	ff179f23          	sh	a7,-2(a5)
    42e0:	0007de03          	lhu	t3,0(a5)
    42e4:	00278793          	addi	a5,a5,2
    42e8:	01c68eb3          	add	t4,a3,t3
    42ec:	ffd79f23          	sh	t4,-2(a5)
    42f0:	0007df03          	lhu	t5,0(a5)
    42f4:	00278793          	addi	a5,a5,2
    42f8:	01e68733          	add	a4,a3,t5
    42fc:	fee79f23          	sh	a4,-2(a5)
    4300:	0007d303          	lhu	t1,0(a5)
    4304:	00278793          	addi	a5,a5,2
    4308:	00668833          	add	a6,a3,t1
    430c:	ff079f23          	sh	a6,-2(a5)
    4310:	14f60663          	beq	a2,a5,445c <matrix_add_const+0x22c>
    4314:	ff010113          	addi	sp,sp,-16
    4318:	00812623          	sw	s0,12(sp)
    431c:	0007d403          	lhu	s0,0(a5)
    4320:	0027df03          	lhu	t5,2(a5)
    4324:	0047de83          	lhu	t4,4(a5)
    4328:	0067de03          	lhu	t3,6(a5)
    432c:	0087d303          	lhu	t1,8(a5)
    4330:	00a7d883          	lhu	a7,10(a5)
    4334:	00c7d803          	lhu	a6,12(a5)
    4338:	00e7d703          	lhu	a4,14(a5)
    433c:	00868433          	add	s0,a3,s0
    4340:	01e68f33          	add	t5,a3,t5
    4344:	01d68eb3          	add	t4,a3,t4
    4348:	01c68e33          	add	t3,a3,t3
    434c:	00668333          	add	t1,a3,t1
    4350:	011688b3          	add	a7,a3,a7
    4354:	01068833          	add	a6,a3,a6
    4358:	00e68733          	add	a4,a3,a4
    435c:	00879023          	sh	s0,0(a5)
    4360:	01e79123          	sh	t5,2(a5)
    4364:	01d79223          	sh	t4,4(a5)
    4368:	01c79323          	sh	t3,6(a5)
    436c:	00679423          	sh	t1,8(a5)
    4370:	01179523          	sh	a7,10(a5)
    4374:	01079623          	sh	a6,12(a5)
    4378:	00e79723          	sh	a4,14(a5)
    437c:	01078793          	addi	a5,a5,16
    4380:	f8f61ee3          	bne	a2,a5,431c <matrix_add_const+0xec>
    4384:	001f8f93          	addi	t6,t6,1
    4388:	40558633          	sub	a2,a1,t0
    438c:	0df50263          	beq	a0,t6,4450 <matrix_add_const+0x220>
    4390:	407605b3          	sub	a1,a2,t2
    4394:	40b607b3          	sub	a5,a2,a1
    4398:	ffe78413          	addi	s0,a5,-2
    439c:	00145f13          	srli	t5,s0,0x1
    43a0:	001f0e93          	addi	t4,t5,1
    43a4:	007efe13          	andi	t3,t4,7
    43a8:	00058793          	mv	a5,a1
    43ac:	f60e08e3          	beqz	t3,431c <matrix_add_const+0xec>
    43b0:	00100313          	li	t1,1
    43b4:	066e0e63          	beq	t3,t1,4430 <matrix_add_const+0x200>
    43b8:	00200893          	li	a7,2
    43bc:	071e0263          	beq	t3,a7,4420 <matrix_add_const+0x1f0>
    43c0:	00300813          	li	a6,3
    43c4:	050e0663          	beq	t3,a6,4410 <matrix_add_const+0x1e0>
    43c8:	00400713          	li	a4,4
    43cc:	02ee0a63          	beq	t3,a4,4400 <matrix_add_const+0x1d0>
    43d0:	00500413          	li	s0,5
    43d4:	008e0e63          	beq	t3,s0,43f0 <matrix_add_const+0x1c0>
    43d8:	00600f13          	li	t5,6
    43dc:	09ee1863          	bne	t3,t5,446c <matrix_add_const+0x23c>
    43e0:	0007d303          	lhu	t1,0(a5)
    43e4:	00278793          	addi	a5,a5,2
    43e8:	006688b3          	add	a7,a3,t1
    43ec:	ff179f23          	sh	a7,-2(a5)
    43f0:	0007d803          	lhu	a6,0(a5)
    43f4:	00278793          	addi	a5,a5,2
    43f8:	01068733          	add	a4,a3,a6
    43fc:	fee79f23          	sh	a4,-2(a5)
    4400:	0007d403          	lhu	s0,0(a5)
    4404:	00278793          	addi	a5,a5,2
    4408:	00868f33          	add	t5,a3,s0
    440c:	ffe79f23          	sh	t5,-2(a5)
    4410:	0007de83          	lhu	t4,0(a5)
    4414:	00278793          	addi	a5,a5,2
    4418:	01d68e33          	add	t3,a3,t4
    441c:	ffc79f23          	sh	t3,-2(a5)
    4420:	0007d303          	lhu	t1,0(a5)
    4424:	00278793          	addi	a5,a5,2
    4428:	006688b3          	add	a7,a3,t1
    442c:	ff179f23          	sh	a7,-2(a5)
    4430:	0007d803          	lhu	a6,0(a5)
    4434:	00278793          	addi	a5,a5,2
    4438:	01068733          	add	a4,a3,a6
    443c:	fee79f23          	sh	a4,-2(a5)
    4440:	ecf61ee3          	bne	a2,a5,431c <matrix_add_const+0xec>
    4444:	001f8f93          	addi	t6,t6,1
    4448:	40558633          	sub	a2,a1,t0
    444c:	f5f512e3          	bne	a0,t6,4390 <matrix_add_const+0x160>
    4450:	00c12403          	lw	s0,12(sp)
    4454:	01010113          	addi	sp,sp,16
    4458:	00008067          	ret
    445c:	001f8f93          	addi	t6,t6,1
    4460:	40558633          	sub	a2,a1,t0
    4464:	dff516e3          	bne	a0,t6,4250 <matrix_add_const+0x20>
    4468:	00008067          	ret
    446c:	0005de83          	lhu	t4,0(a1)
    4470:	00258793          	addi	a5,a1,2
    4474:	01d68e33          	add	t3,a3,t4
    4478:	01c59023          	sh	t3,0(a1)
    447c:	f65ff06f          	j	43e0 <matrix_add_const+0x1b0>

00004480 <matrix_mul_vect>:
    4480:	20050a63          	beqz	a0,4694 <matrix_mul_vect+0x214>
    4484:	fd010113          	addi	sp,sp,-48
    4488:	00251e93          	slli	t4,a0,0x2
    448c:	00151313          	slli	t1,a0,0x1
    4490:	02812623          	sw	s0,44(sp)
    4494:	02912423          	sw	s1,40(sp)
    4498:	03212223          	sw	s2,36(sp)
    449c:	03312023          	sw	s3,32(sp)
    44a0:	01412e23          	sw	s4,28(sp)
    44a4:	01512c23          	sw	s5,24(sp)
    44a8:	01612a23          	sw	s6,20(sp)
    44ac:	01712823          	sw	s7,16(sp)
    44b0:	01812623          	sw	s8,12(sp)
    44b4:	01912423          	sw	s9,8(sp)
    44b8:	00058893          	mv	a7,a1
    44bc:	01d58eb3          	add	t4,a1,t4
    44c0:	00668333          	add	t1,a3,t1
    44c4:	00000e13          	li	t3,0
    44c8:	40d305b3          	sub	a1,t1,a3
    44cc:	ffe58293          	addi	t0,a1,-2
    44d0:	0012d393          	srli	t2,t0,0x1
    44d4:	00138413          	addi	s0,t2,1
    44d8:	001e1793          	slli	a5,t3,0x1
    44dc:	00747493          	andi	s1,s0,7
    44e0:	00f607b3          	add	a5,a2,a5
    44e4:	00068713          	mv	a4,a3
    44e8:	00000813          	li	a6,0
    44ec:	0c048e63          	beqz	s1,45c8 <matrix_mul_vect+0x148>
    44f0:	00100f13          	li	t5,1
    44f4:	0be48c63          	beq	s1,t5,45ac <matrix_mul_vect+0x12c>
    44f8:	00200913          	li	s2,2
    44fc:	09248c63          	beq	s1,s2,4594 <matrix_mul_vect+0x114>
    4500:	00300993          	li	s3,3
    4504:	07348c63          	beq	s1,s3,457c <matrix_mul_vect+0xfc>
    4508:	00400a13          	li	s4,4
    450c:	05448c63          	beq	s1,s4,4564 <matrix_mul_vect+0xe4>
    4510:	00500a93          	li	s5,5
    4514:	03548c63          	beq	s1,s5,454c <matrix_mul_vect+0xcc>
    4518:	00600b13          	li	s6,6
    451c:	01648c63          	beq	s1,s6,4534 <matrix_mul_vect+0xb4>
    4520:	00079803          	lh	a6,0(a5)
    4524:	00069b83          	lh	s7,0(a3)
    4528:	00278793          	addi	a5,a5,2
    452c:	00268713          	addi	a4,a3,2
    4530:	03780833          	mul	a6,a6,s7
    4534:	00079c03          	lh	s8,0(a5)
    4538:	00071c83          	lh	s9,0(a4)
    453c:	00278793          	addi	a5,a5,2
    4540:	00270713          	addi	a4,a4,2
    4544:	039c0fb3          	mul	t6,s8,s9
    4548:	01f80833          	add	a6,a6,t6
    454c:	00079583          	lh	a1,0(a5)
    4550:	00071283          	lh	t0,0(a4)
    4554:	00278793          	addi	a5,a5,2
    4558:	00270713          	addi	a4,a4,2
    455c:	025583b3          	mul	t2,a1,t0
    4560:	00780833          	add	a6,a6,t2
    4564:	00079403          	lh	s0,0(a5)
    4568:	00071483          	lh	s1,0(a4)
    456c:	00278793          	addi	a5,a5,2
    4570:	00270713          	addi	a4,a4,2
    4574:	02940f33          	mul	t5,s0,s1
    4578:	01e80833          	add	a6,a6,t5
    457c:	00079903          	lh	s2,0(a5)
    4580:	00071983          	lh	s3,0(a4)
    4584:	00278793          	addi	a5,a5,2
    4588:	00270713          	addi	a4,a4,2
    458c:	03390a33          	mul	s4,s2,s3
    4590:	01480833          	add	a6,a6,s4
    4594:	00079a83          	lh	s5,0(a5)
    4598:	00071b03          	lh	s6,0(a4)
    459c:	00278793          	addi	a5,a5,2
    45a0:	00270713          	addi	a4,a4,2
    45a4:	036a8bb3          	mul	s7,s5,s6
    45a8:	01780833          	add	a6,a6,s7
    45ac:	00079c03          	lh	s8,0(a5)
    45b0:	00071c83          	lh	s9,0(a4)
    45b4:	00270713          	addi	a4,a4,2
    45b8:	00278793          	addi	a5,a5,2
    45bc:	039c0fb3          	mul	t6,s8,s9
    45c0:	01f80833          	add	a6,a6,t6
    45c4:	08e30863          	beq	t1,a4,4654 <matrix_mul_vect+0x1d4>
    45c8:	00071283          	lh	t0,0(a4)
    45cc:	00079583          	lh	a1,0(a5)
    45d0:	00271c83          	lh	s9,2(a4)
    45d4:	00279a83          	lh	s5,2(a5)
    45d8:	00479903          	lh	s2,4(a5)
    45dc:	00471c03          	lh	s8,4(a4)
    45e0:	025585b3          	mul	a1,a1,t0
    45e4:	00679403          	lh	s0,6(a5)
    45e8:	00671b83          	lh	s7,6(a4)
    45ec:	00879383          	lh	t2,8(a5)
    45f0:	00871b03          	lh	s6,8(a4)
    45f4:	00a79283          	lh	t0,10(a5)
    45f8:	00a71a03          	lh	s4,10(a4)
    45fc:	00c79f83          	lh	t6,12(a5)
    4600:	00c71983          	lh	s3,12(a4)
    4604:	00e79f03          	lh	t5,14(a5)
    4608:	039a8ab3          	mul	s5,s5,s9
    460c:	00e71483          	lh	s1,14(a4)
    4610:	00b80833          	add	a6,a6,a1
    4614:	01070713          	addi	a4,a4,16
    4618:	01078793          	addi	a5,a5,16
    461c:	03890cb3          	mul	s9,s2,s8
    4620:	01580933          	add	s2,a6,s5
    4624:	03740c33          	mul	s8,s0,s7
    4628:	01990433          	add	s0,s2,s9
    462c:	03638bb3          	mul	s7,t2,s6
    4630:	018405b3          	add	a1,s0,s8
    4634:	034283b3          	mul	t2,t0,s4
    4638:	01758b33          	add	s6,a1,s7
    463c:	033f82b3          	mul	t0,t6,s3
    4640:	007b0a33          	add	s4,s6,t2
    4644:	029f0fb3          	mul	t6,t5,s1
    4648:	005a09b3          	add	s3,s4,t0
    464c:	01f98833          	add	a6,s3,t6
    4650:	f6e31ce3          	bne	t1,a4,45c8 <matrix_mul_vect+0x148>
    4654:	0108a023          	sw	a6,0(a7)
    4658:	00488893          	addi	a7,a7,4
    465c:	00ae0e33          	add	t3,t3,a0
    4660:	e71e94e3          	bne	t4,a7,44c8 <matrix_mul_vect+0x48>
    4664:	02c12403          	lw	s0,44(sp)
    4668:	02812483          	lw	s1,40(sp)
    466c:	02412903          	lw	s2,36(sp)
    4670:	02012983          	lw	s3,32(sp)
    4674:	01c12a03          	lw	s4,28(sp)
    4678:	01812a83          	lw	s5,24(sp)
    467c:	01412b03          	lw	s6,20(sp)
    4680:	01012b83          	lw	s7,16(sp)
    4684:	00c12c03          	lw	s8,12(sp)
    4688:	00812c83          	lw	s9,8(sp)
    468c:	03010113          	addi	sp,sp,48
    4690:	00008067          	ret
    4694:	00008067          	ret

00004698 <matrix_mul_matrix>:
    4698:	28050063          	beqz	a0,4918 <matrix_mul_matrix+0x280>
    469c:	fc010113          	addi	sp,sp,-64
    46a0:	00060393          	mv	t2,a2
    46a4:	00151613          	slli	a2,a0,0x1
    46a8:	02912c23          	sw	s1,56(sp)
    46ac:	03212a23          	sw	s2,52(sp)
    46b0:	03312823          	sw	s3,48(sp)
    46b4:	02812e23          	sw	s0,60(sp)
    46b8:	00068993          	mv	s3,a3
    46bc:	03412623          	sw	s4,44(sp)
    46c0:	03512423          	sw	s5,40(sp)
    46c4:	03612223          	sw	s6,36(sp)
    46c8:	03712023          	sw	s7,32(sp)
    46cc:	01812e23          	sw	s8,28(sp)
    46d0:	01912c23          	sw	s9,24(sp)
    46d4:	01a12a23          	sw	s10,20(sp)
    46d8:	01b12823          	sw	s11,16(sp)
    46dc:	00050913          	mv	s2,a0
    46e0:	00c38fb3          	add	t6,t2,a2
    46e4:	00000693          	li	a3,0
    46e8:	00000493          	li	s1,0
    46ec:	00269413          	slli	s0,a3,0x2
    46f0:	00858433          	add	s0,a1,s0
    46f4:	00098293          	mv	t0,s3
    46f8:	00000a13          	li	s4,0
    46fc:	00b12623          	sw	a1,12(sp)
    4700:	407f8833          	sub	a6,t6,t2
    4704:	ffe80313          	addi	t1,a6,-2
    4708:	00135513          	srli	a0,t1,0x1
    470c:	00150593          	addi	a1,a0,1
    4710:	0075f713          	andi	a4,a1,7
    4714:	00038513          	mv	a0,t2
    4718:	00028593          	mv	a1,t0
    471c:	00000793          	li	a5,0
    4720:	0c070e63          	beqz	a4,47fc <matrix_mul_matrix+0x164>
    4724:	00100893          	li	a7,1
    4728:	0b170c63          	beq	a4,a7,47e0 <matrix_mul_matrix+0x148>
    472c:	00200a93          	li	s5,2
    4730:	09570c63          	beq	a4,s5,47c8 <matrix_mul_matrix+0x130>
    4734:	00300b13          	li	s6,3
    4738:	07670c63          	beq	a4,s6,47b0 <matrix_mul_matrix+0x118>
    473c:	00400b93          	li	s7,4
    4740:	05770c63          	beq	a4,s7,4798 <matrix_mul_matrix+0x100>
    4744:	00500c13          	li	s8,5
    4748:	03870c63          	beq	a4,s8,4780 <matrix_mul_matrix+0xe8>
    474c:	00600c93          	li	s9,6
    4750:	01970c63          	beq	a4,s9,4768 <matrix_mul_matrix+0xd0>
    4754:	00039783          	lh	a5,0(t2)
    4758:	00029d03          	lh	s10,0(t0)
    475c:	00238513          	addi	a0,t2,2
    4760:	00c285b3          	add	a1,t0,a2
    4764:	03a787b3          	mul	a5,a5,s10
    4768:	00051d83          	lh	s11,0(a0)
    476c:	00059e03          	lh	t3,0(a1)
    4770:	00250513          	addi	a0,a0,2
    4774:	00c585b3          	add	a1,a1,a2
    4778:	03cd8eb3          	mul	t4,s11,t3
    477c:	01d787b3          	add	a5,a5,t4
    4780:	00051f03          	lh	t5,0(a0)
    4784:	00059803          	lh	a6,0(a1)
    4788:	00250513          	addi	a0,a0,2
    478c:	00c585b3          	add	a1,a1,a2
    4790:	030f0333          	mul	t1,t5,a6
    4794:	006787b3          	add	a5,a5,t1
    4798:	00051703          	lh	a4,0(a0)
    479c:	00059883          	lh	a7,0(a1)
    47a0:	00250513          	addi	a0,a0,2
    47a4:	00c585b3          	add	a1,a1,a2
    47a8:	03170ab3          	mul	s5,a4,a7
    47ac:	015787b3          	add	a5,a5,s5
    47b0:	00051b03          	lh	s6,0(a0)
    47b4:	00059b83          	lh	s7,0(a1)
    47b8:	00250513          	addi	a0,a0,2
    47bc:	00c585b3          	add	a1,a1,a2
    47c0:	037b0c33          	mul	s8,s6,s7
    47c4:	018787b3          	add	a5,a5,s8
    47c8:	00051c83          	lh	s9,0(a0)
    47cc:	00059d03          	lh	s10,0(a1)
    47d0:	00250513          	addi	a0,a0,2
    47d4:	00c585b3          	add	a1,a1,a2
    47d8:	03ac8db3          	mul	s11,s9,s10
    47dc:	01b787b3          	add	a5,a5,s11
    47e0:	00051e03          	lh	t3,0(a0)
    47e4:	00059e83          	lh	t4,0(a1)
    47e8:	00250513          	addi	a0,a0,2
    47ec:	00c585b3          	add	a1,a1,a2
    47f0:	03de0f33          	mul	t5,t3,t4
    47f4:	01e787b3          	add	a5,a5,t5
    47f8:	0aaf8663          	beq	t6,a0,48a4 <matrix_mul_matrix+0x20c>
    47fc:	00c58333          	add	t1,a1,a2
    4800:	00059703          	lh	a4,0(a1)
    4804:	00051803          	lh	a6,0(a0)
    4808:	00031b83          	lh	s7,0(t1)
    480c:	00251b03          	lh	s6,2(a0)
    4810:	02e80833          	mul	a6,a6,a4
    4814:	00c308b3          	add	a7,t1,a2
    4818:	00c88c33          	add	s8,a7,a2
    481c:	00089a83          	lh	s5,0(a7)
    4820:	00451d83          	lh	s11,4(a0)
    4824:	000c1d03          	lh	s10,0(s8)
    4828:	00cc0cb3          	add	s9,s8,a2
    482c:	00651f03          	lh	t5,6(a0)
    4830:	00cc85b3          	add	a1,s9,a2
    4834:	00851e83          	lh	t4,8(a0)
    4838:	037b0b33          	mul	s6,s6,s7
    483c:	000c9c83          	lh	s9,0(s9)
    4840:	00a51e03          	lh	t3,10(a0)
    4844:	00059c03          	lh	s8,0(a1)
    4848:	00c58733          	add	a4,a1,a2
    484c:	00c51303          	lh	t1,12(a0)
    4850:	00071b83          	lh	s7,0(a4)
    4854:	00c705b3          	add	a1,a4,a2
    4858:	00e51883          	lh	a7,14(a0)
    485c:	00059703          	lh	a4,0(a1)
    4860:	035d8db3          	mul	s11,s11,s5
    4864:	010787b3          	add	a5,a5,a6
    4868:	01678ab3          	add	s5,a5,s6
    486c:	01050513          	addi	a0,a0,16
    4870:	00c585b3          	add	a1,a1,a2
    4874:	03af0f33          	mul	t5,t5,s10
    4878:	01ba8833          	add	a6,s5,s11
    487c:	039e8d33          	mul	s10,t4,s9
    4880:	01e80eb3          	add	t4,a6,t5
    4884:	038e0cb3          	mul	s9,t3,s8
    4888:	01ae8e33          	add	t3,t4,s10
    488c:	03730c33          	mul	s8,t1,s7
    4890:	019e0333          	add	t1,t3,s9
    4894:	02e88b33          	mul	s6,a7,a4
    4898:	01830bb3          	add	s7,t1,s8
    489c:	016b87b3          	add	a5,s7,s6
    48a0:	f4af9ee3          	bne	t6,a0,47fc <matrix_mul_matrix+0x164>
    48a4:	00f42023          	sw	a5,0(s0)
    48a8:	001a0513          	addi	a0,s4,1
    48ac:	00440413          	addi	s0,s0,4
    48b0:	00228293          	addi	t0,t0,2
    48b4:	00a90663          	beq	s2,a0,48c0 <matrix_mul_matrix+0x228>
    48b8:	00050a13          	mv	s4,a0
    48bc:	e45ff06f          	j	4700 <matrix_mul_matrix+0x68>
    48c0:	00c12583          	lw	a1,12(sp)
    48c4:	00148413          	addi	s0,s1,1
    48c8:	00c383b3          	add	t2,t2,a2
    48cc:	012686b3          	add	a3,a3,s2
    48d0:	00cf8fb3          	add	t6,t6,a2
    48d4:	01448663          	beq	s1,s4,48e0 <matrix_mul_matrix+0x248>
    48d8:	00040493          	mv	s1,s0
    48dc:	e11ff06f          	j	46ec <matrix_mul_matrix+0x54>
    48e0:	03c12403          	lw	s0,60(sp)
    48e4:	03812483          	lw	s1,56(sp)
    48e8:	03412903          	lw	s2,52(sp)
    48ec:	03012983          	lw	s3,48(sp)
    48f0:	02c12a03          	lw	s4,44(sp)
    48f4:	02812a83          	lw	s5,40(sp)
    48f8:	02412b03          	lw	s6,36(sp)
    48fc:	02012b83          	lw	s7,32(sp)
    4900:	01c12c03          	lw	s8,28(sp)
    4904:	01812c83          	lw	s9,24(sp)
    4908:	01412d03          	lw	s10,20(sp)
    490c:	01012d83          	lw	s11,16(sp)
    4910:	04010113          	addi	sp,sp,64
    4914:	00008067          	ret
    4918:	00008067          	ret

0000491c <matrix_mul_matrix_bitextract>:
    491c:	20050863          	beqz	a0,4b2c <matrix_mul_matrix_bitextract+0x210>
    4920:	fe010113          	addi	sp,sp,-32
    4924:	00151813          	slli	a6,a0,0x1
    4928:	00812e23          	sw	s0,28(sp)
    492c:	00912c23          	sw	s1,24(sp)
    4930:	01212a23          	sw	s2,20(sp)
    4934:	01312823          	sw	s3,16(sp)
    4938:	01412623          	sw	s4,12(sp)
    493c:	01512423          	sw	s5,8(sp)
    4940:	01612223          	sw	s6,4(sp)
    4944:	00050f93          	mv	t6,a0
    4948:	00058413          	mv	s0,a1
    494c:	00068493          	mv	s1,a3
    4950:	00060e93          	mv	t4,a2
    4954:	010608b3          	add	a7,a2,a6
    4958:	00000293          	li	t0,0
    495c:	00000393          	li	t2,0
    4960:	00229e13          	slli	t3,t0,0x2
    4964:	01c40e33          	add	t3,s0,t3
    4968:	00048313          	mv	t1,s1
    496c:	00000f13          	li	t5,0
    4970:	41d887b3          	sub	a5,a7,t4
    4974:	ffe78513          	addi	a0,a5,-2
    4978:	00155593          	srli	a1,a0,0x1
    497c:	00158613          	addi	a2,a1,1
    4980:	00367993          	andi	s3,a2,3
    4984:	00030513          	mv	a0,t1
    4988:	000e8713          	mv	a4,t4
    498c:	00000913          	li	s2,0
    4990:	08098c63          	beqz	s3,4a28 <matrix_mul_matrix_bitextract+0x10c>
    4994:	00100693          	li	a3,1
    4998:	06d98063          	beq	s3,a3,49f8 <matrix_mul_matrix_bitextract+0xdc>
    499c:	00200a13          	li	s4,2
    49a0:	03498663          	beq	s3,s4,49cc <matrix_mul_matrix_bitextract+0xb0>
    49a4:	000e9903          	lh	s2,0(t4)
    49a8:	00031a83          	lh	s5,0(t1)
    49ac:	002e8713          	addi	a4,t4,2
    49b0:	01030533          	add	a0,t1,a6
    49b4:	03590b33          	mul	s6,s2,s5
    49b8:	402b5593          	srai	a1,s6,0x2
    49bc:	405b5793          	srai	a5,s6,0x5
    49c0:	00f5f613          	andi	a2,a1,15
    49c4:	07f7f993          	andi	s3,a5,127
    49c8:	03360933          	mul	s2,a2,s3
    49cc:	00071a03          	lh	s4,0(a4)
    49d0:	00051683          	lh	a3,0(a0)
    49d4:	00270713          	addi	a4,a4,2
    49d8:	01050533          	add	a0,a0,a6
    49dc:	02da0ab3          	mul	s5,s4,a3
    49e0:	402adb13          	srai	s6,s5,0x2
    49e4:	405ad593          	srai	a1,s5,0x5
    49e8:	00fb7613          	andi	a2,s6,15
    49ec:	07f5f793          	andi	a5,a1,127
    49f0:	02f609b3          	mul	s3,a2,a5
    49f4:	01390933          	add	s2,s2,s3
    49f8:	00071a03          	lh	s4,0(a4)
    49fc:	00051683          	lh	a3,0(a0)
    4a00:	00270713          	addi	a4,a4,2
    4a04:	01050533          	add	a0,a0,a6
    4a08:	02da0ab3          	mul	s5,s4,a3
    4a0c:	402adb13          	srai	s6,s5,0x2
    4a10:	405ad593          	srai	a1,s5,0x5
    4a14:	00fb7613          	andi	a2,s6,15
    4a18:	07f5f793          	andi	a5,a1,127
    4a1c:	02f609b3          	mul	s3,a2,a5
    4a20:	01390933          	add	s2,s2,s3
    4a24:	0ae88663          	beq	a7,a4,4ad0 <matrix_mul_matrix_bitextract+0x1b4>
    4a28:	01050a33          	add	s4,a0,a6
    4a2c:	00071683          	lh	a3,0(a4)
    4a30:	00051a83          	lh	s5,0(a0)
    4a34:	000a1b03          	lh	s6,0(s4)
    4a38:	010a07b3          	add	a5,s4,a6
    4a3c:	00271583          	lh	a1,2(a4)
    4a40:	00079a03          	lh	s4,0(a5)
    4a44:	01078533          	add	a0,a5,a6
    4a48:	00471603          	lh	a2,4(a4)
    4a4c:	035689b3          	mul	s3,a3,s5
    4a50:	00051a83          	lh	s5,0(a0)
    4a54:	00671683          	lh	a3,6(a4)
    4a58:	00870713          	addi	a4,a4,8
    4a5c:	01050533          	add	a0,a0,a6
    4a60:	036585b3          	mul	a1,a1,s6
    4a64:	4029d793          	srai	a5,s3,0x2
    4a68:	4059db13          	srai	s6,s3,0x5
    4a6c:	07fb7993          	andi	s3,s6,127
    4a70:	00f7f793          	andi	a5,a5,15
    4a74:	03460633          	mul	a2,a2,s4
    4a78:	4025da13          	srai	s4,a1,0x2
    4a7c:	4055d593          	srai	a1,a1,0x5
    4a80:	00fa7b13          	andi	s6,s4,15
    4a84:	07f5fa13          	andi	s4,a1,127
    4a88:	035686b3          	mul	a3,a3,s5
    4a8c:	40265a93          	srai	s5,a2,0x2
    4a90:	40565613          	srai	a2,a2,0x5
    4a94:	00faf593          	andi	a1,s5,15
    4a98:	07f67a93          	andi	s5,a2,127
    4a9c:	033787b3          	mul	a5,a5,s3
    4aa0:	4026d993          	srai	s3,a3,0x2
    4aa4:	4056d693          	srai	a3,a3,0x5
    4aa8:	00f9f613          	andi	a2,s3,15
    4aac:	07f6f993          	andi	s3,a3,127
    4ab0:	034b0b33          	mul	s6,s6,s4
    4ab4:	00f90933          	add	s2,s2,a5
    4ab8:	03558a33          	mul	s4,a1,s5
    4abc:	016905b3          	add	a1,s2,s6
    4ac0:	03360ab3          	mul	s5,a2,s3
    4ac4:	014587b3          	add	a5,a1,s4
    4ac8:	01578933          	add	s2,a5,s5
    4acc:	f4e89ee3          	bne	a7,a4,4a28 <matrix_mul_matrix_bitextract+0x10c>
    4ad0:	012e2023          	sw	s2,0(t3)
    4ad4:	001f0713          	addi	a4,t5,1
    4ad8:	004e0e13          	addi	t3,t3,4
    4adc:	00230313          	addi	t1,t1,2
    4ae0:	00ef8663          	beq	t6,a4,4aec <matrix_mul_matrix_bitextract+0x1d0>
    4ae4:	00070f13          	mv	t5,a4
    4ae8:	e89ff06f          	j	4970 <matrix_mul_matrix_bitextract+0x54>
    4aec:	00138e13          	addi	t3,t2,1
    4af0:	010e8eb3          	add	t4,t4,a6
    4af4:	01f282b3          	add	t0,t0,t6
    4af8:	010888b3          	add	a7,a7,a6
    4afc:	01e38663          	beq	t2,t5,4b08 <matrix_mul_matrix_bitextract+0x1ec>
    4b00:	000e0393          	mv	t2,t3
    4b04:	e5dff06f          	j	4960 <matrix_mul_matrix_bitextract+0x44>
    4b08:	01c12403          	lw	s0,28(sp)
    4b0c:	01812483          	lw	s1,24(sp)
    4b10:	01412903          	lw	s2,20(sp)
    4b14:	01012983          	lw	s3,16(sp)
    4b18:	00c12a03          	lw	s4,12(sp)
    4b1c:	00812a83          	lw	s5,8(sp)
    4b20:	00412b03          	lw	s6,4(sp)
    4b24:	02010113          	addi	sp,sp,32
    4b28:	00008067          	ret
    4b2c:	00008067          	ret

00004b30 <main>:
    4b30:	f7010113          	addi	sp,sp,-144
    4b34:	00810613          	addi	a2,sp,8
    4b38:	00410593          	addi	a1,sp,4
    4b3c:	04e10513          	addi	a0,sp,78
    4b40:	08112623          	sw	ra,140(sp)
    4b44:	08812423          	sw	s0,136(sp)
    4b48:	08912223          	sw	s1,132(sp)
    4b4c:	09212023          	sw	s2,128(sp)
    4b50:	07312e23          	sw	s3,124(sp)
    4b54:	07412c23          	sw	s4,120(sp)
    4b58:	07512a23          	sw	s5,116(sp)
    4b5c:	07612823          	sw	s6,112(sp)
    4b60:	07712623          	sw	s7,108(sp)
    4b64:	07812423          	sw	s8,104(sp)
    4b68:	07912223          	sw	s9,100(sp)
    4b6c:	07a12023          	sw	s10,96(sp)
    4b70:	05b12e23          	sw	s11,92(sp)
    4b74:	00012223          	sw	zero,4(sp)
    4b78:	e00fb0ef          	jal	ra,178 <portable_init>
    4b7c:	00100513          	li	a0,1
    4b80:	859fe0ef          	jal	ra,33d8 <get_seed_32>
    4b84:	00050793          	mv	a5,a0
    4b88:	00200513          	li	a0,2
    4b8c:	00f11623          	sh	a5,12(sp)
    4b90:	849fe0ef          	jal	ra,33d8 <get_seed_32>
    4b94:	00050293          	mv	t0,a0
    4b98:	00300513          	li	a0,3
    4b9c:	00511723          	sh	t0,14(sp)
    4ba0:	839fe0ef          	jal	ra,33d8 <get_seed_32>
    4ba4:	00050313          	mv	t1,a0
    4ba8:	00400513          	li	a0,4
    4bac:	00611823          	sh	t1,16(sp)
    4bb0:	829fe0ef          	jal	ra,33d8 <get_seed_32>
    4bb4:	00050393          	mv	t2,a0
    4bb8:	00500513          	li	a0,5
    4bbc:	02712423          	sw	t2,40(sp)
    4bc0:	819fe0ef          	jal	ra,33d8 <get_seed_32>
    4bc4:	00051463          	bnez	a0,4bcc <main+0x9c>
    4bc8:	00700513          	li	a0,7
    4bcc:	00c12083          	lw	ra,12(sp)
    4bd0:	02a12623          	sw	a0,44(sp)
    4bd4:	04009c63          	bnez	ra,4c2c <main+0xfc>
    4bd8:	01011603          	lh	a2,16(sp)
    4bdc:	06060663          	beqz	a2,4c48 <main+0x118>
    4be0:	0000d837          	lui	a6,0xd
    4be4:	1b880993          	addi	s3,a6,440 # d1b8 <static_memblk>
    4be8:	00257a13          	andi	s4,a0,2
    4bec:	00157913          	andi	s2,a0,1
    4bf0:	014038b3          	snez	a7,s4
    4bf4:	01312a23          	sw	s3,20(sp)
    4bf8:	04011623          	sh	zero,76(sp)
    4bfc:	00457a93          	andi	s5,a0,4
    4c00:	01190bb3          	add	s7,s2,a7
    4c04:	040a9863          	bnez	s5,4c54 <main+0x124>
    4c08:	7d000513          	li	a0,2000
    4c0c:	03755533          	divu	a0,a0,s7
    4c10:	02a12223          	sw	a0,36(sp)
    4c14:	62091263          	bnez	s2,5238 <main+0x708>
    4c18:	060a0063          	beqz	s4,4c78 <main+0x148>
    4c1c:	02a90c33          	mul	s8,s2,a0
    4c20:	01898cb3          	add	s9,s3,s8
    4c24:	01912e23          	sw	s9,28(sp)
    4c28:	0500006f          	j	4c78 <main+0x148>
    4c2c:	00100713          	li	a4,1
    4c30:	fae098e3          	bne	ra,a4,4be0 <main+0xb0>
    4c34:	01011403          	lh	s0,16(sp)
    4c38:	fa0414e3          	bnez	s0,4be0 <main+0xb0>
    4c3c:	341534b7          	lui	s1,0x34153
    4c40:	41548593          	addi	a1,s1,1045 # 34153415 <_stack_top+0x3412dc15>
    4c44:	00b12623          	sw	a1,12(sp)
    4c48:	06600693          	li	a3,102
    4c4c:	00d11823          	sh	a3,16(sp)
    4c50:	f91ff06f          	j	4be0 <main+0xb0>
    4c54:	001b8d13          	addi	s10,s7,1
    4c58:	7d000d93          	li	s11,2000
    4c5c:	03add533          	divu	a0,s11,s10
    4c60:	02a12223          	sw	a0,36(sp)
    4c64:	5a091c63          	bnez	s2,521c <main+0x6ec>
    4c68:	600a1c63          	bnez	s4,5280 <main+0x750>
    4c6c:	02ab87b3          	mul	a5,s7,a0
    4c70:	00f982b3          	add	t0,s3,a5
    4c74:	02512023          	sw	t0,32(sp)
    4c78:	02c12483          	lw	s1,44(sp)
    4c7c:	0014f313          	andi	t1,s1,1
    4c80:	00030c63          	beqz	t1,4c98 <main+0x168>
    4c84:	00c11603          	lh	a2,12(sp)
    4c88:	01812583          	lw	a1,24(sp)
    4c8c:	e38fc0ef          	jal	ra,12c4 <core_list_init>
    4c90:	02c12483          	lw	s1,44(sp)
    4c94:	02a12823          	sw	a0,48(sp)
    4c98:	0024f393          	andi	t2,s1,2
    4c9c:	20039e63          	bnez	t2,4eb8 <main+0x388>
    4ca0:	0044f593          	andi	a1,s1,4
    4ca4:	00058a63          	beqz	a1,4cb8 <main+0x188>
    4ca8:	02012603          	lw	a2,32(sp)
    4cac:	00c11583          	lh	a1,12(sp)
    4cb0:	02412503          	lw	a0,36(sp)
    4cb4:	f90fe0ef          	jal	ra,3444 <core_init_state>
    4cb8:	02812603          	lw	a2,40(sp)
    4cbc:	04061a63          	bnez	a2,4d10 <main+0x1e0>
    4cc0:	00100c13          	li	s8,1
    4cc4:	0080006f          	j	4ccc <main+0x19c>
    4cc8:	02812c03          	lw	s8,40(sp)
    4ccc:	002c1693          	slli	a3,s8,0x2
    4cd0:	01868933          	add	s2,a3,s8
    4cd4:	00191813          	slli	a6,s2,0x1
    4cd8:	03012423          	sw	a6,40(sp)
    4cdc:	b64fb0ef          	jal	ra,40 <start_time>
    4ce0:	00c10513          	addi	a0,sp,12
    4ce4:	cb4fe0ef          	jal	ra,3198 <iterate>
    4ce8:	b88fb0ef          	jal	ra,70 <stop_time>
    4cec:	bb4fb0ef          	jal	ra,a0 <get_time_elasped>
    4cf0:	bdcfb0ef          	jal	ra,cc <time_in_secs>
    4cf4:	fc050ae3          	beqz	a0,4cc8 <main+0x198>
    4cf8:	00a00993          	li	s3,10
    4cfc:	02a9da33          	divu	s4,s3,a0
    4d00:	02812a83          	lw	s5,40(sp)
    4d04:	001a0893          	addi	a7,s4,1
    4d08:	031a8b33          	mul	s6,s5,a7
    4d0c:	03612423          	sw	s6,40(sp)
    4d10:	b30fb0ef          	jal	ra,40 <start_time>
    4d14:	00c10513          	addi	a0,sp,12
    4d18:	c80fe0ef          	jal	ra,3198 <iterate>
    4d1c:	b54fb0ef          	jal	ra,70 <stop_time>
    4d20:	b80fb0ef          	jal	ra,a0 <get_time_elasped>
    4d24:	00050993          	mv	s3,a0
    4d28:	00c11503          	lh	a0,12(sp)
    4d2c:	00058a13          	mv	s4,a1
    4d30:	00000593          	li	a1,0
    4d34:	64d000ef          	jal	ra,5b80 <crc16>
    4d38:	00050593          	mv	a1,a0
    4d3c:	00e11503          	lh	a0,14(sp)
    4d40:	00008bb7          	lui	s7,0x8
    4d44:	63d000ef          	jal	ra,5b80 <crc16>
    4d48:	00050593          	mv	a1,a0
    4d4c:	01011503          	lh	a0,16(sp)
    4d50:	631000ef          	jal	ra,5b80 <crc16>
    4d54:	00050593          	mv	a1,a0
    4d58:	02411503          	lh	a0,36(sp)
    4d5c:	625000ef          	jal	ra,5b80 <crc16>
    4d60:	00050913          	mv	s2,a0
    4d64:	b05b8513          	addi	a0,s7,-1275 # 7b05 <__subdf3+0x7c9>
    4d68:	4ca90e63          	beq	s2,a0,5244 <main+0x714>
    4d6c:	43256063          	bltu	a0,s2,518c <main+0x65c>
    4d70:	00002fb7          	lui	t6,0x2
    4d74:	8f2f8793          	addi	a5,t6,-1806 # 18f2 <core_init_matrix+0x286>
    4d78:	4ef90a63          	beq	s2,a5,526c <main+0x73c>
    4d7c:	000053b7          	lui	t2,0x5
    4d80:	eaf38093          	addi	ra,t2,-337 # 4eaf <main+0x37f>
    4d84:	50191c63          	bne	s2,ra,529c <main+0x76c>
    4d88:	0000d737          	lui	a4,0xd
    4d8c:	ae470513          	addi	a0,a4,-1308 # cae4 <errpat+0x120>
    4d90:	df8fb0ef          	jal	ra,388 <sc_printf>
    4d94:	00200313          	li	t1,2
    4d98:	0000dcb7          	lui	s9,0xd
    4d9c:	18cca403          	lw	s0,396(s9) # d18c <default_num_contexts>
    4da0:	16040263          	beqz	s0,4f04 <main+0x3d4>
    4da4:	0000d5b7          	lui	a1,0xd
    4da8:	00131613          	slli	a2,t1,0x1
    4dac:	95858693          	addi	a3,a1,-1704 # c958 <list_known_crc>
    4db0:	00000d93          	li	s11,0
    4db4:	00000c13          	li	s8,0
    4db8:	00c68d33          	add	s10,a3,a2
    4dbc:	0000dbb7          	lui	s7,0xd
    4dc0:	0000db37          	lui	s6,0xd
    4dc4:	0000dab7          	lui	s5,0xd
    4dc8:	0380006f          	j	4e00 <main+0x2d0>
    4dcc:	05068413          	addi	s0,a3,80
    4dd0:	00240833          	add	a6,s0,sp
    4dd4:	ffc85f03          	lhu	t5,-4(a6)
    4dd8:	001c0c13          	addi	s8,s8,1
    4ddc:	18ccaf83          	lw	t6,396(s9)
    4de0:	01bf0db3          	add	s11,t5,s11
    4de4:	010c1293          	slli	t0,s8,0x10
    4de8:	010d9313          	slli	t1,s11,0x10
    4dec:	010d9393          	slli	t2,s11,0x10
    4df0:	0102dc13          	srli	s8,t0,0x10
    4df4:	01035493          	srli	s1,t1,0x10
    4df8:	4103dd93          	srai	s11,t2,0x10
    4dfc:	11fc7663          	bgeu	s8,t6,4f08 <main+0x3d8>
    4e00:	004c1413          	slli	s0,s8,0x4
    4e04:	01840833          	add	a6,s0,s8
    4e08:	00281893          	slli	a7,a6,0x2
    4e0c:	05088513          	addi	a0,a7,80
    4e10:	002504b3          	add	s1,a0,sp
    4e14:	fdc4a783          	lw	a5,-36(s1)
    4e18:	fe049e23          	sh	zero,-4(s1)
    4e1c:	0017fe13          	andi	t3,a5,1
    4e20:	020e0663          	beqz	t3,4e4c <main+0x31c>
    4e24:	ff64d603          	lhu	a2,-10(s1)
    4e28:	000d5683          	lhu	a3,0(s10)
    4e2c:	02d60063          	beq	a2,a3,4e4c <main+0x31c>
    4e30:	000c0593          	mv	a1,s8
    4e34:	b74b8513          	addi	a0,s7,-1164 # cb74 <errpat+0x1b0>
    4e38:	d50fb0ef          	jal	ra,388 <sc_printf>
    4e3c:	ffc4de83          	lhu	t4,-4(s1)
    4e40:	fdc4a783          	lw	a5,-36(s1)
    4e44:	001e8f13          	addi	t5,t4,1
    4e48:	ffe49e23          	sh	t5,-4(s1)
    4e4c:	0027ff93          	andi	t6,a5,2
    4e50:	020f8e63          	beqz	t6,4e8c <main+0x35c>
    4e54:	018402b3          	add	t0,s0,s8
    4e58:	00229313          	slli	t1,t0,0x2
    4e5c:	05030393          	addi	t2,t1,80
    4e60:	002384b3          	add	s1,t2,sp
    4e64:	ff84d603          	lhu	a2,-8(s1)
    4e68:	00cd5683          	lhu	a3,12(s10)
    4e6c:	02d60063          	beq	a2,a3,4e8c <main+0x35c>
    4e70:	000c0593          	mv	a1,s8
    4e74:	ba4b0513          	addi	a0,s6,-1116 # cba4 <errpat+0x1e0>
    4e78:	d10fb0ef          	jal	ra,388 <sc_printf>
    4e7c:	ffc4d703          	lhu	a4,-4(s1)
    4e80:	fdc4a783          	lw	a5,-36(s1)
    4e84:	00170593          	addi	a1,a4,1
    4e88:	feb49e23          	sh	a1,-4(s1)
    4e8c:	01840633          	add	a2,s0,s8
    4e90:	0047f093          	andi	ra,a5,4
    4e94:	00261693          	slli	a3,a2,0x2
    4e98:	f2008ae3          	beqz	ra,4dcc <main+0x29c>
    4e9c:	05068893          	addi	a7,a3,80
    4ea0:	002884b3          	add	s1,a7,sp
    4ea4:	ffa4d603          	lhu	a2,-6(s1)
    4ea8:	018d5683          	lhu	a3,24(s10)
    4eac:	02d61a63          	bne	a2,a3,4ee0 <main+0x3b0>
    4eb0:	ffc4df03          	lhu	t5,-4(s1)
    4eb4:	f25ff06f          	j	4dd8 <main+0x2a8>
    4eb8:	00e11083          	lh	ra,14(sp)
    4ebc:	00c11703          	lh	a4,12(sp)
    4ec0:	01c12583          	lw	a1,28(sp)
    4ec4:	02412503          	lw	a0,36(sp)
    4ec8:	01009413          	slli	s0,ra,0x10
    4ecc:	03410693          	addi	a3,sp,52
    4ed0:	00e46633          	or	a2,s0,a4
    4ed4:	f98fc0ef          	jal	ra,166c <core_init_matrix>
    4ed8:	02c12483          	lw	s1,44(sp)
    4edc:	dc5ff06f          	j	4ca0 <main+0x170>
    4ee0:	000c0593          	mv	a1,s8
    4ee4:	bd8a8513          	addi	a0,s5,-1064 # cbd8 <errpat+0x214>
    4ee8:	ca0fb0ef          	jal	ra,388 <sc_printf>
    4eec:	ffc4d503          	lhu	a0,-4(s1)
    4ef0:	00150e13          	addi	t3,a0,1
    4ef4:	010e1e93          	slli	t4,t3,0x10
    4ef8:	010edf13          	srli	t5,t4,0x10
    4efc:	ffe49e23          	sh	t5,-4(s1)
    4f00:	ed9ff06f          	j	4dd8 <main+0x2a8>
    4f04:	00000493          	li	s1,0
    4f08:	d34fe0ef          	jal	ra,343c <check_data_types>
    4f0c:	02412583          	lw	a1,36(sp)
    4f10:	0000dbb7          	lui	s7,0xd
    4f14:	00950d33          	add	s10,a0,s1
    4f18:	c08b8513          	addi	a0,s7,-1016 # cc08 <errpat+0x244>
    4f1c:	c6cfb0ef          	jal	ra,388 <sc_printf>
    4f20:	0000dab7          	lui	s5,0xd
    4f24:	00098593          	mv	a1,s3
    4f28:	c20a8513          	addi	a0,s5,-992 # cc20 <errpat+0x25c>
    4f2c:	c5cfb0ef          	jal	ra,388 <sc_printf>
    4f30:	000a0593          	mv	a1,s4
    4f34:	00098513          	mv	a0,s3
    4f38:	994fb0ef          	jal	ra,cc <time_in_secs>
    4f3c:	0000d737          	lui	a4,0xd
    4f40:	00050593          	mv	a1,a0
    4f44:	c3870513          	addi	a0,a4,-968 # cc38 <errpat+0x274>
    4f48:	c40fb0ef          	jal	ra,388 <sc_printf>
    4f4c:	010d1b13          	slli	s6,s10,0x10
    4f50:	00098513          	mv	a0,s3
    4f54:	000a0593          	mv	a1,s4
    4f58:	010b5493          	srli	s1,s6,0x10
    4f5c:	970fb0ef          	jal	ra,cc <time_in_secs>
    4f60:	26051e63          	bnez	a0,51dc <main+0x6ac>
    4f64:	00098513          	mv	a0,s3
    4f68:	000a0593          	mv	a1,s4
    4f6c:	960fb0ef          	jal	ra,cc <time_in_secs>
    4f70:	00900993          	li	s3,9
    4f74:	24a9fa63          	bgeu	s3,a0,51c8 <main+0x698>
    4f78:	18cca803          	lw	a6,396(s9)
    4f7c:	02812e03          	lw	t3,40(sp)
    4f80:	0000d8b7          	lui	a7,0xd
    4f84:	01049693          	slli	a3,s1,0x10
    4f88:	030e05b3          	mul	a1,t3,a6
    4f8c:	ca888513          	addi	a0,a7,-856 # cca8 <errpat+0x2e4>
    4f90:	4106dc13          	srai	s8,a3,0x10
    4f94:	bf4fb0ef          	jal	ra,388 <sc_printf>
    4f98:	0000deb7          	lui	t4,0xd
    4f9c:	0000d537          	lui	a0,0xd
    4fa0:	cc050593          	addi	a1,a0,-832 # ccc0 <errpat+0x2fc>
    4fa4:	ccce8513          	addi	a0,t4,-820 # cccc <errpat+0x308>
    4fa8:	be0fb0ef          	jal	ra,388 <sc_printf>
    4fac:	0000df37          	lui	t5,0xd
    4fb0:	0000dfb7          	lui	t6,0xd
    4fb4:	ce4f0593          	addi	a1,t5,-796 # cce4 <errpat+0x320>
    4fb8:	d28f8513          	addi	a0,t6,-728 # cd28 <errpat+0x364>
    4fbc:	bccfb0ef          	jal	ra,388 <sc_printf>
    4fc0:	0000d2b7          	lui	t0,0xd
    4fc4:	0000d337          	lui	t1,0xd
    4fc8:	d4028593          	addi	a1,t0,-704 # cd40 <errpat+0x37c>
    4fcc:	d4830513          	addi	a0,t1,-696 # cd48 <errpat+0x384>
    4fd0:	bb8fb0ef          	jal	ra,388 <sc_printf>
    4fd4:	00090593          	mv	a1,s2
    4fd8:	0000d937          	lui	s2,0xd
    4fdc:	d6090513          	addi	a0,s2,-672 # cd60 <errpat+0x39c>
    4fe0:	ba8fb0ef          	jal	ra,388 <sc_printf>
    4fe4:	02c12283          	lw	t0,44(sp)
    4fe8:	0012f393          	andi	t2,t0,1
    4fec:	04038863          	beqz	t2,503c <main+0x50c>
    4ff0:	18ccad83          	lw	s11,396(s9)
    4ff4:	040d8463          	beqz	s11,503c <main+0x50c>
    4ff8:	00000993          	li	s3,0
    4ffc:	0000dd37          	lui	s10,0xd
    5000:	00499b93          	slli	s7,s3,0x4
    5004:	013b8b33          	add	s6,s7,s3
    5008:	002b1a93          	slli	s5,s6,0x2
    500c:	050a8713          	addi	a4,s5,80
    5010:	002707b3          	add	a5,a4,sp
    5014:	ff67d603          	lhu	a2,-10(a5)
    5018:	00098593          	mv	a1,s3
    501c:	d7cd0513          	addi	a0,s10,-644 # cd7c <errpat+0x3b8>
    5020:	b68fb0ef          	jal	ra,388 <sc_printf>
    5024:	00198413          	addi	s0,s3,1
    5028:	18cca583          	lw	a1,396(s9)
    502c:	01041613          	slli	a2,s0,0x10
    5030:	01065993          	srli	s3,a2,0x10
    5034:	fcb9e6e3          	bltu	s3,a1,5000 <main+0x4d0>
    5038:	02c12283          	lw	t0,44(sp)
    503c:	0022f093          	andi	ra,t0,2
    5040:	04008863          	beqz	ra,5090 <main+0x560>
    5044:	18ccaa03          	lw	s4,396(s9)
    5048:	240a0463          	beqz	s4,5290 <main+0x760>
    504c:	00000d93          	li	s11,0
    5050:	0000d937          	lui	s2,0xd
    5054:	004d9693          	slli	a3,s11,0x4
    5058:	01b68833          	add	a6,a3,s11
    505c:	00281893          	slli	a7,a6,0x2
    5060:	05088e13          	addi	t3,a7,80
    5064:	002e0533          	add	a0,t3,sp
    5068:	ff855603          	lhu	a2,-8(a0)
    506c:	000d8593          	mv	a1,s11
    5070:	d9890513          	addi	a0,s2,-616 # cd98 <errpat+0x3d4>
    5074:	b14fb0ef          	jal	ra,388 <sc_printf>
    5078:	001d8f13          	addi	t5,s11,1
    507c:	18ccae83          	lw	t4,396(s9)
    5080:	010f1f93          	slli	t6,t5,0x10
    5084:	010fdd93          	srli	s11,t6,0x10
    5088:	fddde6e3          	bltu	s11,t4,5054 <main+0x524>
    508c:	02c12283          	lw	t0,44(sp)
    5090:	0042f313          	andi	t1,t0,4
    5094:	18cca383          	lw	t2,396(s9)
    5098:	04030463          	beqz	t1,50e0 <main+0x5b0>
    509c:	08038663          	beqz	t2,5128 <main+0x5f8>
    50a0:	00000993          	li	s3,0
    50a4:	0000dd37          	lui	s10,0xd
    50a8:	00499b93          	slli	s7,s3,0x4
    50ac:	013b8b33          	add	s6,s7,s3
    50b0:	002b1a93          	slli	s5,s6,0x2
    50b4:	050a8713          	addi	a4,s5,80
    50b8:	002707b3          	add	a5,a4,sp
    50bc:	ffa7d603          	lhu	a2,-6(a5)
    50c0:	00098593          	mv	a1,s3
    50c4:	db4d0513          	addi	a0,s10,-588 # cdb4 <errpat+0x3f0>
    50c8:	ac0fb0ef          	jal	ra,388 <sc_printf>
    50cc:	00198413          	addi	s0,s3,1
    50d0:	18cca583          	lw	a1,396(s9)
    50d4:	01041613          	slli	a2,s0,0x10
    50d8:	01065993          	srli	s3,a2,0x10
    50dc:	fcb9e6e3          	bltu	s3,a1,50a8 <main+0x578>
    50e0:	18cca083          	lw	ra,396(s9)
    50e4:	00000d93          	li	s11,0
    50e8:	0000da37          	lui	s4,0xd
    50ec:	02008e63          	beqz	ra,5128 <main+0x5f8>
    50f0:	004d9493          	slli	s1,s11,0x4
    50f4:	01b48933          	add	s2,s1,s11
    50f8:	00291693          	slli	a3,s2,0x2
    50fc:	05068813          	addi	a6,a3,80
    5100:	002808b3          	add	a7,a6,sp
    5104:	ff48d603          	lhu	a2,-12(a7)
    5108:	000d8593          	mv	a1,s11
    510c:	dd0a0513          	addi	a0,s4,-560 # cdd0 <errpat+0x40c>
    5110:	a78fb0ef          	jal	ra,388 <sc_printf>
    5114:	001d8513          	addi	a0,s11,1
    5118:	18ccae03          	lw	t3,396(s9)
    511c:	01051e93          	slli	t4,a0,0x10
    5120:	010edd93          	srli	s11,t4,0x10
    5124:	fdcde6e3          	bltu	s11,t3,50f0 <main+0x5c0>
    5128:	0e0c0263          	beqz	s8,520c <main+0x6dc>
    512c:	09804663          	bgtz	s8,51b8 <main+0x688>
    5130:	0000dcb7          	lui	s9,0xd
    5134:	e38c8513          	addi	a0,s9,-456 # ce38 <errpat+0x474>
    5138:	a50fb0ef          	jal	ra,388 <sc_printf>
    513c:	000c0513          	mv	a0,s8
    5140:	8c8fb0ef          	jal	ra,208 <board_result>
    5144:	04e10513          	addi	a0,sp,78
    5148:	92cfb0ef          	jal	ra,274 <portable_fini>
    514c:	08c12083          	lw	ra,140(sp)
    5150:	08812403          	lw	s0,136(sp)
    5154:	08412483          	lw	s1,132(sp)
    5158:	08012903          	lw	s2,128(sp)
    515c:	07c12983          	lw	s3,124(sp)
    5160:	07812a03          	lw	s4,120(sp)
    5164:	07412a83          	lw	s5,116(sp)
    5168:	07012b03          	lw	s6,112(sp)
    516c:	06c12b83          	lw	s7,108(sp)
    5170:	06812c03          	lw	s8,104(sp)
    5174:	06412c83          	lw	s9,100(sp)
    5178:	06012d03          	lw	s10,96(sp)
    517c:	05c12d83          	lw	s11,92(sp)
    5180:	00000513          	li	a0,0
    5184:	09010113          	addi	sp,sp,144
    5188:	00008067          	ret
    518c:	00009cb7          	lui	s9,0x9
    5190:	a02c8d13          	addi	s10,s9,-1534 # 8a02 <_etext+0x136>
    5194:	0da90263          	beq	s2,s10,5258 <main+0x728>
    5198:	0000fe37          	lui	t3,0xf
    519c:	9f5e0e93          	addi	t4,t3,-1547 # e9f5 <seed1_volatile+0x1055>
    51a0:	0fd91e63          	bne	s2,t4,529c <main+0x76c>
    51a4:	0000df37          	lui	t5,0xd
    51a8:	b18f0513          	addi	a0,t5,-1256 # cb18 <errpat+0x154>
    51ac:	9dcfb0ef          	jal	ra,388 <sc_printf>
    51b0:	00300313          	li	t1,3
    51b4:	be5ff06f          	j	4d98 <main+0x268>
    51b8:	0000df37          	lui	t5,0xd
    51bc:	e9cf0513          	addi	a0,t5,-356 # ce9c <errpat+0x4d8>
    51c0:	9c8fb0ef          	jal	ra,388 <sc_printf>
    51c4:	f79ff06f          	j	513c <main+0x60c>
    51c8:	0000da37          	lui	s4,0xd
    51cc:	c68a0513          	addi	a0,s4,-920 # cc68 <errpat+0x2a4>
    51d0:	9b8fb0ef          	jal	ra,388 <sc_printf>
    51d4:	00148493          	addi	s1,s1,1
    51d8:	da1ff06f          	j	4f78 <main+0x448>
    51dc:	18cca783          	lw	a5,396(s9)
    51e0:	02812083          	lw	ra,40(sp)
    51e4:	000a0593          	mv	a1,s4
    51e8:	00098513          	mv	a0,s3
    51ec:	02f08433          	mul	s0,ra,a5
    51f0:	eddfa0ef          	jal	ra,cc <time_in_secs>
    51f4:	00050593          	mv	a1,a0
    51f8:	0000d637          	lui	a2,0xd
    51fc:	c5060513          	addi	a0,a2,-944 # cc50 <errpat+0x28c>
    5200:	02b455b3          	divu	a1,s0,a1
    5204:	984fb0ef          	jal	ra,388 <sc_printf>
    5208:	d5dff06f          	j	4f64 <main+0x434>
    520c:	0000dfb7          	lui	t6,0xd
    5210:	decf8513          	addi	a0,t6,-532 # cdec <errpat+0x428>
    5214:	974fb0ef          	jal	ra,388 <sc_printf>
    5218:	f25ff06f          	j	513c <main+0x60c>
    521c:	01312c23          	sw	s3,24(sp)
    5220:	a40a06e3          	beqz	s4,4c6c <main+0x13c>
    5224:	02a90f33          	mul	t5,s2,a0
    5228:	01e98fb3          	add	t6,s3,t5
    522c:	01f12e23          	sw	t6,28(sp)
    5230:	a40a84e3          	beqz	s5,4c78 <main+0x148>
    5234:	a39ff06f          	j	4c6c <main+0x13c>
    5238:	01312c23          	sw	s3,24(sp)
    523c:	a20a0ee3          	beqz	s4,4c78 <main+0x148>
    5240:	fe5ff06f          	j	5224 <main+0x6f4>
    5244:	0000dc37          	lui	s8,0xd
    5248:	ab8c0513          	addi	a0,s8,-1352 # cab8 <errpat+0xf4>
    524c:	93cfb0ef          	jal	ra,388 <sc_printf>
    5250:	00100313          	li	t1,1
    5254:	b45ff06f          	j	4d98 <main+0x268>
    5258:	0000ddb7          	lui	s11,0xd
    525c:	a88d8513          	addi	a0,s11,-1400 # ca88 <errpat+0xc4>
    5260:	928fb0ef          	jal	ra,388 <sc_printf>
    5264:	00000313          	li	t1,0
    5268:	b31ff06f          	j	4d98 <main+0x268>
    526c:	0000d2b7          	lui	t0,0xd
    5270:	b4828513          	addi	a0,t0,-1208 # cb48 <errpat+0x184>
    5274:	914fb0ef          	jal	ra,388 <sc_printf>
    5278:	00400313          	li	t1,4
    527c:	b1dff06f          	j	4d98 <main+0x268>
    5280:	02a90e33          	mul	t3,s2,a0
    5284:	01c98eb3          	add	t4,s3,t3
    5288:	01d12e23          	sw	t4,28(sp)
    528c:	9e1ff06f          	j	4c6c <main+0x13c>
    5290:	0042f493          	andi	s1,t0,4
    5294:	e40486e3          	beqz	s1,50e0 <main+0x5b0>
    5298:	e91ff06f          	j	5128 <main+0x5f8>
    529c:	00010cb7          	lui	s9,0x10
    52a0:	fffc8493          	addi	s1,s9,-1 # ffff <seed1_volatile+0x265f>
    52a4:	0000dcb7          	lui	s9,0xd
    52a8:	c61ff06f          	j	4f08 <main+0x3d8>

000052ac <crcu8>:
    52ac:	00b546b3          	xor	a3,a0,a1
    52b0:	0016f293          	andi	t0,a3,1
    52b4:	00155713          	srli	a4,a0,0x1
    52b8:	0015d613          	srli	a2,a1,0x1
    52bc:	00028c63          	beqz	t0,52d4 <crcu8+0x28>
    52c0:	ffffa337          	lui	t1,0xffffa
    52c4:	00130393          	addi	t2,t1,1 # ffffa001 <_stack_top+0xfffd4801>
    52c8:	007647b3          	xor	a5,a2,t2
    52cc:	01079593          	slli	a1,a5,0x10
    52d0:	0105d613          	srli	a2,a1,0x10
    52d4:	00c74833          	xor	a6,a4,a2
    52d8:	00187893          	andi	a7,a6,1
    52dc:	00255e13          	srli	t3,a0,0x2
    52e0:	00165293          	srli	t0,a2,0x1
    52e4:	00088c63          	beqz	a7,52fc <crcu8+0x50>
    52e8:	ffffaeb7          	lui	t4,0xffffa
    52ec:	001e8f13          	addi	t5,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    52f0:	01e2cfb3          	xor	t6,t0,t5
    52f4:	010f9693          	slli	a3,t6,0x10
    52f8:	0106d293          	srli	t0,a3,0x10
    52fc:	005e4733          	xor	a4,t3,t0
    5300:	00177313          	andi	t1,a4,1
    5304:	00355393          	srli	t2,a0,0x3
    5308:	0012d893          	srli	a7,t0,0x1
    530c:	00030c63          	beqz	t1,5324 <crcu8+0x78>
    5310:	ffffa5b7          	lui	a1,0xffffa
    5314:	00158613          	addi	a2,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    5318:	00c8c7b3          	xor	a5,a7,a2
    531c:	01079813          	slli	a6,a5,0x10
    5320:	01085893          	srli	a7,a6,0x10
    5324:	0113ce33          	xor	t3,t2,a7
    5328:	001e7e93          	andi	t4,t3,1
    532c:	00455f13          	srli	t5,a0,0x4
    5330:	0018d313          	srli	t1,a7,0x1
    5334:	000e8c63          	beqz	t4,534c <crcu8+0xa0>
    5338:	ffffafb7          	lui	t6,0xffffa
    533c:	001f8693          	addi	a3,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    5340:	00d342b3          	xor	t0,t1,a3
    5344:	01029713          	slli	a4,t0,0x10
    5348:	01075313          	srli	t1,a4,0x10
    534c:	006f43b3          	xor	t2,t5,t1
    5350:	0013f593          	andi	a1,t2,1
    5354:	00555613          	srli	a2,a0,0x5
    5358:	00135e93          	srli	t4,t1,0x1
    535c:	00058c63          	beqz	a1,5374 <crcu8+0xc8>
    5360:	ffffa837          	lui	a6,0xffffa
    5364:	00180893          	addi	a7,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    5368:	011ec7b3          	xor	a5,t4,a7
    536c:	01079e13          	slli	t3,a5,0x10
    5370:	010e5e93          	srli	t4,t3,0x10
    5374:	01d64f33          	xor	t5,a2,t4
    5378:	001f7f93          	andi	t6,t5,1
    537c:	00655693          	srli	a3,a0,0x6
    5380:	001ed593          	srli	a1,t4,0x1
    5384:	000f8c63          	beqz	t6,539c <crcu8+0xf0>
    5388:	ffffa2b7          	lui	t0,0xffffa
    538c:	00128713          	addi	a4,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5390:	00e5c333          	xor	t1,a1,a4
    5394:	01031393          	slli	t2,t1,0x10
    5398:	0103d593          	srli	a1,t2,0x10
    539c:	00b6c633          	xor	a2,a3,a1
    53a0:	00167813          	andi	a6,a2,1
    53a4:	00755893          	srli	a7,a0,0x7
    53a8:	0015df13          	srli	t5,a1,0x1
    53ac:	00080c63          	beqz	a6,53c4 <crcu8+0x118>
    53b0:	ffffa537          	lui	a0,0xffffa
    53b4:	00150e13          	addi	t3,a0,1 # ffffa001 <_stack_top+0xfffd4801>
    53b8:	01cf47b3          	xor	a5,t5,t3
    53bc:	01079e93          	slli	t4,a5,0x10
    53c0:	010edf13          	srli	t5,t4,0x10
    53c4:	001f7f93          	andi	t6,t5,1
    53c8:	001f5513          	srli	a0,t5,0x1
    53cc:	011f8c63          	beq	t6,a7,53e4 <crcu8+0x138>
    53d0:	ffffa6b7          	lui	a3,0xffffa
    53d4:	00168293          	addi	t0,a3,1 # ffffa001 <_stack_top+0xfffd4801>
    53d8:	00554733          	xor	a4,a0,t0
    53dc:	01071313          	slli	t1,a4,0x10
    53e0:	01035513          	srli	a0,t1,0x10
    53e4:	00008067          	ret

000053e8 <crcu16>:
    53e8:	0ff57713          	zext.b	a4,a0
    53ec:	00b746b3          	xor	a3,a4,a1
    53f0:	0016f293          	andi	t0,a3,1
    53f4:	00050793          	mv	a5,a0
    53f8:	00175613          	srli	a2,a4,0x1
    53fc:	0015d813          	srli	a6,a1,0x1
    5400:	00028c63          	beqz	t0,5418 <crcu16+0x30>
    5404:	ffffa337          	lui	t1,0xffffa
    5408:	00130393          	addi	t2,t1,1 # ffffa001 <_stack_top+0xfffd4801>
    540c:	00784533          	xor	a0,a6,t2
    5410:	01051593          	slli	a1,a0,0x10
    5414:	0105d813          	srli	a6,a1,0x10
    5418:	010648b3          	xor	a7,a2,a6
    541c:	0018fe13          	andi	t3,a7,1
    5420:	00275e93          	srli	t4,a4,0x2
    5424:	00185313          	srli	t1,a6,0x1
    5428:	000e0c63          	beqz	t3,5440 <crcu16+0x58>
    542c:	ffffaf37          	lui	t5,0xffffa
    5430:	001f0f93          	addi	t6,t5,1 # ffffa001 <_stack_top+0xfffd4801>
    5434:	01f346b3          	xor	a3,t1,t6
    5438:	01069293          	slli	t0,a3,0x10
    543c:	0102d313          	srli	t1,t0,0x10
    5440:	006ec633          	xor	a2,t4,t1
    5444:	00167393          	andi	t2,a2,1
    5448:	00375593          	srli	a1,a4,0x3
    544c:	00135e93          	srli	t4,t1,0x1
    5450:	00038c63          	beqz	t2,5468 <crcu16+0x80>
    5454:	ffffa837          	lui	a6,0xffffa
    5458:	00180893          	addi	a7,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    545c:	011ec533          	xor	a0,t4,a7
    5460:	01051e13          	slli	t3,a0,0x10
    5464:	010e5e93          	srli	t4,t3,0x10
    5468:	01d5cf33          	xor	t5,a1,t4
    546c:	001f7f93          	andi	t6,t5,1
    5470:	00475693          	srli	a3,a4,0x4
    5474:	001ed593          	srli	a1,t4,0x1
    5478:	000f8c63          	beqz	t6,5490 <crcu16+0xa8>
    547c:	ffffa2b7          	lui	t0,0xffffa
    5480:	00128313          	addi	t1,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5484:	0065c633          	xor	a2,a1,t1
    5488:	01061393          	slli	t2,a2,0x10
    548c:	0103d593          	srli	a1,t2,0x10
    5490:	00b6c833          	xor	a6,a3,a1
    5494:	00187893          	andi	a7,a6,1
    5498:	00575e13          	srli	t3,a4,0x5
    549c:	0015d293          	srli	t0,a1,0x1
    54a0:	00088c63          	beqz	a7,54b8 <crcu16+0xd0>
    54a4:	ffffaeb7          	lui	t4,0xffffa
    54a8:	001e8f13          	addi	t5,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    54ac:	01e2c533          	xor	a0,t0,t5
    54b0:	01051f93          	slli	t6,a0,0x10
    54b4:	010fd293          	srli	t0,t6,0x10
    54b8:	005e46b3          	xor	a3,t3,t0
    54bc:	0016f313          	andi	t1,a3,1
    54c0:	00675393          	srli	t2,a4,0x6
    54c4:	0012de13          	srli	t3,t0,0x1
    54c8:	00030c63          	beqz	t1,54e0 <crcu16+0xf8>
    54cc:	ffffa637          	lui	a2,0xffffa
    54d0:	00160593          	addi	a1,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    54d4:	00be4833          	xor	a6,t3,a1
    54d8:	01081893          	slli	a7,a6,0x10
    54dc:	0108de13          	srli	t3,a7,0x10
    54e0:	01c3ceb3          	xor	t4,t2,t3
    54e4:	001eff13          	andi	t5,t4,1
    54e8:	00775713          	srli	a4,a4,0x7
    54ec:	001e5313          	srli	t1,t3,0x1
    54f0:	000f0c63          	beqz	t5,5508 <crcu16+0x120>
    54f4:	ffffafb7          	lui	t6,0xffffa
    54f8:	001f8293          	addi	t0,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    54fc:	00534533          	xor	a0,t1,t0
    5500:	01051693          	slli	a3,a0,0x10
    5504:	0106d313          	srli	t1,a3,0x10
    5508:	00137393          	andi	t2,t1,1
    550c:	00135e13          	srli	t3,t1,0x1
    5510:	14e39263          	bne	t2,a4,5654 <crcu16+0x26c>
    5514:	0087de93          	srli	t4,a5,0x8
    5518:	01cecf33          	xor	t5,t4,t3
    551c:	001f7f93          	andi	t6,t5,1
    5520:	0097d713          	srli	a4,a5,0x9
    5524:	001e5313          	srli	t1,t3,0x1
    5528:	000f8c63          	beqz	t6,5540 <crcu16+0x158>
    552c:	ffffa7b7          	lui	a5,0xffffa
    5530:	00178293          	addi	t0,a5,1 # ffffa001 <_stack_top+0xfffd4801>
    5534:	00534533          	xor	a0,t1,t0
    5538:	01051693          	slli	a3,a0,0x10
    553c:	0106d313          	srli	t1,a3,0x10
    5540:	006743b3          	xor	t2,a4,t1
    5544:	0013f613          	andi	a2,t2,1
    5548:	002ed593          	srli	a1,t4,0x2
    554c:	00135f93          	srli	t6,t1,0x1
    5550:	00060c63          	beqz	a2,5568 <crcu16+0x180>
    5554:	ffffa837          	lui	a6,0xffffa
    5558:	00180893          	addi	a7,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    555c:	011fce33          	xor	t3,t6,a7
    5560:	010e1f13          	slli	t5,t3,0x10
    5564:	010f5f93          	srli	t6,t5,0x10
    5568:	01f5c733          	xor	a4,a1,t6
    556c:	00177293          	andi	t0,a4,1
    5570:	003ed793          	srli	a5,t4,0x3
    5574:	001fd613          	srli	a2,t6,0x1
    5578:	00028c63          	beqz	t0,5590 <crcu16+0x1a8>
    557c:	ffffa6b7          	lui	a3,0xffffa
    5580:	00168313          	addi	t1,a3,1 # ffffa001 <_stack_top+0xfffd4801>
    5584:	00664533          	xor	a0,a2,t1
    5588:	01051393          	slli	t2,a0,0x10
    558c:	0103d613          	srli	a2,t2,0x10
    5590:	00c7c5b3          	xor	a1,a5,a2
    5594:	0015f813          	andi	a6,a1,1
    5598:	004ed893          	srli	a7,t4,0x4
    559c:	00165293          	srli	t0,a2,0x1
    55a0:	00080c63          	beqz	a6,55b8 <crcu16+0x1d0>
    55a4:	ffffae37          	lui	t3,0xffffa
    55a8:	001e0f13          	addi	t5,t3,1 # ffffa001 <_stack_top+0xfffd4801>
    55ac:	01e2cfb3          	xor	t6,t0,t5
    55b0:	010f9713          	slli	a4,t6,0x10
    55b4:	01075293          	srli	t0,a4,0x10
    55b8:	0058c7b3          	xor	a5,a7,t0
    55bc:	0017f693          	andi	a3,a5,1
    55c0:	005ed313          	srli	t1,t4,0x5
    55c4:	0012d813          	srli	a6,t0,0x1
    55c8:	00068c63          	beqz	a3,55e0 <crcu16+0x1f8>
    55cc:	ffffa3b7          	lui	t2,0xffffa
    55d0:	00138613          	addi	a2,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    55d4:	00c84533          	xor	a0,a6,a2
    55d8:	01051593          	slli	a1,a0,0x10
    55dc:	0105d813          	srli	a6,a1,0x10
    55e0:	010348b3          	xor	a7,t1,a6
    55e4:	0018fe13          	andi	t3,a7,1
    55e8:	006edf13          	srli	t5,t4,0x6
    55ec:	00185693          	srli	a3,a6,0x1
    55f0:	000e0c63          	beqz	t3,5608 <crcu16+0x220>
    55f4:	ffffafb7          	lui	t6,0xffffa
    55f8:	001f8713          	addi	a4,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    55fc:	00e6c2b3          	xor	t0,a3,a4
    5600:	01029793          	slli	a5,t0,0x10
    5604:	0107d693          	srli	a3,a5,0x10
    5608:	00df4333          	xor	t1,t5,a3
    560c:	00137393          	andi	t2,t1,1
    5610:	007ede93          	srli	t4,t4,0x7
    5614:	0016d893          	srli	a7,a3,0x1
    5618:	00038c63          	beqz	t2,5630 <crcu16+0x248>
    561c:	ffffa637          	lui	a2,0xffffa
    5620:	00160593          	addi	a1,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5624:	00b8c533          	xor	a0,a7,a1
    5628:	01051813          	slli	a6,a0,0x10
    562c:	01085893          	srli	a7,a6,0x10
    5630:	0018fe13          	andi	t3,a7,1
    5634:	0018d513          	srli	a0,a7,0x1
    5638:	01de0c63          	beq	t3,t4,5650 <crcu16+0x268>
    563c:	ffffaf37          	lui	t5,0xffffa
    5640:	001f0f93          	addi	t6,t5,1 # ffffa001 <_stack_top+0xfffd4801>
    5644:	01f54733          	xor	a4,a0,t6
    5648:	01071293          	slli	t0,a4,0x10
    564c:	0102d513          	srli	a0,t0,0x10
    5650:	00008067          	ret
    5654:	ffffa637          	lui	a2,0xffffa
    5658:	00160593          	addi	a1,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    565c:	00be4833          	xor	a6,t3,a1
    5660:	01081893          	slli	a7,a6,0x10
    5664:	0108de13          	srli	t3,a7,0x10
    5668:	eadff06f          	j	5514 <crcu16+0x12c>

0000566c <crcu32>:
    566c:	0ff57713          	zext.b	a4,a0
    5670:	00b74833          	xor	a6,a4,a1
    5674:	01051693          	slli	a3,a0,0x10
    5678:	00187293          	andi	t0,a6,1
    567c:	00050793          	mv	a5,a0
    5680:	0106d313          	srli	t1,a3,0x10
    5684:	00175613          	srli	a2,a4,0x1
    5688:	0015de13          	srli	t3,a1,0x1
    568c:	00028c63          	beqz	t0,56a4 <crcu32+0x38>
    5690:	ffffa5b7          	lui	a1,0xffffa
    5694:	00158393          	addi	t2,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    5698:	007e4533          	xor	a0,t3,t2
    569c:	01051893          	slli	a7,a0,0x10
    56a0:	0108de13          	srli	t3,a7,0x10
    56a4:	01c64eb3          	xor	t4,a2,t3
    56a8:	001eff13          	andi	t5,t4,1
    56ac:	00275f93          	srli	t6,a4,0x2
    56b0:	001e5393          	srli	t2,t3,0x1
    56b4:	000f0c63          	beqz	t5,56cc <crcu32+0x60>
    56b8:	ffffa837          	lui	a6,0xffffa
    56bc:	00180293          	addi	t0,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    56c0:	0053c6b3          	xor	a3,t2,t0
    56c4:	01069613          	slli	a2,a3,0x10
    56c8:	01065393          	srli	t2,a2,0x10
    56cc:	007fc5b3          	xor	a1,t6,t2
    56d0:	0015f893          	andi	a7,a1,1
    56d4:	00375e13          	srli	t3,a4,0x3
    56d8:	0013d813          	srli	a6,t2,0x1
    56dc:	00088c63          	beqz	a7,56f4 <crcu32+0x88>
    56e0:	ffffaeb7          	lui	t4,0xffffa
    56e4:	001e8f13          	addi	t5,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    56e8:	01e84533          	xor	a0,a6,t5
    56ec:	01051f93          	slli	t6,a0,0x10
    56f0:	010fd813          	srli	a6,t6,0x10
    56f4:	010e42b3          	xor	t0,t3,a6
    56f8:	0012f693          	andi	a3,t0,1
    56fc:	00475613          	srli	a2,a4,0x4
    5700:	00185e93          	srli	t4,a6,0x1
    5704:	00068c63          	beqz	a3,571c <crcu32+0xb0>
    5708:	ffffa3b7          	lui	t2,0xffffa
    570c:	00138593          	addi	a1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    5710:	00bec8b3          	xor	a7,t4,a1
    5714:	01089e13          	slli	t3,a7,0x10
    5718:	010e5e93          	srli	t4,t3,0x10
    571c:	01d64f33          	xor	t5,a2,t4
    5720:	001f7f93          	andi	t6,t5,1
    5724:	00575813          	srli	a6,a4,0x5
    5728:	001ed393          	srli	t2,t4,0x1
    572c:	000f8c63          	beqz	t6,5744 <crcu32+0xd8>
    5730:	ffffa2b7          	lui	t0,0xffffa
    5734:	00128693          	addi	a3,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5738:	00d3c533          	xor	a0,t2,a3
    573c:	01051613          	slli	a2,a0,0x10
    5740:	01065393          	srli	t2,a2,0x10
    5744:	007845b3          	xor	a1,a6,t2
    5748:	0015f893          	andi	a7,a1,1
    574c:	00675e13          	srli	t3,a4,0x6
    5750:	0013d293          	srli	t0,t2,0x1
    5754:	00088c63          	beqz	a7,576c <crcu32+0x100>
    5758:	ffffaeb7          	lui	t4,0xffffa
    575c:	001e8f13          	addi	t5,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    5760:	01e2cfb3          	xor	t6,t0,t5
    5764:	010f9813          	slli	a6,t6,0x10
    5768:	01085293          	srli	t0,a6,0x10
    576c:	005e46b3          	xor	a3,t3,t0
    5770:	0016f613          	andi	a2,a3,1
    5774:	00775713          	srli	a4,a4,0x7
    5778:	0012de13          	srli	t3,t0,0x1
    577c:	00060c63          	beqz	a2,5794 <crcu32+0x128>
    5780:	ffffa3b7          	lui	t2,0xffffa
    5784:	00138593          	addi	a1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    5788:	00be4533          	xor	a0,t3,a1
    578c:	01051893          	slli	a7,a0,0x10
    5790:	0108de13          	srli	t3,a7,0x10
    5794:	001e7e93          	andi	t4,t3,1
    5798:	001e5393          	srli	t2,t3,0x1
    579c:	3cee9663          	bne	t4,a4,5b68 <crcu32+0x4fc>
    57a0:	00835713          	srli	a4,t1,0x8
    57a4:	007746b3          	xor	a3,a4,t2
    57a8:	0016f613          	andi	a2,a3,1
    57ac:	00935313          	srli	t1,t1,0x9
    57b0:	0013de93          	srli	t4,t2,0x1
    57b4:	00060c63          	beqz	a2,57cc <crcu32+0x160>
    57b8:	ffffa5b7          	lui	a1,0xffffa
    57bc:	00158893          	addi	a7,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    57c0:	011ec533          	xor	a0,t4,a7
    57c4:	01051e13          	slli	t3,a0,0x10
    57c8:	010e5e93          	srli	t4,t3,0x10
    57cc:	01d34f33          	xor	t5,t1,t4
    57d0:	001f7f93          	andi	t6,t5,1
    57d4:	00275813          	srli	a6,a4,0x2
    57d8:	001ed313          	srli	t1,t4,0x1
    57dc:	000f8c63          	beqz	t6,57f4 <crcu32+0x188>
    57e0:	ffffa2b7          	lui	t0,0xffffa
    57e4:	00128393          	addi	t2,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    57e8:	007346b3          	xor	a3,t1,t2
    57ec:	01069613          	slli	a2,a3,0x10
    57f0:	01065313          	srli	t1,a2,0x10
    57f4:	006845b3          	xor	a1,a6,t1
    57f8:	0015f893          	andi	a7,a1,1
    57fc:	00375e13          	srli	t3,a4,0x3
    5800:	00135813          	srli	a6,t1,0x1
    5804:	00088c63          	beqz	a7,581c <crcu32+0x1b0>
    5808:	ffffaeb7          	lui	t4,0xffffa
    580c:	001e8f13          	addi	t5,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    5810:	01e84533          	xor	a0,a6,t5
    5814:	01051f93          	slli	t6,a0,0x10
    5818:	010fd813          	srli	a6,t6,0x10
    581c:	010e42b3          	xor	t0,t3,a6
    5820:	0012f393          	andi	t2,t0,1
    5824:	00475693          	srli	a3,a4,0x4
    5828:	00185e13          	srli	t3,a6,0x1
    582c:	00038c63          	beqz	t2,5844 <crcu32+0x1d8>
    5830:	ffffa637          	lui	a2,0xffffa
    5834:	00160313          	addi	t1,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5838:	006e45b3          	xor	a1,t3,t1
    583c:	01059893          	slli	a7,a1,0x10
    5840:	0108de13          	srli	t3,a7,0x10
    5844:	01c6ceb3          	xor	t4,a3,t3
    5848:	001eff13          	andi	t5,t4,1
    584c:	00575f93          	srli	t6,a4,0x5
    5850:	001e5313          	srli	t1,t3,0x1
    5854:	000f0c63          	beqz	t5,586c <crcu32+0x200>
    5858:	ffffa837          	lui	a6,0xffffa
    585c:	00180293          	addi	t0,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    5860:	00534533          	xor	a0,t1,t0
    5864:	01051393          	slli	t2,a0,0x10
    5868:	0103d313          	srli	t1,t2,0x10
    586c:	006fc6b3          	xor	a3,t6,t1
    5870:	0016f613          	andi	a2,a3,1
    5874:	00675593          	srli	a1,a4,0x6
    5878:	00135f93          	srli	t6,t1,0x1
    587c:	00060c63          	beqz	a2,5894 <crcu32+0x228>
    5880:	ffffa8b7          	lui	a7,0xffffa
    5884:	00188e13          	addi	t3,a7,1 # ffffa001 <_stack_top+0xfffd4801>
    5888:	01cfceb3          	xor	t4,t6,t3
    588c:	010e9f13          	slli	t5,t4,0x10
    5890:	010f5f93          	srli	t6,t5,0x10
    5894:	01f5c833          	xor	a6,a1,t6
    5898:	00187293          	andi	t0,a6,1
    589c:	00775713          	srli	a4,a4,0x7
    58a0:	001fd613          	srli	a2,t6,0x1
    58a4:	00028c63          	beqz	t0,58bc <crcu32+0x250>
    58a8:	ffffa3b7          	lui	t2,0xffffa
    58ac:	00138313          	addi	t1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    58b0:	00664533          	xor	a0,a2,t1
    58b4:	01051693          	slli	a3,a0,0x10
    58b8:	0106d613          	srli	a2,a3,0x10
    58bc:	00167593          	andi	a1,a2,1
    58c0:	00165f93          	srli	t6,a2,0x1
    58c4:	28e59663          	bne	a1,a4,5b50 <crcu32+0x4e4>
    58c8:	0107d813          	srli	a6,a5,0x10
    58cc:	0ff87293          	zext.b	t0,a6
    58d0:	01f2c733          	xor	a4,t0,t6
    58d4:	00177393          	andi	t2,a4,1
    58d8:	0107d793          	srli	a5,a5,0x10
    58dc:	0012d313          	srli	t1,t0,0x1
    58e0:	001fd893          	srli	a7,t6,0x1
    58e4:	00038c63          	beqz	t2,58fc <crcu32+0x290>
    58e8:	ffffa6b7          	lui	a3,0xffffa
    58ec:	00168613          	addi	a2,a3,1 # ffffa001 <_stack_top+0xfffd4801>
    58f0:	00c8c533          	xor	a0,a7,a2
    58f4:	01051593          	slli	a1,a0,0x10
    58f8:	0105d893          	srli	a7,a1,0x10
    58fc:	01134e33          	xor	t3,t1,a7
    5900:	001e7e93          	andi	t4,t3,1
    5904:	0022df13          	srli	t5,t0,0x2
    5908:	0018d313          	srli	t1,a7,0x1
    590c:	000e8c63          	beqz	t4,5924 <crcu32+0x2b8>
    5910:	ffffafb7          	lui	t6,0xffffa
    5914:	001f8813          	addi	a6,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    5918:	01034733          	xor	a4,t1,a6
    591c:	01071393          	slli	t2,a4,0x10
    5920:	0103d313          	srli	t1,t2,0x10
    5924:	006f46b3          	xor	a3,t5,t1
    5928:	0016f593          	andi	a1,a3,1
    592c:	0032d613          	srli	a2,t0,0x3
    5930:	00135f13          	srli	t5,t1,0x1
    5934:	00058c63          	beqz	a1,594c <crcu32+0x2e0>
    5938:	ffffa8b7          	lui	a7,0xffffa
    593c:	00188e13          	addi	t3,a7,1 # ffffa001 <_stack_top+0xfffd4801>
    5940:	01cf4533          	xor	a0,t5,t3
    5944:	01051e93          	slli	t4,a0,0x10
    5948:	010edf13          	srli	t5,t4,0x10
    594c:	01e64fb3          	xor	t6,a2,t5
    5950:	001ff813          	andi	a6,t6,1
    5954:	0042d713          	srli	a4,t0,0x4
    5958:	001f5893          	srli	a7,t5,0x1
    595c:	00080c63          	beqz	a6,5974 <crcu32+0x308>
    5960:	ffffa3b7          	lui	t2,0xffffa
    5964:	00138313          	addi	t1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    5968:	0068c6b3          	xor	a3,a7,t1
    596c:	01069593          	slli	a1,a3,0x10
    5970:	0105d893          	srli	a7,a1,0x10
    5974:	01174633          	xor	a2,a4,a7
    5978:	00167e13          	andi	t3,a2,1
    597c:	0052de93          	srli	t4,t0,0x5
    5980:	0018d713          	srli	a4,a7,0x1
    5984:	000e0c63          	beqz	t3,599c <crcu32+0x330>
    5988:	ffffaf37          	lui	t5,0xffffa
    598c:	001f0f93          	addi	t6,t5,1 # ffffa001 <_stack_top+0xfffd4801>
    5990:	01f74533          	xor	a0,a4,t6
    5994:	01051813          	slli	a6,a0,0x10
    5998:	01085713          	srli	a4,a6,0x10
    599c:	00eec3b3          	xor	t2,t4,a4
    59a0:	0013f313          	andi	t1,t2,1
    59a4:	0062d693          	srli	a3,t0,0x6
    59a8:	00175e93          	srli	t4,a4,0x1
    59ac:	00030c63          	beqz	t1,59c4 <crcu32+0x358>
    59b0:	ffffa5b7          	lui	a1,0xffffa
    59b4:	00158893          	addi	a7,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    59b8:	011ec633          	xor	a2,t4,a7
    59bc:	01061e13          	slli	t3,a2,0x10
    59c0:	010e5e93          	srli	t4,t3,0x10
    59c4:	01d6cf33          	xor	t5,a3,t4
    59c8:	001f7f93          	andi	t6,t5,1
    59cc:	0072d293          	srli	t0,t0,0x7
    59d0:	001ed313          	srli	t1,t4,0x1
    59d4:	000f8c63          	beqz	t6,59ec <crcu32+0x380>
    59d8:	ffffa837          	lui	a6,0xffffa
    59dc:	00180713          	addi	a4,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    59e0:	00e34533          	xor	a0,t1,a4
    59e4:	01051393          	slli	t2,a0,0x10
    59e8:	0103d313          	srli	t1,t2,0x10
    59ec:	00137693          	andi	a3,t1,1
    59f0:	00135e93          	srli	t4,t1,0x1
    59f4:	14569263          	bne	a3,t0,5b38 <crcu32+0x4cc>
    59f8:	0087df13          	srli	t5,a5,0x8
    59fc:	01df4fb3          	xor	t6,t5,t4
    5a00:	001ff293          	andi	t0,t6,1
    5a04:	0097d793          	srli	a5,a5,0x9
    5a08:	001ed313          	srli	t1,t4,0x1
    5a0c:	00028c63          	beqz	t0,5a24 <crcu32+0x3b8>
    5a10:	ffffa837          	lui	a6,0xffffa
    5a14:	00180713          	addi	a4,a6,1 # ffffa001 <_stack_top+0xfffd4801>
    5a18:	00e34533          	xor	a0,t1,a4
    5a1c:	01051393          	slli	t2,a0,0x10
    5a20:	0103d313          	srli	t1,t2,0x10
    5a24:	0067c6b3          	xor	a3,a5,t1
    5a28:	0016f593          	andi	a1,a3,1
    5a2c:	002f5893          	srli	a7,t5,0x2
    5a30:	00135293          	srli	t0,t1,0x1
    5a34:	00058c63          	beqz	a1,5a4c <crcu32+0x3e0>
    5a38:	ffffa637          	lui	a2,0xffffa
    5a3c:	00160e13          	addi	t3,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5a40:	01c2ceb3          	xor	t4,t0,t3
    5a44:	010e9f93          	slli	t6,t4,0x10
    5a48:	010fd293          	srli	t0,t6,0x10
    5a4c:	0058c7b3          	xor	a5,a7,t0
    5a50:	0017f813          	andi	a6,a5,1
    5a54:	003f5713          	srli	a4,t5,0x3
    5a58:	0012d593          	srli	a1,t0,0x1
    5a5c:	00080c63          	beqz	a6,5a74 <crcu32+0x408>
    5a60:	ffffa3b7          	lui	t2,0xffffa
    5a64:	00138313          	addi	t1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    5a68:	0065c533          	xor	a0,a1,t1
    5a6c:	01051693          	slli	a3,a0,0x10
    5a70:	0106d593          	srli	a1,a3,0x10
    5a74:	00b748b3          	xor	a7,a4,a1
    5a78:	0018f613          	andi	a2,a7,1
    5a7c:	004f5e13          	srli	t3,t5,0x4
    5a80:	0015d813          	srli	a6,a1,0x1
    5a84:	00060c63          	beqz	a2,5a9c <crcu32+0x430>
    5a88:	ffffaeb7          	lui	t4,0xffffa
    5a8c:	001e8f93          	addi	t6,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    5a90:	01f842b3          	xor	t0,a6,t6
    5a94:	01029793          	slli	a5,t0,0x10
    5a98:	0107d813          	srli	a6,a5,0x10
    5a9c:	010e4733          	xor	a4,t3,a6
    5aa0:	00177393          	andi	t2,a4,1
    5aa4:	005f5313          	srli	t1,t5,0x5
    5aa8:	00185613          	srli	a2,a6,0x1
    5aac:	00038c63          	beqz	t2,5ac4 <crcu32+0x458>
    5ab0:	ffffa6b7          	lui	a3,0xffffa
    5ab4:	00168593          	addi	a1,a3,1 # ffffa001 <_stack_top+0xfffd4801>
    5ab8:	00b64533          	xor	a0,a2,a1
    5abc:	01051893          	slli	a7,a0,0x10
    5ac0:	0108d613          	srli	a2,a7,0x10
    5ac4:	00c34e33          	xor	t3,t1,a2
    5ac8:	001e7e93          	andi	t4,t3,1
    5acc:	006f5f93          	srli	t6,t5,0x6
    5ad0:	00165393          	srli	t2,a2,0x1
    5ad4:	000e8c63          	beqz	t4,5aec <crcu32+0x480>
    5ad8:	ffffa2b7          	lui	t0,0xffffa
    5adc:	00128793          	addi	a5,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5ae0:	00f3c833          	xor	a6,t2,a5
    5ae4:	01081713          	slli	a4,a6,0x10
    5ae8:	01075393          	srli	t2,a4,0x10
    5aec:	007fc333          	xor	t1,t6,t2
    5af0:	00137693          	andi	a3,t1,1
    5af4:	007f5f13          	srli	t5,t5,0x7
    5af8:	0013de13          	srli	t3,t2,0x1
    5afc:	00068c63          	beqz	a3,5b14 <crcu32+0x4a8>
    5b00:	ffffa5b7          	lui	a1,0xffffa
    5b04:	00158893          	addi	a7,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    5b08:	011e4533          	xor	a0,t3,a7
    5b0c:	01051613          	slli	a2,a0,0x10
    5b10:	01065e13          	srli	t3,a2,0x10
    5b14:	001e7e93          	andi	t4,t3,1
    5b18:	001e5513          	srli	a0,t3,0x1
    5b1c:	01ee8c63          	beq	t4,t5,5b34 <crcu32+0x4c8>
    5b20:	ffffafb7          	lui	t6,0xffffa
    5b24:	001f8293          	addi	t0,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    5b28:	005547b3          	xor	a5,a0,t0
    5b2c:	01079813          	slli	a6,a5,0x10
    5b30:	01085513          	srli	a0,a6,0x10
    5b34:	00008067          	ret
    5b38:	ffffa5b7          	lui	a1,0xffffa
    5b3c:	00158893          	addi	a7,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    5b40:	011ec633          	xor	a2,t4,a7
    5b44:	01061e13          	slli	t3,a2,0x10
    5b48:	010e5e93          	srli	t4,t3,0x10
    5b4c:	eadff06f          	j	59f8 <crcu32+0x38c>
    5b50:	ffffa8b7          	lui	a7,0xffffa
    5b54:	00188e13          	addi	t3,a7,1 # ffffa001 <_stack_top+0xfffd4801>
    5b58:	01cfceb3          	xor	t4,t6,t3
    5b5c:	010e9f13          	slli	t5,t4,0x10
    5b60:	010f5f93          	srli	t6,t5,0x10
    5b64:	d65ff06f          	j	58c8 <crcu32+0x25c>
    5b68:	ffffaf37          	lui	t5,0xffffa
    5b6c:	001f0f93          	addi	t6,t5,1 # ffffa001 <_stack_top+0xfffd4801>
    5b70:	01f3c833          	xor	a6,t2,t6
    5b74:	01081293          	slli	t0,a6,0x10
    5b78:	0102d393          	srli	t2,t0,0x10
    5b7c:	c25ff06f          	j	57a0 <crcu32+0x134>

00005b80 <crc16>:
    5b80:	0ff57713          	zext.b	a4,a0
    5b84:	00b746b3          	xor	a3,a4,a1
    5b88:	01051793          	slli	a5,a0,0x10
    5b8c:	0016f293          	andi	t0,a3,1
    5b90:	0107d313          	srli	t1,a5,0x10
    5b94:	00175613          	srli	a2,a4,0x1
    5b98:	0015d893          	srli	a7,a1,0x1
    5b9c:	00028c63          	beqz	t0,5bb4 <crc16+0x34>
    5ba0:	ffffa3b7          	lui	t2,0xffffa
    5ba4:	00138593          	addi	a1,t2,1 # ffffa001 <_stack_top+0xfffd4801>
    5ba8:	00b8c533          	xor	a0,a7,a1
    5bac:	01051813          	slli	a6,a0,0x10
    5bb0:	01085893          	srli	a7,a6,0x10
    5bb4:	01164e33          	xor	t3,a2,a7
    5bb8:	001e7e93          	andi	t4,t3,1
    5bbc:	00275f13          	srli	t5,a4,0x2
    5bc0:	0018d393          	srli	t2,a7,0x1
    5bc4:	000e8c63          	beqz	t4,5bdc <crc16+0x5c>
    5bc8:	ffffafb7          	lui	t6,0xffffa
    5bcc:	001f8693          	addi	a3,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    5bd0:	00d3c2b3          	xor	t0,t2,a3
    5bd4:	01029793          	slli	a5,t0,0x10
    5bd8:	0107d393          	srli	t2,a5,0x10
    5bdc:	007f4633          	xor	a2,t5,t2
    5be0:	00167593          	andi	a1,a2,1
    5be4:	00375813          	srli	a6,a4,0x3
    5be8:	0013df13          	srli	t5,t2,0x1
    5bec:	00058c63          	beqz	a1,5c04 <crc16+0x84>
    5bf0:	ffffa8b7          	lui	a7,0xffffa
    5bf4:	00188e13          	addi	t3,a7,1 # ffffa001 <_stack_top+0xfffd4801>
    5bf8:	01cf4533          	xor	a0,t5,t3
    5bfc:	01051e93          	slli	t4,a0,0x10
    5c00:	010edf13          	srli	t5,t4,0x10
    5c04:	01e84fb3          	xor	t6,a6,t5
    5c08:	001ff293          	andi	t0,t6,1
    5c0c:	00475693          	srli	a3,a4,0x4
    5c10:	001f5813          	srli	a6,t5,0x1
    5c14:	00028c63          	beqz	t0,5c2c <crc16+0xac>
    5c18:	ffffa7b7          	lui	a5,0xffffa
    5c1c:	00178393          	addi	t2,a5,1 # ffffa001 <_stack_top+0xfffd4801>
    5c20:	00784633          	xor	a2,a6,t2
    5c24:	01061593          	slli	a1,a2,0x10
    5c28:	0105d813          	srli	a6,a1,0x10
    5c2c:	0106c8b3          	xor	a7,a3,a6
    5c30:	0018fe13          	andi	t3,a7,1
    5c34:	00575e93          	srli	t4,a4,0x5
    5c38:	00185793          	srli	a5,a6,0x1
    5c3c:	000e0c63          	beqz	t3,5c54 <crc16+0xd4>
    5c40:	ffffaf37          	lui	t5,0xffffa
    5c44:	001f0f93          	addi	t6,t5,1 # ffffa001 <_stack_top+0xfffd4801>
    5c48:	01f7c533          	xor	a0,a5,t6
    5c4c:	01051293          	slli	t0,a0,0x10
    5c50:	0102d793          	srli	a5,t0,0x10
    5c54:	00fec6b3          	xor	a3,t4,a5
    5c58:	0016f393          	andi	t2,a3,1
    5c5c:	00675593          	srli	a1,a4,0x6
    5c60:	0017de93          	srli	t4,a5,0x1
    5c64:	00038c63          	beqz	t2,5c7c <crc16+0xfc>
    5c68:	ffffa637          	lui	a2,0xffffa
    5c6c:	00160813          	addi	a6,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5c70:	010ec8b3          	xor	a7,t4,a6
    5c74:	01089e13          	slli	t3,a7,0x10
    5c78:	010e5e93          	srli	t4,t3,0x10
    5c7c:	01d5cf33          	xor	t5,a1,t4
    5c80:	001f7f93          	andi	t6,t5,1
    5c84:	00775713          	srli	a4,a4,0x7
    5c88:	001ed393          	srli	t2,t4,0x1
    5c8c:	000f8c63          	beqz	t6,5ca4 <crc16+0x124>
    5c90:	ffffa2b7          	lui	t0,0xffffa
    5c94:	00128793          	addi	a5,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5c98:	00f3c533          	xor	a0,t2,a5
    5c9c:	01051693          	slli	a3,a0,0x10
    5ca0:	0106d393          	srli	t2,a3,0x10
    5ca4:	0013f593          	andi	a1,t2,1
    5ca8:	0013de93          	srli	t4,t2,0x1
    5cac:	14e59263          	bne	a1,a4,5df0 <crc16+0x270>
    5cb0:	00835f13          	srli	t5,t1,0x8
    5cb4:	01df4fb3          	xor	t6,t5,t4
    5cb8:	001ff293          	andi	t0,t6,1
    5cbc:	00935313          	srli	t1,t1,0x9
    5cc0:	001ed393          	srli	t2,t4,0x1
    5cc4:	00028c63          	beqz	t0,5cdc <crc16+0x15c>
    5cc8:	ffffa737          	lui	a4,0xffffa
    5ccc:	00170793          	addi	a5,a4,1 # ffffa001 <_stack_top+0xfffd4801>
    5cd0:	00f3c533          	xor	a0,t2,a5
    5cd4:	01051693          	slli	a3,a0,0x10
    5cd8:	0106d393          	srli	t2,a3,0x10
    5cdc:	007345b3          	xor	a1,t1,t2
    5ce0:	0015f613          	andi	a2,a1,1
    5ce4:	002f5813          	srli	a6,t5,0x2
    5ce8:	0013d293          	srli	t0,t2,0x1
    5cec:	00060c63          	beqz	a2,5d04 <crc16+0x184>
    5cf0:	ffffa8b7          	lui	a7,0xffffa
    5cf4:	00188e13          	addi	t3,a7,1 # ffffa001 <_stack_top+0xfffd4801>
    5cf8:	01c2ceb3          	xor	t4,t0,t3
    5cfc:	010e9f93          	slli	t6,t4,0x10
    5d00:	010fd293          	srli	t0,t6,0x10
    5d04:	00584333          	xor	t1,a6,t0
    5d08:	00137713          	andi	a4,t1,1
    5d0c:	003f5793          	srli	a5,t5,0x3
    5d10:	0012d613          	srli	a2,t0,0x1
    5d14:	00070c63          	beqz	a4,5d2c <crc16+0x1ac>
    5d18:	ffffa6b7          	lui	a3,0xffffa
    5d1c:	00168393          	addi	t2,a3,1 # ffffa001 <_stack_top+0xfffd4801>
    5d20:	00764533          	xor	a0,a2,t2
    5d24:	01051593          	slli	a1,a0,0x10
    5d28:	0105d613          	srli	a2,a1,0x10
    5d2c:	00c7c833          	xor	a6,a5,a2
    5d30:	00187893          	andi	a7,a6,1
    5d34:	004f5e13          	srli	t3,t5,0x4
    5d38:	00165693          	srli	a3,a2,0x1
    5d3c:	00088c63          	beqz	a7,5d54 <crc16+0x1d4>
    5d40:	ffffaeb7          	lui	t4,0xffffa
    5d44:	001e8f93          	addi	t6,t4,1 # ffffa001 <_stack_top+0xfffd4801>
    5d48:	01f6c2b3          	xor	t0,a3,t6
    5d4c:	01029313          	slli	t1,t0,0x10
    5d50:	01035693          	srli	a3,t1,0x10
    5d54:	00de4733          	xor	a4,t3,a3
    5d58:	00177393          	andi	t2,a4,1
    5d5c:	005f5793          	srli	a5,t5,0x5
    5d60:	0016d893          	srli	a7,a3,0x1
    5d64:	00038c63          	beqz	t2,5d7c <crc16+0x1fc>
    5d68:	ffffa5b7          	lui	a1,0xffffa
    5d6c:	00158613          	addi	a2,a1,1 # ffffa001 <_stack_top+0xfffd4801>
    5d70:	00c8c533          	xor	a0,a7,a2
    5d74:	01051813          	slli	a6,a0,0x10
    5d78:	01085893          	srli	a7,a6,0x10
    5d7c:	0117ce33          	xor	t3,a5,a7
    5d80:	001e7e93          	andi	t4,t3,1
    5d84:	006f5f93          	srli	t6,t5,0x6
    5d88:	0018d393          	srli	t2,a7,0x1
    5d8c:	000e8c63          	beqz	t4,5da4 <crc16+0x224>
    5d90:	ffffa2b7          	lui	t0,0xffffa
    5d94:	00128313          	addi	t1,t0,1 # ffffa001 <_stack_top+0xfffd4801>
    5d98:	0063c6b3          	xor	a3,t2,t1
    5d9c:	01069713          	slli	a4,a3,0x10
    5da0:	01075393          	srli	t2,a4,0x10
    5da4:	007fc7b3          	xor	a5,t6,t2
    5da8:	0017f593          	andi	a1,a5,1
    5dac:	007f5f13          	srli	t5,t5,0x7
    5db0:	0013de13          	srli	t3,t2,0x1
    5db4:	00058c63          	beqz	a1,5dcc <crc16+0x24c>
    5db8:	ffffa637          	lui	a2,0xffffa
    5dbc:	00160813          	addi	a6,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5dc0:	010e4533          	xor	a0,t3,a6
    5dc4:	01051893          	slli	a7,a0,0x10
    5dc8:	0108de13          	srli	t3,a7,0x10
    5dcc:	001e7e93          	andi	t4,t3,1
    5dd0:	001e5513          	srli	a0,t3,0x1
    5dd4:	01ee8c63          	beq	t4,t5,5dec <crc16+0x26c>
    5dd8:	ffffafb7          	lui	t6,0xffffa
    5ddc:	001f8293          	addi	t0,t6,1 # ffffa001 <_stack_top+0xfffd4801>
    5de0:	00554333          	xor	t1,a0,t0
    5de4:	01031693          	slli	a3,t1,0x10
    5de8:	0106d513          	srli	a0,a3,0x10
    5dec:	00008067          	ret
    5df0:	ffffa637          	lui	a2,0xffffa
    5df4:	00160813          	addi	a6,a2,1 # ffffa001 <_stack_top+0xfffd4801>
    5df8:	010ec8b3          	xor	a7,t4,a6
    5dfc:	01089e13          	slli	t3,a7,0x10
    5e00:	010e5e93          	srli	t4,t3,0x10
    5e04:	eadff06f          	j	5cb0 <crc16+0x130>

00005e08 <strnlen>:
    5e08:	00b506b3          	add	a3,a0,a1
    5e0c:	00050793          	mv	a5,a0
    5e10:	00059863          	bnez	a1,5e20 <strnlen+0x18>
    5e14:	0240006f          	j	5e38 <strnlen+0x30>
    5e18:	00178793          	addi	a5,a5,1
    5e1c:	00f68a63          	beq	a3,a5,5e30 <strnlen+0x28>
    5e20:	0007c703          	lbu	a4,0(a5)
    5e24:	fe071ae3          	bnez	a4,5e18 <strnlen+0x10>
    5e28:	40a78533          	sub	a0,a5,a0
    5e2c:	00008067          	ret
    5e30:	40a68533          	sub	a0,a3,a0
    5e34:	00008067          	ret
    5e38:	00000513          	li	a0,0
    5e3c:	00008067          	ret

00005e40 <__moddi3>:
    5e40:	00000713          	li	a4,0
    5e44:	1605c863          	bltz	a1,5fb4 <__moddi3+0x174>
    5e48:	0006da63          	bgez	a3,5e5c <__moddi3+0x1c>
    5e4c:	00c037b3          	snez	a5,a2
    5e50:	40d006b3          	neg	a3,a3
    5e54:	40f686b3          	sub	a3,a3,a5
    5e58:	40c00633          	neg	a2,a2
    5e5c:	00060813          	mv	a6,a2
    5e60:	00050313          	mv	t1,a0
    5e64:	00058e13          	mv	t3,a1
    5e68:	0e069463          	bnez	a3,5f50 <__moddi3+0x110>
    5e6c:	16c5f063          	bgeu	a1,a2,5fcc <__moddi3+0x18c>
    5e70:	000107b7          	lui	a5,0x10
    5e74:	1ef66c63          	bltu	a2,a5,606c <__moddi3+0x22c>
    5e78:	010007b7          	lui	a5,0x1000
    5e7c:	00f637b3          	sltu	a5,a2,a5
    5e80:	40f007b3          	neg	a5,a5
    5e84:	ff87f793          	andi	a5,a5,-8
    5e88:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    5e8c:	00f658b3          	srl	a7,a2,a5
    5e90:	00007697          	auipc	a3,0x7
    5e94:	19068693          	addi	a3,a3,400 # d020 <__clz_tab>
    5e98:	011686b3          	add	a3,a3,a7
    5e9c:	0006c683          	lbu	a3,0(a3)
    5ea0:	02000e93          	li	t4,32
    5ea4:	00f687b3          	add	a5,a3,a5
    5ea8:	40fe88b3          	sub	a7,t4,a5
    5eac:	00fe8c63          	beq	t4,a5,5ec4 <__moddi3+0x84>
    5eb0:	01159e33          	sll	t3,a1,a7
    5eb4:	00f557b3          	srl	a5,a0,a5
    5eb8:	01161833          	sll	a6,a2,a7
    5ebc:	01c7ee33          	or	t3,a5,t3
    5ec0:	01151333          	sll	t1,a0,a7
    5ec4:	01085613          	srli	a2,a6,0x10
    5ec8:	02ce56b3          	divu	a3,t3,a2
    5ecc:	01081593          	slli	a1,a6,0x10
    5ed0:	0105d593          	srli	a1,a1,0x10
    5ed4:	01035793          	srli	a5,t1,0x10
    5ed8:	02ce7e33          	remu	t3,t3,a2
    5edc:	02b686b3          	mul	a3,a3,a1
    5ee0:	010e1e13          	slli	t3,t3,0x10
    5ee4:	01c7e7b3          	or	a5,a5,t3
    5ee8:	00d7f863          	bgeu	a5,a3,5ef8 <__moddi3+0xb8>
    5eec:	00f807b3          	add	a5,a6,a5
    5ef0:	0107e463          	bltu	a5,a6,5ef8 <__moddi3+0xb8>
    5ef4:	3ed7e063          	bltu	a5,a3,62d4 <__moddi3+0x494>
    5ef8:	40d787b3          	sub	a5,a5,a3
    5efc:	02c7d6b3          	divu	a3,a5,a2
    5f00:	01031513          	slli	a0,t1,0x10
    5f04:	01055513          	srli	a0,a0,0x10
    5f08:	02c7f7b3          	remu	a5,a5,a2
    5f0c:	02b686b3          	mul	a3,a3,a1
    5f10:	01079793          	slli	a5,a5,0x10
    5f14:	00f56533          	or	a0,a0,a5
    5f18:	00d57a63          	bgeu	a0,a3,5f2c <__moddi3+0xec>
    5f1c:	00a80533          	add	a0,a6,a0
    5f20:	01056663          	bltu	a0,a6,5f2c <__moddi3+0xec>
    5f24:	00d57463          	bgeu	a0,a3,5f2c <__moddi3+0xec>
    5f28:	01050533          	add	a0,a0,a6
    5f2c:	40d50533          	sub	a0,a0,a3
    5f30:	01155533          	srl	a0,a0,a7
    5f34:	00000593          	li	a1,0
    5f38:	00070a63          	beqz	a4,5f4c <__moddi3+0x10c>
    5f3c:	00a037b3          	snez	a5,a0
    5f40:	40b005b3          	neg	a1,a1
    5f44:	40f585b3          	sub	a1,a1,a5
    5f48:	40a00533          	neg	a0,a0
    5f4c:	00008067          	ret
    5f50:	fed5e4e3          	bltu	a1,a3,5f38 <__moddi3+0xf8>
    5f54:	000107b7          	lui	a5,0x10
    5f58:	1cf6ec63          	bltu	a3,a5,6130 <__moddi3+0x2f0>
    5f5c:	010007b7          	lui	a5,0x1000
    5f60:	00f6b7b3          	sltu	a5,a3,a5
    5f64:	40f007b3          	neg	a5,a5
    5f68:	ff87f793          	andi	a5,a5,-8
    5f6c:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    5f70:	00f6d8b3          	srl	a7,a3,a5
    5f74:	00007817          	auipc	a6,0x7
    5f78:	0ac80813          	addi	a6,a6,172 # d020 <__clz_tab>
    5f7c:	01180833          	add	a6,a6,a7
    5f80:	00084803          	lbu	a6,0(a6)
    5f84:	02000e13          	li	t3,32
    5f88:	00f80833          	add	a6,a6,a5
    5f8c:	410e08b3          	sub	a7,t3,a6
    5f90:	1d0e1863          	bne	t3,a6,6160 <__moddi3+0x320>
    5f94:	00b6e463          	bltu	a3,a1,5f9c <__moddi3+0x15c>
    5f98:	00c56a63          	bltu	a0,a2,5fac <__moddi3+0x16c>
    5f9c:	40c50333          	sub	t1,a0,a2
    5fa0:	40d586b3          	sub	a3,a1,a3
    5fa4:	006535b3          	sltu	a1,a0,t1
    5fa8:	40b685b3          	sub	a1,a3,a1
    5fac:	00030513          	mv	a0,t1
    5fb0:	f89ff06f          	j	5f38 <__moddi3+0xf8>
    5fb4:	00a037b3          	snez	a5,a0
    5fb8:	40b005b3          	neg	a1,a1
    5fbc:	40f585b3          	sub	a1,a1,a5
    5fc0:	40a00533          	neg	a0,a0
    5fc4:	fff00713          	li	a4,-1
    5fc8:	e81ff06f          	j	5e48 <__moddi3+0x8>
    5fcc:	0a060863          	beqz	a2,607c <__moddi3+0x23c>
    5fd0:	000107b7          	lui	a5,0x10
    5fd4:	2cf67e63          	bgeu	a2,a5,62b0 <__moddi3+0x470>
    5fd8:	10063693          	sltiu	a3,a2,256
    5fdc:	0016c693          	xori	a3,a3,1
    5fe0:	00369693          	slli	a3,a3,0x3
    5fe4:	00d658b3          	srl	a7,a2,a3
    5fe8:	00007797          	auipc	a5,0x7
    5fec:	03878793          	addi	a5,a5,56 # d020 <__clz_tab>
    5ff0:	011787b3          	add	a5,a5,a7
    5ff4:	0007c783          	lbu	a5,0(a5)
    5ff8:	02000e13          	li	t3,32
    5ffc:	00d787b3          	add	a5,a5,a3
    6000:	40fe08b3          	sub	a7,t3,a5
    6004:	0afe1063          	bne	t3,a5,60a4 <__moddi3+0x264>
    6008:	40c586b3          	sub	a3,a1,a2
    600c:	01065e13          	srli	t3,a2,0x10
    6010:	01061613          	slli	a2,a2,0x10
    6014:	01065613          	srli	a2,a2,0x10
    6018:	03c6d5b3          	divu	a1,a3,t3
    601c:	01035793          	srli	a5,t1,0x10
    6020:	03c6f6b3          	remu	a3,a3,t3
    6024:	02c585b3          	mul	a1,a1,a2
    6028:	01069693          	slli	a3,a3,0x10
    602c:	00d7e7b3          	or	a5,a5,a3
    6030:	00b7fa63          	bgeu	a5,a1,6044 <__moddi3+0x204>
    6034:	00f807b3          	add	a5,a6,a5
    6038:	0107e663          	bltu	a5,a6,6044 <__moddi3+0x204>
    603c:	00b7f463          	bgeu	a5,a1,6044 <__moddi3+0x204>
    6040:	010787b3          	add	a5,a5,a6
    6044:	40b787b3          	sub	a5,a5,a1
    6048:	03c7d6b3          	divu	a3,a5,t3
    604c:	01031313          	slli	t1,t1,0x10
    6050:	01035313          	srli	t1,t1,0x10
    6054:	03c7f7b3          	remu	a5,a5,t3
    6058:	02c686b3          	mul	a3,a3,a2
    605c:	01079513          	slli	a0,a5,0x10
    6060:	00a36533          	or	a0,t1,a0
    6064:	ecd574e3          	bgeu	a0,a3,5f2c <__moddi3+0xec>
    6068:	eb5ff06f          	j	5f1c <__moddi3+0xdc>
    606c:	10063793          	sltiu	a5,a2,256
    6070:	0017c793          	xori	a5,a5,1
    6074:	00379793          	slli	a5,a5,0x3
    6078:	e15ff06f          	j	5e8c <__moddi3+0x4c>
    607c:	00000893          	li	a7,0
    6080:	00007797          	auipc	a5,0x7
    6084:	fa078793          	addi	a5,a5,-96 # d020 <__clz_tab>
    6088:	011787b3          	add	a5,a5,a7
    608c:	0007c783          	lbu	a5,0(a5)
    6090:	00000693          	li	a3,0
    6094:	02000e13          	li	t3,32
    6098:	00d787b3          	add	a5,a5,a3
    609c:	40fe08b3          	sub	a7,t3,a5
    60a0:	f6fe04e3          	beq	t3,a5,6008 <__moddi3+0x1c8>
    60a4:	01161833          	sll	a6,a2,a7
    60a8:	00f5deb3          	srl	t4,a1,a5
    60ac:	01085e13          	srli	t3,a6,0x10
    60b0:	03cedf33          	divu	t5,t4,t3
    60b4:	01081613          	slli	a2,a6,0x10
    60b8:	011595b3          	sll	a1,a1,a7
    60bc:	00f556b3          	srl	a3,a0,a5
    60c0:	01065613          	srli	a2,a2,0x10
    60c4:	00b6e6b3          	or	a3,a3,a1
    60c8:	0106d793          	srli	a5,a3,0x10
    60cc:	01151333          	sll	t1,a0,a7
    60d0:	03cefeb3          	remu	t4,t4,t3
    60d4:	02cf05b3          	mul	a1,t5,a2
    60d8:	010e9e93          	slli	t4,t4,0x10
    60dc:	01d7e7b3          	or	a5,a5,t4
    60e0:	00b7fa63          	bgeu	a5,a1,60f4 <__moddi3+0x2b4>
    60e4:	00f807b3          	add	a5,a6,a5
    60e8:	0107e663          	bltu	a5,a6,60f4 <__moddi3+0x2b4>
    60ec:	00b7f463          	bgeu	a5,a1,60f4 <__moddi3+0x2b4>
    60f0:	010787b3          	add	a5,a5,a6
    60f4:	40b787b3          	sub	a5,a5,a1
    60f8:	03c7d5b3          	divu	a1,a5,t3
    60fc:	01069693          	slli	a3,a3,0x10
    6100:	0106d693          	srli	a3,a3,0x10
    6104:	03c7f7b3          	remu	a5,a5,t3
    6108:	02c585b3          	mul	a1,a1,a2
    610c:	01079793          	slli	a5,a5,0x10
    6110:	00f6e6b3          	or	a3,a3,a5
    6114:	00b6fa63          	bgeu	a3,a1,6128 <__moddi3+0x2e8>
    6118:	00d806b3          	add	a3,a6,a3
    611c:	0106e663          	bltu	a3,a6,6128 <__moddi3+0x2e8>
    6120:	00b6f463          	bgeu	a3,a1,6128 <__moddi3+0x2e8>
    6124:	010686b3          	add	a3,a3,a6
    6128:	40b686b3          	sub	a3,a3,a1
    612c:	eedff06f          	j	6018 <__moddi3+0x1d8>
    6130:	1006b793          	sltiu	a5,a3,256
    6134:	0017c793          	xori	a5,a5,1
    6138:	00379793          	slli	a5,a5,0x3
    613c:	00f6d8b3          	srl	a7,a3,a5
    6140:	00007817          	auipc	a6,0x7
    6144:	ee080813          	addi	a6,a6,-288 # d020 <__clz_tab>
    6148:	01180833          	add	a6,a6,a7
    614c:	00084803          	lbu	a6,0(a6)
    6150:	02000e13          	li	t3,32
    6154:	00f80833          	add	a6,a6,a5
    6158:	410e08b3          	sub	a7,t3,a6
    615c:	e30e0ce3          	beq	t3,a6,5f94 <__moddi3+0x154>
    6160:	011696b3          	sll	a3,a3,a7
    6164:	01065333          	srl	t1,a2,a6
    6168:	00d36333          	or	t1,t1,a3
    616c:	0105deb3          	srl	t4,a1,a6
    6170:	01035f93          	srli	t6,t1,0x10
    6174:	03fed7b3          	divu	a5,t4,t6
    6178:	01031f13          	slli	t5,t1,0x10
    617c:	010f5f13          	srli	t5,t5,0x10
    6180:	010556b3          	srl	a3,a0,a6
    6184:	01151e33          	sll	t3,a0,a7
    6188:	011595b3          	sll	a1,a1,a7
    618c:	00b6e5b3          	or	a1,a3,a1
    6190:	0105d693          	srli	a3,a1,0x10
    6194:	01161633          	sll	a2,a2,a7
    6198:	03fefeb3          	remu	t4,t4,t6
    619c:	02ff0533          	mul	a0,t5,a5
    61a0:	010e9e93          	slli	t4,t4,0x10
    61a4:	01d6e6b3          	or	a3,a3,t4
    61a8:	00a6fe63          	bgeu	a3,a0,61c4 <__moddi3+0x384>
    61ac:	00d306b3          	add	a3,t1,a3
    61b0:	fff78e93          	addi	t4,a5,-1
    61b4:	1066ec63          	bltu	a3,t1,62cc <__moddi3+0x48c>
    61b8:	10a6fa63          	bgeu	a3,a0,62cc <__moddi3+0x48c>
    61bc:	ffe78793          	addi	a5,a5,-2
    61c0:	006686b3          	add	a3,a3,t1
    61c4:	40a686b3          	sub	a3,a3,a0
    61c8:	03f6d533          	divu	a0,a3,t6
    61cc:	01059593          	slli	a1,a1,0x10
    61d0:	0105d593          	srli	a1,a1,0x10
    61d4:	03f6f6b3          	remu	a3,a3,t6
    61d8:	02af0f33          	mul	t5,t5,a0
    61dc:	01069693          	slli	a3,a3,0x10
    61e0:	00d5e5b3          	or	a1,a1,a3
    61e4:	01e5fe63          	bgeu	a1,t5,6200 <__moddi3+0x3c0>
    61e8:	00b305b3          	add	a1,t1,a1
    61ec:	fff50693          	addi	a3,a0,-1
    61f0:	0c65ea63          	bltu	a1,t1,62c4 <__moddi3+0x484>
    61f4:	0de5f863          	bgeu	a1,t5,62c4 <__moddi3+0x484>
    61f8:	ffe50513          	addi	a0,a0,-2
    61fc:	006585b3          	add	a1,a1,t1
    6200:	01079693          	slli	a3,a5,0x10
    6204:	000103b7          	lui	t2,0x10
    6208:	00a6e6b3          	or	a3,a3,a0
    620c:	fff38513          	addi	a0,t2,-1 # ffff <seed1_volatile+0x265f>
    6210:	00a6feb3          	and	t4,a3,a0
    6214:	01065293          	srli	t0,a2,0x10
    6218:	0106d693          	srli	a3,a3,0x10
    621c:	00a67533          	and	a0,a2,a0
    6220:	02ae8fb3          	mul	t6,t4,a0
    6224:	41e585b3          	sub	a1,a1,t5
    6228:	02a68533          	mul	a0,a3,a0
    622c:	010fd793          	srli	a5,t6,0x10
    6230:	025e8eb3          	mul	t4,t4,t0
    6234:	00ae8eb3          	add	t4,t4,a0
    6238:	01d787b3          	add	a5,a5,t4
    623c:	025686b3          	mul	a3,a3,t0
    6240:	00a7f463          	bgeu	a5,a0,6248 <__moddi3+0x408>
    6244:	007686b3          	add	a3,a3,t2
    6248:	00010f37          	lui	t5,0x10
    624c:	ffff0f13          	addi	t5,t5,-1 # ffff <seed1_volatile+0x265f>
    6250:	01e7f533          	and	a0,a5,t5
    6254:	0107de93          	srli	t4,a5,0x10
    6258:	01051513          	slli	a0,a0,0x10
    625c:	01efffb3          	and	t6,t6,t5
    6260:	00de87b3          	add	a5,t4,a3
    6264:	01f50533          	add	a0,a0,t6
    6268:	02f5e863          	bltu	a1,a5,6298 <__moddi3+0x458>
    626c:	02f58463          	beq	a1,a5,6294 <__moddi3+0x454>
    6270:	40ae0533          	sub	a0,t3,a0
    6274:	00ae3e33          	sltu	t3,t3,a0
    6278:	40f585b3          	sub	a1,a1,a5
    627c:	41c585b3          	sub	a1,a1,t3
    6280:	01059833          	sll	a6,a1,a6
    6284:	01155533          	srl	a0,a0,a7
    6288:	00a86533          	or	a0,a6,a0
    628c:	0115d5b3          	srl	a1,a1,a7
    6290:	ca9ff06f          	j	5f38 <__moddi3+0xf8>
    6294:	fcae7ee3          	bgeu	t3,a0,6270 <__moddi3+0x430>
    6298:	40c50633          	sub	a2,a0,a2
    629c:	00c53533          	sltu	a0,a0,a2
    62a0:	00650333          	add	t1,a0,t1
    62a4:	406787b3          	sub	a5,a5,t1
    62a8:	00060513          	mv	a0,a2
    62ac:	fc5ff06f          	j	6270 <__moddi3+0x430>
    62b0:	010007b7          	lui	a5,0x1000
    62b4:	02f67463          	bgeu	a2,a5,62dc <__moddi3+0x49c>
    62b8:	01065893          	srli	a7,a2,0x10
    62bc:	01000693          	li	a3,16
    62c0:	d29ff06f          	j	5fe8 <__moddi3+0x1a8>
    62c4:	00068513          	mv	a0,a3
    62c8:	f39ff06f          	j	6200 <__moddi3+0x3c0>
    62cc:	000e8793          	mv	a5,t4
    62d0:	ef5ff06f          	j	61c4 <__moddi3+0x384>
    62d4:	010787b3          	add	a5,a5,a6
    62d8:	c21ff06f          	j	5ef8 <__moddi3+0xb8>
    62dc:	01865893          	srli	a7,a2,0x18
    62e0:	01800693          	li	a3,24
    62e4:	d05ff06f          	j	5fe8 <__moddi3+0x1a8>

000062e8 <__udivdi3>:
    62e8:	00060813          	mv	a6,a2
    62ec:	00050893          	mv	a7,a0
    62f0:	00058713          	mv	a4,a1
    62f4:	0e069263          	bnez	a3,63d8 <__udivdi3+0xf0>
    62f8:	14c5f263          	bgeu	a1,a2,643c <__udivdi3+0x154>
    62fc:	000107b7          	lui	a5,0x10
    6300:	20f66263          	bltu	a2,a5,6504 <__udivdi3+0x21c>
    6304:	010007b7          	lui	a5,0x1000
    6308:	00f637b3          	sltu	a5,a2,a5
    630c:	40f007b3          	neg	a5,a5
    6310:	ff87f793          	andi	a5,a5,-8
    6314:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    6318:	00f65333          	srl	t1,a2,a5
    631c:	00007697          	auipc	a3,0x7
    6320:	d0468693          	addi	a3,a3,-764 # d020 <__clz_tab>
    6324:	006686b3          	add	a3,a3,t1
    6328:	0006c683          	lbu	a3,0(a3)
    632c:	02000313          	li	t1,32
    6330:	00f687b3          	add	a5,a3,a5
    6334:	40f306b3          	sub	a3,t1,a5
    6338:	00f30c63          	beq	t1,a5,6350 <__udivdi3+0x68>
    633c:	00d59733          	sll	a4,a1,a3
    6340:	00f557b3          	srl	a5,a0,a5
    6344:	00d61833          	sll	a6,a2,a3
    6348:	00e7e733          	or	a4,a5,a4
    634c:	00d518b3          	sll	a7,a0,a3
    6350:	01085613          	srli	a2,a6,0x10
    6354:	02c75533          	divu	a0,a4,a2
    6358:	01081693          	slli	a3,a6,0x10
    635c:	0106d693          	srli	a3,a3,0x10
    6360:	0108d793          	srli	a5,a7,0x10
    6364:	02c77733          	remu	a4,a4,a2
    6368:	02a685b3          	mul	a1,a3,a0
    636c:	01071713          	slli	a4,a4,0x10
    6370:	00e7e7b3          	or	a5,a5,a4
    6374:	00b7fc63          	bgeu	a5,a1,638c <__udivdi3+0xa4>
    6378:	00f807b3          	add	a5,a6,a5
    637c:	fff50713          	addi	a4,a0,-1
    6380:	0107e463          	bltu	a5,a6,6388 <__udivdi3+0xa0>
    6384:	40b7e263          	bltu	a5,a1,6788 <__udivdi3+0x4a0>
    6388:	00070513          	mv	a0,a4
    638c:	40b787b3          	sub	a5,a5,a1
    6390:	02c7d733          	divu	a4,a5,a2
    6394:	01089893          	slli	a7,a7,0x10
    6398:	0108d893          	srli	a7,a7,0x10
    639c:	02c7f7b3          	remu	a5,a5,a2
    63a0:	02e686b3          	mul	a3,a3,a4
    63a4:	01079793          	slli	a5,a5,0x10
    63a8:	00f8e8b3          	or	a7,a7,a5
    63ac:	00d8fe63          	bgeu	a7,a3,63c8 <__udivdi3+0xe0>
    63b0:	011808b3          	add	a7,a6,a7
    63b4:	fff70793          	addi	a5,a4,-1
    63b8:	0108e663          	bltu	a7,a6,63c4 <__udivdi3+0xdc>
    63bc:	ffe70713          	addi	a4,a4,-2
    63c0:	00d8e463          	bltu	a7,a3,63c8 <__udivdi3+0xe0>
    63c4:	00078713          	mv	a4,a5
    63c8:	01051513          	slli	a0,a0,0x10
    63cc:	00e56533          	or	a0,a0,a4
    63d0:	00000593          	li	a1,0
    63d4:	00008067          	ret
    63d8:	00d5f863          	bgeu	a1,a3,63e8 <__udivdi3+0x100>
    63dc:	00000593          	li	a1,0
    63e0:	00000513          	li	a0,0
    63e4:	00008067          	ret
    63e8:	000107b7          	lui	a5,0x10
    63ec:	1ef6ea63          	bltu	a3,a5,65e0 <__udivdi3+0x2f8>
    63f0:	010007b7          	lui	a5,0x1000
    63f4:	00f6b7b3          	sltu	a5,a3,a5
    63f8:	40f007b3          	neg	a5,a5
    63fc:	ff87f793          	andi	a5,a5,-8
    6400:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    6404:	00f6d833          	srl	a6,a3,a5
    6408:	00007717          	auipc	a4,0x7
    640c:	c1870713          	addi	a4,a4,-1000 # d020 <__clz_tab>
    6410:	01070733          	add	a4,a4,a6
    6414:	00074703          	lbu	a4,0(a4)
    6418:	02000893          	li	a7,32
    641c:	00f70733          	add	a4,a4,a5
    6420:	40e88833          	sub	a6,a7,a4
    6424:	1ee89663          	bne	a7,a4,6610 <__udivdi3+0x328>
    6428:	32b6e463          	bltu	a3,a1,6750 <__udivdi3+0x468>
    642c:	00c53533          	sltu	a0,a0,a2
    6430:	00154513          	xori	a0,a0,1
    6434:	00000593          	li	a1,0
    6438:	00008067          	ret
    643c:	0c060c63          	beqz	a2,6514 <__udivdi3+0x22c>
    6440:	000107b7          	lui	a5,0x10
    6444:	2ef67c63          	bgeu	a2,a5,673c <__udivdi3+0x454>
    6448:	10063713          	sltiu	a4,a2,256
    644c:	00174713          	xori	a4,a4,1
    6450:	00371713          	slli	a4,a4,0x3
    6454:	00e656b3          	srl	a3,a2,a4
    6458:	00007797          	auipc	a5,0x7
    645c:	bc878793          	addi	a5,a5,-1080 # d020 <__clz_tab>
    6460:	00d787b3          	add	a5,a5,a3
    6464:	0007c783          	lbu	a5,0(a5)
    6468:	02000693          	li	a3,32
    646c:	00e787b3          	add	a5,a5,a4
    6470:	40f68eb3          	sub	t4,a3,a5
    6474:	0cf69463          	bne	a3,a5,653c <__udivdi3+0x254>
    6478:	40c587b3          	sub	a5,a1,a2
    647c:	01065693          	srli	a3,a2,0x10
    6480:	01061613          	slli	a2,a2,0x10
    6484:	01065613          	srli	a2,a2,0x10
    6488:	00100593          	li	a1,1
    648c:	02d7d533          	divu	a0,a5,a3
    6490:	0108d713          	srli	a4,a7,0x10
    6494:	02d7f7b3          	remu	a5,a5,a3
    6498:	02c50333          	mul	t1,a0,a2
    649c:	01079793          	slli	a5,a5,0x10
    64a0:	00f767b3          	or	a5,a4,a5
    64a4:	0067fc63          	bgeu	a5,t1,64bc <__udivdi3+0x1d4>
    64a8:	00f807b3          	add	a5,a6,a5
    64ac:	fff50713          	addi	a4,a0,-1
    64b0:	0107e463          	bltu	a5,a6,64b8 <__udivdi3+0x1d0>
    64b4:	2c67e463          	bltu	a5,t1,677c <__udivdi3+0x494>
    64b8:	00070513          	mv	a0,a4
    64bc:	406787b3          	sub	a5,a5,t1
    64c0:	02d7d733          	divu	a4,a5,a3
    64c4:	01089893          	slli	a7,a7,0x10
    64c8:	0108d893          	srli	a7,a7,0x10
    64cc:	02d7f7b3          	remu	a5,a5,a3
    64d0:	02c70633          	mul	a2,a4,a2
    64d4:	01079793          	slli	a5,a5,0x10
    64d8:	00f8e8b3          	or	a7,a7,a5
    64dc:	00c8fe63          	bgeu	a7,a2,64f8 <__udivdi3+0x210>
    64e0:	011808b3          	add	a7,a6,a7
    64e4:	fff70793          	addi	a5,a4,-1
    64e8:	0108e663          	bltu	a7,a6,64f4 <__udivdi3+0x20c>
    64ec:	ffe70713          	addi	a4,a4,-2
    64f0:	00c8e463          	bltu	a7,a2,64f8 <__udivdi3+0x210>
    64f4:	00078713          	mv	a4,a5
    64f8:	01051513          	slli	a0,a0,0x10
    64fc:	00e56533          	or	a0,a0,a4
    6500:	00008067          	ret
    6504:	10063793          	sltiu	a5,a2,256
    6508:	0017c793          	xori	a5,a5,1
    650c:	00379793          	slli	a5,a5,0x3
    6510:	e09ff06f          	j	6318 <__udivdi3+0x30>
    6514:	00000693          	li	a3,0
    6518:	00007797          	auipc	a5,0x7
    651c:	b0878793          	addi	a5,a5,-1272 # d020 <__clz_tab>
    6520:	00d787b3          	add	a5,a5,a3
    6524:	0007c783          	lbu	a5,0(a5)
    6528:	00000713          	li	a4,0
    652c:	02000693          	li	a3,32
    6530:	00e787b3          	add	a5,a5,a4
    6534:	40f68eb3          	sub	t4,a3,a5
    6538:	f4f680e3          	beq	a3,a5,6478 <__udivdi3+0x190>
    653c:	01d61833          	sll	a6,a2,t4
    6540:	00f5d333          	srl	t1,a1,a5
    6544:	01085693          	srli	a3,a6,0x10
    6548:	02d35e33          	divu	t3,t1,a3
    654c:	01081613          	slli	a2,a6,0x10
    6550:	01d595b3          	sll	a1,a1,t4
    6554:	01065613          	srli	a2,a2,0x10
    6558:	00f557b3          	srl	a5,a0,a5
    655c:	00b7e7b3          	or	a5,a5,a1
    6560:	0107d713          	srli	a4,a5,0x10
    6564:	01d518b3          	sll	a7,a0,t4
    6568:	02d37333          	remu	t1,t1,a3
    656c:	03c605b3          	mul	a1,a2,t3
    6570:	01031313          	slli	t1,t1,0x10
    6574:	00676733          	or	a4,a4,t1
    6578:	00b77e63          	bgeu	a4,a1,6594 <__udivdi3+0x2ac>
    657c:	00e80733          	add	a4,a6,a4
    6580:	fffe0513          	addi	a0,t3,-1
    6584:	1f076463          	bltu	a4,a6,676c <__udivdi3+0x484>
    6588:	1eb77263          	bgeu	a4,a1,676c <__udivdi3+0x484>
    658c:	ffee0e13          	addi	t3,t3,-2
    6590:	01070733          	add	a4,a4,a6
    6594:	40b70733          	sub	a4,a4,a1
    6598:	02d75533          	divu	a0,a4,a3
    659c:	01079793          	slli	a5,a5,0x10
    65a0:	0107d793          	srli	a5,a5,0x10
    65a4:	02d77733          	remu	a4,a4,a3
    65a8:	02a60333          	mul	t1,a2,a0
    65ac:	01071713          	slli	a4,a4,0x10
    65b0:	00e7e7b3          	or	a5,a5,a4
    65b4:	0067fe63          	bgeu	a5,t1,65d0 <__udivdi3+0x2e8>
    65b8:	00f807b3          	add	a5,a6,a5
    65bc:	fff50713          	addi	a4,a0,-1
    65c0:	1907ee63          	bltu	a5,a6,675c <__udivdi3+0x474>
    65c4:	1867fc63          	bgeu	a5,t1,675c <__udivdi3+0x474>
    65c8:	ffe50513          	addi	a0,a0,-2
    65cc:	010787b3          	add	a5,a5,a6
    65d0:	010e1593          	slli	a1,t3,0x10
    65d4:	406787b3          	sub	a5,a5,t1
    65d8:	00a5e5b3          	or	a1,a1,a0
    65dc:	eb1ff06f          	j	648c <__udivdi3+0x1a4>
    65e0:	1006b793          	sltiu	a5,a3,256
    65e4:	0017c793          	xori	a5,a5,1
    65e8:	00379793          	slli	a5,a5,0x3
    65ec:	00f6d833          	srl	a6,a3,a5
    65f0:	00007717          	auipc	a4,0x7
    65f4:	a3070713          	addi	a4,a4,-1488 # d020 <__clz_tab>
    65f8:	01070733          	add	a4,a4,a6
    65fc:	00074703          	lbu	a4,0(a4)
    6600:	02000893          	li	a7,32
    6604:	00f70733          	add	a4,a4,a5
    6608:	40e88833          	sub	a6,a7,a4
    660c:	e0e88ee3          	beq	a7,a4,6428 <__udivdi3+0x140>
    6610:	00e65e33          	srl	t3,a2,a4
    6614:	010696b3          	sll	a3,a3,a6
    6618:	00de6e33          	or	t3,t3,a3
    661c:	00e5d8b3          	srl	a7,a1,a4
    6620:	010e5e93          	srli	t4,t3,0x10
    6624:	03d8d7b3          	divu	a5,a7,t4
    6628:	010e1313          	slli	t1,t3,0x10
    662c:	010595b3          	sll	a1,a1,a6
    6630:	01035313          	srli	t1,t1,0x10
    6634:	00e55733          	srl	a4,a0,a4
    6638:	00b76733          	or	a4,a4,a1
    663c:	01075693          	srli	a3,a4,0x10
    6640:	01061633          	sll	a2,a2,a6
    6644:	03d8f8b3          	remu	a7,a7,t4
    6648:	02f305b3          	mul	a1,t1,a5
    664c:	01089893          	slli	a7,a7,0x10
    6650:	0116e6b3          	or	a3,a3,a7
    6654:	00b6fe63          	bgeu	a3,a1,6670 <__udivdi3+0x388>
    6658:	00de06b3          	add	a3,t3,a3
    665c:	fff78893          	addi	a7,a5,-1
    6660:	11c6ea63          	bltu	a3,t3,6774 <__udivdi3+0x48c>
    6664:	10b6f863          	bgeu	a3,a1,6774 <__udivdi3+0x48c>
    6668:	ffe78793          	addi	a5,a5,-2
    666c:	01c686b3          	add	a3,a3,t3
    6670:	40b686b3          	sub	a3,a3,a1
    6674:	03d6d5b3          	divu	a1,a3,t4
    6678:	01071713          	slli	a4,a4,0x10
    667c:	01075713          	srli	a4,a4,0x10
    6680:	03d6f6b3          	remu	a3,a3,t4
    6684:	02b308b3          	mul	a7,t1,a1
    6688:	01069693          	slli	a3,a3,0x10
    668c:	00d76733          	or	a4,a4,a3
    6690:	01177e63          	bgeu	a4,a7,66ac <__udivdi3+0x3c4>
    6694:	00ee0733          	add	a4,t3,a4
    6698:	fff58693          	addi	a3,a1,-1
    669c:	0dc76463          	bltu	a4,t3,6764 <__udivdi3+0x47c>
    66a0:	0d177263          	bgeu	a4,a7,6764 <__udivdi3+0x47c>
    66a4:	ffe58593          	addi	a1,a1,-2
    66a8:	01c70733          	add	a4,a4,t3
    66ac:	01079793          	slli	a5,a5,0x10
    66b0:	00010eb7          	lui	t4,0x10
    66b4:	00b7e7b3          	or	a5,a5,a1
    66b8:	fffe8693          	addi	a3,t4,-1 # ffff <seed1_volatile+0x265f>
    66bc:	00d7f5b3          	and	a1,a5,a3
    66c0:	0107d313          	srli	t1,a5,0x10
    66c4:	00d676b3          	and	a3,a2,a3
    66c8:	01065613          	srli	a2,a2,0x10
    66cc:	02d58e33          	mul	t3,a1,a3
    66d0:	41170733          	sub	a4,a4,a7
    66d4:	02d306b3          	mul	a3,t1,a3
    66d8:	010e5893          	srli	a7,t3,0x10
    66dc:	02c585b3          	mul	a1,a1,a2
    66e0:	00d585b3          	add	a1,a1,a3
    66e4:	00b885b3          	add	a1,a7,a1
    66e8:	02c30333          	mul	t1,t1,a2
    66ec:	00d5f463          	bgeu	a1,a3,66f4 <__udivdi3+0x40c>
    66f0:	01d30333          	add	t1,t1,t4
    66f4:	0105d693          	srli	a3,a1,0x10
    66f8:	006686b3          	add	a3,a3,t1
    66fc:	02d76a63          	bltu	a4,a3,6730 <__udivdi3+0x448>
    6700:	00d70863          	beq	a4,a3,6710 <__udivdi3+0x428>
    6704:	00078513          	mv	a0,a5
    6708:	00000593          	li	a1,0
    670c:	00008067          	ret
    6710:	000106b7          	lui	a3,0x10
    6714:	fff68693          	addi	a3,a3,-1 # ffff <seed1_volatile+0x265f>
    6718:	00d5f733          	and	a4,a1,a3
    671c:	01071713          	slli	a4,a4,0x10
    6720:	00de7e33          	and	t3,t3,a3
    6724:	01051533          	sll	a0,a0,a6
    6728:	01c70733          	add	a4,a4,t3
    672c:	fce57ce3          	bgeu	a0,a4,6704 <__udivdi3+0x41c>
    6730:	fff78513          	addi	a0,a5,-1
    6734:	00000593          	li	a1,0
    6738:	00008067          	ret
    673c:	010007b7          	lui	a5,0x1000
    6740:	04f67a63          	bgeu	a2,a5,6794 <__udivdi3+0x4ac>
    6744:	01065693          	srli	a3,a2,0x10
    6748:	01000713          	li	a4,16
    674c:	d0dff06f          	j	6458 <__udivdi3+0x170>
    6750:	00000593          	li	a1,0
    6754:	00100513          	li	a0,1
    6758:	00008067          	ret
    675c:	00070513          	mv	a0,a4
    6760:	e71ff06f          	j	65d0 <__udivdi3+0x2e8>
    6764:	00068593          	mv	a1,a3
    6768:	f45ff06f          	j	66ac <__udivdi3+0x3c4>
    676c:	00050e13          	mv	t3,a0
    6770:	e25ff06f          	j	6594 <__udivdi3+0x2ac>
    6774:	00088793          	mv	a5,a7
    6778:	ef9ff06f          	j	6670 <__udivdi3+0x388>
    677c:	ffe50513          	addi	a0,a0,-2
    6780:	010787b3          	add	a5,a5,a6
    6784:	d39ff06f          	j	64bc <__udivdi3+0x1d4>
    6788:	ffe50513          	addi	a0,a0,-2
    678c:	010787b3          	add	a5,a5,a6
    6790:	bfdff06f          	j	638c <__udivdi3+0xa4>
    6794:	01865693          	srli	a3,a2,0x18
    6798:	01800713          	li	a4,24
    679c:	cbdff06f          	j	6458 <__udivdi3+0x170>

000067a0 <__umoddi3>:
    67a0:	00060813          	mv	a6,a2
    67a4:	00050893          	mv	a7,a0
    67a8:	00058313          	mv	t1,a1
    67ac:	00058713          	mv	a4,a1
    67b0:	0c069a63          	bnez	a3,6884 <__umoddi3+0xe4>
    67b4:	12c5fe63          	bgeu	a1,a2,68f0 <__umoddi3+0x150>
    67b8:	000107b7          	lui	a5,0x10
    67bc:	1ef66063          	bltu	a2,a5,699c <__umoddi3+0x1fc>
    67c0:	010007b7          	lui	a5,0x1000
    67c4:	00f637b3          	sltu	a5,a2,a5
    67c8:	40f007b3          	neg	a5,a5
    67cc:	ff87f793          	andi	a5,a5,-8
    67d0:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    67d4:	00f65333          	srl	t1,a2,a5
    67d8:	00007697          	auipc	a3,0x7
    67dc:	84868693          	addi	a3,a3,-1976 # d020 <__clz_tab>
    67e0:	006686b3          	add	a3,a3,t1
    67e4:	0006c683          	lbu	a3,0(a3)
    67e8:	02000313          	li	t1,32
    67ec:	00f687b3          	add	a5,a3,a5
    67f0:	40f306b3          	sub	a3,t1,a5
    67f4:	00f30c63          	beq	t1,a5,680c <__umoddi3+0x6c>
    67f8:	00d59733          	sll	a4,a1,a3
    67fc:	00f557b3          	srl	a5,a0,a5
    6800:	00d61833          	sll	a6,a2,a3
    6804:	00e7e733          	or	a4,a5,a4
    6808:	00d518b3          	sll	a7,a0,a3
    680c:	01085593          	srli	a1,a6,0x10
    6810:	02b75633          	divu	a2,a4,a1
    6814:	01081313          	slli	t1,a6,0x10
    6818:	01035313          	srli	t1,t1,0x10
    681c:	0108d793          	srli	a5,a7,0x10
    6820:	02b77733          	remu	a4,a4,a1
    6824:	02660633          	mul	a2,a2,t1
    6828:	01071713          	slli	a4,a4,0x10
    682c:	00e7e7b3          	or	a5,a5,a4
    6830:	00c7f863          	bgeu	a5,a2,6840 <__umoddi3+0xa0>
    6834:	00f807b3          	add	a5,a6,a5
    6838:	0107e463          	bltu	a5,a6,6840 <__umoddi3+0xa0>
    683c:	3cc7e463          	bltu	a5,a2,6c04 <__umoddi3+0x464>
    6840:	40c787b3          	sub	a5,a5,a2
    6844:	02b7d733          	divu	a4,a5,a1
    6848:	01089513          	slli	a0,a7,0x10
    684c:	01055513          	srli	a0,a0,0x10
    6850:	02b7f7b3          	remu	a5,a5,a1
    6854:	02670733          	mul	a4,a4,t1
    6858:	01079793          	slli	a5,a5,0x10
    685c:	00f56533          	or	a0,a0,a5
    6860:	00e57a63          	bgeu	a0,a4,6874 <__umoddi3+0xd4>
    6864:	00a80533          	add	a0,a6,a0
    6868:	01056663          	bltu	a0,a6,6874 <__umoddi3+0xd4>
    686c:	00e57463          	bgeu	a0,a4,6874 <__umoddi3+0xd4>
    6870:	01050533          	add	a0,a0,a6
    6874:	40e50533          	sub	a0,a0,a4
    6878:	00d55533          	srl	a0,a0,a3
    687c:	00000593          	li	a1,0
    6880:	00008067          	ret
    6884:	00d5f463          	bgeu	a1,a3,688c <__umoddi3+0xec>
    6888:	00008067          	ret
    688c:	000107b7          	lui	a5,0x10
    6890:	1cf6e863          	bltu	a3,a5,6a60 <__umoddi3+0x2c0>
    6894:	010007b7          	lui	a5,0x1000
    6898:	00f6b7b3          	sltu	a5,a3,a5
    689c:	40f007b3          	neg	a5,a5
    68a0:	ff87f793          	andi	a5,a5,-8
    68a4:	01878793          	addi	a5,a5,24 # 1000018 <_stack_top+0xfda818>
    68a8:	00f6d833          	srl	a6,a3,a5
    68ac:	00006717          	auipc	a4,0x6
    68b0:	77470713          	addi	a4,a4,1908 # d020 <__clz_tab>
    68b4:	01070733          	add	a4,a4,a6
    68b8:	00074703          	lbu	a4,0(a4)
    68bc:	02000e13          	li	t3,32
    68c0:	00f70733          	add	a4,a4,a5
    68c4:	40ee0833          	sub	a6,t3,a4
    68c8:	1cee1463          	bne	t3,a4,6a90 <__umoddi3+0x2f0>
    68cc:	00b6e463          	bltu	a3,a1,68d4 <__umoddi3+0x134>
    68d0:	00c56a63          	bltu	a0,a2,68e4 <__umoddi3+0x144>
    68d4:	40c508b3          	sub	a7,a0,a2
    68d8:	40d586b3          	sub	a3,a1,a3
    68dc:	01153333          	sltu	t1,a0,a7
    68e0:	40668333          	sub	t1,a3,t1
    68e4:	00088513          	mv	a0,a7
    68e8:	00030593          	mv	a1,t1
    68ec:	00008067          	ret
    68f0:	0a060e63          	beqz	a2,69ac <__umoddi3+0x20c>
    68f4:	000107b7          	lui	a5,0x10
    68f8:	2ef67463          	bgeu	a2,a5,6be0 <__umoddi3+0x440>
    68fc:	10063713          	sltiu	a4,a2,256
    6900:	00174713          	xori	a4,a4,1
    6904:	00371713          	slli	a4,a4,0x3
    6908:	00e656b3          	srl	a3,a2,a4
    690c:	00006797          	auipc	a5,0x6
    6910:	71478793          	addi	a5,a5,1812 # d020 <__clz_tab>
    6914:	00d787b3          	add	a5,a5,a3
    6918:	0007c783          	lbu	a5,0(a5)
    691c:	02000313          	li	t1,32
    6920:	00e787b3          	add	a5,a5,a4
    6924:	40f306b3          	sub	a3,t1,a5
    6928:	0af31663          	bne	t1,a5,69d4 <__umoddi3+0x234>
    692c:	40c58733          	sub	a4,a1,a2
    6930:	01065313          	srli	t1,a2,0x10
    6934:	01061613          	slli	a2,a2,0x10
    6938:	01065613          	srli	a2,a2,0x10
    693c:	026755b3          	divu	a1,a4,t1
    6940:	0108d793          	srli	a5,a7,0x10
    6944:	02677733          	remu	a4,a4,t1
    6948:	02c585b3          	mul	a1,a1,a2
    694c:	01071713          	slli	a4,a4,0x10
    6950:	00e7e7b3          	or	a5,a5,a4
    6954:	00b7fa63          	bgeu	a5,a1,6968 <__umoddi3+0x1c8>
    6958:	00f807b3          	add	a5,a6,a5
    695c:	0107e663          	bltu	a5,a6,6968 <__umoddi3+0x1c8>
    6960:	00b7f463          	bgeu	a5,a1,6968 <__umoddi3+0x1c8>
    6964:	010787b3          	add	a5,a5,a6
    6968:	40b787b3          	sub	a5,a5,a1
    696c:	0267d733          	divu	a4,a5,t1
    6970:	01089893          	slli	a7,a7,0x10
    6974:	0108d893          	srli	a7,a7,0x10
    6978:	0267f7b3          	remu	a5,a5,t1
    697c:	02c70733          	mul	a4,a4,a2
    6980:	01079513          	slli	a0,a5,0x10
    6984:	00a8e533          	or	a0,a7,a0
    6988:	ece56ee3          	bltu	a0,a4,6864 <__umoddi3+0xc4>
    698c:	40e50533          	sub	a0,a0,a4
    6990:	00d55533          	srl	a0,a0,a3
    6994:	00000593          	li	a1,0
    6998:	00008067          	ret
    699c:	10063793          	sltiu	a5,a2,256
    69a0:	0017c793          	xori	a5,a5,1
    69a4:	00379793          	slli	a5,a5,0x3
    69a8:	e2dff06f          	j	67d4 <__umoddi3+0x34>
    69ac:	00000693          	li	a3,0
    69b0:	00006797          	auipc	a5,0x6
    69b4:	67078793          	addi	a5,a5,1648 # d020 <__clz_tab>
    69b8:	00d787b3          	add	a5,a5,a3
    69bc:	0007c783          	lbu	a5,0(a5)
    69c0:	00000713          	li	a4,0
    69c4:	02000313          	li	t1,32
    69c8:	00e787b3          	add	a5,a5,a4
    69cc:	40f306b3          	sub	a3,t1,a5
    69d0:	f4f30ee3          	beq	t1,a5,692c <__umoddi3+0x18c>
    69d4:	00d61833          	sll	a6,a2,a3
    69d8:	00f5de33          	srl	t3,a1,a5
    69dc:	01085313          	srli	t1,a6,0x10
    69e0:	026e5eb3          	divu	t4,t3,t1
    69e4:	01081613          	slli	a2,a6,0x10
    69e8:	00d595b3          	sll	a1,a1,a3
    69ec:	00f55733          	srl	a4,a0,a5
    69f0:	01065613          	srli	a2,a2,0x10
    69f4:	00b76733          	or	a4,a4,a1
    69f8:	01075793          	srli	a5,a4,0x10
    69fc:	00d518b3          	sll	a7,a0,a3
    6a00:	026e7e33          	remu	t3,t3,t1
    6a04:	02ce85b3          	mul	a1,t4,a2
    6a08:	010e1e13          	slli	t3,t3,0x10
    6a0c:	01c7e7b3          	or	a5,a5,t3
    6a10:	00b7fa63          	bgeu	a5,a1,6a24 <__umoddi3+0x284>
    6a14:	00f807b3          	add	a5,a6,a5
    6a18:	0107e663          	bltu	a5,a6,6a24 <__umoddi3+0x284>
    6a1c:	00b7f463          	bgeu	a5,a1,6a24 <__umoddi3+0x284>
    6a20:	010787b3          	add	a5,a5,a6
    6a24:	40b787b3          	sub	a5,a5,a1
    6a28:	0267d5b3          	divu	a1,a5,t1
    6a2c:	01071713          	slli	a4,a4,0x10
    6a30:	01075713          	srli	a4,a4,0x10
    6a34:	0267f7b3          	remu	a5,a5,t1
    6a38:	02c585b3          	mul	a1,a1,a2
    6a3c:	01079793          	slli	a5,a5,0x10
    6a40:	00f76733          	or	a4,a4,a5
    6a44:	00b77a63          	bgeu	a4,a1,6a58 <__umoddi3+0x2b8>
    6a48:	00e80733          	add	a4,a6,a4
    6a4c:	01076663          	bltu	a4,a6,6a58 <__umoddi3+0x2b8>
    6a50:	00b77463          	bgeu	a4,a1,6a58 <__umoddi3+0x2b8>
    6a54:	01070733          	add	a4,a4,a6
    6a58:	40b70733          	sub	a4,a4,a1
    6a5c:	ee1ff06f          	j	693c <__umoddi3+0x19c>
    6a60:	1006b793          	sltiu	a5,a3,256
    6a64:	0017c793          	xori	a5,a5,1
    6a68:	00379793          	slli	a5,a5,0x3
    6a6c:	00f6d833          	srl	a6,a3,a5
    6a70:	00006717          	auipc	a4,0x6
    6a74:	5b070713          	addi	a4,a4,1456 # d020 <__clz_tab>
    6a78:	01070733          	add	a4,a4,a6
    6a7c:	00074703          	lbu	a4,0(a4)
    6a80:	02000e13          	li	t3,32
    6a84:	00f70733          	add	a4,a4,a5
    6a88:	40ee0833          	sub	a6,t3,a4
    6a8c:	e4ee00e3          	beq	t3,a4,68cc <__umoddi3+0x12c>
    6a90:	010696b3          	sll	a3,a3,a6
    6a94:	00e658b3          	srl	a7,a2,a4
    6a98:	00d8e8b3          	or	a7,a7,a3
    6a9c:	00e5de33          	srl	t3,a1,a4
    6aa0:	0108df13          	srli	t5,a7,0x10
    6aa4:	03ee57b3          	divu	a5,t3,t5
    6aa8:	01089e93          	slli	t4,a7,0x10
    6aac:	010ede93          	srli	t4,t4,0x10
    6ab0:	00e556b3          	srl	a3,a0,a4
    6ab4:	01051333          	sll	t1,a0,a6
    6ab8:	010595b3          	sll	a1,a1,a6
    6abc:	00b6e5b3          	or	a1,a3,a1
    6ac0:	0105d693          	srli	a3,a1,0x10
    6ac4:	01061633          	sll	a2,a2,a6
    6ac8:	03ee7e33          	remu	t3,t3,t5
    6acc:	02fe8533          	mul	a0,t4,a5
    6ad0:	010e1e13          	slli	t3,t3,0x10
    6ad4:	01c6e6b3          	or	a3,a3,t3
    6ad8:	00a6fe63          	bgeu	a3,a0,6af4 <__umoddi3+0x354>
    6adc:	00d886b3          	add	a3,a7,a3
    6ae0:	fff78e13          	addi	t3,a5,-1
    6ae4:	1116ec63          	bltu	a3,a7,6bfc <__umoddi3+0x45c>
    6ae8:	10a6fa63          	bgeu	a3,a0,6bfc <__umoddi3+0x45c>
    6aec:	ffe78793          	addi	a5,a5,-2
    6af0:	011686b3          	add	a3,a3,a7
    6af4:	40a686b3          	sub	a3,a3,a0
    6af8:	03e6d533          	divu	a0,a3,t5
    6afc:	01059593          	slli	a1,a1,0x10
    6b00:	0105d593          	srli	a1,a1,0x10
    6b04:	03e6f6b3          	remu	a3,a3,t5
    6b08:	02ae8eb3          	mul	t4,t4,a0
    6b0c:	01069693          	slli	a3,a3,0x10
    6b10:	00d5e5b3          	or	a1,a1,a3
    6b14:	01d5fe63          	bgeu	a1,t4,6b30 <__umoddi3+0x390>
    6b18:	00b885b3          	add	a1,a7,a1
    6b1c:	fff50693          	addi	a3,a0,-1
    6b20:	0d15ea63          	bltu	a1,a7,6bf4 <__umoddi3+0x454>
    6b24:	0dd5f863          	bgeu	a1,t4,6bf4 <__umoddi3+0x454>
    6b28:	ffe50513          	addi	a0,a0,-2
    6b2c:	011585b3          	add	a1,a1,a7
    6b30:	01079693          	slli	a3,a5,0x10
    6b34:	000102b7          	lui	t0,0x10
    6b38:	00a6e6b3          	or	a3,a3,a0
    6b3c:	fff28513          	addi	a0,t0,-1 # ffff <seed1_volatile+0x265f>
    6b40:	00a6fe33          	and	t3,a3,a0
    6b44:	01065f93          	srli	t6,a2,0x10
    6b48:	0106d693          	srli	a3,a3,0x10
    6b4c:	00a67533          	and	a0,a2,a0
    6b50:	02ae0f33          	mul	t5,t3,a0
    6b54:	41d585b3          	sub	a1,a1,t4
    6b58:	02a68533          	mul	a0,a3,a0
    6b5c:	010f5793          	srli	a5,t5,0x10
    6b60:	03fe0e33          	mul	t3,t3,t6
    6b64:	00ae0e33          	add	t3,t3,a0
    6b68:	01c787b3          	add	a5,a5,t3
    6b6c:	03f686b3          	mul	a3,a3,t6
    6b70:	00a7f463          	bgeu	a5,a0,6b78 <__umoddi3+0x3d8>
    6b74:	005686b3          	add	a3,a3,t0
    6b78:	00010eb7          	lui	t4,0x10
    6b7c:	fffe8e93          	addi	t4,t4,-1 # ffff <seed1_volatile+0x265f>
    6b80:	01d7f533          	and	a0,a5,t4
    6b84:	0107de13          	srli	t3,a5,0x10
    6b88:	01051513          	slli	a0,a0,0x10
    6b8c:	01df7f33          	and	t5,t5,t4
    6b90:	00de07b3          	add	a5,t3,a3
    6b94:	01e50533          	add	a0,a0,t5
    6b98:	02f5e863          	bltu	a1,a5,6bc8 <__umoddi3+0x428>
    6b9c:	02f58463          	beq	a1,a5,6bc4 <__umoddi3+0x424>
    6ba0:	40a30533          	sub	a0,t1,a0
    6ba4:	00a33333          	sltu	t1,t1,a0
    6ba8:	40f585b3          	sub	a1,a1,a5
    6bac:	406585b3          	sub	a1,a1,t1
    6bb0:	00e59733          	sll	a4,a1,a4
    6bb4:	01055533          	srl	a0,a0,a6
    6bb8:	00a76533          	or	a0,a4,a0
    6bbc:	0105d5b3          	srl	a1,a1,a6
    6bc0:	00008067          	ret
    6bc4:	fca37ee3          	bgeu	t1,a0,6ba0 <__umoddi3+0x400>
    6bc8:	40c50633          	sub	a2,a0,a2
    6bcc:	00c53533          	sltu	a0,a0,a2
    6bd0:	011508b3          	add	a7,a0,a7
    6bd4:	411787b3          	sub	a5,a5,a7
    6bd8:	00060513          	mv	a0,a2
    6bdc:	fc5ff06f          	j	6ba0 <__umoddi3+0x400>
    6be0:	010007b7          	lui	a5,0x1000
    6be4:	02f67463          	bgeu	a2,a5,6c0c <__umoddi3+0x46c>
    6be8:	01065693          	srli	a3,a2,0x10
    6bec:	01000713          	li	a4,16
    6bf0:	d1dff06f          	j	690c <__umoddi3+0x16c>
    6bf4:	00068513          	mv	a0,a3
    6bf8:	f39ff06f          	j	6b30 <__umoddi3+0x390>
    6bfc:	000e0793          	mv	a5,t3
    6c00:	ef5ff06f          	j	6af4 <__umoddi3+0x354>
    6c04:	010787b3          	add	a5,a5,a6
    6c08:	c39ff06f          	j	6840 <__umoddi3+0xa0>
    6c0c:	01865693          	srli	a3,a2,0x18
    6c10:	01800713          	li	a4,24
    6c14:	cf9ff06f          	j	690c <__umoddi3+0x16c>

00006c18 <__muldf3>:
    6c18:	fc010113          	addi	sp,sp,-64
    6c1c:	0145d793          	srli	a5,a1,0x14
    6c20:	02812c23          	sw	s0,56(sp)
    6c24:	02912a23          	sw	s1,52(sp)
    6c28:	03312623          	sw	s3,44(sp)
    6c2c:	01812c23          	sw	s8,24(sp)
    6c30:	00c59493          	slli	s1,a1,0xc
    6c34:	02112e23          	sw	ra,60(sp)
    6c38:	03212823          	sw	s2,48(sp)
    6c3c:	03412423          	sw	s4,40(sp)
    6c40:	03512223          	sw	s5,36(sp)
    6c44:	03612023          	sw	s6,32(sp)
    6c48:	01712e23          	sw	s7,28(sp)
    6c4c:	7ff7f793          	andi	a5,a5,2047
    6c50:	00050413          	mv	s0,a0
    6c54:	00060c13          	mv	s8,a2
    6c58:	00c4d493          	srli	s1,s1,0xc
    6c5c:	01f5d993          	srli	s3,a1,0x1f
    6c60:	1e078663          	beqz	a5,6e4c <__muldf3+0x234>
    6c64:	7ff00813          	li	a6,2047
    6c68:	23078c63          	beq	a5,a6,6ea0 <__muldf3+0x288>
    6c6c:	00349493          	slli	s1,s1,0x3
    6c70:	01d55593          	srli	a1,a0,0x1d
    6c74:	0095e5b3          	or	a1,a1,s1
    6c78:	008004b7          	lui	s1,0x800
    6c7c:	0095e4b3          	or	s1,a1,s1
    6c80:	00351a13          	slli	s4,a0,0x3
    6c84:	c0178b93          	addi	s7,a5,-1023 # fffc01 <_stack_top+0xfda401>
    6c88:	00000b13          	li	s6,0
    6c8c:	00000a93          	li	s5,0
    6c90:	0146d793          	srli	a5,a3,0x14
    6c94:	00c69813          	slli	a6,a3,0xc
    6c98:	7ff7f793          	andi	a5,a5,2047
    6c9c:	000c0e93          	mv	t4,s8
    6ca0:	00c85413          	srli	s0,a6,0xc
    6ca4:	01f6d913          	srli	s2,a3,0x1f
    6ca8:	14078863          	beqz	a5,6df8 <__muldf3+0x1e0>
    6cac:	7ff00813          	li	a6,2047
    6cb0:	0b078a63          	beq	a5,a6,6d64 <__muldf3+0x14c>
    6cb4:	00341693          	slli	a3,s0,0x3
    6cb8:	c0178793          	addi	a5,a5,-1023
    6cbc:	01dc5593          	srli	a1,s8,0x1d
    6cc0:	00d5e5b3          	or	a1,a1,a3
    6cc4:	01778e33          	add	t3,a5,s7
    6cc8:	008006b7          	lui	a3,0x800
    6ccc:	00a00793          	li	a5,10
    6cd0:	00d5e433          	or	s0,a1,a3
    6cd4:	003c1e93          	slli	t4,s8,0x3
    6cd8:	00000513          	li	a0,0
    6cdc:	001e0313          	addi	t1,t3,1
    6ce0:	2367c663          	blt	a5,s6,6f0c <__muldf3+0x2f4>
    6ce4:	0129c833          	xor	a6,s3,s2
    6ce8:	00080693          	mv	a3,a6
    6cec:	00200613          	li	a2,2
    6cf0:	0b664263          	blt	a2,s6,6d94 <__muldf3+0x17c>
    6cf4:	fffb0893          	addi	a7,s6,-1
    6cf8:	00100593          	li	a1,1
    6cfc:	2715ec63          	bltu	a1,a7,6f74 <__muldf3+0x35c>
    6d00:	1ac50e63          	beq	a0,a2,6ebc <__muldf3+0x2a4>
    6d04:	00100793          	li	a5,1
    6d08:	00068813          	mv	a6,a3
    6d0c:	0cf51063          	bne	a0,a5,6dcc <__muldf3+0x1b4>
    6d10:	00000793          	li	a5,0
    6d14:	00000693          	li	a3,0
    6d18:	00000713          	li	a4,0
    6d1c:	03c12083          	lw	ra,60(sp)
    6d20:	03812403          	lw	s0,56(sp)
    6d24:	01479793          	slli	a5,a5,0x14
    6d28:	00d7e7b3          	or	a5,a5,a3
    6d2c:	01f81813          	slli	a6,a6,0x1f
    6d30:	0107e7b3          	or	a5,a5,a6
    6d34:	03412483          	lw	s1,52(sp)
    6d38:	03012903          	lw	s2,48(sp)
    6d3c:	02c12983          	lw	s3,44(sp)
    6d40:	02812a03          	lw	s4,40(sp)
    6d44:	02412a83          	lw	s5,36(sp)
    6d48:	02012b03          	lw	s6,32(sp)
    6d4c:	01c12b83          	lw	s7,28(sp)
    6d50:	01812c03          	lw	s8,24(sp)
    6d54:	00070513          	mv	a0,a4
    6d58:	00078593          	mv	a1,a5
    6d5c:	04010113          	addi	sp,sp,64
    6d60:	00008067          	ret
    6d64:	01846733          	or	a4,s0,s8
    6d68:	7ffb8e13          	addi	t3,s7,2047
    6d6c:	16070a63          	beqz	a4,6ee0 <__muldf3+0x2c8>
    6d70:	00001737          	lui	a4,0x1
    6d74:	0129c833          	xor	a6,s3,s2
    6d78:	80070713          	addi	a4,a4,-2048 # 800 <vprintfmt.constprop.0+0x434>
    6d7c:	003b6b13          	ori	s6,s6,3
    6d80:	00a00613          	li	a2,10
    6d84:	00080693          	mv	a3,a6
    6d88:	00eb8333          	add	t1,s7,a4
    6d8c:	59664463          	blt	a2,s6,7314 <__muldf3+0x6fc>
    6d90:	00300513          	li	a0,3
    6d94:	00100613          	li	a2,1
    6d98:	01661633          	sll	a2,a2,s6
    6d9c:	53067713          	andi	a4,a2,1328
    6da0:	02070a63          	beqz	a4,6dd4 <__muldf3+0x1bc>
    6da4:	00200793          	li	a5,2
    6da8:	10fa8a63          	beq	s5,a5,6ebc <__muldf3+0x2a4>
    6dac:	00300793          	li	a5,3
    6db0:	1afa8863          	beq	s5,a5,6f60 <__muldf3+0x348>
    6db4:	000a8513          	mv	a0,s5
    6db8:	00100793          	li	a5,1
    6dbc:	00048413          	mv	s0,s1
    6dc0:	000a0e93          	mv	t4,s4
    6dc4:	00068813          	mv	a6,a3
    6dc8:	f4f504e3          	beq	a0,a5,6d10 <__muldf3+0xf8>
    6dcc:	00030e13          	mv	t3,t1
    6dd0:	36c0006f          	j	713c <__muldf3+0x524>
    6dd4:	24067793          	andi	a5,a2,576
    6dd8:	0e079c63          	bnez	a5,6ed0 <__muldf3+0x2b8>
    6ddc:	08867613          	andi	a2,a2,136
    6de0:	18060a63          	beqz	a2,6f74 <__muldf3+0x35c>
    6de4:	00090693          	mv	a3,s2
    6de8:	00040493          	mv	s1,s0
    6dec:	000e8a13          	mv	s4,t4
    6df0:	00050a93          	mv	s5,a0
    6df4:	fb1ff06f          	j	6da4 <__muldf3+0x18c>
    6df8:	018467b3          	or	a5,s0,s8
    6dfc:	14078063          	beqz	a5,6f3c <__muldf3+0x324>
    6e00:	42040c63          	beqz	s0,7238 <__muldf3+0x620>
    6e04:	00040513          	mv	a0,s0
    6e08:	23d010ef          	jal	ra,8844 <__clzsi2>
    6e0c:	00050e13          	mv	t3,a0
    6e10:	ff550713          	addi	a4,a0,-11
    6e14:	01d00793          	li	a5,29
    6e18:	ff8e0e93          	addi	t4,t3,-8
    6e1c:	40e787b3          	sub	a5,a5,a4
    6e20:	01d416b3          	sll	a3,s0,t4
    6e24:	00fc57b3          	srl	a5,s8,a5
    6e28:	00d7e433          	or	s0,a5,a3
    6e2c:	01dc1eb3          	sll	t4,s8,t4
    6e30:	41cb8e33          	sub	t3,s7,t3
    6e34:	c0de0e13          	addi	t3,t3,-1011
    6e38:	00a00793          	li	a5,10
    6e3c:	00000513          	li	a0,0
    6e40:	001e0313          	addi	t1,t3,1
    6e44:	eb67d0e3          	bge	a5,s6,6ce4 <__muldf3+0xcc>
    6e48:	0c40006f          	j	6f0c <__muldf3+0x2f4>
    6e4c:	00a4ea33          	or	s4,s1,a0
    6e50:	0c0a0c63          	beqz	s4,6f28 <__muldf3+0x310>
    6e54:	00d12623          	sw	a3,12(sp)
    6e58:	3a048c63          	beqz	s1,7210 <__muldf3+0x5f8>
    6e5c:	00048513          	mv	a0,s1
    6e60:	1e5010ef          	jal	ra,8844 <__clzsi2>
    6e64:	00c12683          	lw	a3,12(sp)
    6e68:	00050713          	mv	a4,a0
    6e6c:	ff550613          	addi	a2,a0,-11
    6e70:	01d00793          	li	a5,29
    6e74:	ff870a13          	addi	s4,a4,-8
    6e78:	40c787b3          	sub	a5,a5,a2
    6e7c:	014494b3          	sll	s1,s1,s4
    6e80:	00f457b3          	srl	a5,s0,a5
    6e84:	0097e4b3          	or	s1,a5,s1
    6e88:	01441a33          	sll	s4,s0,s4
    6e8c:	c0d00793          	li	a5,-1011
    6e90:	40e78bb3          	sub	s7,a5,a4
    6e94:	00000b13          	li	s6,0
    6e98:	00000a93          	li	s5,0
    6e9c:	df5ff06f          	j	6c90 <__muldf3+0x78>
    6ea0:	00a4ea33          	or	s4,s1,a0
    6ea4:	060a1863          	bnez	s4,6f14 <__muldf3+0x2fc>
    6ea8:	00000493          	li	s1,0
    6eac:	00800b13          	li	s6,8
    6eb0:	7ff00b93          	li	s7,2047
    6eb4:	00200a93          	li	s5,2
    6eb8:	dd9ff06f          	j	6c90 <__muldf3+0x78>
    6ebc:	00068813          	mv	a6,a3
    6ec0:	7ff00793          	li	a5,2047
    6ec4:	00000693          	li	a3,0
    6ec8:	00000713          	li	a4,0
    6ecc:	e51ff06f          	j	6d1c <__muldf3+0x104>
    6ed0:	00000813          	li	a6,0
    6ed4:	7ff00793          	li	a5,2047
    6ed8:	000806b7          	lui	a3,0x80
    6edc:	e41ff06f          	j	6d1c <__muldf3+0x104>
    6ee0:	000017b7          	lui	a5,0x1
    6ee4:	80078793          	addi	a5,a5,-2048 # 800 <vprintfmt.constprop.0+0x434>
    6ee8:	002b6b13          	ori	s6,s6,2
    6eec:	00a00693          	li	a3,10
    6ef0:	00fb8333          	add	t1,s7,a5
    6ef4:	3766de63          	bge	a3,s6,7270 <__muldf3+0x658>
    6ef8:	00000e93          	li	t4,0
    6efc:	00e00793          	li	a5,14
    6f00:	00200513          	li	a0,2
    6f04:	00b00693          	li	a3,11
    6f08:	40d78263          	beq	a5,a3,730c <__muldf3+0x6f4>
    6f0c:	00098693          	mv	a3,s3
    6f10:	e95ff06f          	j	6da4 <__muldf3+0x18c>
    6f14:	00050a13          	mv	s4,a0
    6f18:	00c00b13          	li	s6,12
    6f1c:	7ff00b93          	li	s7,2047
    6f20:	00300a93          	li	s5,3
    6f24:	d6dff06f          	j	6c90 <__muldf3+0x78>
    6f28:	00000493          	li	s1,0
    6f2c:	00400b13          	li	s6,4
    6f30:	00000b93          	li	s7,0
    6f34:	00100a93          	li	s5,1
    6f38:	d59ff06f          	j	6c90 <__muldf3+0x78>
    6f3c:	000b8e13          	mv	t3,s7
    6f40:	001b6b13          	ori	s6,s6,1
    6f44:	00a00793          	li	a5,10
    6f48:	00000413          	li	s0,0
    6f4c:	00000e93          	li	t4,0
    6f50:	00100513          	li	a0,1
    6f54:	001e0313          	addi	t1,t3,1
    6f58:	d967d6e3          	bge	a5,s6,6ce4 <__muldf3+0xcc>
    6f5c:	fb1ff06f          	j	6f0c <__muldf3+0x2f4>
    6f60:	00000813          	li	a6,0
    6f64:	7ff00793          	li	a5,2047
    6f68:	000806b7          	lui	a3,0x80
    6f6c:	00000713          	li	a4,0
    6f70:	dadff06f          	j	6d1c <__muldf3+0x104>
    6f74:	000105b7          	lui	a1,0x10
    6f78:	fff58713          	addi	a4,a1,-1 # ffff <seed1_volatile+0x265f>
    6f7c:	010a5793          	srli	a5,s4,0x10
    6f80:	010ed893          	srli	a7,t4,0x10
    6f84:	00ea7a33          	and	s4,s4,a4
    6f88:	00eefeb3          	and	t4,t4,a4
    6f8c:	03da0733          	mul	a4,s4,t4
    6f90:	03d78633          	mul	a2,a5,t4
    6f94:	01075513          	srli	a0,a4,0x10
    6f98:	034886b3          	mul	a3,a7,s4
    6f9c:	00c686b3          	add	a3,a3,a2
    6fa0:	00d50533          	add	a0,a0,a3
    6fa4:	03178f33          	mul	t5,a5,a7
    6fa8:	00c57463          	bgeu	a0,a2,6fb0 <__muldf3+0x398>
    6fac:	00bf0f33          	add	t5,t5,a1
    6fb0:	000103b7          	lui	t2,0x10
    6fb4:	fff38613          	addi	a2,t2,-1 # ffff <seed1_volatile+0x265f>
    6fb8:	00c575b3          	and	a1,a0,a2
    6fbc:	00c476b3          	and	a3,s0,a2
    6fc0:	00c77733          	and	a4,a4,a2
    6fc4:	01045f93          	srli	t6,s0,0x10
    6fc8:	01059593          	slli	a1,a1,0x10
    6fcc:	02da02b3          	mul	t0,s4,a3
    6fd0:	00e585b3          	add	a1,a1,a4
    6fd4:	01055513          	srli	a0,a0,0x10
    6fd8:	02d78733          	mul	a4,a5,a3
    6fdc:	0102d613          	srli	a2,t0,0x10
    6fe0:	034f8a33          	mul	s4,t6,s4
    6fe4:	00ea0a33          	add	s4,s4,a4
    6fe8:	01460633          	add	a2,a2,s4
    6fec:	03f787b3          	mul	a5,a5,t6
    6ff0:	00e67463          	bgeu	a2,a4,6ff8 <__muldf3+0x3e0>
    6ff4:	007787b3          	add	a5,a5,t2
    6ff8:	00010937          	lui	s2,0x10
    6ffc:	fff90413          	addi	s0,s2,-1 # ffff <seed1_volatile+0x265f>
    7000:	00867733          	and	a4,a2,s0
    7004:	0104d393          	srli	t2,s1,0x10
    7008:	0082f2b3          	and	t0,t0,s0
    700c:	0084f4b3          	and	s1,s1,s0
    7010:	01071713          	slli	a4,a4,0x10
    7014:	029e8433          	mul	s0,t4,s1
    7018:	00570733          	add	a4,a4,t0
    701c:	01065613          	srli	a2,a2,0x10
    7020:	00f60633          	add	a2,a2,a5
    7024:	00e50533          	add	a0,a0,a4
    7028:	029882b3          	mul	t0,a7,s1
    702c:	01045793          	srli	a5,s0,0x10
    7030:	03d38eb3          	mul	t4,t2,t4
    7034:	01d282b3          	add	t0,t0,t4
    7038:	005787b3          	add	a5,a5,t0
    703c:	027888b3          	mul	a7,a7,t2
    7040:	01d7f463          	bgeu	a5,t4,7048 <__muldf3+0x430>
    7044:	012888b3          	add	a7,a7,s2
    7048:	00010937          	lui	s2,0x10
    704c:	fff90e93          	addi	t4,s2,-1 # ffff <seed1_volatile+0x265f>
    7050:	01d7f2b3          	and	t0,a5,t4
    7054:	01d47eb3          	and	t4,s0,t4
    7058:	01029293          	slli	t0,t0,0x10
    705c:	0107d793          	srli	a5,a5,0x10
    7060:	011787b3          	add	a5,a5,a7
    7064:	02968433          	mul	s0,a3,s1
    7068:	01d288b3          	add	a7,t0,t4
    706c:	02d386b3          	mul	a3,t2,a3
    7070:	01045293          	srli	t0,s0,0x10
    7074:	029f84b3          	mul	s1,t6,s1
    7078:	00d484b3          	add	s1,s1,a3
    707c:	009282b3          	add	t0,t0,s1
    7080:	027f8eb3          	mul	t4,t6,t2
    7084:	00d2f463          	bgeu	t0,a3,708c <__muldf3+0x474>
    7088:	012e8eb3          	add	t4,t4,s2
    708c:	00010fb7          	lui	t6,0x10
    7090:	ffff8f93          	addi	t6,t6,-1 # ffff <seed1_volatile+0x265f>
    7094:	01f2f6b3          	and	a3,t0,t6
    7098:	01f47433          	and	s0,s0,t6
    709c:	01069693          	slli	a3,a3,0x10
    70a0:	01e50533          	add	a0,a0,t5
    70a4:	008686b3          	add	a3,a3,s0
    70a8:	00c68633          	add	a2,a3,a2
    70ac:	00e53733          	sltu	a4,a0,a4
    70b0:	00e60733          	add	a4,a2,a4
    70b4:	011508b3          	add	a7,a0,a7
    70b8:	00f707b3          	add	a5,a4,a5
    70bc:	00a8b533          	sltu	a0,a7,a0
    70c0:	00a78533          	add	a0,a5,a0
    70c4:	00d636b3          	sltu	a3,a2,a3
    70c8:	00c73633          	sltu	a2,a4,a2
    70cc:	00c6e6b3          	or	a3,a3,a2
    70d0:	00e7b733          	sltu	a4,a5,a4
    70d4:	0102d613          	srli	a2,t0,0x10
    70d8:	00f537b3          	sltu	a5,a0,a5
    70dc:	00f76733          	or	a4,a4,a5
    70e0:	00c686b3          	add	a3,a3,a2
    70e4:	00d70733          	add	a4,a4,a3
    70e8:	01d70733          	add	a4,a4,t4
    70ec:	00989e93          	slli	t4,a7,0x9
    70f0:	01755793          	srli	a5,a0,0x17
    70f4:	00971713          	slli	a4,a4,0x9
    70f8:	00beeeb3          	or	t4,t4,a1
    70fc:	00f76433          	or	s0,a4,a5
    7100:	01d03eb3          	snez	t4,t4
    7104:	0178d793          	srli	a5,a7,0x17
    7108:	00feeeb3          	or	t4,t4,a5
    710c:	010007b7          	lui	a5,0x1000
    7110:	00951513          	slli	a0,a0,0x9
    7114:	00f477b3          	and	a5,s0,a5
    7118:	00aeeeb3          	or	t4,t4,a0
    711c:	02078063          	beqz	a5,713c <__muldf3+0x524>
    7120:	001ed793          	srli	a5,t4,0x1
    7124:	001efe93          	andi	t4,t4,1
    7128:	01f41713          	slli	a4,s0,0x1f
    712c:	01d7e7b3          	or	a5,a5,t4
    7130:	00e7eeb3          	or	t4,a5,a4
    7134:	00145413          	srli	s0,s0,0x1
    7138:	00030e13          	mv	t3,t1
    713c:	3ffe0793          	addi	a5,t3,1023
    7140:	06f05463          	blez	a5,71a8 <__muldf3+0x590>
    7144:	007ef713          	andi	a4,t4,7
    7148:	02070063          	beqz	a4,7168 <__muldf3+0x550>
    714c:	00fef713          	andi	a4,t4,15
    7150:	00400693          	li	a3,4
    7154:	00d70a63          	beq	a4,a3,7168 <__muldf3+0x550>
    7158:	004e8713          	addi	a4,t4,4
    715c:	01d73eb3          	sltu	t4,a4,t4
    7160:	01d40433          	add	s0,s0,t4
    7164:	00070e93          	mv	t4,a4
    7168:	01000737          	lui	a4,0x1000
    716c:	00e47733          	and	a4,s0,a4
    7170:	00070a63          	beqz	a4,7184 <__muldf3+0x56c>
    7174:	ff0007b7          	lui	a5,0xff000
    7178:	fff78793          	addi	a5,a5,-1 # feffffff <_stack_top+0xfefda7ff>
    717c:	00f47433          	and	s0,s0,a5
    7180:	400e0793          	addi	a5,t3,1024
    7184:	7fe00713          	li	a4,2046
    7188:	0cf74c63          	blt	a4,a5,7260 <__muldf3+0x648>
    718c:	003ede93          	srli	t4,t4,0x3
    7190:	01d41713          	slli	a4,s0,0x1d
    7194:	00941693          	slli	a3,s0,0x9
    7198:	01d76733          	or	a4,a4,t4
    719c:	00c6d693          	srli	a3,a3,0xc
    71a0:	7ff7f793          	andi	a5,a5,2047
    71a4:	b79ff06f          	j	6d1c <__muldf3+0x104>
    71a8:	00100713          	li	a4,1
    71ac:	0c079e63          	bnez	a5,7288 <__muldf3+0x670>
    71b0:	41ee0e13          	addi	t3,t3,1054
    71b4:	01ce9633          	sll	a2,t4,t3
    71b8:	00c03633          	snez	a2,a2
    71bc:	01c41e33          	sll	t3,s0,t3
    71c0:	00eedeb3          	srl	t4,t4,a4
    71c4:	01c66633          	or	a2,a2,t3
    71c8:	01d66633          	or	a2,a2,t4
    71cc:	00767793          	andi	a5,a2,7
    71d0:	00e455b3          	srl	a1,s0,a4
    71d4:	02078063          	beqz	a5,71f4 <__muldf3+0x5dc>
    71d8:	00f67793          	andi	a5,a2,15
    71dc:	00400713          	li	a4,4
    71e0:	00e78a63          	beq	a5,a4,71f4 <__muldf3+0x5dc>
    71e4:	00460793          	addi	a5,a2,4
    71e8:	00c7b633          	sltu	a2,a5,a2
    71ec:	00c585b3          	add	a1,a1,a2
    71f0:	00078613          	mv	a2,a5
    71f4:	00800537          	lui	a0,0x800
    71f8:	00a5f533          	and	a0,a1,a0
    71fc:	00100793          	li	a5,1
    7200:	00000693          	li	a3,0
    7204:	00000713          	li	a4,0
    7208:	b0051ae3          	bnez	a0,6d1c <__muldf3+0x104>
    720c:	0e40006f          	j	72f0 <__muldf3+0x6d8>
    7210:	634010ef          	jal	ra,8844 <__clzsi2>
    7214:	01550613          	addi	a2,a0,21 # 800015 <_stack_top+0x7da815>
    7218:	01c00793          	li	a5,28
    721c:	00c12683          	lw	a3,12(sp)
    7220:	02050713          	addi	a4,a0,32
    7224:	c4c7d6e3          	bge	a5,a2,6e70 <__muldf3+0x258>
    7228:	ff850513          	addi	a0,a0,-8
    722c:	00000a13          	li	s4,0
    7230:	00a414b3          	sll	s1,s0,a0
    7234:	c59ff06f          	j	6e8c <__muldf3+0x274>
    7238:	000c0513          	mv	a0,s8
    723c:	608010ef          	jal	ra,8844 <__clzsi2>
    7240:	01550713          	addi	a4,a0,21
    7244:	01c00793          	li	a5,28
    7248:	02050e13          	addi	t3,a0,32
    724c:	bce7d4e3          	bge	a5,a4,6e14 <__muldf3+0x1fc>
    7250:	ff850513          	addi	a0,a0,-8
    7254:	00000e93          	li	t4,0
    7258:	00ac1433          	sll	s0,s8,a0
    725c:	bd5ff06f          	j	6e30 <__muldf3+0x218>
    7260:	7ff00793          	li	a5,2047
    7264:	00000693          	li	a3,0
    7268:	00000713          	li	a4,0
    726c:	ab1ff06f          	j	6d1c <__muldf3+0x104>
    7270:	0129c833          	xor	a6,s3,s2
    7274:	00080693          	mv	a3,a6
    7278:	00000413          	li	s0,0
    727c:	00000e93          	li	t4,0
    7280:	00200513          	li	a0,2
    7284:	a69ff06f          	j	6cec <__muldf3+0xd4>
    7288:	40f70733          	sub	a4,a4,a5
    728c:	03800693          	li	a3,56
    7290:	a8e6c0e3          	blt	a3,a4,6d10 <__muldf3+0xf8>
    7294:	01f00693          	li	a3,31
    7298:	f0e6dce3          	bge	a3,a4,71b0 <__muldf3+0x598>
    729c:	fe100693          	li	a3,-31
    72a0:	40f687b3          	sub	a5,a3,a5
    72a4:	02000693          	li	a3,32
    72a8:	00f457b3          	srl	a5,s0,a5
    72ac:	00d70863          	beq	a4,a3,72bc <__muldf3+0x6a4>
    72b0:	43ee0e13          	addi	t3,t3,1086
    72b4:	01c41e33          	sll	t3,s0,t3
    72b8:	01ceeeb3          	or	t4,t4,t3
    72bc:	01d03633          	snez	a2,t4
    72c0:	00f66633          	or	a2,a2,a5
    72c4:	00767713          	andi	a4,a2,7
    72c8:	00000693          	li	a3,0
    72cc:	02070863          	beqz	a4,72fc <__muldf3+0x6e4>
    72d0:	00f67793          	andi	a5,a2,15
    72d4:	00400713          	li	a4,4
    72d8:	00000593          	li	a1,0
    72dc:	00e78a63          	beq	a5,a4,72f0 <__muldf3+0x6d8>
    72e0:	00460793          	addi	a5,a2,4
    72e4:	00c7b633          	sltu	a2,a5,a2
    72e8:	00c035b3          	snez	a1,a2
    72ec:	00078613          	mv	a2,a5
    72f0:	00959693          	slli	a3,a1,0x9
    72f4:	01d59713          	slli	a4,a1,0x1d
    72f8:	00c6d693          	srli	a3,a3,0xc
    72fc:	00365613          	srli	a2,a2,0x3
    7300:	00e66733          	or	a4,a2,a4
    7304:	00000793          	li	a5,0
    7308:	a15ff06f          	j	6d1c <__muldf3+0x104>
    730c:	00070413          	mv	s0,a4
    7310:	ad5ff06f          	j	6de4 <__muldf3+0x1cc>
    7314:	00f00713          	li	a4,15
    7318:	00eb1a63          	bne	s6,a4,732c <__muldf3+0x714>
    731c:	00000813          	li	a6,0
    7320:	000806b7          	lui	a3,0x80
    7324:	00000713          	li	a4,0
    7328:	9f5ff06f          	j	6d1c <__muldf3+0x104>
    732c:	00040713          	mv	a4,s0
    7330:	00b00793          	li	a5,11
    7334:	00300513          	li	a0,3
    7338:	bcdff06f          	j	6f04 <__muldf3+0x2ec>

0000733c <__subdf3>:
    733c:	001007b7          	lui	a5,0x100
    7340:	fff78793          	addi	a5,a5,-1 # fffff <_stack_top+0xda7ff>
    7344:	fe010113          	addi	sp,sp,-32
    7348:	00b7f8b3          	and	a7,a5,a1
    734c:	0146d813          	srli	a6,a3,0x14
    7350:	00d7f7b3          	and	a5,a5,a3
    7354:	00389893          	slli	a7,a7,0x3
    7358:	00379713          	slli	a4,a5,0x3
    735c:	00812c23          	sw	s0,24(sp)
    7360:	00912a23          	sw	s1,20(sp)
    7364:	0145d413          	srli	s0,a1,0x14
    7368:	01212823          	sw	s2,16(sp)
    736c:	01d65793          	srli	a5,a2,0x1d
    7370:	01d55913          	srli	s2,a0,0x1d
    7374:	00112e23          	sw	ra,28(sp)
    7378:	01312623          	sw	s3,12(sp)
    737c:	7ff87813          	andi	a6,a6,2047
    7380:	7ff00313          	li	t1,2047
    7384:	01f5d493          	srli	s1,a1,0x1f
    7388:	01196933          	or	s2,s2,a7
    738c:	7ff47413          	andi	s0,s0,2047
    7390:	00351893          	slli	a7,a0,0x3
    7394:	01f6d693          	srli	a3,a3,0x1f
    7398:	00e7e7b3          	or	a5,a5,a4
    739c:	00361593          	slli	a1,a2,0x3
    73a0:	20680e63          	beq	a6,t1,75bc <__subdf3+0x280>
    73a4:	0016c693          	xori	a3,a3,1
    73a8:	41040733          	sub	a4,s0,a6
    73ac:	16d48263          	beq	s1,a3,7510 <__subdf3+0x1d4>
    73b0:	04e050e3          	blez	a4,7bf0 <__subdf3+0x8b4>
    73b4:	24080a63          	beqz	a6,7608 <__subdf3+0x2cc>
    73b8:	66640a63          	beq	s0,t1,7a2c <__subdf3+0x6f0>
    73bc:	03800693          	li	a3,56
    73c0:	00100993          	li	s3,1
    73c4:	02e6ce63          	blt	a3,a4,7400 <__subdf3+0xc4>
    73c8:	008006b7          	lui	a3,0x800
    73cc:	00d7e7b3          	or	a5,a5,a3
    73d0:	01f00693          	li	a3,31
    73d4:	4ce6c463          	blt	a3,a4,789c <__subdf3+0x560>
    73d8:	02000693          	li	a3,32
    73dc:	40e686b3          	sub	a3,a3,a4
    73e0:	00d799b3          	sll	s3,a5,a3
    73e4:	00e5d633          	srl	a2,a1,a4
    73e8:	00d596b3          	sll	a3,a1,a3
    73ec:	00c9e9b3          	or	s3,s3,a2
    73f0:	00d036b3          	snez	a3,a3
    73f4:	00e7d733          	srl	a4,a5,a4
    73f8:	00d9e9b3          	or	s3,s3,a3
    73fc:	40e90933          	sub	s2,s2,a4
    7400:	413889b3          	sub	s3,a7,s3
    7404:	0138b7b3          	sltu	a5,a7,s3
    7408:	40f90933          	sub	s2,s2,a5
    740c:	008007b7          	lui	a5,0x800
    7410:	00f97733          	and	a4,s2,a5
    7414:	32070263          	beqz	a4,7738 <__subdf3+0x3fc>
    7418:	fff78793          	addi	a5,a5,-1 # 7fffff <_stack_top+0x7da7ff>
    741c:	00f97933          	and	s2,s2,a5
    7420:	32090263          	beqz	s2,7744 <__subdf3+0x408>
    7424:	00090513          	mv	a0,s2
    7428:	41c010ef          	jal	ra,8844 <__clzsi2>
    742c:	ff850713          	addi	a4,a0,-8
    7430:	02000693          	li	a3,32
    7434:	40e687b3          	sub	a5,a3,a4
    7438:	00f9d7b3          	srl	a5,s3,a5
    743c:	00e91933          	sll	s2,s2,a4
    7440:	0127e7b3          	or	a5,a5,s2
    7444:	00e999b3          	sll	s3,s3,a4
    7448:	3a874663          	blt	a4,s0,77f4 <__subdf3+0x4b8>
    744c:	40870733          	sub	a4,a4,s0
    7450:	00170713          	addi	a4,a4,1 # 1000001 <_stack_top+0xfda801>
    7454:	40e686b3          	sub	a3,a3,a4
    7458:	00d99633          	sll	a2,s3,a3
    745c:	00e9d933          	srl	s2,s3,a4
    7460:	00c03633          	snez	a2,a2
    7464:	00c96633          	or	a2,s2,a2
    7468:	00d796b3          	sll	a3,a5,a3
    746c:	00c6e9b3          	or	s3,a3,a2
    7470:	00e7d933          	srl	s2,a5,a4
    7474:	00000413          	li	s0,0
    7478:	0079f793          	andi	a5,s3,7
    747c:	02078063          	beqz	a5,749c <__subdf3+0x160>
    7480:	00f9f793          	andi	a5,s3,15
    7484:	00400713          	li	a4,4
    7488:	00e78a63          	beq	a5,a4,749c <__subdf3+0x160>
    748c:	00498793          	addi	a5,s3,4
    7490:	0137b9b3          	sltu	s3,a5,s3
    7494:	01390933          	add	s2,s2,s3
    7498:	00078993          	mv	s3,a5
    749c:	008007b7          	lui	a5,0x800
    74a0:	00f977b3          	and	a5,s2,a5
    74a4:	30078063          	beqz	a5,77a4 <__subdf3+0x468>
    74a8:	00140413          	addi	s0,s0,1
    74ac:	7ff00793          	li	a5,2047
    74b0:	26f40a63          	beq	s0,a5,7724 <__subdf3+0x3e8>
    74b4:	ff8007b7          	lui	a5,0xff800
    74b8:	fff78793          	addi	a5,a5,-1 # ff7fffff <_stack_top+0xff7da7ff>
    74bc:	00f977b3          	and	a5,s2,a5
    74c0:	01d79713          	slli	a4,a5,0x1d
    74c4:	0039d993          	srli	s3,s3,0x3
    74c8:	00979793          	slli	a5,a5,0x9
    74cc:	01376733          	or	a4,a4,s3
    74d0:	00c7d793          	srli	a5,a5,0xc
    74d4:	7ff47413          	andi	s0,s0,2047
    74d8:	0014f493          	andi	s1,s1,1
    74dc:	01441413          	slli	s0,s0,0x14
    74e0:	01f49493          	slli	s1,s1,0x1f
    74e4:	00f46433          	or	s0,s0,a5
    74e8:	00946433          	or	s0,s0,s1
    74ec:	01c12083          	lw	ra,28(sp)
    74f0:	00040593          	mv	a1,s0
    74f4:	01812403          	lw	s0,24(sp)
    74f8:	01412483          	lw	s1,20(sp)
    74fc:	01012903          	lw	s2,16(sp)
    7500:	00c12983          	lw	s3,12(sp)
    7504:	00070513          	mv	a0,a4
    7508:	02010113          	addi	sp,sp,32
    750c:	00008067          	ret
    7510:	70e05a63          	blez	a4,7c24 <__subdf3+0x8e8>
    7514:	1e081a63          	bnez	a6,7708 <__subdf3+0x3cc>
    7518:	00b7e6b3          	or	a3,a5,a1
    751c:	2c068663          	beqz	a3,77e8 <__subdf3+0x4ac>
    7520:	fff70613          	addi	a2,a4,-1
    7524:	4a060463          	beqz	a2,79cc <__subdf3+0x690>
    7528:	54670a63          	beq	a4,t1,7a7c <__subdf3+0x740>
    752c:	03800713          	li	a4,56
    7530:	00100693          	li	a3,1
    7534:	02c74c63          	blt	a4,a2,756c <__subdf3+0x230>
    7538:	00060713          	mv	a4,a2
    753c:	01f00693          	li	a3,31
    7540:	50e6c263          	blt	a3,a4,7a44 <__subdf3+0x708>
    7544:	02000613          	li	a2,32
    7548:	40e60633          	sub	a2,a2,a4
    754c:	00c796b3          	sll	a3,a5,a2
    7550:	00e5d533          	srl	a0,a1,a4
    7554:	00c59633          	sll	a2,a1,a2
    7558:	00a6e6b3          	or	a3,a3,a0
    755c:	00c03633          	snez	a2,a2
    7560:	00e7d733          	srl	a4,a5,a4
    7564:	00c6e6b3          	or	a3,a3,a2
    7568:	00e90933          	add	s2,s2,a4
    756c:	011687b3          	add	a5,a3,a7
    7570:	00d7b6b3          	sltu	a3,a5,a3
    7574:	00078993          	mv	s3,a5
    7578:	00d90933          	add	s2,s2,a3
    757c:	008007b7          	lui	a5,0x800
    7580:	00f977b3          	and	a5,s2,a5
    7584:	1a078a63          	beqz	a5,7738 <__subdf3+0x3fc>
    7588:	00140413          	addi	s0,s0,1
    758c:	7ff00793          	li	a5,2047
    7590:	18f40a63          	beq	s0,a5,7724 <__subdf3+0x3e8>
    7594:	ff8007b7          	lui	a5,0xff800
    7598:	fff78793          	addi	a5,a5,-1 # ff7fffff <_stack_top+0xff7da7ff>
    759c:	00f977b3          	and	a5,s2,a5
    75a0:	0019d713          	srli	a4,s3,0x1
    75a4:	0019f993          	andi	s3,s3,1
    75a8:	01376733          	or	a4,a4,s3
    75ac:	01f79993          	slli	s3,a5,0x1f
    75b0:	00e9e9b3          	or	s3,s3,a4
    75b4:	0017d913          	srli	s2,a5,0x1
    75b8:	ec1ff06f          	j	7478 <__subdf3+0x13c>
    75bc:	00b7e733          	or	a4,a5,a1
    75c0:	80140313          	addi	t1,s0,-2047
    75c4:	06070663          	beqz	a4,7630 <__subdf3+0x2f4>
    75c8:	06d48863          	beq	s1,a3,7638 <__subdf3+0x2fc>
    75cc:	0e030263          	beqz	t1,76b0 <__subdf3+0x374>
    75d0:	20040063          	beqz	s0,77d0 <__subdf3+0x494>
    75d4:	00361613          	slli	a2,a2,0x3
    75d8:	01d79713          	slli	a4,a5,0x1d
    75dc:	00365613          	srli	a2,a2,0x3
    75e0:	00e66733          	or	a4,a2,a4
    75e4:	0037d793          	srli	a5,a5,0x3
    75e8:	00068493          	mv	s1,a3
    75ec:	00f76733          	or	a4,a4,a5
    75f0:	12070a63          	beqz	a4,7724 <__subdf3+0x3e8>
    75f4:	00000493          	li	s1,0
    75f8:	7ff00413          	li	s0,2047
    75fc:	000807b7          	lui	a5,0x80
    7600:	00000713          	li	a4,0
    7604:	ed9ff06f          	j	74dc <__subdf3+0x1a0>
    7608:	00b7e6b3          	or	a3,a5,a1
    760c:	1c068e63          	beqz	a3,77e8 <__subdf3+0x4ac>
    7610:	fff70693          	addi	a3,a4,-1
    7614:	3e068e63          	beqz	a3,7a10 <__subdf3+0x6d4>
    7618:	3e670063          	beq	a4,t1,79f8 <__subdf3+0x6bc>
    761c:	03800713          	li	a4,56
    7620:	00100993          	li	s3,1
    7624:	dcd74ee3          	blt	a4,a3,7400 <__subdf3+0xc4>
    7628:	00068713          	mv	a4,a3
    762c:	da5ff06f          	j	73d0 <__subdf3+0x94>
    7630:	0016c693          	xori	a3,a3,1
    7634:	f8d49ce3          	bne	s1,a3,75cc <__subdf3+0x290>
    7638:	1c030863          	beqz	t1,7808 <__subdf3+0x4cc>
    763c:	2e041863          	bnez	s0,792c <__subdf3+0x5f0>
    7640:	7ff00713          	li	a4,2047
    7644:	011966b3          	or	a3,s2,a7
    7648:	4c068863          	beqz	a3,7b18 <__subdf3+0x7dc>
    764c:	fff70693          	addi	a3,a4,-1
    7650:	36068e63          	beqz	a3,79cc <__subdf3+0x690>
    7654:	7ff00513          	li	a0,2047
    7658:	2ca70a63          	beq	a4,a0,792c <__subdf3+0x5f0>
    765c:	03800613          	li	a2,56
    7660:	00100713          	li	a4,1
    7664:	02d64a63          	blt	a2,a3,7698 <__subdf3+0x35c>
    7668:	01f00713          	li	a4,31
    766c:	52d74063          	blt	a4,a3,7b8c <__subdf3+0x850>
    7670:	02000613          	li	a2,32
    7674:	40d60633          	sub	a2,a2,a3
    7678:	00c91733          	sll	a4,s2,a2
    767c:	00d8d533          	srl	a0,a7,a3
    7680:	00c89633          	sll	a2,a7,a2
    7684:	00a76733          	or	a4,a4,a0
    7688:	00c03633          	snez	a2,a2
    768c:	00d956b3          	srl	a3,s2,a3
    7690:	00c76733          	or	a4,a4,a2
    7694:	00d787b3          	add	a5,a5,a3
    7698:	00b705b3          	add	a1,a4,a1
    769c:	00e5b733          	sltu	a4,a1,a4
    76a0:	00058993          	mv	s3,a1
    76a4:	00f70933          	add	s2,a4,a5
    76a8:	00080413          	mv	s0,a6
    76ac:	ed1ff06f          	j	757c <__subdf3+0x240>
    76b0:	00140713          	addi	a4,s0,1
    76b4:	7fe77713          	andi	a4,a4,2046
    76b8:	1a071663          	bnez	a4,7864 <__subdf3+0x528>
    76bc:	00b7e733          	or	a4,a5,a1
    76c0:	01196833          	or	a6,s2,a7
    76c4:	2e041863          	bnez	s0,79b4 <__subdf3+0x678>
    76c8:	3e080c63          	beqz	a6,7ac0 <__subdf3+0x784>
    76cc:	42070a63          	beqz	a4,7b00 <__subdf3+0x7c4>
    76d0:	40b889b3          	sub	s3,a7,a1
    76d4:	0138b733          	sltu	a4,a7,s3
    76d8:	40f90633          	sub	a2,s2,a5
    76dc:	40e60633          	sub	a2,a2,a4
    76e0:	00800737          	lui	a4,0x800
    76e4:	00e67733          	and	a4,a2,a4
    76e8:	4e070463          	beqz	a4,7bd0 <__subdf3+0x894>
    76ec:	411588b3          	sub	a7,a1,a7
    76f0:	412787b3          	sub	a5,a5,s2
    76f4:	0115b5b3          	sltu	a1,a1,a7
    76f8:	00088993          	mv	s3,a7
    76fc:	40b78933          	sub	s2,a5,a1
    7700:	00068493          	mv	s1,a3
    7704:	d75ff06f          	j	7478 <__subdf3+0x13c>
    7708:	2e640863          	beq	s0,t1,79f8 <__subdf3+0x6bc>
    770c:	03800613          	li	a2,56
    7710:	00100693          	li	a3,1
    7714:	e4e64ce3          	blt	a2,a4,756c <__subdf3+0x230>
    7718:	008006b7          	lui	a3,0x800
    771c:	00d7e7b3          	or	a5,a5,a3
    7720:	e1dff06f          	j	753c <__subdf3+0x200>
    7724:	0014f493          	andi	s1,s1,1
    7728:	7ff00413          	li	s0,2047
    772c:	00000793          	li	a5,0
    7730:	00000713          	li	a4,0
    7734:	da9ff06f          	j	74dc <__subdf3+0x1a0>
    7738:	0079f713          	andi	a4,s3,7
    773c:	d40712e3          	bnez	a4,7480 <__subdf3+0x144>
    7740:	1180006f          	j	7858 <__subdf3+0x51c>
    7744:	00098513          	mv	a0,s3
    7748:	0fc010ef          	jal	ra,8844 <__clzsi2>
    774c:	01850713          	addi	a4,a0,24
    7750:	01f00693          	li	a3,31
    7754:	cce6dee3          	bge	a3,a4,7430 <__subdf3+0xf4>
    7758:	ff850793          	addi	a5,a0,-8
    775c:	00f997b3          	sll	a5,s3,a5
    7760:	1e874263          	blt	a4,s0,7944 <__subdf3+0x608>
    7764:	408709b3          	sub	s3,a4,s0
    7768:	00198713          	addi	a4,s3,1
    776c:	46e6da63          	bge	a3,a4,7be0 <__subdf3+0x8a4>
    7770:	fe198993          	addi	s3,s3,-31
    7774:	02000693          	li	a3,32
    7778:	0137d9b3          	srl	s3,a5,s3
    777c:	00d70c63          	beq	a4,a3,7794 <__subdf3+0x458>
    7780:	04000693          	li	a3,64
    7784:	40e68733          	sub	a4,a3,a4
    7788:	00e797b3          	sll	a5,a5,a4
    778c:	00f037b3          	snez	a5,a5
    7790:	00f9e9b3          	or	s3,s3,a5
    7794:	0079f713          	andi	a4,s3,7
    7798:	00000413          	li	s0,0
    779c:	ce0712e3          	bnez	a4,7480 <__subdf3+0x144>
    77a0:	0b80006f          	j	7858 <__subdf3+0x51c>
    77a4:	0039d793          	srli	a5,s3,0x3
    77a8:	01d91713          	slli	a4,s2,0x1d
    77ac:	7ff00693          	li	a3,2047
    77b0:	00f76733          	or	a4,a4,a5
    77b4:	00395793          	srli	a5,s2,0x3
    77b8:	e2d40ae3          	beq	s0,a3,75ec <__subdf3+0x2b0>
    77bc:	00c79793          	slli	a5,a5,0xc
    77c0:	00c7d793          	srli	a5,a5,0xc
    77c4:	7ff47413          	andi	s0,s0,2047
    77c8:	0014f493          	andi	s1,s1,1
    77cc:	d11ff06f          	j	74dc <__subdf3+0x1a0>
    77d0:	7ff00713          	li	a4,2047
    77d4:	01196533          	or	a0,s2,a7
    77d8:	0e051863          	bnez	a0,78c8 <__subdf3+0x58c>
    77dc:	00078913          	mv	s2,a5
    77e0:	00058893          	mv	a7,a1
    77e4:	00068493          	mv	s1,a3
    77e8:	0038d793          	srli	a5,a7,0x3
    77ec:	00070413          	mv	s0,a4
    77f0:	fb9ff06f          	j	77a8 <__subdf3+0x46c>
    77f4:	ff800937          	lui	s2,0xff800
    77f8:	fff90913          	addi	s2,s2,-1 # ff7fffff <_stack_top+0xff7da7ff>
    77fc:	40e40433          	sub	s0,s0,a4
    7800:	0127f933          	and	s2,a5,s2
    7804:	c75ff06f          	j	7478 <__subdf3+0x13c>
    7808:	00140693          	addi	a3,s0,1
    780c:	7fe6f713          	andi	a4,a3,2046
    7810:	14071863          	bnez	a4,7960 <__subdf3+0x624>
    7814:	01196733          	or	a4,s2,a7
    7818:	24041c63          	bnez	s0,7a70 <__subdf3+0x734>
    781c:	32070263          	beqz	a4,7b40 <__subdf3+0x804>
    7820:	00b7e733          	or	a4,a5,a1
    7824:	34070863          	beqz	a4,7b74 <__subdf3+0x838>
    7828:	00b885b3          	add	a1,a7,a1
    782c:	00f907b3          	add	a5,s2,a5
    7830:	0115b8b3          	sltu	a7,a1,a7
    7834:	01178933          	add	s2,a5,a7
    7838:	00800737          	lui	a4,0x800
    783c:	00e97733          	and	a4,s2,a4
    7840:	00058993          	mv	s3,a1
    7844:	00070a63          	beqz	a4,7858 <__subdf3+0x51c>
    7848:	ff8007b7          	lui	a5,0xff800
    784c:	fff78793          	addi	a5,a5,-1 # ff7fffff <_stack_top+0xff7da7ff>
    7850:	00f97933          	and	s2,s2,a5
    7854:	00100413          	li	s0,1
    7858:	00098893          	mv	a7,s3
    785c:	00040713          	mv	a4,s0
    7860:	f89ff06f          	j	77e8 <__subdf3+0x4ac>
    7864:	40b889b3          	sub	s3,a7,a1
    7868:	0138b733          	sltu	a4,a7,s3
    786c:	40f90633          	sub	a2,s2,a5
    7870:	40e60633          	sub	a2,a2,a4
    7874:	00800737          	lui	a4,0x800
    7878:	00e67733          	and	a4,a2,a4
    787c:	10071e63          	bnez	a4,7998 <__subdf3+0x65c>
    7880:	00c9e733          	or	a4,s3,a2
    7884:	00060913          	mv	s2,a2
    7888:	b8071ce3          	bnez	a4,7420 <__subdf3+0xe4>
    788c:	00000493          	li	s1,0
    7890:	00000413          	li	s0,0
    7894:	00000793          	li	a5,0
    7898:	c45ff06f          	j	74dc <__subdf3+0x1a0>
    789c:	fe070693          	addi	a3,a4,-32 # 7fffe0 <_stack_top+0x7da7e0>
    78a0:	02000613          	li	a2,32
    78a4:	00d7d6b3          	srl	a3,a5,a3
    78a8:	00c70a63          	beq	a4,a2,78bc <__subdf3+0x580>
    78ac:	04000613          	li	a2,64
    78b0:	40e60733          	sub	a4,a2,a4
    78b4:	00e797b3          	sll	a5,a5,a4
    78b8:	00f5e5b3          	or	a1,a1,a5
    78bc:	00b039b3          	snez	s3,a1
    78c0:	00d9e9b3          	or	s3,s3,a3
    78c4:	b3dff06f          	j	7400 <__subdf3+0xc4>
    78c8:	fff70513          	addi	a0,a4,-1
    78cc:	20050a63          	beqz	a0,7ae0 <__subdf3+0x7a4>
    78d0:	7ff00313          	li	t1,2047
    78d4:	28670263          	beq	a4,t1,7b58 <__subdf3+0x81c>
    78d8:	03800713          	li	a4,56
    78dc:	00068493          	mv	s1,a3
    78e0:	00100993          	li	s3,1
    78e4:	02a74a63          	blt	a4,a0,7918 <__subdf3+0x5dc>
    78e8:	01f00713          	li	a4,31
    78ec:	1aa74463          	blt	a4,a0,7a94 <__subdf3+0x758>
    78f0:	02000713          	li	a4,32
    78f4:	40a70733          	sub	a4,a4,a0
    78f8:	00e919b3          	sll	s3,s2,a4
    78fc:	00a8d6b3          	srl	a3,a7,a0
    7900:	00e89733          	sll	a4,a7,a4
    7904:	00d9e9b3          	or	s3,s3,a3
    7908:	00e03733          	snez	a4,a4
    790c:	00a95533          	srl	a0,s2,a0
    7910:	00e9e9b3          	or	s3,s3,a4
    7914:	40a787b3          	sub	a5,a5,a0
    7918:	413589b3          	sub	s3,a1,s3
    791c:	0135b5b3          	sltu	a1,a1,s3
    7920:	40b78933          	sub	s2,a5,a1
    7924:	00080413          	mv	s0,a6
    7928:	ae5ff06f          	j	740c <__subdf3+0xd0>
    792c:	00361613          	slli	a2,a2,0x3
    7930:	01d79713          	slli	a4,a5,0x1d
    7934:	00365613          	srli	a2,a2,0x3
    7938:	00e66733          	or	a4,a2,a4
    793c:	0037d793          	srli	a5,a5,0x3
    7940:	cadff06f          	j	75ec <__subdf3+0x2b0>
    7944:	ff8006b7          	lui	a3,0xff800
    7948:	fff68693          	addi	a3,a3,-1 # ff7fffff <_stack_top+0xff7da7ff>
    794c:	00d7f7b3          	and	a5,a5,a3
    7950:	40e40433          	sub	s0,s0,a4
    7954:	01d79713          	slli	a4,a5,0x1d
    7958:	0037d793          	srli	a5,a5,0x3
    795c:	e61ff06f          	j	77bc <__subdf3+0x480>
    7960:	7ff00713          	li	a4,2047
    7964:	dce680e3          	beq	a3,a4,7724 <__subdf3+0x3e8>
    7968:	00b88733          	add	a4,a7,a1
    796c:	00f907b3          	add	a5,s2,a5
    7970:	011738b3          	sltu	a7,a4,a7
    7974:	011787b3          	add	a5,a5,a7
    7978:	00175713          	srli	a4,a4,0x1
    797c:	01f79993          	slli	s3,a5,0x1f
    7980:	00e9e9b3          	or	s3,s3,a4
    7984:	00777713          	andi	a4,a4,7
    7988:	0017d913          	srli	s2,a5,0x1
    798c:	00068413          	mv	s0,a3
    7990:	ae0718e3          	bnez	a4,7480 <__subdf3+0x144>
    7994:	ec5ff06f          	j	7858 <__subdf3+0x51c>
    7998:	411588b3          	sub	a7,a1,a7
    799c:	412787b3          	sub	a5,a5,s2
    79a0:	0115b5b3          	sltu	a1,a1,a7
    79a4:	00088993          	mv	s3,a7
    79a8:	40b78933          	sub	s2,a5,a1
    79ac:	00068493          	mv	s1,a3
    79b0:	a71ff06f          	j	7420 <__subdf3+0xe4>
    79b4:	16081863          	bnez	a6,7b24 <__subdf3+0x7e8>
    79b8:	c0071ee3          	bnez	a4,75d4 <__subdf3+0x298>
    79bc:	00000493          	li	s1,0
    79c0:	7ff00413          	li	s0,2047
    79c4:	000807b7          	lui	a5,0x80
    79c8:	b15ff06f          	j	74dc <__subdf3+0x1a0>
    79cc:	00b885b3          	add	a1,a7,a1
    79d0:	00f907b3          	add	a5,s2,a5
    79d4:	0115b8b3          	sltu	a7,a1,a7
    79d8:	01178933          	add	s2,a5,a7
    79dc:	008007b7          	lui	a5,0x800
    79e0:	00f977b3          	and	a5,s2,a5
    79e4:	00058993          	mv	s3,a1
    79e8:	00100413          	li	s0,1
    79ec:	d40786e3          	beqz	a5,7738 <__subdf3+0x3fc>
    79f0:	00200413          	li	s0,2
    79f4:	ba1ff06f          	j	7594 <__subdf3+0x258>
    79f8:	00351513          	slli	a0,a0,0x3
    79fc:	01d91793          	slli	a5,s2,0x1d
    7a00:	00355713          	srli	a4,a0,0x3
    7a04:	00f76733          	or	a4,a4,a5
    7a08:	00395793          	srli	a5,s2,0x3
    7a0c:	be1ff06f          	j	75ec <__subdf3+0x2b0>
    7a10:	40b885b3          	sub	a1,a7,a1
    7a14:	40f907b3          	sub	a5,s2,a5
    7a18:	00b8b8b3          	sltu	a7,a7,a1
    7a1c:	00058993          	mv	s3,a1
    7a20:	41178933          	sub	s2,a5,a7
    7a24:	00100413          	li	s0,1
    7a28:	9e5ff06f          	j	740c <__subdf3+0xd0>
    7a2c:	00351513          	slli	a0,a0,0x3
    7a30:	01d91713          	slli	a4,s2,0x1d
    7a34:	00355513          	srli	a0,a0,0x3
    7a38:	00a76733          	or	a4,a4,a0
    7a3c:	00395793          	srli	a5,s2,0x3
    7a40:	badff06f          	j	75ec <__subdf3+0x2b0>
    7a44:	fe070613          	addi	a2,a4,-32
    7a48:	02000693          	li	a3,32
    7a4c:	00c7d633          	srl	a2,a5,a2
    7a50:	00d70a63          	beq	a4,a3,7a64 <__subdf3+0x728>
    7a54:	04000693          	li	a3,64
    7a58:	40e68733          	sub	a4,a3,a4
    7a5c:	00e797b3          	sll	a5,a5,a4
    7a60:	00f5e5b3          	or	a1,a1,a5
    7a64:	00b036b3          	snez	a3,a1
    7a68:	00c6e6b3          	or	a3,a3,a2
    7a6c:	b01ff06f          	j	756c <__subdf3+0x230>
    7a70:	14070463          	beqz	a4,7bb8 <__subdf3+0x87c>
    7a74:	00b7e5b3          	or	a1,a5,a1
    7a78:	b6059ee3          	bnez	a1,75f4 <__subdf3+0x2b8>
    7a7c:	00351513          	slli	a0,a0,0x3
    7a80:	01d91793          	slli	a5,s2,0x1d
    7a84:	00355513          	srli	a0,a0,0x3
    7a88:	00f56733          	or	a4,a0,a5
    7a8c:	00395793          	srli	a5,s2,0x3
    7a90:	b5dff06f          	j	75ec <__subdf3+0x2b0>
    7a94:	fe050713          	addi	a4,a0,-32
    7a98:	02000693          	li	a3,32
    7a9c:	00e95733          	srl	a4,s2,a4
    7aa0:	00d50a63          	beq	a0,a3,7ab4 <__subdf3+0x778>
    7aa4:	04000693          	li	a3,64
    7aa8:	40a686b3          	sub	a3,a3,a0
    7aac:	00d916b3          	sll	a3,s2,a3
    7ab0:	00d8e8b3          	or	a7,a7,a3
    7ab4:	011039b3          	snez	s3,a7
    7ab8:	00e9e9b3          	or	s3,s3,a4
    7abc:	e5dff06f          	j	7918 <__subdf3+0x5dc>
    7ac0:	dc0706e3          	beqz	a4,788c <__subdf3+0x550>
    7ac4:	00361613          	slli	a2,a2,0x3
    7ac8:	01d79713          	slli	a4,a5,0x1d
    7acc:	00365613          	srli	a2,a2,0x3
    7ad0:	00c76733          	or	a4,a4,a2
    7ad4:	0037d793          	srli	a5,a5,0x3
    7ad8:	00068493          	mv	s1,a3
    7adc:	ce1ff06f          	j	77bc <__subdf3+0x480>
    7ae0:	411588b3          	sub	a7,a1,a7
    7ae4:	412787b3          	sub	a5,a5,s2
    7ae8:	0115b5b3          	sltu	a1,a1,a7
    7aec:	00088993          	mv	s3,a7
    7af0:	40b78933          	sub	s2,a5,a1
    7af4:	00068493          	mv	s1,a3
    7af8:	00100413          	li	s0,1
    7afc:	911ff06f          	j	740c <__subdf3+0xd0>
    7b00:	00351793          	slli	a5,a0,0x3
    7b04:	0037d793          	srli	a5,a5,0x3
    7b08:	01d91713          	slli	a4,s2,0x1d
    7b0c:	00f76733          	or	a4,a4,a5
    7b10:	00395793          	srli	a5,s2,0x3
    7b14:	ca9ff06f          	j	77bc <__subdf3+0x480>
    7b18:	00078913          	mv	s2,a5
    7b1c:	00058893          	mv	a7,a1
    7b20:	cc9ff06f          	j	77e8 <__subdf3+0x4ac>
    7b24:	ac0718e3          	bnez	a4,75f4 <__subdf3+0x2b8>
    7b28:	00351793          	slli	a5,a0,0x3
    7b2c:	0037d793          	srli	a5,a5,0x3
    7b30:	01d91713          	slli	a4,s2,0x1d
    7b34:	00f76733          	or	a4,a4,a5
    7b38:	00395793          	srli	a5,s2,0x3
    7b3c:	ab1ff06f          	j	75ec <__subdf3+0x2b0>
    7b40:	00361613          	slli	a2,a2,0x3
    7b44:	01d79713          	slli	a4,a5,0x1d
    7b48:	00365613          	srli	a2,a2,0x3
    7b4c:	00e66733          	or	a4,a2,a4
    7b50:	0037d793          	srli	a5,a5,0x3
    7b54:	c69ff06f          	j	77bc <__subdf3+0x480>
    7b58:	00361613          	slli	a2,a2,0x3
    7b5c:	01d79713          	slli	a4,a5,0x1d
    7b60:	00365613          	srli	a2,a2,0x3
    7b64:	00c76733          	or	a4,a4,a2
    7b68:	0037d793          	srli	a5,a5,0x3
    7b6c:	00068493          	mv	s1,a3
    7b70:	a7dff06f          	j	75ec <__subdf3+0x2b0>
    7b74:	00351513          	slli	a0,a0,0x3
    7b78:	01d91793          	slli	a5,s2,0x1d
    7b7c:	00355513          	srli	a0,a0,0x3
    7b80:	00f56733          	or	a4,a0,a5
    7b84:	00395793          	srli	a5,s2,0x3
    7b88:	c35ff06f          	j	77bc <__subdf3+0x480>
    7b8c:	fe068613          	addi	a2,a3,-32
    7b90:	02000713          	li	a4,32
    7b94:	00c95633          	srl	a2,s2,a2
    7b98:	00e68a63          	beq	a3,a4,7bac <__subdf3+0x870>
    7b9c:	04000713          	li	a4,64
    7ba0:	40d70733          	sub	a4,a4,a3
    7ba4:	00e91733          	sll	a4,s2,a4
    7ba8:	00e8e8b3          	or	a7,a7,a4
    7bac:	01103733          	snez	a4,a7
    7bb0:	00c76733          	or	a4,a4,a2
    7bb4:	ae5ff06f          	j	7698 <__subdf3+0x35c>
    7bb8:	00361613          	slli	a2,a2,0x3
    7bbc:	01d79713          	slli	a4,a5,0x1d
    7bc0:	00365693          	srli	a3,a2,0x3
    7bc4:	00d76733          	or	a4,a4,a3
    7bc8:	0037d793          	srli	a5,a5,0x3
    7bcc:	a21ff06f          	j	75ec <__subdf3+0x2b0>
    7bd0:	00c9e733          	or	a4,s3,a2
    7bd4:	00060913          	mv	s2,a2
    7bd8:	c80710e3          	bnez	a4,7858 <__subdf3+0x51c>
    7bdc:	cb1ff06f          	j	788c <__subdf3+0x550>
    7be0:	02000693          	li	a3,32
    7be4:	40e686b3          	sub	a3,a3,a4
    7be8:	00000613          	li	a2,0
    7bec:	879ff06f          	j	7464 <__subdf3+0x128>
    7bf0:	ac0700e3          	beqz	a4,76b0 <__subdf3+0x374>
    7bf4:	40880533          	sub	a0,a6,s0
    7bf8:	00050713          	mv	a4,a0
    7bfc:	bc040ce3          	beqz	s0,77d4 <__subdf3+0x498>
    7c00:	03800713          	li	a4,56
    7c04:	00a74a63          	blt	a4,a0,7c18 <__subdf3+0x8dc>
    7c08:	00800737          	lui	a4,0x800
    7c0c:	00e96933          	or	s2,s2,a4
    7c10:	00068493          	mv	s1,a3
    7c14:	cd5ff06f          	j	78e8 <__subdf3+0x5ac>
    7c18:	00068493          	mv	s1,a3
    7c1c:	00100993          	li	s3,1
    7c20:	cf9ff06f          	j	7918 <__subdf3+0x5dc>
    7c24:	be0702e3          	beqz	a4,7808 <__subdf3+0x4cc>
    7c28:	408806b3          	sub	a3,a6,s0
    7c2c:	00041663          	bnez	s0,7c38 <__subdf3+0x8fc>
    7c30:	00068713          	mv	a4,a3
    7c34:	a11ff06f          	j	7644 <__subdf3+0x308>
    7c38:	03800613          	li	a2,56
    7c3c:	00100713          	li	a4,1
    7c40:	a4d64ce3          	blt	a2,a3,7698 <__subdf3+0x35c>
    7c44:	00800737          	lui	a4,0x800
    7c48:	00e96933          	or	s2,s2,a4
    7c4c:	a1dff06f          	j	7668 <__subdf3+0x32c>

00007c50 <__fixdfsi>:
    7c50:	0145d793          	srli	a5,a1,0x14
    7c54:	001006b7          	lui	a3,0x100
    7c58:	fff68713          	addi	a4,a3,-1 # fffff <_stack_top+0xda7ff>
    7c5c:	7ff7f793          	andi	a5,a5,2047
    7c60:	3fe00613          	li	a2,1022
    7c64:	00b77733          	and	a4,a4,a1
    7c68:	01f5d593          	srli	a1,a1,0x1f
    7c6c:	00f65e63          	bge	a2,a5,7c88 <__fixdfsi+0x38>
    7c70:	41d00613          	li	a2,1053
    7c74:	00f65e63          	bge	a2,a5,7c90 <__fixdfsi+0x40>
    7c78:	80000537          	lui	a0,0x80000
    7c7c:	fff54513          	not	a0,a0
    7c80:	00a58533          	add	a0,a1,a0
    7c84:	00008067          	ret
    7c88:	00000513          	li	a0,0
    7c8c:	00008067          	ret
    7c90:	43300613          	li	a2,1075
    7c94:	40f60633          	sub	a2,a2,a5
    7c98:	01f00813          	li	a6,31
    7c9c:	00d76733          	or	a4,a4,a3
    7ca0:	02c85063          	bge	a6,a2,7cc0 <__fixdfsi+0x70>
    7ca4:	41300693          	li	a3,1043
    7ca8:	40f687b3          	sub	a5,a3,a5
    7cac:	00f75733          	srl	a4,a4,a5
    7cb0:	40e00533          	neg	a0,a4
    7cb4:	fc059ce3          	bnez	a1,7c8c <__fixdfsi+0x3c>
    7cb8:	00070513          	mv	a0,a4
    7cbc:	00008067          	ret
    7cc0:	bed78793          	addi	a5,a5,-1043 # 7ffbed <_stack_top+0x7da3ed>
    7cc4:	00f71733          	sll	a4,a4,a5
    7cc8:	00c55533          	srl	a0,a0,a2
    7ccc:	00a76733          	or	a4,a4,a0
    7cd0:	fe1ff06f          	j	7cb0 <__fixdfsi+0x60>

00007cd4 <__floatsidf>:
    7cd4:	ff010113          	addi	sp,sp,-16
    7cd8:	00112623          	sw	ra,12(sp)
    7cdc:	00812423          	sw	s0,8(sp)
    7ce0:	00912223          	sw	s1,4(sp)
    7ce4:	04050a63          	beqz	a0,7d38 <__floatsidf+0x64>
    7ce8:	41f55713          	srai	a4,a0,0x1f
    7cec:	00a744b3          	xor	s1,a4,a0
    7cf0:	40e484b3          	sub	s1,s1,a4
    7cf4:	00050793          	mv	a5,a0
    7cf8:	00048513          	mv	a0,s1
    7cfc:	01f7d413          	srli	s0,a5,0x1f
    7d00:	345000ef          	jal	ra,8844 <__clzsi2>
    7d04:	41e00793          	li	a5,1054
    7d08:	40a787b3          	sub	a5,a5,a0
    7d0c:	00a00713          	li	a4,10
    7d10:	7ff7f793          	andi	a5,a5,2047
    7d14:	06a74063          	blt	a4,a0,7d74 <__floatsidf+0xa0>
    7d18:	00b00713          	li	a4,11
    7d1c:	40a70733          	sub	a4,a4,a0
    7d20:	00e4d733          	srl	a4,s1,a4
    7d24:	01550513          	addi	a0,a0,21 # 80000015 <_stack_top+0x7ffda815>
    7d28:	00c71713          	slli	a4,a4,0xc
    7d2c:	00a494b3          	sll	s1,s1,a0
    7d30:	00c75713          	srli	a4,a4,0xc
    7d34:	0140006f          	j	7d48 <__floatsidf+0x74>
    7d38:	00000413          	li	s0,0
    7d3c:	00000793          	li	a5,0
    7d40:	00000713          	li	a4,0
    7d44:	00000493          	li	s1,0
    7d48:	01479793          	slli	a5,a5,0x14
    7d4c:	01f41413          	slli	s0,s0,0x1f
    7d50:	00e7e7b3          	or	a5,a5,a4
    7d54:	00c12083          	lw	ra,12(sp)
    7d58:	0087e7b3          	or	a5,a5,s0
    7d5c:	00812403          	lw	s0,8(sp)
    7d60:	00048513          	mv	a0,s1
    7d64:	00078593          	mv	a1,a5
    7d68:	00412483          	lw	s1,4(sp)
    7d6c:	01010113          	addi	sp,sp,16
    7d70:	00008067          	ret
    7d74:	ff550513          	addi	a0,a0,-11
    7d78:	00a49733          	sll	a4,s1,a0
    7d7c:	00c71713          	slli	a4,a4,0xc
    7d80:	00c75713          	srli	a4,a4,0xc
    7d84:	00000493          	li	s1,0
    7d88:	fc1ff06f          	j	7d48 <__floatsidf+0x74>

00007d8c <__divsf3>:
    7d8c:	fd010113          	addi	sp,sp,-48
    7d90:	01755793          	srli	a5,a0,0x17
    7d94:	03212023          	sw	s2,32(sp)
    7d98:	01312e23          	sw	s3,28(sp)
    7d9c:	02112623          	sw	ra,44(sp)
    7da0:	00951993          	slli	s3,a0,0x9
    7da4:	02812423          	sw	s0,40(sp)
    7da8:	02912223          	sw	s1,36(sp)
    7dac:	01412c23          	sw	s4,24(sp)
    7db0:	01512a23          	sw	s5,20(sp)
    7db4:	01612823          	sw	s6,16(sp)
    7db8:	0ff7f793          	zext.b	a5,a5
    7dbc:	0099d993          	srli	s3,s3,0x9
    7dc0:	01f55913          	srli	s2,a0,0x1f
    7dc4:	12078a63          	beqz	a5,7ef8 <__divsf3+0x16c>
    7dc8:	0ff00713          	li	a4,255
    7dcc:	14e78063          	beq	a5,a4,7f0c <__divsf3+0x180>
    7dd0:	00399993          	slli	s3,s3,0x3
    7dd4:	04000737          	lui	a4,0x4000
    7dd8:	00e9e9b3          	or	s3,s3,a4
    7ddc:	f8178a93          	addi	s5,a5,-127
    7de0:	00000413          	li	s0,0
    7de4:	00000b13          	li	s6,0
    7de8:	0175d793          	srli	a5,a1,0x17
    7dec:	00959a13          	slli	s4,a1,0x9
    7df0:	0ff7f793          	zext.b	a5,a5
    7df4:	009a5a13          	srli	s4,s4,0x9
    7df8:	01f5d493          	srli	s1,a1,0x1f
    7dfc:	0c078663          	beqz	a5,7ec8 <__divsf3+0x13c>
    7e00:	0ff00713          	li	a4,255
    7e04:	10e78e63          	beq	a5,a4,7f20 <__divsf3+0x194>
    7e08:	003a1a13          	slli	s4,s4,0x3
    7e0c:	04000737          	lui	a4,0x4000
    7e10:	00ea6a33          	or	s4,s4,a4
    7e14:	f8178793          	addi	a5,a5,-127
    7e18:	00000613          	li	a2,0
    7e1c:	00f00693          	li	a3,15
    7e20:	00994733          	xor	a4,s2,s1
    7e24:	40fa8ab3          	sub	s5,s5,a5
    7e28:	2686e863          	bltu	a3,s0,8098 <__divsf3+0x30c>
    7e2c:	00005697          	auipc	a3,0x5
    7e30:	14c68693          	addi	a3,a3,332 # cf78 <errpat+0x5b4>
    7e34:	00241413          	slli	s0,s0,0x2
    7e38:	00d40433          	add	s0,s0,a3
    7e3c:	00042783          	lw	a5,0(s0)
    7e40:	00d787b3          	add	a5,a5,a3
    7e44:	00078067          	jr	a5
    7e48:	0ff00793          	li	a5,255
    7e4c:	00000693          	li	a3,0
    7e50:	02c12083          	lw	ra,44(sp)
    7e54:	02812403          	lw	s0,40(sp)
    7e58:	01779513          	slli	a0,a5,0x17
    7e5c:	00d56533          	or	a0,a0,a3
    7e60:	01f71713          	slli	a4,a4,0x1f
    7e64:	02412483          	lw	s1,36(sp)
    7e68:	02012903          	lw	s2,32(sp)
    7e6c:	01c12983          	lw	s3,28(sp)
    7e70:	01812a03          	lw	s4,24(sp)
    7e74:	01412a83          	lw	s5,20(sp)
    7e78:	01012b03          	lw	s6,16(sp)
    7e7c:	00e56533          	or	a0,a0,a4
    7e80:	03010113          	addi	sp,sp,48
    7e84:	00008067          	ret
    7e88:	00300793          	li	a5,3
    7e8c:	02fb0663          	beq	s6,a5,7eb8 <__divsf3+0x12c>
    7e90:	00100793          	li	a5,1
    7e94:	14fb1663          	bne	s6,a5,7fe0 <__divsf3+0x254>
    7e98:	00050713          	mv	a4,a0
    7e9c:	00000793          	li	a5,0
    7ea0:	00000693          	li	a3,0
    7ea4:	fadff06f          	j	7e50 <__divsf3+0xc4>
    7ea8:	00300793          	li	a5,3
    7eac:	00048513          	mv	a0,s1
    7eb0:	000a0993          	mv	s3,s4
    7eb4:	12f61663          	bne	a2,a5,7fe0 <__divsf3+0x254>
    7eb8:	00000713          	li	a4,0
    7ebc:	0ff00793          	li	a5,255
    7ec0:	004006b7          	lui	a3,0x400
    7ec4:	f8dff06f          	j	7e50 <__divsf3+0xc4>
    7ec8:	0c0a1c63          	bnez	s4,7fa0 <__divsf3+0x214>
    7ecc:	00146413          	ori	s0,s0,1
    7ed0:	00d00793          	li	a5,13
    7ed4:	00994733          	xor	a4,s2,s1
    7ed8:	f687e8e3          	bltu	a5,s0,7e48 <__divsf3+0xbc>
    7edc:	00005697          	auipc	a3,0x5
    7ee0:	0dc68693          	addi	a3,a3,220 # cfb8 <errpat+0x5f4>
    7ee4:	00241413          	slli	s0,s0,0x2
    7ee8:	00d40433          	add	s0,s0,a3
    7eec:	00042783          	lw	a5,0(s0)
    7ef0:	00d787b3          	add	a5,a5,a3
    7ef4:	00078067          	jr	a5
    7ef8:	06099e63          	bnez	s3,7f74 <__divsf3+0x1e8>
    7efc:	00400413          	li	s0,4
    7f00:	00000a93          	li	s5,0
    7f04:	00100b13          	li	s6,1
    7f08:	ee1ff06f          	j	7de8 <__divsf3+0x5c>
    7f0c:	04099c63          	bnez	s3,7f64 <__divsf3+0x1d8>
    7f10:	00800413          	li	s0,8
    7f14:	0ff00a93          	li	s5,255
    7f18:	00200b13          	li	s6,2
    7f1c:	ecdff06f          	j	7de8 <__divsf3+0x5c>
    7f20:	020a1a63          	bnez	s4,7f54 <__divsf3+0x1c8>
    7f24:	00246413          	ori	s0,s0,2
    7f28:	ffd40413          	addi	s0,s0,-3
    7f2c:	00b00693          	li	a3,11
    7f30:	00994733          	xor	a4,s2,s1
    7f34:	f686e4e3          	bltu	a3,s0,7e9c <__divsf3+0x110>
    7f38:	00005617          	auipc	a2,0x5
    7f3c:	0b860613          	addi	a2,a2,184 # cff0 <errpat+0x62c>
    7f40:	00241413          	slli	s0,s0,0x2
    7f44:	00c40433          	add	s0,s0,a2
    7f48:	00042683          	lw	a3,0(s0)
    7f4c:	00c686b3          	add	a3,a3,a2
    7f50:	00068067          	jr	a3
    7f54:	00346413          	ori	s0,s0,3
    7f58:	0ff00793          	li	a5,255
    7f5c:	00300613          	li	a2,3
    7f60:	ebdff06f          	j	7e1c <__divsf3+0x90>
    7f64:	00c00413          	li	s0,12
    7f68:	0ff00a93          	li	s5,255
    7f6c:	00300b13          	li	s6,3
    7f70:	e79ff06f          	j	7de8 <__divsf3+0x5c>
    7f74:	00098513          	mv	a0,s3
    7f78:	00b12623          	sw	a1,12(sp)
    7f7c:	0c9000ef          	jal	ra,8844 <__clzsi2>
    7f80:	ffb50793          	addi	a5,a0,-5
    7f84:	00f999b3          	sll	s3,s3,a5
    7f88:	f8a00793          	li	a5,-118
    7f8c:	00c12583          	lw	a1,12(sp)
    7f90:	40a78ab3          	sub	s5,a5,a0
    7f94:	00000413          	li	s0,0
    7f98:	00000b13          	li	s6,0
    7f9c:	e4dff06f          	j	7de8 <__divsf3+0x5c>
    7fa0:	000a0513          	mv	a0,s4
    7fa4:	0a1000ef          	jal	ra,8844 <__clzsi2>
    7fa8:	ffb50793          	addi	a5,a0,-5
    7fac:	00fa1a33          	sll	s4,s4,a5
    7fb0:	f8a00793          	li	a5,-118
    7fb4:	40a787b3          	sub	a5,a5,a0
    7fb8:	00000613          	li	a2,0
    7fbc:	e61ff06f          	j	7e1c <__divsf3+0x90>
    7fc0:	f01a8a93          	addi	s5,s5,-255
    7fc4:	00200793          	li	a5,2
    7fc8:	00090513          	mv	a0,s2
    7fcc:	eafb1ee3          	bne	s6,a5,7e88 <__divsf3+0xfc>
    7fd0:	00050713          	mv	a4,a0
    7fd4:	0ff00793          	li	a5,255
    7fd8:	00000693          	li	a3,0
    7fdc:	e75ff06f          	j	7e50 <__divsf3+0xc4>
    7fe0:	00050713          	mv	a4,a0
    7fe4:	07fa8793          	addi	a5,s5,127
    7fe8:	04f05863          	blez	a5,8038 <__divsf3+0x2ac>
    7fec:	0079f693          	andi	a3,s3,7
    7ff0:	00068a63          	beqz	a3,8004 <__divsf3+0x278>
    7ff4:	00f9f693          	andi	a3,s3,15
    7ff8:	00400613          	li	a2,4
    7ffc:	00c68463          	beq	a3,a2,8004 <__divsf3+0x278>
    8000:	00498993          	addi	s3,s3,4
    8004:	080006b7          	lui	a3,0x8000
    8008:	00d9f6b3          	and	a3,s3,a3
    800c:	00068a63          	beqz	a3,8020 <__divsf3+0x294>
    8010:	f80007b7          	lui	a5,0xf8000
    8014:	fff78793          	addi	a5,a5,-1 # f7ffffff <_stack_top+0xf7fda7ff>
    8018:	00f9f9b3          	and	s3,s3,a5
    801c:	080a8793          	addi	a5,s5,128
    8020:	0fe00693          	li	a3,254
    8024:	e2f6c2e3          	blt	a3,a5,7e48 <__divsf3+0xbc>
    8028:	00699693          	slli	a3,s3,0x6
    802c:	0096d693          	srli	a3,a3,0x9
    8030:	0ff7f793          	zext.b	a5,a5
    8034:	e1dff06f          	j	7e50 <__divsf3+0xc4>
    8038:	00100613          	li	a2,1
    803c:	00078c63          	beqz	a5,8054 <__divsf3+0x2c8>
    8040:	40f60633          	sub	a2,a2,a5
    8044:	01b00593          	li	a1,27
    8048:	00000793          	li	a5,0
    804c:	00000693          	li	a3,0
    8050:	e0c5c0e3          	blt	a1,a2,7e50 <__divsf3+0xc4>
    8054:	09ea8693          	addi	a3,s5,158
    8058:	00d996b3          	sll	a3,s3,a3
    805c:	00d036b3          	snez	a3,a3
    8060:	00c9d7b3          	srl	a5,s3,a2
    8064:	00d7e7b3          	or	a5,a5,a3
    8068:	0077f693          	andi	a3,a5,7
    806c:	00068a63          	beqz	a3,8080 <__divsf3+0x2f4>
    8070:	00f7f693          	andi	a3,a5,15
    8074:	00400613          	li	a2,4
    8078:	00c68463          	beq	a3,a2,8080 <__divsf3+0x2f4>
    807c:	00478793          	addi	a5,a5,4
    8080:	040006b7          	lui	a3,0x4000
    8084:	00d7f6b3          	and	a3,a5,a3
    8088:	0e068a63          	beqz	a3,817c <__divsf3+0x3f0>
    808c:	00100793          	li	a5,1
    8090:	00000693          	li	a3,0
    8094:	dbdff06f          	j	7e50 <__divsf3+0xc4>
    8098:	000106b7          	lui	a3,0x10
    809c:	005a1813          	slli	a6,s4,0x5
    80a0:	fff68693          	addi	a3,a3,-1 # ffff <seed1_volatile+0x265f>
    80a4:	01085593          	srli	a1,a6,0x10
    80a8:	00d876b3          	and	a3,a6,a3
    80ac:	0949f863          	bgeu	s3,s4,813c <__divsf3+0x3b0>
    80b0:	02b9d633          	divu	a2,s3,a1
    80b4:	00098793          	mv	a5,s3
    80b8:	fffa8a93          	addi	s5,s5,-1
    80bc:	00000993          	li	s3,0
    80c0:	02d60533          	mul	a0,a2,a3
    80c4:	02b7f7b3          	remu	a5,a5,a1
    80c8:	01079793          	slli	a5,a5,0x10
    80cc:	0137e7b3          	or	a5,a5,s3
    80d0:	00a7fa63          	bgeu	a5,a0,80e4 <__divsf3+0x358>
    80d4:	00f807b3          	add	a5,a6,a5
    80d8:	fff60893          	addi	a7,a2,-1
    80dc:	0907f863          	bgeu	a5,a6,816c <__divsf3+0x3e0>
    80e0:	00088613          	mv	a2,a7
    80e4:	40a787b3          	sub	a5,a5,a0
    80e8:	02b7d533          	divu	a0,a5,a1
    80ec:	02b7f7b3          	remu	a5,a5,a1
    80f0:	02d506b3          	mul	a3,a0,a3
    80f4:	01079793          	slli	a5,a5,0x10
    80f8:	02d7f663          	bgeu	a5,a3,8124 <__divsf3+0x398>
    80fc:	010785b3          	add	a1,a5,a6
    8100:	00f5b8b3          	sltu	a7,a1,a5
    8104:	fff50313          	addi	t1,a0,-1
    8108:	00058793          	mv	a5,a1
    810c:	00089a63          	bnez	a7,8120 <__divsf3+0x394>
    8110:	00d5f863          	bgeu	a1,a3,8120 <__divsf3+0x394>
    8114:	ffe50513          	addi	a0,a0,-2
    8118:	010587b3          	add	a5,a1,a6
    811c:	0080006f          	j	8124 <__divsf3+0x398>
    8120:	00030513          	mv	a0,t1
    8124:	01061613          	slli	a2,a2,0x10
    8128:	40d787b3          	sub	a5,a5,a3
    812c:	00a66633          	or	a2,a2,a0
    8130:	00f037b3          	snez	a5,a5
    8134:	00f669b3          	or	s3,a2,a5
    8138:	eadff06f          	j	7fe4 <__divsf3+0x258>
    813c:	0019d793          	srli	a5,s3,0x1
    8140:	02b7d633          	divu	a2,a5,a1
    8144:	01f99993          	slli	s3,s3,0x1f
    8148:	0109d993          	srli	s3,s3,0x10
    814c:	02d60533          	mul	a0,a2,a3
    8150:	f75ff06f          	j	80c4 <__divsf3+0x338>
    8154:	00048513          	mv	a0,s1
    8158:	00050713          	mv	a4,a0
    815c:	d41ff06f          	j	7e9c <__divsf3+0x110>
    8160:	00000713          	li	a4,0
    8164:	004006b7          	lui	a3,0x400
    8168:	ce9ff06f          	j	7e50 <__divsf3+0xc4>
    816c:	f6a7fae3          	bgeu	a5,a0,80e0 <__divsf3+0x354>
    8170:	ffe60613          	addi	a2,a2,-2
    8174:	010787b3          	add	a5,a5,a6
    8178:	f6dff06f          	j	80e4 <__divsf3+0x358>
    817c:	00679793          	slli	a5,a5,0x6
    8180:	0097d693          	srli	a3,a5,0x9
    8184:	00000793          	li	a5,0
    8188:	cc9ff06f          	j	7e50 <__divsf3+0xc4>
    818c:	00048513          	mv	a0,s1
    8190:	e41ff06f          	j	7fd0 <__divsf3+0x244>

00008194 <__mulsf3>:
    8194:	fd010113          	addi	sp,sp,-48
    8198:	01755793          	srli	a5,a0,0x17
    819c:	01412c23          	sw	s4,24(sp)
    81a0:	01512a23          	sw	s5,20(sp)
    81a4:	00951713          	slli	a4,a0,0x9
    81a8:	02112623          	sw	ra,44(sp)
    81ac:	02812423          	sw	s0,40(sp)
    81b0:	02912223          	sw	s1,36(sp)
    81b4:	03212023          	sw	s2,32(sp)
    81b8:	01312e23          	sw	s3,28(sp)
    81bc:	01612823          	sw	s6,16(sp)
    81c0:	0ff7f793          	zext.b	a5,a5
    81c4:	00975a93          	srli	s5,a4,0x9
    81c8:	01f55a13          	srli	s4,a0,0x1f
    81cc:	18078263          	beqz	a5,8350 <__mulsf3+0x1bc>
    81d0:	0ff00713          	li	a4,255
    81d4:	18e78863          	beq	a5,a4,8364 <__mulsf3+0x1d0>
    81d8:	003a9713          	slli	a4,s5,0x3
    81dc:	040006b7          	lui	a3,0x4000
    81e0:	00d76ab3          	or	s5,a4,a3
    81e4:	f8178493          	addi	s1,a5,-127
    81e8:	00000913          	li	s2,0
    81ec:	00000b13          	li	s6,0
    81f0:	0175d793          	srli	a5,a1,0x17
    81f4:	00959413          	slli	s0,a1,0x9
    81f8:	0ff7f793          	zext.b	a5,a5
    81fc:	00945413          	srli	s0,s0,0x9
    8200:	01f5d993          	srli	s3,a1,0x1f
    8204:	12078663          	beqz	a5,8330 <__mulsf3+0x19c>
    8208:	0ff00713          	li	a4,255
    820c:	08e78a63          	beq	a5,a4,82a0 <__mulsf3+0x10c>
    8210:	f8178793          	addi	a5,a5,-127
    8214:	00978533          	add	a0,a5,s1
    8218:	00341413          	slli	s0,s0,0x3
    821c:	04000737          	lui	a4,0x4000
    8220:	00a00793          	li	a5,10
    8224:	00e46433          	or	s0,s0,a4
    8228:	00000693          	li	a3,0
    822c:	00150493          	addi	s1,a0,1
    8230:	1727cc63          	blt	a5,s2,83a8 <__mulsf3+0x214>
    8234:	013a45b3          	xor	a1,s4,s3
    8238:	00200713          	li	a4,2
    823c:	00058813          	mv	a6,a1
    8240:	09274263          	blt	a4,s2,82c4 <__mulsf3+0x130>
    8244:	fff90913          	addi	s2,s2,-1
    8248:	00100613          	li	a2,1
    824c:	1d266663          	bltu	a2,s2,8418 <__mulsf3+0x284>
    8250:	12e68463          	beq	a3,a4,8378 <__mulsf3+0x1e4>
    8254:	00100793          	li	a5,1
    8258:	00080593          	mv	a1,a6
    825c:	08f69e63          	bne	a3,a5,82f8 <__mulsf3+0x164>
    8260:	00000793          	li	a5,0
    8264:	00000713          	li	a4,0
    8268:	02c12083          	lw	ra,44(sp)
    826c:	02812403          	lw	s0,40(sp)
    8270:	01779513          	slli	a0,a5,0x17
    8274:	00e56533          	or	a0,a0,a4
    8278:	01f59793          	slli	a5,a1,0x1f
    827c:	02412483          	lw	s1,36(sp)
    8280:	02012903          	lw	s2,32(sp)
    8284:	01c12983          	lw	s3,28(sp)
    8288:	01812a03          	lw	s4,24(sp)
    828c:	01412a83          	lw	s5,20(sp)
    8290:	01012b03          	lw	s6,16(sp)
    8294:	00f56533          	or	a0,a0,a5
    8298:	03010113          	addi	sp,sp,48
    829c:	00008067          	ret
    82a0:	0ff48513          	addi	a0,s1,255 # 8000ff <_stack_top+0x7da8ff>
    82a4:	0e040263          	beqz	s0,8388 <__mulsf3+0x1f4>
    82a8:	013a45b3          	xor	a1,s4,s3
    82ac:	00396913          	ori	s2,s2,3
    82b0:	00a00713          	li	a4,10
    82b4:	00058813          	mv	a6,a1
    82b8:	10048493          	addi	s1,s1,256
    82bc:	2b274e63          	blt	a4,s2,8578 <__mulsf3+0x3e4>
    82c0:	00300693          	li	a3,3
    82c4:	00100713          	li	a4,1
    82c8:	01271733          	sll	a4,a4,s2
    82cc:	53077613          	andi	a2,a4,1328
    82d0:	02060863          	beqz	a2,8300 <__mulsf3+0x16c>
    82d4:	00200793          	li	a5,2
    82d8:	0afb0063          	beq	s6,a5,8378 <__mulsf3+0x1e4>
    82dc:	00300793          	li	a5,3
    82e0:	04fb0063          	beq	s6,a5,8320 <__mulsf3+0x18c>
    82e4:	000b0693          	mv	a3,s6
    82e8:	00100793          	li	a5,1
    82ec:	000a8413          	mv	s0,s5
    82f0:	00080593          	mv	a1,a6
    82f4:	f6f686e3          	beq	a3,a5,8260 <__mulsf3+0xcc>
    82f8:	00048513          	mv	a0,s1
    82fc:	1ac0006f          	j	84a8 <__mulsf3+0x314>
    8300:	24077793          	andi	a5,a4,576
    8304:	00079e63          	bnez	a5,8320 <__mulsf3+0x18c>
    8308:	08877713          	andi	a4,a4,136
    830c:	10070663          	beqz	a4,8418 <__mulsf3+0x284>
    8310:	00098813          	mv	a6,s3
    8314:	00040a93          	mv	s5,s0
    8318:	00068b13          	mv	s6,a3
    831c:	fb9ff06f          	j	82d4 <__mulsf3+0x140>
    8320:	00000593          	li	a1,0
    8324:	0ff00793          	li	a5,255
    8328:	00400737          	lui	a4,0x400
    832c:	f3dff06f          	j	8268 <__mulsf3+0xd4>
    8330:	0a041e63          	bnez	s0,83ec <__mulsf3+0x258>
    8334:	00048513          	mv	a0,s1
    8338:	00196913          	ori	s2,s2,1
    833c:	00a00793          	li	a5,10
    8340:	00100693          	li	a3,1
    8344:	00150493          	addi	s1,a0,1
    8348:	ef27d6e3          	bge	a5,s2,8234 <__mulsf3+0xa0>
    834c:	05c0006f          	j	83a8 <__mulsf3+0x214>
    8350:	060a9863          	bnez	s5,83c0 <__mulsf3+0x22c>
    8354:	00400913          	li	s2,4
    8358:	00000493          	li	s1,0
    835c:	00100b13          	li	s6,1
    8360:	e91ff06f          	j	81f0 <__mulsf3+0x5c>
    8364:	040a9663          	bnez	s5,83b0 <__mulsf3+0x21c>
    8368:	00800913          	li	s2,8
    836c:	0ff00493          	li	s1,255
    8370:	00200b13          	li	s6,2
    8374:	e7dff06f          	j	81f0 <__mulsf3+0x5c>
    8378:	00080593          	mv	a1,a6
    837c:	0ff00793          	li	a5,255
    8380:	00000713          	li	a4,0
    8384:	ee5ff06f          	j	8268 <__mulsf3+0xd4>
    8388:	00296913          	ori	s2,s2,2
    838c:	00a00793          	li	a5,10
    8390:	10048493          	addi	s1,s1,256
    8394:	00e00713          	li	a4,14
    8398:	00200693          	li	a3,2
    839c:	e927dce3          	bge	a5,s2,8234 <__mulsf3+0xa0>
    83a0:	00b00793          	li	a5,11
    83a4:	f6f706e3          	beq	a4,a5,8310 <__mulsf3+0x17c>
    83a8:	000a0813          	mv	a6,s4
    83ac:	f29ff06f          	j	82d4 <__mulsf3+0x140>
    83b0:	00c00913          	li	s2,12
    83b4:	0ff00493          	li	s1,255
    83b8:	00300b13          	li	s6,3
    83bc:	e35ff06f          	j	81f0 <__mulsf3+0x5c>
    83c0:	000a8513          	mv	a0,s5
    83c4:	00b12623          	sw	a1,12(sp)
    83c8:	47c000ef          	jal	ra,8844 <__clzsi2>
    83cc:	ffb50793          	addi	a5,a0,-5
    83d0:	00fa9ab3          	sll	s5,s5,a5
    83d4:	f8a00793          	li	a5,-118
    83d8:	00c12583          	lw	a1,12(sp)
    83dc:	40a784b3          	sub	s1,a5,a0
    83e0:	00000913          	li	s2,0
    83e4:	00000b13          	li	s6,0
    83e8:	e09ff06f          	j	81f0 <__mulsf3+0x5c>
    83ec:	00040513          	mv	a0,s0
    83f0:	454000ef          	jal	ra,8844 <__clzsi2>
    83f4:	40a487b3          	sub	a5,s1,a0
    83f8:	ffb50713          	addi	a4,a0,-5
    83fc:	f8a78513          	addi	a0,a5,-118
    8400:	00a00793          	li	a5,10
    8404:	00e41433          	sll	s0,s0,a4
    8408:	00000693          	li	a3,0
    840c:	00150493          	addi	s1,a0,1
    8410:	e327d2e3          	bge	a5,s2,8234 <__mulsf3+0xa0>
    8414:	f95ff06f          	j	83a8 <__mulsf3+0x214>
    8418:	000108b7          	lui	a7,0x10
    841c:	fff88793          	addi	a5,a7,-1 # ffff <seed1_volatile+0x265f>
    8420:	010ad613          	srli	a2,s5,0x10
    8424:	01045813          	srli	a6,s0,0x10
    8428:	00fafab3          	and	s5,s5,a5
    842c:	00f477b3          	and	a5,s0,a5
    8430:	035786b3          	mul	a3,a5,s5
    8434:	02f607b3          	mul	a5,a2,a5
    8438:	0106d713          	srli	a4,a3,0x10
    843c:	03580ab3          	mul	s5,a6,s5
    8440:	00fa8ab3          	add	s5,s5,a5
    8444:	01570733          	add	a4,a4,s5
    8448:	03060633          	mul	a2,a2,a6
    844c:	00f77463          	bgeu	a4,a5,8454 <__mulsf3+0x2c0>
    8450:	01160633          	add	a2,a2,a7
    8454:	00010837          	lui	a6,0x10
    8458:	fff80813          	addi	a6,a6,-1 # ffff <seed1_volatile+0x265f>
    845c:	010777b3          	and	a5,a4,a6
    8460:	0106f6b3          	and	a3,a3,a6
    8464:	01079793          	slli	a5,a5,0x10
    8468:	00d787b3          	add	a5,a5,a3
    846c:	00679693          	slli	a3,a5,0x6
    8470:	01075413          	srli	s0,a4,0x10
    8474:	01a7d793          	srli	a5,a5,0x1a
    8478:	00d03733          	snez	a4,a3
    847c:	00c40433          	add	s0,s0,a2
    8480:	00f767b3          	or	a5,a4,a5
    8484:	00641413          	slli	s0,s0,0x6
    8488:	00f46433          	or	s0,s0,a5
    848c:	080007b7          	lui	a5,0x8000
    8490:	00f477b3          	and	a5,s0,a5
    8494:	00078a63          	beqz	a5,84a8 <__mulsf3+0x314>
    8498:	00145793          	srli	a5,s0,0x1
    849c:	00147413          	andi	s0,s0,1
    84a0:	0087e433          	or	s0,a5,s0
    84a4:	00048513          	mv	a0,s1
    84a8:	07f50793          	addi	a5,a0,127
    84ac:	04f05863          	blez	a5,84fc <__mulsf3+0x368>
    84b0:	00747713          	andi	a4,s0,7
    84b4:	00070a63          	beqz	a4,84c8 <__mulsf3+0x334>
    84b8:	00f47713          	andi	a4,s0,15
    84bc:	00400693          	li	a3,4
    84c0:	00d70463          	beq	a4,a3,84c8 <__mulsf3+0x334>
    84c4:	00440413          	addi	s0,s0,4
    84c8:	08000737          	lui	a4,0x8000
    84cc:	00e47733          	and	a4,s0,a4
    84d0:	00070a63          	beqz	a4,84e4 <__mulsf3+0x350>
    84d4:	f80007b7          	lui	a5,0xf8000
    84d8:	fff78793          	addi	a5,a5,-1 # f7ffffff <_stack_top+0xf7fda7ff>
    84dc:	00f47433          	and	s0,s0,a5
    84e0:	08050793          	addi	a5,a0,128
    84e4:	0fe00713          	li	a4,254
    84e8:	06f74a63          	blt	a4,a5,855c <__mulsf3+0x3c8>
    84ec:	00641713          	slli	a4,s0,0x6
    84f0:	00975713          	srli	a4,a4,0x9
    84f4:	0ff7f793          	zext.b	a5,a5
    84f8:	d71ff06f          	j	8268 <__mulsf3+0xd4>
    84fc:	00100693          	li	a3,1
    8500:	00078c63          	beqz	a5,8518 <__mulsf3+0x384>
    8504:	40f686b3          	sub	a3,a3,a5
    8508:	01b00613          	li	a2,27
    850c:	00000793          	li	a5,0
    8510:	00000713          	li	a4,0
    8514:	d4d64ae3          	blt	a2,a3,8268 <__mulsf3+0xd4>
    8518:	09e50713          	addi	a4,a0,158
    851c:	00e41733          	sll	a4,s0,a4
    8520:	00e03733          	snez	a4,a4
    8524:	00d457b3          	srl	a5,s0,a3
    8528:	00e7e7b3          	or	a5,a5,a4
    852c:	0077f713          	andi	a4,a5,7
    8530:	00070a63          	beqz	a4,8544 <__mulsf3+0x3b0>
    8534:	00f7f713          	andi	a4,a5,15
    8538:	00400693          	li	a3,4
    853c:	00d70463          	beq	a4,a3,8544 <__mulsf3+0x3b0>
    8540:	00478793          	addi	a5,a5,4
    8544:	04000737          	lui	a4,0x4000
    8548:	00e7f733          	and	a4,a5,a4
    854c:	00070e63          	beqz	a4,8568 <__mulsf3+0x3d4>
    8550:	00100793          	li	a5,1
    8554:	00000713          	li	a4,0
    8558:	d11ff06f          	j	8268 <__mulsf3+0xd4>
    855c:	0ff00793          	li	a5,255
    8560:	00000713          	li	a4,0
    8564:	d05ff06f          	j	8268 <__mulsf3+0xd4>
    8568:	00679793          	slli	a5,a5,0x6
    856c:	0097d713          	srli	a4,a5,0x9
    8570:	00000793          	li	a5,0
    8574:	cf5ff06f          	j	8268 <__mulsf3+0xd4>
    8578:	00f00693          	li	a3,15
    857c:	00000593          	li	a1,0
    8580:	00400737          	lui	a4,0x400
    8584:	ced902e3          	beq	s2,a3,8268 <__mulsf3+0xd4>
    8588:	00b00713          	li	a4,11
    858c:	00300693          	li	a3,3
    8590:	e11ff06f          	j	83a0 <__mulsf3+0x20c>

00008594 <__floatundisf>:
    8594:	ff010113          	addi	sp,sp,-16
    8598:	00112623          	sw	ra,12(sp)
    859c:	00812423          	sw	s0,8(sp)
    85a0:	00912223          	sw	s1,4(sp)
    85a4:	00b567b3          	or	a5,a0,a1
    85a8:	0a078e63          	beqz	a5,8664 <__floatundisf+0xd0>
    85ac:	00050413          	mv	s0,a0
    85b0:	00058493          	mv	s1,a1
    85b4:	0c058a63          	beqz	a1,8688 <__floatundisf+0xf4>
    85b8:	00058513          	mv	a0,a1
    85bc:	288000ef          	jal	ra,8844 <__clzsi2>
    85c0:	00050693          	mv	a3,a0
    85c4:	0be00513          	li	a0,190
    85c8:	40d50733          	sub	a4,a0,a3
    85cc:	ffb68613          	addi	a2,a3,-5 # 3fffffb <_stack_top+0x3fda7fb>
    85d0:	01b68793          	addi	a5,a3,27
    85d4:	10064c63          	bltz	a2,86ec <__floatundisf+0x158>
    85d8:	00c41633          	sll	a2,s0,a2
    85dc:	00000793          	li	a5,0
    85e0:	02500593          	li	a1,37
    85e4:	40d585b3          	sub	a1,a1,a3
    85e8:	00c7e7b3          	or	a5,a5,a2
    85ec:	fe058613          	addi	a2,a1,-32
    85f0:	00f037b3          	snez	a5,a5
    85f4:	10064c63          	bltz	a2,870c <__floatundisf+0x178>
    85f8:	00c4d4b3          	srl	s1,s1,a2
    85fc:	0097e7b3          	or	a5,a5,s1
    8600:	fc000637          	lui	a2,0xfc000
    8604:	fff60613          	addi	a2,a2,-1 # fbffffff <_stack_top+0xfbfda7ff>
    8608:	0077f593          	andi	a1,a5,7
    860c:	00c7f433          	and	s0,a5,a2
    8610:	02058663          	beqz	a1,863c <__floatundisf+0xa8>
    8614:	00f7f793          	andi	a5,a5,15
    8618:	00400593          	li	a1,4
    861c:	02b78063          	beq	a5,a1,863c <__floatundisf+0xa8>
    8620:	00440413          	addi	s0,s0,4
    8624:	040007b7          	lui	a5,0x4000
    8628:	00f477b3          	and	a5,s0,a5
    862c:	00078863          	beqz	a5,863c <__floatundisf+0xa8>
    8630:	0bf00513          	li	a0,191
    8634:	00c47433          	and	s0,s0,a2
    8638:	40d50733          	sub	a4,a0,a3
    863c:	00641413          	slli	s0,s0,0x6
    8640:	0ff77513          	zext.b	a0,a4
    8644:	00945413          	srli	s0,s0,0x9
    8648:	01751513          	slli	a0,a0,0x17
    864c:	00c12083          	lw	ra,12(sp)
    8650:	00856533          	or	a0,a0,s0
    8654:	00812403          	lw	s0,8(sp)
    8658:	00412483          	lw	s1,4(sp)
    865c:	01010113          	addi	sp,sp,16
    8660:	00008067          	ret
    8664:	00000513          	li	a0,0
    8668:	00000413          	li	s0,0
    866c:	01751513          	slli	a0,a0,0x17
    8670:	00c12083          	lw	ra,12(sp)
    8674:	00856533          	or	a0,a0,s0
    8678:	00812403          	lw	s0,8(sp)
    867c:	00412483          	lw	s1,4(sp)
    8680:	01010113          	addi	sp,sp,16
    8684:	00008067          	ret
    8688:	1bc000ef          	jal	ra,8844 <__clzsi2>
    868c:	02050693          	addi	a3,a0,32
    8690:	0be00713          	li	a4,190
    8694:	40d70733          	sub	a4,a4,a3
    8698:	09600613          	li	a2,150
    869c:	00040793          	mv	a5,s0
    86a0:	08e64463          	blt	a2,a4,8728 <__floatundisf+0x194>
    86a4:	02800793          	li	a5,40
    86a8:	02f68a63          	beq	a3,a5,86dc <__floatundisf+0x148>
    86ac:	ff850513          	addi	a0,a0,-8
    86b0:	00a41433          	sll	s0,s0,a0
    86b4:	00941413          	slli	s0,s0,0x9
    86b8:	0ff77513          	zext.b	a0,a4
    86bc:	00945413          	srli	s0,s0,0x9
    86c0:	01751513          	slli	a0,a0,0x17
    86c4:	00c12083          	lw	ra,12(sp)
    86c8:	00856533          	or	a0,a0,s0
    86cc:	00812403          	lw	s0,8(sp)
    86d0:	00412483          	lw	s1,4(sp)
    86d4:	01010113          	addi	sp,sp,16
    86d8:	00008067          	ret
    86dc:	00941413          	slli	s0,s0,0x9
    86e0:	00945413          	srli	s0,s0,0x9
    86e4:	09600513          	li	a0,150
    86e8:	f85ff06f          	j	866c <__floatundisf+0xd8>
    86ec:	01f00613          	li	a2,31
    86f0:	40f60633          	sub	a2,a2,a5
    86f4:	00145593          	srli	a1,s0,0x1
    86f8:	00c5d5b3          	srl	a1,a1,a2
    86fc:	00f49633          	sll	a2,s1,a5
    8700:	00c5e633          	or	a2,a1,a2
    8704:	00f417b3          	sll	a5,s0,a5
    8708:	ed9ff06f          	j	85e0 <__floatundisf+0x4c>
    870c:	01f00613          	li	a2,31
    8710:	00149493          	slli	s1,s1,0x1
    8714:	40b60633          	sub	a2,a2,a1
    8718:	00c49633          	sll	a2,s1,a2
    871c:	00b454b3          	srl	s1,s0,a1
    8720:	009664b3          	or	s1,a2,s1
    8724:	ed9ff06f          	j	85fc <__floatundisf+0x68>
    8728:	09900613          	li	a2,153
    872c:	eae640e3          	blt	a2,a4,85cc <__floatundisf+0x38>
    8730:	02500613          	li	a2,37
    8734:	ffb50513          	addi	a0,a0,-5
    8738:	00c68663          	beq	a3,a2,8744 <__floatundisf+0x1b0>
    873c:	00a417b3          	sll	a5,s0,a0
    8740:	ec1ff06f          	j	8600 <__floatundisf+0x6c>
    8744:	09900713          	li	a4,153
    8748:	eb9ff06f          	j	8600 <__floatundisf+0x6c>

0000874c <__extendsfdf2>:
    874c:	01755793          	srli	a5,a0,0x17
    8750:	0ff7f793          	zext.b	a5,a5
    8754:	ff010113          	addi	sp,sp,-16
    8758:	00178713          	addi	a4,a5,1 # 4000001 <_stack_top+0x3fda801>
    875c:	00812423          	sw	s0,8(sp)
    8760:	00912223          	sw	s1,4(sp)
    8764:	00112623          	sw	ra,12(sp)
    8768:	00951493          	slli	s1,a0,0x9
    876c:	0fe77713          	andi	a4,a4,254
    8770:	0094d493          	srli	s1,s1,0x9
    8774:	01f55413          	srli	s0,a0,0x1f
    8778:	02070e63          	beqz	a4,87b4 <__extendsfdf2+0x68>
    877c:	0034d713          	srli	a4,s1,0x3
    8780:	38078793          	addi	a5,a5,896
    8784:	01d49493          	slli	s1,s1,0x1d
    8788:	01f41513          	slli	a0,s0,0x1f
    878c:	00c12083          	lw	ra,12(sp)
    8790:	00812403          	lw	s0,8(sp)
    8794:	01479793          	slli	a5,a5,0x14
    8798:	00e7e7b3          	or	a5,a5,a4
    879c:	00a7e7b3          	or	a5,a5,a0
    87a0:	00078593          	mv	a1,a5
    87a4:	00048513          	mv	a0,s1
    87a8:	00412483          	lw	s1,4(sp)
    87ac:	01010113          	addi	sp,sp,16
    87b0:	00008067          	ret
    87b4:	04079263          	bnez	a5,87f8 <__extendsfdf2+0xac>
    87b8:	06048263          	beqz	s1,881c <__extendsfdf2+0xd0>
    87bc:	00048513          	mv	a0,s1
    87c0:	084000ef          	jal	ra,8844 <__clzsi2>
    87c4:	00a00793          	li	a5,10
    87c8:	06a7c663          	blt	a5,a0,8834 <__extendsfdf2+0xe8>
    87cc:	00b00713          	li	a4,11
    87d0:	40a70733          	sub	a4,a4,a0
    87d4:	01550793          	addi	a5,a0,21
    87d8:	00e4d733          	srl	a4,s1,a4
    87dc:	00f494b3          	sll	s1,s1,a5
    87e0:	38900793          	li	a5,905
    87e4:	00c71713          	slli	a4,a4,0xc
    87e8:	40a787b3          	sub	a5,a5,a0
    87ec:	00c75713          	srli	a4,a4,0xc
    87f0:	7ff7f793          	andi	a5,a5,2047
    87f4:	f95ff06f          	j	8788 <__extendsfdf2+0x3c>
    87f8:	02048863          	beqz	s1,8828 <__extendsfdf2+0xdc>
    87fc:	0034d713          	srli	a4,s1,0x3
    8800:	000807b7          	lui	a5,0x80
    8804:	00f76733          	or	a4,a4,a5
    8808:	00c71713          	slli	a4,a4,0xc
    880c:	01d49493          	slli	s1,s1,0x1d
    8810:	00c75713          	srli	a4,a4,0xc
    8814:	7ff00793          	li	a5,2047
    8818:	f71ff06f          	j	8788 <__extendsfdf2+0x3c>
    881c:	00000793          	li	a5,0
    8820:	00000713          	li	a4,0
    8824:	f65ff06f          	j	8788 <__extendsfdf2+0x3c>
    8828:	7ff00793          	li	a5,2047
    882c:	00000713          	li	a4,0
    8830:	f59ff06f          	j	8788 <__extendsfdf2+0x3c>
    8834:	ff550713          	addi	a4,a0,-11
    8838:	00e49733          	sll	a4,s1,a4
    883c:	00000493          	li	s1,0
    8840:	fa1ff06f          	j	87e0 <__extendsfdf2+0x94>

00008844 <__clzsi2>:
    8844:	000107b7          	lui	a5,0x10
    8848:	02f57a63          	bgeu	a0,a5,887c <__clzsi2+0x38>
    884c:	10053793          	sltiu	a5,a0,256
    8850:	0017c793          	xori	a5,a5,1
    8854:	00379793          	slli	a5,a5,0x3
    8858:	02000713          	li	a4,32
    885c:	40f70733          	sub	a4,a4,a5
    8860:	00f55533          	srl	a0,a0,a5
    8864:	00004797          	auipc	a5,0x4
    8868:	7bc78793          	addi	a5,a5,1980 # d020 <__clz_tab>
    886c:	00a787b3          	add	a5,a5,a0
    8870:	0007c503          	lbu	a0,0(a5)
    8874:	40a70533          	sub	a0,a4,a0
    8878:	00008067          	ret
    887c:	010007b7          	lui	a5,0x1000
    8880:	02f57463          	bgeu	a0,a5,88a8 <__clzsi2+0x64>
    8884:	01000793          	li	a5,16
    8888:	00f55533          	srl	a0,a0,a5
    888c:	00004797          	auipc	a5,0x4
    8890:	79478793          	addi	a5,a5,1940 # d020 <__clz_tab>
    8894:	00a787b3          	add	a5,a5,a0
    8898:	0007c503          	lbu	a0,0(a5)
    889c:	01000713          	li	a4,16
    88a0:	40a70533          	sub	a0,a4,a0
    88a4:	00008067          	ret
    88a8:	01800793          	li	a5,24
    88ac:	00f55533          	srl	a0,a0,a5
    88b0:	00004797          	auipc	a5,0x4
    88b4:	77078793          	addi	a5,a5,1904 # d020 <__clz_tab>
    88b8:	00a787b3          	add	a5,a5,a0
    88bc:	0007c503          	lbu	a0,0(a5)
    88c0:	00800713          	li	a4,8
    88c4:	40a70533          	sub	a0,a4,a0
    88c8:	00008067          	ret

Disassembly of section .rodata:

0000c800 <list_known_crc-0x158>:
    c800:	0984                	.2byte	0x984
    c802:	0000                	.2byte	0x0
    c804:	0520                	.2byte	0x520
    c806:	0000                	.2byte	0x0
    c808:	0990                	.2byte	0x990
    c80a:	0000                	.2byte	0x0
    c80c:	0520                	.2byte	0x520
    c80e:	0000                	.2byte	0x0
    c810:	0520                	.2byte	0x520
    c812:	0000                	.2byte	0x0
    c814:	0520                	.2byte	0x520
    c816:	0000                	.2byte	0x0
    c818:	0520                	.2byte	0x520
    c81a:	0000                	.2byte	0x0
    c81c:	09b8                	.2byte	0x9b8
    c81e:	0000                	.2byte	0x0
    c820:	0520                	.2byte	0x520
    c822:	0000                	.2byte	0x0
    c824:	0520                	.2byte	0x520
    c826:	0000                	.2byte	0x0
    c828:	0500                	.2byte	0x500
    c82a:	0000                	.2byte	0x0
    c82c:	09d4                	.2byte	0x9d4
    c82e:	0000                	.2byte	0x0
    c830:	0520                	.2byte	0x520
    c832:	0000                	.2byte	0x0
    c834:	0500                	.2byte	0x500
    c836:	0000                	.2byte	0x0
    c838:	054c                	.2byte	0x54c
    c83a:	0000                	.2byte	0x0
    c83c:	054c                	.2byte	0x54c
    c83e:	0000                	.2byte	0x0
    c840:	054c                	.2byte	0x54c
    c842:	0000                	.2byte	0x0
    c844:	054c                	.2byte	0x54c
    c846:	0000                	.2byte	0x0
    c848:	054c                	.2byte	0x54c
    c84a:	0000                	.2byte	0x0
    c84c:	054c                	.2byte	0x54c
    c84e:	0000                	.2byte	0x0
    c850:	054c                	.2byte	0x54c
    c852:	0000                	.2byte	0x0
    c854:	054c                	.2byte	0x54c
    c856:	0000                	.2byte	0x0
    c858:	054c                	.2byte	0x54c
    c85a:	0000                	.2byte	0x0
    c85c:	0520                	.2byte	0x520
    c85e:	0000                	.2byte	0x0
    c860:	0520                	.2byte	0x520
    c862:	0000                	.2byte	0x0
    c864:	0520                	.2byte	0x520
    c866:	0000                	.2byte	0x0
    c868:	0520                	.2byte	0x520
    c86a:	0000                	.2byte	0x0
    c86c:	0520                	.2byte	0x520
    c86e:	0000                	.2byte	0x0
    c870:	0520                	.2byte	0x520
    c872:	0000                	.2byte	0x0
    c874:	0520                	.2byte	0x520
    c876:	0000                	.2byte	0x0
    c878:	0520                	.2byte	0x520
    c87a:	0000                	.2byte	0x0
    c87c:	0520                	.2byte	0x520
    c87e:	0000                	.2byte	0x0
    c880:	0520                	.2byte	0x520
    c882:	0000                	.2byte	0x0
    c884:	0520                	.2byte	0x520
    c886:	0000                	.2byte	0x0
    c888:	0520                	.2byte	0x520
    c88a:	0000                	.2byte	0x0
    c88c:	0520                	.2byte	0x520
    c88e:	0000                	.2byte	0x0
    c890:	0520                	.2byte	0x520
    c892:	0000                	.2byte	0x0
    c894:	0520                	.2byte	0x520
    c896:	0000                	.2byte	0x0
    c898:	0520                	.2byte	0x520
    c89a:	0000                	.2byte	0x0
    c89c:	0520                	.2byte	0x520
    c89e:	0000                	.2byte	0x0
    c8a0:	0520                	.2byte	0x520
    c8a2:	0000                	.2byte	0x0
    c8a4:	0520                	.2byte	0x520
    c8a6:	0000                	.2byte	0x0
    c8a8:	0520                	.2byte	0x520
    c8aa:	0000                	.2byte	0x0
    c8ac:	0520                	.2byte	0x520
    c8ae:	0000                	.2byte	0x0
    c8b0:	0520                	.2byte	0x520
    c8b2:	0000                	.2byte	0x0
    c8b4:	0520                	.2byte	0x520
    c8b6:	0000                	.2byte	0x0
    c8b8:	0520                	.2byte	0x520
    c8ba:	0000                	.2byte	0x0
    c8bc:	0520                	.2byte	0x520
    c8be:	0000                	.2byte	0x0
    c8c0:	0520                	.2byte	0x520
    c8c2:	0000                	.2byte	0x0
    c8c4:	0520                	.2byte	0x520
    c8c6:	0000                	.2byte	0x0
    c8c8:	0520                	.2byte	0x520
    c8ca:	0000                	.2byte	0x0
    c8cc:	0520                	.2byte	0x520
    c8ce:	0000                	.2byte	0x0
    c8d0:	0520                	.2byte	0x520
    c8d2:	0000                	.2byte	0x0
    c8d4:	085c                	.2byte	0x85c
    c8d6:	0000                	.2byte	0x0
    c8d8:	0520                	.2byte	0x520
    c8da:	0000                	.2byte	0x0
    c8dc:	0520                	.2byte	0x520
    c8de:	0000                	.2byte	0x0
    c8e0:	0520                	.2byte	0x520
    c8e2:	0000                	.2byte	0x0
    c8e4:	0520                	.2byte	0x520
    c8e6:	0000                	.2byte	0x0
    c8e8:	0520                	.2byte	0x520
    c8ea:	0000                	.2byte	0x0
    c8ec:	0520                	.2byte	0x520
    c8ee:	0000                	.2byte	0x0
    c8f0:	0520                	.2byte	0x520
    c8f2:	0000                	.2byte	0x0
    c8f4:	0520                	.2byte	0x520
    c8f6:	0000                	.2byte	0x0
    c8f8:	0520                	.2byte	0x520
    c8fa:	0000                	.2byte	0x0
    c8fc:	0520                	.2byte	0x520
    c8fe:	0000                	.2byte	0x0
    c900:	05a4                	.2byte	0x5a4
    c902:	0000                	.2byte	0x0
    c904:	0604                	.2byte	0x604
    c906:	0000                	.2byte	0x0
    c908:	0520                	.2byte	0x520
    c90a:	0000                	.2byte	0x0
    c90c:	076c                	.2byte	0x76c
    c90e:	0000                	.2byte	0x0
    c910:	0520                	.2byte	0x520
    c912:	0000                	.2byte	0x0
    c914:	0520                	.2byte	0x520
    c916:	0000                	.2byte	0x0
    c918:	0520                	.2byte	0x520
    c91a:	0000                	.2byte	0x0
    c91c:	0520                	.2byte	0x520
    c91e:	0000                	.2byte	0x0
    c920:	0520                	.2byte	0x520
    c922:	0000                	.2byte	0x0
    c924:	07e4                	.2byte	0x7e4
    c926:	0000                	.2byte	0x0
    c928:	0520                	.2byte	0x520
    c92a:	0000                	.2byte	0x0
    c92c:	0520                	.2byte	0x520
    c92e:	0000                	.2byte	0x0
    c930:	07f4                	.2byte	0x7f4
    c932:	0000                	.2byte	0x0
    c934:	0890                	.2byte	0x890
    c936:	0000                	.2byte	0x0
    c938:	0520                	.2byte	0x520
    c93a:	0000                	.2byte	0x0
    c93c:	0520                	.2byte	0x520
    c93e:	0000                	.2byte	0x0
    c940:	08f4                	.2byte	0x8f4
    c942:	0000                	.2byte	0x0
    c944:	0520                	.2byte	0x520
    c946:	0000                	.2byte	0x0
    c948:	0a84                	.2byte	0xa84
    c94a:	0000                	.2byte	0x0
    c94c:	0520                	.2byte	0x520
    c94e:	0000                	.2byte	0x0
    c950:	0520                	.2byte	0x520
    c952:	0000                	.2byte	0x0
    c954:	09ec                	.2byte	0x9ec
	...

0000c958 <list_known_crc>:
    c958:	d4b0                	.2byte	0xd4b0
    c95a:	3340                	.2byte	0x3340
    c95c:	6a79                	.2byte	0x6a79
    c95e:	e714                	.2byte	0xe714
    c960:	e3c1                	.2byte	0xe3c1
	...

0000c964 <matrix_known_crc>:
    c964:	be52                	.2byte	0xbe52
    c966:	1199                	.2byte	0x1199
    c968:	5608                	.2byte	0x5608
    c96a:	07471fd7          	.4byte	0x7471fd7
	...

0000c970 <state_known_crc>:
    c970:	39bf5e47          	.4byte	0x39bf5e47
    c974:	e5a4                	.2byte	0xe5a4
    c976:	8e3a                	.2byte	0x8e3a
    c978:	8d84                	.2byte	0x8d84
    c97a:	0000                	.2byte	0x0
    c97c:	3434                	.2byte	0x3434
    c97e:	0000                	.2byte	0x0
    c980:	3404                	.2byte	0x3404
    c982:	0000                	.2byte	0x0
    c984:	3410                	.2byte	0x3410
    c986:	0000                	.2byte	0x0
    c988:	341c                	.2byte	0x341c
    c98a:	0000                	.2byte	0x0
    c98c:	3428                	.2byte	0x3428
    c98e:	0000                	.2byte	0x0
    c990:	33f8                	.2byte	0x33f8
	...

0000c994 <intpat>:
    c994:	cf58                	.2byte	0xcf58
    c996:	0000                	.2byte	0x0
    c998:	cf60                	.2byte	0xcf60
    c99a:	0000                	.2byte	0x0
    c99c:	cf68                	.2byte	0xcf68
    c99e:	0000                	.2byte	0x0
    c9a0:	cf70                	.2byte	0xcf70
	...

0000c9a4 <floatpat>:
    c9a4:	cf28                	.2byte	0xcf28
    c9a6:	0000                	.2byte	0x0
    c9a8:	cf34                	.2byte	0xcf34
    c9aa:	0000                	.2byte	0x0
    c9ac:	cf40                	.2byte	0xcf40
    c9ae:	0000                	.2byte	0x0
    c9b0:	cf4c                	.2byte	0xcf4c
	...

0000c9b4 <scipat>:
    c9b4:	cef8                	.2byte	0xcef8
    c9b6:	0000                	.2byte	0x0
    c9b8:	cf04                	.2byte	0xcf04
    c9ba:	0000                	.2byte	0x0
    c9bc:	cf10                	.2byte	0xcf10
    c9be:	0000                	.2byte	0x0
    c9c0:	cf1c                	.2byte	0xcf1c
	...

0000c9c4 <errpat>:
    c9c4:	cec8                	.2byte	0xcec8
    c9c6:	0000                	.2byte	0x0
    c9c8:	ced4                	.2byte	0xced4
    c9ca:	0000                	.2byte	0x0
    c9cc:	cee0                	.2byte	0xcee0
    c9ce:	0000                	.2byte	0x0
    c9d0:	ceec                	.2byte	0xceec
    c9d2:	0000                	.2byte	0x0
    c9d4:	696d                	.2byte	0x696d
    c9d6:	696e                	.2byte	0x696e
    c9d8:	5652                	.2byte	0x5652
    c9da:	5020                	.2byte	0x5020
    c9dc:	7069                	.2byte	0x7069
    c9de:	6c65                	.2byte	0x6c65
    c9e0:	6e69                	.2byte	0x6e69
    c9e2:	2065                	.2byte	0x2065
    c9e4:	5841                	.2byte	0x5841
    c9e6:	2049                	.2byte	0x2049
    c9e8:	4745                	.2byte	0x4745
    c9ea:	4320314f          	.4byte	0x4320314f
    c9ee:	4d65726f          	jal	tp,63ec4 <_stack_top+0x3e6c4>
    c9f2:	7261                	.2byte	0x7261
    c9f4:	00000a6b          	.4byte	0xa6b
    c9f8:	3032                	.2byte	0x3032
    c9fa:	3432                	.2byte	0x3432
    c9fc:	30313133          	.4byte	0x30313133
    ca00:	3138                	.2byte	0x3138
    ca02:	325f 3230 3334      	.byte	0x5f, 0x32, 0x30, 0x32, 0x34, 0x33
    ca08:	3131                	.2byte	0x3131
    ca0a:	3534                	.2byte	0x3534
    ca0c:	00000033          	add	zero,zero,zero
    ca10:	64757453          	.4byte	0x64757453
    ca14:	6e65                	.2byte	0x6e65
    ca16:	2074                	.2byte	0x2074
    ca18:	4449                	.2byte	0x4449
    ca1a:	25203a73          	.4byte	0x25203a73
    ca1e:	00000a73          	.4byte	0xa73
    ca22:	0000                	.2byte	0x0
    ca24:	20555043          	.4byte	0x20555043
    ca28:	636f6c63          	bltu	t5,s6,d060 <__clz_tab+0x40>
    ca2c:	25203a6b          	.4byte	0x25203a6b
    ca30:	2064                	.2byte	0x2064
    ca32:	484d                	.2byte	0x484d
    ca34:	0a7a                	.2byte	0xa7a
    ca36:	0000                	.2byte	0x0
    ca38:	65726f43          	.4byte	0x65726f43
    ca3c:	614d                	.2byte	0x614d
    ca3e:	6b72                	.2byte	0x6b72
    ca40:	3120                	.2byte	0x3120
    ca42:	302e                	.2byte	0x302e
    ca44:	000a                	.2byte	0xa
    ca46:	0000                	.2byte	0x0
    ca48:	65726f43          	.4byte	0x65726f43
    ca4c:	614d                	.2byte	0x614d
    ca4e:	6b72                	.2byte	0x6b72
    ca50:	3120                	.2byte	0x3120
    ca52:	302e                	.2byte	0x302e
    ca54:	3a20                	.2byte	0x3a20
    ca56:	2520                	.2byte	0x2520
    ca58:	0a66                	.2byte	0xa66
    ca5a:	0000                	.2byte	0x0
    ca5c:	65726f43          	.4byte	0x65726f43
    ca60:	614d                	.2byte	0x614d
    ca62:	6b72                	.2byte	0x6b72
    ca64:	7a484d2f          	.4byte	0x7a484d2f
    ca68:	3a20                	.2byte	0x3a20
    ca6a:	2520                	.2byte	0x2520
    ca6c:	0a66                	.2byte	0xa66
    ca6e:	0000                	.2byte	0x0
    ca70:	4946                	.2byte	0x4946
    ca72:	494e                	.2byte	0x494e
    ca74:	000a4853          	.4byte	0xa4853
    ca78:	6e28                	.2byte	0x6e28
    ca7a:	6c75                	.2byte	0x6c75
    ca7c:	296c                	.2byte	0x296c
    ca7e:	0000                	.2byte	0x0
    ca80:	6425                	.2byte	0x6425
    ca82:	252e                	.2byte	0x252e
    ca84:	3330                	.2byte	0x3330
    ca86:	0064                	.2byte	0x64
    ca88:	6b36                	.2byte	0x6b36
    ca8a:	7020                	.2byte	0x7020
    ca8c:	7265                	.2byte	0x7265
    ca8e:	6f66                	.2byte	0x6f66
    ca90:	6d72                	.2byte	0x6d72
    ca92:	6e61                	.2byte	0x6e61
    ca94:	72206563          	bltu	zero,sp,d1be <static_memblk+0x6>
    ca98:	6e75                	.2byte	0x6e75
    ca9a:	7020                	.2byte	0x7020
    ca9c:	7261                	.2byte	0x7261
    ca9e:	6d61                	.2byte	0x6d61
    caa0:	7465                	.2byte	0x7465
    caa2:	7265                	.2byte	0x7265
    caa4:	6f662073          	.4byte	0x6f662073
    caa8:	2072                	.2byte	0x2072
    caaa:	65726f63          	bltu	tp,s7,d108 <__clz_tab+0xe8>
    caae:	616d                	.2byte	0x616d
    cab0:	6b72                	.2byte	0x6b72
    cab2:	0a2e                	.2byte	0xa2e
    cab4:	0000                	.2byte	0x0
    cab6:	0000                	.2byte	0x0
    cab8:	6b36                	.2byte	0x6b36
    caba:	7620                	.2byte	0x7620
    cabc:	6c61                	.2byte	0x6c61
    cabe:	6469                	.2byte	0x6469
    cac0:	7461                	.2byte	0x7461
    cac2:	6f69                	.2byte	0x6f69
    cac4:	206e                	.2byte	0x206e
    cac6:	7572                	.2byte	0x7572
    cac8:	206e                	.2byte	0x206e
    caca:	6170                	.2byte	0x6170
    cacc:	6172                	.2byte	0x6172
    cace:	656d                	.2byte	0x656d
    cad0:	6574                	.2byte	0x6574
    cad2:	7372                	.2byte	0x7372
    cad4:	6620                	.2byte	0x6620
    cad6:	6320726f          	jal	tp,14108 <seed1_volatile+0x6768>
    cada:	6d65726f          	jal	tp,641b0 <_stack_top+0x3e9b0>
    cade:	7261                	.2byte	0x7261
    cae0:	000a2e6b          	.4byte	0xa2e6b
    cae4:	7250                	.2byte	0x7250
    cae6:	6c69666f          	jal	a2,a31ac <_stack_top+0x7d9ac>
    caea:	2065                	.2byte	0x2065
    caec:	656e6567          	.4byte	0x656e6567
    caf0:	6172                	.2byte	0x6172
    caf2:	6974                	.2byte	0x6974
    caf4:	72206e6f          	jal	t3,13216 <seed1_volatile+0x5876>
    caf8:	6e75                	.2byte	0x6e75
    cafa:	7020                	.2byte	0x7020
    cafc:	7261                	.2byte	0x7261
    cafe:	6d61                	.2byte	0x6d61
    cb00:	7465                	.2byte	0x7465
    cb02:	7265                	.2byte	0x7265
    cb04:	6f662073          	.4byte	0x6f662073
    cb08:	2072                	.2byte	0x2072
    cb0a:	65726f63          	bltu	tp,s7,d168 <__clz_tab+0x148>
    cb0e:	616d                	.2byte	0x616d
    cb10:	6b72                	.2byte	0x6b72
    cb12:	0a2e                	.2byte	0xa2e
    cb14:	0000                	.2byte	0x0
    cb16:	0000                	.2byte	0x0
    cb18:	4b32                	.2byte	0x4b32
    cb1a:	7020                	.2byte	0x7020
    cb1c:	7265                	.2byte	0x7265
    cb1e:	6f66                	.2byte	0x6f66
    cb20:	6d72                	.2byte	0x6d72
    cb22:	6e61                	.2byte	0x6e61
    cb24:	72206563          	bltu	zero,sp,d24e <static_memblk+0x96>
    cb28:	6e75                	.2byte	0x6e75
    cb2a:	7020                	.2byte	0x7020
    cb2c:	7261                	.2byte	0x7261
    cb2e:	6d61                	.2byte	0x6d61
    cb30:	7465                	.2byte	0x7465
    cb32:	7265                	.2byte	0x7265
    cb34:	6f662073          	.4byte	0x6f662073
    cb38:	2072                	.2byte	0x2072
    cb3a:	65726f63          	bltu	tp,s7,d198 <timer_high>
    cb3e:	616d                	.2byte	0x616d
    cb40:	6b72                	.2byte	0x6b72
    cb42:	0a2e                	.2byte	0xa2e
    cb44:	0000                	.2byte	0x0
    cb46:	0000                	.2byte	0x0
    cb48:	4b32                	.2byte	0x4b32
    cb4a:	7620                	.2byte	0x7620
    cb4c:	6c61                	.2byte	0x6c61
    cb4e:	6469                	.2byte	0x6469
    cb50:	7461                	.2byte	0x7461
    cb52:	6f69                	.2byte	0x6f69
    cb54:	206e                	.2byte	0x206e
    cb56:	7572                	.2byte	0x7572
    cb58:	206e                	.2byte	0x206e
    cb5a:	6170                	.2byte	0x6170
    cb5c:	6172                	.2byte	0x6172
    cb5e:	656d                	.2byte	0x656d
    cb60:	6574                	.2byte	0x6574
    cb62:	7372                	.2byte	0x7372
    cb64:	6620                	.2byte	0x6620
    cb66:	6320726f          	jal	tp,14198 <seed1_volatile+0x67f8>
    cb6a:	6d65726f          	jal	tp,64240 <_stack_top+0x3ea40>
    cb6e:	7261                	.2byte	0x7261
    cb70:	000a2e6b          	.4byte	0xa2e6b
    cb74:	5d75255b          	.4byte	0x5d75255b
    cb78:	5245                	.2byte	0x5245
    cb7a:	4f52                	.2byte	0x4f52
    cb7c:	2152                	.2byte	0x2152
    cb7e:	6c20                	.2byte	0x6c20
    cb80:	7369                	.2byte	0x7369
    cb82:	2074                	.2byte	0x2074
    cb84:	20637263          	bgeu	t1,t1,cd88 <errpat+0x3c4>
    cb88:	7830                	.2byte	0x7830
    cb8a:	3025                	.2byte	0x3025
    cb8c:	7834                	.2byte	0x7834
    cb8e:	2d20                	.2byte	0x2d20
    cb90:	7320                	.2byte	0x7320
    cb92:	6f68                	.2byte	0x6f68
    cb94:	6c75                	.2byte	0x6c75
    cb96:	2064                	.2byte	0x2064
    cb98:	6562                	.2byte	0x6562
    cb9a:	3020                	.2byte	0x3020
    cb9c:	2578                	.2byte	0x2578
    cb9e:	3430                	.2byte	0x3430
    cba0:	0a78                	.2byte	0xa78
    cba2:	0000                	.2byte	0x0
    cba4:	5d75255b          	.4byte	0x5d75255b
    cba8:	5245                	.2byte	0x5245
    cbaa:	4f52                	.2byte	0x4f52
    cbac:	2152                	.2byte	0x2152
    cbae:	6d20                	.2byte	0x6d20
    cbb0:	7461                	.2byte	0x7461
    cbb2:	6972                	.2byte	0x6972
    cbb4:	2078                	.2byte	0x2078
    cbb6:	20637263          	bgeu	t1,t1,cdba <errpat+0x3f6>
    cbba:	7830                	.2byte	0x7830
    cbbc:	3025                	.2byte	0x3025
    cbbe:	7834                	.2byte	0x7834
    cbc0:	2d20                	.2byte	0x2d20
    cbc2:	7320                	.2byte	0x7320
    cbc4:	6f68                	.2byte	0x6f68
    cbc6:	6c75                	.2byte	0x6c75
    cbc8:	2064                	.2byte	0x2064
    cbca:	6562                	.2byte	0x6562
    cbcc:	3020                	.2byte	0x3020
    cbce:	2578                	.2byte	0x2578
    cbd0:	3430                	.2byte	0x3430
    cbd2:	0a78                	.2byte	0xa78
    cbd4:	0000                	.2byte	0x0
    cbd6:	0000                	.2byte	0x0
    cbd8:	5d75255b          	.4byte	0x5d75255b
    cbdc:	5245                	.2byte	0x5245
    cbde:	4f52                	.2byte	0x4f52
    cbe0:	2152                	.2byte	0x2152
    cbe2:	7320                	.2byte	0x7320
    cbe4:	6174                	.2byte	0x6174
    cbe6:	6574                	.2byte	0x6574
    cbe8:	6320                	.2byte	0x6320
    cbea:	6372                	.2byte	0x6372
    cbec:	3020                	.2byte	0x3020
    cbee:	2578                	.2byte	0x2578
    cbf0:	3430                	.2byte	0x3430
    cbf2:	2078                	.2byte	0x2078
    cbf4:	202d                	.2byte	0x202d
    cbf6:	756f6873          	.4byte	0x756f6873
    cbfa:	646c                	.2byte	0x646c
    cbfc:	6220                	.2byte	0x6220
    cbfe:	2065                	.2byte	0x2065
    cc00:	7830                	.2byte	0x7830
    cc02:	3025                	.2byte	0x3025
    cc04:	7834                	.2byte	0x7834
    cc06:	000a                	.2byte	0xa
    cc08:	65726f43          	.4byte	0x65726f43
    cc0c:	614d                	.2byte	0x614d
    cc0e:	6b72                	.2byte	0x6b72
    cc10:	5320                	.2byte	0x5320
    cc12:	7a69                	.2byte	0x7a69
    cc14:	2065                	.2byte	0x2065
    cc16:	2020                	.2byte	0x2020
    cc18:	3a20                	.2byte	0x3a20
    cc1a:	2520                	.2byte	0x2520
    cc1c:	756c                	.2byte	0x756c
    cc1e:	000a                	.2byte	0xa
    cc20:	6f54                	.2byte	0x6f54
    cc22:	6174                	.2byte	0x6174
    cc24:	206c                	.2byte	0x206c
    cc26:	6974                	.2byte	0x6974
    cc28:	20736b63          	bltu	t1,t2,ce3e <errpat+0x47a>
    cc2c:	2020                	.2byte	0x2020
    cc2e:	2020                	.2byte	0x2020
    cc30:	3a20                	.2byte	0x3a20
    cc32:	2520                	.2byte	0x2520
    cc34:	756c                	.2byte	0x756c
    cc36:	000a                	.2byte	0xa
    cc38:	6f54                	.2byte	0x6f54
    cc3a:	6174                	.2byte	0x6174
    cc3c:	206c                	.2byte	0x206c
    cc3e:	6974                	.2byte	0x6974
    cc40:	656d                	.2byte	0x656d
    cc42:	2820                	.2byte	0x2820
    cc44:	73636573          	.4byte	0x73636573
    cc48:	3a29                	.2byte	0x3a29
    cc4a:	2520                	.2byte	0x2520
    cc4c:	0a64                	.2byte	0xa64
    cc4e:	0000                	.2byte	0x0
    cc50:	7449                	.2byte	0x7449
    cc52:	7265                	.2byte	0x7265
    cc54:	7461                	.2byte	0x7461
    cc56:	6f69                	.2byte	0x6f69
    cc58:	736e                	.2byte	0x736e
    cc5a:	6365532f          	.4byte	0x6365532f
    cc5e:	2020                	.2byte	0x2020
    cc60:	3a20                	.2byte	0x3a20
    cc62:	2520                	.2byte	0x2520
    cc64:	0a64                	.2byte	0xa64
    cc66:	0000                	.2byte	0x0
    cc68:	5245                	.2byte	0x5245
    cc6a:	4f52                	.2byte	0x4f52
    cc6c:	2152                	.2byte	0x2152
    cc6e:	4d20                	.2byte	0x4d20
    cc70:	7375                	.2byte	0x7375
    cc72:	2074                	.2byte	0x2074
    cc74:	7865                	.2byte	0x7865
    cc76:	6365                	.2byte	0x6365
    cc78:	7475                	.2byte	0x7475
    cc7a:	2065                	.2byte	0x2065
    cc7c:	6f66                	.2byte	0x6f66
    cc7e:	2072                	.2byte	0x2072
    cc80:	7461                	.2byte	0x7461
    cc82:	6c20                	.2byte	0x6c20
    cc84:	6165                	.2byte	0x6165
    cc86:	31207473          	.4byte	0x31207473
    cc8a:	2030                	.2byte	0x2030
    cc8c:	73636573          	.4byte	0x73636573
    cc90:	6620                	.2byte	0x6620
    cc92:	6120726f          	jal	tp,142a4 <seed1_volatile+0x6904>
    cc96:	7620                	.2byte	0x7620
    cc98:	6c61                	.2byte	0x6c61
    cc9a:	6469                	.2byte	0x6469
    cc9c:	7220                	.2byte	0x7220
    cc9e:	7365                	.2byte	0x7365
    cca0:	6c75                	.2byte	0x6c75
    cca2:	2174                	.2byte	0x2174
    cca4:	000a                	.2byte	0xa
    cca6:	0000                	.2byte	0x0
    cca8:	7449                	.2byte	0x7449
    ccaa:	7265                	.2byte	0x7265
    ccac:	7461                	.2byte	0x7461
    ccae:	6f69                	.2byte	0x6f69
    ccb0:	736e                	.2byte	0x736e
    ccb2:	2020                	.2byte	0x2020
    ccb4:	2020                	.2byte	0x2020
    ccb6:	2020                	.2byte	0x2020
    ccb8:	3a20                	.2byte	0x3a20
    ccba:	2520                	.2byte	0x2520
    ccbc:	756c                	.2byte	0x756c
    ccbe:	000a                	.2byte	0xa
    ccc0:	31434347          	.4byte	0x31434347
    ccc4:	2e32                	.2byte	0x2e32
    ccc6:	2e32                	.2byte	0x2e32
    ccc8:	0030                	.2byte	0x30
    ccca:	0000                	.2byte	0x0
    cccc:	706d6f43          	.4byte	0x706d6f43
    ccd0:	6c69                	.2byte	0x6c69
    ccd2:	7265                	.2byte	0x7265
    ccd4:	7620                	.2byte	0x7620
    ccd6:	7265                	.2byte	0x7265
    ccd8:	6e6f6973          	.4byte	0x6e6f6973
    ccdc:	3a20                	.2byte	0x3a20
    ccde:	2520                	.2byte	0x2520
    cce0:	00000a73          	.4byte	0xa73
    cce4:	4f2d                	.2byte	0x4f2d
    cce6:	2032                	.2byte	0x2032
    cce8:	662d                	.2byte	0x662d
    ccea:	6e75                	.2byte	0x6e75
    ccec:	6f72                	.2byte	0x6f72
    ccee:	6c6c                	.2byte	0x6c6c
    ccf0:	6c2d                	.2byte	0x6c2d
    ccf2:	73706f6f          	jal	t5,13c28 <seed1_volatile+0x6288>
    ccf6:	2d20                	.2byte	0x2d20
    ccf8:	7066                	.2byte	0x7066
    ccfa:	6565                	.2byte	0x6565
    ccfc:	2d6c                	.2byte	0x2d6c
    ccfe:	6f6c                	.2byte	0x6f6c
    cd00:	2073706f          	j	44706 <_stack_top+0x1ef06>
    cd04:	662d                	.2byte	0x662d
    cd06:	65736367          	.4byte	0x65736367
    cd0a:	732d                	.2byte	0x732d
    cd0c:	206d                	.2byte	0x206d
    cd0e:	662d                	.2byte	0x662d
    cd10:	65736367          	.4byte	0x65736367
    cd14:	6c2d                	.2byte	0x6c2d
    cd16:	7361                	.2byte	0x7361
    cd18:	2d20                	.2byte	0x2d20
    cd1a:	616d                	.2byte	0x616d
    cd1c:	6372                	.2byte	0x6372
    cd1e:	3d68                	.2byte	0x3d68
    cd20:	7672                	.2byte	0x7672
    cd22:	6d693233          	.4byte	0x6d693233
    cd26:	0000                	.2byte	0x0
    cd28:	706d6f43          	.4byte	0x706d6f43
    cd2c:	6c69                	.2byte	0x6c69
    cd2e:	7265                	.2byte	0x7265
    cd30:	6620                	.2byte	0x6620
    cd32:	616c                	.2byte	0x616c
    cd34:	20207367          	.4byte	0x20207367
    cd38:	3a20                	.2byte	0x3a20
    cd3a:	2520                	.2byte	0x2520
    cd3c:	00000a73          	.4byte	0xa73
    cd40:	54415453          	.4byte	0x54415453
    cd44:	4349                	.2byte	0x4349
    cd46:	0000                	.2byte	0x0
    cd48:	654d                	.2byte	0x654d
    cd4a:	6f6d                	.2byte	0x6f6d
    cd4c:	7972                	.2byte	0x7972
    cd4e:	6c20                	.2byte	0x6c20
    cd50:	7461636f          	jal	t1,23496 <_heap_start+0xa496>
    cd54:	6f69                	.2byte	0x6f69
    cd56:	206e                	.2byte	0x206e
    cd58:	3a20                	.2byte	0x3a20
    cd5a:	2520                	.2byte	0x2520
    cd5c:	00000a73          	.4byte	0xa73
    cd60:	64656573          	.4byte	0x64656573
    cd64:	20637263          	bgeu	t1,t1,cf68 <errpat+0x5a4>
    cd68:	2020                	.2byte	0x2020
    cd6a:	2020                	.2byte	0x2020
    cd6c:	2020                	.2byte	0x2020
    cd6e:	2020                	.2byte	0x2020
    cd70:	3a20                	.2byte	0x3a20
    cd72:	3020                	.2byte	0x3020
    cd74:	2578                	.2byte	0x2578
    cd76:	3430                	.2byte	0x3430
    cd78:	0a78                	.2byte	0xa78
    cd7a:	0000                	.2byte	0x0
    cd7c:	5d64255b          	.4byte	0x5d64255b
    cd80:	6c637263          	bgeu	t1,t1,d444 <static_memblk+0x28c>
    cd84:	7369                	.2byte	0x7369
    cd86:	2074                	.2byte	0x2074
    cd88:	2020                	.2byte	0x2020
    cd8a:	2020                	.2byte	0x2020
    cd8c:	2020                	.2byte	0x2020
    cd8e:	203a                	.2byte	0x203a
    cd90:	7830                	.2byte	0x7830
    cd92:	3025                	.2byte	0x3025
    cd94:	7834                	.2byte	0x7834
    cd96:	000a                	.2byte	0xa
    cd98:	5d64255b          	.4byte	0x5d64255b
    cd9c:	6d637263          	bgeu	t1,s6,d460 <static_memblk+0x2a8>
    cda0:	7461                	.2byte	0x7461
    cda2:	6972                	.2byte	0x6972
    cda4:	2078                	.2byte	0x2078
    cda6:	2020                	.2byte	0x2020
    cda8:	2020                	.2byte	0x2020
    cdaa:	203a                	.2byte	0x203a
    cdac:	7830                	.2byte	0x7830
    cdae:	3025                	.2byte	0x3025
    cdb0:	7834                	.2byte	0x7834
    cdb2:	000a                	.2byte	0xa
    cdb4:	5d64255b          	.4byte	0x5d64255b
    cdb8:	73637263          	bgeu	t1,s6,d4dc <static_memblk+0x324>
    cdbc:	6174                	.2byte	0x6174
    cdbe:	6574                	.2byte	0x6574
    cdc0:	2020                	.2byte	0x2020
    cdc2:	2020                	.2byte	0x2020
    cdc4:	2020                	.2byte	0x2020
    cdc6:	203a                	.2byte	0x203a
    cdc8:	7830                	.2byte	0x7830
    cdca:	3025                	.2byte	0x3025
    cdcc:	7834                	.2byte	0x7834
    cdce:	000a                	.2byte	0xa
    cdd0:	5d64255b          	.4byte	0x5d64255b
    cdd4:	66637263          	bgeu	t1,t1,d438 <static_memblk+0x280>
    cdd8:	6e69                	.2byte	0x6e69
    cdda:	6c61                	.2byte	0x6c61
    cddc:	2020                	.2byte	0x2020
    cdde:	2020                	.2byte	0x2020
    cde0:	2020                	.2byte	0x2020
    cde2:	203a                	.2byte	0x203a
    cde4:	7830                	.2byte	0x7830
    cde6:	3025                	.2byte	0x3025
    cde8:	7834                	.2byte	0x7834
    cdea:	000a                	.2byte	0xa
    cdec:	72726f43          	.4byte	0x72726f43
    cdf0:	6365                	.2byte	0x6365
    cdf2:	2074                	.2byte	0x2074
    cdf4:	7265706f          	j	6451a <_stack_top+0x3ed1a>
    cdf8:	7461                	.2byte	0x7461
    cdfa:	6f69                	.2byte	0x6f69
    cdfc:	206e                	.2byte	0x206e
    cdfe:	6176                	.2byte	0x6176
    ce00:	696c                	.2byte	0x696c
    ce02:	6164                	.2byte	0x6164
    ce04:	6574                	.2byte	0x6574
    ce06:	2e64                	.2byte	0x2e64
    ce08:	5320                	.2byte	0x5320
    ce0a:	6565                	.2byte	0x6565
    ce0c:	5220                	.2byte	0x5220
    ce0e:	4145                	.2byte	0x4145
    ce10:	4d44                	.2byte	0x4d44
    ce12:	2e45                	.2byte	0x2e45
    ce14:	646d                	.2byte	0x646d
    ce16:	6620                	.2byte	0x6620
    ce18:	7220726f          	jal	tp,1453a <seed1_volatile+0x6b9a>
    ce1c:	6e75                	.2byte	0x6e75
    ce1e:	6120                	.2byte	0x6120
    ce20:	646e                	.2byte	0x646e
    ce22:	7220                	.2byte	0x7220
    ce24:	7065                	.2byte	0x7065
    ce26:	6974726f          	jal	tp,54cbc <_stack_top+0x2f4bc>
    ce2a:	676e                	.2byte	0x676e
    ce2c:	7220                	.2byte	0x7220
    ce2e:	6c75                	.2byte	0x6c75
    ce30:	7365                	.2byte	0x7365
    ce32:	0a2e                	.2byte	0xa2e
    ce34:	0000                	.2byte	0x0
    ce36:	0000                	.2byte	0x0
    ce38:	6e6e6143          	.4byte	0x6e6e6143
    ce3c:	7620746f          	jal	s0,1459e <seed1_volatile+0x6bfe>
    ce40:	6c61                	.2byte	0x6c61
    ce42:	6469                	.2byte	0x6469
    ce44:	7461                	.2byte	0x7461
    ce46:	2065                	.2byte	0x2065
    ce48:	7265706f          	j	6456e <_stack_top+0x3ed6e>
    ce4c:	7461                	.2byte	0x7461
    ce4e:	6f69                	.2byte	0x6f69
    ce50:	206e                	.2byte	0x206e
    ce52:	6f66                	.2byte	0x6f66
    ce54:	2072                	.2byte	0x2072
    ce56:	6874                	.2byte	0x6874
    ce58:	7365                	.2byte	0x7365
    ce5a:	2065                	.2byte	0x2065
    ce5c:	64656573          	.4byte	0x64656573
    ce60:	7620                	.2byte	0x7620
    ce62:	6c61                	.2byte	0x6c61
    ce64:	6575                	.2byte	0x6575
    ce66:	70202c73          	.4byte	0x70202c73
    ce6a:	656c                	.2byte	0x656c
    ce6c:	7361                	.2byte	0x7361
    ce6e:	2065                	.2byte	0x2065
    ce70:	706d6f63          	bltu	s10,t1,d58e <static_memblk+0x3d6>
    ce74:	7261                	.2byte	0x7261
    ce76:	2065                	.2byte	0x2065
    ce78:	68746977          	.4byte	0x68746977
    ce7c:	7220                	.2byte	0x7220
    ce7e:	7365                	.2byte	0x7365
    ce80:	6c75                	.2byte	0x6c75
    ce82:	7374                	.2byte	0x7374
    ce84:	6f20                	.2byte	0x6f20
    ce86:	206e                	.2byte	0x206e
    ce88:	2061                	.2byte	0x2061
    ce8a:	776f6e6b          	.4byte	0x776f6e6b
    ce8e:	206e                	.2byte	0x206e
    ce90:	6c70                	.2byte	0x6c70
    ce92:	7461                	.2byte	0x7461
    ce94:	6f66                	.2byte	0x6f66
    ce96:	6d72                	.2byte	0x6d72
    ce98:	0a2e                	.2byte	0xa2e
    ce9a:	0000                	.2byte	0x0
    ce9c:	7245                	.2byte	0x7245
    ce9e:	6f72                	.2byte	0x6f72
    cea0:	7372                	.2byte	0x7372
    cea2:	6420                	.2byte	0x6420
    cea4:	7465                	.2byte	0x7465
    cea6:	6365                	.2byte	0x6365
    cea8:	6574                	.2byte	0x6574
    ceaa:	0a64                	.2byte	0xa64
    ceac:	0000                	.2byte	0x0
    ceae:	0000                	.2byte	0x0
    ceb0:	74617453          	.4byte	0x74617453
    ceb4:	6369                	.2byte	0x6369
    ceb6:	0000                	.2byte	0x0
    ceb8:	6548                	.2byte	0x6548
    ceba:	7061                	.2byte	0x7061
    cebc:	0000                	.2byte	0x0
    cebe:	0000                	.2byte	0x0
    cec0:	63617453          	.4byte	0x63617453
    cec4:	0000006b          	.4byte	0x6b
    cec8:	3054                	.2byte	0x3054
    ceca:	332e                	.2byte	0x332e
    cecc:	2d65                	.2byte	0x2d65
    cece:	4631                	.2byte	0x4631
    ced0:	0000                	.2byte	0x0
    ced2:	0000                	.2byte	0x0
    ced4:	542d                	.2byte	0x542d
    ced6:	542e                	.2byte	0x542e
    ced8:	71542b2b          	.4byte	0x71542b2b
    cedc:	0000                	.2byte	0x0
    cede:	0000                	.2byte	0x0
    cee0:	5431                	.2byte	0x5431
    cee2:	65342e33          	.4byte	0x65342e33
    cee6:	7a34                	.2byte	0x7a34
    cee8:	0000                	.2byte	0x0
    ceea:	0000                	.2byte	0x0
    ceec:	302e3433          	.4byte	0x302e3433
    cef0:	2d65                	.2byte	0x2d65
    cef2:	5e54                	.2byte	0x5e54
    cef4:	0000                	.2byte	0x0
    cef6:	0000                	.2byte	0x0
    cef8:	2e35                	.2byte	0x2e35
    cefa:	3035                	.2byte	0x3035
    cefc:	6530                	.2byte	0x6530
    cefe:	0000332b          	.4byte	0x332b
    cf02:	0000                	.2byte	0x0
    cf04:	2e2d                	.2byte	0x2e2d
    cf06:	3231                	.2byte	0x3231
    cf08:	322d6533          	.4byte	0x322d6533
    cf0c:	0000                	.2byte	0x0
    cf0e:	0000                	.2byte	0x0
    cf10:	382d                	.2byte	0x382d
    cf12:	382b6537          	lui	a0,0x382b6
    cf16:	00003233          	snez	tp,zero
    cf1a:	0000                	.2byte	0x0
    cf1c:	362e302b          	.4byte	0x362e302b
    cf20:	2d65                	.2byte	0x2d65
    cf22:	3231                	.2byte	0x3231
    cf24:	0000                	.2byte	0x0
    cf26:	0000                	.2byte	0x0
    cf28:	352e3533          	.4byte	0x352e3533
    cf2c:	3434                	.2byte	0x3434
    cf2e:	3030                	.2byte	0x3030
    cf30:	0000                	.2byte	0x0
    cf32:	0000                	.2byte	0x0
    cf34:	312e                	.2byte	0x312e
    cf36:	3332                	.2byte	0x3332
    cf38:	3534                	.2byte	0x3534
    cf3a:	3030                	.2byte	0x3030
    cf3c:	0000                	.2byte	0x0
    cf3e:	0000                	.2byte	0x0
    cf40:	312d                	.2byte	0x312d
    cf42:	3031                	.2byte	0x3031
    cf44:	372e                	.2byte	0x372e
    cf46:	3030                	.2byte	0x3030
    cf48:	0000                	.2byte	0x0
    cf4a:	0000                	.2byte	0x0
    cf4c:	362e302b          	.4byte	0x362e302b
    cf50:	3434                	.2byte	0x3434
    cf52:	3030                	.2byte	0x3030
    cf54:	0000                	.2byte	0x0
    cf56:	0000                	.2byte	0x0
    cf58:	3035                	.2byte	0x3035
    cf5a:	3231                	.2byte	0x3231
    cf5c:	0000                	.2byte	0x0
    cf5e:	0000                	.2byte	0x0
    cf60:	3231                	.2byte	0x3231
    cf62:	00003433          	snez	s0,zero
    cf66:	0000                	.2byte	0x0
    cf68:	382d                	.2byte	0x382d
    cf6a:	00003437          	lui	s0,0x3
    cf6e:	0000                	.2byte	0x0
    cf70:	3232312b          	.4byte	0x3232312b
    cf74:	0000                	.2byte	0x0
    cf76:	0000                	.2byte	0x0
    cf78:	b120                	.2byte	0xb120
    cf7a:	ffff                	.2byte	0xffff
    cf7c:	aed0                	.2byte	0xaed0
    cf7e:	ffff                	.2byte	0xffff
    cf80:	af24                	.2byte	0xaf24
    cf82:	ffff                	.2byte	0xffff
    cf84:	af30                	.2byte	0xaf30
    cf86:	ffff                	.2byte	0xffff
    cf88:	af24                	.2byte	0xaf24
    cf8a:	ffff                	.2byte	0xffff
    cf8c:	af40                	.2byte	0xaf40
    cf8e:	ffff                	.2byte	0xffff
    cf90:	af24                	.2byte	0xaf24
    cf92:	ffff                	.2byte	0xffff
    cf94:	af30                	.2byte	0xaf30
    cf96:	ffff                	.2byte	0xffff
    cf98:	aed0                	.2byte	0xaed0
    cf9a:	ffff                	.2byte	0xffff
    cf9c:	aed0                	.2byte	0xaed0
    cf9e:	ffff                	.2byte	0xffff
    cfa0:	af40                	.2byte	0xaf40
    cfa2:	ffff                	.2byte	0xffff
    cfa4:	af30                	.2byte	0xaf30
    cfa6:	ffff                	.2byte	0xffff
    cfa8:	b04c                	.2byte	0xb04c
    cfaa:	ffff                	.2byte	0xffff
    cfac:	b04c                	.2byte	0xb04c
    cfae:	ffff                	.2byte	0xffff
    cfb0:	b04c                	.2byte	0xb04c
    cfb2:	ffff                	.2byte	0xffff
    cfb4:	af40                	.2byte	0xaf40
    cfb6:	ffff                	.2byte	0xffff
    cfb8:	ae90                	.2byte	0xae90
    cfba:	ffff                	.2byte	0xffff
    cfbc:	ae90                	.2byte	0xae90
    cfbe:	ffff                	.2byte	0xffff
    cfc0:	aee4                	.2byte	0xaee4
    cfc2:	ffff                	.2byte	0xffff
    cfc4:	b19c                	.2byte	0xb19c
    cfc6:	ffff                	.2byte	0xffff
    cfc8:	aee4                	.2byte	0xaee4
    cfca:	ffff                	.2byte	0xffff
    cfcc:	af00                	.2byte	0xaf00
    cfce:	ffff                	.2byte	0xffff
    cfd0:	aee4                	.2byte	0xaee4
    cfd2:	ffff                	.2byte	0xffff
    cfd4:	b19c                	.2byte	0xb19c
    cfd6:	ffff                	.2byte	0xffff
    cfd8:	ae90                	.2byte	0xae90
    cfda:	ffff                	.2byte	0xffff
    cfdc:	ae90                	.2byte	0xae90
    cfde:	ffff                	.2byte	0xffff
    cfe0:	af00                	.2byte	0xaf00
    cfe2:	ffff                	.2byte	0xffff
    cfe4:	b19c                	.2byte	0xb19c
    cfe6:	ffff                	.2byte	0xffff
    cfe8:	b00c                	.2byte	0xb00c
    cfea:	ffff                	.2byte	0xffff
    cfec:	b00c                	.2byte	0xb00c
    cfee:	ffff                	.2byte	0xffff
    cff0:	b19c                	.2byte	0xb19c
    cff2:	ffff                	.2byte	0xffff
    cff4:	aeac                	.2byte	0xaeac
    cff6:	ffff                	.2byte	0xffff
    cff8:	b170                	.2byte	0xb170
    cffa:	ffff                	.2byte	0xffff
    cffc:	aeac                	.2byte	0xaeac
    cffe:	ffff                	.2byte	0xffff
    d000:	b19c                	.2byte	0xb19c
    d002:	ffff                	.2byte	0xffff
    d004:	ae58                	.2byte	0xae58
    d006:	ffff                	.2byte	0xffff
    d008:	ae58                	.2byte	0xae58
    d00a:	ffff                	.2byte	0xffff
    d00c:	b170                	.2byte	0xb170
    d00e:	ffff                	.2byte	0xffff
    d010:	b19c                	.2byte	0xb19c
    d012:	ffff                	.2byte	0xffff
    d014:	afd0                	.2byte	0xafd0
    d016:	ffff                	.2byte	0xffff
    d018:	afd0                	.2byte	0xafd0
    d01a:	ffff                	.2byte	0xffff
    d01c:	afd0                	.2byte	0xafd0
    d01e:	ffff                	.2byte	0xffff

0000d020 <__clz_tab>:
    d020:	0100                	.2byte	0x100
    d022:	0202                	.2byte	0x202
    d024:	03030303          	lb	t1,48(t1)
    d028:	0404                	.2byte	0x404
    d02a:	0404                	.2byte	0x404
    d02c:	0404                	.2byte	0x404
    d02e:	0404                	.2byte	0x404
    d030:	0505                	.2byte	0x505
    d032:	0505                	.2byte	0x505
    d034:	0505                	.2byte	0x505
    d036:	0505                	.2byte	0x505
    d038:	0505                	.2byte	0x505
    d03a:	0505                	.2byte	0x505
    d03c:	0505                	.2byte	0x505
    d03e:	0505                	.2byte	0x505
    d040:	0606                	.2byte	0x606
    d042:	0606                	.2byte	0x606
    d044:	0606                	.2byte	0x606
    d046:	0606                	.2byte	0x606
    d048:	0606                	.2byte	0x606
    d04a:	0606                	.2byte	0x606
    d04c:	0606                	.2byte	0x606
    d04e:	0606                	.2byte	0x606
    d050:	0606                	.2byte	0x606
    d052:	0606                	.2byte	0x606
    d054:	0606                	.2byte	0x606
    d056:	0606                	.2byte	0x606
    d058:	0606                	.2byte	0x606
    d05a:	0606                	.2byte	0x606
    d05c:	0606                	.2byte	0x606
    d05e:	0606                	.2byte	0x606
    d060:	07070707          	.4byte	0x7070707
    d064:	07070707          	.4byte	0x7070707
    d068:	07070707          	.4byte	0x7070707
    d06c:	07070707          	.4byte	0x7070707
    d070:	07070707          	.4byte	0x7070707
    d074:	07070707          	.4byte	0x7070707
    d078:	07070707          	.4byte	0x7070707
    d07c:	07070707          	.4byte	0x7070707
    d080:	07070707          	.4byte	0x7070707
    d084:	07070707          	.4byte	0x7070707
    d088:	07070707          	.4byte	0x7070707
    d08c:	07070707          	.4byte	0x7070707
    d090:	07070707          	.4byte	0x7070707
    d094:	07070707          	.4byte	0x7070707
    d098:	07070707          	.4byte	0x7070707
    d09c:	07070707          	.4byte	0x7070707
    d0a0:	0808                	.2byte	0x808
    d0a2:	0808                	.2byte	0x808
    d0a4:	0808                	.2byte	0x808
    d0a6:	0808                	.2byte	0x808
    d0a8:	0808                	.2byte	0x808
    d0aa:	0808                	.2byte	0x808
    d0ac:	0808                	.2byte	0x808
    d0ae:	0808                	.2byte	0x808
    d0b0:	0808                	.2byte	0x808
    d0b2:	0808                	.2byte	0x808
    d0b4:	0808                	.2byte	0x808
    d0b6:	0808                	.2byte	0x808
    d0b8:	0808                	.2byte	0x808
    d0ba:	0808                	.2byte	0x808
    d0bc:	0808                	.2byte	0x808
    d0be:	0808                	.2byte	0x808
    d0c0:	0808                	.2byte	0x808
    d0c2:	0808                	.2byte	0x808
    d0c4:	0808                	.2byte	0x808
    d0c6:	0808                	.2byte	0x808
    d0c8:	0808                	.2byte	0x808
    d0ca:	0808                	.2byte	0x808
    d0cc:	0808                	.2byte	0x808
    d0ce:	0808                	.2byte	0x808
    d0d0:	0808                	.2byte	0x808
    d0d2:	0808                	.2byte	0x808
    d0d4:	0808                	.2byte	0x808
    d0d6:	0808                	.2byte	0x808
    d0d8:	0808                	.2byte	0x808
    d0da:	0808                	.2byte	0x808
    d0dc:	0808                	.2byte	0x808
    d0de:	0808                	.2byte	0x808
    d0e0:	0808                	.2byte	0x808
    d0e2:	0808                	.2byte	0x808
    d0e4:	0808                	.2byte	0x808
    d0e6:	0808                	.2byte	0x808
    d0e8:	0808                	.2byte	0x808
    d0ea:	0808                	.2byte	0x808
    d0ec:	0808                	.2byte	0x808
    d0ee:	0808                	.2byte	0x808
    d0f0:	0808                	.2byte	0x808
    d0f2:	0808                	.2byte	0x808
    d0f4:	0808                	.2byte	0x808
    d0f6:	0808                	.2byte	0x808
    d0f8:	0808                	.2byte	0x808
    d0fa:	0808                	.2byte	0x808
    d0fc:	0808                	.2byte	0x808
    d0fe:	0808                	.2byte	0x808
    d100:	0808                	.2byte	0x808
    d102:	0808                	.2byte	0x808
    d104:	0808                	.2byte	0x808
    d106:	0808                	.2byte	0x808
    d108:	0808                	.2byte	0x808
    d10a:	0808                	.2byte	0x808
    d10c:	0808                	.2byte	0x808
    d10e:	0808                	.2byte	0x808
    d110:	0808                	.2byte	0x808
    d112:	0808                	.2byte	0x808
    d114:	0808                	.2byte	0x808
    d116:	0808                	.2byte	0x808
    d118:	0808                	.2byte	0x808
    d11a:	0808                	.2byte	0x808
    d11c:	0808                	.2byte	0x808
    d11e:	0808                	.2byte	0x808

Disassembly of section .srodata.cst4:

0000d120 <.srodata.cst4>:
    d120:	e49c                	.2byte	0xe49c
    d122:	4e26                	.2byte	0x4e26
    d124:	0000                	.2byte	0x0
    d126:	4248                	.2byte	0x4248

Disassembly of section .srodata.cst8:

0000d128 <.srodata.cst8>:
    d128:	0000                	.2byte	0x0
    d12a:	0000                	.2byte	0x0
    d12c:	4000                	.2byte	0x4000
    d12e:	8f 40             	Address 0x000000000000d12e is out of bounds.


Disassembly of section .eh_frame:

0000d130 <.eh_frame>:
    d130:	0010                	.2byte	0x10
    d132:	0000                	.2byte	0x0
    d134:	0000                	.2byte	0x0
    d136:	0000                	.2byte	0x0
    d138:	00527a03          	.4byte	0x527a03
    d13c:	7c01                	.2byte	0x7c01
    d13e:	0101                	.2byte	0x101
    d140:	00020d1b          	.4byte	0x20d1b
    d144:	0010                	.2byte	0x10
    d146:	0000                	.2byte	0x0
    d148:	0018                	.2byte	0x18
    d14a:	0000                	.2byte	0x0
    d14c:	8cf4                	.2byte	0x8cf4
    d14e:	ffff                	.2byte	0xffff
    d150:	04a8                	.2byte	0x4a8
    d152:	0000                	.2byte	0x0
    d154:	0000                	.2byte	0x0
    d156:	0000                	.2byte	0x0
    d158:	0010                	.2byte	0x10
    d15a:	0000                	.2byte	0x0
    d15c:	002c                	.2byte	0x2c
    d15e:	0000                	.2byte	0x0
    d160:	9188                	.2byte	0x9188
    d162:	ffff                	.2byte	0xffff
    d164:	04b8                	.2byte	0x4b8
    d166:	0000                	.2byte	0x0
    d168:	0000                	.2byte	0x0
    d16a:	0000                	.2byte	0x0
    d16c:	0010                	.2byte	0x10
    d16e:	0000                	.2byte	0x0
    d170:	0040                	.2byte	0x40
    d172:	0000                	.2byte	0x0
    d174:	962c                	.2byte	0x962c
    d176:	ffff                	.2byte	0xffff
    d178:	0478                	.2byte	0x478
    d17a:	0000                	.2byte	0x0
    d17c:	0000                	.2byte	0x0
	...

Disassembly of section .data:

0000d180 <mem_name>:
    d180:	ceb0                	.2byte	0xceb0
    d182:	0000                	.2byte	0x0
    d184:	ceb8                	.2byte	0xceb8
    d186:	0000                	.2byte	0x0
    d188:	cec0                	.2byte	0xcec0
	...

Disassembly of section .sdata:

0000d18c <default_num_contexts>:
    d18c:	0001                	.2byte	0x1
	...

0000d190 <board_dig>:
    d190:	2000                	.2byte	0x2000
    d192:	ffff                	.2byte	0xffff

0000d194 <board_led>:
    d194:	1000                	.2byte	0x1000
    d196:	ffff                	.2byte	0xffff

0000d198 <timer_high>:
    d198:	4008                	.2byte	0x4008
    d19a:	ffff                	.2byte	0xffff

0000d19c <timer_low>:
    d19c:	4000                	.2byte	0x4000
    d19e:	ffff                	.2byte	0xffff

0000d1a0 <seed4_volatile>:
    d1a0:	02bc                	.2byte	0x2bc
	...

0000d1a4 <seed3_volatile>:
    d1a4:	0066                	.2byte	0x66
	...

0000d1a8 <uart_ctrl_reg>:
    d1a8:	300c                	.2byte	0x300c
    d1aa:	ffff                	.2byte	0xffff

0000d1ac <uart_stat_reg>:
    d1ac:	3008                	.2byte	0x3008
    d1ae:	ffff                	.2byte	0xffff

0000d1b0 <uart_tx_fifo>:
    d1b0:	3004                	.2byte	0x3004
    d1b2:	ffff                	.2byte	0xffff

0000d1b4 <uart_rx_fifo>:
    d1b4:	3000                	.2byte	0x3000
    d1b6:	ffff                	.2byte	0xffff

Disassembly of section .bss:

0000d1b8 <static_memblk>:
	...

Disassembly of section .sbss:

0000d988 <stop_time_val>:
	...

0000d990 <start_time_val>:
	...

0000d998 <seed5_volatile>:
    d998:	0000                	.2byte	0x0
	...

0000d99c <seed2_volatile>:
    d99c:	0000                	.2byte	0x0
	...

0000d9a0 <seed1_volatile>:
    d9a0:	0000                	.2byte	0x0
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	.4byte	0x3a434347
   4:	2820                	.2byte	0x2820
   6:	5078                	.2byte	0x5078
   8:	6361                	.2byte	0x6361
   a:	4e47206b          	.4byte	0x4e47206b
   e:	2055                	.2byte	0x2055
  10:	4952                	.2byte	0x4952
  12:	562d4353          	.4byte	0x562d4353
  16:	4520                	.2byte	0x4520
  18:	626d                	.2byte	0x626d
  1a:	6465                	.2byte	0x6465
  1c:	6564                	.2byte	0x6564
  1e:	2064                	.2byte	0x2064
  20:	20434347          	.4byte	0x20434347
  24:	3878                	.2byte	0x3878
  26:	5f36                	.2byte	0x5f36
  28:	3436                	.2byte	0x3436
  2a:	2029                	.2byte	0x2029
  2c:	3231                	.2byte	0x3231
  2e:	322e                	.2byte	0x322e
  30:	302e                	.2byte	0x302e
	...

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	2041                	.2byte	0x2041
   2:	0000                	.2byte	0x0
   4:	7200                	.2byte	0x7200
   6:	7369                	.2byte	0x7369
   8:	01007663          	bgeu	zero,a6,14 <_start+0x14>
   c:	0016                	.2byte	0x16
   e:	0000                	.2byte	0x0
  10:	1004                	.2byte	0x1004
  12:	7205                	.2byte	0x7205
  14:	3376                	.2byte	0x3376
  16:	6932                	.2byte	0x6932
  18:	7032                	.2byte	0x7032
  1a:	5f31                	.2byte	0x5f31
  1c:	326d                	.2byte	0x326d
  1e:	3070                	.2byte	0x3070
	...
