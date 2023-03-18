
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8e013103          	ld	sp,-1824(sp) # 800088e0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8f070713          	addi	a4,a4,-1808 # 80008940 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	bfe78793          	addi	a5,a5,-1026 # 80005c60 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc84f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	458080e7          	jalr	1112(ra) # 80002582 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8f650513          	addi	a0,a0,-1802 # 80010a80 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8e648493          	addi	s1,s1,-1818 # 80010a80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	97690913          	addi	s2,s2,-1674 # 80010b18 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	810080e7          	jalr	-2032(ra) # 800019d0 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	204080e7          	jalr	516(ra) # 800023cc <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f4e080e7          	jalr	-178(ra) # 80002124 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	31a080e7          	jalr	794(ra) # 8000252c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	85a50513          	addi	a0,a0,-1958 # 80010a80 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	84450513          	addi	a0,a0,-1980 # 80010a80 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8af72323          	sw	a5,-1882(a4) # 80010b18 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7b450513          	addi	a0,a0,1972 # 80010a80 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	2e6080e7          	jalr	742(ra) # 800025d8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	78650513          	addi	a0,a0,1926 # 80010a80 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	76270713          	addi	a4,a4,1890 # 80010a80 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	73878793          	addi	a5,a5,1848 # 80010a80 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7a27a783          	lw	a5,1954(a5) # 80010b18 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6f670713          	addi	a4,a4,1782 # 80010a80 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6e648493          	addi	s1,s1,1766 # 80010a80 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	6aa70713          	addi	a4,a4,1706 # 80010a80 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72a23          	sw	a5,1844(a4) # 80010b20 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	66e78793          	addi	a5,a5,1646 # 80010a80 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ec7a323          	sw	a2,1766(a5) # 80010b1c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6da50513          	addi	a0,a0,1754 # 80010b18 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d42080e7          	jalr	-702(ra) # 80002188 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	62050513          	addi	a0,a0,1568 # 80010a80 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	9a078793          	addi	a5,a5,-1632 # 80020e18 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5e07aa23          	sw	zero,1524(a5) # 80010b40 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b8250513          	addi	a0,a0,-1150 # 800080f0 <digits+0xb0>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	38f72023          	sw	a5,896(a4) # 80008900 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	584dad83          	lw	s11,1412(s11) # 80010b40 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	52e50513          	addi	a0,a0,1326 # 80010b28 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3d050513          	addi	a0,a0,976 # 80010b28 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	3b448493          	addi	s1,s1,948 # 80010b28 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	37450513          	addi	a0,a0,884 # 80010b48 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	1007a783          	lw	a5,256(a5) # 80008900 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0d07b783          	ld	a5,208(a5) # 80008908 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0d073703          	ld	a4,208(a4) # 80008910 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2e6a0a13          	addi	s4,s4,742 # 80010b48 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	09e48493          	addi	s1,s1,158 # 80008908 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	09e98993          	addi	s3,s3,158 # 80008910 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	8f4080e7          	jalr	-1804(ra) # 80002188 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	27850513          	addi	a0,a0,632 # 80010b48 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0207a783          	lw	a5,32(a5) # 80008900 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	02673703          	ld	a4,38(a4) # 80008910 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0167b783          	ld	a5,22(a5) # 80008908 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	24a98993          	addi	s3,s3,586 # 80010b48 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	00248493          	addi	s1,s1,2 # 80008908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	00290913          	addi	s2,s2,2 # 80008910 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	806080e7          	jalr	-2042(ra) # 80002124 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	21448493          	addi	s1,s1,532 # 80010b48 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fce7b423          	sd	a4,-56(a5) # 80008910 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	18e48493          	addi	s1,s1,398 # 80010b48 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	5b478793          	addi	a5,a5,1460 # 80021fb0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	16490913          	addi	s2,s2,356 # 80010b80 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0c650513          	addi	a0,a0,198 # 80010b80 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	4e250513          	addi	a0,a0,1250 # 80021fb0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	09048493          	addi	s1,s1,144 # 80010b80 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	07850513          	addi	a0,a0,120 # 80010b80 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	04c50513          	addi	a0,a0,76 # 80010b80 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e44080e7          	jalr	-444(ra) # 800019b4 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e12080e7          	jalr	-494(ra) # 800019b4 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e06080e7          	jalr	-506(ra) # 800019b4 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dee080e7          	jalr	-530(ra) # 800019b4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	dae080e7          	jalr	-594(ra) # 800019b4 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d82080e7          	jalr	-638(ra) # 800019b4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd051>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b24080e7          	jalr	-1244(ra) # 800019a4 <cpuid>

    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a9070713          	addi	a4,a4,-1392 # 80008918 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b08080e7          	jalr	-1272(ra) # 800019a4 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	23a50513          	addi	a0,a0,570 # 800080e0 <digits+0xa0>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0f8080e7          	jalr	248(ra) # 80000fae <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	84a080e7          	jalr	-1974(ra) # 80002708 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	dda080e7          	jalr	-550(ra) # 80005ca0 <plicinithart>
  }
  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	004080e7          	jalr	4(ra) # 80001ed2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	20a50513          	addi	a0,a0,522 # 800080f0 <digits+0xb0>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1ea50513          	addi	a0,a0,490 # 800080f0 <digits+0xb0>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	346080e7          	jalr	838(ra) # 80001264 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	088080e7          	jalr	136(ra) # 80000fae <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9be080e7          	jalr	-1602(ra) # 800018ec <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	7aa080e7          	jalr	1962(ra) # 800026e0 <trapinit>
        printf("trapinit listo\n");
    80000f3e:	00007517          	auipc	a0,0x7
    80000f42:	17a50513          	addi	a0,a0,378 # 800080b8 <digits+0x78>
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	644080e7          	jalr	1604(ra) # 8000058a <printf>
    trapinithart();  // install kernel trap vector
    80000f4e:	00001097          	auipc	ra,0x1
    80000f52:	7ba080e7          	jalr	1978(ra) # 80002708 <trapinithart>
    printf("trapinithart listo\n");
    80000f56:	00007517          	auipc	a0,0x7
    80000f5a:	17250513          	addi	a0,a0,370 # 800080c8 <digits+0x88>
    80000f5e:	fffff097          	auipc	ra,0xfffff
    80000f62:	62c080e7          	jalr	1580(ra) # 8000058a <printf>
    plicinit();      // set up interrupt controller
    80000f66:	00005097          	auipc	ra,0x5
    80000f6a:	d24080e7          	jalr	-732(ra) # 80005c8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	d32080e7          	jalr	-718(ra) # 80005ca0 <plicinithart>
    binit();         // buffer cache
    80000f76:	00002097          	auipc	ra,0x2
    80000f7a:	ece080e7          	jalr	-306(ra) # 80002e44 <binit>
    iinit();         // inode table
    80000f7e:	00002097          	auipc	ra,0x2
    80000f82:	56e080e7          	jalr	1390(ra) # 800034ec <iinit>
    fileinit();      // file table
    80000f86:	00003097          	auipc	ra,0x3
    80000f8a:	514080e7          	jalr	1300(ra) # 8000449a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	e1a080e7          	jalr	-486(ra) # 80005da8 <virtio_disk_init>
    userinit();      // first user process
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	d1e080e7          	jalr	-738(ra) # 80001cb4 <userinit>
    __sync_synchronize();
    80000f9e:	0ff0000f          	fence
    started = 1;
    80000fa2:	4785                	li	a5,1
    80000fa4:	00008717          	auipc	a4,0x8
    80000fa8:	96f72a23          	sw	a5,-1676(a4) # 80008918 <started>
    80000fac:	b70d                	j	80000ece <main+0x56>

0000000080000fae <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fae:	1141                	addi	sp,sp,-16
    80000fb0:	e422                	sd	s0,8(sp)
    80000fb2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb8:	00008797          	auipc	a5,0x8
    80000fbc:	9687b783          	ld	a5,-1688(a5) # 80008920 <kernel_pagetable>
    80000fc0:	83b1                	srli	a5,a5,0xc
    80000fc2:	577d                	li	a4,-1
    80000fc4:	177e                	slli	a4,a4,0x3f
    80000fc6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fcc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fd0:	6422                	ld	s0,8(sp)
    80000fd2:	0141                	addi	sp,sp,16
    80000fd4:	8082                	ret

0000000080000fd6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd6:	7139                	addi	sp,sp,-64
    80000fd8:	fc06                	sd	ra,56(sp)
    80000fda:	f822                	sd	s0,48(sp)
    80000fdc:	f426                	sd	s1,40(sp)
    80000fde:	f04a                	sd	s2,32(sp)
    80000fe0:	ec4e                	sd	s3,24(sp)
    80000fe2:	e852                	sd	s4,16(sp)
    80000fe4:	e456                	sd	s5,8(sp)
    80000fe6:	e05a                	sd	s6,0(sp)
    80000fe8:	0080                	addi	s0,sp,64
    80000fea:	84aa                	mv	s1,a0
    80000fec:	89ae                	mv	s3,a1
    80000fee:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ff0:	57fd                	li	a5,-1
    80000ff2:	83e9                	srli	a5,a5,0x1a
    80000ff4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff8:	04b7f263          	bgeu	a5,a1,8000103c <walk+0x66>
    panic("walk");
    80000ffc:	00007517          	auipc	a0,0x7
    80001000:	0fc50513          	addi	a0,a0,252 # 800080f8 <digits+0xb8>
    80001004:	fffff097          	auipc	ra,0xfffff
    80001008:	53c080e7          	jalr	1340(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000100c:	060a8663          	beqz	s5,80001078 <walk+0xa2>
    80001010:	00000097          	auipc	ra,0x0
    80001014:	ad6080e7          	jalr	-1322(ra) # 80000ae6 <kalloc>
    80001018:	84aa                	mv	s1,a0
    8000101a:	c529                	beqz	a0,80001064 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000101c:	6605                	lui	a2,0x1
    8000101e:	4581                	li	a1,0
    80001020:	00000097          	auipc	ra,0x0
    80001024:	cb2080e7          	jalr	-846(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001028:	00c4d793          	srli	a5,s1,0xc
    8000102c:	07aa                	slli	a5,a5,0xa
    8000102e:	0017e793          	ori	a5,a5,1
    80001032:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001036:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd047>
    80001038:	036a0063          	beq	s4,s6,80001058 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000103c:	0149d933          	srl	s2,s3,s4
    80001040:	1ff97913          	andi	s2,s2,511
    80001044:	090e                	slli	s2,s2,0x3
    80001046:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001048:	00093483          	ld	s1,0(s2)
    8000104c:	0014f793          	andi	a5,s1,1
    80001050:	dfd5                	beqz	a5,8000100c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001052:	80a9                	srli	s1,s1,0xa
    80001054:	04b2                	slli	s1,s1,0xc
    80001056:	b7c5                	j	80001036 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001058:	00c9d513          	srli	a0,s3,0xc
    8000105c:	1ff57513          	andi	a0,a0,511
    80001060:	050e                	slli	a0,a0,0x3
    80001062:	9526                	add	a0,a0,s1
}
    80001064:	70e2                	ld	ra,56(sp)
    80001066:	7442                	ld	s0,48(sp)
    80001068:	74a2                	ld	s1,40(sp)
    8000106a:	7902                	ld	s2,32(sp)
    8000106c:	69e2                	ld	s3,24(sp)
    8000106e:	6a42                	ld	s4,16(sp)
    80001070:	6aa2                	ld	s5,8(sp)
    80001072:	6b02                	ld	s6,0(sp)
    80001074:	6121                	addi	sp,sp,64
    80001076:	8082                	ret
        return 0;
    80001078:	4501                	li	a0,0
    8000107a:	b7ed                	j	80001064 <walk+0x8e>

000000008000107c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000107c:	57fd                	li	a5,-1
    8000107e:	83e9                	srli	a5,a5,0x1a
    80001080:	00b7f463          	bgeu	a5,a1,80001088 <walkaddr+0xc>
    return 0;
    80001084:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001086:	8082                	ret
{
    80001088:	1141                	addi	sp,sp,-16
    8000108a:	e406                	sd	ra,8(sp)
    8000108c:	e022                	sd	s0,0(sp)
    8000108e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001090:	4601                	li	a2,0
    80001092:	00000097          	auipc	ra,0x0
    80001096:	f44080e7          	jalr	-188(ra) # 80000fd6 <walk>
  if(pte == 0)
    8000109a:	c105                	beqz	a0,800010ba <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000109c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109e:	0117f693          	andi	a3,a5,17
    800010a2:	4745                	li	a4,17
    return 0;
    800010a4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a6:	00e68663          	beq	a3,a4,800010b2 <walkaddr+0x36>
}
    800010aa:	60a2                	ld	ra,8(sp)
    800010ac:	6402                	ld	s0,0(sp)
    800010ae:	0141                	addi	sp,sp,16
    800010b0:	8082                	ret
  pa = PTE2PA(*pte);
    800010b2:	83a9                	srli	a5,a5,0xa
    800010b4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010b8:	bfcd                	j	800010aa <walkaddr+0x2e>
    return 0;
    800010ba:	4501                	li	a0,0
    800010bc:	b7fd                	j	800010aa <walkaddr+0x2e>

00000000800010be <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010be:	715d                	addi	sp,sp,-80
    800010c0:	e486                	sd	ra,72(sp)
    800010c2:	e0a2                	sd	s0,64(sp)
    800010c4:	fc26                	sd	s1,56(sp)
    800010c6:	f84a                	sd	s2,48(sp)
    800010c8:	f44e                	sd	s3,40(sp)
    800010ca:	f052                	sd	s4,32(sp)
    800010cc:	ec56                	sd	s5,24(sp)
    800010ce:	e85a                	sd	s6,16(sp)
    800010d0:	e45e                	sd	s7,8(sp)
    800010d2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d4:	c639                	beqz	a2,80001122 <mappages+0x64>
    800010d6:	8aaa                	mv	s5,a0
    800010d8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010da:	777d                	lui	a4,0xfffff
    800010dc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010e0:	fff58993          	addi	s3,a1,-1
    800010e4:	99b2                	add	s3,s3,a2
    800010e6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ea:	893e                	mv	s2,a5
    800010ec:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010f0:	6b85                	lui	s7,0x1
    800010f2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	4605                	li	a2,1
    800010f8:	85ca                	mv	a1,s2
    800010fa:	8556                	mv	a0,s5
    800010fc:	00000097          	auipc	ra,0x0
    80001100:	eda080e7          	jalr	-294(ra) # 80000fd6 <walk>
    80001104:	cd1d                	beqz	a0,80001142 <mappages+0x84>
    if(*pte & PTE_V)
    80001106:	611c                	ld	a5,0(a0)
    80001108:	8b85                	andi	a5,a5,1
    8000110a:	e785                	bnez	a5,80001132 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000110c:	80b1                	srli	s1,s1,0xc
    8000110e:	04aa                	slli	s1,s1,0xa
    80001110:	0164e4b3          	or	s1,s1,s6
    80001114:	0014e493          	ori	s1,s1,1
    80001118:	e104                	sd	s1,0(a0)
    if(a == last)
    8000111a:	05390063          	beq	s2,s3,8000115a <mappages+0x9c>
    a += PGSIZE;
    8000111e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001120:	bfc9                	j	800010f2 <mappages+0x34>
    panic("mappages: size");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	fde50513          	addi	a0,a0,-34 # 80008100 <digits+0xc0>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	416080e7          	jalr	1046(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	fde50513          	addi	a0,a0,-34 # 80008110 <digits+0xd0>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	406080e7          	jalr	1030(ra) # 80000540 <panic>
      return -1;
    80001142:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret
  return 0;
    8000115a:	4501                	li	a0,0
    8000115c:	b7e5                	j	80001144 <mappages+0x86>

000000008000115e <kvmmap>:
{
    8000115e:	1141                	addi	sp,sp,-16
    80001160:	e406                	sd	ra,8(sp)
    80001162:	e022                	sd	s0,0(sp)
    80001164:	0800                	addi	s0,sp,16
    80001166:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001168:	86b2                	mv	a3,a2
    8000116a:	863e                	mv	a2,a5
    8000116c:	00000097          	auipc	ra,0x0
    80001170:	f52080e7          	jalr	-174(ra) # 800010be <mappages>
    80001174:	e509                	bnez	a0,8000117e <kvmmap+0x20>
}
    80001176:	60a2                	ld	ra,8(sp)
    80001178:	6402                	ld	s0,0(sp)
    8000117a:	0141                	addi	sp,sp,16
    8000117c:	8082                	ret
    panic("kvmmap");
    8000117e:	00007517          	auipc	a0,0x7
    80001182:	fa250513          	addi	a0,a0,-94 # 80008120 <digits+0xe0>
    80001186:	fffff097          	auipc	ra,0xfffff
    8000118a:	3ba080e7          	jalr	954(ra) # 80000540 <panic>

000000008000118e <kvmmake>:
{
    8000118e:	1101                	addi	sp,sp,-32
    80001190:	ec06                	sd	ra,24(sp)
    80001192:	e822                	sd	s0,16(sp)
    80001194:	e426                	sd	s1,8(sp)
    80001196:	e04a                	sd	s2,0(sp)
    80001198:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	94c080e7          	jalr	-1716(ra) # 80000ae6 <kalloc>
    800011a2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a4:	6605                	lui	a2,0x1
    800011a6:	4581                	li	a1,0
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	b2a080e7          	jalr	-1238(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10000637          	lui	a2,0x10000
    800011b8:	100005b7          	lui	a1,0x10000
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	fa0080e7          	jalr	-96(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	6685                	lui	a3,0x1
    800011ca:	10001637          	lui	a2,0x10001
    800011ce:	100015b7          	lui	a1,0x10001
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f8a080e7          	jalr	-118(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011dc:	4719                	li	a4,6
    800011de:	004006b7          	lui	a3,0x400
    800011e2:	0c000637          	lui	a2,0xc000
    800011e6:	0c0005b7          	lui	a1,0xc000
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f72080e7          	jalr	-142(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f4:	00007917          	auipc	s2,0x7
    800011f8:	e0c90913          	addi	s2,s2,-500 # 80008000 <etext>
    800011fc:	4729                	li	a4,10
    800011fe:	80007697          	auipc	a3,0x80007
    80001202:	e0268693          	addi	a3,a3,-510 # 8000 <_entry-0x7fff8000>
    80001206:	4605                	li	a2,1
    80001208:	067e                	slli	a2,a2,0x1f
    8000120a:	85b2                	mv	a1,a2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f50080e7          	jalr	-176(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	46c5                	li	a3,17
    8000121a:	06ee                	slli	a3,a3,0x1b
    8000121c:	412686b3          	sub	a3,a3,s2
    80001220:	864a                	mv	a2,s2
    80001222:	85ca                	mv	a1,s2
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f38080e7          	jalr	-200(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122e:	4729                	li	a4,10
    80001230:	6685                	lui	a3,0x1
    80001232:	00006617          	auipc	a2,0x6
    80001236:	dce60613          	addi	a2,a2,-562 # 80007000 <_trampoline>
    8000123a:	040005b7          	lui	a1,0x4000
    8000123e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001240:	05b2                	slli	a1,a1,0xc
    80001242:	8526                	mv	a0,s1
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f1a080e7          	jalr	-230(ra) # 8000115e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000124c:	8526                	mv	a0,s1
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	608080e7          	jalr	1544(ra) # 80001856 <proc_mapstacks>
}
    80001256:	8526                	mv	a0,s1
    80001258:	60e2                	ld	ra,24(sp)
    8000125a:	6442                	ld	s0,16(sp)
    8000125c:	64a2                	ld	s1,8(sp)
    8000125e:	6902                	ld	s2,0(sp)
    80001260:	6105                	addi	sp,sp,32
    80001262:	8082                	ret

0000000080001264 <kvminit>:
{
    80001264:	1141                	addi	sp,sp,-16
    80001266:	e406                	sd	ra,8(sp)
    80001268:	e022                	sd	s0,0(sp)
    8000126a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f22080e7          	jalr	-222(ra) # 8000118e <kvmmake>
    80001274:	00007797          	auipc	a5,0x7
    80001278:	6aa7b623          	sd	a0,1708(a5) # 80008920 <kernel_pagetable>
}
    8000127c:	60a2                	ld	ra,8(sp)
    8000127e:	6402                	ld	s0,0(sp)
    80001280:	0141                	addi	sp,sp,16
    80001282:	8082                	ret

0000000080001284 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001284:	715d                	addi	sp,sp,-80
    80001286:	e486                	sd	ra,72(sp)
    80001288:	e0a2                	sd	s0,64(sp)
    8000128a:	fc26                	sd	s1,56(sp)
    8000128c:	f84a                	sd	s2,48(sp)
    8000128e:	f44e                	sd	s3,40(sp)
    80001290:	f052                	sd	s4,32(sp)
    80001292:	ec56                	sd	s5,24(sp)
    80001294:	e85a                	sd	s6,16(sp)
    80001296:	e45e                	sd	s7,8(sp)
    80001298:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000129a:	03459793          	slli	a5,a1,0x34
    8000129e:	e795                	bnez	a5,800012ca <uvmunmap+0x46>
    800012a0:	8a2a                	mv	s4,a0
    800012a2:	892e                	mv	s2,a1
    800012a4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a6:	0632                	slli	a2,a2,0xc
    800012a8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ac:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ae:	6b05                	lui	s6,0x1
    800012b0:	0735e263          	bltu	a1,s3,80001314 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b4:	60a6                	ld	ra,72(sp)
    800012b6:	6406                	ld	s0,64(sp)
    800012b8:	74e2                	ld	s1,56(sp)
    800012ba:	7942                	ld	s2,48(sp)
    800012bc:	79a2                	ld	s3,40(sp)
    800012be:	7a02                	ld	s4,32(sp)
    800012c0:	6ae2                	ld	s5,24(sp)
    800012c2:	6b42                	ld	s6,16(sp)
    800012c4:	6ba2                	ld	s7,8(sp)
    800012c6:	6161                	addi	sp,sp,80
    800012c8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e6650513          	addi	a0,a0,-410 # 80008150 <digits+0x110>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24e080e7          	jalr	590(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012fa:	00007517          	auipc	a0,0x7
    800012fe:	e6e50513          	addi	a0,a0,-402 # 80008168 <digits+0x128>
    80001302:	fffff097          	auipc	ra,0xfffff
    80001306:	23e080e7          	jalr	574(ra) # 80000540 <panic>
    *pte = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130e:	995a                	add	s2,s2,s6
    80001310:	fb3972e3          	bgeu	s2,s3,800012b4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001314:	4601                	li	a2,0
    80001316:	85ca                	mv	a1,s2
    80001318:	8552                	mv	a0,s4
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	cbc080e7          	jalr	-836(ra) # 80000fd6 <walk>
    80001322:	84aa                	mv	s1,a0
    80001324:	d95d                	beqz	a0,800012da <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001326:	6108                	ld	a0,0(a0)
    80001328:	00157793          	andi	a5,a0,1
    8000132c:	dfdd                	beqz	a5,800012ea <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132e:	3ff57793          	andi	a5,a0,1023
    80001332:	fd7784e3          	beq	a5,s7,800012fa <uvmunmap+0x76>
    if(do_free){
    80001336:	fc0a8ae3          	beqz	s5,8000130a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000133a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000133c:	0532                	slli	a0,a0,0xc
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	6aa080e7          	jalr	1706(ra) # 800009e8 <kfree>
    80001346:	b7d1                	j	8000130a <uvmunmap+0x86>

0000000080001348 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001348:	1101                	addi	sp,sp,-32
    8000134a:	ec06                	sd	ra,24(sp)
    8000134c:	e822                	sd	s0,16(sp)
    8000134e:	e426                	sd	s1,8(sp)
    80001350:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001352:	fffff097          	auipc	ra,0xfffff
    80001356:	794080e7          	jalr	1940(ra) # 80000ae6 <kalloc>
    8000135a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000135c:	c519                	beqz	a0,8000136a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135e:	6605                	lui	a2,0x1
    80001360:	4581                	li	a1,0
    80001362:	00000097          	auipc	ra,0x0
    80001366:	970080e7          	jalr	-1680(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000136a:	8526                	mv	a0,s1
    8000136c:	60e2                	ld	ra,24(sp)
    8000136e:	6442                	ld	s0,16(sp)
    80001370:	64a2                	ld	s1,8(sp)
    80001372:	6105                	addi	sp,sp,32
    80001374:	8082                	ret

0000000080001376 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001376:	7179                	addi	sp,sp,-48
    80001378:	f406                	sd	ra,40(sp)
    8000137a:	f022                	sd	s0,32(sp)
    8000137c:	ec26                	sd	s1,24(sp)
    8000137e:	e84a                	sd	s2,16(sp)
    80001380:	e44e                	sd	s3,8(sp)
    80001382:	e052                	sd	s4,0(sp)
    80001384:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001386:	6785                	lui	a5,0x1
    80001388:	04f67863          	bgeu	a2,a5,800013d8 <uvmfirst+0x62>
    8000138c:	8a2a                	mv	s4,a0
    8000138e:	89ae                	mv	s3,a1
    80001390:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	754080e7          	jalr	1876(ra) # 80000ae6 <kalloc>
    8000139a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	932080e7          	jalr	-1742(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a8:	4779                	li	a4,30
    800013aa:	86ca                	mv	a3,s2
    800013ac:	6605                	lui	a2,0x1
    800013ae:	4581                	li	a1,0
    800013b0:	8552                	mv	a0,s4
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	d0c080e7          	jalr	-756(ra) # 800010be <mappages>
  memmove(mem, src, sz);
    800013ba:	8626                	mv	a2,s1
    800013bc:	85ce                	mv	a1,s3
    800013be:	854a                	mv	a0,s2
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	96e080e7          	jalr	-1682(ra) # 80000d2e <memmove>
}
    800013c8:	70a2                	ld	ra,40(sp)
    800013ca:	7402                	ld	s0,32(sp)
    800013cc:	64e2                	ld	s1,24(sp)
    800013ce:	6942                	ld	s2,16(sp)
    800013d0:	69a2                	ld	s3,8(sp)
    800013d2:	6a02                	ld	s4,0(sp)
    800013d4:	6145                	addi	sp,sp,48
    800013d6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d8:	00007517          	auipc	a0,0x7
    800013dc:	da850513          	addi	a0,a0,-600 # 80008180 <digits+0x140>
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	160080e7          	jalr	352(ra) # 80000540 <panic>

00000000800013e8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e8:	1101                	addi	sp,sp,-32
    800013ea:	ec06                	sd	ra,24(sp)
    800013ec:	e822                	sd	s0,16(sp)
    800013ee:	e426                	sd	s1,8(sp)
    800013f0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013f2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f4:	00b67d63          	bgeu	a2,a1,8000140e <uvmdealloc+0x26>
    800013f8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013fa:	6785                	lui	a5,0x1
    800013fc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013fe:	00f60733          	add	a4,a2,a5
    80001402:	76fd                	lui	a3,0xfffff
    80001404:	8f75                	and	a4,a4,a3
    80001406:	97ae                	add	a5,a5,a1
    80001408:	8ff5                	and	a5,a5,a3
    8000140a:	00f76863          	bltu	a4,a5,8000141a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140e:	8526                	mv	a0,s1
    80001410:	60e2                	ld	ra,24(sp)
    80001412:	6442                	ld	s0,16(sp)
    80001414:	64a2                	ld	s1,8(sp)
    80001416:	6105                	addi	sp,sp,32
    80001418:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000141a:	8f99                	sub	a5,a5,a4
    8000141c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141e:	4685                	li	a3,1
    80001420:	0007861b          	sext.w	a2,a5
    80001424:	85ba                	mv	a1,a4
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	e5e080e7          	jalr	-418(ra) # 80001284 <uvmunmap>
    8000142e:	b7c5                	j	8000140e <uvmdealloc+0x26>

0000000080001430 <uvmalloc>:
  if(newsz < oldsz)
    80001430:	0ab66563          	bltu	a2,a1,800014da <uvmalloc+0xaa>
{
    80001434:	7139                	addi	sp,sp,-64
    80001436:	fc06                	sd	ra,56(sp)
    80001438:	f822                	sd	s0,48(sp)
    8000143a:	f426                	sd	s1,40(sp)
    8000143c:	f04a                	sd	s2,32(sp)
    8000143e:	ec4e                	sd	s3,24(sp)
    80001440:	e852                	sd	s4,16(sp)
    80001442:	e456                	sd	s5,8(sp)
    80001444:	e05a                	sd	s6,0(sp)
    80001446:	0080                	addi	s0,sp,64
    80001448:	8aaa                	mv	s5,a0
    8000144a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000144c:	6785                	lui	a5,0x1
    8000144e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001450:	95be                	add	a1,a1,a5
    80001452:	77fd                	lui	a5,0xfffff
    80001454:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001458:	08c9f363          	bgeu	s3,a2,800014de <uvmalloc+0xae>
    8000145c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001462:	fffff097          	auipc	ra,0xfffff
    80001466:	684080e7          	jalr	1668(ra) # 80000ae6 <kalloc>
    8000146a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000146c:	c51d                	beqz	a0,8000149a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146e:	6605                	lui	a2,0x1
    80001470:	4581                	li	a1,0
    80001472:	00000097          	auipc	ra,0x0
    80001476:	860080e7          	jalr	-1952(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000147a:	875a                	mv	a4,s6
    8000147c:	86a6                	mv	a3,s1
    8000147e:	6605                	lui	a2,0x1
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	c3a080e7          	jalr	-966(ra) # 800010be <mappages>
    8000148c:	e90d                	bnez	a0,800014be <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148e:	6785                	lui	a5,0x1
    80001490:	993e                	add	s2,s2,a5
    80001492:	fd4968e3          	bltu	s2,s4,80001462 <uvmalloc+0x32>
  return newsz;
    80001496:	8552                	mv	a0,s4
    80001498:	a809                	j	800014aa <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000149a:	864e                	mv	a2,s3
    8000149c:	85ca                	mv	a1,s2
    8000149e:	8556                	mv	a0,s5
    800014a0:	00000097          	auipc	ra,0x0
    800014a4:	f48080e7          	jalr	-184(ra) # 800013e8 <uvmdealloc>
      return 0;
    800014a8:	4501                	li	a0,0
}
    800014aa:	70e2                	ld	ra,56(sp)
    800014ac:	7442                	ld	s0,48(sp)
    800014ae:	74a2                	ld	s1,40(sp)
    800014b0:	7902                	ld	s2,32(sp)
    800014b2:	69e2                	ld	s3,24(sp)
    800014b4:	6a42                	ld	s4,16(sp)
    800014b6:	6aa2                	ld	s5,8(sp)
    800014b8:	6b02                	ld	s6,0(sp)
    800014ba:	6121                	addi	sp,sp,64
    800014bc:	8082                	ret
      kfree(mem);
    800014be:	8526                	mv	a0,s1
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	528080e7          	jalr	1320(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c8:	864e                	mv	a2,s3
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	f1a080e7          	jalr	-230(ra) # 800013e8 <uvmdealloc>
      return 0;
    800014d6:	4501                	li	a0,0
    800014d8:	bfc9                	j	800014aa <uvmalloc+0x7a>
    return oldsz;
    800014da:	852e                	mv	a0,a1
}
    800014dc:	8082                	ret
  return newsz;
    800014de:	8532                	mv	a0,a2
    800014e0:	b7e9                	j	800014aa <uvmalloc+0x7a>

00000000800014e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014e2:	7179                	addi	sp,sp,-48
    800014e4:	f406                	sd	ra,40(sp)
    800014e6:	f022                	sd	s0,32(sp)
    800014e8:	ec26                	sd	s1,24(sp)
    800014ea:	e84a                	sd	s2,16(sp)
    800014ec:	e44e                	sd	s3,8(sp)
    800014ee:	e052                	sd	s4,0(sp)
    800014f0:	1800                	addi	s0,sp,48
    800014f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f4:	84aa                	mv	s1,a0
    800014f6:	6905                	lui	s2,0x1
    800014f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fa:	4985                	li	s3,1
    800014fc:	a829                	j	80001516 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fe:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001500:	00c79513          	slli	a0,a5,0xc
    80001504:	00000097          	auipc	ra,0x0
    80001508:	fde080e7          	jalr	-34(ra) # 800014e2 <freewalk>
      pagetable[i] = 0;
    8000150c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001510:	04a1                	addi	s1,s1,8
    80001512:	03248163          	beq	s1,s2,80001534 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001516:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001518:	00f7f713          	andi	a4,a5,15
    8000151c:	ff3701e3          	beq	a4,s3,800014fe <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001520:	8b85                	andi	a5,a5,1
    80001522:	d7fd                	beqz	a5,80001510 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001524:	00007517          	auipc	a0,0x7
    80001528:	c7c50513          	addi	a0,a0,-900 # 800081a0 <digits+0x160>
    8000152c:	fffff097          	auipc	ra,0xfffff
    80001530:	014080e7          	jalr	20(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001534:	8552                	mv	a0,s4
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	4b2080e7          	jalr	1202(ra) # 800009e8 <kfree>
}
    8000153e:	70a2                	ld	ra,40(sp)
    80001540:	7402                	ld	s0,32(sp)
    80001542:	64e2                	ld	s1,24(sp)
    80001544:	6942                	ld	s2,16(sp)
    80001546:	69a2                	ld	s3,8(sp)
    80001548:	6a02                	ld	s4,0(sp)
    8000154a:	6145                	addi	sp,sp,48
    8000154c:	8082                	ret

000000008000154e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000154e:	1101                	addi	sp,sp,-32
    80001550:	ec06                	sd	ra,24(sp)
    80001552:	e822                	sd	s0,16(sp)
    80001554:	e426                	sd	s1,8(sp)
    80001556:	1000                	addi	s0,sp,32
    80001558:	84aa                	mv	s1,a0
  if(sz > 0)
    8000155a:	e999                	bnez	a1,80001570 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000155c:	8526                	mv	a0,s1
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	f84080e7          	jalr	-124(ra) # 800014e2 <freewalk>
}
    80001566:	60e2                	ld	ra,24(sp)
    80001568:	6442                	ld	s0,16(sp)
    8000156a:	64a2                	ld	s1,8(sp)
    8000156c:	6105                	addi	sp,sp,32
    8000156e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001570:	6785                	lui	a5,0x1
    80001572:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001574:	95be                	add	a1,a1,a5
    80001576:	4685                	li	a3,1
    80001578:	00c5d613          	srli	a2,a1,0xc
    8000157c:	4581                	li	a1,0
    8000157e:	00000097          	auipc	ra,0x0
    80001582:	d06080e7          	jalr	-762(ra) # 80001284 <uvmunmap>
    80001586:	bfd9                	j	8000155c <uvmfree+0xe>

0000000080001588 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001588:	c679                	beqz	a2,80001656 <uvmcopy+0xce>
{
    8000158a:	715d                	addi	sp,sp,-80
    8000158c:	e486                	sd	ra,72(sp)
    8000158e:	e0a2                	sd	s0,64(sp)
    80001590:	fc26                	sd	s1,56(sp)
    80001592:	f84a                	sd	s2,48(sp)
    80001594:	f44e                	sd	s3,40(sp)
    80001596:	f052                	sd	s4,32(sp)
    80001598:	ec56                	sd	s5,24(sp)
    8000159a:	e85a                	sd	s6,16(sp)
    8000159c:	e45e                	sd	s7,8(sp)
    8000159e:	0880                	addi	s0,sp,80
    800015a0:	8b2a                	mv	s6,a0
    800015a2:	8aae                	mv	s5,a1
    800015a4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015a6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a8:	4601                	li	a2,0
    800015aa:	85ce                	mv	a1,s3
    800015ac:	855a                	mv	a0,s6
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	a28080e7          	jalr	-1496(ra) # 80000fd6 <walk>
    800015b6:	c531                	beqz	a0,80001602 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b8:	6118                	ld	a4,0(a0)
    800015ba:	00177793          	andi	a5,a4,1
    800015be:	cbb1                	beqz	a5,80001612 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015c0:	00a75593          	srli	a1,a4,0xa
    800015c4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	51a080e7          	jalr	1306(ra) # 80000ae6 <kalloc>
    800015d4:	892a                	mv	s2,a0
    800015d6:	c939                	beqz	a0,8000162c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d8:	6605                	lui	a2,0x1
    800015da:	85de                	mv	a1,s7
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	752080e7          	jalr	1874(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015e4:	8726                	mv	a4,s1
    800015e6:	86ca                	mv	a3,s2
    800015e8:	6605                	lui	a2,0x1
    800015ea:	85ce                	mv	a1,s3
    800015ec:	8556                	mv	a0,s5
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	ad0080e7          	jalr	-1328(ra) # 800010be <mappages>
    800015f6:	e515                	bnez	a0,80001622 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f8:	6785                	lui	a5,0x1
    800015fa:	99be                	add	s3,s3,a5
    800015fc:	fb49e6e3          	bltu	s3,s4,800015a8 <uvmcopy+0x20>
    80001600:	a081                	j	80001640 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001602:	00007517          	auipc	a0,0x7
    80001606:	bae50513          	addi	a0,a0,-1106 # 800081b0 <digits+0x170>
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	f36080e7          	jalr	-202(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    80001612:	00007517          	auipc	a0,0x7
    80001616:	bbe50513          	addi	a0,a0,-1090 # 800081d0 <digits+0x190>
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	f26080e7          	jalr	-218(ra) # 80000540 <panic>
      kfree(mem);
    80001622:	854a                	mv	a0,s2
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	3c4080e7          	jalr	964(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000162c:	4685                	li	a3,1
    8000162e:	00c9d613          	srli	a2,s3,0xc
    80001632:	4581                	li	a1,0
    80001634:	8556                	mv	a0,s5
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	c4e080e7          	jalr	-946(ra) # 80001284 <uvmunmap>
  return -1;
    8000163e:	557d                	li	a0,-1
}
    80001640:	60a6                	ld	ra,72(sp)
    80001642:	6406                	ld	s0,64(sp)
    80001644:	74e2                	ld	s1,56(sp)
    80001646:	7942                	ld	s2,48(sp)
    80001648:	79a2                	ld	s3,40(sp)
    8000164a:	7a02                	ld	s4,32(sp)
    8000164c:	6ae2                	ld	s5,24(sp)
    8000164e:	6b42                	ld	s6,16(sp)
    80001650:	6ba2                	ld	s7,8(sp)
    80001652:	6161                	addi	sp,sp,80
    80001654:	8082                	ret
  return 0;
    80001656:	4501                	li	a0,0
}
    80001658:	8082                	ret

000000008000165a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000165a:	1141                	addi	sp,sp,-16
    8000165c:	e406                	sd	ra,8(sp)
    8000165e:	e022                	sd	s0,0(sp)
    80001660:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001662:	4601                	li	a2,0
    80001664:	00000097          	auipc	ra,0x0
    80001668:	972080e7          	jalr	-1678(ra) # 80000fd6 <walk>
  if(pte == 0)
    8000166c:	c901                	beqz	a0,8000167c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000166e:	611c                	ld	a5,0(a0)
    80001670:	9bbd                	andi	a5,a5,-17
    80001672:	e11c                	sd	a5,0(a0)
}
    80001674:	60a2                	ld	ra,8(sp)
    80001676:	6402                	ld	s0,0(sp)
    80001678:	0141                	addi	sp,sp,16
    8000167a:	8082                	ret
    panic("uvmclear");
    8000167c:	00007517          	auipc	a0,0x7
    80001680:	b7450513          	addi	a0,a0,-1164 # 800081f0 <digits+0x1b0>
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	ebc080e7          	jalr	-324(ra) # 80000540 <panic>

000000008000168c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000168c:	c6bd                	beqz	a3,800016fa <copyout+0x6e>
{
    8000168e:	715d                	addi	sp,sp,-80
    80001690:	e486                	sd	ra,72(sp)
    80001692:	e0a2                	sd	s0,64(sp)
    80001694:	fc26                	sd	s1,56(sp)
    80001696:	f84a                	sd	s2,48(sp)
    80001698:	f44e                	sd	s3,40(sp)
    8000169a:	f052                	sd	s4,32(sp)
    8000169c:	ec56                	sd	s5,24(sp)
    8000169e:	e85a                	sd	s6,16(sp)
    800016a0:	e45e                	sd	s7,8(sp)
    800016a2:	e062                	sd	s8,0(sp)
    800016a4:	0880                	addi	s0,sp,80
    800016a6:	8b2a                	mv	s6,a0
    800016a8:	8c2e                	mv	s8,a1
    800016aa:	8a32                	mv	s4,a2
    800016ac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ae:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016b0:	6a85                	lui	s5,0x1
    800016b2:	a015                	j	800016d6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b4:	9562                	add	a0,a0,s8
    800016b6:	0004861b          	sext.w	a2,s1
    800016ba:	85d2                	mv	a1,s4
    800016bc:	41250533          	sub	a0,a0,s2
    800016c0:	fffff097          	auipc	ra,0xfffff
    800016c4:	66e080e7          	jalr	1646(ra) # 80000d2e <memmove>

    len -= n;
    800016c8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016cc:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ce:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d2:	02098263          	beqz	s3,800016f6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016da:	85ca                	mv	a1,s2
    800016dc:	855a                	mv	a0,s6
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	99e080e7          	jalr	-1634(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    800016e6:	cd01                	beqz	a0,800016fe <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e8:	418904b3          	sub	s1,s2,s8
    800016ec:	94d6                	add	s1,s1,s5
    800016ee:	fc99f3e3          	bgeu	s3,s1,800016b4 <copyout+0x28>
    800016f2:	84ce                	mv	s1,s3
    800016f4:	b7c1                	j	800016b4 <copyout+0x28>
  }
  return 0;
    800016f6:	4501                	li	a0,0
    800016f8:	a021                	j	80001700 <copyout+0x74>
    800016fa:	4501                	li	a0,0
}
    800016fc:	8082                	ret
      return -1;
    800016fe:	557d                	li	a0,-1
}
    80001700:	60a6                	ld	ra,72(sp)
    80001702:	6406                	ld	s0,64(sp)
    80001704:	74e2                	ld	s1,56(sp)
    80001706:	7942                	ld	s2,48(sp)
    80001708:	79a2                	ld	s3,40(sp)
    8000170a:	7a02                	ld	s4,32(sp)
    8000170c:	6ae2                	ld	s5,24(sp)
    8000170e:	6b42                	ld	s6,16(sp)
    80001710:	6ba2                	ld	s7,8(sp)
    80001712:	6c02                	ld	s8,0(sp)
    80001714:	6161                	addi	sp,sp,80
    80001716:	8082                	ret

0000000080001718 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001718:	caa5                	beqz	a3,80001788 <copyin+0x70>
{
    8000171a:	715d                	addi	sp,sp,-80
    8000171c:	e486                	sd	ra,72(sp)
    8000171e:	e0a2                	sd	s0,64(sp)
    80001720:	fc26                	sd	s1,56(sp)
    80001722:	f84a                	sd	s2,48(sp)
    80001724:	f44e                	sd	s3,40(sp)
    80001726:	f052                	sd	s4,32(sp)
    80001728:	ec56                	sd	s5,24(sp)
    8000172a:	e85a                	sd	s6,16(sp)
    8000172c:	e45e                	sd	s7,8(sp)
    8000172e:	e062                	sd	s8,0(sp)
    80001730:	0880                	addi	s0,sp,80
    80001732:	8b2a                	mv	s6,a0
    80001734:	8a2e                	mv	s4,a1
    80001736:	8c32                	mv	s8,a2
    80001738:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000173a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000173c:	6a85                	lui	s5,0x1
    8000173e:	a01d                	j	80001764 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001740:	018505b3          	add	a1,a0,s8
    80001744:	0004861b          	sext.w	a2,s1
    80001748:	412585b3          	sub	a1,a1,s2
    8000174c:	8552                	mv	a0,s4
    8000174e:	fffff097          	auipc	ra,0xfffff
    80001752:	5e0080e7          	jalr	1504(ra) # 80000d2e <memmove>

    len -= n;
    80001756:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000175a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000175c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001760:	02098263          	beqz	s3,80001784 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001764:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ca                	mv	a1,s2
    8000176a:	855a                	mv	a0,s6
    8000176c:	00000097          	auipc	ra,0x0
    80001770:	910080e7          	jalr	-1776(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    80001774:	cd01                	beqz	a0,8000178c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001776:	418904b3          	sub	s1,s2,s8
    8000177a:	94d6                	add	s1,s1,s5
    8000177c:	fc99f2e3          	bgeu	s3,s1,80001740 <copyin+0x28>
    80001780:	84ce                	mv	s1,s3
    80001782:	bf7d                	j	80001740 <copyin+0x28>
  }
  return 0;
    80001784:	4501                	li	a0,0
    80001786:	a021                	j	8000178e <copyin+0x76>
    80001788:	4501                	li	a0,0
}
    8000178a:	8082                	ret
      return -1;
    8000178c:	557d                	li	a0,-1
}
    8000178e:	60a6                	ld	ra,72(sp)
    80001790:	6406                	ld	s0,64(sp)
    80001792:	74e2                	ld	s1,56(sp)
    80001794:	7942                	ld	s2,48(sp)
    80001796:	79a2                	ld	s3,40(sp)
    80001798:	7a02                	ld	s4,32(sp)
    8000179a:	6ae2                	ld	s5,24(sp)
    8000179c:	6b42                	ld	s6,16(sp)
    8000179e:	6ba2                	ld	s7,8(sp)
    800017a0:	6c02                	ld	s8,0(sp)
    800017a2:	6161                	addi	sp,sp,80
    800017a4:	8082                	ret

00000000800017a6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a6:	c2dd                	beqz	a3,8000184c <copyinstr+0xa6>
{
    800017a8:	715d                	addi	sp,sp,-80
    800017aa:	e486                	sd	ra,72(sp)
    800017ac:	e0a2                	sd	s0,64(sp)
    800017ae:	fc26                	sd	s1,56(sp)
    800017b0:	f84a                	sd	s2,48(sp)
    800017b2:	f44e                	sd	s3,40(sp)
    800017b4:	f052                	sd	s4,32(sp)
    800017b6:	ec56                	sd	s5,24(sp)
    800017b8:	e85a                	sd	s6,16(sp)
    800017ba:	e45e                	sd	s7,8(sp)
    800017bc:	0880                	addi	s0,sp,80
    800017be:	8a2a                	mv	s4,a0
    800017c0:	8b2e                	mv	s6,a1
    800017c2:	8bb2                	mv	s7,a2
    800017c4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c8:	6985                	lui	s3,0x1
    800017ca:	a02d                	j	800017f4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017cc:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017d0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d2:	37fd                	addiw	a5,a5,-1
    800017d4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d8:	60a6                	ld	ra,72(sp)
    800017da:	6406                	ld	s0,64(sp)
    800017dc:	74e2                	ld	s1,56(sp)
    800017de:	7942                	ld	s2,48(sp)
    800017e0:	79a2                	ld	s3,40(sp)
    800017e2:	7a02                	ld	s4,32(sp)
    800017e4:	6ae2                	ld	s5,24(sp)
    800017e6:	6b42                	ld	s6,16(sp)
    800017e8:	6ba2                	ld	s7,8(sp)
    800017ea:	6161                	addi	sp,sp,80
    800017ec:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ee:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f2:	c8a9                	beqz	s1,80001844 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017f4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f8:	85ca                	mv	a1,s2
    800017fa:	8552                	mv	a0,s4
    800017fc:	00000097          	auipc	ra,0x0
    80001800:	880080e7          	jalr	-1920(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    80001804:	c131                	beqz	a0,80001848 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001806:	417906b3          	sub	a3,s2,s7
    8000180a:	96ce                	add	a3,a3,s3
    8000180c:	00d4f363          	bgeu	s1,a3,80001812 <copyinstr+0x6c>
    80001810:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001812:	955e                	add	a0,a0,s7
    80001814:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001818:	daf9                	beqz	a3,800017ee <copyinstr+0x48>
    8000181a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000181c:	41650633          	sub	a2,a0,s6
    80001820:	fff48593          	addi	a1,s1,-1
    80001824:	95da                	add	a1,a1,s6
    while(n > 0){
    80001826:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001828:	00f60733          	add	a4,a2,a5
    8000182c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd050>
    80001830:	df51                	beqz	a4,800017cc <copyinstr+0x26>
        *dst = *p;
    80001832:	00e78023          	sb	a4,0(a5)
      --max;
    80001836:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000183a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183c:	fed796e3          	bne	a5,a3,80001828 <copyinstr+0x82>
      dst++;
    80001840:	8b3e                	mv	s6,a5
    80001842:	b775                	j	800017ee <copyinstr+0x48>
    80001844:	4781                	li	a5,0
    80001846:	b771                	j	800017d2 <copyinstr+0x2c>
      return -1;
    80001848:	557d                	li	a0,-1
    8000184a:	b779                	j	800017d8 <copyinstr+0x32>
  int got_null = 0;
    8000184c:	4781                	li	a5,0
  if(got_null){
    8000184e:	37fd                	addiw	a5,a5,-1
    80001850:	0007851b          	sext.w	a0,a5
}
    80001854:	8082                	ret

0000000080001856 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001856:	7139                	addi	sp,sp,-64
    80001858:	fc06                	sd	ra,56(sp)
    8000185a:	f822                	sd	s0,48(sp)
    8000185c:	f426                	sd	s1,40(sp)
    8000185e:	f04a                	sd	s2,32(sp)
    80001860:	ec4e                	sd	s3,24(sp)
    80001862:	e852                	sd	s4,16(sp)
    80001864:	e456                	sd	s5,8(sp)
    80001866:	e05a                	sd	s6,0(sp)
    80001868:	0080                	addi	s0,sp,64
    8000186a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186c:	0000f497          	auipc	s1,0xf
    80001870:	76448493          	addi	s1,s1,1892 # 80010fd0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001874:	8b26                	mv	s6,s1
    80001876:	00006a97          	auipc	s5,0x6
    8000187a:	78aa8a93          	addi	s5,s5,1930 # 80008000 <etext>
    8000187e:	04000937          	lui	s2,0x4000
    80001882:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001884:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	00015a17          	auipc	s4,0x15
    8000188a:	34aa0a13          	addi	s4,s4,842 # 80016bd0 <tickslock>
    char *pa = kalloc();
    8000188e:	fffff097          	auipc	ra,0xfffff
    80001892:	258080e7          	jalr	600(ra) # 80000ae6 <kalloc>
    80001896:	862a                	mv	a2,a0
    if(pa == 0)
    80001898:	c131                	beqz	a0,800018dc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000189a:	416485b3          	sub	a1,s1,s6
    8000189e:	8591                	srai	a1,a1,0x4
    800018a0:	000ab783          	ld	a5,0(s5)
    800018a4:	02f585b3          	mul	a1,a1,a5
    800018a8:	2585                	addiw	a1,a1,1
    800018aa:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ae:	4719                	li	a4,6
    800018b0:	6685                	lui	a3,0x1
    800018b2:	40b905b3          	sub	a1,s2,a1
    800018b6:	854e                	mv	a0,s3
    800018b8:	00000097          	auipc	ra,0x0
    800018bc:	8a6080e7          	jalr	-1882(ra) # 8000115e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c0:	17048493          	addi	s1,s1,368
    800018c4:	fd4495e3          	bne	s1,s4,8000188e <proc_mapstacks+0x38>
  }
}
    800018c8:	70e2                	ld	ra,56(sp)
    800018ca:	7442                	ld	s0,48(sp)
    800018cc:	74a2                	ld	s1,40(sp)
    800018ce:	7902                	ld	s2,32(sp)
    800018d0:	69e2                	ld	s3,24(sp)
    800018d2:	6a42                	ld	s4,16(sp)
    800018d4:	6aa2                	ld	s5,8(sp)
    800018d6:	6b02                	ld	s6,0(sp)
    800018d8:	6121                	addi	sp,sp,64
    800018da:	8082                	ret
      panic("kalloc");
    800018dc:	00007517          	auipc	a0,0x7
    800018e0:	92450513          	addi	a0,a0,-1756 # 80008200 <digits+0x1c0>
    800018e4:	fffff097          	auipc	ra,0xfffff
    800018e8:	c5c080e7          	jalr	-932(ra) # 80000540 <panic>

00000000800018ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ec:	7139                	addi	sp,sp,-64
    800018ee:	fc06                	sd	ra,56(sp)
    800018f0:	f822                	sd	s0,48(sp)
    800018f2:	f426                	sd	s1,40(sp)
    800018f4:	f04a                	sd	s2,32(sp)
    800018f6:	ec4e                	sd	s3,24(sp)
    800018f8:	e852                	sd	s4,16(sp)
    800018fa:	e456                	sd	s5,8(sp)
    800018fc:	e05a                	sd	s6,0(sp)
    800018fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	90858593          	addi	a1,a1,-1784 # 80008208 <digits+0x1c8>
    80001908:	0000f517          	auipc	a0,0xf
    8000190c:	29850513          	addi	a0,a0,664 # 80010ba0 <pid_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	236080e7          	jalr	566(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001918:	00007597          	auipc	a1,0x7
    8000191c:	8f858593          	addi	a1,a1,-1800 # 80008210 <digits+0x1d0>
    80001920:	0000f517          	auipc	a0,0xf
    80001924:	29850513          	addi	a0,a0,664 # 80010bb8 <wait_lock>
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	21e080e7          	jalr	542(ra) # 80000b46 <initlock>
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	0000f497          	auipc	s1,0xf
    80001934:	6a048493          	addi	s1,s1,1696 # 80010fd0 <proc>
      initlock(&p->lock, "proc");
    80001938:	00007b17          	auipc	s6,0x7
    8000193c:	8e8b0b13          	addi	s6,s6,-1816 # 80008220 <digits+0x1e0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001940:	8aa6                	mv	s5,s1
    80001942:	00006a17          	auipc	s4,0x6
    80001946:	6bea0a13          	addi	s4,s4,1726 # 80008000 <etext>
    8000194a:	04000937          	lui	s2,0x4000
    8000194e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001950:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001952:	00015997          	auipc	s3,0x15
    80001956:	27e98993          	addi	s3,s3,638 # 80016bd0 <tickslock>
      initlock(&p->lock, "proc");
    8000195a:	85da                	mv	a1,s6
    8000195c:	8526                	mv	a0,s1
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	1e8080e7          	jalr	488(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001966:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000196a:	415487b3          	sub	a5,s1,s5
    8000196e:	8791                	srai	a5,a5,0x4
    80001970:	000a3703          	ld	a4,0(s4)
    80001974:	02e787b3          	mul	a5,a5,a4
    80001978:	2785                	addiw	a5,a5,1
    8000197a:	00d7979b          	slliw	a5,a5,0xd
    8000197e:	40f907b3          	sub	a5,s2,a5
    80001982:	e0bc                	sd	a5,64(s1)
      p->times_exec = 0;
    80001984:	1604a623          	sw	zero,364(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001988:	17048493          	addi	s1,s1,368
    8000198c:	fd3497e3          	bne	s1,s3,8000195a <procinit+0x6e>
      
  }

  
}
    80001990:	70e2                	ld	ra,56(sp)
    80001992:	7442                	ld	s0,48(sp)
    80001994:	74a2                	ld	s1,40(sp)
    80001996:	7902                	ld	s2,32(sp)
    80001998:	69e2                	ld	s3,24(sp)
    8000199a:	6a42                	ld	s4,16(sp)
    8000199c:	6aa2                	ld	s5,8(sp)
    8000199e:	6b02                	ld	s6,0(sp)
    800019a0:	6121                	addi	sp,sp,64
    800019a2:	8082                	ret

00000000800019a4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019a4:	1141                	addi	sp,sp,-16
    800019a6:	e422                	sd	s0,8(sp)
    800019a8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019aa:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ac:	2501                	sext.w	a0,a0
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019b4:	1141                	addi	sp,sp,-16
    800019b6:	e422                	sd	s0,8(sp)
    800019b8:	0800                	addi	s0,sp,16
    800019ba:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019bc:	2781                	sext.w	a5,a5
    800019be:	079e                	slli	a5,a5,0x7
  return c;
}
    800019c0:	0000f517          	auipc	a0,0xf
    800019c4:	21050513          	addi	a0,a0,528 # 80010bd0 <cpus>
    800019c8:	953e                	add	a0,a0,a5
    800019ca:	6422                	ld	s0,8(sp)
    800019cc:	0141                	addi	sp,sp,16
    800019ce:	8082                	ret

00000000800019d0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	1000                	addi	s0,sp,32
  push_off();
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	1b0080e7          	jalr	432(ra) # 80000b8a <push_off>
    800019e2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019e4:	2781                	sext.w	a5,a5
    800019e6:	079e                	slli	a5,a5,0x7
    800019e8:	0000f717          	auipc	a4,0xf
    800019ec:	1b870713          	addi	a4,a4,440 # 80010ba0 <pid_lock>
    800019f0:	97ba                	add	a5,a5,a4
    800019f2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	236080e7          	jalr	566(ra) # 80000c2a <pop_off>
  return p;
}
    800019fc:	8526                	mv	a0,s1
    800019fe:	60e2                	ld	ra,24(sp)
    80001a00:	6442                	ld	s0,16(sp)
    80001a02:	64a2                	ld	s1,8(sp)
    80001a04:	6105                	addi	sp,sp,32
    80001a06:	8082                	ret

0000000080001a08 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a08:	1141                	addi	sp,sp,-16
    80001a0a:	e406                	sd	ra,8(sp)
    80001a0c:	e022                	sd	s0,0(sp)
    80001a0e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a10:	00000097          	auipc	ra,0x0
    80001a14:	fc0080e7          	jalr	-64(ra) # 800019d0 <myproc>
    80001a18:	fffff097          	auipc	ra,0xfffff
    80001a1c:	272080e7          	jalr	626(ra) # 80000c8a <release>

  if (first) {
    80001a20:	00007797          	auipc	a5,0x7
    80001a24:	e707a783          	lw	a5,-400(a5) # 80008890 <first.1>
    80001a28:	eb89                	bnez	a5,80001a3a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a2a:	00001097          	auipc	ra,0x1
    80001a2e:	cf6080e7          	jalr	-778(ra) # 80002720 <usertrapret>
}
    80001a32:	60a2                	ld	ra,8(sp)
    80001a34:	6402                	ld	s0,0(sp)
    80001a36:	0141                	addi	sp,sp,16
    80001a38:	8082                	ret
    first = 0;
    80001a3a:	00007797          	auipc	a5,0x7
    80001a3e:	e407ab23          	sw	zero,-426(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001a42:	4505                	li	a0,1
    80001a44:	00002097          	auipc	ra,0x2
    80001a48:	a28080e7          	jalr	-1496(ra) # 8000346c <fsinit>
    80001a4c:	bff9                	j	80001a2a <forkret+0x22>

0000000080001a4e <allocpid>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	e04a                	sd	s2,0(sp)
    80001a58:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a5a:	0000f917          	auipc	s2,0xf
    80001a5e:	14690913          	addi	s2,s2,326 # 80010ba0 <pid_lock>
    80001a62:	854a                	mv	a0,s2
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	172080e7          	jalr	370(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a6c:	00007797          	auipc	a5,0x7
    80001a70:	e2878793          	addi	a5,a5,-472 # 80008894 <nextpid>
    80001a74:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a76:	0014871b          	addiw	a4,s1,1
    80001a7a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a7c:	854a                	mv	a0,s2
    80001a7e:	fffff097          	auipc	ra,0xfffff
    80001a82:	20c080e7          	jalr	524(ra) # 80000c8a <release>
}
    80001a86:	8526                	mv	a0,s1
    80001a88:	60e2                	ld	ra,24(sp)
    80001a8a:	6442                	ld	s0,16(sp)
    80001a8c:	64a2                	ld	s1,8(sp)
    80001a8e:	6902                	ld	s2,0(sp)
    80001a90:	6105                	addi	sp,sp,32
    80001a92:	8082                	ret

0000000080001a94 <proc_pagetable>:
{
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	e04a                	sd	s2,0(sp)
    80001a9e:	1000                	addi	s0,sp,32
    80001aa0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	8a6080e7          	jalr	-1882(ra) # 80001348 <uvmcreate>
    80001aaa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aac:	c121                	beqz	a0,80001aec <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aae:	4729                	li	a4,10
    80001ab0:	00005697          	auipc	a3,0x5
    80001ab4:	55068693          	addi	a3,a3,1360 # 80007000 <_trampoline>
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	040005b7          	lui	a1,0x4000
    80001abe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac0:	05b2                	slli	a1,a1,0xc
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	5fc080e7          	jalr	1532(ra) # 800010be <mappages>
    80001aca:	02054863          	bltz	a0,80001afa <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ace:	4719                	li	a4,6
    80001ad0:	05893683          	ld	a3,88(s2)
    80001ad4:	6605                	lui	a2,0x1
    80001ad6:	020005b7          	lui	a1,0x2000
    80001ada:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001adc:	05b6                	slli	a1,a1,0xd
    80001ade:	8526                	mv	a0,s1
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	5de080e7          	jalr	1502(ra) # 800010be <mappages>
    80001ae8:	02054163          	bltz	a0,80001b0a <proc_pagetable+0x76>
}
    80001aec:	8526                	mv	a0,s1
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6902                	ld	s2,0(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret
    uvmfree(pagetable, 0);
    80001afa:	4581                	li	a1,0
    80001afc:	8526                	mv	a0,s1
    80001afe:	00000097          	auipc	ra,0x0
    80001b02:	a50080e7          	jalr	-1456(ra) # 8000154e <uvmfree>
    return 0;
    80001b06:	4481                	li	s1,0
    80001b08:	b7d5                	j	80001aec <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0a:	4681                	li	a3,0
    80001b0c:	4605                	li	a2,1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b14:	05b2                	slli	a1,a1,0xc
    80001b16:	8526                	mv	a0,s1
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	76c080e7          	jalr	1900(ra) # 80001284 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b20:	4581                	li	a1,0
    80001b22:	8526                	mv	a0,s1
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	a2a080e7          	jalr	-1494(ra) # 8000154e <uvmfree>
    return 0;
    80001b2c:	4481                	li	s1,0
    80001b2e:	bf7d                	j	80001aec <proc_pagetable+0x58>

0000000080001b30 <proc_freepagetable>:
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	e04a                	sd	s2,0(sp)
    80001b3a:	1000                	addi	s0,sp,32
    80001b3c:	84aa                	mv	s1,a0
    80001b3e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b40:	4681                	li	a3,0
    80001b42:	4605                	li	a2,1
    80001b44:	040005b7          	lui	a1,0x4000
    80001b48:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b4a:	05b2                	slli	a1,a1,0xc
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	738080e7          	jalr	1848(ra) # 80001284 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b54:	4681                	li	a3,0
    80001b56:	4605                	li	a2,1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	722080e7          	jalr	1826(ra) # 80001284 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b6a:	85ca                	mv	a1,s2
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	00000097          	auipc	ra,0x0
    80001b72:	9e0080e7          	jalr	-1568(ra) # 8000154e <uvmfree>
}
    80001b76:	60e2                	ld	ra,24(sp)
    80001b78:	6442                	ld	s0,16(sp)
    80001b7a:	64a2                	ld	s1,8(sp)
    80001b7c:	6902                	ld	s2,0(sp)
    80001b7e:	6105                	addi	sp,sp,32
    80001b80:	8082                	ret

0000000080001b82 <freeproc>:
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	e426                	sd	s1,8(sp)
    80001b8a:	1000                	addi	s0,sp,32
    80001b8c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b8e:	6d28                	ld	a0,88(a0)
    80001b90:	c509                	beqz	a0,80001b9a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	e56080e7          	jalr	-426(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b9a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b9e:	68a8                	ld	a0,80(s1)
    80001ba0:	c511                	beqz	a0,80001bac <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ba2:	64ac                	ld	a1,72(s1)
    80001ba4:	00000097          	auipc	ra,0x0
    80001ba8:	f8c080e7          	jalr	-116(ra) # 80001b30 <proc_freepagetable>
  p->pagetable = 0;
    80001bac:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bb0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bb4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bbc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bc0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bcc:	0004ac23          	sw	zero,24(s1)
  p->times_exec = 0;
    80001bd0:	1604a623          	sw	zero,364(s1)
  p->prio = 0;
    80001bd4:	1604a423          	sw	zero,360(s1)
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6105                	addi	sp,sp,32
    80001be0:	8082                	ret

0000000080001be2 <allocproc>:
{
    80001be2:	1101                	addi	sp,sp,-32
    80001be4:	ec06                	sd	ra,24(sp)
    80001be6:	e822                	sd	s0,16(sp)
    80001be8:	e426                	sd	s1,8(sp)
    80001bea:	e04a                	sd	s2,0(sp)
    80001bec:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bee:	0000f497          	auipc	s1,0xf
    80001bf2:	3e248493          	addi	s1,s1,994 # 80010fd0 <proc>
    80001bf6:	00015917          	auipc	s2,0x15
    80001bfa:	fda90913          	addi	s2,s2,-38 # 80016bd0 <tickslock>
    acquire(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	fd6080e7          	jalr	-42(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001c08:	4c9c                	lw	a5,24(s1)
    80001c0a:	cf81                	beqz	a5,80001c22 <allocproc+0x40>
      release(&p->lock);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	07c080e7          	jalr	124(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c16:	17048493          	addi	s1,s1,368
    80001c1a:	ff2492e3          	bne	s1,s2,80001bfe <allocproc+0x1c>
  return 0;
    80001c1e:	4481                	li	s1,0
    80001c20:	a899                	j	80001c76 <allocproc+0x94>
  p->pid = allocpid();
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	e2c080e7          	jalr	-468(ra) # 80001a4e <allocpid>
    80001c2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c2c:	4785                	li	a5,1
    80001c2e:	cc9c                	sw	a5,24(s1)
  p->prio = 0; 
    80001c30:	1604a423          	sw	zero,360(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	eb2080e7          	jalr	-334(ra) # 80000ae6 <kalloc>
    80001c3c:	892a                	mv	s2,a0
    80001c3e:	eca8                	sd	a0,88(s1)
    80001c40:	c131                	beqz	a0,80001c84 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c42:	8526                	mv	a0,s1
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	e50080e7          	jalr	-432(ra) # 80001a94 <proc_pagetable>
    80001c4c:	892a                	mv	s2,a0
    80001c4e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c50:	c531                	beqz	a0,80001c9c <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c52:	07000613          	li	a2,112
    80001c56:	4581                	li	a1,0
    80001c58:	06048513          	addi	a0,s1,96
    80001c5c:	fffff097          	auipc	ra,0xfffff
    80001c60:	076080e7          	jalr	118(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c64:	00000797          	auipc	a5,0x0
    80001c68:	da478793          	addi	a5,a5,-604 # 80001a08 <forkret>
    80001c6c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c6e:	60bc                	ld	a5,64(s1)
    80001c70:	6705                	lui	a4,0x1
    80001c72:	97ba                	add	a5,a5,a4
    80001c74:	f4bc                	sd	a5,104(s1)
}
    80001c76:	8526                	mv	a0,s1
    80001c78:	60e2                	ld	ra,24(sp)
    80001c7a:	6442                	ld	s0,16(sp)
    80001c7c:	64a2                	ld	s1,8(sp)
    80001c7e:	6902                	ld	s2,0(sp)
    80001c80:	6105                	addi	sp,sp,32
    80001c82:	8082                	ret
    freeproc(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	efc080e7          	jalr	-260(ra) # 80001b82 <freeproc>
    release(&p->lock);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ffa080e7          	jalr	-6(ra) # 80000c8a <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	bff1                	j	80001c76 <allocproc+0x94>
    freeproc(p);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	ee4080e7          	jalr	-284(ra) # 80001b82 <freeproc>
    release(&p->lock);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	fe2080e7          	jalr	-30(ra) # 80000c8a <release>
    return 0;
    80001cb0:	84ca                	mv	s1,s2
    80001cb2:	b7d1                	j	80001c76 <allocproc+0x94>

0000000080001cb4 <userinit>:
{
    80001cb4:	1101                	addi	sp,sp,-32
    80001cb6:	ec06                	sd	ra,24(sp)
    80001cb8:	e822                	sd	s0,16(sp)
    80001cba:	e426                	sd	s1,8(sp)
    80001cbc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cbe:	00000097          	auipc	ra,0x0
    80001cc2:	f24080e7          	jalr	-220(ra) # 80001be2 <allocproc>
    80001cc6:	84aa                	mv	s1,a0
  initproc = p;
    80001cc8:	00007797          	auipc	a5,0x7
    80001ccc:	c6a7b023          	sd	a0,-928(a5) # 80008928 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd0:	03400613          	li	a2,52
    80001cd4:	00007597          	auipc	a1,0x7
    80001cd8:	bcc58593          	addi	a1,a1,-1076 # 800088a0 <initcode>
    80001cdc:	6928                	ld	a0,80(a0)
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	698080e7          	jalr	1688(ra) # 80001376 <uvmfirst>
  p->sz = PGSIZE;
    80001ce6:	6785                	lui	a5,0x1
    80001ce8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cea:	6cb8                	ld	a4,88(s1)
    80001cec:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cf0:	6cb8                	ld	a4,88(s1)
    80001cf2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf4:	4641                	li	a2,16
    80001cf6:	00006597          	auipc	a1,0x6
    80001cfa:	53258593          	addi	a1,a1,1330 # 80008228 <digits+0x1e8>
    80001cfe:	15848513          	addi	a0,s1,344
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	11a080e7          	jalr	282(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d0a:	00006517          	auipc	a0,0x6
    80001d0e:	52e50513          	addi	a0,a0,1326 # 80008238 <digits+0x1f8>
    80001d12:	00002097          	auipc	ra,0x2
    80001d16:	184080e7          	jalr	388(ra) # 80003e96 <namei>
    80001d1a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d1e:	478d                	li	a5,3
    80001d20:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d22:	8526                	mv	a0,s1
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	f66080e7          	jalr	-154(ra) # 80000c8a <release>
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret

0000000080001d36 <growproc>:
{
    80001d36:	1101                	addi	sp,sp,-32
    80001d38:	ec06                	sd	ra,24(sp)
    80001d3a:	e822                	sd	s0,16(sp)
    80001d3c:	e426                	sd	s1,8(sp)
    80001d3e:	e04a                	sd	s2,0(sp)
    80001d40:	1000                	addi	s0,sp,32
    80001d42:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	c8c080e7          	jalr	-884(ra) # 800019d0 <myproc>
    80001d4c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d4e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d50:	01204c63          	bgtz	s2,80001d68 <growproc+0x32>
  } else if(n < 0){
    80001d54:	02094663          	bltz	s2,80001d80 <growproc+0x4a>
  p->sz = sz;
    80001d58:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d5a:	4501                	li	a0,0
}
    80001d5c:	60e2                	ld	ra,24(sp)
    80001d5e:	6442                	ld	s0,16(sp)
    80001d60:	64a2                	ld	s1,8(sp)
    80001d62:	6902                	ld	s2,0(sp)
    80001d64:	6105                	addi	sp,sp,32
    80001d66:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d68:	4691                	li	a3,4
    80001d6a:	00b90633          	add	a2,s2,a1
    80001d6e:	6928                	ld	a0,80(a0)
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	6c0080e7          	jalr	1728(ra) # 80001430 <uvmalloc>
    80001d78:	85aa                	mv	a1,a0
    80001d7a:	fd79                	bnez	a0,80001d58 <growproc+0x22>
      return -1;
    80001d7c:	557d                	li	a0,-1
    80001d7e:	bff9                	j	80001d5c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d80:	00b90633          	add	a2,s2,a1
    80001d84:	6928                	ld	a0,80(a0)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	662080e7          	jalr	1634(ra) # 800013e8 <uvmdealloc>
    80001d8e:	85aa                	mv	a1,a0
    80001d90:	b7e1                	j	80001d58 <growproc+0x22>

0000000080001d92 <fork>:
{
    80001d92:	7139                	addi	sp,sp,-64
    80001d94:	fc06                	sd	ra,56(sp)
    80001d96:	f822                	sd	s0,48(sp)
    80001d98:	f426                	sd	s1,40(sp)
    80001d9a:	f04a                	sd	s2,32(sp)
    80001d9c:	ec4e                	sd	s3,24(sp)
    80001d9e:	e852                	sd	s4,16(sp)
    80001da0:	e456                	sd	s5,8(sp)
    80001da2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	c2c080e7          	jalr	-980(ra) # 800019d0 <myproc>
    80001dac:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	e34080e7          	jalr	-460(ra) # 80001be2 <allocproc>
    80001db6:	10050c63          	beqz	a0,80001ece <fork+0x13c>
    80001dba:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dbc:	048ab603          	ld	a2,72(s5)
    80001dc0:	692c                	ld	a1,80(a0)
    80001dc2:	050ab503          	ld	a0,80(s5)
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	7c2080e7          	jalr	1986(ra) # 80001588 <uvmcopy>
    80001dce:	04054863          	bltz	a0,80001e1e <fork+0x8c>
  np->sz = p->sz;
    80001dd2:	048ab783          	ld	a5,72(s5)
    80001dd6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dda:	058ab683          	ld	a3,88(s5)
    80001dde:	87b6                	mv	a5,a3
    80001de0:	058a3703          	ld	a4,88(s4)
    80001de4:	12068693          	addi	a3,a3,288
    80001de8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dec:	6788                	ld	a0,8(a5)
    80001dee:	6b8c                	ld	a1,16(a5)
    80001df0:	6f90                	ld	a2,24(a5)
    80001df2:	01073023          	sd	a6,0(a4)
    80001df6:	e708                	sd	a0,8(a4)
    80001df8:	eb0c                	sd	a1,16(a4)
    80001dfa:	ef10                	sd	a2,24(a4)
    80001dfc:	02078793          	addi	a5,a5,32
    80001e00:	02070713          	addi	a4,a4,32
    80001e04:	fed792e3          	bne	a5,a3,80001de8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e08:	058a3783          	ld	a5,88(s4)
    80001e0c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e10:	0d0a8493          	addi	s1,s5,208
    80001e14:	0d0a0913          	addi	s2,s4,208
    80001e18:	150a8993          	addi	s3,s5,336
    80001e1c:	a00d                	j	80001e3e <fork+0xac>
    freeproc(np);
    80001e1e:	8552                	mv	a0,s4
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	d62080e7          	jalr	-670(ra) # 80001b82 <freeproc>
    release(&np->lock);
    80001e28:	8552                	mv	a0,s4
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	e60080e7          	jalr	-416(ra) # 80000c8a <release>
    return -1;
    80001e32:	597d                	li	s2,-1
    80001e34:	a059                	j	80001eba <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e36:	04a1                	addi	s1,s1,8
    80001e38:	0921                	addi	s2,s2,8
    80001e3a:	01348b63          	beq	s1,s3,80001e50 <fork+0xbe>
    if(p->ofile[i])
    80001e3e:	6088                	ld	a0,0(s1)
    80001e40:	d97d                	beqz	a0,80001e36 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e42:	00002097          	auipc	ra,0x2
    80001e46:	6ea080e7          	jalr	1770(ra) # 8000452c <filedup>
    80001e4a:	00a93023          	sd	a0,0(s2)
    80001e4e:	b7e5                	j	80001e36 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e50:	150ab503          	ld	a0,336(s5)
    80001e54:	00002097          	auipc	ra,0x2
    80001e58:	858080e7          	jalr	-1960(ra) # 800036ac <idup>
    80001e5c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e60:	4641                	li	a2,16
    80001e62:	158a8593          	addi	a1,s5,344
    80001e66:	158a0513          	addi	a0,s4,344
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	fb2080e7          	jalr	-78(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e72:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e76:	8552                	mv	a0,s4
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e12080e7          	jalr	-494(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e80:	0000f497          	auipc	s1,0xf
    80001e84:	d3848493          	addi	s1,s1,-712 # 80010bb8 <wait_lock>
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d4c080e7          	jalr	-692(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e92:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e96:	8526                	mv	a0,s1
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	df2080e7          	jalr	-526(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ea0:	8552                	mv	a0,s4
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	d34080e7          	jalr	-716(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001eaa:	478d                	li	a5,3
    80001eac:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eb0:	8552                	mv	a0,s4
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	dd8080e7          	jalr	-552(ra) # 80000c8a <release>
}
    80001eba:	854a                	mv	a0,s2
    80001ebc:	70e2                	ld	ra,56(sp)
    80001ebe:	7442                	ld	s0,48(sp)
    80001ec0:	74a2                	ld	s1,40(sp)
    80001ec2:	7902                	ld	s2,32(sp)
    80001ec4:	69e2                	ld	s3,24(sp)
    80001ec6:	6a42                	ld	s4,16(sp)
    80001ec8:	6aa2                	ld	s5,8(sp)
    80001eca:	6121                	addi	sp,sp,64
    80001ecc:	8082                	ret
    return -1;
    80001ece:	597d                	li	s2,-1
    80001ed0:	b7ed                	j	80001eba <fork+0x128>

0000000080001ed2 <scheduler>:
{
    80001ed2:	711d                	addi	sp,sp,-96
    80001ed4:	ec86                	sd	ra,88(sp)
    80001ed6:	e8a2                	sd	s0,80(sp)
    80001ed8:	e4a6                	sd	s1,72(sp)
    80001eda:	e0ca                	sd	s2,64(sp)
    80001edc:	fc4e                	sd	s3,56(sp)
    80001ede:	f852                	sd	s4,48(sp)
    80001ee0:	f456                	sd	s5,40(sp)
    80001ee2:	f05a                	sd	s6,32(sp)
    80001ee4:	ec5e                	sd	s7,24(sp)
    80001ee6:	e862                	sd	s8,16(sp)
    80001ee8:	e466                	sd	s9,8(sp)
    80001eea:	1080                	addi	s0,sp,96
    80001eec:	8792                	mv	a5,tp
  int id = r_tp();
    80001eee:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ef0:	00779c13          	slli	s8,a5,0x7
    80001ef4:	0000f717          	auipc	a4,0xf
    80001ef8:	cac70713          	addi	a4,a4,-852 # 80010ba0 <pid_lock>
    80001efc:	9762                	add	a4,a4,s8
    80001efe:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f02:	0000f717          	auipc	a4,0xf
    80001f06:	cd670713          	addi	a4,a4,-810 # 80010bd8 <cpus+0x8>
    80001f0a:	9c3a                	add	s8,s8,a4
  int contador = 0;
    80001f0c:	4b01                	li	s6,0
      if(p->state == RUNNABLE) {
    80001f0e:	498d                	li	s3,3
        for(p1 = proc; p1 < &proc[NPROC]; p1++){
    80001f10:	00015497          	auipc	s1,0x15
    80001f14:	cc048493          	addi	s1,s1,-832 # 80016bd0 <tickslock>
        c->proc = p;
    80001f18:	079e                	slli	a5,a5,0x7
    80001f1a:	0000fb97          	auipc	s7,0xf
    80001f1e:	c86b8b93          	addi	s7,s7,-890 # 80010ba0 <pid_lock>
    80001f22:	9bbe                	add	s7,s7,a5
    80001f24:	a079                	j	80001fb2 <scheduler+0xe0>
        for(p1 = proc; p1 < &proc[NPROC]; p1++){
    80001f26:	0000f797          	auipc	a5,0xf
    80001f2a:	0aa78793          	addi	a5,a5,170 # 80010fd0 <proc>
    80001f2e:	a031                	j	80001f3a <scheduler+0x68>
    80001f30:	893e                	mv	s2,a5
    80001f32:	17078793          	addi	a5,a5,368
    80001f36:	02978563          	beq	a5,s1,80001f60 <scheduler+0x8e>
          if(p1->state == RUNNABLE){
    80001f3a:	4f98                	lw	a4,24(a5)
    80001f3c:	ff371be3          	bne	a4,s3,80001f32 <scheduler+0x60>
            if(maxproc->prio > p1->prio){  
    80001f40:	16892683          	lw	a3,360(s2)
    80001f44:	1687a703          	lw	a4,360(a5)
    80001f48:	fed744e3          	blt	a4,a3,80001f30 <scheduler+0x5e>
            else if(maxproc->prio == p1->prio && maxproc->times_exec > p1->times_exec)
    80001f4c:	fee693e3          	bne	a3,a4,80001f32 <scheduler+0x60>
    80001f50:	16c92683          	lw	a3,364(s2)
    80001f54:	16c7a703          	lw	a4,364(a5)
    80001f58:	fcd75de3          	bge	a4,a3,80001f32 <scheduler+0x60>
    80001f5c:	893e                	mv	s2,a5
    80001f5e:	bfd1                	j	80001f32 <scheduler+0x60>
         release(&p->lock);
    80001f60:	8566                	mv	a0,s9
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	d28080e7          	jalr	-728(ra) # 80000c8a <release>
         acquire(&p->lock);
    80001f6a:	854a                	mv	a0,s2
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	c6a080e7          	jalr	-918(ra) # 80000bd6 <acquire>
        p->state = RUNNING;
    80001f74:	01592c23          	sw	s5,24(s2)
        c->proc = p;
    80001f78:	032bb823          	sd	s2,48(s7)
        swtch(&c->context, &p->context);
    80001f7c:	06090593          	addi	a1,s2,96
    80001f80:	8562                	mv	a0,s8
    80001f82:	00000097          	auipc	ra,0x0
    80001f86:	6f4080e7          	jalr	1780(ra) # 80002676 <swtch>
        p->times_exec++;
    80001f8a:	16c92783          	lw	a5,364(s2)
    80001f8e:	2785                	addiw	a5,a5,1
    80001f90:	16f92623          	sw	a5,364(s2)
        contador++;
    80001f94:	2b05                	addiw	s6,s6,1
        c->proc = 0;
    80001f96:	020bb823          	sd	zero,48(s7)
    80001f9a:	a099                	j	80001fe0 <scheduler+0x10e>
        for(p = proc; p < &proc[NPROC]; p++)
    80001f9c:	0000f797          	auipc	a5,0xf
    80001fa0:	03478793          	addi	a5,a5,52 # 80010fd0 <proc>
          p->prio = 0;
    80001fa4:	1607a423          	sw	zero,360(a5)
        for(p = proc; p < &proc[NPROC]; p++)
    80001fa8:	17078793          	addi	a5,a5,368
    80001fac:	fe979ce3          	bne	a5,s1,80001fa4 <scheduler+0xd2>
        contador = 0;
    80001fb0:	4b01                	li	s6,0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fb6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fba:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	0000f917          	auipc	s2,0xf
    80001fc2:	01290913          	addi	s2,s2,18 # 80010fd0 <proc>
        p->state = RUNNING;
    80001fc6:	4a91                	li	s5,4
      if (contador >= cant_proc  ){
    80001fc8:	12b00a13          	li	s4,299
      acquire(&p->lock);
    80001fcc:	8cca                	mv	s9,s2
    80001fce:	854a                	mv	a0,s2
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	c06080e7          	jalr	-1018(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001fd8:	01892783          	lw	a5,24(s2)
    80001fdc:	f53785e3          	beq	a5,s3,80001f26 <scheduler+0x54>
      release(&p->lock);
    80001fe0:	854a                	mv	a0,s2
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	ca8080e7          	jalr	-856(ra) # 80000c8a <release>
      if (contador >= cant_proc  ){
    80001fea:	fb6a49e3          	blt	s4,s6,80001f9c <scheduler+0xca>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fee:	17090913          	addi	s2,s2,368
    80001ff2:	fc9970e3          	bgeu	s2,s1,80001fb2 <scheduler+0xe0>
    80001ff6:	bfd9                	j	80001fcc <scheduler+0xfa>

0000000080001ff8 <sched>:
{
    80001ff8:	7179                	addi	sp,sp,-48
    80001ffa:	f406                	sd	ra,40(sp)
    80001ffc:	f022                	sd	s0,32(sp)
    80001ffe:	ec26                	sd	s1,24(sp)
    80002000:	e84a                	sd	s2,16(sp)
    80002002:	e44e                	sd	s3,8(sp)
    80002004:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002006:	00000097          	auipc	ra,0x0
    8000200a:	9ca080e7          	jalr	-1590(ra) # 800019d0 <myproc>
    8000200e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	b4c080e7          	jalr	-1204(ra) # 80000b5c <holding>
    80002018:	c93d                	beqz	a0,8000208e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	0000f717          	auipc	a4,0xf
    80002024:	b8070713          	addi	a4,a4,-1152 # 80010ba0 <pid_lock>
    80002028:	97ba                	add	a5,a5,a4
    8000202a:	0a87a703          	lw	a4,168(a5)
    8000202e:	4785                	li	a5,1
    80002030:	06f71763          	bne	a4,a5,8000209e <sched+0xa6>
  if(p->state == RUNNING)
    80002034:	4c98                	lw	a4,24(s1)
    80002036:	4791                	li	a5,4
    80002038:	06f70b63          	beq	a4,a5,800020ae <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002040:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002042:	efb5                	bnez	a5,800020be <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002044:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002046:	0000f917          	auipc	s2,0xf
    8000204a:	b5a90913          	addi	s2,s2,-1190 # 80010ba0 <pid_lock>
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	slli	a5,a5,0x7
    80002052:	97ca                	add	a5,a5,s2
    80002054:	0ac7a983          	lw	s3,172(a5)
    80002058:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000205a:	2781                	sext.w	a5,a5
    8000205c:	079e                	slli	a5,a5,0x7
    8000205e:	0000f597          	auipc	a1,0xf
    80002062:	b7a58593          	addi	a1,a1,-1158 # 80010bd8 <cpus+0x8>
    80002066:	95be                	add	a1,a1,a5
    80002068:	06048513          	addi	a0,s1,96
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	60a080e7          	jalr	1546(ra) # 80002676 <swtch>
    80002074:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	993e                	add	s2,s2,a5
    8000207c:	0b392623          	sw	s3,172(s2)
}
    80002080:	70a2                	ld	ra,40(sp)
    80002082:	7402                	ld	s0,32(sp)
    80002084:	64e2                	ld	s1,24(sp)
    80002086:	6942                	ld	s2,16(sp)
    80002088:	69a2                	ld	s3,8(sp)
    8000208a:	6145                	addi	sp,sp,48
    8000208c:	8082                	ret
    panic("sched p->lock");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	1b250513          	addi	a0,a0,434 # 80008240 <digits+0x200>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4aa080e7          	jalr	1194(ra) # 80000540 <panic>
    panic("sched locks");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	1b250513          	addi	a0,a0,434 # 80008250 <digits+0x210>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	49a080e7          	jalr	1178(ra) # 80000540 <panic>
    panic("sched running");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	1b250513          	addi	a0,a0,434 # 80008260 <digits+0x220>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	48a080e7          	jalr	1162(ra) # 80000540 <panic>
    panic("sched interruptible");
    800020be:	00006517          	auipc	a0,0x6
    800020c2:	1b250513          	addi	a0,a0,434 # 80008270 <digits+0x230>
    800020c6:	ffffe097          	auipc	ra,0xffffe
    800020ca:	47a080e7          	jalr	1146(ra) # 80000540 <panic>

00000000800020ce <yield>:
{
    800020ce:	1101                	addi	sp,sp,-32
    800020d0:	ec06                	sd	ra,24(sp)
    800020d2:	e822                	sd	s0,16(sp)
    800020d4:	e426                	sd	s1,8(sp)
    800020d6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	8f8080e7          	jalr	-1800(ra) # 800019d0 <myproc>
    800020e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	af4080e7          	jalr	-1292(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020ea:	478d                	li	a5,3
    800020ec:	cc9c                	sw	a5,24(s1)
  p->prio = (p->prio >= 0  &&  p->prio < NPRIO-1) ? (p->prio)+1 : NPRIO-1 ;
    800020ee:	1684a703          	lw	a4,360(s1)
    800020f2:	0007061b          	sext.w	a2,a4
    800020f6:	4685                	li	a3,1
    800020f8:	4789                	li	a5,2
    800020fa:	02c6f263          	bgeu	a3,a2,8000211e <yield+0x50>
    800020fe:	16f4a423          	sw	a5,360(s1)
  sched();
    80002102:	00000097          	auipc	ra,0x0
    80002106:	ef6080e7          	jalr	-266(ra) # 80001ff8 <sched>
  release(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	b7e080e7          	jalr	-1154(ra) # 80000c8a <release>
}
    80002114:	60e2                	ld	ra,24(sp)
    80002116:	6442                	ld	s0,16(sp)
    80002118:	64a2                	ld	s1,8(sp)
    8000211a:	6105                	addi	sp,sp,32
    8000211c:	8082                	ret
  p->prio = (p->prio >= 0  &&  p->prio < NPRIO-1) ? (p->prio)+1 : NPRIO-1 ;
    8000211e:	0017079b          	addiw	a5,a4,1
    80002122:	bff1                	j	800020fe <yield+0x30>

0000000080002124 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002124:	7179                	addi	sp,sp,-48
    80002126:	f406                	sd	ra,40(sp)
    80002128:	f022                	sd	s0,32(sp)
    8000212a:	ec26                	sd	s1,24(sp)
    8000212c:	e84a                	sd	s2,16(sp)
    8000212e:	e44e                	sd	s3,8(sp)
    80002130:	1800                	addi	s0,sp,48
    80002132:	89aa                	mv	s3,a0
    80002134:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	89a080e7          	jalr	-1894(ra) # 800019d0 <myproc>
    8000213e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	a96080e7          	jalr	-1386(ra) # 80000bd6 <acquire>
  release(lk);
    80002148:	854a                	mv	a0,s2
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	b40080e7          	jalr	-1216(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002152:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002156:	4789                	li	a5,2
    80002158:	cc9c                	sw	a5,24(s1)
 
  sched();
    8000215a:	00000097          	auipc	ra,0x0
    8000215e:	e9e080e7          	jalr	-354(ra) # 80001ff8 <sched>
  // Tidy up.
  p->chan = 0;
    80002162:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	b22080e7          	jalr	-1246(ra) # 80000c8a <release>
  acquire(lk);
    80002170:	854a                	mv	a0,s2
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	a64080e7          	jalr	-1436(ra) # 80000bd6 <acquire>
}
    8000217a:	70a2                	ld	ra,40(sp)
    8000217c:	7402                	ld	s0,32(sp)
    8000217e:	64e2                	ld	s1,24(sp)
    80002180:	6942                	ld	s2,16(sp)
    80002182:	69a2                	ld	s3,8(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret

0000000080002188 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002188:	7139                	addi	sp,sp,-64
    8000218a:	fc06                	sd	ra,56(sp)
    8000218c:	f822                	sd	s0,48(sp)
    8000218e:	f426                	sd	s1,40(sp)
    80002190:	f04a                	sd	s2,32(sp)
    80002192:	ec4e                	sd	s3,24(sp)
    80002194:	e852                	sd	s4,16(sp)
    80002196:	e456                	sd	s5,8(sp)
    80002198:	0080                	addi	s0,sp,64
    8000219a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000219c:	0000f497          	auipc	s1,0xf
    800021a0:	e3448493          	addi	s1,s1,-460 # 80010fd0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021a6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a8:	00015917          	auipc	s2,0x15
    800021ac:	a2890913          	addi	s2,s2,-1496 # 80016bd0 <tickslock>
    800021b0:	a811                	j	800021c4 <wakeup+0x3c>
      }
      release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ad6080e7          	jalr	-1322(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021bc:	17048493          	addi	s1,s1,368
    800021c0:	03248663          	beq	s1,s2,800021ec <wakeup+0x64>
    if(p != myproc()){
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	80c080e7          	jalr	-2036(ra) # 800019d0 <myproc>
    800021cc:	fea488e3          	beq	s1,a0,800021bc <wakeup+0x34>
      acquire(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	a04080e7          	jalr	-1532(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021da:	4c9c                	lw	a5,24(s1)
    800021dc:	fd379be3          	bne	a5,s3,800021b2 <wakeup+0x2a>
    800021e0:	709c                	ld	a5,32(s1)
    800021e2:	fd4798e3          	bne	a5,s4,800021b2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021e6:	0154ac23          	sw	s5,24(s1)
    800021ea:	b7e1                	j	800021b2 <wakeup+0x2a>
    }
  }
}
    800021ec:	70e2                	ld	ra,56(sp)
    800021ee:	7442                	ld	s0,48(sp)
    800021f0:	74a2                	ld	s1,40(sp)
    800021f2:	7902                	ld	s2,32(sp)
    800021f4:	69e2                	ld	s3,24(sp)
    800021f6:	6a42                	ld	s4,16(sp)
    800021f8:	6aa2                	ld	s5,8(sp)
    800021fa:	6121                	addi	sp,sp,64
    800021fc:	8082                	ret

00000000800021fe <reparent>:
{
    800021fe:	7179                	addi	sp,sp,-48
    80002200:	f406                	sd	ra,40(sp)
    80002202:	f022                	sd	s0,32(sp)
    80002204:	ec26                	sd	s1,24(sp)
    80002206:	e84a                	sd	s2,16(sp)
    80002208:	e44e                	sd	s3,8(sp)
    8000220a:	e052                	sd	s4,0(sp)
    8000220c:	1800                	addi	s0,sp,48
    8000220e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002210:	0000f497          	auipc	s1,0xf
    80002214:	dc048493          	addi	s1,s1,-576 # 80010fd0 <proc>
      pp->parent = initproc;
    80002218:	00006a17          	auipc	s4,0x6
    8000221c:	710a0a13          	addi	s4,s4,1808 # 80008928 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002220:	00015997          	auipc	s3,0x15
    80002224:	9b098993          	addi	s3,s3,-1616 # 80016bd0 <tickslock>
    80002228:	a029                	j	80002232 <reparent+0x34>
    8000222a:	17048493          	addi	s1,s1,368
    8000222e:	01348d63          	beq	s1,s3,80002248 <reparent+0x4a>
    if(pp->parent == p){
    80002232:	7c9c                	ld	a5,56(s1)
    80002234:	ff279be3          	bne	a5,s2,8000222a <reparent+0x2c>
      pp->parent = initproc;
    80002238:	000a3503          	ld	a0,0(s4)
    8000223c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	f4a080e7          	jalr	-182(ra) # 80002188 <wakeup>
    80002246:	b7d5                	j	8000222a <reparent+0x2c>
}
    80002248:	70a2                	ld	ra,40(sp)
    8000224a:	7402                	ld	s0,32(sp)
    8000224c:	64e2                	ld	s1,24(sp)
    8000224e:	6942                	ld	s2,16(sp)
    80002250:	69a2                	ld	s3,8(sp)
    80002252:	6a02                	ld	s4,0(sp)
    80002254:	6145                	addi	sp,sp,48
    80002256:	8082                	ret

0000000080002258 <exit>:
{
    80002258:	7179                	addi	sp,sp,-48
    8000225a:	f406                	sd	ra,40(sp)
    8000225c:	f022                	sd	s0,32(sp)
    8000225e:	ec26                	sd	s1,24(sp)
    80002260:	e84a                	sd	s2,16(sp)
    80002262:	e44e                	sd	s3,8(sp)
    80002264:	e052                	sd	s4,0(sp)
    80002266:	1800                	addi	s0,sp,48
    80002268:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	766080e7          	jalr	1894(ra) # 800019d0 <myproc>
    80002272:	89aa                	mv	s3,a0
  if(p == initproc)
    80002274:	00006797          	auipc	a5,0x6
    80002278:	6b47b783          	ld	a5,1716(a5) # 80008928 <initproc>
    8000227c:	0d050493          	addi	s1,a0,208
    80002280:	15050913          	addi	s2,a0,336
    80002284:	02a79363          	bne	a5,a0,800022aa <exit+0x52>
    panic("init exiting");
    80002288:	00006517          	auipc	a0,0x6
    8000228c:	00050513          	mv	a0,a0
    80002290:	ffffe097          	auipc	ra,0xffffe
    80002294:	2b0080e7          	jalr	688(ra) # 80000540 <panic>
      fileclose(f);
    80002298:	00002097          	auipc	ra,0x2
    8000229c:	2e6080e7          	jalr	742(ra) # 8000457e <fileclose>
      p->ofile[fd] = 0;
    800022a0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022a4:	04a1                	addi	s1,s1,8
    800022a6:	01248563          	beq	s1,s2,800022b0 <exit+0x58>
    if(p->ofile[fd]){
    800022aa:	6088                	ld	a0,0(s1)
    800022ac:	f575                	bnez	a0,80002298 <exit+0x40>
    800022ae:	bfdd                	j	800022a4 <exit+0x4c>
  begin_op();
    800022b0:	00002097          	auipc	ra,0x2
    800022b4:	e06080e7          	jalr	-506(ra) # 800040b6 <begin_op>
  iput(p->cwd);
    800022b8:	1509b503          	ld	a0,336(s3)
    800022bc:	00001097          	auipc	ra,0x1
    800022c0:	5e8080e7          	jalr	1512(ra) # 800038a4 <iput>
  end_op();
    800022c4:	00002097          	auipc	ra,0x2
    800022c8:	e70080e7          	jalr	-400(ra) # 80004134 <end_op>
  p->cwd = 0;
    800022cc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022d0:	0000f497          	auipc	s1,0xf
    800022d4:	8e848493          	addi	s1,s1,-1816 # 80010bb8 <wait_lock>
    800022d8:	8526                	mv	a0,s1
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	8fc080e7          	jalr	-1796(ra) # 80000bd6 <acquire>
  reparent(p);
    800022e2:	854e                	mv	a0,s3
    800022e4:	00000097          	auipc	ra,0x0
    800022e8:	f1a080e7          	jalr	-230(ra) # 800021fe <reparent>
  wakeup(p->parent);
    800022ec:	0389b503          	ld	a0,56(s3)
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	e98080e7          	jalr	-360(ra) # 80002188 <wakeup>
  acquire(&p->lock);
    800022f8:	854e                	mv	a0,s3
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	8dc080e7          	jalr	-1828(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002302:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002306:	4795                	li	a5,5
    80002308:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	97c080e7          	jalr	-1668(ra) # 80000c8a <release>
  sched();
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	ce2080e7          	jalr	-798(ra) # 80001ff8 <sched>
  panic("zombie exit");
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	f7a50513          	addi	a0,a0,-134 # 80008298 <digits+0x258>
    80002326:	ffffe097          	auipc	ra,0xffffe
    8000232a:	21a080e7          	jalr	538(ra) # 80000540 <panic>

000000008000232e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	1800                	addi	s0,sp,48
    8000233c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000233e:	0000f497          	auipc	s1,0xf
    80002342:	c9248493          	addi	s1,s1,-878 # 80010fd0 <proc>
    80002346:	00015997          	auipc	s3,0x15
    8000234a:	88a98993          	addi	s3,s3,-1910 # 80016bd0 <tickslock>
    acquire(&p->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	886080e7          	jalr	-1914(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002358:	589c                	lw	a5,48(s1)
    8000235a:	01278d63          	beq	a5,s2,80002374 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002368:	17048493          	addi	s1,s1,368
    8000236c:	ff3491e3          	bne	s1,s3,8000234e <kill+0x20>
  }
  return -1;
    80002370:	557d                	li	a0,-1
    80002372:	a829                	j	8000238c <kill+0x5e>
      p->killed = 1;
    80002374:	4785                	li	a5,1
    80002376:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002378:	4c98                	lw	a4,24(s1)
    8000237a:	4789                	li	a5,2
    8000237c:	00f70f63          	beq	a4,a5,8000239a <kill+0x6c>
      release(&p->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	908080e7          	jalr	-1784(ra) # 80000c8a <release>
      return 0;
    8000238a:	4501                	li	a0,0
}
    8000238c:	70a2                	ld	ra,40(sp)
    8000238e:	7402                	ld	s0,32(sp)
    80002390:	64e2                	ld	s1,24(sp)
    80002392:	6942                	ld	s2,16(sp)
    80002394:	69a2                	ld	s3,8(sp)
    80002396:	6145                	addi	sp,sp,48
    80002398:	8082                	ret
        p->state = RUNNABLE;
    8000239a:	478d                	li	a5,3
    8000239c:	cc9c                	sw	a5,24(s1)
    8000239e:	b7cd                	j	80002380 <kill+0x52>

00000000800023a0 <setkilled>:

void
setkilled(struct proc *p)
{
    800023a0:	1101                	addi	sp,sp,-32
    800023a2:	ec06                	sd	ra,24(sp)
    800023a4:	e822                	sd	s0,16(sp)
    800023a6:	e426                	sd	s1,8(sp)
    800023a8:	1000                	addi	s0,sp,32
    800023aa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	82a080e7          	jalr	-2006(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023b4:	4785                	li	a5,1
    800023b6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8d0080e7          	jalr	-1840(ra) # 80000c8a <release>
}
    800023c2:	60e2                	ld	ra,24(sp)
    800023c4:	6442                	ld	s0,16(sp)
    800023c6:	64a2                	ld	s1,8(sp)
    800023c8:	6105                	addi	sp,sp,32
    800023ca:	8082                	ret

00000000800023cc <killed>:

int
killed(struct proc *p)
{
    800023cc:	1101                	addi	sp,sp,-32
    800023ce:	ec06                	sd	ra,24(sp)
    800023d0:	e822                	sd	s0,16(sp)
    800023d2:	e426                	sd	s1,8(sp)
    800023d4:	e04a                	sd	s2,0(sp)
    800023d6:	1000                	addi	s0,sp,32
    800023d8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	7fc080e7          	jalr	2044(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023e2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	8a2080e7          	jalr	-1886(ra) # 80000c8a <release>
  return k;
}
    800023f0:	854a                	mv	a0,s2
    800023f2:	60e2                	ld	ra,24(sp)
    800023f4:	6442                	ld	s0,16(sp)
    800023f6:	64a2                	ld	s1,8(sp)
    800023f8:	6902                	ld	s2,0(sp)
    800023fa:	6105                	addi	sp,sp,32
    800023fc:	8082                	ret

00000000800023fe <wait>:
{
    800023fe:	715d                	addi	sp,sp,-80
    80002400:	e486                	sd	ra,72(sp)
    80002402:	e0a2                	sd	s0,64(sp)
    80002404:	fc26                	sd	s1,56(sp)
    80002406:	f84a                	sd	s2,48(sp)
    80002408:	f44e                	sd	s3,40(sp)
    8000240a:	f052                	sd	s4,32(sp)
    8000240c:	ec56                	sd	s5,24(sp)
    8000240e:	e85a                	sd	s6,16(sp)
    80002410:	e45e                	sd	s7,8(sp)
    80002412:	e062                	sd	s8,0(sp)
    80002414:	0880                	addi	s0,sp,80
    80002416:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	5b8080e7          	jalr	1464(ra) # 800019d0 <myproc>
    80002420:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	79650513          	addi	a0,a0,1942 # 80010bb8 <wait_lock>
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	7ac080e7          	jalr	1964(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002432:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002434:	4a15                	li	s4,5
        havekids = 1;
    80002436:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002438:	00014997          	auipc	s3,0x14
    8000243c:	79898993          	addi	s3,s3,1944 # 80016bd0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002440:	0000ec17          	auipc	s8,0xe
    80002444:	778c0c13          	addi	s8,s8,1912 # 80010bb8 <wait_lock>
    havekids = 0;
    80002448:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000244a:	0000f497          	auipc	s1,0xf
    8000244e:	b8648493          	addi	s1,s1,-1146 # 80010fd0 <proc>
    80002452:	a0bd                	j	800024c0 <wait+0xc2>
          pid = pp->pid;
    80002454:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002458:	000b0e63          	beqz	s6,80002474 <wait+0x76>
    8000245c:	4691                	li	a3,4
    8000245e:	02c48613          	addi	a2,s1,44
    80002462:	85da                	mv	a1,s6
    80002464:	05093503          	ld	a0,80(s2)
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	224080e7          	jalr	548(ra) # 8000168c <copyout>
    80002470:	02054563          	bltz	a0,8000249a <wait+0x9c>
          freeproc(pp);
    80002474:	8526                	mv	a0,s1
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	70c080e7          	jalr	1804(ra) # 80001b82 <freeproc>
          release(&pp->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	80a080e7          	jalr	-2038(ra) # 80000c8a <release>
          release(&wait_lock);
    80002488:	0000e517          	auipc	a0,0xe
    8000248c:	73050513          	addi	a0,a0,1840 # 80010bb8 <wait_lock>
    80002490:	ffffe097          	auipc	ra,0xffffe
    80002494:	7fa080e7          	jalr	2042(ra) # 80000c8a <release>
          return pid;
    80002498:	a0b5                	j	80002504 <wait+0x106>
            release(&pp->lock);
    8000249a:	8526                	mv	a0,s1
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	7ee080e7          	jalr	2030(ra) # 80000c8a <release>
            release(&wait_lock);
    800024a4:	0000e517          	auipc	a0,0xe
    800024a8:	71450513          	addi	a0,a0,1812 # 80010bb8 <wait_lock>
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	7de080e7          	jalr	2014(ra) # 80000c8a <release>
            return -1;
    800024b4:	59fd                	li	s3,-1
    800024b6:	a0b9                	j	80002504 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b8:	17048493          	addi	s1,s1,368
    800024bc:	03348463          	beq	s1,s3,800024e4 <wait+0xe6>
      if(pp->parent == p){
    800024c0:	7c9c                	ld	a5,56(s1)
    800024c2:	ff279be3          	bne	a5,s2,800024b8 <wait+0xba>
        acquire(&pp->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	70e080e7          	jalr	1806(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800024d0:	4c9c                	lw	a5,24(s1)
    800024d2:	f94781e3          	beq	a5,s4,80002454 <wait+0x56>
        release(&pp->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	ffffe097          	auipc	ra,0xffffe
    800024dc:	7b2080e7          	jalr	1970(ra) # 80000c8a <release>
        havekids = 1;
    800024e0:	8756                	mv	a4,s5
    800024e2:	bfd9                	j	800024b8 <wait+0xba>
    if(!havekids || killed(p)){
    800024e4:	c719                	beqz	a4,800024f2 <wait+0xf4>
    800024e6:	854a                	mv	a0,s2
    800024e8:	00000097          	auipc	ra,0x0
    800024ec:	ee4080e7          	jalr	-284(ra) # 800023cc <killed>
    800024f0:	c51d                	beqz	a0,8000251e <wait+0x120>
      release(&wait_lock);
    800024f2:	0000e517          	auipc	a0,0xe
    800024f6:	6c650513          	addi	a0,a0,1734 # 80010bb8 <wait_lock>
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	790080e7          	jalr	1936(ra) # 80000c8a <release>
      return -1;
    80002502:	59fd                	li	s3,-1
}
    80002504:	854e                	mv	a0,s3
    80002506:	60a6                	ld	ra,72(sp)
    80002508:	6406                	ld	s0,64(sp)
    8000250a:	74e2                	ld	s1,56(sp)
    8000250c:	7942                	ld	s2,48(sp)
    8000250e:	79a2                	ld	s3,40(sp)
    80002510:	7a02                	ld	s4,32(sp)
    80002512:	6ae2                	ld	s5,24(sp)
    80002514:	6b42                	ld	s6,16(sp)
    80002516:	6ba2                	ld	s7,8(sp)
    80002518:	6c02                	ld	s8,0(sp)
    8000251a:	6161                	addi	sp,sp,80
    8000251c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000251e:	85e2                	mv	a1,s8
    80002520:	854a                	mv	a0,s2
    80002522:	00000097          	auipc	ra,0x0
    80002526:	c02080e7          	jalr	-1022(ra) # 80002124 <sleep>
    havekids = 0;
    8000252a:	bf39                	j	80002448 <wait+0x4a>

000000008000252c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000252c:	7179                	addi	sp,sp,-48
    8000252e:	f406                	sd	ra,40(sp)
    80002530:	f022                	sd	s0,32(sp)
    80002532:	ec26                	sd	s1,24(sp)
    80002534:	e84a                	sd	s2,16(sp)
    80002536:	e44e                	sd	s3,8(sp)
    80002538:	e052                	sd	s4,0(sp)
    8000253a:	1800                	addi	s0,sp,48
    8000253c:	84aa                	mv	s1,a0
    8000253e:	892e                	mv	s2,a1
    80002540:	89b2                	mv	s3,a2
    80002542:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	48c080e7          	jalr	1164(ra) # 800019d0 <myproc>
  if(user_dst){
    8000254c:	c08d                	beqz	s1,8000256e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000254e:	86d2                	mv	a3,s4
    80002550:	864e                	mv	a2,s3
    80002552:	85ca                	mv	a1,s2
    80002554:	6928                	ld	a0,80(a0)
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	136080e7          	jalr	310(ra) # 8000168c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000255e:	70a2                	ld	ra,40(sp)
    80002560:	7402                	ld	s0,32(sp)
    80002562:	64e2                	ld	s1,24(sp)
    80002564:	6942                	ld	s2,16(sp)
    80002566:	69a2                	ld	s3,8(sp)
    80002568:	6a02                	ld	s4,0(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret
    memmove((char *)dst, src, len);
    8000256e:	000a061b          	sext.w	a2,s4
    80002572:	85ce                	mv	a1,s3
    80002574:	854a                	mv	a0,s2
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	7b8080e7          	jalr	1976(ra) # 80000d2e <memmove>
    return 0;
    8000257e:	8526                	mv	a0,s1
    80002580:	bff9                	j	8000255e <either_copyout+0x32>

0000000080002582 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002582:	7179                	addi	sp,sp,-48
    80002584:	f406                	sd	ra,40(sp)
    80002586:	f022                	sd	s0,32(sp)
    80002588:	ec26                	sd	s1,24(sp)
    8000258a:	e84a                	sd	s2,16(sp)
    8000258c:	e44e                	sd	s3,8(sp)
    8000258e:	e052                	sd	s4,0(sp)
    80002590:	1800                	addi	s0,sp,48
    80002592:	892a                	mv	s2,a0
    80002594:	84ae                	mv	s1,a1
    80002596:	89b2                	mv	s3,a2
    80002598:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	436080e7          	jalr	1078(ra) # 800019d0 <myproc>
  if(user_src){
    800025a2:	c08d                	beqz	s1,800025c4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025a4:	86d2                	mv	a3,s4
    800025a6:	864e                	mv	a2,s3
    800025a8:	85ca                	mv	a1,s2
    800025aa:	6928                	ld	a0,80(a0)
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	16c080e7          	jalr	364(ra) # 80001718 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025b4:	70a2                	ld	ra,40(sp)
    800025b6:	7402                	ld	s0,32(sp)
    800025b8:	64e2                	ld	s1,24(sp)
    800025ba:	6942                	ld	s2,16(sp)
    800025bc:	69a2                	ld	s3,8(sp)
    800025be:	6a02                	ld	s4,0(sp)
    800025c0:	6145                	addi	sp,sp,48
    800025c2:	8082                	ret
    memmove(dst, (char*)src, len);
    800025c4:	000a061b          	sext.w	a2,s4
    800025c8:	85ce                	mv	a1,s3
    800025ca:	854a                	mv	a0,s2
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	762080e7          	jalr	1890(ra) # 80000d2e <memmove>
    return 0;
    800025d4:	8526                	mv	a0,s1
    800025d6:	bff9                	j	800025b4 <either_copyin+0x32>

00000000800025d8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025d8:	7139                	addi	sp,sp,-64
    800025da:	fc06                	sd	ra,56(sp)
    800025dc:	f822                	sd	s0,48(sp)
    800025de:	f426                	sd	s1,40(sp)
    800025e0:	f04a                	sd	s2,32(sp)
    800025e2:	ec4e                	sd	s3,24(sp)
    800025e4:	e852                	sd	s4,16(sp)
    800025e6:	e456                	sd	s5,8(sp)
    800025e8:	e05a                	sd	s6,0(sp)
    800025ea:	0080                	addi	s0,sp,64
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025ec:	00006517          	auipc	a0,0x6
    800025f0:	b0450513          	addi	a0,a0,-1276 # 800080f0 <digits+0xb0>
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	f96080e7          	jalr	-106(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025fc:	0000f497          	auipc	s1,0xf
    80002600:	b2c48493          	addi	s1,s1,-1236 # 80011128 <proc+0x158>
    80002604:	00014917          	auipc	s2,0x14
    80002608:	72490913          	addi	s2,s2,1828 # 80016d28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260c:	4a95                	li	s5,5
      state = states[p->state];
    else
      state = "???";
    8000260e:	00006997          	auipc	s3,0x6
    80002612:	c9a98993          	addi	s3,s3,-870 # 800082a8 <digits+0x268>
    printf("%d %s %s times_exe:%d prio:%d\n", p->pid, state, p->name, p->times_exec, p->prio);
    80002616:	00006a17          	auipc	s4,0x6
    8000261a:	c9aa0a13          	addi	s4,s4,-870 # 800082b0 <digits+0x270>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261e:	00006b17          	auipc	s6,0x6
    80002622:	cf2b0b13          	addi	s6,s6,-782 # 80008310 <states.0>
    80002626:	a831                	j	80002642 <procdump+0x6a>
    printf("%d %s %s times_exe:%d prio:%d\n", p->pid, state, p->name, p->times_exec, p->prio);
    80002628:	4a9c                	lw	a5,16(a3)
    8000262a:	4ad8                	lw	a4,20(a3)
    8000262c:	ed86a583          	lw	a1,-296(a3)
    80002630:	8552                	mv	a0,s4
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	f58080e7          	jalr	-168(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000263a:	17048493          	addi	s1,s1,368
    8000263e:	03248263          	beq	s1,s2,80002662 <procdump+0x8a>
    if(p->state == UNUSED)
    80002642:	86a6                	mv	a3,s1
    80002644:	ec04a783          	lw	a5,-320(s1)
    80002648:	dbed                	beqz	a5,8000263a <procdump+0x62>
      state = "???";
    8000264a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264c:	fcfaeee3          	bltu	s5,a5,80002628 <procdump+0x50>
    80002650:	02079713          	slli	a4,a5,0x20
    80002654:	01d75793          	srli	a5,a4,0x1d
    80002658:	97da                	add	a5,a5,s6
    8000265a:	6390                	ld	a2,0(a5)
    8000265c:	f671                	bnez	a2,80002628 <procdump+0x50>
      state = "???";
    8000265e:	864e                	mv	a2,s3
    80002660:	b7e1                	j	80002628 <procdump+0x50>
    //printf("\n");
  }
    80002662:	70e2                	ld	ra,56(sp)
    80002664:	7442                	ld	s0,48(sp)
    80002666:	74a2                	ld	s1,40(sp)
    80002668:	7902                	ld	s2,32(sp)
    8000266a:	69e2                	ld	s3,24(sp)
    8000266c:	6a42                	ld	s4,16(sp)
    8000266e:	6aa2                	ld	s5,8(sp)
    80002670:	6b02                	ld	s6,0(sp)
    80002672:	6121                	addi	sp,sp,64
    80002674:	8082                	ret

0000000080002676 <swtch>:
    80002676:	00153023          	sd	ra,0(a0)
    8000267a:	00253423          	sd	sp,8(a0)
    8000267e:	e900                	sd	s0,16(a0)
    80002680:	ed04                	sd	s1,24(a0)
    80002682:	03253023          	sd	s2,32(a0)
    80002686:	03353423          	sd	s3,40(a0)
    8000268a:	03453823          	sd	s4,48(a0)
    8000268e:	03553c23          	sd	s5,56(a0)
    80002692:	05653023          	sd	s6,64(a0)
    80002696:	05753423          	sd	s7,72(a0)
    8000269a:	05853823          	sd	s8,80(a0)
    8000269e:	05953c23          	sd	s9,88(a0)
    800026a2:	07a53023          	sd	s10,96(a0)
    800026a6:	07b53423          	sd	s11,104(a0)
    800026aa:	0005b083          	ld	ra,0(a1)
    800026ae:	0085b103          	ld	sp,8(a1)
    800026b2:	6980                	ld	s0,16(a1)
    800026b4:	6d84                	ld	s1,24(a1)
    800026b6:	0205b903          	ld	s2,32(a1)
    800026ba:	0285b983          	ld	s3,40(a1)
    800026be:	0305ba03          	ld	s4,48(a1)
    800026c2:	0385ba83          	ld	s5,56(a1)
    800026c6:	0405bb03          	ld	s6,64(a1)
    800026ca:	0485bb83          	ld	s7,72(a1)
    800026ce:	0505bc03          	ld	s8,80(a1)
    800026d2:	0585bc83          	ld	s9,88(a1)
    800026d6:	0605bd03          	ld	s10,96(a1)
    800026da:	0685bd83          	ld	s11,104(a1)
    800026de:	8082                	ret

00000000800026e0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026e0:	1141                	addi	sp,sp,-16
    800026e2:	e406                	sd	ra,8(sp)
    800026e4:	e022                	sd	s0,0(sp)
    800026e6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026e8:	00006597          	auipc	a1,0x6
    800026ec:	c5858593          	addi	a1,a1,-936 # 80008340 <states.0+0x30>
    800026f0:	00014517          	auipc	a0,0x14
    800026f4:	4e050513          	addi	a0,a0,1248 # 80016bd0 <tickslock>
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	44e080e7          	jalr	1102(ra) # 80000b46 <initlock>
}
    80002700:	60a2                	ld	ra,8(sp)
    80002702:	6402                	ld	s0,0(sp)
    80002704:	0141                	addi	sp,sp,16
    80002706:	8082                	ret

0000000080002708 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002708:	1141                	addi	sp,sp,-16
    8000270a:	e422                	sd	s0,8(sp)
    8000270c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000270e:	00003797          	auipc	a5,0x3
    80002712:	4c278793          	addi	a5,a5,1218 # 80005bd0 <kernelvec>
    80002716:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000271a:	6422                	ld	s0,8(sp)
    8000271c:	0141                	addi	sp,sp,16
    8000271e:	8082                	ret

0000000080002720 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002720:	1141                	addi	sp,sp,-16
    80002722:	e406                	sd	ra,8(sp)
    80002724:	e022                	sd	s0,0(sp)
    80002726:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002728:	fffff097          	auipc	ra,0xfffff
    8000272c:	2a8080e7          	jalr	680(ra) # 800019d0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002730:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002734:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002736:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000273a:	00005697          	auipc	a3,0x5
    8000273e:	8c668693          	addi	a3,a3,-1850 # 80007000 <_trampoline>
    80002742:	00005717          	auipc	a4,0x5
    80002746:	8be70713          	addi	a4,a4,-1858 # 80007000 <_trampoline>
    8000274a:	8f15                	sub	a4,a4,a3
    8000274c:	040007b7          	lui	a5,0x4000
    80002750:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002752:	07b2                	slli	a5,a5,0xc
    80002754:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002756:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000275a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000275c:	18002673          	csrr	a2,satp
    80002760:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002762:	6d30                	ld	a2,88(a0)
    80002764:	6138                	ld	a4,64(a0)
    80002766:	6585                	lui	a1,0x1
    80002768:	972e                	add	a4,a4,a1
    8000276a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000276c:	6d38                	ld	a4,88(a0)
    8000276e:	00000617          	auipc	a2,0x0
    80002772:	13060613          	addi	a2,a2,304 # 8000289e <usertrap>
    80002776:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002778:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000277a:	8612                	mv	a2,tp
    8000277c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000277e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002782:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002786:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000278a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000278e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002790:	6f18                	ld	a4,24(a4)
    80002792:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002796:	6928                	ld	a0,80(a0)
    80002798:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000279a:	00005717          	auipc	a4,0x5
    8000279e:	90270713          	addi	a4,a4,-1790 # 8000709c <userret>
    800027a2:	8f15                	sub	a4,a4,a3
    800027a4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027a6:	577d                	li	a4,-1
    800027a8:	177e                	slli	a4,a4,0x3f
    800027aa:	8d59                	or	a0,a0,a4
    800027ac:	9782                	jalr	a5
}
    800027ae:	60a2                	ld	ra,8(sp)
    800027b0:	6402                	ld	s0,0(sp)
    800027b2:	0141                	addi	sp,sp,16
    800027b4:	8082                	ret

00000000800027b6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027b6:	1101                	addi	sp,sp,-32
    800027b8:	ec06                	sd	ra,24(sp)
    800027ba:	e822                	sd	s0,16(sp)
    800027bc:	e426                	sd	s1,8(sp)
    800027be:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027c0:	00014497          	auipc	s1,0x14
    800027c4:	41048493          	addi	s1,s1,1040 # 80016bd0 <tickslock>
    800027c8:	8526                	mv	a0,s1
    800027ca:	ffffe097          	auipc	ra,0xffffe
    800027ce:	40c080e7          	jalr	1036(ra) # 80000bd6 <acquire>
  ticks++;
    800027d2:	00006517          	auipc	a0,0x6
    800027d6:	15e50513          	addi	a0,a0,350 # 80008930 <ticks>
    800027da:	411c                	lw	a5,0(a0)
    800027dc:	2785                	addiw	a5,a5,1
    800027de:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027e0:	00000097          	auipc	ra,0x0
    800027e4:	9a8080e7          	jalr	-1624(ra) # 80002188 <wakeup>
  release(&tickslock);
    800027e8:	8526                	mv	a0,s1
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	4a0080e7          	jalr	1184(ra) # 80000c8a <release>
}
    800027f2:	60e2                	ld	ra,24(sp)
    800027f4:	6442                	ld	s0,16(sp)
    800027f6:	64a2                	ld	s1,8(sp)
    800027f8:	6105                	addi	sp,sp,32
    800027fa:	8082                	ret

00000000800027fc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002806:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000280a:	00074d63          	bltz	a4,80002824 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000280e:	57fd                	li	a5,-1
    80002810:	17fe                	slli	a5,a5,0x3f
    80002812:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002814:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002816:	06f70363          	beq	a4,a5,8000287c <devintr+0x80>
  }
}
    8000281a:	60e2                	ld	ra,24(sp)
    8000281c:	6442                	ld	s0,16(sp)
    8000281e:	64a2                	ld	s1,8(sp)
    80002820:	6105                	addi	sp,sp,32
    80002822:	8082                	ret
     (scause & 0xff) == 9){
    80002824:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002828:	46a5                	li	a3,9
    8000282a:	fed792e3          	bne	a5,a3,8000280e <devintr+0x12>
    int irq = plic_claim();
    8000282e:	00003097          	auipc	ra,0x3
    80002832:	4aa080e7          	jalr	1194(ra) # 80005cd8 <plic_claim>
    80002836:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002838:	47a9                	li	a5,10
    8000283a:	02f50763          	beq	a0,a5,80002868 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000283e:	4785                	li	a5,1
    80002840:	02f50963          	beq	a0,a5,80002872 <devintr+0x76>
    return 1;
    80002844:	4505                	li	a0,1
    } else if(irq){
    80002846:	d8f1                	beqz	s1,8000281a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002848:	85a6                	mv	a1,s1
    8000284a:	00006517          	auipc	a0,0x6
    8000284e:	afe50513          	addi	a0,a0,-1282 # 80008348 <states.0+0x38>
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	d38080e7          	jalr	-712(ra) # 8000058a <printf>
      plic_complete(irq);
    8000285a:	8526                	mv	a0,s1
    8000285c:	00003097          	auipc	ra,0x3
    80002860:	4a0080e7          	jalr	1184(ra) # 80005cfc <plic_complete>
    return 1;
    80002864:	4505                	li	a0,1
    80002866:	bf55                	j	8000281a <devintr+0x1e>
      uartintr();
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	130080e7          	jalr	304(ra) # 80000998 <uartintr>
    80002870:	b7ed                	j	8000285a <devintr+0x5e>
      virtio_disk_intr();
    80002872:	00004097          	auipc	ra,0x4
    80002876:	952080e7          	jalr	-1710(ra) # 800061c4 <virtio_disk_intr>
    8000287a:	b7c5                	j	8000285a <devintr+0x5e>
    if(cpuid() == 0){
    8000287c:	fffff097          	auipc	ra,0xfffff
    80002880:	128080e7          	jalr	296(ra) # 800019a4 <cpuid>
    80002884:	c901                	beqz	a0,80002894 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002886:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000288a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000288c:	14479073          	csrw	sip,a5
    return 2;
    80002890:	4509                	li	a0,2
    80002892:	b761                	j	8000281a <devintr+0x1e>
      clockintr();
    80002894:	00000097          	auipc	ra,0x0
    80002898:	f22080e7          	jalr	-222(ra) # 800027b6 <clockintr>
    8000289c:	b7ed                	j	80002886 <devintr+0x8a>

000000008000289e <usertrap>:
{
    8000289e:	1101                	addi	sp,sp,-32
    800028a0:	ec06                	sd	ra,24(sp)
    800028a2:	e822                	sd	s0,16(sp)
    800028a4:	e426                	sd	s1,8(sp)
    800028a6:	e04a                	sd	s2,0(sp)
    800028a8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028aa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028ae:	1007f793          	andi	a5,a5,256
    800028b2:	e3b1                	bnez	a5,800028f6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b4:	00003797          	auipc	a5,0x3
    800028b8:	31c78793          	addi	a5,a5,796 # 80005bd0 <kernelvec>
    800028bc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028c0:	fffff097          	auipc	ra,0xfffff
    800028c4:	110080e7          	jalr	272(ra) # 800019d0 <myproc>
    800028c8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028ca:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028cc:	14102773          	csrr	a4,sepc
    800028d0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028d6:	47a1                	li	a5,8
    800028d8:	02f70763          	beq	a4,a5,80002906 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	f20080e7          	jalr	-224(ra) # 800027fc <devintr>
    800028e4:	892a                	mv	s2,a0
    800028e6:	c151                	beqz	a0,8000296a <usertrap+0xcc>
  if(killed(p))
    800028e8:	8526                	mv	a0,s1
    800028ea:	00000097          	auipc	ra,0x0
    800028ee:	ae2080e7          	jalr	-1310(ra) # 800023cc <killed>
    800028f2:	c929                	beqz	a0,80002944 <usertrap+0xa6>
    800028f4:	a099                	j	8000293a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	a7250513          	addi	a0,a0,-1422 # 80008368 <states.0+0x58>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c42080e7          	jalr	-958(ra) # 80000540 <panic>
    if(killed(p))
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	ac6080e7          	jalr	-1338(ra) # 800023cc <killed>
    8000290e:	e921                	bnez	a0,8000295e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002910:	6cb8                	ld	a4,88(s1)
    80002912:	6f1c                	ld	a5,24(a4)
    80002914:	0791                	addi	a5,a5,4
    80002916:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002918:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000291c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002920:	10079073          	csrw	sstatus,a5
    syscall();
    80002924:	00000097          	auipc	ra,0x0
    80002928:	2d4080e7          	jalr	724(ra) # 80002bf8 <syscall>
  if(killed(p))
    8000292c:	8526                	mv	a0,s1
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	a9e080e7          	jalr	-1378(ra) # 800023cc <killed>
    80002936:	c911                	beqz	a0,8000294a <usertrap+0xac>
    80002938:	4901                	li	s2,0
    exit(-1);
    8000293a:	557d                	li	a0,-1
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	91c080e7          	jalr	-1764(ra) # 80002258 <exit>
  if(which_dev == 2)
    80002944:	4789                	li	a5,2
    80002946:	04f90f63          	beq	s2,a5,800029a4 <usertrap+0x106>
  usertrapret();
    8000294a:	00000097          	auipc	ra,0x0
    8000294e:	dd6080e7          	jalr	-554(ra) # 80002720 <usertrapret>
}
    80002952:	60e2                	ld	ra,24(sp)
    80002954:	6442                	ld	s0,16(sp)
    80002956:	64a2                	ld	s1,8(sp)
    80002958:	6902                	ld	s2,0(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret
      exit(-1);
    8000295e:	557d                	li	a0,-1
    80002960:	00000097          	auipc	ra,0x0
    80002964:	8f8080e7          	jalr	-1800(ra) # 80002258 <exit>
    80002968:	b765                	j	80002910 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000296a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000296e:	5890                	lw	a2,48(s1)
    80002970:	00006517          	auipc	a0,0x6
    80002974:	a1850513          	addi	a0,a0,-1512 # 80008388 <states.0+0x78>
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	c12080e7          	jalr	-1006(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002980:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002984:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	a3050513          	addi	a0,a0,-1488 # 800083b8 <states.0+0xa8>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bfa080e7          	jalr	-1030(ra) # 8000058a <printf>
    setkilled(p);
    80002998:	8526                	mv	a0,s1
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	a06080e7          	jalr	-1530(ra) # 800023a0 <setkilled>
    800029a2:	b769                	j	8000292c <usertrap+0x8e>
    yield();
    800029a4:	fffff097          	auipc	ra,0xfffff
    800029a8:	72a080e7          	jalr	1834(ra) # 800020ce <yield>
    800029ac:	bf79                	j	8000294a <usertrap+0xac>

00000000800029ae <kerneltrap>:
{
    800029ae:	7179                	addi	sp,sp,-48
    800029b0:	f406                	sd	ra,40(sp)
    800029b2:	f022                	sd	s0,32(sp)
    800029b4:	ec26                	sd	s1,24(sp)
    800029b6:	e84a                	sd	s2,16(sp)
    800029b8:	e44e                	sd	s3,8(sp)
    800029ba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029bc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029c8:	1004f793          	andi	a5,s1,256
    800029cc:	cb85                	beqz	a5,800029fc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029d2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029d4:	ef85                	bnez	a5,80002a0c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029d6:	00000097          	auipc	ra,0x0
    800029da:	e26080e7          	jalr	-474(ra) # 800027fc <devintr>
    800029de:	cd1d                	beqz	a0,80002a1c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e0:	4789                	li	a5,2
    800029e2:	06f50a63          	beq	a0,a5,80002a56 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029e6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ea:	10049073          	csrw	sstatus,s1
}
    800029ee:	70a2                	ld	ra,40(sp)
    800029f0:	7402                	ld	s0,32(sp)
    800029f2:	64e2                	ld	s1,24(sp)
    800029f4:	6942                	ld	s2,16(sp)
    800029f6:	69a2                	ld	s3,8(sp)
    800029f8:	6145                	addi	sp,sp,48
    800029fa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029fc:	00006517          	auipc	a0,0x6
    80002a00:	9dc50513          	addi	a0,a0,-1572 # 800083d8 <states.0+0xc8>
    80002a04:	ffffe097          	auipc	ra,0xffffe
    80002a08:	b3c080e7          	jalr	-1220(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a0c:	00006517          	auipc	a0,0x6
    80002a10:	9f450513          	addi	a0,a0,-1548 # 80008400 <states.0+0xf0>
    80002a14:	ffffe097          	auipc	ra,0xffffe
    80002a18:	b2c080e7          	jalr	-1236(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002a1c:	85ce                	mv	a1,s3
    80002a1e:	00006517          	auipc	a0,0x6
    80002a22:	a0250513          	addi	a0,a0,-1534 # 80008420 <states.0+0x110>
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	b64080e7          	jalr	-1180(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a2e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a32:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a36:	00006517          	auipc	a0,0x6
    80002a3a:	9fa50513          	addi	a0,a0,-1542 # 80008430 <states.0+0x120>
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	b4c080e7          	jalr	-1204(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	a0250513          	addi	a0,a0,-1534 # 80008448 <states.0+0x138>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	af2080e7          	jalr	-1294(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	f7a080e7          	jalr	-134(ra) # 800019d0 <myproc>
    80002a5e:	d541                	beqz	a0,800029e6 <kerneltrap+0x38>
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	f70080e7          	jalr	-144(ra) # 800019d0 <myproc>
    80002a68:	4d18                	lw	a4,24(a0)
    80002a6a:	4791                	li	a5,4
    80002a6c:	f6f71de3          	bne	a4,a5,800029e6 <kerneltrap+0x38>
    yield();
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	65e080e7          	jalr	1630(ra) # 800020ce <yield>
    80002a78:	b7bd                	j	800029e6 <kerneltrap+0x38>

0000000080002a7a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	1000                	addi	s0,sp,32
    80002a84:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	f4a080e7          	jalr	-182(ra) # 800019d0 <myproc>
  switch (n) {
    80002a8e:	4795                	li	a5,5
    80002a90:	0497e163          	bltu	a5,s1,80002ad2 <argraw+0x58>
    80002a94:	048a                	slli	s1,s1,0x2
    80002a96:	00006717          	auipc	a4,0x6
    80002a9a:	9ea70713          	addi	a4,a4,-1558 # 80008480 <states.0+0x170>
    80002a9e:	94ba                	add	s1,s1,a4
    80002aa0:	409c                	lw	a5,0(s1)
    80002aa2:	97ba                	add	a5,a5,a4
    80002aa4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002aa6:	6d3c                	ld	a5,88(a0)
    80002aa8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aaa:	60e2                	ld	ra,24(sp)
    80002aac:	6442                	ld	s0,16(sp)
    80002aae:	64a2                	ld	s1,8(sp)
    80002ab0:	6105                	addi	sp,sp,32
    80002ab2:	8082                	ret
    return p->trapframe->a1;
    80002ab4:	6d3c                	ld	a5,88(a0)
    80002ab6:	7fa8                	ld	a0,120(a5)
    80002ab8:	bfcd                	j	80002aaa <argraw+0x30>
    return p->trapframe->a2;
    80002aba:	6d3c                	ld	a5,88(a0)
    80002abc:	63c8                	ld	a0,128(a5)
    80002abe:	b7f5                	j	80002aaa <argraw+0x30>
    return p->trapframe->a3;
    80002ac0:	6d3c                	ld	a5,88(a0)
    80002ac2:	67c8                	ld	a0,136(a5)
    80002ac4:	b7dd                	j	80002aaa <argraw+0x30>
    return p->trapframe->a4;
    80002ac6:	6d3c                	ld	a5,88(a0)
    80002ac8:	6bc8                	ld	a0,144(a5)
    80002aca:	b7c5                	j	80002aaa <argraw+0x30>
    return p->trapframe->a5;
    80002acc:	6d3c                	ld	a5,88(a0)
    80002ace:	6fc8                	ld	a0,152(a5)
    80002ad0:	bfe9                	j	80002aaa <argraw+0x30>
  panic("argraw");
    80002ad2:	00006517          	auipc	a0,0x6
    80002ad6:	98650513          	addi	a0,a0,-1658 # 80008458 <states.0+0x148>
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	a66080e7          	jalr	-1434(ra) # 80000540 <panic>

0000000080002ae2 <fetchaddr>:
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	e426                	sd	s1,8(sp)
    80002aea:	e04a                	sd	s2,0(sp)
    80002aec:	1000                	addi	s0,sp,32
    80002aee:	84aa                	mv	s1,a0
    80002af0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	ede080e7          	jalr	-290(ra) # 800019d0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002afa:	653c                	ld	a5,72(a0)
    80002afc:	02f4f863          	bgeu	s1,a5,80002b2c <fetchaddr+0x4a>
    80002b00:	00848713          	addi	a4,s1,8
    80002b04:	02e7e663          	bltu	a5,a4,80002b30 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b08:	46a1                	li	a3,8
    80002b0a:	8626                	mv	a2,s1
    80002b0c:	85ca                	mv	a1,s2
    80002b0e:	6928                	ld	a0,80(a0)
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	c08080e7          	jalr	-1016(ra) # 80001718 <copyin>
    80002b18:	00a03533          	snez	a0,a0
    80002b1c:	40a00533          	neg	a0,a0
}
    80002b20:	60e2                	ld	ra,24(sp)
    80002b22:	6442                	ld	s0,16(sp)
    80002b24:	64a2                	ld	s1,8(sp)
    80002b26:	6902                	ld	s2,0(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret
    return -1;
    80002b2c:	557d                	li	a0,-1
    80002b2e:	bfcd                	j	80002b20 <fetchaddr+0x3e>
    80002b30:	557d                	li	a0,-1
    80002b32:	b7fd                	j	80002b20 <fetchaddr+0x3e>

0000000080002b34 <fetchstr>:
{
    80002b34:	7179                	addi	sp,sp,-48
    80002b36:	f406                	sd	ra,40(sp)
    80002b38:	f022                	sd	s0,32(sp)
    80002b3a:	ec26                	sd	s1,24(sp)
    80002b3c:	e84a                	sd	s2,16(sp)
    80002b3e:	e44e                	sd	s3,8(sp)
    80002b40:	1800                	addi	s0,sp,48
    80002b42:	892a                	mv	s2,a0
    80002b44:	84ae                	mv	s1,a1
    80002b46:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	e88080e7          	jalr	-376(ra) # 800019d0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b50:	86ce                	mv	a3,s3
    80002b52:	864a                	mv	a2,s2
    80002b54:	85a6                	mv	a1,s1
    80002b56:	6928                	ld	a0,80(a0)
    80002b58:	fffff097          	auipc	ra,0xfffff
    80002b5c:	c4e080e7          	jalr	-946(ra) # 800017a6 <copyinstr>
    80002b60:	00054e63          	bltz	a0,80002b7c <fetchstr+0x48>
  return strlen(buf);
    80002b64:	8526                	mv	a0,s1
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	2e8080e7          	jalr	744(ra) # 80000e4e <strlen>
}
    80002b6e:	70a2                	ld	ra,40(sp)
    80002b70:	7402                	ld	s0,32(sp)
    80002b72:	64e2                	ld	s1,24(sp)
    80002b74:	6942                	ld	s2,16(sp)
    80002b76:	69a2                	ld	s3,8(sp)
    80002b78:	6145                	addi	sp,sp,48
    80002b7a:	8082                	ret
    return -1;
    80002b7c:	557d                	li	a0,-1
    80002b7e:	bfc5                	j	80002b6e <fetchstr+0x3a>

0000000080002b80 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	1000                	addi	s0,sp,32
    80002b8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	eee080e7          	jalr	-274(ra) # 80002a7a <argraw>
    80002b94:	c088                	sw	a0,0(s1)
}
    80002b96:	60e2                	ld	ra,24(sp)
    80002b98:	6442                	ld	s0,16(sp)
    80002b9a:	64a2                	ld	s1,8(sp)
    80002b9c:	6105                	addi	sp,sp,32
    80002b9e:	8082                	ret

0000000080002ba0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ba0:	1101                	addi	sp,sp,-32
    80002ba2:	ec06                	sd	ra,24(sp)
    80002ba4:	e822                	sd	s0,16(sp)
    80002ba6:	e426                	sd	s1,8(sp)
    80002ba8:	1000                	addi	s0,sp,32
    80002baa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bac:	00000097          	auipc	ra,0x0
    80002bb0:	ece080e7          	jalr	-306(ra) # 80002a7a <argraw>
    80002bb4:	e088                	sd	a0,0(s1)
}
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret

0000000080002bc0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bc0:	7179                	addi	sp,sp,-48
    80002bc2:	f406                	sd	ra,40(sp)
    80002bc4:	f022                	sd	s0,32(sp)
    80002bc6:	ec26                	sd	s1,24(sp)
    80002bc8:	e84a                	sd	s2,16(sp)
    80002bca:	1800                	addi	s0,sp,48
    80002bcc:	84ae                	mv	s1,a1
    80002bce:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002bd0:	fd840593          	addi	a1,s0,-40
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	fcc080e7          	jalr	-52(ra) # 80002ba0 <argaddr>
  return fetchstr(addr, buf, max);
    80002bdc:	864a                	mv	a2,s2
    80002bde:	85a6                	mv	a1,s1
    80002be0:	fd843503          	ld	a0,-40(s0)
    80002be4:	00000097          	auipc	ra,0x0
    80002be8:	f50080e7          	jalr	-176(ra) # 80002b34 <fetchstr>
}
    80002bec:	70a2                	ld	ra,40(sp)
    80002bee:	7402                	ld	s0,32(sp)
    80002bf0:	64e2                	ld	s1,24(sp)
    80002bf2:	6942                	ld	s2,16(sp)
    80002bf4:	6145                	addi	sp,sp,48
    80002bf6:	8082                	ret

0000000080002bf8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002bf8:	1101                	addi	sp,sp,-32
    80002bfa:	ec06                	sd	ra,24(sp)
    80002bfc:	e822                	sd	s0,16(sp)
    80002bfe:	e426                	sd	s1,8(sp)
    80002c00:	e04a                	sd	s2,0(sp)
    80002c02:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c04:	fffff097          	auipc	ra,0xfffff
    80002c08:	dcc080e7          	jalr	-564(ra) # 800019d0 <myproc>
    80002c0c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c0e:	05853903          	ld	s2,88(a0)
    80002c12:	0a893783          	ld	a5,168(s2)
    80002c16:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c1a:	37fd                	addiw	a5,a5,-1
    80002c1c:	4751                	li	a4,20
    80002c1e:	00f76f63          	bltu	a4,a5,80002c3c <syscall+0x44>
    80002c22:	00369713          	slli	a4,a3,0x3
    80002c26:	00006797          	auipc	a5,0x6
    80002c2a:	87278793          	addi	a5,a5,-1934 # 80008498 <syscalls>
    80002c2e:	97ba                	add	a5,a5,a4
    80002c30:	639c                	ld	a5,0(a5)
    80002c32:	c789                	beqz	a5,80002c3c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c34:	9782                	jalr	a5
    80002c36:	06a93823          	sd	a0,112(s2)
    80002c3a:	a839                	j	80002c58 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c3c:	15848613          	addi	a2,s1,344
    80002c40:	588c                	lw	a1,48(s1)
    80002c42:	00006517          	auipc	a0,0x6
    80002c46:	81e50513          	addi	a0,a0,-2018 # 80008460 <states.0+0x150>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	940080e7          	jalr	-1728(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c52:	6cbc                	ld	a5,88(s1)
    80002c54:	577d                	li	a4,-1
    80002c56:	fbb8                	sd	a4,112(a5)
  }
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6902                	ld	s2,0(sp)
    80002c60:	6105                	addi	sp,sp,32
    80002c62:	8082                	ret

0000000080002c64 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c64:	1101                	addi	sp,sp,-32
    80002c66:	ec06                	sd	ra,24(sp)
    80002c68:	e822                	sd	s0,16(sp)
    80002c6a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c6c:	fec40593          	addi	a1,s0,-20
    80002c70:	4501                	li	a0,0
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	f0e080e7          	jalr	-242(ra) # 80002b80 <argint>
  exit(n);
    80002c7a:	fec42503          	lw	a0,-20(s0)
    80002c7e:	fffff097          	auipc	ra,0xfffff
    80002c82:	5da080e7          	jalr	1498(ra) # 80002258 <exit>
  return 0;  // not reached
}
    80002c86:	4501                	li	a0,0
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret

0000000080002c90 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c90:	1141                	addi	sp,sp,-16
    80002c92:	e406                	sd	ra,8(sp)
    80002c94:	e022                	sd	s0,0(sp)
    80002c96:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	d38080e7          	jalr	-712(ra) # 800019d0 <myproc>
}
    80002ca0:	5908                	lw	a0,48(a0)
    80002ca2:	60a2                	ld	ra,8(sp)
    80002ca4:	6402                	ld	s0,0(sp)
    80002ca6:	0141                	addi	sp,sp,16
    80002ca8:	8082                	ret

0000000080002caa <sys_fork>:

uint64
sys_fork(void)
{
    80002caa:	1141                	addi	sp,sp,-16
    80002cac:	e406                	sd	ra,8(sp)
    80002cae:	e022                	sd	s0,0(sp)
    80002cb0:	0800                	addi	s0,sp,16
  return fork();
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	0e0080e7          	jalr	224(ra) # 80001d92 <fork>
}
    80002cba:	60a2                	ld	ra,8(sp)
    80002cbc:	6402                	ld	s0,0(sp)
    80002cbe:	0141                	addi	sp,sp,16
    80002cc0:	8082                	ret

0000000080002cc2 <sys_wait>:

uint64
sys_wait(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cca:	fe840593          	addi	a1,s0,-24
    80002cce:	4501                	li	a0,0
    80002cd0:	00000097          	auipc	ra,0x0
    80002cd4:	ed0080e7          	jalr	-304(ra) # 80002ba0 <argaddr>
  return wait(p);
    80002cd8:	fe843503          	ld	a0,-24(s0)
    80002cdc:	fffff097          	auipc	ra,0xfffff
    80002ce0:	722080e7          	jalr	1826(ra) # 800023fe <wait>
}
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	6105                	addi	sp,sp,32
    80002cea:	8082                	ret

0000000080002cec <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cec:	7179                	addi	sp,sp,-48
    80002cee:	f406                	sd	ra,40(sp)
    80002cf0:	f022                	sd	s0,32(sp)
    80002cf2:	ec26                	sd	s1,24(sp)
    80002cf4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cf6:	fdc40593          	addi	a1,s0,-36
    80002cfa:	4501                	li	a0,0
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	e84080e7          	jalr	-380(ra) # 80002b80 <argint>
  addr = myproc()->sz;
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	ccc080e7          	jalr	-820(ra) # 800019d0 <myproc>
    80002d0c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d0e:	fdc42503          	lw	a0,-36(s0)
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	024080e7          	jalr	36(ra) # 80001d36 <growproc>
    80002d1a:	00054863          	bltz	a0,80002d2a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d1e:	8526                	mv	a0,s1
    80002d20:	70a2                	ld	ra,40(sp)
    80002d22:	7402                	ld	s0,32(sp)
    80002d24:	64e2                	ld	s1,24(sp)
    80002d26:	6145                	addi	sp,sp,48
    80002d28:	8082                	ret
    return -1;
    80002d2a:	54fd                	li	s1,-1
    80002d2c:	bfcd                	j	80002d1e <sys_sbrk+0x32>

0000000080002d2e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d2e:	7139                	addi	sp,sp,-64
    80002d30:	fc06                	sd	ra,56(sp)
    80002d32:	f822                	sd	s0,48(sp)
    80002d34:	f426                	sd	s1,40(sp)
    80002d36:	f04a                	sd	s2,32(sp)
    80002d38:	ec4e                	sd	s3,24(sp)
    80002d3a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d3c:	fcc40593          	addi	a1,s0,-52
    80002d40:	4501                	li	a0,0
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	e3e080e7          	jalr	-450(ra) # 80002b80 <argint>
  acquire(&tickslock);
    80002d4a:	00014517          	auipc	a0,0x14
    80002d4e:	e8650513          	addi	a0,a0,-378 # 80016bd0 <tickslock>
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	e84080e7          	jalr	-380(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d5a:	00006917          	auipc	s2,0x6
    80002d5e:	bd692903          	lw	s2,-1066(s2) # 80008930 <ticks>
  while(ticks - ticks0 < n){
    80002d62:	fcc42783          	lw	a5,-52(s0)
    80002d66:	cf9d                	beqz	a5,80002da4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d68:	00014997          	auipc	s3,0x14
    80002d6c:	e6898993          	addi	s3,s3,-408 # 80016bd0 <tickslock>
    80002d70:	00006497          	auipc	s1,0x6
    80002d74:	bc048493          	addi	s1,s1,-1088 # 80008930 <ticks>
    if(killed(myproc())){
    80002d78:	fffff097          	auipc	ra,0xfffff
    80002d7c:	c58080e7          	jalr	-936(ra) # 800019d0 <myproc>
    80002d80:	fffff097          	auipc	ra,0xfffff
    80002d84:	64c080e7          	jalr	1612(ra) # 800023cc <killed>
    80002d88:	ed15                	bnez	a0,80002dc4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d8a:	85ce                	mv	a1,s3
    80002d8c:	8526                	mv	a0,s1
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	396080e7          	jalr	918(ra) # 80002124 <sleep>
  while(ticks - ticks0 < n){
    80002d96:	409c                	lw	a5,0(s1)
    80002d98:	412787bb          	subw	a5,a5,s2
    80002d9c:	fcc42703          	lw	a4,-52(s0)
    80002da0:	fce7ece3          	bltu	a5,a4,80002d78 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002da4:	00014517          	auipc	a0,0x14
    80002da8:	e2c50513          	addi	a0,a0,-468 # 80016bd0 <tickslock>
    80002dac:	ffffe097          	auipc	ra,0xffffe
    80002db0:	ede080e7          	jalr	-290(ra) # 80000c8a <release>
  return 0;
    80002db4:	4501                	li	a0,0
}
    80002db6:	70e2                	ld	ra,56(sp)
    80002db8:	7442                	ld	s0,48(sp)
    80002dba:	74a2                	ld	s1,40(sp)
    80002dbc:	7902                	ld	s2,32(sp)
    80002dbe:	69e2                	ld	s3,24(sp)
    80002dc0:	6121                	addi	sp,sp,64
    80002dc2:	8082                	ret
      release(&tickslock);
    80002dc4:	00014517          	auipc	a0,0x14
    80002dc8:	e0c50513          	addi	a0,a0,-500 # 80016bd0 <tickslock>
    80002dcc:	ffffe097          	auipc	ra,0xffffe
    80002dd0:	ebe080e7          	jalr	-322(ra) # 80000c8a <release>
      return -1;
    80002dd4:	557d                	li	a0,-1
    80002dd6:	b7c5                	j	80002db6 <sys_sleep+0x88>

0000000080002dd8 <sys_kill>:

uint64
sys_kill(void)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002de0:	fec40593          	addi	a1,s0,-20
    80002de4:	4501                	li	a0,0
    80002de6:	00000097          	auipc	ra,0x0
    80002dea:	d9a080e7          	jalr	-614(ra) # 80002b80 <argint>
  return kill(pid);
    80002dee:	fec42503          	lw	a0,-20(s0)
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	53c080e7          	jalr	1340(ra) # 8000232e <kill>
}
    80002dfa:	60e2                	ld	ra,24(sp)
    80002dfc:	6442                	ld	s0,16(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e02:	1101                	addi	sp,sp,-32
    80002e04:	ec06                	sd	ra,24(sp)
    80002e06:	e822                	sd	s0,16(sp)
    80002e08:	e426                	sd	s1,8(sp)
    80002e0a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e0c:	00014517          	auipc	a0,0x14
    80002e10:	dc450513          	addi	a0,a0,-572 # 80016bd0 <tickslock>
    80002e14:	ffffe097          	auipc	ra,0xffffe
    80002e18:	dc2080e7          	jalr	-574(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002e1c:	00006497          	auipc	s1,0x6
    80002e20:	b144a483          	lw	s1,-1260(s1) # 80008930 <ticks>
  release(&tickslock);
    80002e24:	00014517          	auipc	a0,0x14
    80002e28:	dac50513          	addi	a0,a0,-596 # 80016bd0 <tickslock>
    80002e2c:	ffffe097          	auipc	ra,0xffffe
    80002e30:	e5e080e7          	jalr	-418(ra) # 80000c8a <release>
  return xticks;
}
    80002e34:	02049513          	slli	a0,s1,0x20
    80002e38:	9101                	srli	a0,a0,0x20
    80002e3a:	60e2                	ld	ra,24(sp)
    80002e3c:	6442                	ld	s0,16(sp)
    80002e3e:	64a2                	ld	s1,8(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e44:	7179                	addi	sp,sp,-48
    80002e46:	f406                	sd	ra,40(sp)
    80002e48:	f022                	sd	s0,32(sp)
    80002e4a:	ec26                	sd	s1,24(sp)
    80002e4c:	e84a                	sd	s2,16(sp)
    80002e4e:	e44e                	sd	s3,8(sp)
    80002e50:	e052                	sd	s4,0(sp)
    80002e52:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e54:	00005597          	auipc	a1,0x5
    80002e58:	6f458593          	addi	a1,a1,1780 # 80008548 <syscalls+0xb0>
    80002e5c:	00014517          	auipc	a0,0x14
    80002e60:	d8c50513          	addi	a0,a0,-628 # 80016be8 <bcache>
    80002e64:	ffffe097          	auipc	ra,0xffffe
    80002e68:	ce2080e7          	jalr	-798(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e6c:	0001c797          	auipc	a5,0x1c
    80002e70:	d7c78793          	addi	a5,a5,-644 # 8001ebe8 <bcache+0x8000>
    80002e74:	0001c717          	auipc	a4,0x1c
    80002e78:	fdc70713          	addi	a4,a4,-36 # 8001ee50 <bcache+0x8268>
    80002e7c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e80:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e84:	00014497          	auipc	s1,0x14
    80002e88:	d7c48493          	addi	s1,s1,-644 # 80016c00 <bcache+0x18>
    b->next = bcache.head.next;
    80002e8c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e8e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e90:	00005a17          	auipc	s4,0x5
    80002e94:	6c0a0a13          	addi	s4,s4,1728 # 80008550 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002e98:	2b893783          	ld	a5,696(s2)
    80002e9c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e9e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ea2:	85d2                	mv	a1,s4
    80002ea4:	01048513          	addi	a0,s1,16
    80002ea8:	00001097          	auipc	ra,0x1
    80002eac:	4c8080e7          	jalr	1224(ra) # 80004370 <initsleeplock>
    bcache.head.next->prev = b;
    80002eb0:	2b893783          	ld	a5,696(s2)
    80002eb4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eb6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eba:	45848493          	addi	s1,s1,1112
    80002ebe:	fd349de3          	bne	s1,s3,80002e98 <binit+0x54>
  }
}
    80002ec2:	70a2                	ld	ra,40(sp)
    80002ec4:	7402                	ld	s0,32(sp)
    80002ec6:	64e2                	ld	s1,24(sp)
    80002ec8:	6942                	ld	s2,16(sp)
    80002eca:	69a2                	ld	s3,8(sp)
    80002ecc:	6a02                	ld	s4,0(sp)
    80002ece:	6145                	addi	sp,sp,48
    80002ed0:	8082                	ret

0000000080002ed2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ed2:	7179                	addi	sp,sp,-48
    80002ed4:	f406                	sd	ra,40(sp)
    80002ed6:	f022                	sd	s0,32(sp)
    80002ed8:	ec26                	sd	s1,24(sp)
    80002eda:	e84a                	sd	s2,16(sp)
    80002edc:	e44e                	sd	s3,8(sp)
    80002ede:	1800                	addi	s0,sp,48
    80002ee0:	892a                	mv	s2,a0
    80002ee2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ee4:	00014517          	auipc	a0,0x14
    80002ee8:	d0450513          	addi	a0,a0,-764 # 80016be8 <bcache>
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	cea080e7          	jalr	-790(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ef4:	0001c497          	auipc	s1,0x1c
    80002ef8:	fac4b483          	ld	s1,-84(s1) # 8001eea0 <bcache+0x82b8>
    80002efc:	0001c797          	auipc	a5,0x1c
    80002f00:	f5478793          	addi	a5,a5,-172 # 8001ee50 <bcache+0x8268>
    80002f04:	02f48f63          	beq	s1,a5,80002f42 <bread+0x70>
    80002f08:	873e                	mv	a4,a5
    80002f0a:	a021                	j	80002f12 <bread+0x40>
    80002f0c:	68a4                	ld	s1,80(s1)
    80002f0e:	02e48a63          	beq	s1,a4,80002f42 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f12:	449c                	lw	a5,8(s1)
    80002f14:	ff279ce3          	bne	a5,s2,80002f0c <bread+0x3a>
    80002f18:	44dc                	lw	a5,12(s1)
    80002f1a:	ff3799e3          	bne	a5,s3,80002f0c <bread+0x3a>
      b->refcnt++;
    80002f1e:	40bc                	lw	a5,64(s1)
    80002f20:	2785                	addiw	a5,a5,1
    80002f22:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f24:	00014517          	auipc	a0,0x14
    80002f28:	cc450513          	addi	a0,a0,-828 # 80016be8 <bcache>
    80002f2c:	ffffe097          	auipc	ra,0xffffe
    80002f30:	d5e080e7          	jalr	-674(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f34:	01048513          	addi	a0,s1,16
    80002f38:	00001097          	auipc	ra,0x1
    80002f3c:	472080e7          	jalr	1138(ra) # 800043aa <acquiresleep>
      return b;
    80002f40:	a8b9                	j	80002f9e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f42:	0001c497          	auipc	s1,0x1c
    80002f46:	f564b483          	ld	s1,-170(s1) # 8001ee98 <bcache+0x82b0>
    80002f4a:	0001c797          	auipc	a5,0x1c
    80002f4e:	f0678793          	addi	a5,a5,-250 # 8001ee50 <bcache+0x8268>
    80002f52:	00f48863          	beq	s1,a5,80002f62 <bread+0x90>
    80002f56:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f58:	40bc                	lw	a5,64(s1)
    80002f5a:	cf81                	beqz	a5,80002f72 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f5c:	64a4                	ld	s1,72(s1)
    80002f5e:	fee49de3          	bne	s1,a4,80002f58 <bread+0x86>
  panic("bget: no buffers");
    80002f62:	00005517          	auipc	a0,0x5
    80002f66:	5f650513          	addi	a0,a0,1526 # 80008558 <syscalls+0xc0>
    80002f6a:	ffffd097          	auipc	ra,0xffffd
    80002f6e:	5d6080e7          	jalr	1494(ra) # 80000540 <panic>
      b->dev = dev;
    80002f72:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f76:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f7e:	4785                	li	a5,1
    80002f80:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f82:	00014517          	auipc	a0,0x14
    80002f86:	c6650513          	addi	a0,a0,-922 # 80016be8 <bcache>
    80002f8a:	ffffe097          	auipc	ra,0xffffe
    80002f8e:	d00080e7          	jalr	-768(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f92:	01048513          	addi	a0,s1,16
    80002f96:	00001097          	auipc	ra,0x1
    80002f9a:	414080e7          	jalr	1044(ra) # 800043aa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f9e:	409c                	lw	a5,0(s1)
    80002fa0:	cb89                	beqz	a5,80002fb2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fa2:	8526                	mv	a0,s1
    80002fa4:	70a2                	ld	ra,40(sp)
    80002fa6:	7402                	ld	s0,32(sp)
    80002fa8:	64e2                	ld	s1,24(sp)
    80002faa:	6942                	ld	s2,16(sp)
    80002fac:	69a2                	ld	s3,8(sp)
    80002fae:	6145                	addi	sp,sp,48
    80002fb0:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fb2:	4581                	li	a1,0
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	00003097          	auipc	ra,0x3
    80002fba:	fdc080e7          	jalr	-36(ra) # 80005f92 <virtio_disk_rw>
    b->valid = 1;
    80002fbe:	4785                	li	a5,1
    80002fc0:	c09c                	sw	a5,0(s1)
  return b;
    80002fc2:	b7c5                	j	80002fa2 <bread+0xd0>

0000000080002fc4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	e426                	sd	s1,8(sp)
    80002fcc:	1000                	addi	s0,sp,32
    80002fce:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fd0:	0541                	addi	a0,a0,16
    80002fd2:	00001097          	auipc	ra,0x1
    80002fd6:	472080e7          	jalr	1138(ra) # 80004444 <holdingsleep>
    80002fda:	cd01                	beqz	a0,80002ff2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fdc:	4585                	li	a1,1
    80002fde:	8526                	mv	a0,s1
    80002fe0:	00003097          	auipc	ra,0x3
    80002fe4:	fb2080e7          	jalr	-78(ra) # 80005f92 <virtio_disk_rw>
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	64a2                	ld	s1,8(sp)
    80002fee:	6105                	addi	sp,sp,32
    80002ff0:	8082                	ret
    panic("bwrite");
    80002ff2:	00005517          	auipc	a0,0x5
    80002ff6:	57e50513          	addi	a0,a0,1406 # 80008570 <syscalls+0xd8>
    80002ffa:	ffffd097          	auipc	ra,0xffffd
    80002ffe:	546080e7          	jalr	1350(ra) # 80000540 <panic>

0000000080003002 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003002:	1101                	addi	sp,sp,-32
    80003004:	ec06                	sd	ra,24(sp)
    80003006:	e822                	sd	s0,16(sp)
    80003008:	e426                	sd	s1,8(sp)
    8000300a:	e04a                	sd	s2,0(sp)
    8000300c:	1000                	addi	s0,sp,32
    8000300e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003010:	01050913          	addi	s2,a0,16
    80003014:	854a                	mv	a0,s2
    80003016:	00001097          	auipc	ra,0x1
    8000301a:	42e080e7          	jalr	1070(ra) # 80004444 <holdingsleep>
    8000301e:	c92d                	beqz	a0,80003090 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003020:	854a                	mv	a0,s2
    80003022:	00001097          	auipc	ra,0x1
    80003026:	3de080e7          	jalr	990(ra) # 80004400 <releasesleep>

  acquire(&bcache.lock);
    8000302a:	00014517          	auipc	a0,0x14
    8000302e:	bbe50513          	addi	a0,a0,-1090 # 80016be8 <bcache>
    80003032:	ffffe097          	auipc	ra,0xffffe
    80003036:	ba4080e7          	jalr	-1116(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000303a:	40bc                	lw	a5,64(s1)
    8000303c:	37fd                	addiw	a5,a5,-1
    8000303e:	0007871b          	sext.w	a4,a5
    80003042:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003044:	eb05                	bnez	a4,80003074 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003046:	68bc                	ld	a5,80(s1)
    80003048:	64b8                	ld	a4,72(s1)
    8000304a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000304c:	64bc                	ld	a5,72(s1)
    8000304e:	68b8                	ld	a4,80(s1)
    80003050:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003052:	0001c797          	auipc	a5,0x1c
    80003056:	b9678793          	addi	a5,a5,-1130 # 8001ebe8 <bcache+0x8000>
    8000305a:	2b87b703          	ld	a4,696(a5)
    8000305e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003060:	0001c717          	auipc	a4,0x1c
    80003064:	df070713          	addi	a4,a4,-528 # 8001ee50 <bcache+0x8268>
    80003068:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000306a:	2b87b703          	ld	a4,696(a5)
    8000306e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003070:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003074:	00014517          	auipc	a0,0x14
    80003078:	b7450513          	addi	a0,a0,-1164 # 80016be8 <bcache>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>
}
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6902                	ld	s2,0(sp)
    8000308c:	6105                	addi	sp,sp,32
    8000308e:	8082                	ret
    panic("brelse");
    80003090:	00005517          	auipc	a0,0x5
    80003094:	4e850513          	addi	a0,a0,1256 # 80008578 <syscalls+0xe0>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4a8080e7          	jalr	1192(ra) # 80000540 <panic>

00000000800030a0 <bpin>:

void
bpin(struct buf *b) {
    800030a0:	1101                	addi	sp,sp,-32
    800030a2:	ec06                	sd	ra,24(sp)
    800030a4:	e822                	sd	s0,16(sp)
    800030a6:	e426                	sd	s1,8(sp)
    800030a8:	1000                	addi	s0,sp,32
    800030aa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ac:	00014517          	auipc	a0,0x14
    800030b0:	b3c50513          	addi	a0,a0,-1220 # 80016be8 <bcache>
    800030b4:	ffffe097          	auipc	ra,0xffffe
    800030b8:	b22080e7          	jalr	-1246(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	2785                	addiw	a5,a5,1
    800030c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c2:	00014517          	auipc	a0,0x14
    800030c6:	b2650513          	addi	a0,a0,-1242 # 80016be8 <bcache>
    800030ca:	ffffe097          	auipc	ra,0xffffe
    800030ce:	bc0080e7          	jalr	-1088(ra) # 80000c8a <release>
}
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6105                	addi	sp,sp,32
    800030da:	8082                	ret

00000000800030dc <bunpin>:

void
bunpin(struct buf *b) {
    800030dc:	1101                	addi	sp,sp,-32
    800030de:	ec06                	sd	ra,24(sp)
    800030e0:	e822                	sd	s0,16(sp)
    800030e2:	e426                	sd	s1,8(sp)
    800030e4:	1000                	addi	s0,sp,32
    800030e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030e8:	00014517          	auipc	a0,0x14
    800030ec:	b0050513          	addi	a0,a0,-1280 # 80016be8 <bcache>
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	ae6080e7          	jalr	-1306(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030f8:	40bc                	lw	a5,64(s1)
    800030fa:	37fd                	addiw	a5,a5,-1
    800030fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030fe:	00014517          	auipc	a0,0x14
    80003102:	aea50513          	addi	a0,a0,-1302 # 80016be8 <bcache>
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	b84080e7          	jalr	-1148(ra) # 80000c8a <release>
}
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	64a2                	ld	s1,8(sp)
    80003114:	6105                	addi	sp,sp,32
    80003116:	8082                	ret

0000000080003118 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	e04a                	sd	s2,0(sp)
    80003122:	1000                	addi	s0,sp,32
    80003124:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003126:	00d5d59b          	srliw	a1,a1,0xd
    8000312a:	0001c797          	auipc	a5,0x1c
    8000312e:	19a7a783          	lw	a5,410(a5) # 8001f2c4 <sb+0x1c>
    80003132:	9dbd                	addw	a1,a1,a5
    80003134:	00000097          	auipc	ra,0x0
    80003138:	d9e080e7          	jalr	-610(ra) # 80002ed2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000313c:	0074f713          	andi	a4,s1,7
    80003140:	4785                	li	a5,1
    80003142:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003146:	14ce                	slli	s1,s1,0x33
    80003148:	90d9                	srli	s1,s1,0x36
    8000314a:	00950733          	add	a4,a0,s1
    8000314e:	05874703          	lbu	a4,88(a4)
    80003152:	00e7f6b3          	and	a3,a5,a4
    80003156:	c69d                	beqz	a3,80003184 <bfree+0x6c>
    80003158:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000315a:	94aa                	add	s1,s1,a0
    8000315c:	fff7c793          	not	a5,a5
    80003160:	8f7d                	and	a4,a4,a5
    80003162:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003166:	00001097          	auipc	ra,0x1
    8000316a:	126080e7          	jalr	294(ra) # 8000428c <log_write>
  brelse(bp);
    8000316e:	854a                	mv	a0,s2
    80003170:	00000097          	auipc	ra,0x0
    80003174:	e92080e7          	jalr	-366(ra) # 80003002 <brelse>
}
    80003178:	60e2                	ld	ra,24(sp)
    8000317a:	6442                	ld	s0,16(sp)
    8000317c:	64a2                	ld	s1,8(sp)
    8000317e:	6902                	ld	s2,0(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret
    panic("freeing free block");
    80003184:	00005517          	auipc	a0,0x5
    80003188:	3fc50513          	addi	a0,a0,1020 # 80008580 <syscalls+0xe8>
    8000318c:	ffffd097          	auipc	ra,0xffffd
    80003190:	3b4080e7          	jalr	948(ra) # 80000540 <panic>

0000000080003194 <balloc>:
{
    80003194:	711d                	addi	sp,sp,-96
    80003196:	ec86                	sd	ra,88(sp)
    80003198:	e8a2                	sd	s0,80(sp)
    8000319a:	e4a6                	sd	s1,72(sp)
    8000319c:	e0ca                	sd	s2,64(sp)
    8000319e:	fc4e                	sd	s3,56(sp)
    800031a0:	f852                	sd	s4,48(sp)
    800031a2:	f456                	sd	s5,40(sp)
    800031a4:	f05a                	sd	s6,32(sp)
    800031a6:	ec5e                	sd	s7,24(sp)
    800031a8:	e862                	sd	s8,16(sp)
    800031aa:	e466                	sd	s9,8(sp)
    800031ac:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031ae:	0001c797          	auipc	a5,0x1c
    800031b2:	0fe7a783          	lw	a5,254(a5) # 8001f2ac <sb+0x4>
    800031b6:	cff5                	beqz	a5,800032b2 <balloc+0x11e>
    800031b8:	8baa                	mv	s7,a0
    800031ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031bc:	0001cb17          	auipc	s6,0x1c
    800031c0:	0ecb0b13          	addi	s6,s6,236 # 8001f2a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ca:	6c89                	lui	s9,0x2
    800031cc:	a061                	j	80003254 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031ce:	97ca                	add	a5,a5,s2
    800031d0:	8e55                	or	a2,a2,a3
    800031d2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031d6:	854a                	mv	a0,s2
    800031d8:	00001097          	auipc	ra,0x1
    800031dc:	0b4080e7          	jalr	180(ra) # 8000428c <log_write>
        brelse(bp);
    800031e0:	854a                	mv	a0,s2
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	e20080e7          	jalr	-480(ra) # 80003002 <brelse>
  bp = bread(dev, bno);
    800031ea:	85a6                	mv	a1,s1
    800031ec:	855e                	mv	a0,s7
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	ce4080e7          	jalr	-796(ra) # 80002ed2 <bread>
    800031f6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031f8:	40000613          	li	a2,1024
    800031fc:	4581                	li	a1,0
    800031fe:	05850513          	addi	a0,a0,88
    80003202:	ffffe097          	auipc	ra,0xffffe
    80003206:	ad0080e7          	jalr	-1328(ra) # 80000cd2 <memset>
  log_write(bp);
    8000320a:	854a                	mv	a0,s2
    8000320c:	00001097          	auipc	ra,0x1
    80003210:	080080e7          	jalr	128(ra) # 8000428c <log_write>
  brelse(bp);
    80003214:	854a                	mv	a0,s2
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	dec080e7          	jalr	-532(ra) # 80003002 <brelse>
}
    8000321e:	8526                	mv	a0,s1
    80003220:	60e6                	ld	ra,88(sp)
    80003222:	6446                	ld	s0,80(sp)
    80003224:	64a6                	ld	s1,72(sp)
    80003226:	6906                	ld	s2,64(sp)
    80003228:	79e2                	ld	s3,56(sp)
    8000322a:	7a42                	ld	s4,48(sp)
    8000322c:	7aa2                	ld	s5,40(sp)
    8000322e:	7b02                	ld	s6,32(sp)
    80003230:	6be2                	ld	s7,24(sp)
    80003232:	6c42                	ld	s8,16(sp)
    80003234:	6ca2                	ld	s9,8(sp)
    80003236:	6125                	addi	sp,sp,96
    80003238:	8082                	ret
    brelse(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	dc6080e7          	jalr	-570(ra) # 80003002 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003244:	015c87bb          	addw	a5,s9,s5
    80003248:	00078a9b          	sext.w	s5,a5
    8000324c:	004b2703          	lw	a4,4(s6)
    80003250:	06eaf163          	bgeu	s5,a4,800032b2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003254:	41fad79b          	sraiw	a5,s5,0x1f
    80003258:	0137d79b          	srliw	a5,a5,0x13
    8000325c:	015787bb          	addw	a5,a5,s5
    80003260:	40d7d79b          	sraiw	a5,a5,0xd
    80003264:	01cb2583          	lw	a1,28(s6)
    80003268:	9dbd                	addw	a1,a1,a5
    8000326a:	855e                	mv	a0,s7
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	c66080e7          	jalr	-922(ra) # 80002ed2 <bread>
    80003274:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003276:	004b2503          	lw	a0,4(s6)
    8000327a:	000a849b          	sext.w	s1,s5
    8000327e:	8762                	mv	a4,s8
    80003280:	faa4fde3          	bgeu	s1,a0,8000323a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003284:	00777693          	andi	a3,a4,7
    80003288:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000328c:	41f7579b          	sraiw	a5,a4,0x1f
    80003290:	01d7d79b          	srliw	a5,a5,0x1d
    80003294:	9fb9                	addw	a5,a5,a4
    80003296:	4037d79b          	sraiw	a5,a5,0x3
    8000329a:	00f90633          	add	a2,s2,a5
    8000329e:	05864603          	lbu	a2,88(a2)
    800032a2:	00c6f5b3          	and	a1,a3,a2
    800032a6:	d585                	beqz	a1,800031ce <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a8:	2705                	addiw	a4,a4,1
    800032aa:	2485                	addiw	s1,s1,1
    800032ac:	fd471ae3          	bne	a4,s4,80003280 <balloc+0xec>
    800032b0:	b769                	j	8000323a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800032b2:	00005517          	auipc	a0,0x5
    800032b6:	2e650513          	addi	a0,a0,742 # 80008598 <syscalls+0x100>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	2d0080e7          	jalr	720(ra) # 8000058a <printf>
  return 0;
    800032c2:	4481                	li	s1,0
    800032c4:	bfa9                	j	8000321e <balloc+0x8a>

00000000800032c6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032c6:	7179                	addi	sp,sp,-48
    800032c8:	f406                	sd	ra,40(sp)
    800032ca:	f022                	sd	s0,32(sp)
    800032cc:	ec26                	sd	s1,24(sp)
    800032ce:	e84a                	sd	s2,16(sp)
    800032d0:	e44e                	sd	s3,8(sp)
    800032d2:	e052                	sd	s4,0(sp)
    800032d4:	1800                	addi	s0,sp,48
    800032d6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032d8:	47ad                	li	a5,11
    800032da:	02b7e863          	bltu	a5,a1,8000330a <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800032de:	02059793          	slli	a5,a1,0x20
    800032e2:	01e7d593          	srli	a1,a5,0x1e
    800032e6:	00b504b3          	add	s1,a0,a1
    800032ea:	0504a903          	lw	s2,80(s1)
    800032ee:	06091e63          	bnez	s2,8000336a <bmap+0xa4>
      addr = balloc(ip->dev);
    800032f2:	4108                	lw	a0,0(a0)
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	ea0080e7          	jalr	-352(ra) # 80003194 <balloc>
    800032fc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003300:	06090563          	beqz	s2,8000336a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003304:	0524a823          	sw	s2,80(s1)
    80003308:	a08d                	j	8000336a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000330a:	ff45849b          	addiw	s1,a1,-12
    8000330e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003312:	0ff00793          	li	a5,255
    80003316:	08e7e563          	bltu	a5,a4,800033a0 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000331a:	08052903          	lw	s2,128(a0)
    8000331e:	00091d63          	bnez	s2,80003338 <bmap+0x72>
      addr = balloc(ip->dev);
    80003322:	4108                	lw	a0,0(a0)
    80003324:	00000097          	auipc	ra,0x0
    80003328:	e70080e7          	jalr	-400(ra) # 80003194 <balloc>
    8000332c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003330:	02090d63          	beqz	s2,8000336a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003334:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003338:	85ca                	mv	a1,s2
    8000333a:	0009a503          	lw	a0,0(s3)
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	b94080e7          	jalr	-1132(ra) # 80002ed2 <bread>
    80003346:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003348:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000334c:	02049713          	slli	a4,s1,0x20
    80003350:	01e75593          	srli	a1,a4,0x1e
    80003354:	00b784b3          	add	s1,a5,a1
    80003358:	0004a903          	lw	s2,0(s1)
    8000335c:	02090063          	beqz	s2,8000337c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003360:	8552                	mv	a0,s4
    80003362:	00000097          	auipc	ra,0x0
    80003366:	ca0080e7          	jalr	-864(ra) # 80003002 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000336a:	854a                	mv	a0,s2
    8000336c:	70a2                	ld	ra,40(sp)
    8000336e:	7402                	ld	s0,32(sp)
    80003370:	64e2                	ld	s1,24(sp)
    80003372:	6942                	ld	s2,16(sp)
    80003374:	69a2                	ld	s3,8(sp)
    80003376:	6a02                	ld	s4,0(sp)
    80003378:	6145                	addi	sp,sp,48
    8000337a:	8082                	ret
      addr = balloc(ip->dev);
    8000337c:	0009a503          	lw	a0,0(s3)
    80003380:	00000097          	auipc	ra,0x0
    80003384:	e14080e7          	jalr	-492(ra) # 80003194 <balloc>
    80003388:	0005091b          	sext.w	s2,a0
      if(addr){
    8000338c:	fc090ae3          	beqz	s2,80003360 <bmap+0x9a>
        a[bn] = addr;
    80003390:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003394:	8552                	mv	a0,s4
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	ef6080e7          	jalr	-266(ra) # 8000428c <log_write>
    8000339e:	b7c9                	j	80003360 <bmap+0x9a>
  panic("bmap: out of range");
    800033a0:	00005517          	auipc	a0,0x5
    800033a4:	21050513          	addi	a0,a0,528 # 800085b0 <syscalls+0x118>
    800033a8:	ffffd097          	auipc	ra,0xffffd
    800033ac:	198080e7          	jalr	408(ra) # 80000540 <panic>

00000000800033b0 <iget>:
{
    800033b0:	7179                	addi	sp,sp,-48
    800033b2:	f406                	sd	ra,40(sp)
    800033b4:	f022                	sd	s0,32(sp)
    800033b6:	ec26                	sd	s1,24(sp)
    800033b8:	e84a                	sd	s2,16(sp)
    800033ba:	e44e                	sd	s3,8(sp)
    800033bc:	e052                	sd	s4,0(sp)
    800033be:	1800                	addi	s0,sp,48
    800033c0:	89aa                	mv	s3,a0
    800033c2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033c4:	0001c517          	auipc	a0,0x1c
    800033c8:	f0450513          	addi	a0,a0,-252 # 8001f2c8 <itable>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	80a080e7          	jalr	-2038(ra) # 80000bd6 <acquire>
  empty = 0;
    800033d4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033d6:	0001c497          	auipc	s1,0x1c
    800033da:	f0a48493          	addi	s1,s1,-246 # 8001f2e0 <itable+0x18>
    800033de:	0001e697          	auipc	a3,0x1e
    800033e2:	99268693          	addi	a3,a3,-1646 # 80020d70 <log>
    800033e6:	a039                	j	800033f4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033e8:	02090b63          	beqz	s2,8000341e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ec:	08848493          	addi	s1,s1,136
    800033f0:	02d48a63          	beq	s1,a3,80003424 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f4:	449c                	lw	a5,8(s1)
    800033f6:	fef059e3          	blez	a5,800033e8 <iget+0x38>
    800033fa:	4098                	lw	a4,0(s1)
    800033fc:	ff3716e3          	bne	a4,s3,800033e8 <iget+0x38>
    80003400:	40d8                	lw	a4,4(s1)
    80003402:	ff4713e3          	bne	a4,s4,800033e8 <iget+0x38>
      ip->ref++;
    80003406:	2785                	addiw	a5,a5,1
    80003408:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	ebe50513          	addi	a0,a0,-322 # 8001f2c8 <itable>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
      return ip;
    8000341a:	8926                	mv	s2,s1
    8000341c:	a03d                	j	8000344a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000341e:	f7f9                	bnez	a5,800033ec <iget+0x3c>
    80003420:	8926                	mv	s2,s1
    80003422:	b7e9                	j	800033ec <iget+0x3c>
  if(empty == 0)
    80003424:	02090c63          	beqz	s2,8000345c <iget+0xac>
  ip->dev = dev;
    80003428:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000342c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003430:	4785                	li	a5,1
    80003432:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003436:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000343a:	0001c517          	auipc	a0,0x1c
    8000343e:	e8e50513          	addi	a0,a0,-370 # 8001f2c8 <itable>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
}
    8000344a:	854a                	mv	a0,s2
    8000344c:	70a2                	ld	ra,40(sp)
    8000344e:	7402                	ld	s0,32(sp)
    80003450:	64e2                	ld	s1,24(sp)
    80003452:	6942                	ld	s2,16(sp)
    80003454:	69a2                	ld	s3,8(sp)
    80003456:	6a02                	ld	s4,0(sp)
    80003458:	6145                	addi	sp,sp,48
    8000345a:	8082                	ret
    panic("iget: no inodes");
    8000345c:	00005517          	auipc	a0,0x5
    80003460:	16c50513          	addi	a0,a0,364 # 800085c8 <syscalls+0x130>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	0dc080e7          	jalr	220(ra) # 80000540 <panic>

000000008000346c <fsinit>:
fsinit(int dev) {
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	addi	s0,sp,48
    8000347a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000347c:	4585                	li	a1,1
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	a54080e7          	jalr	-1452(ra) # 80002ed2 <bread>
    80003486:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003488:	0001c997          	auipc	s3,0x1c
    8000348c:	e2098993          	addi	s3,s3,-480 # 8001f2a8 <sb>
    80003490:	02000613          	li	a2,32
    80003494:	05850593          	addi	a1,a0,88
    80003498:	854e                	mv	a0,s3
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	894080e7          	jalr	-1900(ra) # 80000d2e <memmove>
  brelse(bp);
    800034a2:	8526                	mv	a0,s1
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	b5e080e7          	jalr	-1186(ra) # 80003002 <brelse>
  if(sb.magic != FSMAGIC)
    800034ac:	0009a703          	lw	a4,0(s3)
    800034b0:	102037b7          	lui	a5,0x10203
    800034b4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034b8:	02f71263          	bne	a4,a5,800034dc <fsinit+0x70>
  initlog(dev, &sb);
    800034bc:	0001c597          	auipc	a1,0x1c
    800034c0:	dec58593          	addi	a1,a1,-532 # 8001f2a8 <sb>
    800034c4:	854a                	mv	a0,s2
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	b4a080e7          	jalr	-1206(ra) # 80004010 <initlog>
}
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret
    panic("invalid file system");
    800034dc:	00005517          	auipc	a0,0x5
    800034e0:	0fc50513          	addi	a0,a0,252 # 800085d8 <syscalls+0x140>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	05c080e7          	jalr	92(ra) # 80000540 <panic>

00000000800034ec <iinit>:
{
    800034ec:	7179                	addi	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034fa:	00005597          	auipc	a1,0x5
    800034fe:	0f658593          	addi	a1,a1,246 # 800085f0 <syscalls+0x158>
    80003502:	0001c517          	auipc	a0,0x1c
    80003506:	dc650513          	addi	a0,a0,-570 # 8001f2c8 <itable>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	63c080e7          	jalr	1596(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003512:	0001c497          	auipc	s1,0x1c
    80003516:	dde48493          	addi	s1,s1,-546 # 8001f2f0 <itable+0x28>
    8000351a:	0001e997          	auipc	s3,0x1e
    8000351e:	86698993          	addi	s3,s3,-1946 # 80020d80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003522:	00005917          	auipc	s2,0x5
    80003526:	0d690913          	addi	s2,s2,214 # 800085f8 <syscalls+0x160>
    8000352a:	85ca                	mv	a1,s2
    8000352c:	8526                	mv	a0,s1
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	e42080e7          	jalr	-446(ra) # 80004370 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003536:	08848493          	addi	s1,s1,136
    8000353a:	ff3498e3          	bne	s1,s3,8000352a <iinit+0x3e>
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6942                	ld	s2,16(sp)
    80003546:	69a2                	ld	s3,8(sp)
    80003548:	6145                	addi	sp,sp,48
    8000354a:	8082                	ret

000000008000354c <ialloc>:
{
    8000354c:	715d                	addi	sp,sp,-80
    8000354e:	e486                	sd	ra,72(sp)
    80003550:	e0a2                	sd	s0,64(sp)
    80003552:	fc26                	sd	s1,56(sp)
    80003554:	f84a                	sd	s2,48(sp)
    80003556:	f44e                	sd	s3,40(sp)
    80003558:	f052                	sd	s4,32(sp)
    8000355a:	ec56                	sd	s5,24(sp)
    8000355c:	e85a                	sd	s6,16(sp)
    8000355e:	e45e                	sd	s7,8(sp)
    80003560:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003562:	0001c717          	auipc	a4,0x1c
    80003566:	d5272703          	lw	a4,-686(a4) # 8001f2b4 <sb+0xc>
    8000356a:	4785                	li	a5,1
    8000356c:	04e7fa63          	bgeu	a5,a4,800035c0 <ialloc+0x74>
    80003570:	8aaa                	mv	s5,a0
    80003572:	8bae                	mv	s7,a1
    80003574:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003576:	0001ca17          	auipc	s4,0x1c
    8000357a:	d32a0a13          	addi	s4,s4,-718 # 8001f2a8 <sb>
    8000357e:	00048b1b          	sext.w	s6,s1
    80003582:	0044d593          	srli	a1,s1,0x4
    80003586:	018a2783          	lw	a5,24(s4)
    8000358a:	9dbd                	addw	a1,a1,a5
    8000358c:	8556                	mv	a0,s5
    8000358e:	00000097          	auipc	ra,0x0
    80003592:	944080e7          	jalr	-1724(ra) # 80002ed2 <bread>
    80003596:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003598:	05850993          	addi	s3,a0,88
    8000359c:	00f4f793          	andi	a5,s1,15
    800035a0:	079a                	slli	a5,a5,0x6
    800035a2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a4:	00099783          	lh	a5,0(s3)
    800035a8:	c3a1                	beqz	a5,800035e8 <ialloc+0x9c>
    brelse(bp);
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	a58080e7          	jalr	-1448(ra) # 80003002 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b2:	0485                	addi	s1,s1,1
    800035b4:	00ca2703          	lw	a4,12(s4)
    800035b8:	0004879b          	sext.w	a5,s1
    800035bc:	fce7e1e3          	bltu	a5,a4,8000357e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035c0:	00005517          	auipc	a0,0x5
    800035c4:	04050513          	addi	a0,a0,64 # 80008600 <syscalls+0x168>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	fc2080e7          	jalr	-62(ra) # 8000058a <printf>
  return 0;
    800035d0:	4501                	li	a0,0
}
    800035d2:	60a6                	ld	ra,72(sp)
    800035d4:	6406                	ld	s0,64(sp)
    800035d6:	74e2                	ld	s1,56(sp)
    800035d8:	7942                	ld	s2,48(sp)
    800035da:	79a2                	ld	s3,40(sp)
    800035dc:	7a02                	ld	s4,32(sp)
    800035de:	6ae2                	ld	s5,24(sp)
    800035e0:	6b42                	ld	s6,16(sp)
    800035e2:	6ba2                	ld	s7,8(sp)
    800035e4:	6161                	addi	sp,sp,80
    800035e6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035e8:	04000613          	li	a2,64
    800035ec:	4581                	li	a1,0
    800035ee:	854e                	mv	a0,s3
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	6e2080e7          	jalr	1762(ra) # 80000cd2 <memset>
      dip->type = type;
    800035f8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035fc:	854a                	mv	a0,s2
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	c8e080e7          	jalr	-882(ra) # 8000428c <log_write>
      brelse(bp);
    80003606:	854a                	mv	a0,s2
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	9fa080e7          	jalr	-1542(ra) # 80003002 <brelse>
      return iget(dev, inum);
    80003610:	85da                	mv	a1,s6
    80003612:	8556                	mv	a0,s5
    80003614:	00000097          	auipc	ra,0x0
    80003618:	d9c080e7          	jalr	-612(ra) # 800033b0 <iget>
    8000361c:	bf5d                	j	800035d2 <ialloc+0x86>

000000008000361e <iupdate>:
{
    8000361e:	1101                	addi	sp,sp,-32
    80003620:	ec06                	sd	ra,24(sp)
    80003622:	e822                	sd	s0,16(sp)
    80003624:	e426                	sd	s1,8(sp)
    80003626:	e04a                	sd	s2,0(sp)
    80003628:	1000                	addi	s0,sp,32
    8000362a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000362c:	415c                	lw	a5,4(a0)
    8000362e:	0047d79b          	srliw	a5,a5,0x4
    80003632:	0001c597          	auipc	a1,0x1c
    80003636:	c8e5a583          	lw	a1,-882(a1) # 8001f2c0 <sb+0x18>
    8000363a:	9dbd                	addw	a1,a1,a5
    8000363c:	4108                	lw	a0,0(a0)
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	894080e7          	jalr	-1900(ra) # 80002ed2 <bread>
    80003646:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003648:	05850793          	addi	a5,a0,88
    8000364c:	40d8                	lw	a4,4(s1)
    8000364e:	8b3d                	andi	a4,a4,15
    80003650:	071a                	slli	a4,a4,0x6
    80003652:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003654:	04449703          	lh	a4,68(s1)
    80003658:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000365c:	04649703          	lh	a4,70(s1)
    80003660:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003664:	04849703          	lh	a4,72(s1)
    80003668:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000366c:	04a49703          	lh	a4,74(s1)
    80003670:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003674:	44f8                	lw	a4,76(s1)
    80003676:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003678:	03400613          	li	a2,52
    8000367c:	05048593          	addi	a1,s1,80
    80003680:	00c78513          	addi	a0,a5,12
    80003684:	ffffd097          	auipc	ra,0xffffd
    80003688:	6aa080e7          	jalr	1706(ra) # 80000d2e <memmove>
  log_write(bp);
    8000368c:	854a                	mv	a0,s2
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	bfe080e7          	jalr	-1026(ra) # 8000428c <log_write>
  brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	96a080e7          	jalr	-1686(ra) # 80003002 <brelse>
}
    800036a0:	60e2                	ld	ra,24(sp)
    800036a2:	6442                	ld	s0,16(sp)
    800036a4:	64a2                	ld	s1,8(sp)
    800036a6:	6902                	ld	s2,0(sp)
    800036a8:	6105                	addi	sp,sp,32
    800036aa:	8082                	ret

00000000800036ac <idup>:
{
    800036ac:	1101                	addi	sp,sp,-32
    800036ae:	ec06                	sd	ra,24(sp)
    800036b0:	e822                	sd	s0,16(sp)
    800036b2:	e426                	sd	s1,8(sp)
    800036b4:	1000                	addi	s0,sp,32
    800036b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036b8:	0001c517          	auipc	a0,0x1c
    800036bc:	c1050513          	addi	a0,a0,-1008 # 8001f2c8 <itable>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	516080e7          	jalr	1302(ra) # 80000bd6 <acquire>
  ip->ref++;
    800036c8:	449c                	lw	a5,8(s1)
    800036ca:	2785                	addiw	a5,a5,1
    800036cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036ce:	0001c517          	auipc	a0,0x1c
    800036d2:	bfa50513          	addi	a0,a0,-1030 # 8001f2c8 <itable>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	5b4080e7          	jalr	1460(ra) # 80000c8a <release>
}
    800036de:	8526                	mv	a0,s1
    800036e0:	60e2                	ld	ra,24(sp)
    800036e2:	6442                	ld	s0,16(sp)
    800036e4:	64a2                	ld	s1,8(sp)
    800036e6:	6105                	addi	sp,sp,32
    800036e8:	8082                	ret

00000000800036ea <ilock>:
{
    800036ea:	1101                	addi	sp,sp,-32
    800036ec:	ec06                	sd	ra,24(sp)
    800036ee:	e822                	sd	s0,16(sp)
    800036f0:	e426                	sd	s1,8(sp)
    800036f2:	e04a                	sd	s2,0(sp)
    800036f4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036f6:	c115                	beqz	a0,8000371a <ilock+0x30>
    800036f8:	84aa                	mv	s1,a0
    800036fa:	451c                	lw	a5,8(a0)
    800036fc:	00f05f63          	blez	a5,8000371a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003700:	0541                	addi	a0,a0,16
    80003702:	00001097          	auipc	ra,0x1
    80003706:	ca8080e7          	jalr	-856(ra) # 800043aa <acquiresleep>
  if(ip->valid == 0){
    8000370a:	40bc                	lw	a5,64(s1)
    8000370c:	cf99                	beqz	a5,8000372a <ilock+0x40>
}
    8000370e:	60e2                	ld	ra,24(sp)
    80003710:	6442                	ld	s0,16(sp)
    80003712:	64a2                	ld	s1,8(sp)
    80003714:	6902                	ld	s2,0(sp)
    80003716:	6105                	addi	sp,sp,32
    80003718:	8082                	ret
    panic("ilock");
    8000371a:	00005517          	auipc	a0,0x5
    8000371e:	efe50513          	addi	a0,a0,-258 # 80008618 <syscalls+0x180>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	e1e080e7          	jalr	-482(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372a:	40dc                	lw	a5,4(s1)
    8000372c:	0047d79b          	srliw	a5,a5,0x4
    80003730:	0001c597          	auipc	a1,0x1c
    80003734:	b905a583          	lw	a1,-1136(a1) # 8001f2c0 <sb+0x18>
    80003738:	9dbd                	addw	a1,a1,a5
    8000373a:	4088                	lw	a0,0(s1)
    8000373c:	fffff097          	auipc	ra,0xfffff
    80003740:	796080e7          	jalr	1942(ra) # 80002ed2 <bread>
    80003744:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003746:	05850593          	addi	a1,a0,88
    8000374a:	40dc                	lw	a5,4(s1)
    8000374c:	8bbd                	andi	a5,a5,15
    8000374e:	079a                	slli	a5,a5,0x6
    80003750:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003752:	00059783          	lh	a5,0(a1)
    80003756:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000375a:	00259783          	lh	a5,2(a1)
    8000375e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003762:	00459783          	lh	a5,4(a1)
    80003766:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000376a:	00659783          	lh	a5,6(a1)
    8000376e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003772:	459c                	lw	a5,8(a1)
    80003774:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003776:	03400613          	li	a2,52
    8000377a:	05b1                	addi	a1,a1,12
    8000377c:	05048513          	addi	a0,s1,80
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	5ae080e7          	jalr	1454(ra) # 80000d2e <memmove>
    brelse(bp);
    80003788:	854a                	mv	a0,s2
    8000378a:	00000097          	auipc	ra,0x0
    8000378e:	878080e7          	jalr	-1928(ra) # 80003002 <brelse>
    ip->valid = 1;
    80003792:	4785                	li	a5,1
    80003794:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003796:	04449783          	lh	a5,68(s1)
    8000379a:	fbb5                	bnez	a5,8000370e <ilock+0x24>
      panic("ilock: no type");
    8000379c:	00005517          	auipc	a0,0x5
    800037a0:	e8450513          	addi	a0,a0,-380 # 80008620 <syscalls+0x188>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	d9c080e7          	jalr	-612(ra) # 80000540 <panic>

00000000800037ac <iunlock>:
{
    800037ac:	1101                	addi	sp,sp,-32
    800037ae:	ec06                	sd	ra,24(sp)
    800037b0:	e822                	sd	s0,16(sp)
    800037b2:	e426                	sd	s1,8(sp)
    800037b4:	e04a                	sd	s2,0(sp)
    800037b6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037b8:	c905                	beqz	a0,800037e8 <iunlock+0x3c>
    800037ba:	84aa                	mv	s1,a0
    800037bc:	01050913          	addi	s2,a0,16
    800037c0:	854a                	mv	a0,s2
    800037c2:	00001097          	auipc	ra,0x1
    800037c6:	c82080e7          	jalr	-894(ra) # 80004444 <holdingsleep>
    800037ca:	cd19                	beqz	a0,800037e8 <iunlock+0x3c>
    800037cc:	449c                	lw	a5,8(s1)
    800037ce:	00f05d63          	blez	a5,800037e8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037d2:	854a                	mv	a0,s2
    800037d4:	00001097          	auipc	ra,0x1
    800037d8:	c2c080e7          	jalr	-980(ra) # 80004400 <releasesleep>
}
    800037dc:	60e2                	ld	ra,24(sp)
    800037de:	6442                	ld	s0,16(sp)
    800037e0:	64a2                	ld	s1,8(sp)
    800037e2:	6902                	ld	s2,0(sp)
    800037e4:	6105                	addi	sp,sp,32
    800037e6:	8082                	ret
    panic("iunlock");
    800037e8:	00005517          	auipc	a0,0x5
    800037ec:	e4850513          	addi	a0,a0,-440 # 80008630 <syscalls+0x198>
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	d50080e7          	jalr	-688(ra) # 80000540 <panic>

00000000800037f8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037f8:	7179                	addi	sp,sp,-48
    800037fa:	f406                	sd	ra,40(sp)
    800037fc:	f022                	sd	s0,32(sp)
    800037fe:	ec26                	sd	s1,24(sp)
    80003800:	e84a                	sd	s2,16(sp)
    80003802:	e44e                	sd	s3,8(sp)
    80003804:	e052                	sd	s4,0(sp)
    80003806:	1800                	addi	s0,sp,48
    80003808:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000380a:	05050493          	addi	s1,a0,80
    8000380e:	08050913          	addi	s2,a0,128
    80003812:	a021                	j	8000381a <itrunc+0x22>
    80003814:	0491                	addi	s1,s1,4
    80003816:	01248d63          	beq	s1,s2,80003830 <itrunc+0x38>
    if(ip->addrs[i]){
    8000381a:	408c                	lw	a1,0(s1)
    8000381c:	dde5                	beqz	a1,80003814 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000381e:	0009a503          	lw	a0,0(s3)
    80003822:	00000097          	auipc	ra,0x0
    80003826:	8f6080e7          	jalr	-1802(ra) # 80003118 <bfree>
      ip->addrs[i] = 0;
    8000382a:	0004a023          	sw	zero,0(s1)
    8000382e:	b7dd                	j	80003814 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003830:	0809a583          	lw	a1,128(s3)
    80003834:	e185                	bnez	a1,80003854 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003836:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000383a:	854e                	mv	a0,s3
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	de2080e7          	jalr	-542(ra) # 8000361e <iupdate>
}
    80003844:	70a2                	ld	ra,40(sp)
    80003846:	7402                	ld	s0,32(sp)
    80003848:	64e2                	ld	s1,24(sp)
    8000384a:	6942                	ld	s2,16(sp)
    8000384c:	69a2                	ld	s3,8(sp)
    8000384e:	6a02                	ld	s4,0(sp)
    80003850:	6145                	addi	sp,sp,48
    80003852:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003854:	0009a503          	lw	a0,0(s3)
    80003858:	fffff097          	auipc	ra,0xfffff
    8000385c:	67a080e7          	jalr	1658(ra) # 80002ed2 <bread>
    80003860:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003862:	05850493          	addi	s1,a0,88
    80003866:	45850913          	addi	s2,a0,1112
    8000386a:	a021                	j	80003872 <itrunc+0x7a>
    8000386c:	0491                	addi	s1,s1,4
    8000386e:	01248b63          	beq	s1,s2,80003884 <itrunc+0x8c>
      if(a[j])
    80003872:	408c                	lw	a1,0(s1)
    80003874:	dde5                	beqz	a1,8000386c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003876:	0009a503          	lw	a0,0(s3)
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	89e080e7          	jalr	-1890(ra) # 80003118 <bfree>
    80003882:	b7ed                	j	8000386c <itrunc+0x74>
    brelse(bp);
    80003884:	8552                	mv	a0,s4
    80003886:	fffff097          	auipc	ra,0xfffff
    8000388a:	77c080e7          	jalr	1916(ra) # 80003002 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000388e:	0809a583          	lw	a1,128(s3)
    80003892:	0009a503          	lw	a0,0(s3)
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	882080e7          	jalr	-1918(ra) # 80003118 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000389e:	0809a023          	sw	zero,128(s3)
    800038a2:	bf51                	j	80003836 <itrunc+0x3e>

00000000800038a4 <iput>:
{
    800038a4:	1101                	addi	sp,sp,-32
    800038a6:	ec06                	sd	ra,24(sp)
    800038a8:	e822                	sd	s0,16(sp)
    800038aa:	e426                	sd	s1,8(sp)
    800038ac:	e04a                	sd	s2,0(sp)
    800038ae:	1000                	addi	s0,sp,32
    800038b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038b2:	0001c517          	auipc	a0,0x1c
    800038b6:	a1650513          	addi	a0,a0,-1514 # 8001f2c8 <itable>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	31c080e7          	jalr	796(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038c2:	4498                	lw	a4,8(s1)
    800038c4:	4785                	li	a5,1
    800038c6:	02f70363          	beq	a4,a5,800038ec <iput+0x48>
  ip->ref--;
    800038ca:	449c                	lw	a5,8(s1)
    800038cc:	37fd                	addiw	a5,a5,-1
    800038ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038d0:	0001c517          	auipc	a0,0x1c
    800038d4:	9f850513          	addi	a0,a0,-1544 # 8001f2c8 <itable>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	3b2080e7          	jalr	946(ra) # 80000c8a <release>
}
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6902                	ld	s2,0(sp)
    800038e8:	6105                	addi	sp,sp,32
    800038ea:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038ec:	40bc                	lw	a5,64(s1)
    800038ee:	dff1                	beqz	a5,800038ca <iput+0x26>
    800038f0:	04a49783          	lh	a5,74(s1)
    800038f4:	fbf9                	bnez	a5,800038ca <iput+0x26>
    acquiresleep(&ip->lock);
    800038f6:	01048913          	addi	s2,s1,16
    800038fa:	854a                	mv	a0,s2
    800038fc:	00001097          	auipc	ra,0x1
    80003900:	aae080e7          	jalr	-1362(ra) # 800043aa <acquiresleep>
    release(&itable.lock);
    80003904:	0001c517          	auipc	a0,0x1c
    80003908:	9c450513          	addi	a0,a0,-1596 # 8001f2c8 <itable>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	37e080e7          	jalr	894(ra) # 80000c8a <release>
    itrunc(ip);
    80003914:	8526                	mv	a0,s1
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	ee2080e7          	jalr	-286(ra) # 800037f8 <itrunc>
    ip->type = 0;
    8000391e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003922:	8526                	mv	a0,s1
    80003924:	00000097          	auipc	ra,0x0
    80003928:	cfa080e7          	jalr	-774(ra) # 8000361e <iupdate>
    ip->valid = 0;
    8000392c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003930:	854a                	mv	a0,s2
    80003932:	00001097          	auipc	ra,0x1
    80003936:	ace080e7          	jalr	-1330(ra) # 80004400 <releasesleep>
    acquire(&itable.lock);
    8000393a:	0001c517          	auipc	a0,0x1c
    8000393e:	98e50513          	addi	a0,a0,-1650 # 8001f2c8 <itable>
    80003942:	ffffd097          	auipc	ra,0xffffd
    80003946:	294080e7          	jalr	660(ra) # 80000bd6 <acquire>
    8000394a:	b741                	j	800038ca <iput+0x26>

000000008000394c <iunlockput>:
{
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	1000                	addi	s0,sp,32
    80003956:	84aa                	mv	s1,a0
  iunlock(ip);
    80003958:	00000097          	auipc	ra,0x0
    8000395c:	e54080e7          	jalr	-428(ra) # 800037ac <iunlock>
  iput(ip);
    80003960:	8526                	mv	a0,s1
    80003962:	00000097          	auipc	ra,0x0
    80003966:	f42080e7          	jalr	-190(ra) # 800038a4 <iput>
}
    8000396a:	60e2                	ld	ra,24(sp)
    8000396c:	6442                	ld	s0,16(sp)
    8000396e:	64a2                	ld	s1,8(sp)
    80003970:	6105                	addi	sp,sp,32
    80003972:	8082                	ret

0000000080003974 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003974:	1141                	addi	sp,sp,-16
    80003976:	e422                	sd	s0,8(sp)
    80003978:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000397a:	411c                	lw	a5,0(a0)
    8000397c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000397e:	415c                	lw	a5,4(a0)
    80003980:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003982:	04451783          	lh	a5,68(a0)
    80003986:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000398a:	04a51783          	lh	a5,74(a0)
    8000398e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003992:	04c56783          	lwu	a5,76(a0)
    80003996:	e99c                	sd	a5,16(a1)
}
    80003998:	6422                	ld	s0,8(sp)
    8000399a:	0141                	addi	sp,sp,16
    8000399c:	8082                	ret

000000008000399e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000399e:	457c                	lw	a5,76(a0)
    800039a0:	0ed7e963          	bltu	a5,a3,80003a92 <readi+0xf4>
{
    800039a4:	7159                	addi	sp,sp,-112
    800039a6:	f486                	sd	ra,104(sp)
    800039a8:	f0a2                	sd	s0,96(sp)
    800039aa:	eca6                	sd	s1,88(sp)
    800039ac:	e8ca                	sd	s2,80(sp)
    800039ae:	e4ce                	sd	s3,72(sp)
    800039b0:	e0d2                	sd	s4,64(sp)
    800039b2:	fc56                	sd	s5,56(sp)
    800039b4:	f85a                	sd	s6,48(sp)
    800039b6:	f45e                	sd	s7,40(sp)
    800039b8:	f062                	sd	s8,32(sp)
    800039ba:	ec66                	sd	s9,24(sp)
    800039bc:	e86a                	sd	s10,16(sp)
    800039be:	e46e                	sd	s11,8(sp)
    800039c0:	1880                	addi	s0,sp,112
    800039c2:	8b2a                	mv	s6,a0
    800039c4:	8bae                	mv	s7,a1
    800039c6:	8a32                	mv	s4,a2
    800039c8:	84b6                	mv	s1,a3
    800039ca:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039cc:	9f35                	addw	a4,a4,a3
    return 0;
    800039ce:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039d0:	0ad76063          	bltu	a4,a3,80003a70 <readi+0xd2>
  if(off + n > ip->size)
    800039d4:	00e7f463          	bgeu	a5,a4,800039dc <readi+0x3e>
    n = ip->size - off;
    800039d8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039dc:	0a0a8963          	beqz	s5,80003a8e <readi+0xf0>
    800039e0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039e6:	5c7d                	li	s8,-1
    800039e8:	a82d                	j	80003a22 <readi+0x84>
    800039ea:	020d1d93          	slli	s11,s10,0x20
    800039ee:	020ddd93          	srli	s11,s11,0x20
    800039f2:	05890613          	addi	a2,s2,88
    800039f6:	86ee                	mv	a3,s11
    800039f8:	963a                	add	a2,a2,a4
    800039fa:	85d2                	mv	a1,s4
    800039fc:	855e                	mv	a0,s7
    800039fe:	fffff097          	auipc	ra,0xfffff
    80003a02:	b2e080e7          	jalr	-1234(ra) # 8000252c <either_copyout>
    80003a06:	05850d63          	beq	a0,s8,80003a60 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	fffff097          	auipc	ra,0xfffff
    80003a10:	5f6080e7          	jalr	1526(ra) # 80003002 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a14:	013d09bb          	addw	s3,s10,s3
    80003a18:	009d04bb          	addw	s1,s10,s1
    80003a1c:	9a6e                	add	s4,s4,s11
    80003a1e:	0559f763          	bgeu	s3,s5,80003a6c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a22:	00a4d59b          	srliw	a1,s1,0xa
    80003a26:	855a                	mv	a0,s6
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	89e080e7          	jalr	-1890(ra) # 800032c6 <bmap>
    80003a30:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a34:	cd85                	beqz	a1,80003a6c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a36:	000b2503          	lw	a0,0(s6)
    80003a3a:	fffff097          	auipc	ra,0xfffff
    80003a3e:	498080e7          	jalr	1176(ra) # 80002ed2 <bread>
    80003a42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a44:	3ff4f713          	andi	a4,s1,1023
    80003a48:	40ec87bb          	subw	a5,s9,a4
    80003a4c:	413a86bb          	subw	a3,s5,s3
    80003a50:	8d3e                	mv	s10,a5
    80003a52:	2781                	sext.w	a5,a5
    80003a54:	0006861b          	sext.w	a2,a3
    80003a58:	f8f679e3          	bgeu	a2,a5,800039ea <readi+0x4c>
    80003a5c:	8d36                	mv	s10,a3
    80003a5e:	b771                	j	800039ea <readi+0x4c>
      brelse(bp);
    80003a60:	854a                	mv	a0,s2
    80003a62:	fffff097          	auipc	ra,0xfffff
    80003a66:	5a0080e7          	jalr	1440(ra) # 80003002 <brelse>
      tot = -1;
    80003a6a:	59fd                	li	s3,-1
  }
  return tot;
    80003a6c:	0009851b          	sext.w	a0,s3
}
    80003a70:	70a6                	ld	ra,104(sp)
    80003a72:	7406                	ld	s0,96(sp)
    80003a74:	64e6                	ld	s1,88(sp)
    80003a76:	6946                	ld	s2,80(sp)
    80003a78:	69a6                	ld	s3,72(sp)
    80003a7a:	6a06                	ld	s4,64(sp)
    80003a7c:	7ae2                	ld	s5,56(sp)
    80003a7e:	7b42                	ld	s6,48(sp)
    80003a80:	7ba2                	ld	s7,40(sp)
    80003a82:	7c02                	ld	s8,32(sp)
    80003a84:	6ce2                	ld	s9,24(sp)
    80003a86:	6d42                	ld	s10,16(sp)
    80003a88:	6da2                	ld	s11,8(sp)
    80003a8a:	6165                	addi	sp,sp,112
    80003a8c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a8e:	89d6                	mv	s3,s5
    80003a90:	bff1                	j	80003a6c <readi+0xce>
    return 0;
    80003a92:	4501                	li	a0,0
}
    80003a94:	8082                	ret

0000000080003a96 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a96:	457c                	lw	a5,76(a0)
    80003a98:	10d7e863          	bltu	a5,a3,80003ba8 <writei+0x112>
{
    80003a9c:	7159                	addi	sp,sp,-112
    80003a9e:	f486                	sd	ra,104(sp)
    80003aa0:	f0a2                	sd	s0,96(sp)
    80003aa2:	eca6                	sd	s1,88(sp)
    80003aa4:	e8ca                	sd	s2,80(sp)
    80003aa6:	e4ce                	sd	s3,72(sp)
    80003aa8:	e0d2                	sd	s4,64(sp)
    80003aaa:	fc56                	sd	s5,56(sp)
    80003aac:	f85a                	sd	s6,48(sp)
    80003aae:	f45e                	sd	s7,40(sp)
    80003ab0:	f062                	sd	s8,32(sp)
    80003ab2:	ec66                	sd	s9,24(sp)
    80003ab4:	e86a                	sd	s10,16(sp)
    80003ab6:	e46e                	sd	s11,8(sp)
    80003ab8:	1880                	addi	s0,sp,112
    80003aba:	8aaa                	mv	s5,a0
    80003abc:	8bae                	mv	s7,a1
    80003abe:	8a32                	mv	s4,a2
    80003ac0:	8936                	mv	s2,a3
    80003ac2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ac4:	00e687bb          	addw	a5,a3,a4
    80003ac8:	0ed7e263          	bltu	a5,a3,80003bac <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003acc:	00043737          	lui	a4,0x43
    80003ad0:	0ef76063          	bltu	a4,a5,80003bb0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ad4:	0c0b0863          	beqz	s6,80003ba4 <writei+0x10e>
    80003ad8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ada:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ade:	5c7d                	li	s8,-1
    80003ae0:	a091                	j	80003b24 <writei+0x8e>
    80003ae2:	020d1d93          	slli	s11,s10,0x20
    80003ae6:	020ddd93          	srli	s11,s11,0x20
    80003aea:	05848513          	addi	a0,s1,88
    80003aee:	86ee                	mv	a3,s11
    80003af0:	8652                	mv	a2,s4
    80003af2:	85de                	mv	a1,s7
    80003af4:	953a                	add	a0,a0,a4
    80003af6:	fffff097          	auipc	ra,0xfffff
    80003afa:	a8c080e7          	jalr	-1396(ra) # 80002582 <either_copyin>
    80003afe:	07850263          	beq	a0,s8,80003b62 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b02:	8526                	mv	a0,s1
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	788080e7          	jalr	1928(ra) # 8000428c <log_write>
    brelse(bp);
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	fffff097          	auipc	ra,0xfffff
    80003b12:	4f4080e7          	jalr	1268(ra) # 80003002 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b16:	013d09bb          	addw	s3,s10,s3
    80003b1a:	012d093b          	addw	s2,s10,s2
    80003b1e:	9a6e                	add	s4,s4,s11
    80003b20:	0569f663          	bgeu	s3,s6,80003b6c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b24:	00a9559b          	srliw	a1,s2,0xa
    80003b28:	8556                	mv	a0,s5
    80003b2a:	fffff097          	auipc	ra,0xfffff
    80003b2e:	79c080e7          	jalr	1948(ra) # 800032c6 <bmap>
    80003b32:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b36:	c99d                	beqz	a1,80003b6c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b38:	000aa503          	lw	a0,0(s5)
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	396080e7          	jalr	918(ra) # 80002ed2 <bread>
    80003b44:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b46:	3ff97713          	andi	a4,s2,1023
    80003b4a:	40ec87bb          	subw	a5,s9,a4
    80003b4e:	413b06bb          	subw	a3,s6,s3
    80003b52:	8d3e                	mv	s10,a5
    80003b54:	2781                	sext.w	a5,a5
    80003b56:	0006861b          	sext.w	a2,a3
    80003b5a:	f8f674e3          	bgeu	a2,a5,80003ae2 <writei+0x4c>
    80003b5e:	8d36                	mv	s10,a3
    80003b60:	b749                	j	80003ae2 <writei+0x4c>
      brelse(bp);
    80003b62:	8526                	mv	a0,s1
    80003b64:	fffff097          	auipc	ra,0xfffff
    80003b68:	49e080e7          	jalr	1182(ra) # 80003002 <brelse>
  }

  if(off > ip->size)
    80003b6c:	04caa783          	lw	a5,76(s5)
    80003b70:	0127f463          	bgeu	a5,s2,80003b78 <writei+0xe2>
    ip->size = off;
    80003b74:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b78:	8556                	mv	a0,s5
    80003b7a:	00000097          	auipc	ra,0x0
    80003b7e:	aa4080e7          	jalr	-1372(ra) # 8000361e <iupdate>

  return tot;
    80003b82:	0009851b          	sext.w	a0,s3
}
    80003b86:	70a6                	ld	ra,104(sp)
    80003b88:	7406                	ld	s0,96(sp)
    80003b8a:	64e6                	ld	s1,88(sp)
    80003b8c:	6946                	ld	s2,80(sp)
    80003b8e:	69a6                	ld	s3,72(sp)
    80003b90:	6a06                	ld	s4,64(sp)
    80003b92:	7ae2                	ld	s5,56(sp)
    80003b94:	7b42                	ld	s6,48(sp)
    80003b96:	7ba2                	ld	s7,40(sp)
    80003b98:	7c02                	ld	s8,32(sp)
    80003b9a:	6ce2                	ld	s9,24(sp)
    80003b9c:	6d42                	ld	s10,16(sp)
    80003b9e:	6da2                	ld	s11,8(sp)
    80003ba0:	6165                	addi	sp,sp,112
    80003ba2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ba4:	89da                	mv	s3,s6
    80003ba6:	bfc9                	j	80003b78 <writei+0xe2>
    return -1;
    80003ba8:	557d                	li	a0,-1
}
    80003baa:	8082                	ret
    return -1;
    80003bac:	557d                	li	a0,-1
    80003bae:	bfe1                	j	80003b86 <writei+0xf0>
    return -1;
    80003bb0:	557d                	li	a0,-1
    80003bb2:	bfd1                	j	80003b86 <writei+0xf0>

0000000080003bb4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bb4:	1141                	addi	sp,sp,-16
    80003bb6:	e406                	sd	ra,8(sp)
    80003bb8:	e022                	sd	s0,0(sp)
    80003bba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bbc:	4639                	li	a2,14
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	1e4080e7          	jalr	484(ra) # 80000da2 <strncmp>
}
    80003bc6:	60a2                	ld	ra,8(sp)
    80003bc8:	6402                	ld	s0,0(sp)
    80003bca:	0141                	addi	sp,sp,16
    80003bcc:	8082                	ret

0000000080003bce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bce:	7139                	addi	sp,sp,-64
    80003bd0:	fc06                	sd	ra,56(sp)
    80003bd2:	f822                	sd	s0,48(sp)
    80003bd4:	f426                	sd	s1,40(sp)
    80003bd6:	f04a                	sd	s2,32(sp)
    80003bd8:	ec4e                	sd	s3,24(sp)
    80003bda:	e852                	sd	s4,16(sp)
    80003bdc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bde:	04451703          	lh	a4,68(a0)
    80003be2:	4785                	li	a5,1
    80003be4:	00f71a63          	bne	a4,a5,80003bf8 <dirlookup+0x2a>
    80003be8:	892a                	mv	s2,a0
    80003bea:	89ae                	mv	s3,a1
    80003bec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bee:	457c                	lw	a5,76(a0)
    80003bf0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bf2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf4:	e79d                	bnez	a5,80003c22 <dirlookup+0x54>
    80003bf6:	a8a5                	j	80003c6e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bf8:	00005517          	auipc	a0,0x5
    80003bfc:	a4050513          	addi	a0,a0,-1472 # 80008638 <syscalls+0x1a0>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	940080e7          	jalr	-1728(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003c08:	00005517          	auipc	a0,0x5
    80003c0c:	a4850513          	addi	a0,a0,-1464 # 80008650 <syscalls+0x1b8>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	930080e7          	jalr	-1744(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c18:	24c1                	addiw	s1,s1,16
    80003c1a:	04c92783          	lw	a5,76(s2)
    80003c1e:	04f4f763          	bgeu	s1,a5,80003c6c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c22:	4741                	li	a4,16
    80003c24:	86a6                	mv	a3,s1
    80003c26:	fc040613          	addi	a2,s0,-64
    80003c2a:	4581                	li	a1,0
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	d70080e7          	jalr	-656(ra) # 8000399e <readi>
    80003c36:	47c1                	li	a5,16
    80003c38:	fcf518e3          	bne	a0,a5,80003c08 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c3c:	fc045783          	lhu	a5,-64(s0)
    80003c40:	dfe1                	beqz	a5,80003c18 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c42:	fc240593          	addi	a1,s0,-62
    80003c46:	854e                	mv	a0,s3
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	f6c080e7          	jalr	-148(ra) # 80003bb4 <namecmp>
    80003c50:	f561                	bnez	a0,80003c18 <dirlookup+0x4a>
      if(poff)
    80003c52:	000a0463          	beqz	s4,80003c5a <dirlookup+0x8c>
        *poff = off;
    80003c56:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c5a:	fc045583          	lhu	a1,-64(s0)
    80003c5e:	00092503          	lw	a0,0(s2)
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	74e080e7          	jalr	1870(ra) # 800033b0 <iget>
    80003c6a:	a011                	j	80003c6e <dirlookup+0xa0>
  return 0;
    80003c6c:	4501                	li	a0,0
}
    80003c6e:	70e2                	ld	ra,56(sp)
    80003c70:	7442                	ld	s0,48(sp)
    80003c72:	74a2                	ld	s1,40(sp)
    80003c74:	7902                	ld	s2,32(sp)
    80003c76:	69e2                	ld	s3,24(sp)
    80003c78:	6a42                	ld	s4,16(sp)
    80003c7a:	6121                	addi	sp,sp,64
    80003c7c:	8082                	ret

0000000080003c7e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c7e:	711d                	addi	sp,sp,-96
    80003c80:	ec86                	sd	ra,88(sp)
    80003c82:	e8a2                	sd	s0,80(sp)
    80003c84:	e4a6                	sd	s1,72(sp)
    80003c86:	e0ca                	sd	s2,64(sp)
    80003c88:	fc4e                	sd	s3,56(sp)
    80003c8a:	f852                	sd	s4,48(sp)
    80003c8c:	f456                	sd	s5,40(sp)
    80003c8e:	f05a                	sd	s6,32(sp)
    80003c90:	ec5e                	sd	s7,24(sp)
    80003c92:	e862                	sd	s8,16(sp)
    80003c94:	e466                	sd	s9,8(sp)
    80003c96:	e06a                	sd	s10,0(sp)
    80003c98:	1080                	addi	s0,sp,96
    80003c9a:	84aa                	mv	s1,a0
    80003c9c:	8b2e                	mv	s6,a1
    80003c9e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ca0:	00054703          	lbu	a4,0(a0)
    80003ca4:	02f00793          	li	a5,47
    80003ca8:	02f70363          	beq	a4,a5,80003cce <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cac:	ffffe097          	auipc	ra,0xffffe
    80003cb0:	d24080e7          	jalr	-732(ra) # 800019d0 <myproc>
    80003cb4:	15053503          	ld	a0,336(a0)
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	9f4080e7          	jalr	-1548(ra) # 800036ac <idup>
    80003cc0:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cc2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cc6:	4cb5                	li	s9,13
  len = path - s;
    80003cc8:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cca:	4c05                	li	s8,1
    80003ccc:	a87d                	j	80003d8a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003cce:	4585                	li	a1,1
    80003cd0:	4505                	li	a0,1
    80003cd2:	fffff097          	auipc	ra,0xfffff
    80003cd6:	6de080e7          	jalr	1758(ra) # 800033b0 <iget>
    80003cda:	8a2a                	mv	s4,a0
    80003cdc:	b7dd                	j	80003cc2 <namex+0x44>
      iunlockput(ip);
    80003cde:	8552                	mv	a0,s4
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	c6c080e7          	jalr	-916(ra) # 8000394c <iunlockput>
      return 0;
    80003ce8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cea:	8552                	mv	a0,s4
    80003cec:	60e6                	ld	ra,88(sp)
    80003cee:	6446                	ld	s0,80(sp)
    80003cf0:	64a6                	ld	s1,72(sp)
    80003cf2:	6906                	ld	s2,64(sp)
    80003cf4:	79e2                	ld	s3,56(sp)
    80003cf6:	7a42                	ld	s4,48(sp)
    80003cf8:	7aa2                	ld	s5,40(sp)
    80003cfa:	7b02                	ld	s6,32(sp)
    80003cfc:	6be2                	ld	s7,24(sp)
    80003cfe:	6c42                	ld	s8,16(sp)
    80003d00:	6ca2                	ld	s9,8(sp)
    80003d02:	6d02                	ld	s10,0(sp)
    80003d04:	6125                	addi	sp,sp,96
    80003d06:	8082                	ret
      iunlock(ip);
    80003d08:	8552                	mv	a0,s4
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	aa2080e7          	jalr	-1374(ra) # 800037ac <iunlock>
      return ip;
    80003d12:	bfe1                	j	80003cea <namex+0x6c>
      iunlockput(ip);
    80003d14:	8552                	mv	a0,s4
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	c36080e7          	jalr	-970(ra) # 8000394c <iunlockput>
      return 0;
    80003d1e:	8a4e                	mv	s4,s3
    80003d20:	b7e9                	j	80003cea <namex+0x6c>
  len = path - s;
    80003d22:	40998633          	sub	a2,s3,s1
    80003d26:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d2a:	09acd863          	bge	s9,s10,80003dba <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003d2e:	4639                	li	a2,14
    80003d30:	85a6                	mv	a1,s1
    80003d32:	8556                	mv	a0,s5
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	ffa080e7          	jalr	-6(ra) # 80000d2e <memmove>
    80003d3c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d3e:	0004c783          	lbu	a5,0(s1)
    80003d42:	01279763          	bne	a5,s2,80003d50 <namex+0xd2>
    path++;
    80003d46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d48:	0004c783          	lbu	a5,0(s1)
    80003d4c:	ff278de3          	beq	a5,s2,80003d46 <namex+0xc8>
    ilock(ip);
    80003d50:	8552                	mv	a0,s4
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	998080e7          	jalr	-1640(ra) # 800036ea <ilock>
    if(ip->type != T_DIR){
    80003d5a:	044a1783          	lh	a5,68(s4)
    80003d5e:	f98790e3          	bne	a5,s8,80003cde <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d62:	000b0563          	beqz	s6,80003d6c <namex+0xee>
    80003d66:	0004c783          	lbu	a5,0(s1)
    80003d6a:	dfd9                	beqz	a5,80003d08 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d6c:	865e                	mv	a2,s7
    80003d6e:	85d6                	mv	a1,s5
    80003d70:	8552                	mv	a0,s4
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	e5c080e7          	jalr	-420(ra) # 80003bce <dirlookup>
    80003d7a:	89aa                	mv	s3,a0
    80003d7c:	dd41                	beqz	a0,80003d14 <namex+0x96>
    iunlockput(ip);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	bcc080e7          	jalr	-1076(ra) # 8000394c <iunlockput>
    ip = next;
    80003d88:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d8a:	0004c783          	lbu	a5,0(s1)
    80003d8e:	01279763          	bne	a5,s2,80003d9c <namex+0x11e>
    path++;
    80003d92:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d94:	0004c783          	lbu	a5,0(s1)
    80003d98:	ff278de3          	beq	a5,s2,80003d92 <namex+0x114>
  if(*path == 0)
    80003d9c:	cb9d                	beqz	a5,80003dd2 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d9e:	0004c783          	lbu	a5,0(s1)
    80003da2:	89a6                	mv	s3,s1
  len = path - s;
    80003da4:	8d5e                	mv	s10,s7
    80003da6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003da8:	01278963          	beq	a5,s2,80003dba <namex+0x13c>
    80003dac:	dbbd                	beqz	a5,80003d22 <namex+0xa4>
    path++;
    80003dae:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003db0:	0009c783          	lbu	a5,0(s3)
    80003db4:	ff279ce3          	bne	a5,s2,80003dac <namex+0x12e>
    80003db8:	b7ad                	j	80003d22 <namex+0xa4>
    memmove(name, s, len);
    80003dba:	2601                	sext.w	a2,a2
    80003dbc:	85a6                	mv	a1,s1
    80003dbe:	8556                	mv	a0,s5
    80003dc0:	ffffd097          	auipc	ra,0xffffd
    80003dc4:	f6e080e7          	jalr	-146(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003dc8:	9d56                	add	s10,s10,s5
    80003dca:	000d0023          	sb	zero,0(s10)
    80003dce:	84ce                	mv	s1,s3
    80003dd0:	b7bd                	j	80003d3e <namex+0xc0>
  if(nameiparent){
    80003dd2:	f00b0ce3          	beqz	s6,80003cea <namex+0x6c>
    iput(ip);
    80003dd6:	8552                	mv	a0,s4
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	acc080e7          	jalr	-1332(ra) # 800038a4 <iput>
    return 0;
    80003de0:	4a01                	li	s4,0
    80003de2:	b721                	j	80003cea <namex+0x6c>

0000000080003de4 <dirlink>:
{
    80003de4:	7139                	addi	sp,sp,-64
    80003de6:	fc06                	sd	ra,56(sp)
    80003de8:	f822                	sd	s0,48(sp)
    80003dea:	f426                	sd	s1,40(sp)
    80003dec:	f04a                	sd	s2,32(sp)
    80003dee:	ec4e                	sd	s3,24(sp)
    80003df0:	e852                	sd	s4,16(sp)
    80003df2:	0080                	addi	s0,sp,64
    80003df4:	892a                	mv	s2,a0
    80003df6:	8a2e                	mv	s4,a1
    80003df8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dfa:	4601                	li	a2,0
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	dd2080e7          	jalr	-558(ra) # 80003bce <dirlookup>
    80003e04:	e93d                	bnez	a0,80003e7a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e06:	04c92483          	lw	s1,76(s2)
    80003e0a:	c49d                	beqz	s1,80003e38 <dirlink+0x54>
    80003e0c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e0e:	4741                	li	a4,16
    80003e10:	86a6                	mv	a3,s1
    80003e12:	fc040613          	addi	a2,s0,-64
    80003e16:	4581                	li	a1,0
    80003e18:	854a                	mv	a0,s2
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	b84080e7          	jalr	-1148(ra) # 8000399e <readi>
    80003e22:	47c1                	li	a5,16
    80003e24:	06f51163          	bne	a0,a5,80003e86 <dirlink+0xa2>
    if(de.inum == 0)
    80003e28:	fc045783          	lhu	a5,-64(s0)
    80003e2c:	c791                	beqz	a5,80003e38 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2e:	24c1                	addiw	s1,s1,16
    80003e30:	04c92783          	lw	a5,76(s2)
    80003e34:	fcf4ede3          	bltu	s1,a5,80003e0e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e38:	4639                	li	a2,14
    80003e3a:	85d2                	mv	a1,s4
    80003e3c:	fc240513          	addi	a0,s0,-62
    80003e40:	ffffd097          	auipc	ra,0xffffd
    80003e44:	f9e080e7          	jalr	-98(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003e48:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e4c:	4741                	li	a4,16
    80003e4e:	86a6                	mv	a3,s1
    80003e50:	fc040613          	addi	a2,s0,-64
    80003e54:	4581                	li	a1,0
    80003e56:	854a                	mv	a0,s2
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	c3e080e7          	jalr	-962(ra) # 80003a96 <writei>
    80003e60:	1541                	addi	a0,a0,-16
    80003e62:	00a03533          	snez	a0,a0
    80003e66:	40a00533          	neg	a0,a0
}
    80003e6a:	70e2                	ld	ra,56(sp)
    80003e6c:	7442                	ld	s0,48(sp)
    80003e6e:	74a2                	ld	s1,40(sp)
    80003e70:	7902                	ld	s2,32(sp)
    80003e72:	69e2                	ld	s3,24(sp)
    80003e74:	6a42                	ld	s4,16(sp)
    80003e76:	6121                	addi	sp,sp,64
    80003e78:	8082                	ret
    iput(ip);
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	a2a080e7          	jalr	-1494(ra) # 800038a4 <iput>
    return -1;
    80003e82:	557d                	li	a0,-1
    80003e84:	b7dd                	j	80003e6a <dirlink+0x86>
      panic("dirlink read");
    80003e86:	00004517          	auipc	a0,0x4
    80003e8a:	7da50513          	addi	a0,a0,2010 # 80008660 <syscalls+0x1c8>
    80003e8e:	ffffc097          	auipc	ra,0xffffc
    80003e92:	6b2080e7          	jalr	1714(ra) # 80000540 <panic>

0000000080003e96 <namei>:

struct inode*
namei(char *path)
{
    80003e96:	1101                	addi	sp,sp,-32
    80003e98:	ec06                	sd	ra,24(sp)
    80003e9a:	e822                	sd	s0,16(sp)
    80003e9c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e9e:	fe040613          	addi	a2,s0,-32
    80003ea2:	4581                	li	a1,0
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	dda080e7          	jalr	-550(ra) # 80003c7e <namex>
}
    80003eac:	60e2                	ld	ra,24(sp)
    80003eae:	6442                	ld	s0,16(sp)
    80003eb0:	6105                	addi	sp,sp,32
    80003eb2:	8082                	ret

0000000080003eb4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb4:	1141                	addi	sp,sp,-16
    80003eb6:	e406                	sd	ra,8(sp)
    80003eb8:	e022                	sd	s0,0(sp)
    80003eba:	0800                	addi	s0,sp,16
    80003ebc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ebe:	4585                	li	a1,1
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	dbe080e7          	jalr	-578(ra) # 80003c7e <namex>
}
    80003ec8:	60a2                	ld	ra,8(sp)
    80003eca:	6402                	ld	s0,0(sp)
    80003ecc:	0141                	addi	sp,sp,16
    80003ece:	8082                	ret

0000000080003ed0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ed0:	1101                	addi	sp,sp,-32
    80003ed2:	ec06                	sd	ra,24(sp)
    80003ed4:	e822                	sd	s0,16(sp)
    80003ed6:	e426                	sd	s1,8(sp)
    80003ed8:	e04a                	sd	s2,0(sp)
    80003eda:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003edc:	0001d917          	auipc	s2,0x1d
    80003ee0:	e9490913          	addi	s2,s2,-364 # 80020d70 <log>
    80003ee4:	01892583          	lw	a1,24(s2)
    80003ee8:	02892503          	lw	a0,40(s2)
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	fe6080e7          	jalr	-26(ra) # 80002ed2 <bread>
    80003ef4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ef6:	02c92683          	lw	a3,44(s2)
    80003efa:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003efc:	02d05863          	blez	a3,80003f2c <write_head+0x5c>
    80003f00:	0001d797          	auipc	a5,0x1d
    80003f04:	ea078793          	addi	a5,a5,-352 # 80020da0 <log+0x30>
    80003f08:	05c50713          	addi	a4,a0,92
    80003f0c:	36fd                	addiw	a3,a3,-1
    80003f0e:	02069613          	slli	a2,a3,0x20
    80003f12:	01e65693          	srli	a3,a2,0x1e
    80003f16:	0001d617          	auipc	a2,0x1d
    80003f1a:	e8e60613          	addi	a2,a2,-370 # 80020da4 <log+0x34>
    80003f1e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f20:	4390                	lw	a2,0(a5)
    80003f22:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f24:	0791                	addi	a5,a5,4
    80003f26:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003f28:	fed79ce3          	bne	a5,a3,80003f20 <write_head+0x50>
  }
  bwrite(buf);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	096080e7          	jalr	150(ra) # 80002fc4 <bwrite>
  brelse(buf);
    80003f36:	8526                	mv	a0,s1
    80003f38:	fffff097          	auipc	ra,0xfffff
    80003f3c:	0ca080e7          	jalr	202(ra) # 80003002 <brelse>
}
    80003f40:	60e2                	ld	ra,24(sp)
    80003f42:	6442                	ld	s0,16(sp)
    80003f44:	64a2                	ld	s1,8(sp)
    80003f46:	6902                	ld	s2,0(sp)
    80003f48:	6105                	addi	sp,sp,32
    80003f4a:	8082                	ret

0000000080003f4c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f4c:	0001d797          	auipc	a5,0x1d
    80003f50:	e507a783          	lw	a5,-432(a5) # 80020d9c <log+0x2c>
    80003f54:	0af05d63          	blez	a5,8000400e <install_trans+0xc2>
{
    80003f58:	7139                	addi	sp,sp,-64
    80003f5a:	fc06                	sd	ra,56(sp)
    80003f5c:	f822                	sd	s0,48(sp)
    80003f5e:	f426                	sd	s1,40(sp)
    80003f60:	f04a                	sd	s2,32(sp)
    80003f62:	ec4e                	sd	s3,24(sp)
    80003f64:	e852                	sd	s4,16(sp)
    80003f66:	e456                	sd	s5,8(sp)
    80003f68:	e05a                	sd	s6,0(sp)
    80003f6a:	0080                	addi	s0,sp,64
    80003f6c:	8b2a                	mv	s6,a0
    80003f6e:	0001da97          	auipc	s5,0x1d
    80003f72:	e32a8a93          	addi	s5,s5,-462 # 80020da0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f76:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f78:	0001d997          	auipc	s3,0x1d
    80003f7c:	df898993          	addi	s3,s3,-520 # 80020d70 <log>
    80003f80:	a00d                	j	80003fa2 <install_trans+0x56>
    brelse(lbuf);
    80003f82:	854a                	mv	a0,s2
    80003f84:	fffff097          	auipc	ra,0xfffff
    80003f88:	07e080e7          	jalr	126(ra) # 80003002 <brelse>
    brelse(dbuf);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	fffff097          	auipc	ra,0xfffff
    80003f92:	074080e7          	jalr	116(ra) # 80003002 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f96:	2a05                	addiw	s4,s4,1
    80003f98:	0a91                	addi	s5,s5,4
    80003f9a:	02c9a783          	lw	a5,44(s3)
    80003f9e:	04fa5e63          	bge	s4,a5,80003ffa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fa2:	0189a583          	lw	a1,24(s3)
    80003fa6:	014585bb          	addw	a1,a1,s4
    80003faa:	2585                	addiw	a1,a1,1
    80003fac:	0289a503          	lw	a0,40(s3)
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	f22080e7          	jalr	-222(ra) # 80002ed2 <bread>
    80003fb8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fba:	000aa583          	lw	a1,0(s5)
    80003fbe:	0289a503          	lw	a0,40(s3)
    80003fc2:	fffff097          	auipc	ra,0xfffff
    80003fc6:	f10080e7          	jalr	-240(ra) # 80002ed2 <bread>
    80003fca:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fcc:	40000613          	li	a2,1024
    80003fd0:	05890593          	addi	a1,s2,88
    80003fd4:	05850513          	addi	a0,a0,88
    80003fd8:	ffffd097          	auipc	ra,0xffffd
    80003fdc:	d56080e7          	jalr	-682(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	fe2080e7          	jalr	-30(ra) # 80002fc4 <bwrite>
    if(recovering == 0)
    80003fea:	f80b1ce3          	bnez	s6,80003f82 <install_trans+0x36>
      bunpin(dbuf);
    80003fee:	8526                	mv	a0,s1
    80003ff0:	fffff097          	auipc	ra,0xfffff
    80003ff4:	0ec080e7          	jalr	236(ra) # 800030dc <bunpin>
    80003ff8:	b769                	j	80003f82 <install_trans+0x36>
}
    80003ffa:	70e2                	ld	ra,56(sp)
    80003ffc:	7442                	ld	s0,48(sp)
    80003ffe:	74a2                	ld	s1,40(sp)
    80004000:	7902                	ld	s2,32(sp)
    80004002:	69e2                	ld	s3,24(sp)
    80004004:	6a42                	ld	s4,16(sp)
    80004006:	6aa2                	ld	s5,8(sp)
    80004008:	6b02                	ld	s6,0(sp)
    8000400a:	6121                	addi	sp,sp,64
    8000400c:	8082                	ret
    8000400e:	8082                	ret

0000000080004010 <initlog>:
{
    80004010:	7179                	addi	sp,sp,-48
    80004012:	f406                	sd	ra,40(sp)
    80004014:	f022                	sd	s0,32(sp)
    80004016:	ec26                	sd	s1,24(sp)
    80004018:	e84a                	sd	s2,16(sp)
    8000401a:	e44e                	sd	s3,8(sp)
    8000401c:	1800                	addi	s0,sp,48
    8000401e:	892a                	mv	s2,a0
    80004020:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004022:	0001d497          	auipc	s1,0x1d
    80004026:	d4e48493          	addi	s1,s1,-690 # 80020d70 <log>
    8000402a:	00004597          	auipc	a1,0x4
    8000402e:	64658593          	addi	a1,a1,1606 # 80008670 <syscalls+0x1d8>
    80004032:	8526                	mv	a0,s1
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	b12080e7          	jalr	-1262(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000403c:	0149a583          	lw	a1,20(s3)
    80004040:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004042:	0109a783          	lw	a5,16(s3)
    80004046:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004048:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000404c:	854a                	mv	a0,s2
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	e84080e7          	jalr	-380(ra) # 80002ed2 <bread>
  log.lh.n = lh->n;
    80004056:	4d34                	lw	a3,88(a0)
    80004058:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000405a:	02d05663          	blez	a3,80004086 <initlog+0x76>
    8000405e:	05c50793          	addi	a5,a0,92
    80004062:	0001d717          	auipc	a4,0x1d
    80004066:	d3e70713          	addi	a4,a4,-706 # 80020da0 <log+0x30>
    8000406a:	36fd                	addiw	a3,a3,-1
    8000406c:	02069613          	slli	a2,a3,0x20
    80004070:	01e65693          	srli	a3,a2,0x1e
    80004074:	06050613          	addi	a2,a0,96
    80004078:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000407a:	4390                	lw	a2,0(a5)
    8000407c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000407e:	0791                	addi	a5,a5,4
    80004080:	0711                	addi	a4,a4,4
    80004082:	fed79ce3          	bne	a5,a3,8000407a <initlog+0x6a>
  brelse(buf);
    80004086:	fffff097          	auipc	ra,0xfffff
    8000408a:	f7c080e7          	jalr	-132(ra) # 80003002 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000408e:	4505                	li	a0,1
    80004090:	00000097          	auipc	ra,0x0
    80004094:	ebc080e7          	jalr	-324(ra) # 80003f4c <install_trans>
  log.lh.n = 0;
    80004098:	0001d797          	auipc	a5,0x1d
    8000409c:	d007a223          	sw	zero,-764(a5) # 80020d9c <log+0x2c>
  write_head(); // clear the log
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	e30080e7          	jalr	-464(ra) # 80003ed0 <write_head>
}
    800040a8:	70a2                	ld	ra,40(sp)
    800040aa:	7402                	ld	s0,32(sp)
    800040ac:	64e2                	ld	s1,24(sp)
    800040ae:	6942                	ld	s2,16(sp)
    800040b0:	69a2                	ld	s3,8(sp)
    800040b2:	6145                	addi	sp,sp,48
    800040b4:	8082                	ret

00000000800040b6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040b6:	1101                	addi	sp,sp,-32
    800040b8:	ec06                	sd	ra,24(sp)
    800040ba:	e822                	sd	s0,16(sp)
    800040bc:	e426                	sd	s1,8(sp)
    800040be:	e04a                	sd	s2,0(sp)
    800040c0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c2:	0001d517          	auipc	a0,0x1d
    800040c6:	cae50513          	addi	a0,a0,-850 # 80020d70 <log>
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	b0c080e7          	jalr	-1268(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800040d2:	0001d497          	auipc	s1,0x1d
    800040d6:	c9e48493          	addi	s1,s1,-866 # 80020d70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040da:	4979                	li	s2,30
    800040dc:	a039                	j	800040ea <begin_op+0x34>
      sleep(&log, &log.lock);
    800040de:	85a6                	mv	a1,s1
    800040e0:	8526                	mv	a0,s1
    800040e2:	ffffe097          	auipc	ra,0xffffe
    800040e6:	042080e7          	jalr	66(ra) # 80002124 <sleep>
    if(log.committing){
    800040ea:	50dc                	lw	a5,36(s1)
    800040ec:	fbed                	bnez	a5,800040de <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040ee:	5098                	lw	a4,32(s1)
    800040f0:	2705                	addiw	a4,a4,1
    800040f2:	0007069b          	sext.w	a3,a4
    800040f6:	0027179b          	slliw	a5,a4,0x2
    800040fa:	9fb9                	addw	a5,a5,a4
    800040fc:	0017979b          	slliw	a5,a5,0x1
    80004100:	54d8                	lw	a4,44(s1)
    80004102:	9fb9                	addw	a5,a5,a4
    80004104:	00f95963          	bge	s2,a5,80004116 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004108:	85a6                	mv	a1,s1
    8000410a:	8526                	mv	a0,s1
    8000410c:	ffffe097          	auipc	ra,0xffffe
    80004110:	018080e7          	jalr	24(ra) # 80002124 <sleep>
    80004114:	bfd9                	j	800040ea <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004116:	0001d517          	auipc	a0,0x1d
    8000411a:	c5a50513          	addi	a0,a0,-934 # 80020d70 <log>
    8000411e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b6a080e7          	jalr	-1174(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004128:	60e2                	ld	ra,24(sp)
    8000412a:	6442                	ld	s0,16(sp)
    8000412c:	64a2                	ld	s1,8(sp)
    8000412e:	6902                	ld	s2,0(sp)
    80004130:	6105                	addi	sp,sp,32
    80004132:	8082                	ret

0000000080004134 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004134:	7139                	addi	sp,sp,-64
    80004136:	fc06                	sd	ra,56(sp)
    80004138:	f822                	sd	s0,48(sp)
    8000413a:	f426                	sd	s1,40(sp)
    8000413c:	f04a                	sd	s2,32(sp)
    8000413e:	ec4e                	sd	s3,24(sp)
    80004140:	e852                	sd	s4,16(sp)
    80004142:	e456                	sd	s5,8(sp)
    80004144:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004146:	0001d497          	auipc	s1,0x1d
    8000414a:	c2a48493          	addi	s1,s1,-982 # 80020d70 <log>
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	a86080e7          	jalr	-1402(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004158:	509c                	lw	a5,32(s1)
    8000415a:	37fd                	addiw	a5,a5,-1
    8000415c:	0007891b          	sext.w	s2,a5
    80004160:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004162:	50dc                	lw	a5,36(s1)
    80004164:	e7b9                	bnez	a5,800041b2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004166:	04091e63          	bnez	s2,800041c2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000416a:	0001d497          	auipc	s1,0x1d
    8000416e:	c0648493          	addi	s1,s1,-1018 # 80020d70 <log>
    80004172:	4785                	li	a5,1
    80004174:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004176:	8526                	mv	a0,s1
    80004178:	ffffd097          	auipc	ra,0xffffd
    8000417c:	b12080e7          	jalr	-1262(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004180:	54dc                	lw	a5,44(s1)
    80004182:	06f04763          	bgtz	a5,800041f0 <end_op+0xbc>
    acquire(&log.lock);
    80004186:	0001d497          	auipc	s1,0x1d
    8000418a:	bea48493          	addi	s1,s1,-1046 # 80020d70 <log>
    8000418e:	8526                	mv	a0,s1
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	a46080e7          	jalr	-1466(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004198:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000419c:	8526                	mv	a0,s1
    8000419e:	ffffe097          	auipc	ra,0xffffe
    800041a2:	fea080e7          	jalr	-22(ra) # 80002188 <wakeup>
    release(&log.lock);
    800041a6:	8526                	mv	a0,s1
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	ae2080e7          	jalr	-1310(ra) # 80000c8a <release>
}
    800041b0:	a03d                	j	800041de <end_op+0xaa>
    panic("log.committing");
    800041b2:	00004517          	auipc	a0,0x4
    800041b6:	4c650513          	addi	a0,a0,1222 # 80008678 <syscalls+0x1e0>
    800041ba:	ffffc097          	auipc	ra,0xffffc
    800041be:	386080e7          	jalr	902(ra) # 80000540 <panic>
    wakeup(&log);
    800041c2:	0001d497          	auipc	s1,0x1d
    800041c6:	bae48493          	addi	s1,s1,-1106 # 80020d70 <log>
    800041ca:	8526                	mv	a0,s1
    800041cc:	ffffe097          	auipc	ra,0xffffe
    800041d0:	fbc080e7          	jalr	-68(ra) # 80002188 <wakeup>
  release(&log.lock);
    800041d4:	8526                	mv	a0,s1
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	ab4080e7          	jalr	-1356(ra) # 80000c8a <release>
}
    800041de:	70e2                	ld	ra,56(sp)
    800041e0:	7442                	ld	s0,48(sp)
    800041e2:	74a2                	ld	s1,40(sp)
    800041e4:	7902                	ld	s2,32(sp)
    800041e6:	69e2                	ld	s3,24(sp)
    800041e8:	6a42                	ld	s4,16(sp)
    800041ea:	6aa2                	ld	s5,8(sp)
    800041ec:	6121                	addi	sp,sp,64
    800041ee:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f0:	0001da97          	auipc	s5,0x1d
    800041f4:	bb0a8a93          	addi	s5,s5,-1104 # 80020da0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041f8:	0001da17          	auipc	s4,0x1d
    800041fc:	b78a0a13          	addi	s4,s4,-1160 # 80020d70 <log>
    80004200:	018a2583          	lw	a1,24(s4)
    80004204:	012585bb          	addw	a1,a1,s2
    80004208:	2585                	addiw	a1,a1,1
    8000420a:	028a2503          	lw	a0,40(s4)
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	cc4080e7          	jalr	-828(ra) # 80002ed2 <bread>
    80004216:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004218:	000aa583          	lw	a1,0(s5)
    8000421c:	028a2503          	lw	a0,40(s4)
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	cb2080e7          	jalr	-846(ra) # 80002ed2 <bread>
    80004228:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000422a:	40000613          	li	a2,1024
    8000422e:	05850593          	addi	a1,a0,88
    80004232:	05848513          	addi	a0,s1,88
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	af8080e7          	jalr	-1288(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000423e:	8526                	mv	a0,s1
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	d84080e7          	jalr	-636(ra) # 80002fc4 <bwrite>
    brelse(from);
    80004248:	854e                	mv	a0,s3
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	db8080e7          	jalr	-584(ra) # 80003002 <brelse>
    brelse(to);
    80004252:	8526                	mv	a0,s1
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	dae080e7          	jalr	-594(ra) # 80003002 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425c:	2905                	addiw	s2,s2,1
    8000425e:	0a91                	addi	s5,s5,4
    80004260:	02ca2783          	lw	a5,44(s4)
    80004264:	f8f94ee3          	blt	s2,a5,80004200 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	c68080e7          	jalr	-920(ra) # 80003ed0 <write_head>
    install_trans(0); // Now install writes to home locations
    80004270:	4501                	li	a0,0
    80004272:	00000097          	auipc	ra,0x0
    80004276:	cda080e7          	jalr	-806(ra) # 80003f4c <install_trans>
    log.lh.n = 0;
    8000427a:	0001d797          	auipc	a5,0x1d
    8000427e:	b207a123          	sw	zero,-1246(a5) # 80020d9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004282:	00000097          	auipc	ra,0x0
    80004286:	c4e080e7          	jalr	-946(ra) # 80003ed0 <write_head>
    8000428a:	bdf5                	j	80004186 <end_op+0x52>

000000008000428c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000428c:	1101                	addi	sp,sp,-32
    8000428e:	ec06                	sd	ra,24(sp)
    80004290:	e822                	sd	s0,16(sp)
    80004292:	e426                	sd	s1,8(sp)
    80004294:	e04a                	sd	s2,0(sp)
    80004296:	1000                	addi	s0,sp,32
    80004298:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000429a:	0001d917          	auipc	s2,0x1d
    8000429e:	ad690913          	addi	s2,s2,-1322 # 80020d70 <log>
    800042a2:	854a                	mv	a0,s2
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	932080e7          	jalr	-1742(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042ac:	02c92603          	lw	a2,44(s2)
    800042b0:	47f5                	li	a5,29
    800042b2:	06c7c563          	blt	a5,a2,8000431c <log_write+0x90>
    800042b6:	0001d797          	auipc	a5,0x1d
    800042ba:	ad67a783          	lw	a5,-1322(a5) # 80020d8c <log+0x1c>
    800042be:	37fd                	addiw	a5,a5,-1
    800042c0:	04f65e63          	bge	a2,a5,8000431c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	acc7a783          	lw	a5,-1332(a5) # 80020d90 <log+0x20>
    800042cc:	06f05063          	blez	a5,8000432c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042d0:	4781                	li	a5,0
    800042d2:	06c05563          	blez	a2,8000433c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042d6:	44cc                	lw	a1,12(s1)
    800042d8:	0001d717          	auipc	a4,0x1d
    800042dc:	ac870713          	addi	a4,a4,-1336 # 80020da0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042e0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e2:	4314                	lw	a3,0(a4)
    800042e4:	04b68c63          	beq	a3,a1,8000433c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042e8:	2785                	addiw	a5,a5,1
    800042ea:	0711                	addi	a4,a4,4
    800042ec:	fef61be3          	bne	a2,a5,800042e2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042f0:	0621                	addi	a2,a2,8
    800042f2:	060a                	slli	a2,a2,0x2
    800042f4:	0001d797          	auipc	a5,0x1d
    800042f8:	a7c78793          	addi	a5,a5,-1412 # 80020d70 <log>
    800042fc:	97b2                	add	a5,a5,a2
    800042fe:	44d8                	lw	a4,12(s1)
    80004300:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004302:	8526                	mv	a0,s1
    80004304:	fffff097          	auipc	ra,0xfffff
    80004308:	d9c080e7          	jalr	-612(ra) # 800030a0 <bpin>
    log.lh.n++;
    8000430c:	0001d717          	auipc	a4,0x1d
    80004310:	a6470713          	addi	a4,a4,-1436 # 80020d70 <log>
    80004314:	575c                	lw	a5,44(a4)
    80004316:	2785                	addiw	a5,a5,1
    80004318:	d75c                	sw	a5,44(a4)
    8000431a:	a82d                	j	80004354 <log_write+0xc8>
    panic("too big a transaction");
    8000431c:	00004517          	auipc	a0,0x4
    80004320:	36c50513          	addi	a0,a0,876 # 80008688 <syscalls+0x1f0>
    80004324:	ffffc097          	auipc	ra,0xffffc
    80004328:	21c080e7          	jalr	540(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000432c:	00004517          	auipc	a0,0x4
    80004330:	37450513          	addi	a0,a0,884 # 800086a0 <syscalls+0x208>
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	20c080e7          	jalr	524(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000433c:	00878693          	addi	a3,a5,8
    80004340:	068a                	slli	a3,a3,0x2
    80004342:	0001d717          	auipc	a4,0x1d
    80004346:	a2e70713          	addi	a4,a4,-1490 # 80020d70 <log>
    8000434a:	9736                	add	a4,a4,a3
    8000434c:	44d4                	lw	a3,12(s1)
    8000434e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004350:	faf609e3          	beq	a2,a5,80004302 <log_write+0x76>
  }
  release(&log.lock);
    80004354:	0001d517          	auipc	a0,0x1d
    80004358:	a1c50513          	addi	a0,a0,-1508 # 80020d70 <log>
    8000435c:	ffffd097          	auipc	ra,0xffffd
    80004360:	92e080e7          	jalr	-1746(ra) # 80000c8a <release>
}
    80004364:	60e2                	ld	ra,24(sp)
    80004366:	6442                	ld	s0,16(sp)
    80004368:	64a2                	ld	s1,8(sp)
    8000436a:	6902                	ld	s2,0(sp)
    8000436c:	6105                	addi	sp,sp,32
    8000436e:	8082                	ret

0000000080004370 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004370:	1101                	addi	sp,sp,-32
    80004372:	ec06                	sd	ra,24(sp)
    80004374:	e822                	sd	s0,16(sp)
    80004376:	e426                	sd	s1,8(sp)
    80004378:	e04a                	sd	s2,0(sp)
    8000437a:	1000                	addi	s0,sp,32
    8000437c:	84aa                	mv	s1,a0
    8000437e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004380:	00004597          	auipc	a1,0x4
    80004384:	34058593          	addi	a1,a1,832 # 800086c0 <syscalls+0x228>
    80004388:	0521                	addi	a0,a0,8
    8000438a:	ffffc097          	auipc	ra,0xffffc
    8000438e:	7bc080e7          	jalr	1980(ra) # 80000b46 <initlock>
  lk->name = name;
    80004392:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004396:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000439a:	0204a423          	sw	zero,40(s1)
}
    8000439e:	60e2                	ld	ra,24(sp)
    800043a0:	6442                	ld	s0,16(sp)
    800043a2:	64a2                	ld	s1,8(sp)
    800043a4:	6902                	ld	s2,0(sp)
    800043a6:	6105                	addi	sp,sp,32
    800043a8:	8082                	ret

00000000800043aa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043aa:	1101                	addi	sp,sp,-32
    800043ac:	ec06                	sd	ra,24(sp)
    800043ae:	e822                	sd	s0,16(sp)
    800043b0:	e426                	sd	s1,8(sp)
    800043b2:	e04a                	sd	s2,0(sp)
    800043b4:	1000                	addi	s0,sp,32
    800043b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043b8:	00850913          	addi	s2,a0,8
    800043bc:	854a                	mv	a0,s2
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	818080e7          	jalr	-2024(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800043c6:	409c                	lw	a5,0(s1)
    800043c8:	cb89                	beqz	a5,800043da <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043ca:	85ca                	mv	a1,s2
    800043cc:	8526                	mv	a0,s1
    800043ce:	ffffe097          	auipc	ra,0xffffe
    800043d2:	d56080e7          	jalr	-682(ra) # 80002124 <sleep>
  while (lk->locked) {
    800043d6:	409c                	lw	a5,0(s1)
    800043d8:	fbed                	bnez	a5,800043ca <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043da:	4785                	li	a5,1
    800043dc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043de:	ffffd097          	auipc	ra,0xffffd
    800043e2:	5f2080e7          	jalr	1522(ra) # 800019d0 <myproc>
    800043e6:	591c                	lw	a5,48(a0)
    800043e8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ea:	854a                	mv	a0,s2
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	89e080e7          	jalr	-1890(ra) # 80000c8a <release>
}
    800043f4:	60e2                	ld	ra,24(sp)
    800043f6:	6442                	ld	s0,16(sp)
    800043f8:	64a2                	ld	s1,8(sp)
    800043fa:	6902                	ld	s2,0(sp)
    800043fc:	6105                	addi	sp,sp,32
    800043fe:	8082                	ret

0000000080004400 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004400:	1101                	addi	sp,sp,-32
    80004402:	ec06                	sd	ra,24(sp)
    80004404:	e822                	sd	s0,16(sp)
    80004406:	e426                	sd	s1,8(sp)
    80004408:	e04a                	sd	s2,0(sp)
    8000440a:	1000                	addi	s0,sp,32
    8000440c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000440e:	00850913          	addi	s2,a0,8
    80004412:	854a                	mv	a0,s2
    80004414:	ffffc097          	auipc	ra,0xffffc
    80004418:	7c2080e7          	jalr	1986(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000441c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004420:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004424:	8526                	mv	a0,s1
    80004426:	ffffe097          	auipc	ra,0xffffe
    8000442a:	d62080e7          	jalr	-670(ra) # 80002188 <wakeup>
  release(&lk->lk);
    8000442e:	854a                	mv	a0,s2
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	85a080e7          	jalr	-1958(ra) # 80000c8a <release>
}
    80004438:	60e2                	ld	ra,24(sp)
    8000443a:	6442                	ld	s0,16(sp)
    8000443c:	64a2                	ld	s1,8(sp)
    8000443e:	6902                	ld	s2,0(sp)
    80004440:	6105                	addi	sp,sp,32
    80004442:	8082                	ret

0000000080004444 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004444:	7179                	addi	sp,sp,-48
    80004446:	f406                	sd	ra,40(sp)
    80004448:	f022                	sd	s0,32(sp)
    8000444a:	ec26                	sd	s1,24(sp)
    8000444c:	e84a                	sd	s2,16(sp)
    8000444e:	e44e                	sd	s3,8(sp)
    80004450:	1800                	addi	s0,sp,48
    80004452:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004454:	00850913          	addi	s2,a0,8
    80004458:	854a                	mv	a0,s2
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	77c080e7          	jalr	1916(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004462:	409c                	lw	a5,0(s1)
    80004464:	ef99                	bnez	a5,80004482 <holdingsleep+0x3e>
    80004466:	4481                	li	s1,0
  release(&lk->lk);
    80004468:	854a                	mv	a0,s2
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	820080e7          	jalr	-2016(ra) # 80000c8a <release>
  return r;
}
    80004472:	8526                	mv	a0,s1
    80004474:	70a2                	ld	ra,40(sp)
    80004476:	7402                	ld	s0,32(sp)
    80004478:	64e2                	ld	s1,24(sp)
    8000447a:	6942                	ld	s2,16(sp)
    8000447c:	69a2                	ld	s3,8(sp)
    8000447e:	6145                	addi	sp,sp,48
    80004480:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004482:	0284a983          	lw	s3,40(s1)
    80004486:	ffffd097          	auipc	ra,0xffffd
    8000448a:	54a080e7          	jalr	1354(ra) # 800019d0 <myproc>
    8000448e:	5904                	lw	s1,48(a0)
    80004490:	413484b3          	sub	s1,s1,s3
    80004494:	0014b493          	seqz	s1,s1
    80004498:	bfc1                	j	80004468 <holdingsleep+0x24>

000000008000449a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000449a:	1141                	addi	sp,sp,-16
    8000449c:	e406                	sd	ra,8(sp)
    8000449e:	e022                	sd	s0,0(sp)
    800044a0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044a2:	00004597          	auipc	a1,0x4
    800044a6:	22e58593          	addi	a1,a1,558 # 800086d0 <syscalls+0x238>
    800044aa:	0001d517          	auipc	a0,0x1d
    800044ae:	a0e50513          	addi	a0,a0,-1522 # 80020eb8 <ftable>
    800044b2:	ffffc097          	auipc	ra,0xffffc
    800044b6:	694080e7          	jalr	1684(ra) # 80000b46 <initlock>
}
    800044ba:	60a2                	ld	ra,8(sp)
    800044bc:	6402                	ld	s0,0(sp)
    800044be:	0141                	addi	sp,sp,16
    800044c0:	8082                	ret

00000000800044c2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044c2:	1101                	addi	sp,sp,-32
    800044c4:	ec06                	sd	ra,24(sp)
    800044c6:	e822                	sd	s0,16(sp)
    800044c8:	e426                	sd	s1,8(sp)
    800044ca:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044cc:	0001d517          	auipc	a0,0x1d
    800044d0:	9ec50513          	addi	a0,a0,-1556 # 80020eb8 <ftable>
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	702080e7          	jalr	1794(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044dc:	0001d497          	auipc	s1,0x1d
    800044e0:	9f448493          	addi	s1,s1,-1548 # 80020ed0 <ftable+0x18>
    800044e4:	0001e717          	auipc	a4,0x1e
    800044e8:	98c70713          	addi	a4,a4,-1652 # 80021e70 <disk>
    if(f->ref == 0){
    800044ec:	40dc                	lw	a5,4(s1)
    800044ee:	cf99                	beqz	a5,8000450c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044f0:	02848493          	addi	s1,s1,40
    800044f4:	fee49ce3          	bne	s1,a4,800044ec <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044f8:	0001d517          	auipc	a0,0x1d
    800044fc:	9c050513          	addi	a0,a0,-1600 # 80020eb8 <ftable>
    80004500:	ffffc097          	auipc	ra,0xffffc
    80004504:	78a080e7          	jalr	1930(ra) # 80000c8a <release>
  return 0;
    80004508:	4481                	li	s1,0
    8000450a:	a819                	j	80004520 <filealloc+0x5e>
      f->ref = 1;
    8000450c:	4785                	li	a5,1
    8000450e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004510:	0001d517          	auipc	a0,0x1d
    80004514:	9a850513          	addi	a0,a0,-1624 # 80020eb8 <ftable>
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	772080e7          	jalr	1906(ra) # 80000c8a <release>
}
    80004520:	8526                	mv	a0,s1
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6105                	addi	sp,sp,32
    8000452a:	8082                	ret

000000008000452c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000452c:	1101                	addi	sp,sp,-32
    8000452e:	ec06                	sd	ra,24(sp)
    80004530:	e822                	sd	s0,16(sp)
    80004532:	e426                	sd	s1,8(sp)
    80004534:	1000                	addi	s0,sp,32
    80004536:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004538:	0001d517          	auipc	a0,0x1d
    8000453c:	98050513          	addi	a0,a0,-1664 # 80020eb8 <ftable>
    80004540:	ffffc097          	auipc	ra,0xffffc
    80004544:	696080e7          	jalr	1686(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004548:	40dc                	lw	a5,4(s1)
    8000454a:	02f05263          	blez	a5,8000456e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000454e:	2785                	addiw	a5,a5,1
    80004550:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004552:	0001d517          	auipc	a0,0x1d
    80004556:	96650513          	addi	a0,a0,-1690 # 80020eb8 <ftable>
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	730080e7          	jalr	1840(ra) # 80000c8a <release>
  return f;
}
    80004562:	8526                	mv	a0,s1
    80004564:	60e2                	ld	ra,24(sp)
    80004566:	6442                	ld	s0,16(sp)
    80004568:	64a2                	ld	s1,8(sp)
    8000456a:	6105                	addi	sp,sp,32
    8000456c:	8082                	ret
    panic("filedup");
    8000456e:	00004517          	auipc	a0,0x4
    80004572:	16a50513          	addi	a0,a0,362 # 800086d8 <syscalls+0x240>
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	fca080e7          	jalr	-54(ra) # 80000540 <panic>

000000008000457e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000457e:	7139                	addi	sp,sp,-64
    80004580:	fc06                	sd	ra,56(sp)
    80004582:	f822                	sd	s0,48(sp)
    80004584:	f426                	sd	s1,40(sp)
    80004586:	f04a                	sd	s2,32(sp)
    80004588:	ec4e                	sd	s3,24(sp)
    8000458a:	e852                	sd	s4,16(sp)
    8000458c:	e456                	sd	s5,8(sp)
    8000458e:	0080                	addi	s0,sp,64
    80004590:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004592:	0001d517          	auipc	a0,0x1d
    80004596:	92650513          	addi	a0,a0,-1754 # 80020eb8 <ftable>
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	63c080e7          	jalr	1596(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800045a2:	40dc                	lw	a5,4(s1)
    800045a4:	06f05163          	blez	a5,80004606 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045a8:	37fd                	addiw	a5,a5,-1
    800045aa:	0007871b          	sext.w	a4,a5
    800045ae:	c0dc                	sw	a5,4(s1)
    800045b0:	06e04363          	bgtz	a4,80004616 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045b4:	0004a903          	lw	s2,0(s1)
    800045b8:	0094ca83          	lbu	s5,9(s1)
    800045bc:	0104ba03          	ld	s4,16(s1)
    800045c0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045c4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045c8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045cc:	0001d517          	auipc	a0,0x1d
    800045d0:	8ec50513          	addi	a0,a0,-1812 # 80020eb8 <ftable>
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	6b6080e7          	jalr	1718(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800045dc:	4785                	li	a5,1
    800045de:	04f90d63          	beq	s2,a5,80004638 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045e2:	3979                	addiw	s2,s2,-2
    800045e4:	4785                	li	a5,1
    800045e6:	0527e063          	bltu	a5,s2,80004626 <fileclose+0xa8>
    begin_op();
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	acc080e7          	jalr	-1332(ra) # 800040b6 <begin_op>
    iput(ff.ip);
    800045f2:	854e                	mv	a0,s3
    800045f4:	fffff097          	auipc	ra,0xfffff
    800045f8:	2b0080e7          	jalr	688(ra) # 800038a4 <iput>
    end_op();
    800045fc:	00000097          	auipc	ra,0x0
    80004600:	b38080e7          	jalr	-1224(ra) # 80004134 <end_op>
    80004604:	a00d                	j	80004626 <fileclose+0xa8>
    panic("fileclose");
    80004606:	00004517          	auipc	a0,0x4
    8000460a:	0da50513          	addi	a0,a0,218 # 800086e0 <syscalls+0x248>
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	f32080e7          	jalr	-206(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004616:	0001d517          	auipc	a0,0x1d
    8000461a:	8a250513          	addi	a0,a0,-1886 # 80020eb8 <ftable>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	66c080e7          	jalr	1644(ra) # 80000c8a <release>
  }
}
    80004626:	70e2                	ld	ra,56(sp)
    80004628:	7442                	ld	s0,48(sp)
    8000462a:	74a2                	ld	s1,40(sp)
    8000462c:	7902                	ld	s2,32(sp)
    8000462e:	69e2                	ld	s3,24(sp)
    80004630:	6a42                	ld	s4,16(sp)
    80004632:	6aa2                	ld	s5,8(sp)
    80004634:	6121                	addi	sp,sp,64
    80004636:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004638:	85d6                	mv	a1,s5
    8000463a:	8552                	mv	a0,s4
    8000463c:	00000097          	auipc	ra,0x0
    80004640:	34c080e7          	jalr	844(ra) # 80004988 <pipeclose>
    80004644:	b7cd                	j	80004626 <fileclose+0xa8>

0000000080004646 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004646:	715d                	addi	sp,sp,-80
    80004648:	e486                	sd	ra,72(sp)
    8000464a:	e0a2                	sd	s0,64(sp)
    8000464c:	fc26                	sd	s1,56(sp)
    8000464e:	f84a                	sd	s2,48(sp)
    80004650:	f44e                	sd	s3,40(sp)
    80004652:	0880                	addi	s0,sp,80
    80004654:	84aa                	mv	s1,a0
    80004656:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004658:	ffffd097          	auipc	ra,0xffffd
    8000465c:	378080e7          	jalr	888(ra) # 800019d0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004660:	409c                	lw	a5,0(s1)
    80004662:	37f9                	addiw	a5,a5,-2
    80004664:	4705                	li	a4,1
    80004666:	04f76763          	bltu	a4,a5,800046b4 <filestat+0x6e>
    8000466a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000466c:	6c88                	ld	a0,24(s1)
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	07c080e7          	jalr	124(ra) # 800036ea <ilock>
    stati(f->ip, &st);
    80004676:	fb840593          	addi	a1,s0,-72
    8000467a:	6c88                	ld	a0,24(s1)
    8000467c:	fffff097          	auipc	ra,0xfffff
    80004680:	2f8080e7          	jalr	760(ra) # 80003974 <stati>
    iunlock(f->ip);
    80004684:	6c88                	ld	a0,24(s1)
    80004686:	fffff097          	auipc	ra,0xfffff
    8000468a:	126080e7          	jalr	294(ra) # 800037ac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000468e:	46e1                	li	a3,24
    80004690:	fb840613          	addi	a2,s0,-72
    80004694:	85ce                	mv	a1,s3
    80004696:	05093503          	ld	a0,80(s2)
    8000469a:	ffffd097          	auipc	ra,0xffffd
    8000469e:	ff2080e7          	jalr	-14(ra) # 8000168c <copyout>
    800046a2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046a6:	60a6                	ld	ra,72(sp)
    800046a8:	6406                	ld	s0,64(sp)
    800046aa:	74e2                	ld	s1,56(sp)
    800046ac:	7942                	ld	s2,48(sp)
    800046ae:	79a2                	ld	s3,40(sp)
    800046b0:	6161                	addi	sp,sp,80
    800046b2:	8082                	ret
  return -1;
    800046b4:	557d                	li	a0,-1
    800046b6:	bfc5                	j	800046a6 <filestat+0x60>

00000000800046b8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046b8:	7179                	addi	sp,sp,-48
    800046ba:	f406                	sd	ra,40(sp)
    800046bc:	f022                	sd	s0,32(sp)
    800046be:	ec26                	sd	s1,24(sp)
    800046c0:	e84a                	sd	s2,16(sp)
    800046c2:	e44e                	sd	s3,8(sp)
    800046c4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046c6:	00854783          	lbu	a5,8(a0)
    800046ca:	c3d5                	beqz	a5,8000476e <fileread+0xb6>
    800046cc:	84aa                	mv	s1,a0
    800046ce:	89ae                	mv	s3,a1
    800046d0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046d2:	411c                	lw	a5,0(a0)
    800046d4:	4705                	li	a4,1
    800046d6:	04e78963          	beq	a5,a4,80004728 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046da:	470d                	li	a4,3
    800046dc:	04e78d63          	beq	a5,a4,80004736 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046e0:	4709                	li	a4,2
    800046e2:	06e79e63          	bne	a5,a4,8000475e <fileread+0xa6>
    ilock(f->ip);
    800046e6:	6d08                	ld	a0,24(a0)
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	002080e7          	jalr	2(ra) # 800036ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046f0:	874a                	mv	a4,s2
    800046f2:	5094                	lw	a3,32(s1)
    800046f4:	864e                	mv	a2,s3
    800046f6:	4585                	li	a1,1
    800046f8:	6c88                	ld	a0,24(s1)
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	2a4080e7          	jalr	676(ra) # 8000399e <readi>
    80004702:	892a                	mv	s2,a0
    80004704:	00a05563          	blez	a0,8000470e <fileread+0x56>
      f->off += r;
    80004708:	509c                	lw	a5,32(s1)
    8000470a:	9fa9                	addw	a5,a5,a0
    8000470c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000470e:	6c88                	ld	a0,24(s1)
    80004710:	fffff097          	auipc	ra,0xfffff
    80004714:	09c080e7          	jalr	156(ra) # 800037ac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004718:	854a                	mv	a0,s2
    8000471a:	70a2                	ld	ra,40(sp)
    8000471c:	7402                	ld	s0,32(sp)
    8000471e:	64e2                	ld	s1,24(sp)
    80004720:	6942                	ld	s2,16(sp)
    80004722:	69a2                	ld	s3,8(sp)
    80004724:	6145                	addi	sp,sp,48
    80004726:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004728:	6908                	ld	a0,16(a0)
    8000472a:	00000097          	auipc	ra,0x0
    8000472e:	3c6080e7          	jalr	966(ra) # 80004af0 <piperead>
    80004732:	892a                	mv	s2,a0
    80004734:	b7d5                	j	80004718 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004736:	02451783          	lh	a5,36(a0)
    8000473a:	03079693          	slli	a3,a5,0x30
    8000473e:	92c1                	srli	a3,a3,0x30
    80004740:	4725                	li	a4,9
    80004742:	02d76863          	bltu	a4,a3,80004772 <fileread+0xba>
    80004746:	0792                	slli	a5,a5,0x4
    80004748:	0001c717          	auipc	a4,0x1c
    8000474c:	6d070713          	addi	a4,a4,1744 # 80020e18 <devsw>
    80004750:	97ba                	add	a5,a5,a4
    80004752:	639c                	ld	a5,0(a5)
    80004754:	c38d                	beqz	a5,80004776 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004756:	4505                	li	a0,1
    80004758:	9782                	jalr	a5
    8000475a:	892a                	mv	s2,a0
    8000475c:	bf75                	j	80004718 <fileread+0x60>
    panic("fileread");
    8000475e:	00004517          	auipc	a0,0x4
    80004762:	f9250513          	addi	a0,a0,-110 # 800086f0 <syscalls+0x258>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	dda080e7          	jalr	-550(ra) # 80000540 <panic>
    return -1;
    8000476e:	597d                	li	s2,-1
    80004770:	b765                	j	80004718 <fileread+0x60>
      return -1;
    80004772:	597d                	li	s2,-1
    80004774:	b755                	j	80004718 <fileread+0x60>
    80004776:	597d                	li	s2,-1
    80004778:	b745                	j	80004718 <fileread+0x60>

000000008000477a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000477a:	715d                	addi	sp,sp,-80
    8000477c:	e486                	sd	ra,72(sp)
    8000477e:	e0a2                	sd	s0,64(sp)
    80004780:	fc26                	sd	s1,56(sp)
    80004782:	f84a                	sd	s2,48(sp)
    80004784:	f44e                	sd	s3,40(sp)
    80004786:	f052                	sd	s4,32(sp)
    80004788:	ec56                	sd	s5,24(sp)
    8000478a:	e85a                	sd	s6,16(sp)
    8000478c:	e45e                	sd	s7,8(sp)
    8000478e:	e062                	sd	s8,0(sp)
    80004790:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004792:	00954783          	lbu	a5,9(a0)
    80004796:	10078663          	beqz	a5,800048a2 <filewrite+0x128>
    8000479a:	892a                	mv	s2,a0
    8000479c:	8b2e                	mv	s6,a1
    8000479e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047a0:	411c                	lw	a5,0(a0)
    800047a2:	4705                	li	a4,1
    800047a4:	02e78263          	beq	a5,a4,800047c8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047a8:	470d                	li	a4,3
    800047aa:	02e78663          	beq	a5,a4,800047d6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047ae:	4709                	li	a4,2
    800047b0:	0ee79163          	bne	a5,a4,80004892 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047b4:	0ac05d63          	blez	a2,8000486e <filewrite+0xf4>
    int i = 0;
    800047b8:	4981                	li	s3,0
    800047ba:	6b85                	lui	s7,0x1
    800047bc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047c0:	6c05                	lui	s8,0x1
    800047c2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047c6:	a861                	j	8000485e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047c8:	6908                	ld	a0,16(a0)
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	22e080e7          	jalr	558(ra) # 800049f8 <pipewrite>
    800047d2:	8a2a                	mv	s4,a0
    800047d4:	a045                	j	80004874 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047d6:	02451783          	lh	a5,36(a0)
    800047da:	03079693          	slli	a3,a5,0x30
    800047de:	92c1                	srli	a3,a3,0x30
    800047e0:	4725                	li	a4,9
    800047e2:	0cd76263          	bltu	a4,a3,800048a6 <filewrite+0x12c>
    800047e6:	0792                	slli	a5,a5,0x4
    800047e8:	0001c717          	auipc	a4,0x1c
    800047ec:	63070713          	addi	a4,a4,1584 # 80020e18 <devsw>
    800047f0:	97ba                	add	a5,a5,a4
    800047f2:	679c                	ld	a5,8(a5)
    800047f4:	cbdd                	beqz	a5,800048aa <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047f6:	4505                	li	a0,1
    800047f8:	9782                	jalr	a5
    800047fa:	8a2a                	mv	s4,a0
    800047fc:	a8a5                	j	80004874 <filewrite+0xfa>
    800047fe:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004802:	00000097          	auipc	ra,0x0
    80004806:	8b4080e7          	jalr	-1868(ra) # 800040b6 <begin_op>
      ilock(f->ip);
    8000480a:	01893503          	ld	a0,24(s2)
    8000480e:	fffff097          	auipc	ra,0xfffff
    80004812:	edc080e7          	jalr	-292(ra) # 800036ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004816:	8756                	mv	a4,s5
    80004818:	02092683          	lw	a3,32(s2)
    8000481c:	01698633          	add	a2,s3,s6
    80004820:	4585                	li	a1,1
    80004822:	01893503          	ld	a0,24(s2)
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	270080e7          	jalr	624(ra) # 80003a96 <writei>
    8000482e:	84aa                	mv	s1,a0
    80004830:	00a05763          	blez	a0,8000483e <filewrite+0xc4>
        f->off += r;
    80004834:	02092783          	lw	a5,32(s2)
    80004838:	9fa9                	addw	a5,a5,a0
    8000483a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000483e:	01893503          	ld	a0,24(s2)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	f6a080e7          	jalr	-150(ra) # 800037ac <iunlock>
      end_op();
    8000484a:	00000097          	auipc	ra,0x0
    8000484e:	8ea080e7          	jalr	-1814(ra) # 80004134 <end_op>

      if(r != n1){
    80004852:	009a9f63          	bne	s5,s1,80004870 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004856:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000485a:	0149db63          	bge	s3,s4,80004870 <filewrite+0xf6>
      int n1 = n - i;
    8000485e:	413a04bb          	subw	s1,s4,s3
    80004862:	0004879b          	sext.w	a5,s1
    80004866:	f8fbdce3          	bge	s7,a5,800047fe <filewrite+0x84>
    8000486a:	84e2                	mv	s1,s8
    8000486c:	bf49                	j	800047fe <filewrite+0x84>
    int i = 0;
    8000486e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004870:	013a1f63          	bne	s4,s3,8000488e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004874:	8552                	mv	a0,s4
    80004876:	60a6                	ld	ra,72(sp)
    80004878:	6406                	ld	s0,64(sp)
    8000487a:	74e2                	ld	s1,56(sp)
    8000487c:	7942                	ld	s2,48(sp)
    8000487e:	79a2                	ld	s3,40(sp)
    80004880:	7a02                	ld	s4,32(sp)
    80004882:	6ae2                	ld	s5,24(sp)
    80004884:	6b42                	ld	s6,16(sp)
    80004886:	6ba2                	ld	s7,8(sp)
    80004888:	6c02                	ld	s8,0(sp)
    8000488a:	6161                	addi	sp,sp,80
    8000488c:	8082                	ret
    ret = (i == n ? n : -1);
    8000488e:	5a7d                	li	s4,-1
    80004890:	b7d5                	j	80004874 <filewrite+0xfa>
    panic("filewrite");
    80004892:	00004517          	auipc	a0,0x4
    80004896:	e6e50513          	addi	a0,a0,-402 # 80008700 <syscalls+0x268>
    8000489a:	ffffc097          	auipc	ra,0xffffc
    8000489e:	ca6080e7          	jalr	-858(ra) # 80000540 <panic>
    return -1;
    800048a2:	5a7d                	li	s4,-1
    800048a4:	bfc1                	j	80004874 <filewrite+0xfa>
      return -1;
    800048a6:	5a7d                	li	s4,-1
    800048a8:	b7f1                	j	80004874 <filewrite+0xfa>
    800048aa:	5a7d                	li	s4,-1
    800048ac:	b7e1                	j	80004874 <filewrite+0xfa>

00000000800048ae <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048ae:	7179                	addi	sp,sp,-48
    800048b0:	f406                	sd	ra,40(sp)
    800048b2:	f022                	sd	s0,32(sp)
    800048b4:	ec26                	sd	s1,24(sp)
    800048b6:	e84a                	sd	s2,16(sp)
    800048b8:	e44e                	sd	s3,8(sp)
    800048ba:	e052                	sd	s4,0(sp)
    800048bc:	1800                	addi	s0,sp,48
    800048be:	84aa                	mv	s1,a0
    800048c0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048c2:	0005b023          	sd	zero,0(a1)
    800048c6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048ca:	00000097          	auipc	ra,0x0
    800048ce:	bf8080e7          	jalr	-1032(ra) # 800044c2 <filealloc>
    800048d2:	e088                	sd	a0,0(s1)
    800048d4:	c551                	beqz	a0,80004960 <pipealloc+0xb2>
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	bec080e7          	jalr	-1044(ra) # 800044c2 <filealloc>
    800048de:	00aa3023          	sd	a0,0(s4)
    800048e2:	c92d                	beqz	a0,80004954 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	202080e7          	jalr	514(ra) # 80000ae6 <kalloc>
    800048ec:	892a                	mv	s2,a0
    800048ee:	c125                	beqz	a0,8000494e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048f0:	4985                	li	s3,1
    800048f2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048f6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048fa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048fe:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004902:	00004597          	auipc	a1,0x4
    80004906:	e0e58593          	addi	a1,a1,-498 # 80008710 <syscalls+0x278>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	23c080e7          	jalr	572(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004912:	609c                	ld	a5,0(s1)
    80004914:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004918:	609c                	ld	a5,0(s1)
    8000491a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000491e:	609c                	ld	a5,0(s1)
    80004920:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004924:	609c                	ld	a5,0(s1)
    80004926:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000492a:	000a3783          	ld	a5,0(s4)
    8000492e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004932:	000a3783          	ld	a5,0(s4)
    80004936:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000493a:	000a3783          	ld	a5,0(s4)
    8000493e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004942:	000a3783          	ld	a5,0(s4)
    80004946:	0127b823          	sd	s2,16(a5)
  return 0;
    8000494a:	4501                	li	a0,0
    8000494c:	a025                	j	80004974 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000494e:	6088                	ld	a0,0(s1)
    80004950:	e501                	bnez	a0,80004958 <pipealloc+0xaa>
    80004952:	a039                	j	80004960 <pipealloc+0xb2>
    80004954:	6088                	ld	a0,0(s1)
    80004956:	c51d                	beqz	a0,80004984 <pipealloc+0xd6>
    fileclose(*f0);
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	c26080e7          	jalr	-986(ra) # 8000457e <fileclose>
  if(*f1)
    80004960:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004964:	557d                	li	a0,-1
  if(*f1)
    80004966:	c799                	beqz	a5,80004974 <pipealloc+0xc6>
    fileclose(*f1);
    80004968:	853e                	mv	a0,a5
    8000496a:	00000097          	auipc	ra,0x0
    8000496e:	c14080e7          	jalr	-1004(ra) # 8000457e <fileclose>
  return -1;
    80004972:	557d                	li	a0,-1
}
    80004974:	70a2                	ld	ra,40(sp)
    80004976:	7402                	ld	s0,32(sp)
    80004978:	64e2                	ld	s1,24(sp)
    8000497a:	6942                	ld	s2,16(sp)
    8000497c:	69a2                	ld	s3,8(sp)
    8000497e:	6a02                	ld	s4,0(sp)
    80004980:	6145                	addi	sp,sp,48
    80004982:	8082                	ret
  return -1;
    80004984:	557d                	li	a0,-1
    80004986:	b7fd                	j	80004974 <pipealloc+0xc6>

0000000080004988 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004988:	1101                	addi	sp,sp,-32
    8000498a:	ec06                	sd	ra,24(sp)
    8000498c:	e822                	sd	s0,16(sp)
    8000498e:	e426                	sd	s1,8(sp)
    80004990:	e04a                	sd	s2,0(sp)
    80004992:	1000                	addi	s0,sp,32
    80004994:	84aa                	mv	s1,a0
    80004996:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	23e080e7          	jalr	574(ra) # 80000bd6 <acquire>
  if(writable){
    800049a0:	02090d63          	beqz	s2,800049da <pipeclose+0x52>
    pi->writeopen = 0;
    800049a4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049a8:	21848513          	addi	a0,s1,536
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	7dc080e7          	jalr	2012(ra) # 80002188 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049b4:	2204b783          	ld	a5,544(s1)
    800049b8:	eb95                	bnez	a5,800049ec <pipeclose+0x64>
    release(&pi->lock);
    800049ba:	8526                	mv	a0,s1
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	2ce080e7          	jalr	718(ra) # 80000c8a <release>
    kfree((char*)pi);
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffc097          	auipc	ra,0xffffc
    800049ca:	022080e7          	jalr	34(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    800049ce:	60e2                	ld	ra,24(sp)
    800049d0:	6442                	ld	s0,16(sp)
    800049d2:	64a2                	ld	s1,8(sp)
    800049d4:	6902                	ld	s2,0(sp)
    800049d6:	6105                	addi	sp,sp,32
    800049d8:	8082                	ret
    pi->readopen = 0;
    800049da:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049de:	21c48513          	addi	a0,s1,540
    800049e2:	ffffd097          	auipc	ra,0xffffd
    800049e6:	7a6080e7          	jalr	1958(ra) # 80002188 <wakeup>
    800049ea:	b7e9                	j	800049b4 <pipeclose+0x2c>
    release(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	29c080e7          	jalr	668(ra) # 80000c8a <release>
}
    800049f6:	bfe1                	j	800049ce <pipeclose+0x46>

00000000800049f8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049f8:	711d                	addi	sp,sp,-96
    800049fa:	ec86                	sd	ra,88(sp)
    800049fc:	e8a2                	sd	s0,80(sp)
    800049fe:	e4a6                	sd	s1,72(sp)
    80004a00:	e0ca                	sd	s2,64(sp)
    80004a02:	fc4e                	sd	s3,56(sp)
    80004a04:	f852                	sd	s4,48(sp)
    80004a06:	f456                	sd	s5,40(sp)
    80004a08:	f05a                	sd	s6,32(sp)
    80004a0a:	ec5e                	sd	s7,24(sp)
    80004a0c:	e862                	sd	s8,16(sp)
    80004a0e:	1080                	addi	s0,sp,96
    80004a10:	84aa                	mv	s1,a0
    80004a12:	8aae                	mv	s5,a1
    80004a14:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a16:	ffffd097          	auipc	ra,0xffffd
    80004a1a:	fba080e7          	jalr	-70(ra) # 800019d0 <myproc>
    80004a1e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a20:	8526                	mv	a0,s1
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	1b4080e7          	jalr	436(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a2a:	0b405663          	blez	s4,80004ad6 <pipewrite+0xde>
  int i = 0;
    80004a2e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a30:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a32:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a36:	21c48b93          	addi	s7,s1,540
    80004a3a:	a089                	j	80004a7c <pipewrite+0x84>
      release(&pi->lock);
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	24c080e7          	jalr	588(ra) # 80000c8a <release>
      return -1;
    80004a46:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a48:	854a                	mv	a0,s2
    80004a4a:	60e6                	ld	ra,88(sp)
    80004a4c:	6446                	ld	s0,80(sp)
    80004a4e:	64a6                	ld	s1,72(sp)
    80004a50:	6906                	ld	s2,64(sp)
    80004a52:	79e2                	ld	s3,56(sp)
    80004a54:	7a42                	ld	s4,48(sp)
    80004a56:	7aa2                	ld	s5,40(sp)
    80004a58:	7b02                	ld	s6,32(sp)
    80004a5a:	6be2                	ld	s7,24(sp)
    80004a5c:	6c42                	ld	s8,16(sp)
    80004a5e:	6125                	addi	sp,sp,96
    80004a60:	8082                	ret
      wakeup(&pi->nread);
    80004a62:	8562                	mv	a0,s8
    80004a64:	ffffd097          	auipc	ra,0xffffd
    80004a68:	724080e7          	jalr	1828(ra) # 80002188 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a6c:	85a6                	mv	a1,s1
    80004a6e:	855e                	mv	a0,s7
    80004a70:	ffffd097          	auipc	ra,0xffffd
    80004a74:	6b4080e7          	jalr	1716(ra) # 80002124 <sleep>
  while(i < n){
    80004a78:	07495063          	bge	s2,s4,80004ad8 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a7c:	2204a783          	lw	a5,544(s1)
    80004a80:	dfd5                	beqz	a5,80004a3c <pipewrite+0x44>
    80004a82:	854e                	mv	a0,s3
    80004a84:	ffffe097          	auipc	ra,0xffffe
    80004a88:	948080e7          	jalr	-1720(ra) # 800023cc <killed>
    80004a8c:	f945                	bnez	a0,80004a3c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a8e:	2184a783          	lw	a5,536(s1)
    80004a92:	21c4a703          	lw	a4,540(s1)
    80004a96:	2007879b          	addiw	a5,a5,512
    80004a9a:	fcf704e3          	beq	a4,a5,80004a62 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a9e:	4685                	li	a3,1
    80004aa0:	01590633          	add	a2,s2,s5
    80004aa4:	faf40593          	addi	a1,s0,-81
    80004aa8:	0509b503          	ld	a0,80(s3)
    80004aac:	ffffd097          	auipc	ra,0xffffd
    80004ab0:	c6c080e7          	jalr	-916(ra) # 80001718 <copyin>
    80004ab4:	03650263          	beq	a0,s6,80004ad8 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ab8:	21c4a783          	lw	a5,540(s1)
    80004abc:	0017871b          	addiw	a4,a5,1
    80004ac0:	20e4ae23          	sw	a4,540(s1)
    80004ac4:	1ff7f793          	andi	a5,a5,511
    80004ac8:	97a6                	add	a5,a5,s1
    80004aca:	faf44703          	lbu	a4,-81(s0)
    80004ace:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ad2:	2905                	addiw	s2,s2,1
    80004ad4:	b755                	j	80004a78 <pipewrite+0x80>
  int i = 0;
    80004ad6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ad8:	21848513          	addi	a0,s1,536
    80004adc:	ffffd097          	auipc	ra,0xffffd
    80004ae0:	6ac080e7          	jalr	1708(ra) # 80002188 <wakeup>
  release(&pi->lock);
    80004ae4:	8526                	mv	a0,s1
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	1a4080e7          	jalr	420(ra) # 80000c8a <release>
  return i;
    80004aee:	bfa9                	j	80004a48 <pipewrite+0x50>

0000000080004af0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004af0:	715d                	addi	sp,sp,-80
    80004af2:	e486                	sd	ra,72(sp)
    80004af4:	e0a2                	sd	s0,64(sp)
    80004af6:	fc26                	sd	s1,56(sp)
    80004af8:	f84a                	sd	s2,48(sp)
    80004afa:	f44e                	sd	s3,40(sp)
    80004afc:	f052                	sd	s4,32(sp)
    80004afe:	ec56                	sd	s5,24(sp)
    80004b00:	e85a                	sd	s6,16(sp)
    80004b02:	0880                	addi	s0,sp,80
    80004b04:	84aa                	mv	s1,a0
    80004b06:	892e                	mv	s2,a1
    80004b08:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b0a:	ffffd097          	auipc	ra,0xffffd
    80004b0e:	ec6080e7          	jalr	-314(ra) # 800019d0 <myproc>
    80004b12:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	0c0080e7          	jalr	192(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1e:	2184a703          	lw	a4,536(s1)
    80004b22:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b26:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b2a:	02f71763          	bne	a4,a5,80004b58 <piperead+0x68>
    80004b2e:	2244a783          	lw	a5,548(s1)
    80004b32:	c39d                	beqz	a5,80004b58 <piperead+0x68>
    if(killed(pr)){
    80004b34:	8552                	mv	a0,s4
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	896080e7          	jalr	-1898(ra) # 800023cc <killed>
    80004b3e:	e949                	bnez	a0,80004bd0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b40:	85a6                	mv	a1,s1
    80004b42:	854e                	mv	a0,s3
    80004b44:	ffffd097          	auipc	ra,0xffffd
    80004b48:	5e0080e7          	jalr	1504(ra) # 80002124 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4c:	2184a703          	lw	a4,536(s1)
    80004b50:	21c4a783          	lw	a5,540(s1)
    80004b54:	fcf70de3          	beq	a4,a5,80004b2e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b58:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b5a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b5c:	05505463          	blez	s5,80004ba4 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b60:	2184a783          	lw	a5,536(s1)
    80004b64:	21c4a703          	lw	a4,540(s1)
    80004b68:	02f70e63          	beq	a4,a5,80004ba4 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b6c:	0017871b          	addiw	a4,a5,1
    80004b70:	20e4ac23          	sw	a4,536(s1)
    80004b74:	1ff7f793          	andi	a5,a5,511
    80004b78:	97a6                	add	a5,a5,s1
    80004b7a:	0187c783          	lbu	a5,24(a5)
    80004b7e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b82:	4685                	li	a3,1
    80004b84:	fbf40613          	addi	a2,s0,-65
    80004b88:	85ca                	mv	a1,s2
    80004b8a:	050a3503          	ld	a0,80(s4)
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	afe080e7          	jalr	-1282(ra) # 8000168c <copyout>
    80004b96:	01650763          	beq	a0,s6,80004ba4 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b9a:	2985                	addiw	s3,s3,1
    80004b9c:	0905                	addi	s2,s2,1
    80004b9e:	fd3a91e3          	bne	s5,s3,80004b60 <piperead+0x70>
    80004ba2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ba4:	21c48513          	addi	a0,s1,540
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	5e0080e7          	jalr	1504(ra) # 80002188 <wakeup>
  release(&pi->lock);
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	0d8080e7          	jalr	216(ra) # 80000c8a <release>
  return i;
}
    80004bba:	854e                	mv	a0,s3
    80004bbc:	60a6                	ld	ra,72(sp)
    80004bbe:	6406                	ld	s0,64(sp)
    80004bc0:	74e2                	ld	s1,56(sp)
    80004bc2:	7942                	ld	s2,48(sp)
    80004bc4:	79a2                	ld	s3,40(sp)
    80004bc6:	7a02                	ld	s4,32(sp)
    80004bc8:	6ae2                	ld	s5,24(sp)
    80004bca:	6b42                	ld	s6,16(sp)
    80004bcc:	6161                	addi	sp,sp,80
    80004bce:	8082                	ret
      release(&pi->lock);
    80004bd0:	8526                	mv	a0,s1
    80004bd2:	ffffc097          	auipc	ra,0xffffc
    80004bd6:	0b8080e7          	jalr	184(ra) # 80000c8a <release>
      return -1;
    80004bda:	59fd                	li	s3,-1
    80004bdc:	bff9                	j	80004bba <piperead+0xca>

0000000080004bde <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004bde:	1141                	addi	sp,sp,-16
    80004be0:	e422                	sd	s0,8(sp)
    80004be2:	0800                	addi	s0,sp,16
    80004be4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004be6:	8905                	andi	a0,a0,1
    80004be8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bea:	8b89                	andi	a5,a5,2
    80004bec:	c399                	beqz	a5,80004bf2 <flags2perm+0x14>
      perm |= PTE_W;
    80004bee:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bf2:	6422                	ld	s0,8(sp)
    80004bf4:	0141                	addi	sp,sp,16
    80004bf6:	8082                	ret

0000000080004bf8 <exec>:

int
exec(char *path, char **argv)
{
    80004bf8:	de010113          	addi	sp,sp,-544
    80004bfc:	20113c23          	sd	ra,536(sp)
    80004c00:	20813823          	sd	s0,528(sp)
    80004c04:	20913423          	sd	s1,520(sp)
    80004c08:	21213023          	sd	s2,512(sp)
    80004c0c:	ffce                	sd	s3,504(sp)
    80004c0e:	fbd2                	sd	s4,496(sp)
    80004c10:	f7d6                	sd	s5,488(sp)
    80004c12:	f3da                	sd	s6,480(sp)
    80004c14:	efde                	sd	s7,472(sp)
    80004c16:	ebe2                	sd	s8,464(sp)
    80004c18:	e7e6                	sd	s9,456(sp)
    80004c1a:	e3ea                	sd	s10,448(sp)
    80004c1c:	ff6e                	sd	s11,440(sp)
    80004c1e:	1400                	addi	s0,sp,544
    80004c20:	892a                	mv	s2,a0
    80004c22:	dea43423          	sd	a0,-536(s0)
    80004c26:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c2a:	ffffd097          	auipc	ra,0xffffd
    80004c2e:	da6080e7          	jalr	-602(ra) # 800019d0 <myproc>
    80004c32:	84aa                	mv	s1,a0

  begin_op();
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	482080e7          	jalr	1154(ra) # 800040b6 <begin_op>

  if((ip = namei(path)) == 0){
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	fffff097          	auipc	ra,0xfffff
    80004c42:	258080e7          	jalr	600(ra) # 80003e96 <namei>
    80004c46:	c93d                	beqz	a0,80004cbc <exec+0xc4>
    80004c48:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	aa0080e7          	jalr	-1376(ra) # 800036ea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c52:	04000713          	li	a4,64
    80004c56:	4681                	li	a3,0
    80004c58:	e5040613          	addi	a2,s0,-432
    80004c5c:	4581                	li	a1,0
    80004c5e:	8556                	mv	a0,s5
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	d3e080e7          	jalr	-706(ra) # 8000399e <readi>
    80004c68:	04000793          	li	a5,64
    80004c6c:	00f51a63          	bne	a0,a5,80004c80 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c70:	e5042703          	lw	a4,-432(s0)
    80004c74:	464c47b7          	lui	a5,0x464c4
    80004c78:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c7c:	04f70663          	beq	a4,a5,80004cc8 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c80:	8556                	mv	a0,s5
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	cca080e7          	jalr	-822(ra) # 8000394c <iunlockput>
    end_op();
    80004c8a:	fffff097          	auipc	ra,0xfffff
    80004c8e:	4aa080e7          	jalr	1194(ra) # 80004134 <end_op>
  }
  return -1;
    80004c92:	557d                	li	a0,-1
}
    80004c94:	21813083          	ld	ra,536(sp)
    80004c98:	21013403          	ld	s0,528(sp)
    80004c9c:	20813483          	ld	s1,520(sp)
    80004ca0:	20013903          	ld	s2,512(sp)
    80004ca4:	79fe                	ld	s3,504(sp)
    80004ca6:	7a5e                	ld	s4,496(sp)
    80004ca8:	7abe                	ld	s5,488(sp)
    80004caa:	7b1e                	ld	s6,480(sp)
    80004cac:	6bfe                	ld	s7,472(sp)
    80004cae:	6c5e                	ld	s8,464(sp)
    80004cb0:	6cbe                	ld	s9,456(sp)
    80004cb2:	6d1e                	ld	s10,448(sp)
    80004cb4:	7dfa                	ld	s11,440(sp)
    80004cb6:	22010113          	addi	sp,sp,544
    80004cba:	8082                	ret
    end_op();
    80004cbc:	fffff097          	auipc	ra,0xfffff
    80004cc0:	478080e7          	jalr	1144(ra) # 80004134 <end_op>
    return -1;
    80004cc4:	557d                	li	a0,-1
    80004cc6:	b7f9                	j	80004c94 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffd097          	auipc	ra,0xffffd
    80004cce:	dca080e7          	jalr	-566(ra) # 80001a94 <proc_pagetable>
    80004cd2:	8b2a                	mv	s6,a0
    80004cd4:	d555                	beqz	a0,80004c80 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cd6:	e7042783          	lw	a5,-400(s0)
    80004cda:	e8845703          	lhu	a4,-376(s0)
    80004cde:	c735                	beqz	a4,80004d4a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ce0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ce2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004ce6:	6a05                	lui	s4,0x1
    80004ce8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cec:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cf0:	6d85                	lui	s11,0x1
    80004cf2:	7d7d                	lui	s10,0xfffff
    80004cf4:	ac3d                	j	80004f32 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cf6:	00004517          	auipc	a0,0x4
    80004cfa:	a2250513          	addi	a0,a0,-1502 # 80008718 <syscalls+0x280>
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	842080e7          	jalr	-1982(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d06:	874a                	mv	a4,s2
    80004d08:	009c86bb          	addw	a3,s9,s1
    80004d0c:	4581                	li	a1,0
    80004d0e:	8556                	mv	a0,s5
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	c8e080e7          	jalr	-882(ra) # 8000399e <readi>
    80004d18:	2501                	sext.w	a0,a0
    80004d1a:	1aa91963          	bne	s2,a0,80004ecc <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004d1e:	009d84bb          	addw	s1,s11,s1
    80004d22:	013d09bb          	addw	s3,s10,s3
    80004d26:	1f74f663          	bgeu	s1,s7,80004f12 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004d2a:	02049593          	slli	a1,s1,0x20
    80004d2e:	9181                	srli	a1,a1,0x20
    80004d30:	95e2                	add	a1,a1,s8
    80004d32:	855a                	mv	a0,s6
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	348080e7          	jalr	840(ra) # 8000107c <walkaddr>
    80004d3c:	862a                	mv	a2,a0
    if(pa == 0)
    80004d3e:	dd45                	beqz	a0,80004cf6 <exec+0xfe>
      n = PGSIZE;
    80004d40:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d42:	fd49f2e3          	bgeu	s3,s4,80004d06 <exec+0x10e>
      n = sz - i;
    80004d46:	894e                	mv	s2,s3
    80004d48:	bf7d                	j	80004d06 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d4a:	4901                	li	s2,0
  iunlockput(ip);
    80004d4c:	8556                	mv	a0,s5
    80004d4e:	fffff097          	auipc	ra,0xfffff
    80004d52:	bfe080e7          	jalr	-1026(ra) # 8000394c <iunlockput>
  end_op();
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	3de080e7          	jalr	990(ra) # 80004134 <end_op>
  p = myproc();
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	c72080e7          	jalr	-910(ra) # 800019d0 <myproc>
    80004d66:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d68:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d6c:	6785                	lui	a5,0x1
    80004d6e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d70:	97ca                	add	a5,a5,s2
    80004d72:	777d                	lui	a4,0xfffff
    80004d74:	8ff9                	and	a5,a5,a4
    80004d76:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d7a:	4691                	li	a3,4
    80004d7c:	6609                	lui	a2,0x2
    80004d7e:	963e                	add	a2,a2,a5
    80004d80:	85be                	mv	a1,a5
    80004d82:	855a                	mv	a0,s6
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	6ac080e7          	jalr	1708(ra) # 80001430 <uvmalloc>
    80004d8c:	8c2a                	mv	s8,a0
  ip = 0;
    80004d8e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d90:	12050e63          	beqz	a0,80004ecc <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d94:	75f9                	lui	a1,0xffffe
    80004d96:	95aa                	add	a1,a1,a0
    80004d98:	855a                	mv	a0,s6
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	8c0080e7          	jalr	-1856(ra) # 8000165a <uvmclear>
  stackbase = sp - PGSIZE;
    80004da2:	7afd                	lui	s5,0xfffff
    80004da4:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004da6:	df043783          	ld	a5,-528(s0)
    80004daa:	6388                	ld	a0,0(a5)
    80004dac:	c925                	beqz	a0,80004e1c <exec+0x224>
    80004dae:	e9040993          	addi	s3,s0,-368
    80004db2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004db6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004db8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dba:	ffffc097          	auipc	ra,0xffffc
    80004dbe:	094080e7          	jalr	148(ra) # 80000e4e <strlen>
    80004dc2:	0015079b          	addiw	a5,a0,1
    80004dc6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dca:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dce:	13596663          	bltu	s2,s5,80004efa <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dd2:	df043d83          	ld	s11,-528(s0)
    80004dd6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dda:	8552                	mv	a0,s4
    80004ddc:	ffffc097          	auipc	ra,0xffffc
    80004de0:	072080e7          	jalr	114(ra) # 80000e4e <strlen>
    80004de4:	0015069b          	addiw	a3,a0,1
    80004de8:	8652                	mv	a2,s4
    80004dea:	85ca                	mv	a1,s2
    80004dec:	855a                	mv	a0,s6
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	89e080e7          	jalr	-1890(ra) # 8000168c <copyout>
    80004df6:	10054663          	bltz	a0,80004f02 <exec+0x30a>
    ustack[argc] = sp;
    80004dfa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dfe:	0485                	addi	s1,s1,1
    80004e00:	008d8793          	addi	a5,s11,8
    80004e04:	def43823          	sd	a5,-528(s0)
    80004e08:	008db503          	ld	a0,8(s11)
    80004e0c:	c911                	beqz	a0,80004e20 <exec+0x228>
    if(argc >= MAXARG)
    80004e0e:	09a1                	addi	s3,s3,8
    80004e10:	fb3c95e3          	bne	s9,s3,80004dba <exec+0x1c2>
  sz = sz1;
    80004e14:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e18:	4a81                	li	s5,0
    80004e1a:	a84d                	j	80004ecc <exec+0x2d4>
  sp = sz;
    80004e1c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e1e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e20:	00349793          	slli	a5,s1,0x3
    80004e24:	f9078793          	addi	a5,a5,-112
    80004e28:	97a2                	add	a5,a5,s0
    80004e2a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e2e:	00148693          	addi	a3,s1,1
    80004e32:	068e                	slli	a3,a3,0x3
    80004e34:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e38:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e3c:	01597663          	bgeu	s2,s5,80004e48 <exec+0x250>
  sz = sz1;
    80004e40:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e44:	4a81                	li	s5,0
    80004e46:	a059                	j	80004ecc <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e48:	e9040613          	addi	a2,s0,-368
    80004e4c:	85ca                	mv	a1,s2
    80004e4e:	855a                	mv	a0,s6
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	83c080e7          	jalr	-1988(ra) # 8000168c <copyout>
    80004e58:	0a054963          	bltz	a0,80004f0a <exec+0x312>
  p->trapframe->a1 = sp;
    80004e5c:	058bb783          	ld	a5,88(s7)
    80004e60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e64:	de843783          	ld	a5,-536(s0)
    80004e68:	0007c703          	lbu	a4,0(a5)
    80004e6c:	cf11                	beqz	a4,80004e88 <exec+0x290>
    80004e6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e70:	02f00693          	li	a3,47
    80004e74:	a039                	j	80004e82 <exec+0x28a>
      last = s+1;
    80004e76:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e7a:	0785                	addi	a5,a5,1
    80004e7c:	fff7c703          	lbu	a4,-1(a5)
    80004e80:	c701                	beqz	a4,80004e88 <exec+0x290>
    if(*s == '/')
    80004e82:	fed71ce3          	bne	a4,a3,80004e7a <exec+0x282>
    80004e86:	bfc5                	j	80004e76 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e88:	4641                	li	a2,16
    80004e8a:	de843583          	ld	a1,-536(s0)
    80004e8e:	158b8513          	addi	a0,s7,344
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	f8a080e7          	jalr	-118(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e9a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e9e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004ea2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ea6:	058bb783          	ld	a5,88(s7)
    80004eaa:	e6843703          	ld	a4,-408(s0)
    80004eae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb0:	058bb783          	ld	a5,88(s7)
    80004eb4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb8:	85ea                	mv	a1,s10
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	c76080e7          	jalr	-906(ra) # 80001b30 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ec2:	0004851b          	sext.w	a0,s1
    80004ec6:	b3f9                	j	80004c94 <exec+0x9c>
    80004ec8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ecc:	df843583          	ld	a1,-520(s0)
    80004ed0:	855a                	mv	a0,s6
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	c5e080e7          	jalr	-930(ra) # 80001b30 <proc_freepagetable>
  if(ip){
    80004eda:	da0a93e3          	bnez	s5,80004c80 <exec+0x88>
  return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bb55                	j	80004c94 <exec+0x9c>
    80004ee2:	df243c23          	sd	s2,-520(s0)
    80004ee6:	b7dd                	j	80004ecc <exec+0x2d4>
    80004ee8:	df243c23          	sd	s2,-520(s0)
    80004eec:	b7c5                	j	80004ecc <exec+0x2d4>
    80004eee:	df243c23          	sd	s2,-520(s0)
    80004ef2:	bfe9                	j	80004ecc <exec+0x2d4>
    80004ef4:	df243c23          	sd	s2,-520(s0)
    80004ef8:	bfd1                	j	80004ecc <exec+0x2d4>
  sz = sz1;
    80004efa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004efe:	4a81                	li	s5,0
    80004f00:	b7f1                	j	80004ecc <exec+0x2d4>
  sz = sz1;
    80004f02:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f06:	4a81                	li	s5,0
    80004f08:	b7d1                	j	80004ecc <exec+0x2d4>
  sz = sz1;
    80004f0a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f0e:	4a81                	li	s5,0
    80004f10:	bf75                	j	80004ecc <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f12:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f16:	e0843783          	ld	a5,-504(s0)
    80004f1a:	0017869b          	addiw	a3,a5,1
    80004f1e:	e0d43423          	sd	a3,-504(s0)
    80004f22:	e0043783          	ld	a5,-512(s0)
    80004f26:	0387879b          	addiw	a5,a5,56
    80004f2a:	e8845703          	lhu	a4,-376(s0)
    80004f2e:	e0e6dfe3          	bge	a3,a4,80004d4c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f32:	2781                	sext.w	a5,a5
    80004f34:	e0f43023          	sd	a5,-512(s0)
    80004f38:	03800713          	li	a4,56
    80004f3c:	86be                	mv	a3,a5
    80004f3e:	e1840613          	addi	a2,s0,-488
    80004f42:	4581                	li	a1,0
    80004f44:	8556                	mv	a0,s5
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	a58080e7          	jalr	-1448(ra) # 8000399e <readi>
    80004f4e:	03800793          	li	a5,56
    80004f52:	f6f51be3          	bne	a0,a5,80004ec8 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004f56:	e1842783          	lw	a5,-488(s0)
    80004f5a:	4705                	li	a4,1
    80004f5c:	fae79de3          	bne	a5,a4,80004f16 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004f60:	e4043483          	ld	s1,-448(s0)
    80004f64:	e3843783          	ld	a5,-456(s0)
    80004f68:	f6f4ede3          	bltu	s1,a5,80004ee2 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f6c:	e2843783          	ld	a5,-472(s0)
    80004f70:	94be                	add	s1,s1,a5
    80004f72:	f6f4ebe3          	bltu	s1,a5,80004ee8 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004f76:	de043703          	ld	a4,-544(s0)
    80004f7a:	8ff9                	and	a5,a5,a4
    80004f7c:	fbad                	bnez	a5,80004eee <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f7e:	e1c42503          	lw	a0,-484(s0)
    80004f82:	00000097          	auipc	ra,0x0
    80004f86:	c5c080e7          	jalr	-932(ra) # 80004bde <flags2perm>
    80004f8a:	86aa                	mv	a3,a0
    80004f8c:	8626                	mv	a2,s1
    80004f8e:	85ca                	mv	a1,s2
    80004f90:	855a                	mv	a0,s6
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	49e080e7          	jalr	1182(ra) # 80001430 <uvmalloc>
    80004f9a:	dea43c23          	sd	a0,-520(s0)
    80004f9e:	d939                	beqz	a0,80004ef4 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fa0:	e2843c03          	ld	s8,-472(s0)
    80004fa4:	e2042c83          	lw	s9,-480(s0)
    80004fa8:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fac:	f60b83e3          	beqz	s7,80004f12 <exec+0x31a>
    80004fb0:	89de                	mv	s3,s7
    80004fb2:	4481                	li	s1,0
    80004fb4:	bb9d                	j	80004d2a <exec+0x132>

0000000080004fb6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fb6:	7179                	addi	sp,sp,-48
    80004fb8:	f406                	sd	ra,40(sp)
    80004fba:	f022                	sd	s0,32(sp)
    80004fbc:	ec26                	sd	s1,24(sp)
    80004fbe:	e84a                	sd	s2,16(sp)
    80004fc0:	1800                	addi	s0,sp,48
    80004fc2:	892e                	mv	s2,a1
    80004fc4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fc6:	fdc40593          	addi	a1,s0,-36
    80004fca:	ffffe097          	auipc	ra,0xffffe
    80004fce:	bb6080e7          	jalr	-1098(ra) # 80002b80 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fd2:	fdc42703          	lw	a4,-36(s0)
    80004fd6:	47bd                	li	a5,15
    80004fd8:	02e7eb63          	bltu	a5,a4,8000500e <argfd+0x58>
    80004fdc:	ffffd097          	auipc	ra,0xffffd
    80004fe0:	9f4080e7          	jalr	-1548(ra) # 800019d0 <myproc>
    80004fe4:	fdc42703          	lw	a4,-36(s0)
    80004fe8:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd06a>
    80004fec:	078e                	slli	a5,a5,0x3
    80004fee:	953e                	add	a0,a0,a5
    80004ff0:	611c                	ld	a5,0(a0)
    80004ff2:	c385                	beqz	a5,80005012 <argfd+0x5c>
    return -1;
  if(pfd)
    80004ff4:	00090463          	beqz	s2,80004ffc <argfd+0x46>
    *pfd = fd;
    80004ff8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ffc:	4501                	li	a0,0
  if(pf)
    80004ffe:	c091                	beqz	s1,80005002 <argfd+0x4c>
    *pf = f;
    80005000:	e09c                	sd	a5,0(s1)
}
    80005002:	70a2                	ld	ra,40(sp)
    80005004:	7402                	ld	s0,32(sp)
    80005006:	64e2                	ld	s1,24(sp)
    80005008:	6942                	ld	s2,16(sp)
    8000500a:	6145                	addi	sp,sp,48
    8000500c:	8082                	ret
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	bfcd                	j	80005002 <argfd+0x4c>
    80005012:	557d                	li	a0,-1
    80005014:	b7fd                	j	80005002 <argfd+0x4c>

0000000080005016 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005016:	1101                	addi	sp,sp,-32
    80005018:	ec06                	sd	ra,24(sp)
    8000501a:	e822                	sd	s0,16(sp)
    8000501c:	e426                	sd	s1,8(sp)
    8000501e:	1000                	addi	s0,sp,32
    80005020:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005022:	ffffd097          	auipc	ra,0xffffd
    80005026:	9ae080e7          	jalr	-1618(ra) # 800019d0 <myproc>
    8000502a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000502c:	0d050793          	addi	a5,a0,208
    80005030:	4501                	li	a0,0
    80005032:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005034:	6398                	ld	a4,0(a5)
    80005036:	cb19                	beqz	a4,8000504c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005038:	2505                	addiw	a0,a0,1
    8000503a:	07a1                	addi	a5,a5,8
    8000503c:	fed51ce3          	bne	a0,a3,80005034 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005040:	557d                	li	a0,-1
}
    80005042:	60e2                	ld	ra,24(sp)
    80005044:	6442                	ld	s0,16(sp)
    80005046:	64a2                	ld	s1,8(sp)
    80005048:	6105                	addi	sp,sp,32
    8000504a:	8082                	ret
      p->ofile[fd] = f;
    8000504c:	01a50793          	addi	a5,a0,26
    80005050:	078e                	slli	a5,a5,0x3
    80005052:	963e                	add	a2,a2,a5
    80005054:	e204                	sd	s1,0(a2)
      return fd;
    80005056:	b7f5                	j	80005042 <fdalloc+0x2c>

0000000080005058 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005058:	715d                	addi	sp,sp,-80
    8000505a:	e486                	sd	ra,72(sp)
    8000505c:	e0a2                	sd	s0,64(sp)
    8000505e:	fc26                	sd	s1,56(sp)
    80005060:	f84a                	sd	s2,48(sp)
    80005062:	f44e                	sd	s3,40(sp)
    80005064:	f052                	sd	s4,32(sp)
    80005066:	ec56                	sd	s5,24(sp)
    80005068:	e85a                	sd	s6,16(sp)
    8000506a:	0880                	addi	s0,sp,80
    8000506c:	8b2e                	mv	s6,a1
    8000506e:	89b2                	mv	s3,a2
    80005070:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005072:	fb040593          	addi	a1,s0,-80
    80005076:	fffff097          	auipc	ra,0xfffff
    8000507a:	e3e080e7          	jalr	-450(ra) # 80003eb4 <nameiparent>
    8000507e:	84aa                	mv	s1,a0
    80005080:	14050f63          	beqz	a0,800051de <create+0x186>
    return 0;

  ilock(dp);
    80005084:	ffffe097          	auipc	ra,0xffffe
    80005088:	666080e7          	jalr	1638(ra) # 800036ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000508c:	4601                	li	a2,0
    8000508e:	fb040593          	addi	a1,s0,-80
    80005092:	8526                	mv	a0,s1
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	b3a080e7          	jalr	-1222(ra) # 80003bce <dirlookup>
    8000509c:	8aaa                	mv	s5,a0
    8000509e:	c931                	beqz	a0,800050f2 <create+0x9a>
    iunlockput(dp);
    800050a0:	8526                	mv	a0,s1
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	8aa080e7          	jalr	-1878(ra) # 8000394c <iunlockput>
    ilock(ip);
    800050aa:	8556                	mv	a0,s5
    800050ac:	ffffe097          	auipc	ra,0xffffe
    800050b0:	63e080e7          	jalr	1598(ra) # 800036ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050b4:	000b059b          	sext.w	a1,s6
    800050b8:	4789                	li	a5,2
    800050ba:	02f59563          	bne	a1,a5,800050e4 <create+0x8c>
    800050be:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd094>
    800050c2:	37f9                	addiw	a5,a5,-2
    800050c4:	17c2                	slli	a5,a5,0x30
    800050c6:	93c1                	srli	a5,a5,0x30
    800050c8:	4705                	li	a4,1
    800050ca:	00f76d63          	bltu	a4,a5,800050e4 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050ce:	8556                	mv	a0,s5
    800050d0:	60a6                	ld	ra,72(sp)
    800050d2:	6406                	ld	s0,64(sp)
    800050d4:	74e2                	ld	s1,56(sp)
    800050d6:	7942                	ld	s2,48(sp)
    800050d8:	79a2                	ld	s3,40(sp)
    800050da:	7a02                	ld	s4,32(sp)
    800050dc:	6ae2                	ld	s5,24(sp)
    800050de:	6b42                	ld	s6,16(sp)
    800050e0:	6161                	addi	sp,sp,80
    800050e2:	8082                	ret
    iunlockput(ip);
    800050e4:	8556                	mv	a0,s5
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	866080e7          	jalr	-1946(ra) # 8000394c <iunlockput>
    return 0;
    800050ee:	4a81                	li	s5,0
    800050f0:	bff9                	j	800050ce <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050f2:	85da                	mv	a1,s6
    800050f4:	4088                	lw	a0,0(s1)
    800050f6:	ffffe097          	auipc	ra,0xffffe
    800050fa:	456080e7          	jalr	1110(ra) # 8000354c <ialloc>
    800050fe:	8a2a                	mv	s4,a0
    80005100:	c539                	beqz	a0,8000514e <create+0xf6>
  ilock(ip);
    80005102:	ffffe097          	auipc	ra,0xffffe
    80005106:	5e8080e7          	jalr	1512(ra) # 800036ea <ilock>
  ip->major = major;
    8000510a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000510e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005112:	4905                	li	s2,1
    80005114:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005118:	8552                	mv	a0,s4
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	504080e7          	jalr	1284(ra) # 8000361e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005122:	000b059b          	sext.w	a1,s6
    80005126:	03258b63          	beq	a1,s2,8000515c <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000512a:	004a2603          	lw	a2,4(s4)
    8000512e:	fb040593          	addi	a1,s0,-80
    80005132:	8526                	mv	a0,s1
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	cb0080e7          	jalr	-848(ra) # 80003de4 <dirlink>
    8000513c:	06054f63          	bltz	a0,800051ba <create+0x162>
  iunlockput(dp);
    80005140:	8526                	mv	a0,s1
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	80a080e7          	jalr	-2038(ra) # 8000394c <iunlockput>
  return ip;
    8000514a:	8ad2                	mv	s5,s4
    8000514c:	b749                	j	800050ce <create+0x76>
    iunlockput(dp);
    8000514e:	8526                	mv	a0,s1
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	7fc080e7          	jalr	2044(ra) # 8000394c <iunlockput>
    return 0;
    80005158:	8ad2                	mv	s5,s4
    8000515a:	bf95                	j	800050ce <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000515c:	004a2603          	lw	a2,4(s4)
    80005160:	00003597          	auipc	a1,0x3
    80005164:	5d858593          	addi	a1,a1,1496 # 80008738 <syscalls+0x2a0>
    80005168:	8552                	mv	a0,s4
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	c7a080e7          	jalr	-902(ra) # 80003de4 <dirlink>
    80005172:	04054463          	bltz	a0,800051ba <create+0x162>
    80005176:	40d0                	lw	a2,4(s1)
    80005178:	00003597          	auipc	a1,0x3
    8000517c:	5c858593          	addi	a1,a1,1480 # 80008740 <syscalls+0x2a8>
    80005180:	8552                	mv	a0,s4
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	c62080e7          	jalr	-926(ra) # 80003de4 <dirlink>
    8000518a:	02054863          	bltz	a0,800051ba <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000518e:	004a2603          	lw	a2,4(s4)
    80005192:	fb040593          	addi	a1,s0,-80
    80005196:	8526                	mv	a0,s1
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	c4c080e7          	jalr	-948(ra) # 80003de4 <dirlink>
    800051a0:	00054d63          	bltz	a0,800051ba <create+0x162>
    dp->nlink++;  // for ".."
    800051a4:	04a4d783          	lhu	a5,74(s1)
    800051a8:	2785                	addiw	a5,a5,1
    800051aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051ae:	8526                	mv	a0,s1
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	46e080e7          	jalr	1134(ra) # 8000361e <iupdate>
    800051b8:	b761                	j	80005140 <create+0xe8>
  ip->nlink = 0;
    800051ba:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051be:	8552                	mv	a0,s4
    800051c0:	ffffe097          	auipc	ra,0xffffe
    800051c4:	45e080e7          	jalr	1118(ra) # 8000361e <iupdate>
  iunlockput(ip);
    800051c8:	8552                	mv	a0,s4
    800051ca:	ffffe097          	auipc	ra,0xffffe
    800051ce:	782080e7          	jalr	1922(ra) # 8000394c <iunlockput>
  iunlockput(dp);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffe097          	auipc	ra,0xffffe
    800051d8:	778080e7          	jalr	1912(ra) # 8000394c <iunlockput>
  return 0;
    800051dc:	bdcd                	j	800050ce <create+0x76>
    return 0;
    800051de:	8aaa                	mv	s5,a0
    800051e0:	b5fd                	j	800050ce <create+0x76>

00000000800051e2 <sys_dup>:
{
    800051e2:	7179                	addi	sp,sp,-48
    800051e4:	f406                	sd	ra,40(sp)
    800051e6:	f022                	sd	s0,32(sp)
    800051e8:	ec26                	sd	s1,24(sp)
    800051ea:	e84a                	sd	s2,16(sp)
    800051ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051ee:	fd840613          	addi	a2,s0,-40
    800051f2:	4581                	li	a1,0
    800051f4:	4501                	li	a0,0
    800051f6:	00000097          	auipc	ra,0x0
    800051fa:	dc0080e7          	jalr	-576(ra) # 80004fb6 <argfd>
    return -1;
    800051fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005200:	02054363          	bltz	a0,80005226 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005204:	fd843903          	ld	s2,-40(s0)
    80005208:	854a                	mv	a0,s2
    8000520a:	00000097          	auipc	ra,0x0
    8000520e:	e0c080e7          	jalr	-500(ra) # 80005016 <fdalloc>
    80005212:	84aa                	mv	s1,a0
    return -1;
    80005214:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005216:	00054863          	bltz	a0,80005226 <sys_dup+0x44>
  filedup(f);
    8000521a:	854a                	mv	a0,s2
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	310080e7          	jalr	784(ra) # 8000452c <filedup>
  return fd;
    80005224:	87a6                	mv	a5,s1
}
    80005226:	853e                	mv	a0,a5
    80005228:	70a2                	ld	ra,40(sp)
    8000522a:	7402                	ld	s0,32(sp)
    8000522c:	64e2                	ld	s1,24(sp)
    8000522e:	6942                	ld	s2,16(sp)
    80005230:	6145                	addi	sp,sp,48
    80005232:	8082                	ret

0000000080005234 <sys_read>:
{
    80005234:	7179                	addi	sp,sp,-48
    80005236:	f406                	sd	ra,40(sp)
    80005238:	f022                	sd	s0,32(sp)
    8000523a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000523c:	fd840593          	addi	a1,s0,-40
    80005240:	4505                	li	a0,1
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	95e080e7          	jalr	-1698(ra) # 80002ba0 <argaddr>
  argint(2, &n);
    8000524a:	fe440593          	addi	a1,s0,-28
    8000524e:	4509                	li	a0,2
    80005250:	ffffe097          	auipc	ra,0xffffe
    80005254:	930080e7          	jalr	-1744(ra) # 80002b80 <argint>
  if(argfd(0, 0, &f) < 0)
    80005258:	fe840613          	addi	a2,s0,-24
    8000525c:	4581                	li	a1,0
    8000525e:	4501                	li	a0,0
    80005260:	00000097          	auipc	ra,0x0
    80005264:	d56080e7          	jalr	-682(ra) # 80004fb6 <argfd>
    80005268:	87aa                	mv	a5,a0
    return -1;
    8000526a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000526c:	0007cc63          	bltz	a5,80005284 <sys_read+0x50>
  return fileread(f, p, n);
    80005270:	fe442603          	lw	a2,-28(s0)
    80005274:	fd843583          	ld	a1,-40(s0)
    80005278:	fe843503          	ld	a0,-24(s0)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	43c080e7          	jalr	1084(ra) # 800046b8 <fileread>
}
    80005284:	70a2                	ld	ra,40(sp)
    80005286:	7402                	ld	s0,32(sp)
    80005288:	6145                	addi	sp,sp,48
    8000528a:	8082                	ret

000000008000528c <sys_write>:
{
    8000528c:	7179                	addi	sp,sp,-48
    8000528e:	f406                	sd	ra,40(sp)
    80005290:	f022                	sd	s0,32(sp)
    80005292:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005294:	fd840593          	addi	a1,s0,-40
    80005298:	4505                	li	a0,1
    8000529a:	ffffe097          	auipc	ra,0xffffe
    8000529e:	906080e7          	jalr	-1786(ra) # 80002ba0 <argaddr>
  argint(2, &n);
    800052a2:	fe440593          	addi	a1,s0,-28
    800052a6:	4509                	li	a0,2
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	8d8080e7          	jalr	-1832(ra) # 80002b80 <argint>
  if(argfd(0, 0, &f) < 0)
    800052b0:	fe840613          	addi	a2,s0,-24
    800052b4:	4581                	li	a1,0
    800052b6:	4501                	li	a0,0
    800052b8:	00000097          	auipc	ra,0x0
    800052bc:	cfe080e7          	jalr	-770(ra) # 80004fb6 <argfd>
    800052c0:	87aa                	mv	a5,a0
    return -1;
    800052c2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c4:	0007cc63          	bltz	a5,800052dc <sys_write+0x50>
  return filewrite(f, p, n);
    800052c8:	fe442603          	lw	a2,-28(s0)
    800052cc:	fd843583          	ld	a1,-40(s0)
    800052d0:	fe843503          	ld	a0,-24(s0)
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	4a6080e7          	jalr	1190(ra) # 8000477a <filewrite>
}
    800052dc:	70a2                	ld	ra,40(sp)
    800052de:	7402                	ld	s0,32(sp)
    800052e0:	6145                	addi	sp,sp,48
    800052e2:	8082                	ret

00000000800052e4 <sys_close>:
{
    800052e4:	1101                	addi	sp,sp,-32
    800052e6:	ec06                	sd	ra,24(sp)
    800052e8:	e822                	sd	s0,16(sp)
    800052ea:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052ec:	fe040613          	addi	a2,s0,-32
    800052f0:	fec40593          	addi	a1,s0,-20
    800052f4:	4501                	li	a0,0
    800052f6:	00000097          	auipc	ra,0x0
    800052fa:	cc0080e7          	jalr	-832(ra) # 80004fb6 <argfd>
    return -1;
    800052fe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005300:	02054463          	bltz	a0,80005328 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	6cc080e7          	jalr	1740(ra) # 800019d0 <myproc>
    8000530c:	fec42783          	lw	a5,-20(s0)
    80005310:	07e9                	addi	a5,a5,26
    80005312:	078e                	slli	a5,a5,0x3
    80005314:	953e                	add	a0,a0,a5
    80005316:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000531a:	fe043503          	ld	a0,-32(s0)
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	260080e7          	jalr	608(ra) # 8000457e <fileclose>
  return 0;
    80005326:	4781                	li	a5,0
}
    80005328:	853e                	mv	a0,a5
    8000532a:	60e2                	ld	ra,24(sp)
    8000532c:	6442                	ld	s0,16(sp)
    8000532e:	6105                	addi	sp,sp,32
    80005330:	8082                	ret

0000000080005332 <sys_fstat>:
{
    80005332:	1101                	addi	sp,sp,-32
    80005334:	ec06                	sd	ra,24(sp)
    80005336:	e822                	sd	s0,16(sp)
    80005338:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000533a:	fe040593          	addi	a1,s0,-32
    8000533e:	4505                	li	a0,1
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	860080e7          	jalr	-1952(ra) # 80002ba0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005348:	fe840613          	addi	a2,s0,-24
    8000534c:	4581                	li	a1,0
    8000534e:	4501                	li	a0,0
    80005350:	00000097          	auipc	ra,0x0
    80005354:	c66080e7          	jalr	-922(ra) # 80004fb6 <argfd>
    80005358:	87aa                	mv	a5,a0
    return -1;
    8000535a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000535c:	0007ca63          	bltz	a5,80005370 <sys_fstat+0x3e>
  return filestat(f, st);
    80005360:	fe043583          	ld	a1,-32(s0)
    80005364:	fe843503          	ld	a0,-24(s0)
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	2de080e7          	jalr	734(ra) # 80004646 <filestat>
}
    80005370:	60e2                	ld	ra,24(sp)
    80005372:	6442                	ld	s0,16(sp)
    80005374:	6105                	addi	sp,sp,32
    80005376:	8082                	ret

0000000080005378 <sys_link>:
{
    80005378:	7169                	addi	sp,sp,-304
    8000537a:	f606                	sd	ra,296(sp)
    8000537c:	f222                	sd	s0,288(sp)
    8000537e:	ee26                	sd	s1,280(sp)
    80005380:	ea4a                	sd	s2,272(sp)
    80005382:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005384:	08000613          	li	a2,128
    80005388:	ed040593          	addi	a1,s0,-304
    8000538c:	4501                	li	a0,0
    8000538e:	ffffe097          	auipc	ra,0xffffe
    80005392:	832080e7          	jalr	-1998(ra) # 80002bc0 <argstr>
    return -1;
    80005396:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005398:	10054e63          	bltz	a0,800054b4 <sys_link+0x13c>
    8000539c:	08000613          	li	a2,128
    800053a0:	f5040593          	addi	a1,s0,-176
    800053a4:	4505                	li	a0,1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	81a080e7          	jalr	-2022(ra) # 80002bc0 <argstr>
    return -1;
    800053ae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b0:	10054263          	bltz	a0,800054b4 <sys_link+0x13c>
  begin_op();
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	d02080e7          	jalr	-766(ra) # 800040b6 <begin_op>
  if((ip = namei(old)) == 0){
    800053bc:	ed040513          	addi	a0,s0,-304
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	ad6080e7          	jalr	-1322(ra) # 80003e96 <namei>
    800053c8:	84aa                	mv	s1,a0
    800053ca:	c551                	beqz	a0,80005456 <sys_link+0xde>
  ilock(ip);
    800053cc:	ffffe097          	auipc	ra,0xffffe
    800053d0:	31e080e7          	jalr	798(ra) # 800036ea <ilock>
  if(ip->type == T_DIR){
    800053d4:	04449703          	lh	a4,68(s1)
    800053d8:	4785                	li	a5,1
    800053da:	08f70463          	beq	a4,a5,80005462 <sys_link+0xea>
  ip->nlink++;
    800053de:	04a4d783          	lhu	a5,74(s1)
    800053e2:	2785                	addiw	a5,a5,1
    800053e4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	234080e7          	jalr	564(ra) # 8000361e <iupdate>
  iunlock(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	3b8080e7          	jalr	952(ra) # 800037ac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053fc:	fd040593          	addi	a1,s0,-48
    80005400:	f5040513          	addi	a0,s0,-176
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	ab0080e7          	jalr	-1360(ra) # 80003eb4 <nameiparent>
    8000540c:	892a                	mv	s2,a0
    8000540e:	c935                	beqz	a0,80005482 <sys_link+0x10a>
  ilock(dp);
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	2da080e7          	jalr	730(ra) # 800036ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005418:	00092703          	lw	a4,0(s2)
    8000541c:	409c                	lw	a5,0(s1)
    8000541e:	04f71d63          	bne	a4,a5,80005478 <sys_link+0x100>
    80005422:	40d0                	lw	a2,4(s1)
    80005424:	fd040593          	addi	a1,s0,-48
    80005428:	854a                	mv	a0,s2
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	9ba080e7          	jalr	-1606(ra) # 80003de4 <dirlink>
    80005432:	04054363          	bltz	a0,80005478 <sys_link+0x100>
  iunlockput(dp);
    80005436:	854a                	mv	a0,s2
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	514080e7          	jalr	1300(ra) # 8000394c <iunlockput>
  iput(ip);
    80005440:	8526                	mv	a0,s1
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	462080e7          	jalr	1122(ra) # 800038a4 <iput>
  end_op();
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	cea080e7          	jalr	-790(ra) # 80004134 <end_op>
  return 0;
    80005452:	4781                	li	a5,0
    80005454:	a085                	j	800054b4 <sys_link+0x13c>
    end_op();
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	cde080e7          	jalr	-802(ra) # 80004134 <end_op>
    return -1;
    8000545e:	57fd                	li	a5,-1
    80005460:	a891                	j	800054b4 <sys_link+0x13c>
    iunlockput(ip);
    80005462:	8526                	mv	a0,s1
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	4e8080e7          	jalr	1256(ra) # 8000394c <iunlockput>
    end_op();
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	cc8080e7          	jalr	-824(ra) # 80004134 <end_op>
    return -1;
    80005474:	57fd                	li	a5,-1
    80005476:	a83d                	j	800054b4 <sys_link+0x13c>
    iunlockput(dp);
    80005478:	854a                	mv	a0,s2
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	4d2080e7          	jalr	1234(ra) # 8000394c <iunlockput>
  ilock(ip);
    80005482:	8526                	mv	a0,s1
    80005484:	ffffe097          	auipc	ra,0xffffe
    80005488:	266080e7          	jalr	614(ra) # 800036ea <ilock>
  ip->nlink--;
    8000548c:	04a4d783          	lhu	a5,74(s1)
    80005490:	37fd                	addiw	a5,a5,-1
    80005492:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005496:	8526                	mv	a0,s1
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	186080e7          	jalr	390(ra) # 8000361e <iupdate>
  iunlockput(ip);
    800054a0:	8526                	mv	a0,s1
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	4aa080e7          	jalr	1194(ra) # 8000394c <iunlockput>
  end_op();
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	c8a080e7          	jalr	-886(ra) # 80004134 <end_op>
  return -1;
    800054b2:	57fd                	li	a5,-1
}
    800054b4:	853e                	mv	a0,a5
    800054b6:	70b2                	ld	ra,296(sp)
    800054b8:	7412                	ld	s0,288(sp)
    800054ba:	64f2                	ld	s1,280(sp)
    800054bc:	6952                	ld	s2,272(sp)
    800054be:	6155                	addi	sp,sp,304
    800054c0:	8082                	ret

00000000800054c2 <sys_unlink>:
{
    800054c2:	7151                	addi	sp,sp,-240
    800054c4:	f586                	sd	ra,232(sp)
    800054c6:	f1a2                	sd	s0,224(sp)
    800054c8:	eda6                	sd	s1,216(sp)
    800054ca:	e9ca                	sd	s2,208(sp)
    800054cc:	e5ce                	sd	s3,200(sp)
    800054ce:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054d0:	08000613          	li	a2,128
    800054d4:	f3040593          	addi	a1,s0,-208
    800054d8:	4501                	li	a0,0
    800054da:	ffffd097          	auipc	ra,0xffffd
    800054de:	6e6080e7          	jalr	1766(ra) # 80002bc0 <argstr>
    800054e2:	18054163          	bltz	a0,80005664 <sys_unlink+0x1a2>
  begin_op();
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	bd0080e7          	jalr	-1072(ra) # 800040b6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054ee:	fb040593          	addi	a1,s0,-80
    800054f2:	f3040513          	addi	a0,s0,-208
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	9be080e7          	jalr	-1602(ra) # 80003eb4 <nameiparent>
    800054fe:	84aa                	mv	s1,a0
    80005500:	c979                	beqz	a0,800055d6 <sys_unlink+0x114>
  ilock(dp);
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	1e8080e7          	jalr	488(ra) # 800036ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000550a:	00003597          	auipc	a1,0x3
    8000550e:	22e58593          	addi	a1,a1,558 # 80008738 <syscalls+0x2a0>
    80005512:	fb040513          	addi	a0,s0,-80
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	69e080e7          	jalr	1694(ra) # 80003bb4 <namecmp>
    8000551e:	14050a63          	beqz	a0,80005672 <sys_unlink+0x1b0>
    80005522:	00003597          	auipc	a1,0x3
    80005526:	21e58593          	addi	a1,a1,542 # 80008740 <syscalls+0x2a8>
    8000552a:	fb040513          	addi	a0,s0,-80
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	686080e7          	jalr	1670(ra) # 80003bb4 <namecmp>
    80005536:	12050e63          	beqz	a0,80005672 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000553a:	f2c40613          	addi	a2,s0,-212
    8000553e:	fb040593          	addi	a1,s0,-80
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	68a080e7          	jalr	1674(ra) # 80003bce <dirlookup>
    8000554c:	892a                	mv	s2,a0
    8000554e:	12050263          	beqz	a0,80005672 <sys_unlink+0x1b0>
  ilock(ip);
    80005552:	ffffe097          	auipc	ra,0xffffe
    80005556:	198080e7          	jalr	408(ra) # 800036ea <ilock>
  if(ip->nlink < 1)
    8000555a:	04a91783          	lh	a5,74(s2)
    8000555e:	08f05263          	blez	a5,800055e2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005562:	04491703          	lh	a4,68(s2)
    80005566:	4785                	li	a5,1
    80005568:	08f70563          	beq	a4,a5,800055f2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000556c:	4641                	li	a2,16
    8000556e:	4581                	li	a1,0
    80005570:	fc040513          	addi	a0,s0,-64
    80005574:	ffffb097          	auipc	ra,0xffffb
    80005578:	75e080e7          	jalr	1886(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000557c:	4741                	li	a4,16
    8000557e:	f2c42683          	lw	a3,-212(s0)
    80005582:	fc040613          	addi	a2,s0,-64
    80005586:	4581                	li	a1,0
    80005588:	8526                	mv	a0,s1
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	50c080e7          	jalr	1292(ra) # 80003a96 <writei>
    80005592:	47c1                	li	a5,16
    80005594:	0af51563          	bne	a0,a5,8000563e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005598:	04491703          	lh	a4,68(s2)
    8000559c:	4785                	li	a5,1
    8000559e:	0af70863          	beq	a4,a5,8000564e <sys_unlink+0x18c>
  iunlockput(dp);
    800055a2:	8526                	mv	a0,s1
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	3a8080e7          	jalr	936(ra) # 8000394c <iunlockput>
  ip->nlink--;
    800055ac:	04a95783          	lhu	a5,74(s2)
    800055b0:	37fd                	addiw	a5,a5,-1
    800055b2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055b6:	854a                	mv	a0,s2
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	066080e7          	jalr	102(ra) # 8000361e <iupdate>
  iunlockput(ip);
    800055c0:	854a                	mv	a0,s2
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	38a080e7          	jalr	906(ra) # 8000394c <iunlockput>
  end_op();
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	b6a080e7          	jalr	-1174(ra) # 80004134 <end_op>
  return 0;
    800055d2:	4501                	li	a0,0
    800055d4:	a84d                	j	80005686 <sys_unlink+0x1c4>
    end_op();
    800055d6:	fffff097          	auipc	ra,0xfffff
    800055da:	b5e080e7          	jalr	-1186(ra) # 80004134 <end_op>
    return -1;
    800055de:	557d                	li	a0,-1
    800055e0:	a05d                	j	80005686 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055e2:	00003517          	auipc	a0,0x3
    800055e6:	16650513          	addi	a0,a0,358 # 80008748 <syscalls+0x2b0>
    800055ea:	ffffb097          	auipc	ra,0xffffb
    800055ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055f2:	04c92703          	lw	a4,76(s2)
    800055f6:	02000793          	li	a5,32
    800055fa:	f6e7f9e3          	bgeu	a5,a4,8000556c <sys_unlink+0xaa>
    800055fe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005602:	4741                	li	a4,16
    80005604:	86ce                	mv	a3,s3
    80005606:	f1840613          	addi	a2,s0,-232
    8000560a:	4581                	li	a1,0
    8000560c:	854a                	mv	a0,s2
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	390080e7          	jalr	912(ra) # 8000399e <readi>
    80005616:	47c1                	li	a5,16
    80005618:	00f51b63          	bne	a0,a5,8000562e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000561c:	f1845783          	lhu	a5,-232(s0)
    80005620:	e7a1                	bnez	a5,80005668 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005622:	29c1                	addiw	s3,s3,16
    80005624:	04c92783          	lw	a5,76(s2)
    80005628:	fcf9ede3          	bltu	s3,a5,80005602 <sys_unlink+0x140>
    8000562c:	b781                	j	8000556c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000562e:	00003517          	auipc	a0,0x3
    80005632:	13250513          	addi	a0,a0,306 # 80008760 <syscalls+0x2c8>
    80005636:	ffffb097          	auipc	ra,0xffffb
    8000563a:	f0a080e7          	jalr	-246(ra) # 80000540 <panic>
    panic("unlink: writei");
    8000563e:	00003517          	auipc	a0,0x3
    80005642:	13a50513          	addi	a0,a0,314 # 80008778 <syscalls+0x2e0>
    80005646:	ffffb097          	auipc	ra,0xffffb
    8000564a:	efa080e7          	jalr	-262(ra) # 80000540 <panic>
    dp->nlink--;
    8000564e:	04a4d783          	lhu	a5,74(s1)
    80005652:	37fd                	addiw	a5,a5,-1
    80005654:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005658:	8526                	mv	a0,s1
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	fc4080e7          	jalr	-60(ra) # 8000361e <iupdate>
    80005662:	b781                	j	800055a2 <sys_unlink+0xe0>
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	a005                	j	80005686 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005668:	854a                	mv	a0,s2
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	2e2080e7          	jalr	738(ra) # 8000394c <iunlockput>
  iunlockput(dp);
    80005672:	8526                	mv	a0,s1
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	2d8080e7          	jalr	728(ra) # 8000394c <iunlockput>
  end_op();
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	ab8080e7          	jalr	-1352(ra) # 80004134 <end_op>
  return -1;
    80005684:	557d                	li	a0,-1
}
    80005686:	70ae                	ld	ra,232(sp)
    80005688:	740e                	ld	s0,224(sp)
    8000568a:	64ee                	ld	s1,216(sp)
    8000568c:	694e                	ld	s2,208(sp)
    8000568e:	69ae                	ld	s3,200(sp)
    80005690:	616d                	addi	sp,sp,240
    80005692:	8082                	ret

0000000080005694 <sys_open>:

uint64
sys_open(void)
{
    80005694:	7131                	addi	sp,sp,-192
    80005696:	fd06                	sd	ra,184(sp)
    80005698:	f922                	sd	s0,176(sp)
    8000569a:	f526                	sd	s1,168(sp)
    8000569c:	f14a                	sd	s2,160(sp)
    8000569e:	ed4e                	sd	s3,152(sp)
    800056a0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056a2:	f4c40593          	addi	a1,s0,-180
    800056a6:	4505                	li	a0,1
    800056a8:	ffffd097          	auipc	ra,0xffffd
    800056ac:	4d8080e7          	jalr	1240(ra) # 80002b80 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056b0:	08000613          	li	a2,128
    800056b4:	f5040593          	addi	a1,s0,-176
    800056b8:	4501                	li	a0,0
    800056ba:	ffffd097          	auipc	ra,0xffffd
    800056be:	506080e7          	jalr	1286(ra) # 80002bc0 <argstr>
    800056c2:	87aa                	mv	a5,a0
    return -1;
    800056c4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056c6:	0a07c963          	bltz	a5,80005778 <sys_open+0xe4>

  begin_op();
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	9ec080e7          	jalr	-1556(ra) # 800040b6 <begin_op>

  if(omode & O_CREATE){
    800056d2:	f4c42783          	lw	a5,-180(s0)
    800056d6:	2007f793          	andi	a5,a5,512
    800056da:	cfc5                	beqz	a5,80005792 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056dc:	4681                	li	a3,0
    800056de:	4601                	li	a2,0
    800056e0:	4589                	li	a1,2
    800056e2:	f5040513          	addi	a0,s0,-176
    800056e6:	00000097          	auipc	ra,0x0
    800056ea:	972080e7          	jalr	-1678(ra) # 80005058 <create>
    800056ee:	84aa                	mv	s1,a0
    if(ip == 0){
    800056f0:	c959                	beqz	a0,80005786 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056f2:	04449703          	lh	a4,68(s1)
    800056f6:	478d                	li	a5,3
    800056f8:	00f71763          	bne	a4,a5,80005706 <sys_open+0x72>
    800056fc:	0464d703          	lhu	a4,70(s1)
    80005700:	47a5                	li	a5,9
    80005702:	0ce7ed63          	bltu	a5,a4,800057dc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	dbc080e7          	jalr	-580(ra) # 800044c2 <filealloc>
    8000570e:	89aa                	mv	s3,a0
    80005710:	10050363          	beqz	a0,80005816 <sys_open+0x182>
    80005714:	00000097          	auipc	ra,0x0
    80005718:	902080e7          	jalr	-1790(ra) # 80005016 <fdalloc>
    8000571c:	892a                	mv	s2,a0
    8000571e:	0e054763          	bltz	a0,8000580c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005722:	04449703          	lh	a4,68(s1)
    80005726:	478d                	li	a5,3
    80005728:	0cf70563          	beq	a4,a5,800057f2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000572c:	4789                	li	a5,2
    8000572e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005732:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005736:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000573a:	f4c42783          	lw	a5,-180(s0)
    8000573e:	0017c713          	xori	a4,a5,1
    80005742:	8b05                	andi	a4,a4,1
    80005744:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005748:	0037f713          	andi	a4,a5,3
    8000574c:	00e03733          	snez	a4,a4
    80005750:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005754:	4007f793          	andi	a5,a5,1024
    80005758:	c791                	beqz	a5,80005764 <sys_open+0xd0>
    8000575a:	04449703          	lh	a4,68(s1)
    8000575e:	4789                	li	a5,2
    80005760:	0af70063          	beq	a4,a5,80005800 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	046080e7          	jalr	70(ra) # 800037ac <iunlock>
  end_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	9c6080e7          	jalr	-1594(ra) # 80004134 <end_op>

  return fd;
    80005776:	854a                	mv	a0,s2
}
    80005778:	70ea                	ld	ra,184(sp)
    8000577a:	744a                	ld	s0,176(sp)
    8000577c:	74aa                	ld	s1,168(sp)
    8000577e:	790a                	ld	s2,160(sp)
    80005780:	69ea                	ld	s3,152(sp)
    80005782:	6129                	addi	sp,sp,192
    80005784:	8082                	ret
      end_op();
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	9ae080e7          	jalr	-1618(ra) # 80004134 <end_op>
      return -1;
    8000578e:	557d                	li	a0,-1
    80005790:	b7e5                	j	80005778 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005792:	f5040513          	addi	a0,s0,-176
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	700080e7          	jalr	1792(ra) # 80003e96 <namei>
    8000579e:	84aa                	mv	s1,a0
    800057a0:	c905                	beqz	a0,800057d0 <sys_open+0x13c>
    ilock(ip);
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	f48080e7          	jalr	-184(ra) # 800036ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057aa:	04449703          	lh	a4,68(s1)
    800057ae:	4785                	li	a5,1
    800057b0:	f4f711e3          	bne	a4,a5,800056f2 <sys_open+0x5e>
    800057b4:	f4c42783          	lw	a5,-180(s0)
    800057b8:	d7b9                	beqz	a5,80005706 <sys_open+0x72>
      iunlockput(ip);
    800057ba:	8526                	mv	a0,s1
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	190080e7          	jalr	400(ra) # 8000394c <iunlockput>
      end_op();
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	970080e7          	jalr	-1680(ra) # 80004134 <end_op>
      return -1;
    800057cc:	557d                	li	a0,-1
    800057ce:	b76d                	j	80005778 <sys_open+0xe4>
      end_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	964080e7          	jalr	-1692(ra) # 80004134 <end_op>
      return -1;
    800057d8:	557d                	li	a0,-1
    800057da:	bf79                	j	80005778 <sys_open+0xe4>
    iunlockput(ip);
    800057dc:	8526                	mv	a0,s1
    800057de:	ffffe097          	auipc	ra,0xffffe
    800057e2:	16e080e7          	jalr	366(ra) # 8000394c <iunlockput>
    end_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	94e080e7          	jalr	-1714(ra) # 80004134 <end_op>
    return -1;
    800057ee:	557d                	li	a0,-1
    800057f0:	b761                	j	80005778 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057f2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057f6:	04649783          	lh	a5,70(s1)
    800057fa:	02f99223          	sh	a5,36(s3)
    800057fe:	bf25                	j	80005736 <sys_open+0xa2>
    itrunc(ip);
    80005800:	8526                	mv	a0,s1
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	ff6080e7          	jalr	-10(ra) # 800037f8 <itrunc>
    8000580a:	bfa9                	j	80005764 <sys_open+0xd0>
      fileclose(f);
    8000580c:	854e                	mv	a0,s3
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	d70080e7          	jalr	-656(ra) # 8000457e <fileclose>
    iunlockput(ip);
    80005816:	8526                	mv	a0,s1
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	134080e7          	jalr	308(ra) # 8000394c <iunlockput>
    end_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	914080e7          	jalr	-1772(ra) # 80004134 <end_op>
    return -1;
    80005828:	557d                	li	a0,-1
    8000582a:	b7b9                	j	80005778 <sys_open+0xe4>

000000008000582c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000582c:	7175                	addi	sp,sp,-144
    8000582e:	e506                	sd	ra,136(sp)
    80005830:	e122                	sd	s0,128(sp)
    80005832:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	882080e7          	jalr	-1918(ra) # 800040b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000583c:	08000613          	li	a2,128
    80005840:	f7040593          	addi	a1,s0,-144
    80005844:	4501                	li	a0,0
    80005846:	ffffd097          	auipc	ra,0xffffd
    8000584a:	37a080e7          	jalr	890(ra) # 80002bc0 <argstr>
    8000584e:	02054963          	bltz	a0,80005880 <sys_mkdir+0x54>
    80005852:	4681                	li	a3,0
    80005854:	4601                	li	a2,0
    80005856:	4585                	li	a1,1
    80005858:	f7040513          	addi	a0,s0,-144
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	7fc080e7          	jalr	2044(ra) # 80005058 <create>
    80005864:	cd11                	beqz	a0,80005880 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	0e6080e7          	jalr	230(ra) # 8000394c <iunlockput>
  end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	8c6080e7          	jalr	-1850(ra) # 80004134 <end_op>
  return 0;
    80005876:	4501                	li	a0,0
}
    80005878:	60aa                	ld	ra,136(sp)
    8000587a:	640a                	ld	s0,128(sp)
    8000587c:	6149                	addi	sp,sp,144
    8000587e:	8082                	ret
    end_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	8b4080e7          	jalr	-1868(ra) # 80004134 <end_op>
    return -1;
    80005888:	557d                	li	a0,-1
    8000588a:	b7fd                	j	80005878 <sys_mkdir+0x4c>

000000008000588c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000588c:	7135                	addi	sp,sp,-160
    8000588e:	ed06                	sd	ra,152(sp)
    80005890:	e922                	sd	s0,144(sp)
    80005892:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005894:	fffff097          	auipc	ra,0xfffff
    80005898:	822080e7          	jalr	-2014(ra) # 800040b6 <begin_op>
  argint(1, &major);
    8000589c:	f6c40593          	addi	a1,s0,-148
    800058a0:	4505                	li	a0,1
    800058a2:	ffffd097          	auipc	ra,0xffffd
    800058a6:	2de080e7          	jalr	734(ra) # 80002b80 <argint>
  argint(2, &minor);
    800058aa:	f6840593          	addi	a1,s0,-152
    800058ae:	4509                	li	a0,2
    800058b0:	ffffd097          	auipc	ra,0xffffd
    800058b4:	2d0080e7          	jalr	720(ra) # 80002b80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058b8:	08000613          	li	a2,128
    800058bc:	f7040593          	addi	a1,s0,-144
    800058c0:	4501                	li	a0,0
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	2fe080e7          	jalr	766(ra) # 80002bc0 <argstr>
    800058ca:	02054b63          	bltz	a0,80005900 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058ce:	f6841683          	lh	a3,-152(s0)
    800058d2:	f6c41603          	lh	a2,-148(s0)
    800058d6:	458d                	li	a1,3
    800058d8:	f7040513          	addi	a0,s0,-144
    800058dc:	fffff097          	auipc	ra,0xfffff
    800058e0:	77c080e7          	jalr	1916(ra) # 80005058 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e4:	cd11                	beqz	a0,80005900 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	066080e7          	jalr	102(ra) # 8000394c <iunlockput>
  end_op();
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	846080e7          	jalr	-1978(ra) # 80004134 <end_op>
  return 0;
    800058f6:	4501                	li	a0,0
}
    800058f8:	60ea                	ld	ra,152(sp)
    800058fa:	644a                	ld	s0,144(sp)
    800058fc:	610d                	addi	sp,sp,160
    800058fe:	8082                	ret
    end_op();
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	834080e7          	jalr	-1996(ra) # 80004134 <end_op>
    return -1;
    80005908:	557d                	li	a0,-1
    8000590a:	b7fd                	j	800058f8 <sys_mknod+0x6c>

000000008000590c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000590c:	7135                	addi	sp,sp,-160
    8000590e:	ed06                	sd	ra,152(sp)
    80005910:	e922                	sd	s0,144(sp)
    80005912:	e526                	sd	s1,136(sp)
    80005914:	e14a                	sd	s2,128(sp)
    80005916:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005918:	ffffc097          	auipc	ra,0xffffc
    8000591c:	0b8080e7          	jalr	184(ra) # 800019d0 <myproc>
    80005920:	892a                	mv	s2,a0
  
  begin_op();
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	794080e7          	jalr	1940(ra) # 800040b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000592a:	08000613          	li	a2,128
    8000592e:	f6040593          	addi	a1,s0,-160
    80005932:	4501                	li	a0,0
    80005934:	ffffd097          	auipc	ra,0xffffd
    80005938:	28c080e7          	jalr	652(ra) # 80002bc0 <argstr>
    8000593c:	04054b63          	bltz	a0,80005992 <sys_chdir+0x86>
    80005940:	f6040513          	addi	a0,s0,-160
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	552080e7          	jalr	1362(ra) # 80003e96 <namei>
    8000594c:	84aa                	mv	s1,a0
    8000594e:	c131                	beqz	a0,80005992 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	d9a080e7          	jalr	-614(ra) # 800036ea <ilock>
  if(ip->type != T_DIR){
    80005958:	04449703          	lh	a4,68(s1)
    8000595c:	4785                	li	a5,1
    8000595e:	04f71063          	bne	a4,a5,8000599e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	e48080e7          	jalr	-440(ra) # 800037ac <iunlock>
  iput(p->cwd);
    8000596c:	15093503          	ld	a0,336(s2)
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	f34080e7          	jalr	-204(ra) # 800038a4 <iput>
  end_op();
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	7bc080e7          	jalr	1980(ra) # 80004134 <end_op>
  p->cwd = ip;
    80005980:	14993823          	sd	s1,336(s2)
  return 0;
    80005984:	4501                	li	a0,0
}
    80005986:	60ea                	ld	ra,152(sp)
    80005988:	644a                	ld	s0,144(sp)
    8000598a:	64aa                	ld	s1,136(sp)
    8000598c:	690a                	ld	s2,128(sp)
    8000598e:	610d                	addi	sp,sp,160
    80005990:	8082                	ret
    end_op();
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	7a2080e7          	jalr	1954(ra) # 80004134 <end_op>
    return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	b7ed                	j	80005986 <sys_chdir+0x7a>
    iunlockput(ip);
    8000599e:	8526                	mv	a0,s1
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	fac080e7          	jalr	-84(ra) # 8000394c <iunlockput>
    end_op();
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	78c080e7          	jalr	1932(ra) # 80004134 <end_op>
    return -1;
    800059b0:	557d                	li	a0,-1
    800059b2:	bfd1                	j	80005986 <sys_chdir+0x7a>

00000000800059b4 <sys_exec>:

uint64
sys_exec(void)
{
    800059b4:	7145                	addi	sp,sp,-464
    800059b6:	e786                	sd	ra,456(sp)
    800059b8:	e3a2                	sd	s0,448(sp)
    800059ba:	ff26                	sd	s1,440(sp)
    800059bc:	fb4a                	sd	s2,432(sp)
    800059be:	f74e                	sd	s3,424(sp)
    800059c0:	f352                	sd	s4,416(sp)
    800059c2:	ef56                	sd	s5,408(sp)
    800059c4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059c6:	e3840593          	addi	a1,s0,-456
    800059ca:	4505                	li	a0,1
    800059cc:	ffffd097          	auipc	ra,0xffffd
    800059d0:	1d4080e7          	jalr	468(ra) # 80002ba0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059d4:	08000613          	li	a2,128
    800059d8:	f4040593          	addi	a1,s0,-192
    800059dc:	4501                	li	a0,0
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	1e2080e7          	jalr	482(ra) # 80002bc0 <argstr>
    800059e6:	87aa                	mv	a5,a0
    return -1;
    800059e8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800059ea:	0c07c363          	bltz	a5,80005ab0 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800059ee:	10000613          	li	a2,256
    800059f2:	4581                	li	a1,0
    800059f4:	e4040513          	addi	a0,s0,-448
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	2da080e7          	jalr	730(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a00:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a04:	89a6                	mv	s3,s1
    80005a06:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a08:	02000a13          	li	s4,32
    80005a0c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a10:	00391513          	slli	a0,s2,0x3
    80005a14:	e3040593          	addi	a1,s0,-464
    80005a18:	e3843783          	ld	a5,-456(s0)
    80005a1c:	953e                	add	a0,a0,a5
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	0c4080e7          	jalr	196(ra) # 80002ae2 <fetchaddr>
    80005a26:	02054a63          	bltz	a0,80005a5a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a2a:	e3043783          	ld	a5,-464(s0)
    80005a2e:	c3b9                	beqz	a5,80005a74 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a30:	ffffb097          	auipc	ra,0xffffb
    80005a34:	0b6080e7          	jalr	182(ra) # 80000ae6 <kalloc>
    80005a38:	85aa                	mv	a1,a0
    80005a3a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a3e:	cd11                	beqz	a0,80005a5a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a40:	6605                	lui	a2,0x1
    80005a42:	e3043503          	ld	a0,-464(s0)
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	0ee080e7          	jalr	238(ra) # 80002b34 <fetchstr>
    80005a4e:	00054663          	bltz	a0,80005a5a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a52:	0905                	addi	s2,s2,1
    80005a54:	09a1                	addi	s3,s3,8
    80005a56:	fb491be3          	bne	s2,s4,80005a0c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a5a:	f4040913          	addi	s2,s0,-192
    80005a5e:	6088                	ld	a0,0(s1)
    80005a60:	c539                	beqz	a0,80005aae <sys_exec+0xfa>
    kfree(argv[i]);
    80005a62:	ffffb097          	auipc	ra,0xffffb
    80005a66:	f86080e7          	jalr	-122(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a6a:	04a1                	addi	s1,s1,8
    80005a6c:	ff2499e3          	bne	s1,s2,80005a5e <sys_exec+0xaa>
  return -1;
    80005a70:	557d                	li	a0,-1
    80005a72:	a83d                	j	80005ab0 <sys_exec+0xfc>
      argv[i] = 0;
    80005a74:	0a8e                	slli	s5,s5,0x3
    80005a76:	fc0a8793          	addi	a5,s5,-64
    80005a7a:	00878ab3          	add	s5,a5,s0
    80005a7e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a82:	e4040593          	addi	a1,s0,-448
    80005a86:	f4040513          	addi	a0,s0,-192
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	16e080e7          	jalr	366(ra) # 80004bf8 <exec>
    80005a92:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a94:	f4040993          	addi	s3,s0,-192
    80005a98:	6088                	ld	a0,0(s1)
    80005a9a:	c901                	beqz	a0,80005aaa <sys_exec+0xf6>
    kfree(argv[i]);
    80005a9c:	ffffb097          	auipc	ra,0xffffb
    80005aa0:	f4c080e7          	jalr	-180(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa4:	04a1                	addi	s1,s1,8
    80005aa6:	ff3499e3          	bne	s1,s3,80005a98 <sys_exec+0xe4>
  return ret;
    80005aaa:	854a                	mv	a0,s2
    80005aac:	a011                	j	80005ab0 <sys_exec+0xfc>
  return -1;
    80005aae:	557d                	li	a0,-1
}
    80005ab0:	60be                	ld	ra,456(sp)
    80005ab2:	641e                	ld	s0,448(sp)
    80005ab4:	74fa                	ld	s1,440(sp)
    80005ab6:	795a                	ld	s2,432(sp)
    80005ab8:	79ba                	ld	s3,424(sp)
    80005aba:	7a1a                	ld	s4,416(sp)
    80005abc:	6afa                	ld	s5,408(sp)
    80005abe:	6179                	addi	sp,sp,464
    80005ac0:	8082                	ret

0000000080005ac2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ac2:	7139                	addi	sp,sp,-64
    80005ac4:	fc06                	sd	ra,56(sp)
    80005ac6:	f822                	sd	s0,48(sp)
    80005ac8:	f426                	sd	s1,40(sp)
    80005aca:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005acc:	ffffc097          	auipc	ra,0xffffc
    80005ad0:	f04080e7          	jalr	-252(ra) # 800019d0 <myproc>
    80005ad4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ad6:	fd840593          	addi	a1,s0,-40
    80005ada:	4501                	li	a0,0
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	0c4080e7          	jalr	196(ra) # 80002ba0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ae4:	fc840593          	addi	a1,s0,-56
    80005ae8:	fd040513          	addi	a0,s0,-48
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	dc2080e7          	jalr	-574(ra) # 800048ae <pipealloc>
    return -1;
    80005af4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005af6:	0c054463          	bltz	a0,80005bbe <sys_pipe+0xfc>
  fd0 = -1;
    80005afa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005afe:	fd043503          	ld	a0,-48(s0)
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	514080e7          	jalr	1300(ra) # 80005016 <fdalloc>
    80005b0a:	fca42223          	sw	a0,-60(s0)
    80005b0e:	08054b63          	bltz	a0,80005ba4 <sys_pipe+0xe2>
    80005b12:	fc843503          	ld	a0,-56(s0)
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	500080e7          	jalr	1280(ra) # 80005016 <fdalloc>
    80005b1e:	fca42023          	sw	a0,-64(s0)
    80005b22:	06054863          	bltz	a0,80005b92 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b26:	4691                	li	a3,4
    80005b28:	fc440613          	addi	a2,s0,-60
    80005b2c:	fd843583          	ld	a1,-40(s0)
    80005b30:	68a8                	ld	a0,80(s1)
    80005b32:	ffffc097          	auipc	ra,0xffffc
    80005b36:	b5a080e7          	jalr	-1190(ra) # 8000168c <copyout>
    80005b3a:	02054063          	bltz	a0,80005b5a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b3e:	4691                	li	a3,4
    80005b40:	fc040613          	addi	a2,s0,-64
    80005b44:	fd843583          	ld	a1,-40(s0)
    80005b48:	0591                	addi	a1,a1,4
    80005b4a:	68a8                	ld	a0,80(s1)
    80005b4c:	ffffc097          	auipc	ra,0xffffc
    80005b50:	b40080e7          	jalr	-1216(ra) # 8000168c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b54:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b56:	06055463          	bgez	a0,80005bbe <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b5a:	fc442783          	lw	a5,-60(s0)
    80005b5e:	07e9                	addi	a5,a5,26
    80005b60:	078e                	slli	a5,a5,0x3
    80005b62:	97a6                	add	a5,a5,s1
    80005b64:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b68:	fc042783          	lw	a5,-64(s0)
    80005b6c:	07e9                	addi	a5,a5,26
    80005b6e:	078e                	slli	a5,a5,0x3
    80005b70:	94be                	add	s1,s1,a5
    80005b72:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b76:	fd043503          	ld	a0,-48(s0)
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	a04080e7          	jalr	-1532(ra) # 8000457e <fileclose>
    fileclose(wf);
    80005b82:	fc843503          	ld	a0,-56(s0)
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	9f8080e7          	jalr	-1544(ra) # 8000457e <fileclose>
    return -1;
    80005b8e:	57fd                	li	a5,-1
    80005b90:	a03d                	j	80005bbe <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b92:	fc442783          	lw	a5,-60(s0)
    80005b96:	0007c763          	bltz	a5,80005ba4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b9a:	07e9                	addi	a5,a5,26
    80005b9c:	078e                	slli	a5,a5,0x3
    80005b9e:	97a6                	add	a5,a5,s1
    80005ba0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ba4:	fd043503          	ld	a0,-48(s0)
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	9d6080e7          	jalr	-1578(ra) # 8000457e <fileclose>
    fileclose(wf);
    80005bb0:	fc843503          	ld	a0,-56(s0)
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	9ca080e7          	jalr	-1590(ra) # 8000457e <fileclose>
    return -1;
    80005bbc:	57fd                	li	a5,-1
}
    80005bbe:	853e                	mv	a0,a5
    80005bc0:	70e2                	ld	ra,56(sp)
    80005bc2:	7442                	ld	s0,48(sp)
    80005bc4:	74a2                	ld	s1,40(sp)
    80005bc6:	6121                	addi	sp,sp,64
    80005bc8:	8082                	ret
    80005bca:	0000                	unimp
    80005bcc:	0000                	unimp
	...

0000000080005bd0 <kernelvec>:
    80005bd0:	7111                	addi	sp,sp,-256
    80005bd2:	e006                	sd	ra,0(sp)
    80005bd4:	e40a                	sd	sp,8(sp)
    80005bd6:	e80e                	sd	gp,16(sp)
    80005bd8:	ec12                	sd	tp,24(sp)
    80005bda:	f016                	sd	t0,32(sp)
    80005bdc:	f41a                	sd	t1,40(sp)
    80005bde:	f81e                	sd	t2,48(sp)
    80005be0:	fc22                	sd	s0,56(sp)
    80005be2:	e0a6                	sd	s1,64(sp)
    80005be4:	e4aa                	sd	a0,72(sp)
    80005be6:	e8ae                	sd	a1,80(sp)
    80005be8:	ecb2                	sd	a2,88(sp)
    80005bea:	f0b6                	sd	a3,96(sp)
    80005bec:	f4ba                	sd	a4,104(sp)
    80005bee:	f8be                	sd	a5,112(sp)
    80005bf0:	fcc2                	sd	a6,120(sp)
    80005bf2:	e146                	sd	a7,128(sp)
    80005bf4:	e54a                	sd	s2,136(sp)
    80005bf6:	e94e                	sd	s3,144(sp)
    80005bf8:	ed52                	sd	s4,152(sp)
    80005bfa:	f156                	sd	s5,160(sp)
    80005bfc:	f55a                	sd	s6,168(sp)
    80005bfe:	f95e                	sd	s7,176(sp)
    80005c00:	fd62                	sd	s8,184(sp)
    80005c02:	e1e6                	sd	s9,192(sp)
    80005c04:	e5ea                	sd	s10,200(sp)
    80005c06:	e9ee                	sd	s11,208(sp)
    80005c08:	edf2                	sd	t3,216(sp)
    80005c0a:	f1f6                	sd	t4,224(sp)
    80005c0c:	f5fa                	sd	t5,232(sp)
    80005c0e:	f9fe                	sd	t6,240(sp)
    80005c10:	d9ffc0ef          	jal	ra,800029ae <kerneltrap>
    80005c14:	6082                	ld	ra,0(sp)
    80005c16:	6122                	ld	sp,8(sp)
    80005c18:	61c2                	ld	gp,16(sp)
    80005c1a:	7282                	ld	t0,32(sp)
    80005c1c:	7322                	ld	t1,40(sp)
    80005c1e:	73c2                	ld	t2,48(sp)
    80005c20:	7462                	ld	s0,56(sp)
    80005c22:	6486                	ld	s1,64(sp)
    80005c24:	6526                	ld	a0,72(sp)
    80005c26:	65c6                	ld	a1,80(sp)
    80005c28:	6666                	ld	a2,88(sp)
    80005c2a:	7686                	ld	a3,96(sp)
    80005c2c:	7726                	ld	a4,104(sp)
    80005c2e:	77c6                	ld	a5,112(sp)
    80005c30:	7866                	ld	a6,120(sp)
    80005c32:	688a                	ld	a7,128(sp)
    80005c34:	692a                	ld	s2,136(sp)
    80005c36:	69ca                	ld	s3,144(sp)
    80005c38:	6a6a                	ld	s4,152(sp)
    80005c3a:	7a8a                	ld	s5,160(sp)
    80005c3c:	7b2a                	ld	s6,168(sp)
    80005c3e:	7bca                	ld	s7,176(sp)
    80005c40:	7c6a                	ld	s8,184(sp)
    80005c42:	6c8e                	ld	s9,192(sp)
    80005c44:	6d2e                	ld	s10,200(sp)
    80005c46:	6dce                	ld	s11,208(sp)
    80005c48:	6e6e                	ld	t3,216(sp)
    80005c4a:	7e8e                	ld	t4,224(sp)
    80005c4c:	7f2e                	ld	t5,232(sp)
    80005c4e:	7fce                	ld	t6,240(sp)
    80005c50:	6111                	addi	sp,sp,256
    80005c52:	10200073          	sret
    80005c56:	00000013          	nop
    80005c5a:	00000013          	nop
    80005c5e:	0001                	nop

0000000080005c60 <timervec>:
    80005c60:	34051573          	csrrw	a0,mscratch,a0
    80005c64:	e10c                	sd	a1,0(a0)
    80005c66:	e510                	sd	a2,8(a0)
    80005c68:	e914                	sd	a3,16(a0)
    80005c6a:	6d0c                	ld	a1,24(a0)
    80005c6c:	7110                	ld	a2,32(a0)
    80005c6e:	6194                	ld	a3,0(a1)
    80005c70:	96b2                	add	a3,a3,a2
    80005c72:	e194                	sd	a3,0(a1)
    80005c74:	4589                	li	a1,2
    80005c76:	14459073          	csrw	sip,a1
    80005c7a:	6914                	ld	a3,16(a0)
    80005c7c:	6510                	ld	a2,8(a0)
    80005c7e:	610c                	ld	a1,0(a0)
    80005c80:	34051573          	csrrw	a0,mscratch,a0
    80005c84:	30200073          	mret
	...

0000000080005c8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c8a:	1141                	addi	sp,sp,-16
    80005c8c:	e422                	sd	s0,8(sp)
    80005c8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c90:	0c0007b7          	lui	a5,0xc000
    80005c94:	4705                	li	a4,1
    80005c96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c98:	c3d8                	sw	a4,4(a5)
}
    80005c9a:	6422                	ld	s0,8(sp)
    80005c9c:	0141                	addi	sp,sp,16
    80005c9e:	8082                	ret

0000000080005ca0 <plicinithart>:

void
plicinithart(void)
{
    80005ca0:	1141                	addi	sp,sp,-16
    80005ca2:	e406                	sd	ra,8(sp)
    80005ca4:	e022                	sd	s0,0(sp)
    80005ca6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	cfc080e7          	jalr	-772(ra) # 800019a4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cb0:	0085171b          	slliw	a4,a0,0x8
    80005cb4:	0c0027b7          	lui	a5,0xc002
    80005cb8:	97ba                	add	a5,a5,a4
    80005cba:	40200713          	li	a4,1026
    80005cbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cc2:	00d5151b          	slliw	a0,a0,0xd
    80005cc6:	0c2017b7          	lui	a5,0xc201
    80005cca:	97aa                	add	a5,a5,a0
    80005ccc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cd0:	60a2                	ld	ra,8(sp)
    80005cd2:	6402                	ld	s0,0(sp)
    80005cd4:	0141                	addi	sp,sp,16
    80005cd6:	8082                	ret

0000000080005cd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cd8:	1141                	addi	sp,sp,-16
    80005cda:	e406                	sd	ra,8(sp)
    80005cdc:	e022                	sd	s0,0(sp)
    80005cde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce0:	ffffc097          	auipc	ra,0xffffc
    80005ce4:	cc4080e7          	jalr	-828(ra) # 800019a4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ce8:	00d5151b          	slliw	a0,a0,0xd
    80005cec:	0c2017b7          	lui	a5,0xc201
    80005cf0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005cf2:	43c8                	lw	a0,4(a5)
    80005cf4:	60a2                	ld	ra,8(sp)
    80005cf6:	6402                	ld	s0,0(sp)
    80005cf8:	0141                	addi	sp,sp,16
    80005cfa:	8082                	ret

0000000080005cfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cfc:	1101                	addi	sp,sp,-32
    80005cfe:	ec06                	sd	ra,24(sp)
    80005d00:	e822                	sd	s0,16(sp)
    80005d02:	e426                	sd	s1,8(sp)
    80005d04:	1000                	addi	s0,sp,32
    80005d06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	c9c080e7          	jalr	-868(ra) # 800019a4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d10:	00d5151b          	slliw	a0,a0,0xd
    80005d14:	0c2017b7          	lui	a5,0xc201
    80005d18:	97aa                	add	a5,a5,a0
    80005d1a:	c3c4                	sw	s1,4(a5)
}
    80005d1c:	60e2                	ld	ra,24(sp)
    80005d1e:	6442                	ld	s0,16(sp)
    80005d20:	64a2                	ld	s1,8(sp)
    80005d22:	6105                	addi	sp,sp,32
    80005d24:	8082                	ret

0000000080005d26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d26:	1141                	addi	sp,sp,-16
    80005d28:	e406                	sd	ra,8(sp)
    80005d2a:	e022                	sd	s0,0(sp)
    80005d2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d2e:	479d                	li	a5,7
    80005d30:	04a7cc63          	blt	a5,a0,80005d88 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d34:	0001c797          	auipc	a5,0x1c
    80005d38:	13c78793          	addi	a5,a5,316 # 80021e70 <disk>
    80005d3c:	97aa                	add	a5,a5,a0
    80005d3e:	0187c783          	lbu	a5,24(a5)
    80005d42:	ebb9                	bnez	a5,80005d98 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d44:	00451693          	slli	a3,a0,0x4
    80005d48:	0001c797          	auipc	a5,0x1c
    80005d4c:	12878793          	addi	a5,a5,296 # 80021e70 <disk>
    80005d50:	6398                	ld	a4,0(a5)
    80005d52:	9736                	add	a4,a4,a3
    80005d54:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d58:	6398                	ld	a4,0(a5)
    80005d5a:	9736                	add	a4,a4,a3
    80005d5c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d60:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d64:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d68:	97aa                	add	a5,a5,a0
    80005d6a:	4705                	li	a4,1
    80005d6c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d70:	0001c517          	auipc	a0,0x1c
    80005d74:	11850513          	addi	a0,a0,280 # 80021e88 <disk+0x18>
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	410080e7          	jalr	1040(ra) # 80002188 <wakeup>
}
    80005d80:	60a2                	ld	ra,8(sp)
    80005d82:	6402                	ld	s0,0(sp)
    80005d84:	0141                	addi	sp,sp,16
    80005d86:	8082                	ret
    panic("free_desc 1");
    80005d88:	00003517          	auipc	a0,0x3
    80005d8c:	a0050513          	addi	a0,a0,-1536 # 80008788 <syscalls+0x2f0>
    80005d90:	ffffa097          	auipc	ra,0xffffa
    80005d94:	7b0080e7          	jalr	1968(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005d98:	00003517          	auipc	a0,0x3
    80005d9c:	a0050513          	addi	a0,a0,-1536 # 80008798 <syscalls+0x300>
    80005da0:	ffffa097          	auipc	ra,0xffffa
    80005da4:	7a0080e7          	jalr	1952(ra) # 80000540 <panic>

0000000080005da8 <virtio_disk_init>:
{
    80005da8:	1101                	addi	sp,sp,-32
    80005daa:	ec06                	sd	ra,24(sp)
    80005dac:	e822                	sd	s0,16(sp)
    80005dae:	e426                	sd	s1,8(sp)
    80005db0:	e04a                	sd	s2,0(sp)
    80005db2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005db4:	00003597          	auipc	a1,0x3
    80005db8:	9f458593          	addi	a1,a1,-1548 # 800087a8 <syscalls+0x310>
    80005dbc:	0001c517          	auipc	a0,0x1c
    80005dc0:	1dc50513          	addi	a0,a0,476 # 80021f98 <disk+0x128>
    80005dc4:	ffffb097          	auipc	ra,0xffffb
    80005dc8:	d82080e7          	jalr	-638(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dcc:	100017b7          	lui	a5,0x10001
    80005dd0:	4398                	lw	a4,0(a5)
    80005dd2:	2701                	sext.w	a4,a4
    80005dd4:	747277b7          	lui	a5,0x74727
    80005dd8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ddc:	14f71b63          	bne	a4,a5,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005de0:	100017b7          	lui	a5,0x10001
    80005de4:	43dc                	lw	a5,4(a5)
    80005de6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005de8:	4709                	li	a4,2
    80005dea:	14e79463          	bne	a5,a4,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dee:	100017b7          	lui	a5,0x10001
    80005df2:	479c                	lw	a5,8(a5)
    80005df4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005df6:	12e79e63          	bne	a5,a4,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dfa:	100017b7          	lui	a5,0x10001
    80005dfe:	47d8                	lw	a4,12(a5)
    80005e00:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e02:	554d47b7          	lui	a5,0x554d4
    80005e06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e0a:	12f71463          	bne	a4,a5,80005f32 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e0e:	100017b7          	lui	a5,0x10001
    80005e12:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e16:	4705                	li	a4,1
    80005e18:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e1a:	470d                	li	a4,3
    80005e1c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e1e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e20:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e24:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc7af>
    80005e28:	8f75                	and	a4,a4,a3
    80005e2a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2c:	472d                	li	a4,11
    80005e2e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e30:	5bbc                	lw	a5,112(a5)
    80005e32:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e36:	8ba1                	andi	a5,a5,8
    80005e38:	10078563          	beqz	a5,80005f42 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e3c:	100017b7          	lui	a5,0x10001
    80005e40:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e44:	43fc                	lw	a5,68(a5)
    80005e46:	2781                	sext.w	a5,a5
    80005e48:	10079563          	bnez	a5,80005f52 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	5bdc                	lw	a5,52(a5)
    80005e52:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e54:	10078763          	beqz	a5,80005f62 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e58:	471d                	li	a4,7
    80005e5a:	10f77c63          	bgeu	a4,a5,80005f72 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e5e:	ffffb097          	auipc	ra,0xffffb
    80005e62:	c88080e7          	jalr	-888(ra) # 80000ae6 <kalloc>
    80005e66:	0001c497          	auipc	s1,0x1c
    80005e6a:	00a48493          	addi	s1,s1,10 # 80021e70 <disk>
    80005e6e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e70:	ffffb097          	auipc	ra,0xffffb
    80005e74:	c76080e7          	jalr	-906(ra) # 80000ae6 <kalloc>
    80005e78:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e7a:	ffffb097          	auipc	ra,0xffffb
    80005e7e:	c6c080e7          	jalr	-916(ra) # 80000ae6 <kalloc>
    80005e82:	87aa                	mv	a5,a0
    80005e84:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e86:	6088                	ld	a0,0(s1)
    80005e88:	cd6d                	beqz	a0,80005f82 <virtio_disk_init+0x1da>
    80005e8a:	0001c717          	auipc	a4,0x1c
    80005e8e:	fee73703          	ld	a4,-18(a4) # 80021e78 <disk+0x8>
    80005e92:	cb65                	beqz	a4,80005f82 <virtio_disk_init+0x1da>
    80005e94:	c7fd                	beqz	a5,80005f82 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005e96:	6605                	lui	a2,0x1
    80005e98:	4581                	li	a1,0
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	e38080e7          	jalr	-456(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ea2:	0001c497          	auipc	s1,0x1c
    80005ea6:	fce48493          	addi	s1,s1,-50 # 80021e70 <disk>
    80005eaa:	6605                	lui	a2,0x1
    80005eac:	4581                	li	a1,0
    80005eae:	6488                	ld	a0,8(s1)
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	e22080e7          	jalr	-478(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005eb8:	6605                	lui	a2,0x1
    80005eba:	4581                	li	a1,0
    80005ebc:	6888                	ld	a0,16(s1)
    80005ebe:	ffffb097          	auipc	ra,0xffffb
    80005ec2:	e14080e7          	jalr	-492(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ec6:	100017b7          	lui	a5,0x10001
    80005eca:	4721                	li	a4,8
    80005ecc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ece:	4098                	lw	a4,0(s1)
    80005ed0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ed4:	40d8                	lw	a4,4(s1)
    80005ed6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005eda:	6498                	ld	a4,8(s1)
    80005edc:	0007069b          	sext.w	a3,a4
    80005ee0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ee4:	9701                	srai	a4,a4,0x20
    80005ee6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005eea:	6898                	ld	a4,16(s1)
    80005eec:	0007069b          	sext.w	a3,a4
    80005ef0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ef4:	9701                	srai	a4,a4,0x20
    80005ef6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005efa:	4705                	li	a4,1
    80005efc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005efe:	00e48c23          	sb	a4,24(s1)
    80005f02:	00e48ca3          	sb	a4,25(s1)
    80005f06:	00e48d23          	sb	a4,26(s1)
    80005f0a:	00e48da3          	sb	a4,27(s1)
    80005f0e:	00e48e23          	sb	a4,28(s1)
    80005f12:	00e48ea3          	sb	a4,29(s1)
    80005f16:	00e48f23          	sb	a4,30(s1)
    80005f1a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f1e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f22:	0727a823          	sw	s2,112(a5)
}
    80005f26:	60e2                	ld	ra,24(sp)
    80005f28:	6442                	ld	s0,16(sp)
    80005f2a:	64a2                	ld	s1,8(sp)
    80005f2c:	6902                	ld	s2,0(sp)
    80005f2e:	6105                	addi	sp,sp,32
    80005f30:	8082                	ret
    panic("could not find virtio disk");
    80005f32:	00003517          	auipc	a0,0x3
    80005f36:	88650513          	addi	a0,a0,-1914 # 800087b8 <syscalls+0x320>
    80005f3a:	ffffa097          	auipc	ra,0xffffa
    80005f3e:	606080e7          	jalr	1542(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f42:	00003517          	auipc	a0,0x3
    80005f46:	89650513          	addi	a0,a0,-1898 # 800087d8 <syscalls+0x340>
    80005f4a:	ffffa097          	auipc	ra,0xffffa
    80005f4e:	5f6080e7          	jalr	1526(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005f52:	00003517          	auipc	a0,0x3
    80005f56:	8a650513          	addi	a0,a0,-1882 # 800087f8 <syscalls+0x360>
    80005f5a:	ffffa097          	auipc	ra,0xffffa
    80005f5e:	5e6080e7          	jalr	1510(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005f62:	00003517          	auipc	a0,0x3
    80005f66:	8b650513          	addi	a0,a0,-1866 # 80008818 <syscalls+0x380>
    80005f6a:	ffffa097          	auipc	ra,0xffffa
    80005f6e:	5d6080e7          	jalr	1494(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	8c650513          	addi	a0,a0,-1850 # 80008838 <syscalls+0x3a0>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c6080e7          	jalr	1478(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	8d650513          	addi	a0,a0,-1834 # 80008858 <syscalls+0x3c0>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b6080e7          	jalr	1462(ra) # 80000540 <panic>

0000000080005f92 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f92:	7119                	addi	sp,sp,-128
    80005f94:	fc86                	sd	ra,120(sp)
    80005f96:	f8a2                	sd	s0,112(sp)
    80005f98:	f4a6                	sd	s1,104(sp)
    80005f9a:	f0ca                	sd	s2,96(sp)
    80005f9c:	ecce                	sd	s3,88(sp)
    80005f9e:	e8d2                	sd	s4,80(sp)
    80005fa0:	e4d6                	sd	s5,72(sp)
    80005fa2:	e0da                	sd	s6,64(sp)
    80005fa4:	fc5e                	sd	s7,56(sp)
    80005fa6:	f862                	sd	s8,48(sp)
    80005fa8:	f466                	sd	s9,40(sp)
    80005faa:	f06a                	sd	s10,32(sp)
    80005fac:	ec6e                	sd	s11,24(sp)
    80005fae:	0100                	addi	s0,sp,128
    80005fb0:	8aaa                	mv	s5,a0
    80005fb2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fb4:	00c52d03          	lw	s10,12(a0)
    80005fb8:	001d1d1b          	slliw	s10,s10,0x1
    80005fbc:	1d02                	slli	s10,s10,0x20
    80005fbe:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005fc2:	0001c517          	auipc	a0,0x1c
    80005fc6:	fd650513          	addi	a0,a0,-42 # 80021f98 <disk+0x128>
    80005fca:	ffffb097          	auipc	ra,0xffffb
    80005fce:	c0c080e7          	jalr	-1012(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005fd2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fd4:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fd6:	0001cb97          	auipc	s7,0x1c
    80005fda:	e9ab8b93          	addi	s7,s7,-358 # 80021e70 <disk>
  for(int i = 0; i < 3; i++){
    80005fde:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fe0:	0001cc97          	auipc	s9,0x1c
    80005fe4:	fb8c8c93          	addi	s9,s9,-72 # 80021f98 <disk+0x128>
    80005fe8:	a08d                	j	8000604a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005fea:	00fb8733          	add	a4,s7,a5
    80005fee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ff2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ff4:	0207c563          	bltz	a5,8000601e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005ff8:	2905                	addiw	s2,s2,1
    80005ffa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ffc:	05690c63          	beq	s2,s6,80006054 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006000:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006002:	0001c717          	auipc	a4,0x1c
    80006006:	e6e70713          	addi	a4,a4,-402 # 80021e70 <disk>
    8000600a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000600c:	01874683          	lbu	a3,24(a4)
    80006010:	fee9                	bnez	a3,80005fea <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006012:	2785                	addiw	a5,a5,1
    80006014:	0705                	addi	a4,a4,1
    80006016:	fe979be3          	bne	a5,s1,8000600c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000601a:	57fd                	li	a5,-1
    8000601c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000601e:	01205d63          	blez	s2,80006038 <virtio_disk_rw+0xa6>
    80006022:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006024:	000a2503          	lw	a0,0(s4)
    80006028:	00000097          	auipc	ra,0x0
    8000602c:	cfe080e7          	jalr	-770(ra) # 80005d26 <free_desc>
      for(int j = 0; j < i; j++)
    80006030:	2d85                	addiw	s11,s11,1
    80006032:	0a11                	addi	s4,s4,4
    80006034:	ff2d98e3          	bne	s11,s2,80006024 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006038:	85e6                	mv	a1,s9
    8000603a:	0001c517          	auipc	a0,0x1c
    8000603e:	e4e50513          	addi	a0,a0,-434 # 80021e88 <disk+0x18>
    80006042:	ffffc097          	auipc	ra,0xffffc
    80006046:	0e2080e7          	jalr	226(ra) # 80002124 <sleep>
  for(int i = 0; i < 3; i++){
    8000604a:	f8040a13          	addi	s4,s0,-128
{
    8000604e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006050:	894e                	mv	s2,s3
    80006052:	b77d                	j	80006000 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006054:	f8042503          	lw	a0,-128(s0)
    80006058:	00a50713          	addi	a4,a0,10
    8000605c:	0712                	slli	a4,a4,0x4

  if(write)
    8000605e:	0001c797          	auipc	a5,0x1c
    80006062:	e1278793          	addi	a5,a5,-494 # 80021e70 <disk>
    80006066:	00e786b3          	add	a3,a5,a4
    8000606a:	01803633          	snez	a2,s8
    8000606e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006070:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006074:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006078:	f6070613          	addi	a2,a4,-160
    8000607c:	6394                	ld	a3,0(a5)
    8000607e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006080:	00870593          	addi	a1,a4,8
    80006084:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006086:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006088:	0007b803          	ld	a6,0(a5)
    8000608c:	9642                	add	a2,a2,a6
    8000608e:	46c1                	li	a3,16
    80006090:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006092:	4585                	li	a1,1
    80006094:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006098:	f8442683          	lw	a3,-124(s0)
    8000609c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060a0:	0692                	slli	a3,a3,0x4
    800060a2:	9836                	add	a6,a6,a3
    800060a4:	058a8613          	addi	a2,s5,88
    800060a8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060ac:	0007b803          	ld	a6,0(a5)
    800060b0:	96c2                	add	a3,a3,a6
    800060b2:	40000613          	li	a2,1024
    800060b6:	c690                	sw	a2,8(a3)
  if(write)
    800060b8:	001c3613          	seqz	a2,s8
    800060bc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060c0:	00166613          	ori	a2,a2,1
    800060c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060c8:	f8842603          	lw	a2,-120(s0)
    800060cc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060d0:	00250693          	addi	a3,a0,2
    800060d4:	0692                	slli	a3,a3,0x4
    800060d6:	96be                	add	a3,a3,a5
    800060d8:	58fd                	li	a7,-1
    800060da:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060de:	0612                	slli	a2,a2,0x4
    800060e0:	9832                	add	a6,a6,a2
    800060e2:	f9070713          	addi	a4,a4,-112
    800060e6:	973e                	add	a4,a4,a5
    800060e8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800060ec:	6398                	ld	a4,0(a5)
    800060ee:	9732                	add	a4,a4,a2
    800060f0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060f2:	4609                	li	a2,2
    800060f4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800060f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060fc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006100:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006104:	6794                	ld	a3,8(a5)
    80006106:	0026d703          	lhu	a4,2(a3)
    8000610a:	8b1d                	andi	a4,a4,7
    8000610c:	0706                	slli	a4,a4,0x1
    8000610e:	96ba                	add	a3,a3,a4
    80006110:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006114:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006118:	6798                	ld	a4,8(a5)
    8000611a:	00275783          	lhu	a5,2(a4)
    8000611e:	2785                	addiw	a5,a5,1
    80006120:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006124:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006130:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006134:	0001c917          	auipc	s2,0x1c
    80006138:	e6490913          	addi	s2,s2,-412 # 80021f98 <disk+0x128>
  while(b->disk == 1) {
    8000613c:	4485                	li	s1,1
    8000613e:	00b79c63          	bne	a5,a1,80006156 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006142:	85ca                	mv	a1,s2
    80006144:	8556                	mv	a0,s5
    80006146:	ffffc097          	auipc	ra,0xffffc
    8000614a:	fde080e7          	jalr	-34(ra) # 80002124 <sleep>
  while(b->disk == 1) {
    8000614e:	004aa783          	lw	a5,4(s5)
    80006152:	fe9788e3          	beq	a5,s1,80006142 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006156:	f8042903          	lw	s2,-128(s0)
    8000615a:	00290713          	addi	a4,s2,2
    8000615e:	0712                	slli	a4,a4,0x4
    80006160:	0001c797          	auipc	a5,0x1c
    80006164:	d1078793          	addi	a5,a5,-752 # 80021e70 <disk>
    80006168:	97ba                	add	a5,a5,a4
    8000616a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000616e:	0001c997          	auipc	s3,0x1c
    80006172:	d0298993          	addi	s3,s3,-766 # 80021e70 <disk>
    80006176:	00491713          	slli	a4,s2,0x4
    8000617a:	0009b783          	ld	a5,0(s3)
    8000617e:	97ba                	add	a5,a5,a4
    80006180:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006184:	854a                	mv	a0,s2
    80006186:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000618a:	00000097          	auipc	ra,0x0
    8000618e:	b9c080e7          	jalr	-1124(ra) # 80005d26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006192:	8885                	andi	s1,s1,1
    80006194:	f0ed                	bnez	s1,80006176 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006196:	0001c517          	auipc	a0,0x1c
    8000619a:	e0250513          	addi	a0,a0,-510 # 80021f98 <disk+0x128>
    8000619e:	ffffb097          	auipc	ra,0xffffb
    800061a2:	aec080e7          	jalr	-1300(ra) # 80000c8a <release>
}
    800061a6:	70e6                	ld	ra,120(sp)
    800061a8:	7446                	ld	s0,112(sp)
    800061aa:	74a6                	ld	s1,104(sp)
    800061ac:	7906                	ld	s2,96(sp)
    800061ae:	69e6                	ld	s3,88(sp)
    800061b0:	6a46                	ld	s4,80(sp)
    800061b2:	6aa6                	ld	s5,72(sp)
    800061b4:	6b06                	ld	s6,64(sp)
    800061b6:	7be2                	ld	s7,56(sp)
    800061b8:	7c42                	ld	s8,48(sp)
    800061ba:	7ca2                	ld	s9,40(sp)
    800061bc:	7d02                	ld	s10,32(sp)
    800061be:	6de2                	ld	s11,24(sp)
    800061c0:	6109                	addi	sp,sp,128
    800061c2:	8082                	ret

00000000800061c4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061c4:	1101                	addi	sp,sp,-32
    800061c6:	ec06                	sd	ra,24(sp)
    800061c8:	e822                	sd	s0,16(sp)
    800061ca:	e426                	sd	s1,8(sp)
    800061cc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061ce:	0001c497          	auipc	s1,0x1c
    800061d2:	ca248493          	addi	s1,s1,-862 # 80021e70 <disk>
    800061d6:	0001c517          	auipc	a0,0x1c
    800061da:	dc250513          	addi	a0,a0,-574 # 80021f98 <disk+0x128>
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	9f8080e7          	jalr	-1544(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061e6:	10001737          	lui	a4,0x10001
    800061ea:	533c                	lw	a5,96(a4)
    800061ec:	8b8d                	andi	a5,a5,3
    800061ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061f4:	689c                	ld	a5,16(s1)
    800061f6:	0204d703          	lhu	a4,32(s1)
    800061fa:	0027d783          	lhu	a5,2(a5)
    800061fe:	04f70863          	beq	a4,a5,8000624e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006202:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006206:	6898                	ld	a4,16(s1)
    80006208:	0204d783          	lhu	a5,32(s1)
    8000620c:	8b9d                	andi	a5,a5,7
    8000620e:	078e                	slli	a5,a5,0x3
    80006210:	97ba                	add	a5,a5,a4
    80006212:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006214:	00278713          	addi	a4,a5,2
    80006218:	0712                	slli	a4,a4,0x4
    8000621a:	9726                	add	a4,a4,s1
    8000621c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006220:	e721                	bnez	a4,80006268 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006222:	0789                	addi	a5,a5,2
    80006224:	0792                	slli	a5,a5,0x4
    80006226:	97a6                	add	a5,a5,s1
    80006228:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000622a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000622e:	ffffc097          	auipc	ra,0xffffc
    80006232:	f5a080e7          	jalr	-166(ra) # 80002188 <wakeup>

    disk.used_idx += 1;
    80006236:	0204d783          	lhu	a5,32(s1)
    8000623a:	2785                	addiw	a5,a5,1
    8000623c:	17c2                	slli	a5,a5,0x30
    8000623e:	93c1                	srli	a5,a5,0x30
    80006240:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006244:	6898                	ld	a4,16(s1)
    80006246:	00275703          	lhu	a4,2(a4)
    8000624a:	faf71ce3          	bne	a4,a5,80006202 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000624e:	0001c517          	auipc	a0,0x1c
    80006252:	d4a50513          	addi	a0,a0,-694 # 80021f98 <disk+0x128>
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	a34080e7          	jalr	-1484(ra) # 80000c8a <release>
}
    8000625e:	60e2                	ld	ra,24(sp)
    80006260:	6442                	ld	s0,16(sp)
    80006262:	64a2                	ld	s1,8(sp)
    80006264:	6105                	addi	sp,sp,32
    80006266:	8082                	ret
      panic("virtio_disk_intr status");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	60850513          	addi	a0,a0,1544 # 80008870 <syscalls+0x3d8>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2d0080e7          	jalr	720(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
