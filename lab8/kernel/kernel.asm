
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	29813103          	ld	sp,664(sp) # 8000a298 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb1ff>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	de678793          	addi	a5,a5,-538 # 80000e5e <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	1d4020ef          	jal	800022f0 <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	7c2000ef          	jal	800008ea <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000194:	00012517          	auipc	a0,0x12
    80000198:	14c50513          	addi	a0,a0,332 # 800122e0 <cons>
    8000019c:	24d000ef          	jal	80000be8 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	14048493          	addi	s1,s1,320 # 800122e0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	1d090913          	addi	s2,s2,464 # 80012378 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	748010ef          	jal	80001908 <myproc>
    800001c4:	7ad010ef          	jal	80002170 <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	547010ef          	jal	80001f12 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	29f000ef          	jal	80000c70 <release>
      sleep();
    800001d6:	579010ef          	jal	80001f4e <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	20d000ef          	jal	80000be8 <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	0f270713          	addi	a4,a4,242 # 800122e0 <cons>
    800001f6:	0017869b          	addiw	a3,a5,1
    800001fa:	08d72c23          	sw	a3,152(a4)
    800001fe:	07f7f693          	andi	a3,a5,127
    80000202:	9736                	add	a4,a4,a3
    80000204:	01874703          	lbu	a4,24(a4)
    80000208:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    8000020c:	4691                	li	a3,4
    8000020e:	04da8663          	beq	s5,a3,8000025a <consoleread+0xe2>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000212:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	faf40613          	addi	a2,s0,-81
    8000021c:	85d2                	mv	a1,s4
    8000021e:	855a                	mv	a0,s6
    80000220:	084020ef          	jal	800022a4 <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	04f50663          	beq	a0,a5,80000272 <consoleread+0xfa>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000022e:	47a9                	li	a5,10
    80000230:	04fa8b63          	beq	s5,a5,80000286 <consoleread+0x10e>
    80000234:	7aa2                	ld	s5,40(sp)
    80000236:	bfad                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	0a850513          	addi	a0,a0,168 # 800122e0 <cons>
    80000240:	231000ef          	jal	80000c70 <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7b02                	ld	s6,32(sp)
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if (n < target) {
    8000025a:	0179fa63          	bgeu	s3,s7,8000026e <consoleread+0xf6>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	10f72d23          	sw	a5,282(a4) # 80012378 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	06c50513          	addi	a0,a0,108 # 800122e0 <cons>
    8000027c:	1f5000ef          	jal	80000c70 <release>
  return target - n;
    80000280:	413b853b          	subw	a0,s7,s3
    80000284:	b7c9                	j	80000246 <consoleread+0xce>
    80000286:	7aa2                	ld	s5,40(sp)
    80000288:	b7f5                	j	80000274 <consoleread+0xfc>

000000008000028a <consputc>:
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000292:	10000793          	li	a5,256
    80000296:	00f50863          	beq	a0,a5,800002a6 <consputc+0x1c>
    uartputc_sync(c);
    8000029a:	6d6000ef          	jal	80000970 <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	6c8000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	6c0000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	6ba000ef          	jal	80000970 <uartputc_sync>
    800002ba:	b7d5                	j	8000029e <consputc+0x14>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00012517          	auipc	a0,0x12
    800002cc:	01850513          	addi	a0,a0,24 # 800122e0 <cons>
    800002d0:	119000ef          	jal	80000be8 <acquire>

  switch (c) {
    800002d4:	47d5                	li	a5,21
    800002d6:	08f48d63          	beq	s1,a5,80000370 <consoleintr+0xb4>
    800002da:	0297c563          	blt	a5,s1,80000304 <consoleintr+0x48>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48263          	beq	s1,a5,800003c4 <consoleintr+0x108>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49363          	bne	s1,a5,800003ec <consoleintr+0x130>
  case C('P'): // Print process list.
    procdump();
    800002ea:	052020ef          	jal	8000233c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	ff250513          	addi	a0,a0,-14 # 800122e0 <cons>
    800002f6:	17b000ef          	jal	80000c70 <release>
}
    800002fa:	60e2                	ld	ra,24(sp)
    800002fc:	6442                	ld	s0,16(sp)
    800002fe:	64a2                	ld	s1,8(sp)
    80000300:	6105                	addi	sp,sp,32
    80000302:	8082                	ret
  switch (c) {
    80000304:	07f00793          	li	a5,127
    80000308:	0af48e63          	beq	s1,a5,800003c4 <consoleintr+0x108>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030c:	00012717          	auipc	a4,0x12
    80000310:	fd470713          	addi	a4,a4,-44 # 800122e0 <cons>
    80000314:	0a072783          	lw	a5,160(a4)
    80000318:	09872703          	lw	a4,152(a4)
    8000031c:	9f99                	subw	a5,a5,a4
    8000031e:	07f00713          	li	a4,127
    80000322:	fcf766e3          	bltu	a4,a5,800002ee <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000326:	47b5                	li	a5,13
    80000328:	0cf48563          	beq	s1,a5,800003f2 <consoleintr+0x136>
      consputc(c);
    8000032c:	8526                	mv	a0,s1
    8000032e:	f5dff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000332:	00012717          	auipc	a4,0x12
    80000336:	fae70713          	addi	a4,a4,-82 # 800122e0 <cons>
    8000033a:	0a072683          	lw	a3,160(a4)
    8000033e:	0016879b          	addiw	a5,a3,1
    80000342:	863e                	mv	a2,a5
    80000344:	0af72023          	sw	a5,160(a4)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	9736                	add	a4,a4,a3
    8000034e:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	ff648713          	addi	a4,s1,-10
    80000356:	c371                	beqz	a4,8000041a <consoleintr+0x15e>
    80000358:	14f1                	addi	s1,s1,-4
    8000035a:	c0e1                	beqz	s1,8000041a <consoleintr+0x15e>
    8000035c:	00012717          	auipc	a4,0x12
    80000360:	01c72703          	lw	a4,28(a4) # 80012378 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	f6e70713          	addi	a4,a4,-146 # 800122e0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	f5e48493          	addi	s1,s1,-162 # 800122e0 <cons>
    while (cons.e != cons.w &&
    8000038a:	4929                	li	s2,10
    8000038c:	02f70863          	beq	a4,a5,800003bc <consoleintr+0x100>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000390:	37fd                	addiw	a5,a5,-1
    80000392:	07f7f713          	andi	a4,a5,127
    80000396:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    80000398:	01874703          	lbu	a4,24(a4)
    8000039c:	03270263          	beq	a4,s2,800003c0 <consoleintr+0x104>
      cons.e--;
    800003a0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a4:	10000513          	li	a0,256
    800003a8:	ee3ff0ef          	jal	8000028a <consputc>
    while (cons.e != cons.w &&
    800003ac:	0a04a783          	lw	a5,160(s1)
    800003b0:	09c4a703          	lw	a4,156(s1)
    800003b4:	fcf71ee3          	bne	a4,a5,80000390 <consoleintr+0xd4>
    800003b8:	6902                	ld	s2,0(sp)
    800003ba:	bf15                	j	800002ee <consoleintr+0x32>
    800003bc:	6902                	ld	s2,0(sp)
    800003be:	bf05                	j	800002ee <consoleintr+0x32>
    800003c0:	6902                	ld	s2,0(sp)
    800003c2:	b735                	j	800002ee <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c4:	00012717          	auipc	a4,0x12
    800003c8:	f1c70713          	addi	a4,a4,-228 # 800122e0 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	faf72323          	sw	a5,-90(a4) # 80012380 <cons+0xa0>
      consputc(BACKSPACE);
    800003e2:	10000513          	li	a0,256
    800003e6:	ea5ff0ef          	jal	8000028a <consputc>
    800003ea:	b711                	j	800002ee <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ec:	f00481e3          	beqz	s1,800002ee <consoleintr+0x32>
    800003f0:	bf31                	j	8000030c <consoleintr+0x50>
      consputc(c);
    800003f2:	4529                	li	a0,10
    800003f4:	e97ff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f8:	00012797          	auipc	a5,0x12
    800003fc:	ee878793          	addi	a5,a5,-280 # 800122e0 <cons>
    80000400:	0a07a703          	lw	a4,160(a5)
    80000404:	0017069b          	addiw	a3,a4,1
    80000408:	8636                	mv	a2,a3
    8000040a:	0ad7a023          	sw	a3,160(a5)
    8000040e:	07f77713          	andi	a4,a4,127
    80000412:	97ba                	add	a5,a5,a4
    80000414:	4729                	li	a4,10
    80000416:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041a:	00012797          	auipc	a5,0x12
    8000041e:	f6c7a123          	sw	a2,-158(a5) # 8001237c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	f5650513          	addi	a0,a0,-170 # 80012378 <cons+0x98>
    8000042a:	355010ef          	jal	80001f7e <wakeup>
    8000042e:	b5c1                	j	800002ee <consoleintr+0x32>

0000000080000430 <consoleinit>:

void
consoleinit(void)
{
    80000430:	1141                	addi	sp,sp,-16
    80000432:	e406                	sd	ra,8(sp)
    80000434:	e022                	sd	s0,0(sp)
    80000436:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000438:	00007597          	auipc	a1,0x7
    8000043c:	bc858593          	addi	a1,a1,-1080 # 80007000 <etext>
    80000440:	00012517          	auipc	a0,0x12
    80000444:	ea050513          	addi	a0,a0,-352 # 800122e0 <cons>
    80000448:	720000ef          	jal	80000b68 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	01878793          	addi	a5,a5,24 # 80022468 <devsw>
    80000458:	00000717          	auipc	a4,0x0
    8000045c:	d2070713          	addi	a4,a4,-736 # 80000178 <consoleread>
    80000460:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000462:	00000717          	auipc	a4,0x0
    80000466:	c7470713          	addi	a4,a4,-908 # 800000d6 <consolewrite>
    8000046a:	ef98                	sd	a4,24(a5)
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret

0000000080000474 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000474:	7139                	addi	sp,sp,-64
    80000476:	fc06                	sd	ra,56(sp)
    80000478:	f822                	sd	s0,48(sp)
    8000047a:	f04a                	sd	s2,32(sp)
    8000047c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    8000047e:	c219                	beqz	a2,80000484 <printint+0x10>
    80000480:	08054163          	bltz	a0,80000502 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000484:	4301                	li	t1,0

  i = 0;
    80000486:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000048a:	86ca                	mv	a3,s2
  i = 0;
    8000048c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007817          	auipc	a6,0x7
    80000492:	2a280813          	addi	a6,a6,674 # 80007730 <digits>
    80000496:	88ba                	mv	a7,a4
    80000498:	0017061b          	addiw	a2,a4,1
    8000049c:	8732                	mv	a4,a2
    8000049e:	02b577b3          	remu	a5,a0,a1
    800004a2:	97c2                	add	a5,a5,a6
    800004a4:	0007c783          	lbu	a5,0(a5)
    800004a8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004ac:	87aa                	mv	a5,a0
    800004ae:	02b55533          	divu	a0,a0,a1
    800004b2:	0685                	addi	a3,a3,1
    800004b4:	feb7f1e3          	bgeu	a5,a1,80000496 <printint+0x22>

  if (sign)
    800004b8:	00030c63          	beqz	t1,800004d0 <printint+0x5c>
    buf[i++] = '-';
    800004bc:	fe060793          	addi	a5,a2,-32
    800004c0:	00878633          	add	a2,a5,s0
    800004c4:	02d00793          	li	a5,45
    800004c8:	fef60423          	sb	a5,-24(a2)
    800004cc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004d0:	02e05463          	blez	a4,800004f8 <printint+0x84>
    800004d4:	f426                	sd	s1,40(sp)
    800004d6:	377d                	addiw	a4,a4,-1
    800004d8:	00e904b3          	add	s1,s2,a4
    800004dc:	197d                	addi	s2,s2,-1
    800004de:	993a                	add	s2,s2,a4
    800004e0:	1702                	slli	a4,a4,0x20
    800004e2:	9301                	srli	a4,a4,0x20
    800004e4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004e8:	0004c503          	lbu	a0,0(s1)
    800004ec:	d9fff0ef          	jal	8000028a <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x74>
    800004f6:	74a2                	ld	s1,40(sp)
}
    800004f8:	70e2                	ld	ra,56(sp)
    800004fa:	7442                	ld	s0,48(sp)
    800004fc:	7902                	ld	s2,32(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4305                	li	t1,1
    x = -xx;
    80000508:	bfbd                	j	80000486 <printint+0x12>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	f0ca                	sd	s2,96(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	892a                	mv	s2,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000a797          	auipc	a5,0xa
    8000052c:	d8c7a783          	lw	a5,-628(a5) # 8000a2b4 <panicking>
    80000530:	cf9d                	beqz	a5,8000056e <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	00094503          	lbu	a0,0(s2)
    8000053e:	22050663          	beqz	a0,8000076a <printk+0x260>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	ecce                	sd	s3,88(sp)
    80000546:	e8d2                	sd	s4,80(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	fc5e                	sd	s7,56(sp)
    8000054e:	f862                	sd	s8,48(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4a01                	li	s4,0
    if (cx != '%') {
    80000556:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    8000055a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    8000055e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    80000562:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000566:	4b29                	li	s6,10
    if (c0 == 'd') {
    80000568:	06400b93          	li	s7,100
    8000056c:	a015                	j	80000590 <printk+0x86>
    acquire(&pr.lock);
    8000056e:	00012517          	auipc	a0,0x12
    80000572:	e1a50513          	addi	a0,a0,-486 # 80012388 <pr>
    80000576:	672000ef          	jal	80000be8 <acquire>
    8000057a:	bf65                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057c:	d0fff0ef          	jal	8000028a <consputc>
      continue;
    80000580:	84d2                	mv	s1,s4
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000582:	2485                	addiw	s1,s1,1
    80000584:	8a26                	mv	s4,s1
    80000586:	94ca                	add	s1,s1,s2
    80000588:	0004c503          	lbu	a0,0(s1)
    8000058c:	1c050663          	beqz	a0,80000758 <printk+0x24e>
    if (cx != '%') {
    80000590:	ff3516e3          	bne	a0,s3,8000057c <printk+0x72>
    i++;
    80000594:	001a079b          	addiw	a5,s4,1
    80000598:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000059a:	00f90733          	add	a4,s2,a5
    8000059e:	00074a83          	lbu	s5,0(a4)
    if (c0)
    800005a2:	200a8963          	beqz	s5,800007b4 <printk+0x2aa>
      c1 = fmt[i + 1] & 0xff;
    800005a6:	00174683          	lbu	a3,1(a4)
    if (c1)
    800005aa:	1e068c63          	beqz	a3,800007a2 <printk+0x298>
    if (c0 == 'd') {
    800005ae:	037a8863          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800005b2:	f94a8713          	addi	a4,s5,-108
    800005b6:	00173713          	seqz	a4,a4
    800005ba:	f9c68613          	addi	a2,a3,-100
    800005be:	ee05                	bnez	a2,800005f6 <printk+0xec>
    800005c0:	cb1d                	beqz	a4,800005f6 <printk+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005c2:	f8843783          	ld	a5,-120(s0)
    800005c6:	00878713          	addi	a4,a5,8
    800005ca:	f8e43423          	sd	a4,-120(s0)
    800005ce:	4605                	li	a2,1
    800005d0:	85da                	mv	a1,s6
    800005d2:	6388                	ld	a0,0(a5)
    800005d4:	ea1ff0ef          	jal	80000474 <printint>
      i += 1;
    800005d8:	002a049b          	addiw	s1,s4,2
    800005dc:	b75d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005de:	f8843783          	ld	a5,-120(s0)
    800005e2:	00878713          	addi	a4,a5,8
    800005e6:	f8e43423          	sd	a4,-120(s0)
    800005ea:	4605                	li	a2,1
    800005ec:	85da                	mv	a1,s6
    800005ee:	4388                	lw	a0,0(a5)
    800005f0:	e85ff0ef          	jal	80000474 <printint>
    800005f4:	b779                	j	80000582 <printk+0x78>
      c2 = fmt[i + 2] & 0xff;
    800005f6:	97ca                	add	a5,a5,s2
    800005f8:	8636                	mv	a2,a3
    800005fa:	0027c683          	lbu	a3,2(a5)
    800005fe:	a2c9                	j	800007c0 <printk+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4605                	li	a2,1
    8000060e:	45a9                	li	a1,10
    80000610:	6388                	ld	a0,0(a5)
    80000612:	e63ff0ef          	jal	80000474 <printint>
      i += 2;
    80000616:	003a049b          	addiw	s1,s4,3
    8000061a:	b7a5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000061c:	f8843783          	ld	a5,-120(s0)
    80000620:	00878713          	addi	a4,a5,8
    80000624:	f8e43423          	sd	a4,-120(s0)
    80000628:	4601                	li	a2,0
    8000062a:	85da                	mv	a1,s6
    8000062c:	0007e503          	lwu	a0,0(a5)
    80000630:	e45ff0ef          	jal	80000474 <printint>
    80000634:	b7b9                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4601                	li	a2,0
    80000644:	85da                	mv	a1,s6
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e2dff0ef          	jal	80000474 <printint>
      i += 1;
    8000064c:	002a049b          	addiw	s1,s4,2
    80000650:	bf0d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	e11ff0ef          	jal	80000474 <printint>
      i += 2;
    80000668:	003a049b          	addiw	s1,s4,3
    8000066c:	bf19                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45c1                	li	a1,16
    8000067e:	0007e503          	lwu	a0,0(a5)
    80000682:	df3ff0ef          	jal	80000474 <printint>
    80000686:	bdf5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	45c1                	li	a1,16
    80000696:	6388                	ld	a0,0(a5)
    80000698:	dddff0ef          	jal	80000474 <printint>
      i += 1;
    8000069c:	002a049b          	addiw	s1,s4,2
    800006a0:	b5cd                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	dc1ff0ef          	jal	80000474 <printint>
      i += 2;
    800006b8:	003a049b          	addiw	s1,s4,3
    800006bc:	b5d9                	j	80000582 <printk+0x78>
    800006be:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006c0:	f8843783          	ld	a5,-120(s0)
    800006c4:	00878713          	addi	a4,a5,8
    800006c8:	f8e43423          	sd	a4,-120(s0)
    800006cc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006d0:	03000513          	li	a0,48
    800006d4:	bb7ff0ef          	jal	8000028a <consputc>
  consputc('x');
    800006d8:	07800513          	li	a0,120
    800006dc:	bafff0ef          	jal	8000028a <consputc>
    800006e0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e2:	00007c97          	auipc	s9,0x7
    800006e6:	04ec8c93          	addi	s9,s9,78 # 80007730 <digits>
    800006ea:	03cad793          	srli	a5,s5,0x3c
    800006ee:	97e6                	add	a5,a5,s9
    800006f0:	0007c503          	lbu	a0,0(a5)
    800006f4:	b97ff0ef          	jal	8000028a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006f8:	0a92                	slli	s5,s5,0x4
    800006fa:	3a7d                	addiw	s4,s4,-1
    800006fc:	fe0a17e3          	bnez	s4,800006ea <printk+0x1e0>
    80000700:	7ca2                	ld	s9,40(sp)
    80000702:	b541                	j	80000582 <printk+0x78>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b79ff0ef          	jal	8000028a <consputc>
    80000716:	b5b5                	j	80000582 <printk+0x78>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007ba03          	ld	s4,0(a5)
    80000728:	000a0d63          	beqz	s4,80000742 <printk+0x238>
        s = "(null)";
      for (; *s; s++)
    8000072c:	000a4503          	lbu	a0,0(s4)
    80000730:	e40509e3          	beqz	a0,80000582 <printk+0x78>
        consputc(*s);
    80000734:	b57ff0ef          	jal	8000028a <consputc>
      for (; *s; s++)
    80000738:	0a05                	addi	s4,s4,1
    8000073a:	000a4503          	lbu	a0,0(s4)
    8000073e:	f97d                	bnez	a0,80000734 <printk+0x22a>
    80000740:	b589                	j	80000582 <printk+0x78>
        s = "(null)";
    80000742:	00007a17          	auipc	s4,0x7
    80000746:	8c6a0a13          	addi	s4,s4,-1850 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printk+0x22a>
    } else if (c0 == '%') {
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	b39ff0ef          	jal	8000028a <consputc>
    80000756:	b535                	j	80000582 <printk+0x78>
    80000758:	74a6                	ld	s1,104(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000076a:	0000a797          	auipc	a5,0xa
    8000076e:	b4a7a783          	lw	a5,-1206(a5) # 8000a2b4 <panicking>
    80000772:	c38d                	beqz	a5,80000794 <printk+0x28a>
    release(&pr.lock);

  return 0;
}
    80000774:	4501                	li	a0,0
    80000776:	70e6                	ld	ra,120(sp)
    80000778:	7446                	ld	s0,112(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	6129                	addi	sp,sp,192
    8000077e:	8082                	ret
    80000780:	74a6                	ld	s1,104(sp)
    80000782:	69e6                	ld	s3,88(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6aa6                	ld	s5,72(sp)
    80000788:	6b06                	ld	s6,64(sp)
    8000078a:	7be2                	ld	s7,56(sp)
    8000078c:	7c42                	ld	s8,48(sp)
    8000078e:	7d02                	ld	s10,32(sp)
    80000790:	6de2                	ld	s11,24(sp)
    80000792:	bfe1                	j	8000076a <printk+0x260>
    release(&pr.lock);
    80000794:	00012517          	auipc	a0,0x12
    80000798:	bf450513          	addi	a0,a0,-1036 # 80012388 <pr>
    8000079c:	4d4000ef          	jal	80000c70 <release>
  return 0;
    800007a0:	bfd1                	j	80000774 <printk+0x26a>
    if (c0 == 'd') {
    800007a2:	e37a8ee3          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800007a6:	f94a8713          	addi	a4,s5,-108
    800007aa:	00173713          	seqz	a4,a4
    800007ae:	8636                	mv	a2,a3
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007b0:	4781                	li	a5,0
    800007b2:	a00d                	j	800007d4 <printk+0x2ca>
    } else if (c0 == 'l' && c1 == 'd') {
    800007b4:	f94a8713          	addi	a4,s5,-108
    800007b8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007bc:	8656                	mv	a2,s5
    800007be:	86d6                	mv	a3,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007c0:	f9460793          	addi	a5,a2,-108
    800007c4:	0017b793          	seqz	a5,a5
    800007c8:	8ff9                	and	a5,a5,a4
    800007ca:	f9c68593          	addi	a1,a3,-100
    800007ce:	e199                	bnez	a1,800007d4 <printk+0x2ca>
    800007d0:	e20798e3          	bnez	a5,80000600 <printk+0xf6>
    } else if (c0 == 'u') {
    800007d4:	e58a84e3          	beq	s5,s8,8000061c <printk+0x112>
    } else if (c0 == 'l' && c1 == 'u') {
    800007d8:	f8b60593          	addi	a1,a2,-117
    800007dc:	e199                	bnez	a1,800007e2 <printk+0x2d8>
    800007de:	e4071ce3          	bnez	a4,80000636 <printk+0x12c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007e2:	f8b68593          	addi	a1,a3,-117
    800007e6:	e199                	bnez	a1,800007ec <printk+0x2e2>
    800007e8:	e60795e3          	bnez	a5,80000652 <printk+0x148>
    } else if (c0 == 'x') {
    800007ec:	e9aa81e3          	beq	s5,s10,8000066e <printk+0x164>
    } else if (c0 == 'l' && c1 == 'x') {
    800007f0:	f8860613          	addi	a2,a2,-120
    800007f4:	e219                	bnez	a2,800007fa <printk+0x2f0>
    800007f6:	e80719e3          	bnez	a4,80000688 <printk+0x17e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007fa:	f8868693          	addi	a3,a3,-120
    800007fe:	e299                	bnez	a3,80000804 <printk+0x2fa>
    80000800:	ea0791e3          	bnez	a5,800006a2 <printk+0x198>
    } else if (c0 == 'p') {
    80000804:	ebba8de3          	beq	s5,s11,800006be <printk+0x1b4>
    } else if (c0 == 'c') {
    80000808:	06300793          	li	a5,99
    8000080c:	eefa8ce3          	beq	s5,a5,80000704 <printk+0x1fa>
    } else if (c0 == 's') {
    80000810:	07300793          	li	a5,115
    80000814:	f0fa82e3          	beq	s5,a5,80000718 <printk+0x20e>
    } else if (c0 == '%') {
    80000818:	02500793          	li	a5,37
    8000081c:	f2fa8ae3          	beq	s5,a5,80000750 <printk+0x246>
    } else if (c0 == 0) {
    80000820:	f60a80e3          	beqz	s5,80000780 <printk+0x276>
      consputc('%');
    80000824:	02500513          	li	a0,37
    80000828:	a63ff0ef          	jal	8000028a <consputc>
      consputc(c0);
    8000082c:	8556                	mv	a0,s5
    8000082e:	a5dff0ef          	jal	8000028a <consputc>
    80000832:	bb81                	j	80000582 <printk+0x78>

0000000080000834 <panic>:

void
panic(char *s)
{
    80000834:	1101                	addi	sp,sp,-32
    80000836:	ec06                	sd	ra,24(sp)
    80000838:	e822                	sd	s0,16(sp)
    8000083a:	e426                	sd	s1,8(sp)
    8000083c:	e04a                	sd	s2,0(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	892a                	mv	s2,a0
  panicking = 1;
    80000842:	4485                	li	s1,1
    80000844:	0000a797          	auipc	a5,0xa
    80000848:	a697a823          	sw	s1,-1424(a5) # 8000a2b4 <panicking>
  printk("panic: ");
    8000084c:	00006517          	auipc	a0,0x6
    80000850:	7cc50513          	addi	a0,a0,1996 # 80007018 <etext+0x18>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00006517          	auipc	a0,0x6
    8000085e:	7c650513          	addi	a0,a0,1990 # 80007020 <etext+0x20>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	a497a523          	sw	s1,-1462(a5) # 8000a2b0 <panicked>
  for (;;)
    8000086e:	a001                	j	8000086e <panic+0x3a>

0000000080000870 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000870:	1141                	addi	sp,sp,-16
    80000872:	e406                	sd	ra,8(sp)
    80000874:	e022                	sd	s0,0(sp)
    80000876:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b058593          	addi	a1,a1,1968 # 80007028 <etext+0x28>
    80000880:	00012517          	auipc	a0,0x12
    80000884:	b0850513          	addi	a0,a0,-1272 # 80012388 <pr>
    80000888:	2e0000ef          	jal	80000b68 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000894:	1141                	addi	sp,sp,-16
    80000896:	e406                	sd	ra,8(sp)
    80000898:	e022                	sd	s0,0(sp)
    8000089a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000089c:	100007b7          	lui	a5,0x10000
    800008a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008a4:	10000737          	lui	a4,0x10000
    800008a8:	f8000693          	li	a3,-128
    800008ac:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b0:	468d                	li	a3,3
    800008b2:	10000637          	lui	a2,0x10000
    800008b6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008be:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c2:	8732                	mv	a4,a2
    800008c4:	461d                	li	a2,7
    800008c6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ca:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    800008ce:	00006597          	auipc	a1,0x6
    800008d2:	76258593          	addi	a1,a1,1890 # 80007030 <etext+0x30>
    800008d6:	00012517          	auipc	a0,0x12
    800008da:	aca50513          	addi	a0,a0,-1334 # 800123a0 <tx_lock>
    800008de:	69c030ef          	jal	80003f7a <initsleeplock>
}
    800008e2:	60a2                	ld	ra,8(sp)
    800008e4:	6402                	ld	s0,0(sp)
    800008e6:	0141                	addi	sp,sp,16
    800008e8:	8082                	ret

00000000800008ea <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ea:	7139                	addi	sp,sp,-64
    800008ec:	fc06                	sd	ra,56(sp)
    800008ee:	f822                	sd	s0,48(sp)
    800008f0:	f04a                	sd	s2,32(sp)
    800008f2:	e456                	sd	s5,8(sp)
    800008f4:	0080                	addi	s0,sp,64
    800008f6:	8aaa                	mv	s5,a0
    800008f8:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008fa:	00012517          	auipc	a0,0x12
    800008fe:	aa650513          	addi	a0,a0,-1370 # 800123a0 <tx_lock>
    80000902:	6ae030ef          	jal	80003fb0 <acquiresleep>

  int i = 0;
  while (i < n) {
    80000906:	05205963          	blez	s2,80000958 <uartwrite+0x6e>
    8000090a:	f426                	sd	s1,40(sp)
    8000090c:	ec4e                	sd	s3,24(sp)
    8000090e:	e852                	sd	s4,16(sp)
    80000910:	e05a                	sd	s6,0(sp)
  int i = 0;
    80000912:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    80000914:	0000aa17          	auipc	s4,0xa
    80000918:	9a4a0a13          	addi	s4,s4,-1628 # 8000a2b8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    8000091c:	100009b7          	lui	s3,0x10000
    80000920:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    80000922:	10000b37          	lui	s6,0x10000
    80000926:	a029                	j	80000930 <uartwrite+0x46>
      i += 1;
    } else {
      sleep();
    80000928:	626010ef          	jal	80001f4e <sleep>
  while (i < n) {
    8000092c:	0324d263          	bge	s1,s2,80000950 <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    80000930:	8552                	mv	a0,s4
    80000932:	5e0010ef          	jal	80001f12 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    80000936:	0009c783          	lbu	a5,0(s3)
    8000093a:	0207f793          	andi	a5,a5,32
    8000093e:	d7ed                	beqz	a5,80000928 <uartwrite+0x3e>
      WriteReg(THR, buf[i]);
    80000940:	009a87b3          	add	a5,s5,s1
    80000944:	0007c783          	lbu	a5,0(a5)
    80000948:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    8000094c:	2485                	addiw	s1,s1,1
    8000094e:	bff9                	j	8000092c <uartwrite+0x42>
    80000950:	74a2                	ld	s1,40(sp)
    80000952:	69e2                	ld	s3,24(sp)
    80000954:	6a42                	ld	s4,16(sp)
    80000956:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000958:	00012517          	auipc	a0,0x12
    8000095c:	a4850513          	addi	a0,a0,-1464 # 800123a0 <tx_lock>
    80000960:	6a4030ef          	jal	80004004 <releasesleep>
}
    80000964:	70e2                	ld	ra,56(sp)
    80000966:	7442                	ld	s0,48(sp)
    80000968:	7902                	ld	s2,32(sp)
    8000096a:	6aa2                	ld	s5,8(sp)
    8000096c:	6121                	addi	sp,sp,64
    8000096e:	8082                	ret

0000000080000970 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000970:	1101                	addi	sp,sp,-32
    80000972:	ec06                	sd	ra,24(sp)
    80000974:	e822                	sd	s0,16(sp)
    80000976:	e426                	sd	s1,8(sp)
    80000978:	1000                	addi	s0,sp,32
    8000097a:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000097c:	0000a797          	auipc	a5,0xa
    80000980:	9387a783          	lw	a5,-1736(a5) # 8000a2b4 <panicking>
    80000984:	cf95                	beqz	a5,800009c0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000986:	0000a797          	auipc	a5,0xa
    8000098a:	92a7a783          	lw	a5,-1750(a5) # 8000a2b0 <panicked>
    8000098e:	ef85                	bnez	a5,800009c6 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000990:	10000737          	lui	a4,0x10000
    80000994:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	00074783          	lbu	a5,0(a4)
    8000099a:	0207f793          	andi	a5,a5,32
    8000099e:	dfe5                	beqz	a5,80000996 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    800009a0:	0ff4f513          	zext.b	a0,s1
    800009a4:	100007b7          	lui	a5,0x10000
    800009a8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    800009ac:	0000a797          	auipc	a5,0xa
    800009b0:	9087a783          	lw	a5,-1784(a5) # 8000a2b4 <panicking>
    800009b4:	cb91                	beqz	a5,800009c8 <uartputc_sync+0x58>
    pop_off();
}
    800009b6:	60e2                	ld	ra,24(sp)
    800009b8:	6442                	ld	s0,16(sp)
    800009ba:	64a2                	ld	s1,8(sp)
    800009bc:	6105                	addi	sp,sp,32
    800009be:	8082                	ret
    push_off();
    800009c0:	1ee000ef          	jal	80000bae <push_off>
    800009c4:	b7c9                	j	80000986 <uartputc_sync+0x16>
    for (;;)
    800009c6:	a001                	j	800009c6 <uartputc_sync+0x56>
    pop_off();
    800009c8:	260000ef          	jal	80000c28 <pop_off>
}
    800009cc:	b7ed                	j	800009b6 <uartputc_sync+0x46>

00000000800009ce <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ce:	1101                	addi	sp,sp,-32
    800009d0:	ec06                	sd	ra,24(sp)
    800009d2:	e822                	sd	s0,16(sp)
    800009d4:	e426                	sd	s1,8(sp)
    800009d6:	e04a                	sd	s2,0(sp)
    800009d8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009e2:	100007b7          	lui	a5,0x10000
    800009e6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ea:	0207f793          	andi	a5,a5,32
    800009ee:	ef99                	bnez	a5,80000a0c <uartintr+0x3e>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009f0:	100004b7          	lui	s1,0x10000
    800009f4:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009f6:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009fa:	0004c783          	lbu	a5,0(s1)
    800009fe:	8b85                	andi	a5,a5,1
    80000a00:	cf89                	beqz	a5,80000a1a <uartintr+0x4c>
    return ReadReg(RHR);
    80000a02:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a06:	8b7ff0ef          	jal	800002bc <consoleintr>
  while (1) {
    80000a0a:	bfc5                	j	800009fa <uartintr+0x2c>
    wakeup(&tx_chan);
    80000a0c:	0000a517          	auipc	a0,0xa
    80000a10:	8ac50513          	addi	a0,a0,-1876 # 8000a2b8 <tx_chan>
    80000a14:	56a010ef          	jal	80001f7e <wakeup>
    80000a18:	bfe1                	j	800009f0 <uartintr+0x22>
  }
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6902                	ld	s2,0(sp)
    80000a22:	6105                	addi	sp,sp,32
    80000a24:	8082                	ret

0000000080000a26 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	e04a                	sd	s2,0(sp)
    80000a30:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a32:	00023797          	auipc	a5,0x23
    80000a36:	bce78793          	addi	a5,a5,-1074 # 80023600 <end>
    80000a3a:	00f53733          	sltu	a4,a0,a5
    80000a3e:	47c5                	li	a5,17
    80000a40:	07ee                	slli	a5,a5,0x1b
    80000a42:	17fd                	addi	a5,a5,-1
    80000a44:	00a7b7b3          	sltu	a5,a5,a0
    80000a48:	8fd9                	or	a5,a5,a4
    80000a4a:	ef95                	bnez	a5,80000a86 <kfree+0x60>
    80000a4c:	84aa                	mv	s1,a0
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	eb95                	bnez	a5,80000a86 <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a54:	6605                	lui	a2,0x1
    80000a56:	4585                	li	a1,1
    80000a58:	250000ef          	jal	80000ca8 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a5c:	00012917          	auipc	s2,0x12
    80000a60:	97490913          	addi	s2,s2,-1676 # 800123d0 <kmem>
    80000a64:	854a                	mv	a0,s2
    80000a66:	182000ef          	jal	80000be8 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	1fa000ef          	jal	80000c70 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
    panic("kfree");
    80000a86:	00006517          	auipc	a0,0x6
    80000a8a:	5b250513          	addi	a0,a0,1458 # 80007038 <etext+0x38>
    80000a8e:	da7ff0ef          	jal	80000834 <panic>

0000000080000a92 <freerange>:
{
    80000a92:	7179                	addi	sp,sp,-48
    80000a94:	f406                	sd	ra,40(sp)
    80000a96:	f022                	sd	s0,32(sp)
    80000a98:	ec26                	sd	s1,24(sp)
    80000a9a:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a9c:	6785                	lui	a5,0x1
    80000a9e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aa2:	00e504b3          	add	s1,a0,a4
    80000aa6:	777d                	lui	a4,0xfffff
    80000aa8:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aaa:	94be                	add	s1,s1,a5
    80000aac:	0295e263          	bltu	a1,s1,80000ad0 <freerange+0x3e>
    80000ab0:	e84a                	sd	s2,16(sp)
    80000ab2:	e44e                	sd	s3,8(sp)
    80000ab4:	e052                	sd	s4,0(sp)
    80000ab6:	892e                	mv	s2,a1
    kfree(p);
    80000ab8:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aba:	89be                	mv	s3,a5
    kfree(p);
    80000abc:	01448533          	add	a0,s1,s4
    80000ac0:	f67ff0ef          	jal	80000a26 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ac4:	94ce                	add	s1,s1,s3
    80000ac6:	fe997be3          	bgeu	s2,s1,80000abc <freerange+0x2a>
    80000aca:	6942                	ld	s2,16(sp)
    80000acc:	69a2                	ld	s3,8(sp)
    80000ace:	6a02                	ld	s4,0(sp)
}
    80000ad0:	70a2                	ld	ra,40(sp)
    80000ad2:	7402                	ld	s0,32(sp)
    80000ad4:	64e2                	ld	s1,24(sp)
    80000ad6:	6145                	addi	sp,sp,48
    80000ad8:	8082                	ret

0000000080000ada <kinit>:
{
    80000ada:	1141                	addi	sp,sp,-16
    80000adc:	e406                	sd	ra,8(sp)
    80000ade:	e022                	sd	s0,0(sp)
    80000ae0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ae2:	00006597          	auipc	a1,0x6
    80000ae6:	55e58593          	addi	a1,a1,1374 # 80007040 <etext+0x40>
    80000aea:	00012517          	auipc	a0,0x12
    80000aee:	8e650513          	addi	a0,a0,-1818 # 800123d0 <kmem>
    80000af2:	076000ef          	jal	80000b68 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000af6:	45c5                	li	a1,17
    80000af8:	05ee                	slli	a1,a1,0x1b
    80000afa:	00023517          	auipc	a0,0x23
    80000afe:	b0650513          	addi	a0,a0,-1274 # 80023600 <end>
    80000b02:	f91ff0ef          	jal	80000a92 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00012517          	auipc	a0,0x12
    80000b1c:	8b850513          	addi	a0,a0,-1864 # 800123d0 <kmem>
    80000b20:	0c8000ef          	jal	80000be8 <acquire>
  r = kmem.freelist;
    80000b24:	00012497          	auipc	s1,0x12
    80000b28:	8c44b483          	ld	s1,-1852(s1) # 800123e8 <kmem+0x18>
  if (r)
    80000b2c:	c49d                	beqz	s1,80000b5a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00012717          	auipc	a4,0x12
    80000b34:	8af73c23          	sd	a5,-1864(a4) # 800123e8 <kmem+0x18>
  release(&kmem.lock);
    80000b38:	00012517          	auipc	a0,0x12
    80000b3c:	89850513          	addi	a0,a0,-1896 # 800123d0 <kmem>
    80000b40:	130000ef          	jal	80000c70 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b44:	6605                	lui	a2,0x1
    80000b46:	4595                	li	a1,5
    80000b48:	8526                	mv	a0,s1
    80000b4a:	15e000ef          	jal	80000ca8 <memset>
  return (void *)r;
}
    80000b4e:	8526                	mv	a0,s1
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret
  release(&kmem.lock);
    80000b5a:	00012517          	auipc	a0,0x12
    80000b5e:	87650513          	addi	a0,a0,-1930 # 800123d0 <kmem>
    80000b62:	10e000ef          	jal	80000c70 <release>
  if (r)
    80000b66:	b7e5                	j	80000b4e <kalloc+0x40>

0000000080000b68 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b68:	1141                	addi	sp,sp,-16
    80000b6a:	e406                	sd	ra,8(sp)
    80000b6c:	e022                	sd	s0,0(sp)
    80000b6e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b70:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b72:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b76:	00053823          	sd	zero,16(a0)
}
    80000b7a:	60a2                	ld	ra,8(sp)
    80000b7c:	6402                	ld	s0,0(sp)
    80000b7e:	0141                	addi	sp,sp,16
    80000b80:	8082                	ret

0000000080000b82 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	411c                	lw	a5,0(a0)
    80000b84:	e399                	bnez	a5,80000b8a <holding+0x8>
    80000b86:	4501                	li	a0,0
  return r;
}
    80000b88:	8082                	ret
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	691c                	ld	a5,16(a0)
    80000b96:	84be                	mv	s1,a5
    80000b98:	551000ef          	jal	800018e8 <mycpu>
    80000b9c:	40a48533          	sub	a0,s1,a0
    80000ba0:	00153513          	seqz	a0,a0
}
    80000ba4:	60e2                	ld	ra,24(sp)
    80000ba6:	6442                	ld	s0,16(sp)
    80000ba8:	64a2                	ld	s1,8(sp)
    80000baa:	6105                	addi	sp,sp,32
    80000bac:	8082                	ret

0000000080000bae <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bae:	1101                	addi	sp,sp,-32
    80000bb0:	ec06                	sd	ra,24(sp)
    80000bb2:	e822                	sd	s0,16(sp)
    80000bb4:	e426                	sd	s1,8(sp)
    80000bb6:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000bb8:	100177f3          	csrrci	a5,sstatus,2
    80000bbc:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000bbe:	52b000ef          	jal	800018e8 <mycpu>
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	cb99                	beqz	a5,80000bda <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc6:	523000ef          	jal	800018e8 <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	50f000ef          	jal	800018e8 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000bde:	0014d793          	srli	a5,s1,0x1
    80000be2:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000be4:	dd7c                	sw	a5,124(a0)
    80000be6:	b7c5                	j	80000bc6 <push_off+0x18>

0000000080000be8 <acquire>:
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
    80000bf2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf4:	fbbff0ef          	jal	80000bae <push_off>
  if (holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	f89ff0ef          	jal	80000b82 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bfe:	4705                	li	a4,1
  if (holding(lk))
    80000c00:	ed11                	bnez	a0,80000c1c <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c02:	87ba                	mv	a5,a4
    80000c04:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c08:	2781                	sext.w	a5,a5
    80000c0a:	ffe5                	bnez	a5,80000c02 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c0c:	4dd000ef          	jal	800018e8 <mycpu>
    80000c10:	e888                	sd	a0,16(s1)
}
    80000c12:	60e2                	ld	ra,24(sp)
    80000c14:	6442                	ld	s0,16(sp)
    80000c16:	64a2                	ld	s1,8(sp)
    80000c18:	6105                	addi	sp,sp,32
    80000c1a:	8082                	ret
    panic("acquire");
    80000c1c:	00006517          	auipc	a0,0x6
    80000c20:	42c50513          	addi	a0,a0,1068 # 80007048 <etext+0x48>
    80000c24:	c11ff0ef          	jal	80000834 <panic>

0000000080000c28 <pop_off>:

void
pop_off(void)
{
    80000c28:	1141                	addi	sp,sp,-16
    80000c2a:	e406                	sd	ra,8(sp)
    80000c2c:	e022                	sd	s0,0(sp)
    80000c2e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c30:	4b9000ef          	jal	800018e8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c3a:	ef99                	bnez	a5,80000c58 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05363          	blez	a5,80000c64 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c46:	e789                	bnez	a5,80000c50 <pop_off+0x28>
    80000c48:	5d7c                	lw	a5,124(a0)
    80000c4a:	c399                	beqz	a5,80000c50 <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c4c:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c50:	60a2                	ld	ra,8(sp)
    80000c52:	6402                	ld	s0,0(sp)
    80000c54:	0141                	addi	sp,sp,16
    80000c56:	8082                	ret
    panic("pop_off - interruptible");
    80000c58:	00006517          	auipc	a0,0x6
    80000c5c:	3f850513          	addi	a0,a0,1016 # 80007050 <etext+0x50>
    80000c60:	bd5ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000c64:	00006517          	auipc	a0,0x6
    80000c68:	40450513          	addi	a0,a0,1028 # 80007068 <etext+0x68>
    80000c6c:	bc9ff0ef          	jal	80000834 <panic>

0000000080000c70 <release>:
{
    80000c70:	1101                	addi	sp,sp,-32
    80000c72:	ec06                	sd	ra,24(sp)
    80000c74:	e822                	sd	s0,16(sp)
    80000c76:	e426                	sd	s1,8(sp)
    80000c78:	1000                	addi	s0,sp,32
    80000c7a:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c7c:	f07ff0ef          	jal	80000b82 <holding>
    80000c80:	cd11                	beqz	a0,80000c9c <release+0x2c>
  lk->cpu = 0;
    80000c82:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c86:	0310000f          	fence	rw,w
    80000c8a:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c8e:	f9bff0ef          	jal	80000c28 <pop_off>
}
    80000c92:	60e2                	ld	ra,24(sp)
    80000c94:	6442                	ld	s0,16(sp)
    80000c96:	64a2                	ld	s1,8(sp)
    80000c98:	6105                	addi	sp,sp,32
    80000c9a:	8082                	ret
    panic("release");
    80000c9c:	00006517          	auipc	a0,0x6
    80000ca0:	3d450513          	addi	a0,a0,980 # 80007070 <etext+0x70>
    80000ca4:	b91ff0ef          	jal	80000834 <panic>

0000000080000ca8 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000ca8:	1141                	addi	sp,sp,-16
    80000caa:	e406                	sd	ra,8(sp)
    80000cac:	e022                	sd	s0,0(sp)
    80000cae:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000cb0:	ca19                	beqz	a2,80000cc6 <memset+0x1e>
    80000cb2:	87aa                	mv	a5,a0
    80000cb4:	1602                	slli	a2,a2,0x20
    80000cb6:	9201                	srli	a2,a2,0x20
    80000cb8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cbc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cc0:	0785                	addi	a5,a5,1
    80000cc2:	fee79de3          	bne	a5,a4,80000cbc <memset+0x14>
  }
  return dst;
}
    80000cc6:	60a2                	ld	ra,8(sp)
    80000cc8:	6402                	ld	s0,0(sp)
    80000cca:	0141                	addi	sp,sp,16
    80000ccc:	8082                	ret

0000000080000cce <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000cd6:	c61d                	beqz	a2,80000d04 <memcmp+0x36>
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000ce0:	00054783          	lbu	a5,0(a0)
    80000ce4:	0005c703          	lbu	a4,0(a1)
    80000ce8:	00e79863          	bne	a5,a4,80000cf8 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000cec:	0505                	addi	a0,a0,1
    80000cee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000cf0:	fed518e3          	bne	a0,a3,80000ce0 <memcmp+0x12>
  }

  return 0;
    80000cf4:	4501                	li	a0,0
    80000cf6:	a019                	j	80000cfc <memcmp+0x2e>
      return *s1 - *s2;
    80000cf8:	40e7853b          	subw	a0,a5,a4
}
    80000cfc:	60a2                	ld	ra,8(sp)
    80000cfe:	6402                	ld	s0,0(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret
  return 0;
    80000d04:	4501                	li	a0,0
    80000d06:	bfdd                	j	80000cfc <memcmp+0x2e>

0000000080000d08 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d08:	1141                	addi	sp,sp,-16
    80000d0a:	e406                	sd	ra,8(sp)
    80000d0c:	e022                	sd	s0,0(sp)
    80000d0e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d10:	c205                	beqz	a2,80000d30 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d12:	02a5e363          	bltu	a1,a0,80000d38 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d16:	1602                	slli	a2,a2,0x20
    80000d18:	9201                	srli	a2,a2,0x20
    80000d1a:	00c587b3          	add	a5,a1,a2
{
    80000d1e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d20:	0585                	addi	a1,a1,1
    80000d22:	0705                	addi	a4,a4,1
    80000d24:	fff5c683          	lbu	a3,-1(a1)
    80000d28:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d2c:	feb79ae3          	bne	a5,a1,80000d20 <memmove+0x18>

  return dst;
}
    80000d30:	60a2                	ld	ra,8(sp)
    80000d32:	6402                	ld	s0,0(sp)
    80000d34:	0141                	addi	sp,sp,16
    80000d36:	8082                	ret
  if (s < d && s + n > d) {
    80000d38:	02061693          	slli	a3,a2,0x20
    80000d3c:	9281                	srli	a3,a3,0x20
    80000d3e:	00d58733          	add	a4,a1,a3
    80000d42:	fce57ae3          	bgeu	a0,a4,80000d16 <memmove+0xe>
    d += n;
    80000d46:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d48:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d4c:	1782                	slli	a5,a5,0x20
    80000d4e:	9381                	srli	a5,a5,0x20
    80000d50:	fff7c793          	not	a5,a5
    80000d54:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d56:	177d                	addi	a4,a4,-1
    80000d58:	16fd                	addi	a3,a3,-1
    80000d5a:	00074603          	lbu	a2,0(a4)
    80000d5e:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d62:	fee79ae3          	bne	a5,a4,80000d56 <memmove+0x4e>
    80000d66:	b7e9                	j	80000d30 <memmove+0x28>

0000000080000d68 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d68:	1141                	addi	sp,sp,-16
    80000d6a:	e406                	sd	ra,8(sp)
    80000d6c:	e022                	sd	s0,0(sp)
    80000d6e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d70:	f99ff0ef          	jal	80000d08 <memmove>
}
    80000d74:	60a2                	ld	ra,8(sp)
    80000d76:	6402                	ld	s0,0(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret

0000000080000d7c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e406                	sd	ra,8(sp)
    80000d80:	e022                	sd	s0,0(sp)
    80000d82:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d84:	ce11                	beqz	a2,80000da0 <strncmp+0x24>
    80000d86:	00054783          	lbu	a5,0(a0)
    80000d8a:	cf89                	beqz	a5,80000da4 <strncmp+0x28>
    80000d8c:	0005c703          	lbu	a4,0(a1)
    80000d90:	00f71a63          	bne	a4,a5,80000da4 <strncmp+0x28>
    n--, p++, q++;
    80000d94:	367d                	addiw	a2,a2,-1
    80000d96:	0505                	addi	a0,a0,1
    80000d98:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d9a:	f675                	bnez	a2,80000d86 <strncmp+0xa>
  if (n == 0)
    return 0;
    80000d9c:	4501                	li	a0,0
    80000d9e:	a801                	j	80000dae <strncmp+0x32>
    80000da0:	4501                	li	a0,0
    80000da2:	a031                	j	80000dae <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000da4:	00054503          	lbu	a0,0(a0)
    80000da8:	0005c783          	lbu	a5,0(a1)
    80000dac:	9d1d                	subw	a0,a0,a5
}
    80000dae:	60a2                	ld	ra,8(sp)
    80000db0:	6402                	ld	s0,0(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e406                	sd	ra,8(sp)
    80000dba:	e022                	sd	s0,0(sp)
    80000dbc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000dbe:	87aa                	mv	a5,a0
    80000dc0:	a011                	j	80000dc4 <strncpy+0xe>
    80000dc2:	8636                	mv	a2,a3
    80000dc4:	02c05863          	blez	a2,80000df4 <strncpy+0x3e>
    80000dc8:	fff6069b          	addiw	a3,a2,-1
    80000dcc:	8836                	mv	a6,a3
    80000dce:	0785                	addi	a5,a5,1
    80000dd0:	0005c703          	lbu	a4,0(a1)
    80000dd4:	fee78fa3          	sb	a4,-1(a5)
    80000dd8:	0585                	addi	a1,a1,1
    80000dda:	f765                	bnez	a4,80000dc2 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000ddc:	873e                	mv	a4,a5
    80000dde:	01005b63          	blez	a6,80000df4 <strncpy+0x3e>
    80000de2:	9fb1                	addw	a5,a5,a2
    80000de4:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000de6:	0705                	addi	a4,a4,1
    80000de8:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000dec:	40e786bb          	subw	a3,a5,a4
    80000df0:	fed04be3          	bgtz	a3,80000de6 <strncpy+0x30>
  return os;
}
    80000df4:	60a2                	ld	ra,8(sp)
    80000df6:	6402                	ld	s0,0(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret

0000000080000dfc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e04:	02c05363          	blez	a2,80000e2a <safestrcpy+0x2e>
    80000e08:	fff6069b          	addiw	a3,a2,-1
    80000e0c:	1682                	slli	a3,a3,0x20
    80000e0e:	9281                	srli	a3,a3,0x20
    80000e10:	96ae                	add	a3,a3,a1
    80000e12:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e14:	00d58963          	beq	a1,a3,80000e26 <safestrcpy+0x2a>
    80000e18:	0585                	addi	a1,a1,1
    80000e1a:	0785                	addi	a5,a5,1
    80000e1c:	fff5c703          	lbu	a4,-1(a1)
    80000e20:	fee78fa3          	sb	a4,-1(a5)
    80000e24:	fb65                	bnez	a4,80000e14 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e26:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e2a:	60a2                	ld	ra,8(sp)
    80000e2c:	6402                	ld	s0,0(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <strlen>:

int
strlen(const char *s)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e406                	sd	ra,8(sp)
    80000e36:	e022                	sd	s0,0(sp)
    80000e38:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e3a:	00054783          	lbu	a5,0(a0)
    80000e3e:	cf91                	beqz	a5,80000e5a <strlen+0x28>
    80000e40:	00150793          	addi	a5,a0,1
    80000e44:	86be                	mv	a3,a5
    80000e46:	0785                	addi	a5,a5,1
    80000e48:	fff7c703          	lbu	a4,-1(a5)
    80000e4c:	ff65                	bnez	a4,80000e44 <strlen+0x12>
    80000e4e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e52:	60a2                	ld	ra,8(sp)
    80000e54:	6402                	ld	s0,0(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e5a:	4501                	li	a0,0
    80000e5c:	bfdd                	j	80000e52 <strlen+0x20>

0000000080000e5e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e406                	sd	ra,8(sp)
    80000e62:	e022                	sd	s0,0(sp)
    80000e64:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e66:	26f000ef          	jal	800018d4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e6a:	00009717          	auipc	a4,0x9
    80000e6e:	45270713          	addi	a4,a4,1106 # 8000a2bc <started>
  if (cpuid() == 0) {
    80000e72:	c51d                	beqz	a0,80000ea0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e74:	431c                	lw	a5,0(a4)
    80000e76:	0230000f          	fence	r,rw
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dfe5                	beqz	a5,80000e74 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e7e:	257000ef          	jal	800018d4 <cpuid>
    80000e82:	85aa                	mv	a1,a0
    80000e84:	00006517          	auipc	a0,0x6
    80000e88:	21450513          	addi	a0,a0,532 # 80007098 <etext+0x98>
    80000e8c:	e7eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e90:	082000ef          	jal	80000f12 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e94:	5da010ef          	jal	8000246e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e98:	790040ef          	jal	80005628 <plicinithart>
  }

  scheduler();
    80000e9c:	6db000ef          	jal	80001d76 <scheduler>
    consoleinit();
    80000ea0:	d90ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ea4:	9cdff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ea8:	00006517          	auipc	a0,0x6
    80000eac:	1d050513          	addi	a0,a0,464 # 80007078 <etext+0x78>
    80000eb0:	e5aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000eb4:	00006517          	auipc	a0,0x6
    80000eb8:	1cc50513          	addi	a0,a0,460 # 80007080 <etext+0x80>
    80000ebc:	e4eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000ec0:	00006517          	auipc	a0,0x6
    80000ec4:	1b850513          	addi	a0,a0,440 # 80007078 <etext+0x78>
    80000ec8:	e42ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000ecc:	c0fff0ef          	jal	80000ada <kinit>
    kvminit();          // create kernel page table
    80000ed0:	2ce000ef          	jal	8000119e <kvminit>
    kvminithart();      // turn on paging
    80000ed4:	03e000ef          	jal	80000f12 <kvminithart>
    procinit();         // process table
    80000ed8:	147000ef          	jal	8000181e <procinit>
    trapinit();         // trap vectors
    80000edc:	56e010ef          	jal	8000244a <trapinit>
    trapinithart();     // install kernel trap vector
    80000ee0:	58e010ef          	jal	8000246e <trapinithart>
    plicinit();         // set up interrupt controller
    80000ee4:	72a040ef          	jal	8000560e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000ee8:	740040ef          	jal	80005628 <plicinithart>
    binit();            // buffer cache
    80000eec:	421010ef          	jal	80002b0c <binit>
    iinit();            // inode table
    80000ef0:	172020ef          	jal	80003062 <iinit>
    fileinit();         // file table
    80000ef4:	192030ef          	jal	80004086 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ef8:	021040ef          	jal	80005718 <virtio_disk_init>
    userinit();         // first user process
    80000efc:	4cf000ef          	jal	80001bca <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f00:	00009797          	auipc	a5,0x9
    80000f04:	3bc78793          	addi	a5,a5,956 # 8000a2bc <started>
    80000f08:	4705                	li	a4,1
    80000f0a:	0310000f          	fence	rw,w
    80000f0e:	c398                	sw	a4,0(a5)
    80000f10:	b771                	j	80000e9c <main+0x3e>

0000000080000f12 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f12:	1141                	addi	sp,sp,-16
    80000f14:	e406                	sd	ra,8(sp)
    80000f16:	e022                	sd	s0,0(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	3a27b783          	ld	a5,930(a5) # 8000a2c0 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	60a2                	ld	ra,8(sp)
    80000f38:	6402                	ld	s0,0(sp)
    80000f3a:	0141                	addi	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3e:	7139                	addi	sp,sp,-64
    80000f40:	fc06                	sd	ra,56(sp)
    80000f42:	f822                	sd	s0,48(sp)
    80000f44:	f426                	sd	s1,40(sp)
    80000f46:	f04a                	sd	s2,32(sp)
    80000f48:	ec4e                	sd	s3,24(sp)
    80000f4a:	e852                	sd	s4,16(sp)
    80000f4c:	e456                	sd	s5,8(sp)
    80000f4e:	e05a                	sd	s6,0(sp)
    80000f50:	0080                	addi	s0,sp,64
    80000f52:	84aa                	mv	s1,a0
    80000f54:	89ae                	mv	s3,a1
    80000f56:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f58:	57fd                	li	a5,-1
    80000f5a:	83e9                	srli	a5,a5,0x1a
    80000f5c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f5e:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000f60:	04b7e263          	bltu	a5,a1,80000fa4 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f64:	0149d933          	srl	s2,s3,s4
    80000f68:	1ff97913          	andi	s2,s2,511
    80000f6c:	090e                	slli	s2,s2,0x3
    80000f6e:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f70:	00093483          	ld	s1,0(s2)
    80000f74:	0014f793          	andi	a5,s1,1
    80000f78:	cf85                	beqz	a5,80000fb0 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f7a:	80a9                	srli	s1,s1,0xa
    80000f7c:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000f7e:	3a5d                	addiw	s4,s4,-9
    80000f80:	ff5a12e3          	bne	s4,s5,80000f64 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000f84:	00c9d513          	srli	a0,s3,0xc
    80000f88:	1ff57513          	andi	a0,a0,511
    80000f8c:	050e                	slli	a0,a0,0x3
    80000f8e:	9526                	add	a0,a0,s1
}
    80000f90:	70e2                	ld	ra,56(sp)
    80000f92:	7442                	ld	s0,48(sp)
    80000f94:	74a2                	ld	s1,40(sp)
    80000f96:	7902                	ld	s2,32(sp)
    80000f98:	69e2                	ld	s3,24(sp)
    80000f9a:	6a42                	ld	s4,16(sp)
    80000f9c:	6aa2                	ld	s5,8(sp)
    80000f9e:	6b02                	ld	s6,0(sp)
    80000fa0:	6121                	addi	sp,sp,64
    80000fa2:	8082                	ret
    panic("walk");
    80000fa4:	00006517          	auipc	a0,0x6
    80000fa8:	10c50513          	addi	a0,a0,268 # 800070b0 <etext+0xb0>
    80000fac:	889ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fb0:	020b0263          	beqz	s6,80000fd4 <walk+0x96>
    80000fb4:	b5bff0ef          	jal	80000b0e <kalloc>
    80000fb8:	84aa                	mv	s1,a0
    80000fba:	d979                	beqz	a0,80000f90 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fbc:	6605                	lui	a2,0x1
    80000fbe:	4581                	li	a1,0
    80000fc0:	ce9ff0ef          	jal	80000ca8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fc4:	00c4d793          	srli	a5,s1,0xc
    80000fc8:	07aa                	slli	a5,a5,0xa
    80000fca:	0017e793          	ori	a5,a5,1
    80000fce:	00f93023          	sd	a5,0(s2)
    80000fd2:	b775                	j	80000f7e <walk+0x40>
        return 0;
    80000fd4:	4501                	li	a0,0
    80000fd6:	bf6d                	j	80000f90 <walk+0x52>

0000000080000fd8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	00b7f463          	bgeu	a5,a1,80000fe4 <walkaddr+0xc>
    return 0;
    80000fe0:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe2:	8082                	ret
{
    80000fe4:	1141                	addi	sp,sp,-16
    80000fe6:	e406                	sd	ra,8(sp)
    80000fe8:	e022                	sd	s0,0(sp)
    80000fea:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fec:	4601                	li	a2,0
    80000fee:	f51ff0ef          	jal	80000f3e <walk>
  if (pte == 0)
    80000ff2:	c901                	beqz	a0,80001002 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80000ff4:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000ff6:	0117f693          	andi	a3,a5,17
    80000ffa:	4745                	li	a4,17
    return 0;
    80000ffc:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000ffe:	00e68663          	beq	a3,a4,8000100a <walkaddr+0x32>
}
    80001002:	60a2                	ld	ra,8(sp)
    80001004:	6402                	ld	s0,0(sp)
    80001006:	0141                	addi	sp,sp,16
    80001008:	8082                	ret
  pa = PTE2PA(*pte);
    8000100a:	83a9                	srli	a5,a5,0xa
    8000100c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001010:	bfcd                	j	80001002 <walkaddr+0x2a>

0000000080001012 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001012:	715d                	addi	sp,sp,-80
    80001014:	e486                	sd	ra,72(sp)
    80001016:	e0a2                	sd	s0,64(sp)
    80001018:	fc26                	sd	s1,56(sp)
    8000101a:	f84a                	sd	s2,48(sp)
    8000101c:	f44e                	sd	s3,40(sp)
    8000101e:	f052                	sd	s4,32(sp)
    80001020:	ec56                	sd	s5,24(sp)
    80001022:	e85a                	sd	s6,16(sp)
    80001024:	e45e                	sd	s7,8(sp)
    80001026:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001028:	03459793          	slli	a5,a1,0x34
    8000102c:	eba1                	bnez	a5,8000107c <mappages+0x6a>
    8000102e:	8a2a                	mv	s4,a0
    80001030:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001032:	03461793          	slli	a5,a2,0x34
    80001036:	eba9                	bnez	a5,80001088 <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    80001038:	ce31                	beqz	a2,80001094 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000103a:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000103e:	80060613          	addi	a2,a2,-2048
    80001042:	00b60933          	add	s2,a2,a1
  a = va;
    80001046:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001048:	4b05                	li	s6,1
    8000104a:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000104e:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001050:	865a                	mv	a2,s6
    80001052:	85a6                	mv	a1,s1
    80001054:	8552                	mv	a0,s4
    80001056:	ee9ff0ef          	jal	80000f3e <walk>
    8000105a:	c929                	beqz	a0,800010ac <mappages+0x9a>
    if (*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	e3a1                	bnez	a5,800010a0 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	013487b3          	add	a5,s1,s3
    80001066:	83b1                	srli	a5,a5,0xc
    80001068:	07aa                	slli	a5,a5,0xa
    8000106a:	0157e7b3          	or	a5,a5,s5
    8000106e:	0017e793          	ori	a5,a5,1
    80001072:	e11c                	sd	a5,0(a0)
    if (a == last)
    80001074:	05248863          	beq	s1,s2,800010c4 <mappages+0xb2>
    a += PGSIZE;
    80001078:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	bfd9                	j	80001050 <mappages+0x3e>
    panic("mappages: va not aligned");
    8000107c:	00006517          	auipc	a0,0x6
    80001080:	03c50513          	addi	a0,a0,60 # 800070b8 <etext+0xb8>
    80001084:	fb0ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    80001088:	00006517          	auipc	a0,0x6
    8000108c:	05050513          	addi	a0,a0,80 # 800070d8 <etext+0xd8>
    80001090:	fa4ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    80001094:	00006517          	auipc	a0,0x6
    80001098:	06450513          	addi	a0,a0,100 # 800070f8 <etext+0xf8>
    8000109c:	f98ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010a0:	00006517          	auipc	a0,0x6
    800010a4:	06850513          	addi	a0,a0,104 # 80007108 <etext+0x108>
    800010a8:	f8cff0ef          	jal	80000834 <panic>
      return -1;
    800010ac:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010ae:	60a6                	ld	ra,72(sp)
    800010b0:	6406                	ld	s0,64(sp)
    800010b2:	74e2                	ld	s1,56(sp)
    800010b4:	7942                	ld	s2,48(sp)
    800010b6:	79a2                	ld	s3,40(sp)
    800010b8:	7a02                	ld	s4,32(sp)
    800010ba:	6ae2                	ld	s5,24(sp)
    800010bc:	6b42                	ld	s6,16(sp)
    800010be:	6ba2                	ld	s7,8(sp)
    800010c0:	6161                	addi	sp,sp,80
    800010c2:	8082                	ret
  return 0;
    800010c4:	4501                	li	a0,0
    800010c6:	b7e5                	j	800010ae <mappages+0x9c>

00000000800010c8 <kvmmap>:
{
    800010c8:	1141                	addi	sp,sp,-16
    800010ca:	e406                	sd	ra,8(sp)
    800010cc:	e022                	sd	s0,0(sp)
    800010ce:	0800                	addi	s0,sp,16
    800010d0:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010d2:	86b2                	mv	a3,a2
    800010d4:	863e                	mv	a2,a5
    800010d6:	f3dff0ef          	jal	80001012 <mappages>
    800010da:	e509                	bnez	a0,800010e4 <kvmmap+0x1c>
}
    800010dc:	60a2                	ld	ra,8(sp)
    800010de:	6402                	ld	s0,0(sp)
    800010e0:	0141                	addi	sp,sp,16
    800010e2:	8082                	ret
    panic("kvmmap");
    800010e4:	00006517          	auipc	a0,0x6
    800010e8:	03450513          	addi	a0,a0,52 # 80007118 <etext+0x118>
    800010ec:	f48ff0ef          	jal	80000834 <panic>

00000000800010f0 <kvmmake>:
{
    800010f0:	1101                	addi	sp,sp,-32
    800010f2:	ec06                	sd	ra,24(sp)
    800010f4:	e822                	sd	s0,16(sp)
    800010f6:	e426                	sd	s1,8(sp)
    800010f8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800010fa:	a15ff0ef          	jal	80000b0e <kalloc>
    800010fe:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001100:	6605                	lui	a2,0x1
    80001102:	4581                	li	a1,0
    80001104:	ba5ff0ef          	jal	80000ca8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001108:	4719                	li	a4,6
    8000110a:	6685                	lui	a3,0x1
    8000110c:	10000637          	lui	a2,0x10000
    80001110:	85b2                	mv	a1,a2
    80001112:	8526                	mv	a0,s1
    80001114:	fb5ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	85b2                	mv	a1,a2
    80001122:	8526                	mv	a0,s1
    80001124:	fa5ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001128:	4719                	li	a4,6
    8000112a:	040006b7          	lui	a3,0x4000
    8000112e:	0c000637          	lui	a2,0xc000
    80001132:	85b2                	mv	a1,a2
    80001134:	8526                	mv	a0,s1
    80001136:	f93ff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000113a:	4729                	li	a4,10
    8000113c:	80006697          	auipc	a3,0x80006
    80001140:	ec468693          	addi	a3,a3,-316 # 7000 <_entry-0x7fff9000>
    80001144:	4605                	li	a2,1
    80001146:	067e                	slli	a2,a2,0x1f
    80001148:	85b2                	mv	a1,a2
    8000114a:	8526                	mv	a0,s1
    8000114c:	f7dff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001150:	4719                	li	a4,6
    80001152:	00006697          	auipc	a3,0x6
    80001156:	eae68693          	addi	a3,a3,-338 # 80007000 <etext>
    8000115a:	47c5                	li	a5,17
    8000115c:	07ee                	slli	a5,a5,0x1b
    8000115e:	40d786b3          	sub	a3,a5,a3
    80001162:	00006617          	auipc	a2,0x6
    80001166:	e9e60613          	addi	a2,a2,-354 # 80007000 <etext>
    8000116a:	85b2                	mv	a1,a2
    8000116c:	8526                	mv	a0,s1
    8000116e:	f5bff0ef          	jal	800010c8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001172:	4729                	li	a4,10
    80001174:	6685                	lui	a3,0x1
    80001176:	00005617          	auipc	a2,0x5
    8000117a:	e8a60613          	addi	a2,a2,-374 # 80006000 <_trampoline>
    8000117e:	040005b7          	lui	a1,0x4000
    80001182:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001184:	05b2                	slli	a1,a1,0xc
    80001186:	8526                	mv	a0,s1
    80001188:	f41ff0ef          	jal	800010c8 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118c:	8526                	mv	a0,s1
    8000118e:	5ec000ef          	jal	8000177a <proc_mapstacks>
}
    80001192:	8526                	mv	a0,s1
    80001194:	60e2                	ld	ra,24(sp)
    80001196:	6442                	ld	s0,16(sp)
    80001198:	64a2                	ld	s1,8(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f4bff0ef          	jal	800010f0 <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	10a7bb23          	sd	a0,278(a5) # 8000a2c0 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800011c4:	94bff0ef          	jal	80000b0e <kalloc>
    800011c8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800011ca:	c509                	beqz	a0,800011d4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011cc:	6605                	lui	a2,0x1
    800011ce:	4581                	li	a1,0
    800011d0:	ad9ff0ef          	jal	80000ca8 <memset>
  return pagetable;
}
    800011d4:	8526                	mv	a0,s1
    800011d6:	60e2                	ld	ra,24(sp)
    800011d8:	6442                	ld	s0,16(sp)
    800011da:	64a2                	ld	s1,8(sp)
    800011dc:	6105                	addi	sp,sp,32
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	7139                	addi	sp,sp,-64
    800011e2:	fc06                	sd	ra,56(sp)
    800011e4:	f822                	sd	s0,48(sp)
    800011e6:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e38d                	bnez	a5,8000120e <uvmunmap+0x2e>
    800011ee:	f04a                	sd	s2,32(sp)
    800011f0:	ec4e                	sd	s3,24(sp)
    800011f2:	e852                	sd	s4,16(sp)
    800011f4:	e456                	sd	s5,8(sp)
    800011f6:	e05a                	sd	s6,0(sp)
    800011f8:	8a2a                	mv	s4,a0
    800011fa:	892e                	mv	s2,a1
    800011fc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011fe:	0632                	slli	a2,a2,0xc
    80001200:	00b609b3          	add	s3,a2,a1
    80001204:	6b05                	lui	s6,0x1
    80001206:	0535f963          	bgeu	a1,s3,80001258 <uvmunmap+0x78>
    8000120a:	f426                	sd	s1,40(sp)
    8000120c:	a015                	j	80001230 <uvmunmap+0x50>
    8000120e:	f426                	sd	s1,40(sp)
    80001210:	f04a                	sd	s2,32(sp)
    80001212:	ec4e                	sd	s3,24(sp)
    80001214:	e852                	sd	s4,16(sp)
    80001216:	e456                	sd	s5,8(sp)
    80001218:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000121a:	00006517          	auipc	a0,0x6
    8000121e:	f0650513          	addi	a0,a0,-250 # 80007120 <etext+0x120>
    80001222:	e12ff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    80001226:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000122a:	995a                	add	s2,s2,s6
    8000122c:	03397563          	bgeu	s2,s3,80001256 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001230:	4601                	li	a2,0
    80001232:	85ca                	mv	a1,s2
    80001234:	8552                	mv	a0,s4
    80001236:	d09ff0ef          	jal	80000f3e <walk>
    8000123a:	84aa                	mv	s1,a0
    8000123c:	d57d                	beqz	a0,8000122a <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000123e:	611c                	ld	a5,0(a0)
    80001240:	0017f713          	andi	a4,a5,1
    80001244:	d37d                	beqz	a4,8000122a <uvmunmap+0x4a>
    if (do_free) {
    80001246:	fe0a80e3          	beqz	s5,80001226 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000124a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000124c:	00c79513          	slli	a0,a5,0xc
    80001250:	fd6ff0ef          	jal	80000a26 <kfree>
    80001254:	bfc9                	j	80001226 <uvmunmap+0x46>
    80001256:	74a2                	ld	s1,40(sp)
    80001258:	7902                	ld	s2,32(sp)
    8000125a:	69e2                	ld	s3,24(sp)
    8000125c:	6a42                	ld	s4,16(sp)
    8000125e:	6aa2                	ld	s5,8(sp)
    80001260:	6b02                	ld	s6,0(sp)
  }
}
    80001262:	70e2                	ld	ra,56(sp)
    80001264:	7442                	ld	s0,48(sp)
    80001266:	6121                	addi	sp,sp,64
    80001268:	8082                	ret

000000008000126a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000126a:	1101                	addi	sp,sp,-32
    8000126c:	ec06                	sd	ra,24(sp)
    8000126e:	e822                	sd	s0,16(sp)
    80001270:	e426                	sd	s1,8(sp)
    80001272:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001274:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001276:	00b67d63          	bgeu	a2,a1,80001290 <uvmdealloc+0x26>
    8000127a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000127c:	6785                	lui	a5,0x1
    8000127e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001280:	00f60733          	add	a4,a2,a5
    80001284:	76fd                	lui	a3,0xfffff
    80001286:	8f75                	and	a4,a4,a3
    80001288:	97ae                	add	a5,a5,a1
    8000128a:	8ff5                	and	a5,a5,a3
    8000128c:	00f76863          	bltu	a4,a5,8000129c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000129c:	8f99                	sub	a5,a5,a4
    8000129e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012a0:	4685                	li	a3,1
    800012a2:	0007861b          	sext.w	a2,a5
    800012a6:	85ba                	mv	a1,a4
    800012a8:	f39ff0ef          	jal	800011e0 <uvmunmap>
    800012ac:	b7d5                	j	80001290 <uvmdealloc+0x26>

00000000800012ae <uvmalloc>:
  if (newsz < oldsz)
    800012ae:	0ab66163          	bltu	a2,a1,80001350 <uvmalloc+0xa2>
{
    800012b2:	715d                	addi	sp,sp,-80
    800012b4:	e486                	sd	ra,72(sp)
    800012b6:	e0a2                	sd	s0,64(sp)
    800012b8:	f84a                	sd	s2,48(sp)
    800012ba:	f052                	sd	s4,32(sp)
    800012bc:	ec56                	sd	s5,24(sp)
    800012be:	e45e                	sd	s7,8(sp)
    800012c0:	0880                	addi	s0,sp,80
    800012c2:	8aaa                	mv	s5,a0
    800012c4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012c6:	6785                	lui	a5,0x1
    800012c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ca:	95be                	add	a1,a1,a5
    800012cc:	77fd                	lui	a5,0xfffff
    800012ce:	00f5f933          	and	s2,a1,a5
    800012d2:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012d4:	08c97063          	bgeu	s2,a2,80001354 <uvmalloc+0xa6>
    800012d8:	fc26                	sd	s1,56(sp)
    800012da:	f44e                	sd	s3,40(sp)
    800012dc:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800012de:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012e0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012e4:	82bff0ef          	jal	80000b0e <kalloc>
    800012e8:	84aa                	mv	s1,a0
    if (mem == 0) {
    800012ea:	c50d                	beqz	a0,80001314 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    800012ec:	864e                	mv	a2,s3
    800012ee:	4581                	li	a1,0
    800012f0:	9b9ff0ef          	jal	80000ca8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012f4:	875a                	mv	a4,s6
    800012f6:	86a6                	mv	a3,s1
    800012f8:	864e                	mv	a2,s3
    800012fa:	85ca                	mv	a1,s2
    800012fc:	8556                	mv	a0,s5
    800012fe:	d15ff0ef          	jal	80001012 <mappages>
    80001302:	e915                	bnez	a0,80001336 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001304:	994e                	add	s2,s2,s3
    80001306:	fd496fe3          	bltu	s2,s4,800012e4 <uvmalloc+0x36>
  return newsz;
    8000130a:	8552                	mv	a0,s4
    8000130c:	74e2                	ld	s1,56(sp)
    8000130e:	79a2                	ld	s3,40(sp)
    80001310:	6b42                	ld	s6,16(sp)
    80001312:	a811                	j	80001326 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001314:	865e                	mv	a2,s7
    80001316:	85ca                	mv	a1,s2
    80001318:	8556                	mv	a0,s5
    8000131a:	f51ff0ef          	jal	8000126a <uvmdealloc>
      return 0;
    8000131e:	4501                	li	a0,0
    80001320:	74e2                	ld	s1,56(sp)
    80001322:	79a2                	ld	s3,40(sp)
    80001324:	6b42                	ld	s6,16(sp)
}
    80001326:	60a6                	ld	ra,72(sp)
    80001328:	6406                	ld	s0,64(sp)
    8000132a:	7942                	ld	s2,48(sp)
    8000132c:	7a02                	ld	s4,32(sp)
    8000132e:	6ae2                	ld	s5,24(sp)
    80001330:	6ba2                	ld	s7,8(sp)
    80001332:	6161                	addi	sp,sp,80
    80001334:	8082                	ret
      kfree(mem);
    80001336:	8526                	mv	a0,s1
    80001338:	eeeff0ef          	jal	80000a26 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000133c:	865e                	mv	a2,s7
    8000133e:	85ca                	mv	a1,s2
    80001340:	8556                	mv	a0,s5
    80001342:	f29ff0ef          	jal	8000126a <uvmdealloc>
      return 0;
    80001346:	4501                	li	a0,0
    80001348:	74e2                	ld	s1,56(sp)
    8000134a:	79a2                	ld	s3,40(sp)
    8000134c:	6b42                	ld	s6,16(sp)
    8000134e:	bfe1                	j	80001326 <uvmalloc+0x78>
    return oldsz;
    80001350:	852e                	mv	a0,a1
}
    80001352:	8082                	ret
  return newsz;
    80001354:	8532                	mv	a0,a2
    80001356:	bfc1                	j	80001326 <uvmalloc+0x78>

0000000080001358 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001358:	7179                	addi	sp,sp,-48
    8000135a:	f406                	sd	ra,40(sp)
    8000135c:	f022                	sd	s0,32(sp)
    8000135e:	ec26                	sd	s1,24(sp)
    80001360:	e84a                	sd	s2,16(sp)
    80001362:	e44e                	sd	s3,8(sp)
    80001364:	1800                	addi	s0,sp,48
    80001366:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001368:	84aa                	mv	s1,a0
    8000136a:	6905                	lui	s2,0x1
    8000136c:	992a                	add	s2,s2,a0
    8000136e:	a811                	j	80001382 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    80001370:	00006517          	auipc	a0,0x6
    80001374:	dc850513          	addi	a0,a0,-568 # 80007138 <etext+0x138>
    80001378:	cbcff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    8000137c:	04a1                	addi	s1,s1,8
    8000137e:	03248163          	beq	s1,s2,800013a0 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001382:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001384:	0017f713          	andi	a4,a5,1
    80001388:	db75                	beqz	a4,8000137c <freewalk+0x24>
    8000138a:	00e7f713          	andi	a4,a5,14
    8000138e:	f36d                	bnez	a4,80001370 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001390:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001392:	00c79513          	slli	a0,a5,0xc
    80001396:	fc3ff0ef          	jal	80001358 <freewalk>
      pagetable[i] = 0;
    8000139a:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000139e:	bff9                	j	8000137c <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013a0:	854e                	mv	a0,s3
    800013a2:	e84ff0ef          	jal	80000a26 <kfree>
}
    800013a6:	70a2                	ld	ra,40(sp)
    800013a8:	7402                	ld	s0,32(sp)
    800013aa:	64e2                	ld	s1,24(sp)
    800013ac:	6942                	ld	s2,16(sp)
    800013ae:	69a2                	ld	s3,8(sp)
    800013b0:	6145                	addi	sp,sp,48
    800013b2:	8082                	ret

00000000800013b4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
    800013be:	84aa                	mv	s1,a0
  if (sz > 0)
    800013c0:	e989                	bnez	a1,800013d2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800013c2:	8526                	mv	a0,s1
    800013c4:	f95ff0ef          	jal	80001358 <freewalk>
}
    800013c8:	60e2                	ld	ra,24(sp)
    800013ca:	6442                	ld	s0,16(sp)
    800013cc:	64a2                	ld	s1,8(sp)
    800013ce:	6105                	addi	sp,sp,32
    800013d0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013d2:	6785                	lui	a5,0x1
    800013d4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d6:	95be                	add	a1,a1,a5
    800013d8:	4685                	li	a3,1
    800013da:	00c5d613          	srli	a2,a1,0xc
    800013de:	4581                	li	a1,0
    800013e0:	e01ff0ef          	jal	800011e0 <uvmunmap>
    800013e4:	bff9                	j	800013c2 <uvmfree+0xe>

00000000800013e6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    800013e6:	ca59                	beqz	a2,8000147c <uvmcopy+0x96>
{
    800013e8:	715d                	addi	sp,sp,-80
    800013ea:	e486                	sd	ra,72(sp)
    800013ec:	e0a2                	sd	s0,64(sp)
    800013ee:	fc26                	sd	s1,56(sp)
    800013f0:	f84a                	sd	s2,48(sp)
    800013f2:	f44e                	sd	s3,40(sp)
    800013f4:	f052                	sd	s4,32(sp)
    800013f6:	ec56                	sd	s5,24(sp)
    800013f8:	e85a                	sd	s6,16(sp)
    800013fa:	e45e                	sd	s7,8(sp)
    800013fc:	0880                	addi	s0,sp,80
    800013fe:	8b2a                	mv	s6,a0
    80001400:	8bae                	mv	s7,a1
    80001402:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001404:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001406:	6a05                	lui	s4,0x1
    80001408:	a021                	j	80001410 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000140a:	94d2                	add	s1,s1,s4
    8000140c:	0554fc63          	bgeu	s1,s5,80001464 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001410:	4601                	li	a2,0
    80001412:	85a6                	mv	a1,s1
    80001414:	855a                	mv	a0,s6
    80001416:	b29ff0ef          	jal	80000f3e <walk>
    8000141a:	d965                	beqz	a0,8000140a <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000141c:	00053983          	ld	s3,0(a0)
    80001420:	0019f793          	andi	a5,s3,1
    80001424:	d3fd                	beqz	a5,8000140a <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001426:	ee8ff0ef          	jal	80000b0e <kalloc>
    8000142a:	892a                	mv	s2,a0
    8000142c:	c11d                	beqz	a0,80001452 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000142e:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001432:	8652                	mv	a2,s4
    80001434:	05b2                	slli	a1,a1,0xc
    80001436:	8d3ff0ef          	jal	80000d08 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000143a:	3ff9f713          	andi	a4,s3,1023
    8000143e:	86ca                	mv	a3,s2
    80001440:	8652                	mv	a2,s4
    80001442:	85a6                	mv	a1,s1
    80001444:	855e                	mv	a0,s7
    80001446:	bcdff0ef          	jal	80001012 <mappages>
    8000144a:	d161                	beqz	a0,8000140a <uvmcopy+0x24>
      kfree(mem);
    8000144c:	854a                	mv	a0,s2
    8000144e:	dd8ff0ef          	jal	80000a26 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001452:	4685                	li	a3,1
    80001454:	00c4d613          	srli	a2,s1,0xc
    80001458:	4581                	li	a1,0
    8000145a:	855e                	mv	a0,s7
    8000145c:	d85ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    80001460:	557d                	li	a0,-1
    80001462:	a011                	j	80001466 <uvmcopy+0x80>
  return 0;
    80001464:	4501                	li	a0,0
}
    80001466:	60a6                	ld	ra,72(sp)
    80001468:	6406                	ld	s0,64(sp)
    8000146a:	74e2                	ld	s1,56(sp)
    8000146c:	7942                	ld	s2,48(sp)
    8000146e:	79a2                	ld	s3,40(sp)
    80001470:	7a02                	ld	s4,32(sp)
    80001472:	6ae2                	ld	s5,24(sp)
    80001474:	6b42                	ld	s6,16(sp)
    80001476:	6ba2                	ld	s7,8(sp)
    80001478:	6161                	addi	sp,sp,80
    8000147a:	8082                	ret
  return 0;
    8000147c:	4501                	li	a0,0
}
    8000147e:	8082                	ret

0000000080001480 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001480:	1141                	addi	sp,sp,-16
    80001482:	e406                	sd	ra,8(sp)
    80001484:	e022                	sd	s0,0(sp)
    80001486:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001488:	4601                	li	a2,0
    8000148a:	ab5ff0ef          	jal	80000f3e <walk>
  if (pte == 0)
    8000148e:	c901                	beqz	a0,8000149e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001490:	611c                	ld	a5,0(a0)
    80001492:	9bbd                	andi	a5,a5,-17
    80001494:	e11c                	sd	a5,0(a0)
}
    80001496:	60a2                	ld	ra,8(sp)
    80001498:	6402                	ld	s0,0(sp)
    8000149a:	0141                	addi	sp,sp,16
    8000149c:	8082                	ret
    panic("uvmclear");
    8000149e:	00006517          	auipc	a0,0x6
    800014a2:	caa50513          	addi	a0,a0,-854 # 80007148 <etext+0x148>
    800014a6:	b8eff0ef          	jal	80000834 <panic>

00000000800014aa <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014aa:	1141                	addi	sp,sp,-16
    800014ac:	e406                	sd	ra,8(sp)
    800014ae:	e022                	sd	s0,0(sp)
    800014b0:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014b2:	4601                	li	a2,0
    800014b4:	a8bff0ef          	jal	80000f3e <walk>
  if (pte == 0) {
    800014b8:	c119                	beqz	a0,800014be <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    800014ba:	6108                	ld	a0,0(a0)
    800014bc:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014be:	60a2                	ld	ra,8(sp)
    800014c0:	6402                	ld	s0,0(sp)
    800014c2:	0141                	addi	sp,sp,16
    800014c4:	8082                	ret

00000000800014c6 <vmfault>:
{
    800014c6:	7179                	addi	sp,sp,-48
    800014c8:	f406                	sd	ra,40(sp)
    800014ca:	f022                	sd	s0,32(sp)
    800014cc:	e052                	sd	s4,0(sp)
    800014ce:	1800                	addi	s0,sp,48
    return 0;
    800014d0:	4a01                	li	s4,0
  if (va >= psz)
    800014d2:	00b66863          	bltu	a2,a1,800014e2 <vmfault+0x1c>
}
    800014d6:	8552                	mv	a0,s4
    800014d8:	70a2                	ld	ra,40(sp)
    800014da:	7402                	ld	s0,32(sp)
    800014dc:	6a02                	ld	s4,0(sp)
    800014de:	6145                	addi	sp,sp,48
    800014e0:	8082                	ret
    800014e2:	ec26                	sd	s1,24(sp)
    800014e4:	e44e                	sd	s3,8(sp)
    800014e6:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800014e8:	77fd                	lui	a5,0xfffff
    800014ea:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    800014ee:	85ce                	mv	a1,s3
    800014f0:	fbbff0ef          	jal	800014aa <ismapped>
    return 0;
    800014f4:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    800014f6:	c501                	beqz	a0,800014fe <vmfault+0x38>
    800014f8:	64e2                	ld	s1,24(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	bfe9                	j	800014d6 <vmfault+0x10>
    800014fe:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001500:	e0eff0ef          	jal	80000b0e <kalloc>
    80001504:	892a                	mv	s2,a0
  if (mem == 0)
    80001506:	c915                	beqz	a0,8000153a <vmfault+0x74>
  mem = (uint64)kalloc();
    80001508:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    8000150a:	6605                	lui	a2,0x1
    8000150c:	4581                	li	a1,0
    8000150e:	f9aff0ef          	jal	80000ca8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    80001512:	4759                	li	a4,22
    80001514:	86ca                	mv	a3,s2
    80001516:	6605                	lui	a2,0x1
    80001518:	85ce                	mv	a1,s3
    8000151a:	8526                	mv	a0,s1
    8000151c:	af7ff0ef          	jal	80001012 <mappages>
    80001520:	e509                	bnez	a0,8000152a <vmfault+0x64>
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	b77d                	j	800014d6 <vmfault+0x10>
    kfree((void *)mem);
    8000152a:	854a                	mv	a0,s2
    8000152c:	cfaff0ef          	jal	80000a26 <kfree>
    return 0;
    80001530:	4a01                	li	s4,0
    80001532:	64e2                	ld	s1,24(sp)
    80001534:	6942                	ld	s2,16(sp)
    80001536:	69a2                	ld	s3,8(sp)
    80001538:	bf79                	j	800014d6 <vmfault+0x10>
    8000153a:	64e2                	ld	s1,24(sp)
    8000153c:	6942                	ld	s2,16(sp)
    8000153e:	69a2                	ld	s3,8(sp)
    80001540:	bf59                	j	800014d6 <vmfault+0x10>

0000000080001542 <copyout>:
  while (len > 0) {
    80001542:	cf49                	beqz	a4,800015dc <copyout+0x9a>
{
    80001544:	7159                	addi	sp,sp,-112
    80001546:	f486                	sd	ra,104(sp)
    80001548:	f0a2                	sd	s0,96(sp)
    8000154a:	eca6                	sd	s1,88(sp)
    8000154c:	e8ca                	sd	s2,80(sp)
    8000154e:	e4ce                	sd	s3,72(sp)
    80001550:	e0d2                	sd	s4,64(sp)
    80001552:	fc56                	sd	s5,56(sp)
    80001554:	f85a                	sd	s6,48(sp)
    80001556:	f45e                	sd	s7,40(sp)
    80001558:	f062                	sd	s8,32(sp)
    8000155a:	ec66                	sd	s9,24(sp)
    8000155c:	e86a                	sd	s10,16(sp)
    8000155e:	e46e                	sd	s11,8(sp)
    80001560:	1880                	addi	s0,sp,112
    80001562:	8baa                	mv	s7,a0
    80001564:	8dae                	mv	s11,a1
    80001566:	8a32                	mv	s4,a2
    80001568:	8b36                	mv	s6,a3
    8000156a:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    8000156c:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    8000156e:	5cfd                	li	s9,-1
    80001570:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001574:	6c05                	lui	s8,0x1
    80001576:	a005                	j	80001596 <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001578:	409a0533          	sub	a0,s4,s1
    8000157c:	0009061b          	sext.w	a2,s2
    80001580:	85da                	mv	a1,s6
    80001582:	954e                	add	a0,a0,s3
    80001584:	f84ff0ef          	jal	80000d08 <memmove>
    len -= n;
    80001588:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000158c:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000158e:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    80001592:	040a8363          	beqz	s5,800015d8 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    80001596:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    8000159a:	049ce363          	bltu	s9,s1,800015e0 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    8000159e:	85a6                	mv	a1,s1
    800015a0:	855e                	mv	a0,s7
    800015a2:	a37ff0ef          	jal	80000fd8 <walkaddr>
    800015a6:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015a8:	e909                	bnez	a0,800015ba <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015aa:	4681                	li	a3,0
    800015ac:	8626                	mv	a2,s1
    800015ae:	85ee                	mv	a1,s11
    800015b0:	855e                	mv	a0,s7
    800015b2:	f15ff0ef          	jal	800014c6 <vmfault>
    800015b6:	89aa                	mv	s3,a0
    800015b8:	c521                	beqz	a0,80001600 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800015ba:	4601                	li	a2,0
    800015bc:	85a6                	mv	a1,s1
    800015be:	855e                	mv	a0,s7
    800015c0:	97fff0ef          	jal	80000f3e <walk>
    if ((*pte & PTE_W) == 0)
    800015c4:	611c                	ld	a5,0(a0)
    800015c6:	8b91                	andi	a5,a5,4
    800015c8:	cf95                	beqz	a5,80001604 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    800015ca:	41448933          	sub	s2,s1,s4
    800015ce:	9962                	add	s2,s2,s8
    if (n > len)
    800015d0:	fb2af4e3          	bgeu	s5,s2,80001578 <copyout+0x36>
    800015d4:	8956                	mv	s2,s5
    800015d6:	b74d                	j	80001578 <copyout+0x36>
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	a021                	j	800015e2 <copyout+0xa0>
    800015dc:	4501                	li	a0,0
}
    800015de:	8082                	ret
      return -1;
    800015e0:	557d                	li	a0,-1
}
    800015e2:	70a6                	ld	ra,104(sp)
    800015e4:	7406                	ld	s0,96(sp)
    800015e6:	64e6                	ld	s1,88(sp)
    800015e8:	6946                	ld	s2,80(sp)
    800015ea:	69a6                	ld	s3,72(sp)
    800015ec:	6a06                	ld	s4,64(sp)
    800015ee:	7ae2                	ld	s5,56(sp)
    800015f0:	7b42                	ld	s6,48(sp)
    800015f2:	7ba2                	ld	s7,40(sp)
    800015f4:	7c02                	ld	s8,32(sp)
    800015f6:	6ce2                	ld	s9,24(sp)
    800015f8:	6d42                	ld	s10,16(sp)
    800015fa:	6da2                	ld	s11,8(sp)
    800015fc:	6165                	addi	sp,sp,112
    800015fe:	8082                	ret
        return -1;
    80001600:	557d                	li	a0,-1
    80001602:	b7c5                	j	800015e2 <copyout+0xa0>
      return -1;
    80001604:	557d                	li	a0,-1
    80001606:	bff1                	j	800015e2 <copyout+0xa0>

0000000080001608 <copyin>:
  while (len > 0) {
    80001608:	cf41                	beqz	a4,800016a0 <copyin+0x98>
{
    8000160a:	711d                	addi	sp,sp,-96
    8000160c:	ec86                	sd	ra,88(sp)
    8000160e:	e8a2                	sd	s0,80(sp)
    80001610:	e4a6                	sd	s1,72(sp)
    80001612:	e0ca                	sd	s2,64(sp)
    80001614:	fc4e                	sd	s3,56(sp)
    80001616:	f852                	sd	s4,48(sp)
    80001618:	f456                	sd	s5,40(sp)
    8000161a:	f05a                	sd	s6,32(sp)
    8000161c:	ec5e                	sd	s7,24(sp)
    8000161e:	e862                	sd	s8,16(sp)
    80001620:	e466                	sd	s9,8(sp)
    80001622:	e06a                	sd	s10,0(sp)
    80001624:	1080                	addi	s0,sp,96
    80001626:	8baa                	mv	s7,a0
    80001628:	8cae                	mv	s9,a1
    8000162a:	8ab2                	mv	s5,a2
    8000162c:	8936                	mv	s2,a3
    8000162e:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001630:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001632:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001634:	6b05                	lui	s6,0x1
    80001636:	a035                	j	80001662 <copyin+0x5a>
    80001638:	412984b3          	sub	s1,s3,s2
    8000163c:	94da                	add	s1,s1,s6
    if (n > len)
    8000163e:	009a7363          	bgeu	s4,s1,80001644 <copyin+0x3c>
    80001642:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001644:	413905b3          	sub	a1,s2,s3
    80001648:	0004861b          	sext.w	a2,s1
    8000164c:	95aa                	add	a1,a1,a0
    8000164e:	8556                	mv	a0,s5
    80001650:	eb8ff0ef          	jal	80000d08 <memmove>
    len -= n;
    80001654:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001658:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000165a:	01698933          	add	s2,s3,s6
  while (len > 0) {
    8000165e:	020a0263          	beqz	s4,80001682 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    80001662:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001666:	85ce                	mv	a1,s3
    80001668:	855e                	mv	a0,s7
    8000166a:	96fff0ef          	jal	80000fd8 <walkaddr>
    if (pa0 == 0) {
    8000166e:	f569                	bnez	a0,80001638 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001670:	86ea                	mv	a3,s10
    80001672:	864e                	mv	a2,s3
    80001674:	85e6                	mv	a1,s9
    80001676:	855e                	mv	a0,s7
    80001678:	e4fff0ef          	jal	800014c6 <vmfault>
    8000167c:	fd55                	bnez	a0,80001638 <copyin+0x30>
        return -1;
    8000167e:	557d                	li	a0,-1
    80001680:	a011                	j	80001684 <copyin+0x7c>
  return 0;
    80001682:	4501                	li	a0,0
}
    80001684:	60e6                	ld	ra,88(sp)
    80001686:	6446                	ld	s0,80(sp)
    80001688:	64a6                	ld	s1,72(sp)
    8000168a:	6906                	ld	s2,64(sp)
    8000168c:	79e2                	ld	s3,56(sp)
    8000168e:	7a42                	ld	s4,48(sp)
    80001690:	7aa2                	ld	s5,40(sp)
    80001692:	7b02                	ld	s6,32(sp)
    80001694:	6be2                	ld	s7,24(sp)
    80001696:	6c42                	ld	s8,16(sp)
    80001698:	6ca2                	ld	s9,8(sp)
    8000169a:	6d02                	ld	s10,0(sp)
    8000169c:	6125                	addi	sp,sp,96
    8000169e:	8082                	ret
  return 0;
    800016a0:	4501                	li	a0,0
}
    800016a2:	8082                	ret

00000000800016a4 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016a4:	c769                	beqz	a4,8000176e <copyinstr+0xca>
{
    800016a6:	711d                	addi	sp,sp,-96
    800016a8:	ec86                	sd	ra,88(sp)
    800016aa:	e8a2                	sd	s0,80(sp)
    800016ac:	e4a6                	sd	s1,72(sp)
    800016ae:	e0ca                	sd	s2,64(sp)
    800016b0:	fc4e                	sd	s3,56(sp)
    800016b2:	f852                	sd	s4,48(sp)
    800016b4:	f456                	sd	s5,40(sp)
    800016b6:	f05a                	sd	s6,32(sp)
    800016b8:	ec5e                	sd	s7,24(sp)
    800016ba:	e862                	sd	s8,16(sp)
    800016bc:	e466                	sd	s9,8(sp)
    800016be:	1080                	addi	s0,sp,96
    800016c0:	8b2a                	mv	s6,a0
    800016c2:	8c2e                	mv	s8,a1
    800016c4:	89b2                	mv	s3,a2
    800016c6:	84b6                	mv	s1,a3
    800016c8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800016ca:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016cc:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    800016ce:	6a85                	lui	s5,0x1
    800016d0:	a881                	j	80001720 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016d2:	86e6                	mv	a3,s9
    800016d4:	864a                	mv	a2,s2
    800016d6:	85e2                	mv	a1,s8
    800016d8:	855a                	mv	a0,s6
    800016da:	dedff0ef          	jal	800014c6 <vmfault>
    800016de:	e921                	bnez	a0,8000172e <copyinstr+0x8a>
        return -1;
    800016e0:	557d                	li	a0,-1
    800016e2:	a801                	j	800016f2 <copyinstr+0x4e>
        *dst = '\0';
    800016e4:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdba00>
        got_null = 1;
    800016e8:	4785                	li	a5,1
  if (got_null) {
    800016ea:	0017c793          	xori	a5,a5,1
    800016ee:	40f0053b          	negw	a0,a5
}
    800016f2:	60e6                	ld	ra,88(sp)
    800016f4:	6446                	ld	s0,80(sp)
    800016f6:	64a6                	ld	s1,72(sp)
    800016f8:	6906                	ld	s2,64(sp)
    800016fa:	79e2                	ld	s3,56(sp)
    800016fc:	7a42                	ld	s4,48(sp)
    800016fe:	7aa2                	ld	s5,40(sp)
    80001700:	7b02                	ld	s6,32(sp)
    80001702:	6be2                	ld	s7,24(sp)
    80001704:	6c42                	ld	s8,16(sp)
    80001706:	6ca2                	ld	s9,8(sp)
    80001708:	6125                	addi	sp,sp,96
    8000170a:	8082                	ret
    8000170c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001710:	974e                	add	a4,a4,s3
      --max;
    80001712:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    80001716:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000171a:	04e58463          	beq	a1,a4,80001762 <copyinstr+0xbe>
{
    8000171e:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001720:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001724:	85ca                	mv	a1,s2
    80001726:	855a                	mv	a0,s6
    80001728:	8b1ff0ef          	jal	80000fd8 <walkaddr>
    if (pa0 == 0) {
    8000172c:	d15d                	beqz	a0,800016d2 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    8000172e:	40990633          	sub	a2,s2,s1
    80001732:	9656                	add	a2,a2,s5
    if (n > max)
    80001734:	00ca7363          	bgeu	s4,a2,8000173a <copyinstr+0x96>
    80001738:	8652                	mv	a2,s4
    while (n > 0) {
    8000173a:	c615                	beqz	a2,80001766 <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    8000173c:	412484b3          	sub	s1,s1,s2
    80001740:	94aa                	add	s1,s1,a0
    80001742:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001744:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    80001748:	964e                	add	a2,a2,s3
    8000174a:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000174c:	00f48733          	add	a4,s1,a5
    80001750:	00074683          	lbu	a3,0(a4)
    80001754:	dac1                	beqz	a3,800016e4 <copyinstr+0x40>
        *dst = *p;
    80001756:	00d78023          	sb	a3,0(a5)
      dst++;
    8000175a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000175c:	fec797e3          	bne	a5,a2,8000174a <copyinstr+0xa6>
    80001760:	b775                	j	8000170c <copyinstr+0x68>
    80001762:	4781                	li	a5,0
    80001764:	b759                	j	800016ea <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    80001766:	6485                	lui	s1,0x1
    80001768:	94ca                	add	s1,s1,s2
    8000176a:	87ce                	mv	a5,s3
    8000176c:	bf4d                	j	8000171e <copyinstr+0x7a>
  int got_null = 0;
    8000176e:	4781                	li	a5,0
  if (got_null) {
    80001770:	0017c793          	xori	a5,a5,1
    80001774:	40f0053b          	negw	a0,a5
}
    80001778:	8082                	ret

000000008000177a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000177a:	715d                	addi	sp,sp,-80
    8000177c:	e486                	sd	ra,72(sp)
    8000177e:	e0a2                	sd	s0,64(sp)
    80001780:	fc26                	sd	s1,56(sp)
    80001782:	f84a                	sd	s2,48(sp)
    80001784:	f44e                	sd	s3,40(sp)
    80001786:	f052                	sd	s4,32(sp)
    80001788:	ec56                	sd	s5,24(sp)
    8000178a:	e85a                	sd	s6,16(sp)
    8000178c:	e45e                	sd	s7,8(sp)
    8000178e:	e062                	sd	s8,0(sp)
    80001790:	0880                	addi	s0,sp,80
    80001792:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001794:	00011497          	auipc	s1,0x11
    80001798:	08c48493          	addi	s1,s1,140 # 80012820 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000179c:	8c26                	mv	s8,s1
    8000179e:	000a57b7          	lui	a5,0xa5
    800017a2:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017a6:	07b2                	slli	a5,a5,0xc
    800017a8:	fa578793          	addi	a5,a5,-91
    800017ac:	4fa50937          	lui	s2,0x4fa50
    800017b0:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017b4:	1902                	slli	s2,s2,0x20
    800017b6:	993e                	add	s2,s2,a5
    800017b8:	040009b7          	lui	s3,0x4000
    800017bc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017be:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c0:	4b99                	li	s7,6
    800017c2:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800017c4:	00017a97          	auipc	s5,0x17
    800017c8:	a5ca8a93          	addi	s5,s5,-1444 # 80018220 <tickslock>
    char *pa = kalloc();
    800017cc:	b42ff0ef          	jal	80000b0e <kalloc>
    800017d0:	862a                	mv	a2,a0
    if (pa == 0)
    800017d2:	c121                	beqz	a0,80001812 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800017d4:	418485b3          	sub	a1,s1,s8
    800017d8:	858d                	srai	a1,a1,0x3
    800017da:	032585b3          	mul	a1,a1,s2
    800017de:	05b6                	slli	a1,a1,0xd
    800017e0:	6789                	lui	a5,0x2
    800017e2:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e4:	875e                	mv	a4,s7
    800017e6:	86da                	mv	a3,s6
    800017e8:	40b985b3          	sub	a1,s3,a1
    800017ec:	8552                	mv	a0,s4
    800017ee:	8dbff0ef          	jal	800010c8 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017f2:	16848493          	addi	s1,s1,360
    800017f6:	fd549be3          	bne	s1,s5,800017cc <proc_mapstacks+0x52>
  }
}
    800017fa:	60a6                	ld	ra,72(sp)
    800017fc:	6406                	ld	s0,64(sp)
    800017fe:	74e2                	ld	s1,56(sp)
    80001800:	7942                	ld	s2,48(sp)
    80001802:	79a2                	ld	s3,40(sp)
    80001804:	7a02                	ld	s4,32(sp)
    80001806:	6ae2                	ld	s5,24(sp)
    80001808:	6b42                	ld	s6,16(sp)
    8000180a:	6ba2                	ld	s7,8(sp)
    8000180c:	6c02                	ld	s8,0(sp)
    8000180e:	6161                	addi	sp,sp,80
    80001810:	8082                	ret
      panic("kalloc");
    80001812:	00006517          	auipc	a0,0x6
    80001816:	94650513          	addi	a0,a0,-1722 # 80007158 <etext+0x158>
    8000181a:	81aff0ef          	jal	80000834 <panic>

000000008000181e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000181e:	7139                	addi	sp,sp,-64
    80001820:	fc06                	sd	ra,56(sp)
    80001822:	f822                	sd	s0,48(sp)
    80001824:	f426                	sd	s1,40(sp)
    80001826:	f04a                	sd	s2,32(sp)
    80001828:	ec4e                	sd	s3,24(sp)
    8000182a:	e852                	sd	s4,16(sp)
    8000182c:	e456                	sd	s5,8(sp)
    8000182e:	e05a                	sd	s6,0(sp)
    80001830:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001832:	00006597          	auipc	a1,0x6
    80001836:	92e58593          	addi	a1,a1,-1746 # 80007160 <etext+0x160>
    8000183a:	00011517          	auipc	a0,0x11
    8000183e:	bb650513          	addi	a0,a0,-1098 # 800123f0 <pid_lock>
    80001842:	b26ff0ef          	jal	80000b68 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001846:	00006597          	auipc	a1,0x6
    8000184a:	92258593          	addi	a1,a1,-1758 # 80007168 <etext+0x168>
    8000184e:	00011517          	auipc	a0,0x11
    80001852:	bba50513          	addi	a0,a0,-1094 # 80012408 <wait_lock>
    80001856:	b12ff0ef          	jal	80000b68 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185a:	00011497          	auipc	s1,0x11
    8000185e:	fc648493          	addi	s1,s1,-58 # 80012820 <proc>
    initlock(&p->lock, "proc");
    80001862:	00006b17          	auipc	s6,0x6
    80001866:	916b0b13          	addi	s6,s6,-1770 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000186a:	8aa6                	mv	s5,s1
    8000186c:	000a57b7          	lui	a5,0xa5
    80001870:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001874:	07b2                	slli	a5,a5,0xc
    80001876:	fa578793          	addi	a5,a5,-91
    8000187a:	4fa50937          	lui	s2,0x4fa50
    8000187e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001882:	1902                	slli	s2,s2,0x20
    80001884:	993e                	add	s2,s2,a5
    80001886:	040009b7          	lui	s3,0x4000
    8000188a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000188c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000188e:	00017a17          	auipc	s4,0x17
    80001892:	992a0a13          	addi	s4,s4,-1646 # 80018220 <tickslock>
    initlock(&p->lock, "proc");
    80001896:	85da                	mv	a1,s6
    80001898:	8526                	mv	a0,s1
    8000189a:	aceff0ef          	jal	80000b68 <initlock>
    p->state = UNUSED;
    8000189e:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018a2:	415487b3          	sub	a5,s1,s5
    800018a6:	878d                	srai	a5,a5,0x3
    800018a8:	032787b3          	mul	a5,a5,s2
    800018ac:	07b6                	slli	a5,a5,0xd
    800018ae:	6709                	lui	a4,0x2
    800018b0:	9fb9                	addw	a5,a5,a4
    800018b2:	40f987b3          	sub	a5,s3,a5
    800018b6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018b8:	16848493          	addi	s1,s1,360
    800018bc:	fd449de3          	bne	s1,s4,80001896 <procinit+0x78>
  }
}
    800018c0:	70e2                	ld	ra,56(sp)
    800018c2:	7442                	ld	s0,48(sp)
    800018c4:	74a2                	ld	s1,40(sp)
    800018c6:	7902                	ld	s2,32(sp)
    800018c8:	69e2                	ld	s3,24(sp)
    800018ca:	6a42                	ld	s4,16(sp)
    800018cc:	6aa2                	ld	s5,8(sp)
    800018ce:	6b02                	ld	s6,0(sp)
    800018d0:	6121                	addi	sp,sp,64
    800018d2:	8082                	ret

00000000800018d4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018d4:	1141                	addi	sp,sp,-16
    800018d6:	e406                	sd	ra,8(sp)
    800018d8:	e022                	sd	s0,0(sp)
    800018da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018de:	2501                	sext.w	a0,a0
    800018e0:	60a2                	ld	ra,8(sp)
    800018e2:	6402                	ld	s0,0(sp)
    800018e4:	0141                	addi	sp,sp,16
    800018e6:	8082                	ret

00000000800018e8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018e8:	1141                	addi	sp,sp,-16
    800018ea:	e406                	sd	ra,8(sp)
    800018ec:	e022                	sd	s0,0(sp)
    800018ee:	0800                	addi	s0,sp,16
    800018f0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018f2:	2781                	sext.w	a5,a5
    800018f4:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f6:	00011517          	auipc	a0,0x11
    800018fa:	b2a50513          	addi	a0,a0,-1238 # 80012420 <cpus>
    800018fe:	953e                	add	a0,a0,a5
    80001900:	60a2                	ld	ra,8(sp)
    80001902:	6402                	ld	s0,0(sp)
    80001904:	0141                	addi	sp,sp,16
    80001906:	8082                	ret

0000000080001908 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	1000                	addi	s0,sp,32
  push_off();
    80001912:	a9cff0ef          	jal	80000bae <push_off>
    80001916:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
    8000191c:	00011717          	auipc	a4,0x11
    80001920:	ad470713          	addi	a4,a4,-1324 # 800123f0 <pid_lock>
    80001924:	97ba                	add	a5,a5,a4
    80001926:	7b9c                	ld	a5,48(a5)
    80001928:	84be                	mv	s1,a5
  pop_off();
    8000192a:	afeff0ef          	jal	80000c28 <pop_off>
  return p;
}
    8000192e:	8526                	mv	a0,s1
    80001930:	60e2                	ld	ra,24(sp)
    80001932:	6442                	ld	s0,16(sp)
    80001934:	64a2                	ld	s1,8(sp)
    80001936:	6105                	addi	sp,sp,32
    80001938:	8082                	ret

000000008000193a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000193a:	7179                	addi	sp,sp,-48
    8000193c:	f406                	sd	ra,40(sp)
    8000193e:	f022                	sd	s0,32(sp)
    80001940:	ec26                	sd	s1,24(sp)
    80001942:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001944:	fc5ff0ef          	jal	80001908 <myproc>
    80001948:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000194a:	b26ff0ef          	jal	80000c70 <release>

  if (first) {
    8000194e:	00009797          	auipc	a5,0x9
    80001952:	9327a783          	lw	a5,-1742(a5) # 8000a280 <first.1>
    80001956:	cf85                	beqz	a5,8000198e <forkret+0x54>
    first = 0;
    80001958:	00009797          	auipc	a5,0x9
    8000195c:	9207a423          	sw	zero,-1752(a5) # 8000a280 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001960:	4505                	li	a0,1
    80001962:	405010ef          	jal	80003566 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001966:	00006797          	auipc	a5,0x6
    8000196a:	81a78793          	addi	a5,a5,-2022 # 80007180 <etext+0x180>
    8000196e:	fcf43823          	sd	a5,-48(s0)
    80001972:	fc043c23          	sd	zero,-40(s0)
    80001976:	fd040593          	addi	a1,s0,-48
    8000197a:	853e                	mv	a0,a5
    8000197c:	66d020ef          	jal	800047e8 <kexec>
    80001980:	6cbc                	ld	a5,88(s1)
    80001982:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001984:	6cbc                	ld	a5,88(s1)
    80001986:	7bb8                	ld	a4,112(a5)
    80001988:	57fd                	li	a5,-1
    8000198a:	02f70d63          	beq	a4,a5,800019c4 <forkret+0x8a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000198e:	2fd000ef          	jal	8000248a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001992:	68a8                	ld	a0,80(s1)
    80001994:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001996:	04000737          	lui	a4,0x4000
    8000199a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000199c:	0732                	slli	a4,a4,0xc
    8000199e:	00004797          	auipc	a5,0x4
    800019a2:	6fe78793          	addi	a5,a5,1790 # 8000609c <userret>
    800019a6:	00004697          	auipc	a3,0x4
    800019aa:	65a68693          	addi	a3,a3,1626 # 80006000 <_trampoline>
    800019ae:	8f95                	sub	a5,a5,a3
    800019b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019b2:	577d                	li	a4,-1
    800019b4:	177e                	slli	a4,a4,0x3f
    800019b6:	8d59                	or	a0,a0,a4
    800019b8:	9782                	jalr	a5
}
    800019ba:	70a2                	ld	ra,40(sp)
    800019bc:	7402                	ld	s0,32(sp)
    800019be:	64e2                	ld	s1,24(sp)
    800019c0:	6145                	addi	sp,sp,48
    800019c2:	8082                	ret
      panic("exec");
    800019c4:	00005517          	auipc	a0,0x5
    800019c8:	7c450513          	addi	a0,a0,1988 # 80007188 <etext+0x188>
    800019cc:	e69fe0ef          	jal	80000834 <panic>

00000000800019d0 <allocpid>:
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019da:	00011517          	auipc	a0,0x11
    800019de:	a1650513          	addi	a0,a0,-1514 # 800123f0 <pid_lock>
    800019e2:	a06ff0ef          	jal	80000be8 <acquire>
  pid = nextpid;
    800019e6:	00009797          	auipc	a5,0x9
    800019ea:	89e78793          	addi	a5,a5,-1890 # 8000a284 <nextpid>
    800019ee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019f0:	0014871b          	addiw	a4,s1,1
    800019f4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019f6:	00011517          	auipc	a0,0x11
    800019fa:	9fa50513          	addi	a0,a0,-1542 # 800123f0 <pid_lock>
    800019fe:	a72ff0ef          	jal	80000c70 <release>
}
    80001a02:	8526                	mv	a0,s1
    80001a04:	60e2                	ld	ra,24(sp)
    80001a06:	6442                	ld	s0,16(sp)
    80001a08:	64a2                	ld	s1,8(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret

0000000080001a0e <proc_pagetable>:
{
    80001a0e:	1101                	addi	sp,sp,-32
    80001a10:	ec06                	sd	ra,24(sp)
    80001a12:	e822                	sd	s0,16(sp)
    80001a14:	e426                	sd	s1,8(sp)
    80001a16:	e04a                	sd	s2,0(sp)
    80001a18:	1000                	addi	s0,sp,32
    80001a1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a1c:	f9eff0ef          	jal	800011ba <uvmcreate>
    80001a20:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a22:	cd05                	beqz	a0,80001a5a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a24:	4729                	li	a4,10
    80001a26:	00004697          	auipc	a3,0x4
    80001a2a:	5da68693          	addi	a3,a3,1498 # 80006000 <_trampoline>
    80001a2e:	6605                	lui	a2,0x1
    80001a30:	040005b7          	lui	a1,0x4000
    80001a34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a36:	05b2                	slli	a1,a1,0xc
    80001a38:	ddaff0ef          	jal	80001012 <mappages>
    80001a3c:	02054663          	bltz	a0,80001a68 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a40:	4719                	li	a4,6
    80001a42:	05893683          	ld	a3,88(s2)
    80001a46:	6605                	lui	a2,0x1
    80001a48:	020005b7          	lui	a1,0x2000
    80001a4c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a4e:	05b6                	slli	a1,a1,0xd
    80001a50:	8526                	mv	a0,s1
    80001a52:	dc0ff0ef          	jal	80001012 <mappages>
    80001a56:	00054f63          	bltz	a0,80001a74 <proc_pagetable+0x66>
}
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	60e2                	ld	ra,24(sp)
    80001a5e:	6442                	ld	s0,16(sp)
    80001a60:	64a2                	ld	s1,8(sp)
    80001a62:	6902                	ld	s2,0(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret
    uvmfree(pagetable, 0);
    80001a68:	4581                	li	a1,0
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	949ff0ef          	jal	800013b4 <uvmfree>
    return 0;
    80001a70:	4481                	li	s1,0
    80001a72:	b7e5                	j	80001a5a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a74:	4681                	li	a3,0
    80001a76:	4605                	li	a2,1
    80001a78:	040005b7          	lui	a1,0x4000
    80001a7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	05b2                	slli	a1,a1,0xc
    80001a80:	8526                	mv	a0,s1
    80001a82:	f5eff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a86:	4581                	li	a1,0
    80001a88:	8526                	mv	a0,s1
    80001a8a:	92bff0ef          	jal	800013b4 <uvmfree>
    return 0;
    80001a8e:	4481                	li	s1,0
    80001a90:	b7e9                	j	80001a5a <proc_pagetable+0x4c>

0000000080001a92 <proc_freepagetable>:
{
    80001a92:	1101                	addi	sp,sp,-32
    80001a94:	ec06                	sd	ra,24(sp)
    80001a96:	e822                	sd	s0,16(sp)
    80001a98:	e426                	sd	s1,8(sp)
    80001a9a:	e04a                	sd	s2,0(sp)
    80001a9c:	1000                	addi	s0,sp,32
    80001a9e:	84aa                	mv	s1,a0
    80001aa0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa2:	4681                	li	a3,0
    80001aa4:	4605                	li	a2,1
    80001aa6:	040005b7          	lui	a1,0x4000
    80001aaa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aac:	05b2                	slli	a1,a1,0xc
    80001aae:	f32ff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ab2:	4681                	li	a3,0
    80001ab4:	4605                	li	a2,1
    80001ab6:	020005b7          	lui	a1,0x2000
    80001aba:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001abc:	05b6                	slli	a1,a1,0xd
    80001abe:	8526                	mv	a0,s1
    80001ac0:	f20ff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ac4:	85ca                	mv	a1,s2
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	8edff0ef          	jal	800013b4 <uvmfree>
}
    80001acc:	60e2                	ld	ra,24(sp)
    80001ace:	6442                	ld	s0,16(sp)
    80001ad0:	64a2                	ld	s1,8(sp)
    80001ad2:	6902                	ld	s2,0(sp)
    80001ad4:	6105                	addi	sp,sp,32
    80001ad6:	8082                	ret

0000000080001ad8 <freeproc>:
{
    80001ad8:	1101                	addi	sp,sp,-32
    80001ada:	ec06                	sd	ra,24(sp)
    80001adc:	e822                	sd	s0,16(sp)
    80001ade:	e426                	sd	s1,8(sp)
    80001ae0:	1000                	addi	s0,sp,32
    80001ae2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ae4:	6d28                	ld	a0,88(a0)
    80001ae6:	c119                	beqz	a0,80001aec <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001ae8:	f3ffe0ef          	jal	80000a26 <kfree>
  p->trapframe = 0;
    80001aec:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001af0:	68a8                	ld	a0,80(s1)
    80001af2:	c501                	beqz	a0,80001afa <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001af4:	64ac                	ld	a1,72(s1)
    80001af6:	f9dff0ef          	jal	80001a92 <proc_freepagetable>
  p->pagetable = 0;
    80001afa:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001afe:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b02:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b06:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b0a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b0e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b12:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b16:	0004ac23          	sw	zero,24(s1)
}
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6105                	addi	sp,sp,32
    80001b22:	8082                	ret

0000000080001b24 <allocproc>:
{
    80001b24:	1101                	addi	sp,sp,-32
    80001b26:	ec06                	sd	ra,24(sp)
    80001b28:	e822                	sd	s0,16(sp)
    80001b2a:	e426                	sd	s1,8(sp)
    80001b2c:	e04a                	sd	s2,0(sp)
    80001b2e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b30:	00011497          	auipc	s1,0x11
    80001b34:	cf048493          	addi	s1,s1,-784 # 80012820 <proc>
    80001b38:	00016917          	auipc	s2,0x16
    80001b3c:	6e890913          	addi	s2,s2,1768 # 80018220 <tickslock>
    acquire(&p->lock);
    80001b40:	8526                	mv	a0,s1
    80001b42:	8a6ff0ef          	jal	80000be8 <acquire>
    if (p->state == UNUSED) {
    80001b46:	4c9c                	lw	a5,24(s1)
    80001b48:	cb91                	beqz	a5,80001b5c <allocproc+0x38>
      release(&p->lock);
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	924ff0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b50:	16848493          	addi	s1,s1,360
    80001b54:	ff2496e3          	bne	s1,s2,80001b40 <allocproc+0x1c>
  return 0;
    80001b58:	4481                	li	s1,0
    80001b5a:	a089                	j	80001b9c <allocproc+0x78>
  p->pid = allocpid();
    80001b5c:	e75ff0ef          	jal	800019d0 <allocpid>
    80001b60:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b62:	4785                	li	a5,1
    80001b64:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b66:	fa9fe0ef          	jal	80000b0e <kalloc>
    80001b6a:	892a                	mv	s2,a0
    80001b6c:	eca8                	sd	a0,88(s1)
    80001b6e:	cd15                	beqz	a0,80001baa <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b70:	8526                	mv	a0,s1
    80001b72:	e9dff0ef          	jal	80001a0e <proc_pagetable>
    80001b76:	892a                	mv	s2,a0
    80001b78:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b7a:	c121                	beqz	a0,80001bba <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b7c:	07000613          	li	a2,112
    80001b80:	4581                	li	a1,0
    80001b82:	06048513          	addi	a0,s1,96
    80001b86:	922ff0ef          	jal	80000ca8 <memset>
  p->context.ra = (uint64)forkret;
    80001b8a:	00000797          	auipc	a5,0x0
    80001b8e:	db078793          	addi	a5,a5,-592 # 8000193a <forkret>
    80001b92:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b94:	60bc                	ld	a5,64(s1)
    80001b96:	6705                	lui	a4,0x1
    80001b98:	97ba                	add	a5,a5,a4
    80001b9a:	f4bc                	sd	a5,104(s1)
}
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6902                	ld	s2,0(sp)
    80001ba6:	6105                	addi	sp,sp,32
    80001ba8:	8082                	ret
    freeproc(p);
    80001baa:	8526                	mv	a0,s1
    80001bac:	f2dff0ef          	jal	80001ad8 <freeproc>
    release(&p->lock);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	8beff0ef          	jal	80000c70 <release>
    return 0;
    80001bb6:	84ca                	mv	s1,s2
    80001bb8:	b7d5                	j	80001b9c <allocproc+0x78>
    freeproc(p);
    80001bba:	8526                	mv	a0,s1
    80001bbc:	f1dff0ef          	jal	80001ad8 <freeproc>
    release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8aeff0ef          	jal	80000c70 <release>
    return 0;
    80001bc6:	84ca                	mv	s1,s2
    80001bc8:	bfd1                	j	80001b9c <allocproc+0x78>

0000000080001bca <userinit>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bd4:	f51ff0ef          	jal	80001b24 <allocproc>
    80001bd8:	84aa                	mv	s1,a0
  initproc = p;
    80001bda:	00008797          	auipc	a5,0x8
    80001bde:	6ea7b723          	sd	a0,1774(a5) # 8000a2c8 <initproc>
  p->cwd = namei("/");
    80001be2:	00005517          	auipc	a0,0x5
    80001be6:	5ae50513          	addi	a0,a0,1454 # 80007190 <etext+0x190>
    80001bea:	6cd010ef          	jal	80003ab6 <namei>
    80001bee:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bf2:	478d                	li	a5,3
    80001bf4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	878ff0ef          	jal	80000c70 <release>
}
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret

0000000080001c06 <growproc>:
{
    80001c06:	1101                	addi	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	e04a                	sd	s2,0(sp)
    80001c10:	1000                	addi	s0,sp,32
    80001c12:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c14:	cf5ff0ef          	jal	80001908 <myproc>
    80001c18:	892a                	mv	s2,a0
  sz = p->sz;
    80001c1a:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c1c:	02905963          	blez	s1,80001c4e <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c20:	00b48633          	add	a2,s1,a1
    80001c24:	020007b7          	lui	a5,0x2000
    80001c28:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c2a:	07b6                	slli	a5,a5,0xd
    80001c2c:	02c7ea63          	bltu	a5,a2,80001c60 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c30:	4691                	li	a3,4
    80001c32:	6928                	ld	a0,80(a0)
    80001c34:	e7aff0ef          	jal	800012ae <uvmalloc>
    80001c38:	85aa                	mv	a1,a0
    80001c3a:	c50d                	beqz	a0,80001c64 <growproc+0x5e>
  p->sz = sz;
    80001c3c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c40:	4501                	li	a0,0
}
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6902                	ld	s2,0(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret
  } else if (n < 0) {
    80001c4e:	fe04d7e3          	bgez	s1,80001c3c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c52:	00b48633          	add	a2,s1,a1
    80001c56:	6928                	ld	a0,80(a0)
    80001c58:	e12ff0ef          	jal	8000126a <uvmdealloc>
    80001c5c:	85aa                	mv	a1,a0
    80001c5e:	bff9                	j	80001c3c <growproc+0x36>
      return -1;
    80001c60:	557d                	li	a0,-1
    80001c62:	b7c5                	j	80001c42 <growproc+0x3c>
      return -1;
    80001c64:	557d                	li	a0,-1
    80001c66:	bff1                	j	80001c42 <growproc+0x3c>

0000000080001c68 <kfork>:
{
    80001c68:	7139                	addi	sp,sp,-64
    80001c6a:	fc06                	sd	ra,56(sp)
    80001c6c:	f822                	sd	s0,48(sp)
    80001c6e:	f426                	sd	s1,40(sp)
    80001c70:	e456                	sd	s5,8(sp)
    80001c72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c74:	c95ff0ef          	jal	80001908 <myproc>
    80001c78:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c7a:	eabff0ef          	jal	80001b24 <allocproc>
    80001c7e:	0e050a63          	beqz	a0,80001d72 <kfork+0x10a>
    80001c82:	e852                	sd	s4,16(sp)
    80001c84:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c86:	048ab603          	ld	a2,72(s5)
    80001c8a:	692c                	ld	a1,80(a0)
    80001c8c:	050ab503          	ld	a0,80(s5)
    80001c90:	f56ff0ef          	jal	800013e6 <uvmcopy>
    80001c94:	04054863          	bltz	a0,80001ce4 <kfork+0x7c>
    80001c98:	f04a                	sd	s2,32(sp)
    80001c9a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c9c:	048ab783          	ld	a5,72(s5)
    80001ca0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ca4:	058ab683          	ld	a3,88(s5)
    80001ca8:	87b6                	mv	a5,a3
    80001caa:	058a3703          	ld	a4,88(s4)
    80001cae:	12068693          	addi	a3,a3,288
    80001cb2:	6388                	ld	a0,0(a5)
    80001cb4:	678c                	ld	a1,8(a5)
    80001cb6:	6b90                	ld	a2,16(a5)
    80001cb8:	e308                	sd	a0,0(a4)
    80001cba:	e70c                	sd	a1,8(a4)
    80001cbc:	eb10                	sd	a2,16(a4)
    80001cbe:	6f90                	ld	a2,24(a5)
    80001cc0:	ef10                	sd	a2,24(a4)
    80001cc2:	02078793          	addi	a5,a5,32
    80001cc6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001cca:	fed794e3          	bne	a5,a3,80001cb2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cce:	058a3783          	ld	a5,88(s4)
    80001cd2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cd6:	0d0a8493          	addi	s1,s5,208
    80001cda:	0d0a0913          	addi	s2,s4,208
    80001cde:	150a8993          	addi	s3,s5,336
    80001ce2:	a831                	j	80001cfe <kfork+0x96>
    freeproc(np);
    80001ce4:	8552                	mv	a0,s4
    80001ce6:	df3ff0ef          	jal	80001ad8 <freeproc>
    release(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	f85fe0ef          	jal	80000c70 <release>
    return -1;
    80001cf0:	54fd                	li	s1,-1
    80001cf2:	6a42                	ld	s4,16(sp)
    80001cf4:	a885                	j	80001d64 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001cf6:	04a1                	addi	s1,s1,8
    80001cf8:	0921                	addi	s2,s2,8
    80001cfa:	01348963          	beq	s1,s3,80001d0c <kfork+0xa4>
    if (p->ofile[i])
    80001cfe:	6088                	ld	a0,0(s1)
    80001d00:	d97d                	beqz	a0,80001cf6 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d02:	406020ef          	jal	80004108 <filedup>
    80001d06:	00a93023          	sd	a0,0(s2)
    80001d0a:	b7f5                	j	80001cf6 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d0c:	150ab503          	ld	a0,336(s5)
    80001d10:	4e4010ef          	jal	800031f4 <idup>
    80001d14:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d18:	4641                	li	a2,16
    80001d1a:	158a8593          	addi	a1,s5,344
    80001d1e:	158a0513          	addi	a0,s4,344
    80001d22:	8daff0ef          	jal	80000dfc <safestrcpy>
  pid = np->pid;
    80001d26:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	f45fe0ef          	jal	80000c70 <release>
  acquire(&wait_lock);
    80001d30:	00010517          	auipc	a0,0x10
    80001d34:	6d850513          	addi	a0,a0,1752 # 80012408 <wait_lock>
    80001d38:	eb1fe0ef          	jal	80000be8 <acquire>
  np->parent = p;
    80001d3c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d40:	00010517          	auipc	a0,0x10
    80001d44:	6c850513          	addi	a0,a0,1736 # 80012408 <wait_lock>
    80001d48:	f29fe0ef          	jal	80000c70 <release>
  acquire(&np->lock);
    80001d4c:	8552                	mv	a0,s4
    80001d4e:	e9bfe0ef          	jal	80000be8 <acquire>
  np->state = RUNNABLE;
    80001d52:	478d                	li	a5,3
    80001d54:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d58:	8552                	mv	a0,s4
    80001d5a:	f17fe0ef          	jal	80000c70 <release>
  return pid;
    80001d5e:	7902                	ld	s2,32(sp)
    80001d60:	69e2                	ld	s3,24(sp)
    80001d62:	6a42                	ld	s4,16(sp)
}
    80001d64:	8526                	mv	a0,s1
    80001d66:	70e2                	ld	ra,56(sp)
    80001d68:	7442                	ld	s0,48(sp)
    80001d6a:	74a2                	ld	s1,40(sp)
    80001d6c:	6aa2                	ld	s5,8(sp)
    80001d6e:	6121                	addi	sp,sp,64
    80001d70:	8082                	ret
    return -1;
    80001d72:	54fd                	li	s1,-1
    80001d74:	bfc5                	j	80001d64 <kfork+0xfc>

0000000080001d76 <scheduler>:
{
    80001d76:	711d                	addi	sp,sp,-96
    80001d78:	ec86                	sd	ra,88(sp)
    80001d7a:	e8a2                	sd	s0,80(sp)
    80001d7c:	e4a6                	sd	s1,72(sp)
    80001d7e:	e0ca                	sd	s2,64(sp)
    80001d80:	fc4e                	sd	s3,56(sp)
    80001d82:	f852                	sd	s4,48(sp)
    80001d84:	f456                	sd	s5,40(sp)
    80001d86:	f05a                	sd	s6,32(sp)
    80001d88:	ec5e                	sd	s7,24(sp)
    80001d8a:	e862                	sd	s8,16(sp)
    80001d8c:	e466                	sd	s9,8(sp)
    80001d8e:	1080                	addi	s0,sp,96
    80001d90:	8792                	mv	a5,tp
  int id = r_tp();
    80001d92:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d94:	00779a93          	slli	s5,a5,0x7
    80001d98:	00010717          	auipc	a4,0x10
    80001d9c:	65870713          	addi	a4,a4,1624 # 800123f0 <pid_lock>
    80001da0:	9756                	add	a4,a4,s5
    80001da2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da6:	00010717          	auipc	a4,0x10
    80001daa:	68270713          	addi	a4,a4,1666 # 80012428 <cpus+0x8>
    80001dae:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001db0:	4c11                	li	s8,4
        c->proc = p;
    80001db2:	00010b17          	auipc	s6,0x10
    80001db6:	63eb0b13          	addi	s6,s6,1598 # 800123f0 <pid_lock>
    80001dba:	079e                	slli	a5,a5,0x7
    80001dbc:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001dc0:	4b85                	li	s7,1
    80001dc2:	a0a9                	j	80001e0c <scheduler+0x96>
      release(&p->lock);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	eabfe0ef          	jal	80000c70 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dca:	16848493          	addi	s1,s1,360
    80001dce:	03248b63          	beq	s1,s2,80001e04 <scheduler+0x8e>
      acquire(&p->lock);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	e15fe0ef          	jal	80000be8 <acquire>
      if (p->state == RUNNABLE) {
    80001dd8:	4c9c                	lw	a5,24(s1)
    80001dda:	ff3795e3          	bne	a5,s3,80001dc4 <scheduler+0x4e>
        p->state = RUNNING;
    80001dde:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001de2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001de6:	06048593          	addi	a1,s1,96
    80001dea:	8556                	mv	a0,s5
    80001dec:	5f4000ef          	jal	800023e0 <swtch>
    80001df0:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001df2:	2781                	sext.w	a5,a5
    80001df4:	079e                	slli	a5,a5,0x7
    80001df6:	97da                	add	a5,a5,s6
    80001df8:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001dfc:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e00:	8cde                	mv	s9,s7
    80001e02:	b7c9                	j	80001dc4 <scheduler+0x4e>
    if (found == 0) {
    80001e04:	000c9463          	bnez	s9,80001e0c <scheduler+0x96>
      asm volatile("wfi");
    80001e08:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e0c:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e10:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e14:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e16:	00011497          	auipc	s1,0x11
    80001e1a:	a0a48493          	addi	s1,s1,-1526 # 80012820 <proc>
      if (p->state == RUNNABLE) {
    80001e1e:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e20:	00016917          	auipc	s2,0x16
    80001e24:	40090913          	addi	s2,s2,1024 # 80018220 <tickslock>
    80001e28:	b76d                	j	80001dd2 <scheduler+0x5c>

0000000080001e2a <sched>:
{
    80001e2a:	7179                	addi	sp,sp,-48
    80001e2c:	f406                	sd	ra,40(sp)
    80001e2e:	f022                	sd	s0,32(sp)
    80001e30:	ec26                	sd	s1,24(sp)
    80001e32:	e84a                	sd	s2,16(sp)
    80001e34:	e44e                	sd	s3,8(sp)
    80001e36:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e38:	ad1ff0ef          	jal	80001908 <myproc>
    80001e3c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e3e:	d45fe0ef          	jal	80000b82 <holding>
    80001e42:	c935                	beqz	a0,80001eb6 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e44:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e46:	2781                	sext.w	a5,a5
    80001e48:	079e                	slli	a5,a5,0x7
    80001e4a:	00010717          	auipc	a4,0x10
    80001e4e:	5a670713          	addi	a4,a4,1446 # 800123f0 <pid_lock>
    80001e52:	97ba                	add	a5,a5,a4
    80001e54:	0a87a703          	lw	a4,168(a5)
    80001e58:	4785                	li	a5,1
    80001e5a:	06f71463          	bne	a4,a5,80001ec2 <sched+0x98>
  if (p->state == RUNNING)
    80001e5e:	4c98                	lw	a4,24(s1)
    80001e60:	4791                	li	a5,4
    80001e62:	06f70663          	beq	a4,a5,80001ece <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e6a:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e6c:	e7bd                	bnez	a5,80001eda <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e6e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e70:	00010917          	auipc	s2,0x10
    80001e74:	58090913          	addi	s2,s2,1408 # 800123f0 <pid_lock>
    80001e78:	2781                	sext.w	a5,a5
    80001e7a:	079e                	slli	a5,a5,0x7
    80001e7c:	97ca                	add	a5,a5,s2
    80001e7e:	0ac7a983          	lw	s3,172(a5)
    80001e82:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e84:	2781                	sext.w	a5,a5
    80001e86:	079e                	slli	a5,a5,0x7
    80001e88:	07a1                	addi	a5,a5,8
    80001e8a:	00010597          	auipc	a1,0x10
    80001e8e:	59658593          	addi	a1,a1,1430 # 80012420 <cpus>
    80001e92:	95be                	add	a1,a1,a5
    80001e94:	06048513          	addi	a0,s1,96
    80001e98:	548000ef          	jal	800023e0 <swtch>
    80001e9c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e9e:	2781                	sext.w	a5,a5
    80001ea0:	079e                	slli	a5,a5,0x7
    80001ea2:	993e                	add	s2,s2,a5
    80001ea4:	0b392623          	sw	s3,172(s2)
}
    80001ea8:	70a2                	ld	ra,40(sp)
    80001eaa:	7402                	ld	s0,32(sp)
    80001eac:	64e2                	ld	s1,24(sp)
    80001eae:	6942                	ld	s2,16(sp)
    80001eb0:	69a2                	ld	s3,8(sp)
    80001eb2:	6145                	addi	sp,sp,48
    80001eb4:	8082                	ret
    panic("sched p->lock");
    80001eb6:	00005517          	auipc	a0,0x5
    80001eba:	2e250513          	addi	a0,a0,738 # 80007198 <etext+0x198>
    80001ebe:	977fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001ec2:	00005517          	auipc	a0,0x5
    80001ec6:	2e650513          	addi	a0,a0,742 # 800071a8 <etext+0x1a8>
    80001eca:	96bfe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001ece:	00005517          	auipc	a0,0x5
    80001ed2:	2ea50513          	addi	a0,a0,746 # 800071b8 <etext+0x1b8>
    80001ed6:	95ffe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001eda:	00005517          	auipc	a0,0x5
    80001ede:	2ee50513          	addi	a0,a0,750 # 800071c8 <etext+0x1c8>
    80001ee2:	953fe0ef          	jal	80000834 <panic>

0000000080001ee6 <yield>:
{
    80001ee6:	1101                	addi	sp,sp,-32
    80001ee8:	ec06                	sd	ra,24(sp)
    80001eea:	e822                	sd	s0,16(sp)
    80001eec:	e426                	sd	s1,8(sp)
    80001eee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ef0:	a19ff0ef          	jal	80001908 <myproc>
    80001ef4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ef6:	cf3fe0ef          	jal	80000be8 <acquire>
  p->state = RUNNABLE;
    80001efa:	478d                	li	a5,3
    80001efc:	cc9c                	sw	a5,24(s1)
  sched();
    80001efe:	f2dff0ef          	jal	80001e2a <sched>
  release(&p->lock);
    80001f02:	8526                	mv	a0,s1
    80001f04:	d6dfe0ef          	jal	80000c70 <release>
}
    80001f08:	60e2                	ld	ra,24(sp)
    80001f0a:	6442                	ld	s0,16(sp)
    80001f0c:	64a2                	ld	s1,8(sp)
    80001f0e:	6105                	addi	sp,sp,32
    80001f10:	8082                	ret

0000000080001f12 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f12:	1101                	addi	sp,sp,-32
    80001f14:	ec06                	sd	ra,24(sp)
    80001f16:	e822                	sd	s0,16(sp)
    80001f18:	e426                	sd	s1,8(sp)
    80001f1a:	e04a                	sd	s2,0(sp)
    80001f1c:	1000                	addi	s0,sp,32
    80001f1e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f20:	9e9ff0ef          	jal	80001908 <myproc>
    80001f24:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f26:	cc3fe0ef          	jal	80000be8 <acquire>
  if (chan == 0)
    80001f2a:	cc81                	beqz	s1,80001f42 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f2c:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f30:	854a                	mv	a0,s2
    80001f32:	d3ffe0ef          	jal	80000c70 <release>
}
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	64a2                	ld	s1,8(sp)
    80001f3c:	6902                	ld	s2,0(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001f42:	00005517          	auipc	a0,0x5
    80001f46:	29e50513          	addi	a0,a0,670 # 800071e0 <etext+0x1e0>
    80001f4a:	8ebfe0ef          	jal	80000834 <panic>

0000000080001f4e <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001f4e:	1101                	addi	sp,sp,-32
    80001f50:	ec06                	sd	ra,24(sp)
    80001f52:	e822                	sd	s0,16(sp)
    80001f54:	e426                	sd	s1,8(sp)
    80001f56:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f58:	9b1ff0ef          	jal	80001908 <myproc>
    80001f5c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f5e:	c8bfe0ef          	jal	80000be8 <acquire>
  if (p->chan != 0) {
    80001f62:	709c                	ld	a5,32(s1)
    80001f64:	c789                	beqz	a5,80001f6e <sleep+0x20>
    p->state = SLEEPING;
    80001f66:	4789                	li	a5,2
    80001f68:	cc9c                	sw	a5,24(s1)
    sched();
    80001f6a:	ec1ff0ef          	jal	80001e2a <sched>
  }
  release(&p->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	d01fe0ef          	jal	80000c70 <release>
}
    80001f74:	60e2                	ld	ra,24(sp)
    80001f76:	6442                	ld	s0,16(sp)
    80001f78:	64a2                	ld	s1,8(sp)
    80001f7a:	6105                	addi	sp,sp,32
    80001f7c:	8082                	ret

0000000080001f7e <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f7e:	7139                	addi	sp,sp,-64
    80001f80:	fc06                	sd	ra,56(sp)
    80001f82:	f822                	sd	s0,48(sp)
    80001f84:	f426                	sd	s1,40(sp)
    80001f86:	f04a                	sd	s2,32(sp)
    80001f88:	ec4e                	sd	s3,24(sp)
    80001f8a:	e852                	sd	s4,16(sp)
    80001f8c:	e456                	sd	s5,8(sp)
    80001f8e:	0080                	addi	s0,sp,64
    80001f90:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f92:	00011497          	auipc	s1,0x11
    80001f96:	88e48493          	addi	s1,s1,-1906 # 80012820 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001f9a:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001f9c:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	00016997          	auipc	s3,0x16
    80001fa2:	28298993          	addi	s3,s3,642 # 80018220 <tickslock>
    80001fa6:	a801                	j	80001fb6 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	cc7fe0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fae:	16848493          	addi	s1,s1,360
    80001fb2:	03348063          	beq	s1,s3,80001fd2 <wakeup+0x54>
    acquire(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	c31fe0ef          	jal	80000be8 <acquire>
    if (p->chan == chan) {
    80001fbc:	709c                	ld	a5,32(s1)
    80001fbe:	ff2795e3          	bne	a5,s2,80001fa8 <wakeup+0x2a>
      p->chan = 0;
    80001fc2:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001fc6:	4c9c                	lw	a5,24(s1)
    80001fc8:	ff4790e3          	bne	a5,s4,80001fa8 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fcc:	0154ac23          	sw	s5,24(s1)
    80001fd0:	bfe1                	j	80001fa8 <wakeup+0x2a>
  }
}
    80001fd2:	70e2                	ld	ra,56(sp)
    80001fd4:	7442                	ld	s0,48(sp)
    80001fd6:	74a2                	ld	s1,40(sp)
    80001fd8:	7902                	ld	s2,32(sp)
    80001fda:	69e2                	ld	s3,24(sp)
    80001fdc:	6a42                	ld	s4,16(sp)
    80001fde:	6aa2                	ld	s5,8(sp)
    80001fe0:	6121                	addi	sp,sp,64
    80001fe2:	8082                	ret

0000000080001fe4 <reparent>:
{
    80001fe4:	7179                	addi	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	e84a                	sd	s2,16(sp)
    80001fee:	e44e                	sd	s3,8(sp)
    80001ff0:	e052                	sd	s4,0(sp)
    80001ff2:	1800                	addi	s0,sp,48
    80001ff4:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001ff6:	00011497          	auipc	s1,0x11
    80001ffa:	82a48493          	addi	s1,s1,-2006 # 80012820 <proc>
      pp->parent = initproc;
    80001ffe:	00008a17          	auipc	s4,0x8
    80002002:	2caa0a13          	addi	s4,s4,714 # 8000a2c8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002006:	00016997          	auipc	s3,0x16
    8000200a:	21a98993          	addi	s3,s3,538 # 80018220 <tickslock>
    8000200e:	a029                	j	80002018 <reparent+0x34>
    80002010:	16848493          	addi	s1,s1,360
    80002014:	01348b63          	beq	s1,s3,8000202a <reparent+0x46>
    if (pp->parent == p) {
    80002018:	7c9c                	ld	a5,56(s1)
    8000201a:	ff279be3          	bne	a5,s2,80002010 <reparent+0x2c>
      pp->parent = initproc;
    8000201e:	000a3503          	ld	a0,0(s4)
    80002022:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002024:	f5bff0ef          	jal	80001f7e <wakeup>
    80002028:	b7e5                	j	80002010 <reparent+0x2c>
}
    8000202a:	70a2                	ld	ra,40(sp)
    8000202c:	7402                	ld	s0,32(sp)
    8000202e:	64e2                	ld	s1,24(sp)
    80002030:	6942                	ld	s2,16(sp)
    80002032:	69a2                	ld	s3,8(sp)
    80002034:	6a02                	ld	s4,0(sp)
    80002036:	6145                	addi	sp,sp,48
    80002038:	8082                	ret

000000008000203a <kexit>:
{
    8000203a:	7179                	addi	sp,sp,-48
    8000203c:	f406                	sd	ra,40(sp)
    8000203e:	f022                	sd	s0,32(sp)
    80002040:	ec26                	sd	s1,24(sp)
    80002042:	e84a                	sd	s2,16(sp)
    80002044:	e44e                	sd	s3,8(sp)
    80002046:	e052                	sd	s4,0(sp)
    80002048:	1800                	addi	s0,sp,48
    8000204a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000204c:	8bdff0ef          	jal	80001908 <myproc>
    80002050:	89aa                	mv	s3,a0
  if (p == initproc)
    80002052:	00008797          	auipc	a5,0x8
    80002056:	2767b783          	ld	a5,630(a5) # 8000a2c8 <initproc>
    8000205a:	0d050493          	addi	s1,a0,208
    8000205e:	15050913          	addi	s2,a0,336
    80002062:	00a79b63          	bne	a5,a0,80002078 <kexit+0x3e>
    panic("init exiting");
    80002066:	00005517          	auipc	a0,0x5
    8000206a:	19a50513          	addi	a0,a0,410 # 80007200 <etext+0x200>
    8000206e:	fc6fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002072:	04a1                	addi	s1,s1,8
    80002074:	01248963          	beq	s1,s2,80002086 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002078:	6088                	ld	a0,0(s1)
    8000207a:	dd65                	beqz	a0,80002072 <kexit+0x38>
      fileclose(f);
    8000207c:	0d2020ef          	jal	8000414e <fileclose>
      p->ofile[fd] = 0;
    80002080:	0004b023          	sd	zero,0(s1)
    80002084:	b7fd                	j	80002072 <kexit+0x38>
  begin_op();
    80002086:	40f010ef          	jal	80003c94 <begin_op>
  iput(p->cwd);
    8000208a:	1509b503          	ld	a0,336(s3)
    8000208e:	31e010ef          	jal	800033ac <iput>
  end_op();
    80002092:	48f010ef          	jal	80003d20 <end_op>
  p->cwd = 0;
    80002096:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000209a:	00010517          	auipc	a0,0x10
    8000209e:	36e50513          	addi	a0,a0,878 # 80012408 <wait_lock>
    800020a2:	b47fe0ef          	jal	80000be8 <acquire>
  reparent(p);
    800020a6:	854e                	mv	a0,s3
    800020a8:	f3dff0ef          	jal	80001fe4 <reparent>
  wakeup(p->parent);
    800020ac:	0389b503          	ld	a0,56(s3)
    800020b0:	ecfff0ef          	jal	80001f7e <wakeup>
  acquire(&p->lock);
    800020b4:	854e                	mv	a0,s3
    800020b6:	b33fe0ef          	jal	80000be8 <acquire>
  p->xstate = status;
    800020ba:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020be:	4795                	li	a5,5
    800020c0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020c4:	00010517          	auipc	a0,0x10
    800020c8:	34450513          	addi	a0,a0,836 # 80012408 <wait_lock>
    800020cc:	ba5fe0ef          	jal	80000c70 <release>
  sched();
    800020d0:	d5bff0ef          	jal	80001e2a <sched>
  panic("zombie exit");
    800020d4:	00005517          	auipc	a0,0x5
    800020d8:	13c50513          	addi	a0,a0,316 # 80007210 <etext+0x210>
    800020dc:	f58fe0ef          	jal	80000834 <panic>

00000000800020e0 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    800020e0:	c525                	beqz	a0,80002148 <kkill+0x68>
{
    800020e2:	7179                	addi	sp,sp,-48
    800020e4:	f406                	sd	ra,40(sp)
    800020e6:	f022                	sd	s0,32(sp)
    800020e8:	ec26                	sd	s1,24(sp)
    800020ea:	e84a                	sd	s2,16(sp)
    800020ec:	e44e                	sd	s3,8(sp)
    800020ee:	1800                	addi	s0,sp,48
    800020f0:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020f2:	00010497          	auipc	s1,0x10
    800020f6:	72e48493          	addi	s1,s1,1838 # 80012820 <proc>
    800020fa:	00016997          	auipc	s3,0x16
    800020fe:	12698993          	addi	s3,s3,294 # 80018220 <tickslock>
    acquire(&p->lock);
    80002102:	8526                	mv	a0,s1
    80002104:	ae5fe0ef          	jal	80000be8 <acquire>
    if (p->pid == pid) {
    80002108:	589c                	lw	a5,48(s1)
    8000210a:	01278b63          	beq	a5,s2,80002120 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	b61fe0ef          	jal	80000c70 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002114:	16848493          	addi	s1,s1,360
    80002118:	ff3495e3          	bne	s1,s3,80002102 <kkill+0x22>
  }
  return -1;
    8000211c:	557d                	li	a0,-1
    8000211e:	a819                	j	80002134 <kkill+0x54>
      p->killed = 1;
    80002120:	4785                	li	a5,1
    80002122:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002124:	4c98                	lw	a4,24(s1)
    80002126:	4789                	li	a5,2
    80002128:	00f70d63          	beq	a4,a5,80002142 <kkill+0x62>
      release(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	b43fe0ef          	jal	80000c70 <release>
      return 0;
    80002132:	4501                	li	a0,0
}
    80002134:	70a2                	ld	ra,40(sp)
    80002136:	7402                	ld	s0,32(sp)
    80002138:	64e2                	ld	s1,24(sp)
    8000213a:	6942                	ld	s2,16(sp)
    8000213c:	69a2                	ld	s3,8(sp)
    8000213e:	6145                	addi	sp,sp,48
    80002140:	8082                	ret
        p->state = RUNNABLE;
    80002142:	478d                	li	a5,3
    80002144:	cc9c                	sw	a5,24(s1)
    80002146:	b7dd                	j	8000212c <kkill+0x4c>
    return -1;
    80002148:	557d                	li	a0,-1
}
    8000214a:	8082                	ret

000000008000214c <setkilled>:

void
setkilled(struct proc *p)
{
    8000214c:	1101                	addi	sp,sp,-32
    8000214e:	ec06                	sd	ra,24(sp)
    80002150:	e822                	sd	s0,16(sp)
    80002152:	e426                	sd	s1,8(sp)
    80002154:	1000                	addi	s0,sp,32
    80002156:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002158:	a91fe0ef          	jal	80000be8 <acquire>
  p->killed = 1;
    8000215c:	4785                	li	a5,1
    8000215e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	b0ffe0ef          	jal	80000c70 <release>
}
    80002166:	60e2                	ld	ra,24(sp)
    80002168:	6442                	ld	s0,16(sp)
    8000216a:	64a2                	ld	s1,8(sp)
    8000216c:	6105                	addi	sp,sp,32
    8000216e:	8082                	ret

0000000080002170 <killed>:

int
killed(struct proc *p)
{
    80002170:	1101                	addi	sp,sp,-32
    80002172:	ec06                	sd	ra,24(sp)
    80002174:	e822                	sd	s0,16(sp)
    80002176:	e426                	sd	s1,8(sp)
    80002178:	e04a                	sd	s2,0(sp)
    8000217a:	1000                	addi	s0,sp,32
    8000217c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000217e:	a6bfe0ef          	jal	80000be8 <acquire>
  k = p->killed;
    80002182:	549c                	lw	a5,40(s1)
    80002184:	893e                	mv	s2,a5
  release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	ae9fe0ef          	jal	80000c70 <release>
  return k;
}
    8000218c:	854a                	mv	a0,s2
    8000218e:	60e2                	ld	ra,24(sp)
    80002190:	6442                	ld	s0,16(sp)
    80002192:	64a2                	ld	s1,8(sp)
    80002194:	6902                	ld	s2,0(sp)
    80002196:	6105                	addi	sp,sp,32
    80002198:	8082                	ret

000000008000219a <kwait>:
{
    8000219a:	715d                	addi	sp,sp,-80
    8000219c:	e486                	sd	ra,72(sp)
    8000219e:	e0a2                	sd	s0,64(sp)
    800021a0:	fc26                	sd	s1,56(sp)
    800021a2:	f84a                	sd	s2,48(sp)
    800021a4:	f44e                	sd	s3,40(sp)
    800021a6:	f052                	sd	s4,32(sp)
    800021a8:	ec56                	sd	s5,24(sp)
    800021aa:	e85a                	sd	s6,16(sp)
    800021ac:	e45e                	sd	s7,8(sp)
    800021ae:	0880                	addi	s0,sp,80
    800021b0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021b2:	f56ff0ef          	jal	80001908 <myproc>
    800021b6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021b8:	00010517          	auipc	a0,0x10
    800021bc:	25050513          	addi	a0,a0,592 # 80012408 <wait_lock>
    800021c0:	a29fe0ef          	jal	80000be8 <acquire>
        if (pp->state == ZOMBIE) {
    800021c4:	4a15                	li	s4,5
        havekids = 1;
    800021c6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021c8:	00016997          	auipc	s3,0x16
    800021cc:	05898993          	addi	s3,s3,88 # 80018220 <tickslock>
    release(&wait_lock);
    800021d0:	00010b17          	auipc	s6,0x10
    800021d4:	238b0b13          	addi	s6,s6,568 # 80012408 <wait_lock>
    800021d8:	a845                	j	80002288 <kwait+0xee>
          pid = pp->pid;
    800021da:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800021de:	000b8e63          	beqz	s7,800021fa <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800021e2:	4711                	li	a4,4
    800021e4:	02c48693          	addi	a3,s1,44
    800021e8:	865e                	mv	a2,s7
    800021ea:	04893583          	ld	a1,72(s2)
    800021ee:	05093503          	ld	a0,80(s2)
    800021f2:	b50ff0ef          	jal	80001542 <copyout>
          if (addr != 0 &&
    800021f6:	02054c63          	bltz	a0,8000222e <kwait+0x94>
          pp->parent = 0;
    800021fa:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    800021fe:	8526                	mv	a0,s1
    80002200:	8d9ff0ef          	jal	80001ad8 <freeproc>
          release(&pp->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	a6bfe0ef          	jal	80000c70 <release>
          release(&wait_lock);
    8000220a:	00010517          	auipc	a0,0x10
    8000220e:	1fe50513          	addi	a0,a0,510 # 80012408 <wait_lock>
    80002212:	a5ffe0ef          	jal	80000c70 <release>
}
    80002216:	854e                	mv	a0,s3
    80002218:	60a6                	ld	ra,72(sp)
    8000221a:	6406                	ld	s0,64(sp)
    8000221c:	74e2                	ld	s1,56(sp)
    8000221e:	7942                	ld	s2,48(sp)
    80002220:	79a2                	ld	s3,40(sp)
    80002222:	7a02                	ld	s4,32(sp)
    80002224:	6ae2                	ld	s5,24(sp)
    80002226:	6b42                	ld	s6,16(sp)
    80002228:	6ba2                	ld	s7,8(sp)
    8000222a:	6161                	addi	sp,sp,80
    8000222c:	8082                	ret
            release(&pp->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	a41fe0ef          	jal	80000c70 <release>
            release(&wait_lock);
    80002234:	00010517          	auipc	a0,0x10
    80002238:	1d450513          	addi	a0,a0,468 # 80012408 <wait_lock>
    8000223c:	a35fe0ef          	jal	80000c70 <release>
            return -1;
    80002240:	59fd                	li	s3,-1
    80002242:	bfd1                	j	80002216 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002244:	16848493          	addi	s1,s1,360
    80002248:	03348063          	beq	s1,s3,80002268 <kwait+0xce>
      if (pp->parent == p) {
    8000224c:	7c9c                	ld	a5,56(s1)
    8000224e:	ff279be3          	bne	a5,s2,80002244 <kwait+0xaa>
        acquire(&pp->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	995fe0ef          	jal	80000be8 <acquire>
        if (pp->state == ZOMBIE) {
    80002258:	4c9c                	lw	a5,24(s1)
    8000225a:	f94780e3          	beq	a5,s4,800021da <kwait+0x40>
        release(&pp->lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	a11fe0ef          	jal	80000c70 <release>
        havekids = 1;
    80002264:	8756                	mv	a4,s5
    80002266:	bff9                	j	80002244 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002268:	c715                	beqz	a4,80002294 <kwait+0xfa>
    8000226a:	854a                	mv	a0,s2
    8000226c:	f05ff0ef          	jal	80002170 <killed>
    80002270:	e115                	bnez	a0,80002294 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002272:	854a                	mv	a0,s2
    80002274:	c9fff0ef          	jal	80001f12 <sleep_prepare>
    release(&wait_lock);
    80002278:	855a                	mv	a0,s6
    8000227a:	9f7fe0ef          	jal	80000c70 <release>
    sleep();
    8000227e:	cd1ff0ef          	jal	80001f4e <sleep>
    acquire(&wait_lock);
    80002282:	855a                	mv	a0,s6
    80002284:	965fe0ef          	jal	80000be8 <acquire>
    havekids = 0;
    80002288:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000228a:	00010497          	auipc	s1,0x10
    8000228e:	59648493          	addi	s1,s1,1430 # 80012820 <proc>
    80002292:	bf6d                	j	8000224c <kwait+0xb2>
      release(&wait_lock);
    80002294:	00010517          	auipc	a0,0x10
    80002298:	17450513          	addi	a0,a0,372 # 80012408 <wait_lock>
    8000229c:	9d5fe0ef          	jal	80000c70 <release>
      return -1;
    800022a0:	59fd                	li	s3,-1
    800022a2:	bf95                	j	80002216 <kwait+0x7c>

00000000800022a4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022a4:	7179                	addi	sp,sp,-48
    800022a6:	f406                	sd	ra,40(sp)
    800022a8:	f022                	sd	s0,32(sp)
    800022aa:	ec26                	sd	s1,24(sp)
    800022ac:	e84a                	sd	s2,16(sp)
    800022ae:	e44e                	sd	s3,8(sp)
    800022b0:	e052                	sd	s4,0(sp)
    800022b2:	1800                	addi	s0,sp,48
    800022b4:	84aa                	mv	s1,a0
    800022b6:	8a2e                	mv	s4,a1
    800022b8:	89b2                	mv	s3,a2
    800022ba:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022bc:	e4cff0ef          	jal	80001908 <myproc>
  if (user_dst) {
    800022c0:	c085                	beqz	s1,800022e0 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800022c2:	874a                	mv	a4,s2
    800022c4:	86ce                	mv	a3,s3
    800022c6:	8652                	mv	a2,s4
    800022c8:	652c                	ld	a1,72(a0)
    800022ca:	6928                	ld	a0,80(a0)
    800022cc:	a76ff0ef          	jal	80001542 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022d0:	70a2                	ld	ra,40(sp)
    800022d2:	7402                	ld	s0,32(sp)
    800022d4:	64e2                	ld	s1,24(sp)
    800022d6:	6942                	ld	s2,16(sp)
    800022d8:	69a2                	ld	s3,8(sp)
    800022da:	6a02                	ld	s4,0(sp)
    800022dc:	6145                	addi	sp,sp,48
    800022de:	8082                	ret
    memmove((char *)dst, src, len);
    800022e0:	0009061b          	sext.w	a2,s2
    800022e4:	85ce                	mv	a1,s3
    800022e6:	8552                	mv	a0,s4
    800022e8:	a21fe0ef          	jal	80000d08 <memmove>
    return 0;
    800022ec:	8526                	mv	a0,s1
    800022ee:	b7cd                	j	800022d0 <either_copyout+0x2c>

00000000800022f0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022f0:	7179                	addi	sp,sp,-48
    800022f2:	f406                	sd	ra,40(sp)
    800022f4:	f022                	sd	s0,32(sp)
    800022f6:	ec26                	sd	s1,24(sp)
    800022f8:	e84a                	sd	s2,16(sp)
    800022fa:	e44e                	sd	s3,8(sp)
    800022fc:	e052                	sd	s4,0(sp)
    800022fe:	1800                	addi	s0,sp,48
    80002300:	8a2a                	mv	s4,a0
    80002302:	84ae                	mv	s1,a1
    80002304:	89b2                	mv	s3,a2
    80002306:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002308:	e00ff0ef          	jal	80001908 <myproc>
  if (user_src) {
    8000230c:	c085                	beqz	s1,8000232c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000230e:	874a                	mv	a4,s2
    80002310:	86ce                	mv	a3,s3
    80002312:	8652                	mv	a2,s4
    80002314:	652c                	ld	a1,72(a0)
    80002316:	6928                	ld	a0,80(a0)
    80002318:	af0ff0ef          	jal	80001608 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000231c:	70a2                	ld	ra,40(sp)
    8000231e:	7402                	ld	s0,32(sp)
    80002320:	64e2                	ld	s1,24(sp)
    80002322:	6942                	ld	s2,16(sp)
    80002324:	69a2                	ld	s3,8(sp)
    80002326:	6a02                	ld	s4,0(sp)
    80002328:	6145                	addi	sp,sp,48
    8000232a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000232c:	0009061b          	sext.w	a2,s2
    80002330:	85ce                	mv	a1,s3
    80002332:	8552                	mv	a0,s4
    80002334:	9d5fe0ef          	jal	80000d08 <memmove>
    return 0;
    80002338:	8526                	mv	a0,s1
    8000233a:	b7cd                	j	8000231c <either_copyin+0x2c>

000000008000233c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000233c:	715d                	addi	sp,sp,-80
    8000233e:	e486                	sd	ra,72(sp)
    80002340:	e0a2                	sd	s0,64(sp)
    80002342:	fc26                	sd	s1,56(sp)
    80002344:	f84a                	sd	s2,48(sp)
    80002346:	f44e                	sd	s3,40(sp)
    80002348:	f052                	sd	s4,32(sp)
    8000234a:	ec56                	sd	s5,24(sp)
    8000234c:	e85a                	sd	s6,16(sp)
    8000234e:	e45e                	sd	s7,8(sp)
    80002350:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002352:	00005517          	auipc	a0,0x5
    80002356:	d2650513          	addi	a0,a0,-730 # 80007078 <etext+0x78>
    8000235a:	9b0fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000235e:	00010497          	auipc	s1,0x10
    80002362:	61a48493          	addi	s1,s1,1562 # 80012978 <proc+0x158>
    80002366:	00016917          	auipc	s2,0x16
    8000236a:	01290913          	addi	s2,s2,18 # 80018378 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000236e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002370:	00005997          	auipc	s3,0x5
    80002374:	eb098993          	addi	s3,s3,-336 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002378:	00005a97          	auipc	s5,0x5
    8000237c:	eb0a8a93          	addi	s5,s5,-336 # 80007228 <etext+0x228>
    printk("\n");
    80002380:	00005a17          	auipc	s4,0x5
    80002384:	cf8a0a13          	addi	s4,s4,-776 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002388:	00005b97          	auipc	s7,0x5
    8000238c:	3c0b8b93          	addi	s7,s7,960 # 80007748 <states.0>
    80002390:	a829                	j	800023aa <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002392:	ed86a583          	lw	a1,-296(a3)
    80002396:	8556                	mv	a0,s5
    80002398:	972fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000239c:	8552                	mv	a0,s4
    8000239e:	96cfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023a2:	16848493          	addi	s1,s1,360
    800023a6:	03248263          	beq	s1,s2,800023ca <procdump+0x8e>
    if (p->state == UNUSED)
    800023aa:	86a6                	mv	a3,s1
    800023ac:	ec04a783          	lw	a5,-320(s1)
    800023b0:	dbed                	beqz	a5,800023a2 <procdump+0x66>
      state = "???";
    800023b2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b4:	fcfb6fe3          	bltu	s6,a5,80002392 <procdump+0x56>
    800023b8:	02079713          	slli	a4,a5,0x20
    800023bc:	01d75793          	srli	a5,a4,0x1d
    800023c0:	97de                	add	a5,a5,s7
    800023c2:	6390                	ld	a2,0(a5)
    800023c4:	f679                	bnez	a2,80002392 <procdump+0x56>
      state = "???";
    800023c6:	864e                	mv	a2,s3
    800023c8:	b7e9                	j	80002392 <procdump+0x56>
  }
}
    800023ca:	60a6                	ld	ra,72(sp)
    800023cc:	6406                	ld	s0,64(sp)
    800023ce:	74e2                	ld	s1,56(sp)
    800023d0:	7942                	ld	s2,48(sp)
    800023d2:	79a2                	ld	s3,40(sp)
    800023d4:	7a02                	ld	s4,32(sp)
    800023d6:	6ae2                	ld	s5,24(sp)
    800023d8:	6b42                	ld	s6,16(sp)
    800023da:	6ba2                	ld	s7,8(sp)
    800023dc:	6161                	addi	sp,sp,80
    800023de:	8082                	ret

00000000800023e0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023e0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023e4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023e8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023ea:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023ec:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023f0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023f4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023f8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023fc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002400:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002404:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002408:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000240c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002410:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002414:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002418:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000241c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000241e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002420:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002424:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002428:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000242c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002430:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002434:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002438:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000243c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002440:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002444:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002448:	8082                	ret

000000008000244a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000244a:	1141                	addi	sp,sp,-16
    8000244c:	e406                	sd	ra,8(sp)
    8000244e:	e022                	sd	s0,0(sp)
    80002450:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002452:	00005597          	auipc	a1,0x5
    80002456:	e1658593          	addi	a1,a1,-490 # 80007268 <etext+0x268>
    8000245a:	00016517          	auipc	a0,0x16
    8000245e:	dc650513          	addi	a0,a0,-570 # 80018220 <tickslock>
    80002462:	f06fe0ef          	jal	80000b68 <initlock>
}
    80002466:	60a2                	ld	ra,8(sp)
    80002468:	6402                	ld	s0,0(sp)
    8000246a:	0141                	addi	sp,sp,16
    8000246c:	8082                	ret

000000008000246e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000246e:	1141                	addi	sp,sp,-16
    80002470:	e406                	sd	ra,8(sp)
    80002472:	e022                	sd	s0,0(sp)
    80002474:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002476:	00003797          	auipc	a5,0x3
    8000247a:	13a78793          	addi	a5,a5,314 # 800055b0 <kernelvec>
    8000247e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002482:	60a2                	ld	ra,8(sp)
    80002484:	6402                	ld	s0,0(sp)
    80002486:	0141                	addi	sp,sp,16
    80002488:	8082                	ret

000000008000248a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000248a:	1141                	addi	sp,sp,-16
    8000248c:	e406                	sd	ra,8(sp)
    8000248e:	e022                	sd	s0,0(sp)
    80002490:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002492:	c76ff0ef          	jal	80001908 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002496:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000249a:	04000737          	lui	a4,0x4000
    8000249e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024a0:	0732                	slli	a4,a4,0xc
    800024a2:	00004797          	auipc	a5,0x4
    800024a6:	b5e78793          	addi	a5,a5,-1186 # 80006000 <_trampoline>
    800024aa:	00004697          	auipc	a3,0x4
    800024ae:	b5668693          	addi	a3,a3,-1194 # 80006000 <_trampoline>
    800024b2:	8f95                	sub	a5,a5,a3
    800024b4:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024b6:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024ba:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800024bc:	18002773          	csrr	a4,satp
    800024c0:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024c2:	6d38                	ld	a4,88(a0)
    800024c4:	613c                	ld	a5,64(a0)
    800024c6:	6685                	lui	a3,0x1
    800024c8:	97b6                	add	a5,a5,a3
    800024ca:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024cc:	6d3c                	ld	a5,88(a0)
    800024ce:	00000717          	auipc	a4,0x0
    800024d2:	0fc70713          	addi	a4,a4,252 # 800025ca <usertrap>
    800024d6:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800024d8:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800024da:	8712                	mv	a4,tp
    800024dc:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800024de:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024e2:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024e6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800024ea:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024ee:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800024f0:	6f9c                	ld	a5,24(a5)
    800024f2:	14179073          	csrw	sepc,a5
}
    800024f6:	60a2                	ld	ra,8(sp)
    800024f8:	6402                	ld	s0,0(sp)
    800024fa:	0141                	addi	sp,sp,16
    800024fc:	8082                	ret

00000000800024fe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024fe:	1141                	addi	sp,sp,-16
    80002500:	e406                	sd	ra,8(sp)
    80002502:	e022                	sd	s0,0(sp)
    80002504:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002506:	bceff0ef          	jal	800018d4 <cpuid>
    8000250a:	cd11                	beqz	a0,80002526 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000250c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002510:	000f4737          	lui	a4,0xf4
    80002514:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002518:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000251a:	14d79073          	csrw	stimecmp,a5
}
    8000251e:	60a2                	ld	ra,8(sp)
    80002520:	6402                	ld	s0,0(sp)
    80002522:	0141                	addi	sp,sp,16
    80002524:	8082                	ret
    acquire(&tickslock);
    80002526:	00016517          	auipc	a0,0x16
    8000252a:	cfa50513          	addi	a0,a0,-774 # 80018220 <tickslock>
    8000252e:	ebafe0ef          	jal	80000be8 <acquire>
    ticks++;
    80002532:	00008717          	auipc	a4,0x8
    80002536:	d9e70713          	addi	a4,a4,-610 # 8000a2d0 <ticks>
    8000253a:	431c                	lw	a5,0(a4)
    8000253c:	2785                	addiw	a5,a5,1
    8000253e:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002540:	853a                	mv	a0,a4
    80002542:	a3dff0ef          	jal	80001f7e <wakeup>
    release(&tickslock);
    80002546:	00016517          	auipc	a0,0x16
    8000254a:	cda50513          	addi	a0,a0,-806 # 80018220 <tickslock>
    8000254e:	f22fe0ef          	jal	80000c70 <release>
    80002552:	bf6d                	j	8000250c <clockintr+0xe>

0000000080002554 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002554:	1101                	addi	sp,sp,-32
    80002556:	ec06                	sd	ra,24(sp)
    80002558:	e822                	sd	s0,16(sp)
    8000255a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000255c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002560:	57fd                	li	a5,-1
    80002562:	17fe                	slli	a5,a5,0x3f
    80002564:	07a5                	addi	a5,a5,9
    80002566:	00f70c63          	beq	a4,a5,8000257e <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000256a:	57fd                	li	a5,-1
    8000256c:	17fe                	slli	a5,a5,0x3f
    8000256e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002570:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002572:	04f70863          	beq	a4,a5,800025c2 <devintr+0x6e>
  }
}
    80002576:	60e2                	ld	ra,24(sp)
    80002578:	6442                	ld	s0,16(sp)
    8000257a:	6105                	addi	sp,sp,32
    8000257c:	8082                	ret
    8000257e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002580:	0dc030ef          	jal	8000565c <plic_claim>
    80002584:	872a                	mv	a4,a0
    80002586:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002588:	47a9                	li	a5,10
    8000258a:	00f50963          	beq	a0,a5,8000259c <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000258e:	4785                	li	a5,1
    80002590:	00f50963          	beq	a0,a5,800025a2 <devintr+0x4e>
    return 1;
    80002594:	4505                	li	a0,1
    } else if (irq) {
    80002596:	eb09                	bnez	a4,800025a8 <devintr+0x54>
    80002598:	64a2                	ld	s1,8(sp)
    8000259a:	bff1                	j	80002576 <devintr+0x22>
      uartintr();
    8000259c:	c32fe0ef          	jal	800009ce <uartintr>
    if (irq)
    800025a0:	a819                	j	800025b6 <devintr+0x62>
      virtio_disk_intr();
    800025a2:	572030ef          	jal	80005b14 <virtio_disk_intr>
    if (irq)
    800025a6:	a801                	j	800025b6 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800025a8:	85ba                	mv	a1,a4
    800025aa:	00005517          	auipc	a0,0x5
    800025ae:	cc650513          	addi	a0,a0,-826 # 80007270 <etext+0x270>
    800025b2:	f59fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800025b6:	8526                	mv	a0,s1
    800025b8:	0c4030ef          	jal	8000567c <plic_complete>
    return 1;
    800025bc:	4505                	li	a0,1
    800025be:	64a2                	ld	s1,8(sp)
    800025c0:	bf5d                	j	80002576 <devintr+0x22>
    clockintr();
    800025c2:	f3dff0ef          	jal	800024fe <clockintr>
    return 2;
    800025c6:	4509                	li	a0,2
    800025c8:	b77d                	j	80002576 <devintr+0x22>

00000000800025ca <usertrap>:
{
    800025ca:	1101                	addi	sp,sp,-32
    800025cc:	ec06                	sd	ra,24(sp)
    800025ce:	e822                	sd	s0,16(sp)
    800025d0:	e426                	sd	s1,8(sp)
    800025d2:	e04a                	sd	s2,0(sp)
    800025d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025d6:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800025da:	1007f793          	andi	a5,a5,256
    800025de:	eba5                	bnez	a5,8000264e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025e0:	00003797          	auipc	a5,0x3
    800025e4:	fd078793          	addi	a5,a5,-48 # 800055b0 <kernelvec>
    800025e8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025ec:	b1cff0ef          	jal	80001908 <myproc>
    800025f0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025f2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025f4:	14102773          	csrr	a4,sepc
    800025f8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800025fa:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800025fe:	47a1                	li	a5,8
    80002600:	04f70d63          	beq	a4,a5,8000265a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002604:	f51ff0ef          	jal	80002554 <devintr>
    80002608:	892a                	mv	s2,a0
    8000260a:	e54d                	bnez	a0,800026b4 <usertrap+0xea>
    8000260c:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002610:	47bd                	li	a5,15
    80002612:	08f70463          	beq	a4,a5,8000269a <usertrap+0xd0>
    80002616:	14202773          	csrr	a4,scause
    8000261a:	47b5                	li	a5,13
    8000261c:	06f70f63          	beq	a4,a5,8000269a <usertrap+0xd0>
    80002620:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002624:	5890                	lw	a2,48(s1)
    80002626:	00005517          	auipc	a0,0x5
    8000262a:	c8a50513          	addi	a0,a0,-886 # 800072b0 <etext+0x2b0>
    8000262e:	eddfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002632:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002636:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000263a:	00005517          	auipc	a0,0x5
    8000263e:	ca650513          	addi	a0,a0,-858 # 800072e0 <etext+0x2e0>
    80002642:	ec9fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002646:	8526                	mv	a0,s1
    80002648:	b05ff0ef          	jal	8000214c <setkilled>
    8000264c:	a015                	j	80002670 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000264e:	00005517          	auipc	a0,0x5
    80002652:	c4250513          	addi	a0,a0,-958 # 80007290 <etext+0x290>
    80002656:	9defe0ef          	jal	80000834 <panic>
    if (killed(p))
    8000265a:	b17ff0ef          	jal	80002170 <killed>
    8000265e:	e915                	bnez	a0,80002692 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002660:	6cb8                	ld	a4,88(s1)
    80002662:	6f1c                	ld	a5,24(a4)
    80002664:	0791                	addi	a5,a5,4
    80002666:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002668:	10016073          	csrsi	sstatus,2
    syscall();
    8000266c:	244000ef          	jal	800028b0 <syscall>
  if (killed(p))
    80002670:	8526                	mv	a0,s1
    80002672:	affff0ef          	jal	80002170 <killed>
    80002676:	e521                	bnez	a0,800026be <usertrap+0xf4>
  prepare_return();
    80002678:	e13ff0ef          	jal	8000248a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000267c:	68a8                	ld	a0,80(s1)
    8000267e:	8131                	srli	a0,a0,0xc
    80002680:	57fd                	li	a5,-1
    80002682:	17fe                	slli	a5,a5,0x3f
    80002684:	8d5d                	or	a0,a0,a5
}
    80002686:	60e2                	ld	ra,24(sp)
    80002688:	6442                	ld	s0,16(sp)
    8000268a:	64a2                	ld	s1,8(sp)
    8000268c:	6902                	ld	s2,0(sp)
    8000268e:	6105                	addi	sp,sp,32
    80002690:	8082                	ret
      kexit(-1);
    80002692:	557d                	li	a0,-1
    80002694:	9a7ff0ef          	jal	8000203a <kexit>
    80002698:	b7e1                	j	80002660 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000269a:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000269e:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800026a2:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800026a4:	0016b693          	seqz	a3,a3
    800026a8:	64ac                	ld	a1,72(s1)
    800026aa:	68a8                	ld	a0,80(s1)
    800026ac:	e1bfe0ef          	jal	800014c6 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800026b0:	f161                	bnez	a0,80002670 <usertrap+0xa6>
    800026b2:	b7bd                	j	80002620 <usertrap+0x56>
  if (killed(p))
    800026b4:	8526                	mv	a0,s1
    800026b6:	abbff0ef          	jal	80002170 <killed>
    800026ba:	c511                	beqz	a0,800026c6 <usertrap+0xfc>
    800026bc:	a011                	j	800026c0 <usertrap+0xf6>
    800026be:	4901                	li	s2,0
    kexit(-1);
    800026c0:	557d                	li	a0,-1
    800026c2:	979ff0ef          	jal	8000203a <kexit>
  if (which_dev == 2)
    800026c6:	4789                	li	a5,2
    800026c8:	faf918e3          	bne	s2,a5,80002678 <usertrap+0xae>
    yield();
    800026cc:	81bff0ef          	jal	80001ee6 <yield>
    800026d0:	b765                	j	80002678 <usertrap+0xae>

00000000800026d2 <kerneltrap>:
{
    800026d2:	7179                	addi	sp,sp,-48
    800026d4:	f406                	sd	ra,40(sp)
    800026d6:	f022                	sd	s0,32(sp)
    800026d8:	ec26                	sd	s1,24(sp)
    800026da:	e84a                	sd	s2,16(sp)
    800026dc:	e44e                	sd	s3,8(sp)
    800026de:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026e0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026e4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800026e8:	142027f3          	csrr	a5,scause
    800026ec:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800026ee:	1004f793          	andi	a5,s1,256
    800026f2:	c795                	beqz	a5,8000271e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026f4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026f8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800026fa:	eb85                	bnez	a5,8000272a <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800026fc:	e59ff0ef          	jal	80002554 <devintr>
    80002700:	c91d                	beqz	a0,80002736 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002702:	4789                	li	a5,2
    80002704:	04f50a63          	beq	a0,a5,80002758 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002708:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000270c:	10049073          	csrw	sstatus,s1
}
    80002710:	70a2                	ld	ra,40(sp)
    80002712:	7402                	ld	s0,32(sp)
    80002714:	64e2                	ld	s1,24(sp)
    80002716:	6942                	ld	s2,16(sp)
    80002718:	69a2                	ld	s3,8(sp)
    8000271a:	6145                	addi	sp,sp,48
    8000271c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000271e:	00005517          	auipc	a0,0x5
    80002722:	bea50513          	addi	a0,a0,-1046 # 80007308 <etext+0x308>
    80002726:	90efe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    8000272a:	00005517          	auipc	a0,0x5
    8000272e:	c0650513          	addi	a0,a0,-1018 # 80007330 <etext+0x330>
    80002732:	902fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002736:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000273a:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000273e:	85ce                	mv	a1,s3
    80002740:	00005517          	auipc	a0,0x5
    80002744:	c1050513          	addi	a0,a0,-1008 # 80007350 <etext+0x350>
    80002748:	dc3fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000274c:	00005517          	auipc	a0,0x5
    80002750:	c2c50513          	addi	a0,a0,-980 # 80007378 <etext+0x378>
    80002754:	8e0fe0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002758:	9b0ff0ef          	jal	80001908 <myproc>
    8000275c:	d555                	beqz	a0,80002708 <kerneltrap+0x36>
    yield();
    8000275e:	f88ff0ef          	jal	80001ee6 <yield>
    80002762:	b75d                	j	80002708 <kerneltrap+0x36>

0000000080002764 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002764:	1101                	addi	sp,sp,-32
    80002766:	ec06                	sd	ra,24(sp)
    80002768:	e822                	sd	s0,16(sp)
    8000276a:	e426                	sd	s1,8(sp)
    8000276c:	1000                	addi	s0,sp,32
    8000276e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002770:	998ff0ef          	jal	80001908 <myproc>
  switch (n) {
    80002774:	4795                	li	a5,5
    80002776:	0497e163          	bltu	a5,s1,800027b8 <argraw+0x54>
    8000277a:	048a                	slli	s1,s1,0x2
    8000277c:	00005717          	auipc	a4,0x5
    80002780:	ffc70713          	addi	a4,a4,-4 # 80007778 <states.0+0x30>
    80002784:	94ba                	add	s1,s1,a4
    80002786:	409c                	lw	a5,0(s1)
    80002788:	97ba                	add	a5,a5,a4
    8000278a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000278c:	6d3c                	ld	a5,88(a0)
    8000278e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	64a2                	ld	s1,8(sp)
    80002796:	6105                	addi	sp,sp,32
    80002798:	8082                	ret
    return p->trapframe->a1;
    8000279a:	6d3c                	ld	a5,88(a0)
    8000279c:	7fa8                	ld	a0,120(a5)
    8000279e:	bfcd                	j	80002790 <argraw+0x2c>
    return p->trapframe->a2;
    800027a0:	6d3c                	ld	a5,88(a0)
    800027a2:	63c8                	ld	a0,128(a5)
    800027a4:	b7f5                	j	80002790 <argraw+0x2c>
    return p->trapframe->a3;
    800027a6:	6d3c                	ld	a5,88(a0)
    800027a8:	67c8                	ld	a0,136(a5)
    800027aa:	b7dd                	j	80002790 <argraw+0x2c>
    return p->trapframe->a4;
    800027ac:	6d3c                	ld	a5,88(a0)
    800027ae:	6bc8                	ld	a0,144(a5)
    800027b0:	b7c5                	j	80002790 <argraw+0x2c>
    return p->trapframe->a5;
    800027b2:	6d3c                	ld	a5,88(a0)
    800027b4:	6fc8                	ld	a0,152(a5)
    800027b6:	bfe9                	j	80002790 <argraw+0x2c>
  panic("argraw");
    800027b8:	00005517          	auipc	a0,0x5
    800027bc:	bd050513          	addi	a0,a0,-1072 # 80007388 <etext+0x388>
    800027c0:	874fe0ef          	jal	80000834 <panic>

00000000800027c4 <fetchaddr>:
{
    800027c4:	1101                	addi	sp,sp,-32
    800027c6:	ec06                	sd	ra,24(sp)
    800027c8:	e822                	sd	s0,16(sp)
    800027ca:	e426                	sd	s1,8(sp)
    800027cc:	e04a                	sd	s2,0(sp)
    800027ce:	1000                	addi	s0,sp,32
    800027d0:	84aa                	mv	s1,a0
    800027d2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027d4:	934ff0ef          	jal	80001908 <myproc>
  if (addr >= p->sz ||
    800027d8:	652c                	ld	a1,72(a0)
    800027da:	02b4f663          	bgeu	s1,a1,80002806 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027de:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800027e2:	02f5e463          	bltu	a1,a5,8000280a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800027e6:	4721                	li	a4,8
    800027e8:	86a6                	mv	a3,s1
    800027ea:	864a                	mv	a2,s2
    800027ec:	6928                	ld	a0,80(a0)
    800027ee:	e1bfe0ef          	jal	80001608 <copyin>
    800027f2:	00a03533          	snez	a0,a0
    800027f6:	40a0053b          	negw	a0,a0
}
    800027fa:	60e2                	ld	ra,24(sp)
    800027fc:	6442                	ld	s0,16(sp)
    800027fe:	64a2                	ld	s1,8(sp)
    80002800:	6902                	ld	s2,0(sp)
    80002802:	6105                	addi	sp,sp,32
    80002804:	8082                	ret
    return -1;
    80002806:	557d                	li	a0,-1
    80002808:	bfcd                	j	800027fa <fetchaddr+0x36>
    8000280a:	557d                	li	a0,-1
    8000280c:	b7fd                	j	800027fa <fetchaddr+0x36>

000000008000280e <fetchstr>:
{
    8000280e:	7179                	addi	sp,sp,-48
    80002810:	f406                	sd	ra,40(sp)
    80002812:	f022                	sd	s0,32(sp)
    80002814:	ec26                	sd	s1,24(sp)
    80002816:	e84a                	sd	s2,16(sp)
    80002818:	e44e                	sd	s3,8(sp)
    8000281a:	1800                	addi	s0,sp,48
    8000281c:	89aa                	mv	s3,a0
    8000281e:	84ae                	mv	s1,a1
    80002820:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002822:	8e6ff0ef          	jal	80001908 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002826:	874a                	mv	a4,s2
    80002828:	86ce                	mv	a3,s3
    8000282a:	8626                	mv	a2,s1
    8000282c:	652c                	ld	a1,72(a0)
    8000282e:	6928                	ld	a0,80(a0)
    80002830:	e75fe0ef          	jal	800016a4 <copyinstr>
    80002834:	00054c63          	bltz	a0,8000284c <fetchstr+0x3e>
  return strlen(buf);
    80002838:	8526                	mv	a0,s1
    8000283a:	df8fe0ef          	jal	80000e32 <strlen>
}
    8000283e:	70a2                	ld	ra,40(sp)
    80002840:	7402                	ld	s0,32(sp)
    80002842:	64e2                	ld	s1,24(sp)
    80002844:	6942                	ld	s2,16(sp)
    80002846:	69a2                	ld	s3,8(sp)
    80002848:	6145                	addi	sp,sp,48
    8000284a:	8082                	ret
    return -1;
    8000284c:	557d                	li	a0,-1
    8000284e:	bfc5                	j	8000283e <fetchstr+0x30>

0000000080002850 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	1000                	addi	s0,sp,32
    8000285a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000285c:	f09ff0ef          	jal	80002764 <argraw>
    80002860:	c088                	sw	a0,0(s1)
}
    80002862:	60e2                	ld	ra,24(sp)
    80002864:	6442                	ld	s0,16(sp)
    80002866:	64a2                	ld	s1,8(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret

000000008000286c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000286c:	1101                	addi	sp,sp,-32
    8000286e:	ec06                	sd	ra,24(sp)
    80002870:	e822                	sd	s0,16(sp)
    80002872:	e426                	sd	s1,8(sp)
    80002874:	1000                	addi	s0,sp,32
    80002876:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002878:	eedff0ef          	jal	80002764 <argraw>
    8000287c:	e088                	sd	a0,0(s1)
}
    8000287e:	60e2                	ld	ra,24(sp)
    80002880:	6442                	ld	s0,16(sp)
    80002882:	64a2                	ld	s1,8(sp)
    80002884:	6105                	addi	sp,sp,32
    80002886:	8082                	ret

0000000080002888 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002888:	1101                	addi	sp,sp,-32
    8000288a:	ec06                	sd	ra,24(sp)
    8000288c:	e822                	sd	s0,16(sp)
    8000288e:	e426                	sd	s1,8(sp)
    80002890:	e04a                	sd	s2,0(sp)
    80002892:	1000                	addi	s0,sp,32
    80002894:	892e                	mv	s2,a1
    80002896:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002898:	ecdff0ef          	jal	80002764 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000289c:	8626                	mv	a2,s1
    8000289e:	85ca                	mv	a1,s2
    800028a0:	f6fff0ef          	jal	8000280e <fetchstr>
}
    800028a4:	60e2                	ld	ra,24(sp)
    800028a6:	6442                	ld	s0,16(sp)
    800028a8:	64a2                	ld	s1,8(sp)
    800028aa:	6902                	ld	s2,0(sp)
    800028ac:	6105                	addi	sp,sp,32
    800028ae:	8082                	ret

00000000800028b0 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800028b0:	1101                	addi	sp,sp,-32
    800028b2:	ec06                	sd	ra,24(sp)
    800028b4:	e822                	sd	s0,16(sp)
    800028b6:	e426                	sd	s1,8(sp)
    800028b8:	e04a                	sd	s2,0(sp)
    800028ba:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028bc:	84cff0ef          	jal	80001908 <myproc>
    800028c0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028c2:	05853903          	ld	s2,88(a0)
    800028c6:	0a893783          	ld	a5,168(s2)
    800028ca:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028ce:	37fd                	addiw	a5,a5,-1
    800028d0:	4755                	li	a4,21
    800028d2:	00f76f63          	bltu	a4,a5,800028f0 <syscall+0x40>
    800028d6:	00369713          	slli	a4,a3,0x3
    800028da:	00005797          	auipc	a5,0x5
    800028de:	eb678793          	addi	a5,a5,-330 # 80007790 <syscalls>
    800028e2:	97ba                	add	a5,a5,a4
    800028e4:	639c                	ld	a5,0(a5)
    800028e6:	c789                	beqz	a5,800028f0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028e8:	9782                	jalr	a5
    800028ea:	06a93823          	sd	a0,112(s2)
    800028ee:	a829                	j	80002908 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800028f0:	15848613          	addi	a2,s1,344
    800028f4:	588c                	lw	a1,48(s1)
    800028f6:	00005517          	auipc	a0,0x5
    800028fa:	a9a50513          	addi	a0,a0,-1382 # 80007390 <etext+0x390>
    800028fe:	c0dfd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002902:	6cbc                	ld	a5,88(s1)
    80002904:	577d                	li	a4,-1
    80002906:	fbb8                	sd	a4,112(a5)
  }
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6902                	ld	s2,0(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret

0000000080002914 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002914:	1101                	addi	sp,sp,-32
    80002916:	ec06                	sd	ra,24(sp)
    80002918:	e822                	sd	s0,16(sp)
    8000291a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000291c:	fec40593          	addi	a1,s0,-20
    80002920:	4501                	li	a0,0
    80002922:	f2fff0ef          	jal	80002850 <argint>
  kexit(n);
    80002926:	fec42503          	lw	a0,-20(s0)
    8000292a:	f10ff0ef          	jal	8000203a <kexit>
  return 0; // not reached
}
    8000292e:	4501                	li	a0,0
    80002930:	60e2                	ld	ra,24(sp)
    80002932:	6442                	ld	s0,16(sp)
    80002934:	6105                	addi	sp,sp,32
    80002936:	8082                	ret

0000000080002938 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002938:	1141                	addi	sp,sp,-16
    8000293a:	e406                	sd	ra,8(sp)
    8000293c:	e022                	sd	s0,0(sp)
    8000293e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002940:	fc9fe0ef          	jal	80001908 <myproc>
}
    80002944:	5908                	lw	a0,48(a0)
    80002946:	60a2                	ld	ra,8(sp)
    80002948:	6402                	ld	s0,0(sp)
    8000294a:	0141                	addi	sp,sp,16
    8000294c:	8082                	ret

000000008000294e <sys_fork>:

uint64
sys_fork(void)
{
    8000294e:	1141                	addi	sp,sp,-16
    80002950:	e406                	sd	ra,8(sp)
    80002952:	e022                	sd	s0,0(sp)
    80002954:	0800                	addi	s0,sp,16
  return kfork();
    80002956:	b12ff0ef          	jal	80001c68 <kfork>
}
    8000295a:	60a2                	ld	ra,8(sp)
    8000295c:	6402                	ld	s0,0(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <sys_wait>:

uint64
sys_wait(void)
{
    80002962:	1101                	addi	sp,sp,-32
    80002964:	ec06                	sd	ra,24(sp)
    80002966:	e822                	sd	s0,16(sp)
    80002968:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000296a:	fe840593          	addi	a1,s0,-24
    8000296e:	4501                	li	a0,0
    80002970:	efdff0ef          	jal	8000286c <argaddr>
  return kwait(p);
    80002974:	fe843503          	ld	a0,-24(s0)
    80002978:	823ff0ef          	jal	8000219a <kwait>
}
    8000297c:	60e2                	ld	ra,24(sp)
    8000297e:	6442                	ld	s0,16(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret

0000000080002984 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002984:	7179                	addi	sp,sp,-48
    80002986:	f406                	sd	ra,40(sp)
    80002988:	f022                	sd	s0,32(sp)
    8000298a:	ec26                	sd	s1,24(sp)
    8000298c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000298e:	fd840593          	addi	a1,s0,-40
    80002992:	4501                	li	a0,0
    80002994:	ebdff0ef          	jal	80002850 <argint>
  argint(1, &t);
    80002998:	fdc40593          	addi	a1,s0,-36
    8000299c:	4505                	li	a0,1
    8000299e:	eb3ff0ef          	jal	80002850 <argint>
  addr = myproc()->sz;
    800029a2:	f67fe0ef          	jal	80001908 <myproc>
    800029a6:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    800029a8:	fdc42703          	lw	a4,-36(s0)
    800029ac:	4785                	li	a5,1
    800029ae:	02f70763          	beq	a4,a5,800029dc <sys_sbrk+0x58>
    800029b2:	fd842783          	lw	a5,-40(s0)
    800029b6:	0207c363          	bltz	a5,800029dc <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    800029ba:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    800029bc:	02000737          	lui	a4,0x2000
    800029c0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029c2:	0736                	slli	a4,a4,0xd
    800029c4:	02f76a63          	bltu	a4,a5,800029f8 <sys_sbrk+0x74>
    800029c8:	0297e863          	bltu	a5,s1,800029f8 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    800029cc:	f3dfe0ef          	jal	80001908 <myproc>
    800029d0:	fd842703          	lw	a4,-40(s0)
    800029d4:	653c                	ld	a5,72(a0)
    800029d6:	97ba                	add	a5,a5,a4
    800029d8:	e53c                	sd	a5,72(a0)
    800029da:	a039                	j	800029e8 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    800029dc:	fd842503          	lw	a0,-40(s0)
    800029e0:	a26ff0ef          	jal	80001c06 <growproc>
    800029e4:	00054863          	bltz	a0,800029f4 <sys_sbrk+0x70>
  }
  return addr;
}
    800029e8:	8526                	mv	a0,s1
    800029ea:	70a2                	ld	ra,40(sp)
    800029ec:	7402                	ld	s0,32(sp)
    800029ee:	64e2                	ld	s1,24(sp)
    800029f0:	6145                	addi	sp,sp,48
    800029f2:	8082                	ret
      return -1;
    800029f4:	54fd                	li	s1,-1
    800029f6:	bfcd                	j	800029e8 <sys_sbrk+0x64>
      return -1;
    800029f8:	54fd                	li	s1,-1
    800029fa:	b7fd                	j	800029e8 <sys_sbrk+0x64>

00000000800029fc <sys_pause>:

uint64
sys_pause(void)
{
    800029fc:	7139                	addi	sp,sp,-64
    800029fe:	fc06                	sd	ra,56(sp)
    80002a00:	f822                	sd	s0,48(sp)
    80002a02:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a04:	fcc40593          	addi	a1,s0,-52
    80002a08:	4501                	li	a0,0
    80002a0a:	e47ff0ef          	jal	80002850 <argint>
  if (n < 0)
    80002a0e:	fcc42783          	lw	a5,-52(s0)
    80002a12:	0807c063          	bltz	a5,80002a92 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a16:	00016517          	auipc	a0,0x16
    80002a1a:	80a50513          	addi	a0,a0,-2038 # 80018220 <tickslock>
    80002a1e:	9cafe0ef          	jal	80000be8 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002a22:	fcc42783          	lw	a5,-52(s0)
    80002a26:	cbb9                	beqz	a5,80002a7c <sys_pause+0x80>
    80002a28:	f426                	sd	s1,40(sp)
    80002a2a:	f04a                	sd	s2,32(sp)
    80002a2c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a2e:	00008997          	auipc	s3,0x8
    80002a32:	8a29a983          	lw	s3,-1886(s3) # 8000a2d0 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002a36:	00008917          	auipc	s2,0x8
    80002a3a:	89a90913          	addi	s2,s2,-1894 # 8000a2d0 <ticks>
    release(&tickslock);
    80002a3e:	00015497          	auipc	s1,0x15
    80002a42:	7e248493          	addi	s1,s1,2018 # 80018220 <tickslock>
    if (killed(myproc())) {
    80002a46:	ec3fe0ef          	jal	80001908 <myproc>
    80002a4a:	f26ff0ef          	jal	80002170 <killed>
    80002a4e:	e529                	bnez	a0,80002a98 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002a50:	854a                	mv	a0,s2
    80002a52:	cc0ff0ef          	jal	80001f12 <sleep_prepare>
    release(&tickslock);
    80002a56:	8526                	mv	a0,s1
    80002a58:	a18fe0ef          	jal	80000c70 <release>
    sleep();
    80002a5c:	cf2ff0ef          	jal	80001f4e <sleep>
    acquire(&tickslock);
    80002a60:	8526                	mv	a0,s1
    80002a62:	986fe0ef          	jal	80000be8 <acquire>
  while (ticks - ticks0 < n) {
    80002a66:	00092783          	lw	a5,0(s2)
    80002a6a:	413787bb          	subw	a5,a5,s3
    80002a6e:	fcc42703          	lw	a4,-52(s0)
    80002a72:	fce7eae3          	bltu	a5,a4,80002a46 <sys_pause+0x4a>
    80002a76:	74a2                	ld	s1,40(sp)
    80002a78:	7902                	ld	s2,32(sp)
    80002a7a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a7c:	00015517          	auipc	a0,0x15
    80002a80:	7a450513          	addi	a0,a0,1956 # 80018220 <tickslock>
    80002a84:	9ecfe0ef          	jal	80000c70 <release>
  return 0;
    80002a88:	4501                	li	a0,0
}
    80002a8a:	70e2                	ld	ra,56(sp)
    80002a8c:	7442                	ld	s0,48(sp)
    80002a8e:	6121                	addi	sp,sp,64
    80002a90:	8082                	ret
    n = 0;
    80002a92:	fc042623          	sw	zero,-52(s0)
    80002a96:	b741                	j	80002a16 <sys_pause+0x1a>
      release(&tickslock);
    80002a98:	00015517          	auipc	a0,0x15
    80002a9c:	78850513          	addi	a0,a0,1928 # 80018220 <tickslock>
    80002aa0:	9d0fe0ef          	jal	80000c70 <release>
      return -1;
    80002aa4:	557d                	li	a0,-1
    80002aa6:	74a2                	ld	s1,40(sp)
    80002aa8:	7902                	ld	s2,32(sp)
    80002aaa:	69e2                	ld	s3,24(sp)
    80002aac:	bff9                	j	80002a8a <sys_pause+0x8e>

0000000080002aae <sys_kill>:

uint64
sys_kill(void)
{
    80002aae:	1101                	addi	sp,sp,-32
    80002ab0:	ec06                	sd	ra,24(sp)
    80002ab2:	e822                	sd	s0,16(sp)
    80002ab4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ab6:	fec40593          	addi	a1,s0,-20
    80002aba:	4501                	li	a0,0
    80002abc:	d95ff0ef          	jal	80002850 <argint>
  return kkill(pid);
    80002ac0:	fec42503          	lw	a0,-20(s0)
    80002ac4:	e1cff0ef          	jal	800020e0 <kkill>
}
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	6105                	addi	sp,sp,32
    80002ace:	8082                	ret

0000000080002ad0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ada:	00015517          	auipc	a0,0x15
    80002ade:	74650513          	addi	a0,a0,1862 # 80018220 <tickslock>
    80002ae2:	906fe0ef          	jal	80000be8 <acquire>
  xticks = ticks;
    80002ae6:	00007797          	auipc	a5,0x7
    80002aea:	7ea7a783          	lw	a5,2026(a5) # 8000a2d0 <ticks>
    80002aee:	84be                	mv	s1,a5
  release(&tickslock);
    80002af0:	00015517          	auipc	a0,0x15
    80002af4:	73050513          	addi	a0,a0,1840 # 80018220 <tickslock>
    80002af8:	978fe0ef          	jal	80000c70 <release>
  return xticks;
}
    80002afc:	02049513          	slli	a0,s1,0x20
    80002b00:	9101                	srli	a0,a0,0x20
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	64a2                	ld	s1,8(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b0c:	7179                	addi	sp,sp,-48
    80002b0e:	f406                	sd	ra,40(sp)
    80002b10:	f022                	sd	s0,32(sp)
    80002b12:	ec26                	sd	s1,24(sp)
    80002b14:	e84a                	sd	s2,16(sp)
    80002b16:	e44e                	sd	s3,8(sp)
    80002b18:	e052                	sd	s4,0(sp)
    80002b1a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b1c:	00005597          	auipc	a1,0x5
    80002b20:	89458593          	addi	a1,a1,-1900 # 800073b0 <etext+0x3b0>
    80002b24:	00015517          	auipc	a0,0x15
    80002b28:	71450513          	addi	a0,a0,1812 # 80018238 <bcache>
    80002b2c:	83cfe0ef          	jal	80000b68 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b30:	0001d797          	auipc	a5,0x1d
    80002b34:	70878793          	addi	a5,a5,1800 # 80020238 <bcache+0x8000>
    80002b38:	0001e717          	auipc	a4,0x1e
    80002b3c:	96870713          	addi	a4,a4,-1688 # 800204a0 <bcache+0x8268>
    80002b40:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b44:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b48:	00015497          	auipc	s1,0x15
    80002b4c:	70848493          	addi	s1,s1,1800 # 80018250 <bcache+0x18>
    b->next = bcache.head.next;
    80002b50:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b52:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b54:	00005a17          	auipc	s4,0x5
    80002b58:	864a0a13          	addi	s4,s4,-1948 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002b5c:	2b893783          	ld	a5,696(s2)
    80002b60:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b62:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b66:	85d2                	mv	a1,s4
    80002b68:	01048513          	addi	a0,s1,16
    80002b6c:	40e010ef          	jal	80003f7a <initsleeplock>
    bcache.head.next->prev = b;
    80002b70:	2b893783          	ld	a5,696(s2)
    80002b74:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b76:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b7a:	45848493          	addi	s1,s1,1112
    80002b7e:	fd349fe3          	bne	s1,s3,80002b5c <binit+0x50>
  }
}
    80002b82:	70a2                	ld	ra,40(sp)
    80002b84:	7402                	ld	s0,32(sp)
    80002b86:	64e2                	ld	s1,24(sp)
    80002b88:	6942                	ld	s2,16(sp)
    80002b8a:	69a2                	ld	s3,8(sp)
    80002b8c:	6a02                	ld	s4,0(sp)
    80002b8e:	6145                	addi	sp,sp,48
    80002b90:	8082                	ret

0000000080002b92 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	e44e                	sd	s3,8(sp)
    80002b9e:	1800                	addi	s0,sp,48
    80002ba0:	892a                	mv	s2,a0
    80002ba2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ba4:	00015517          	auipc	a0,0x15
    80002ba8:	69450513          	addi	a0,a0,1684 # 80018238 <bcache>
    80002bac:	83cfe0ef          	jal	80000be8 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002bb0:	0001e497          	auipc	s1,0x1e
    80002bb4:	9404b483          	ld	s1,-1728(s1) # 800204f0 <bcache+0x82b8>
    80002bb8:	0001e797          	auipc	a5,0x1e
    80002bbc:	8e878793          	addi	a5,a5,-1816 # 800204a0 <bcache+0x8268>
    80002bc0:	02f48b63          	beq	s1,a5,80002bf6 <bread+0x64>
    80002bc4:	873e                	mv	a4,a5
    80002bc6:	a021                	j	80002bce <bread+0x3c>
    80002bc8:	68a4                	ld	s1,80(s1)
    80002bca:	02e48663          	beq	s1,a4,80002bf6 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002bce:	449c                	lw	a5,8(s1)
    80002bd0:	ff279ce3          	bne	a5,s2,80002bc8 <bread+0x36>
    80002bd4:	44dc                	lw	a5,12(s1)
    80002bd6:	ff3799e3          	bne	a5,s3,80002bc8 <bread+0x36>
      b->refcnt++;
    80002bda:	40bc                	lw	a5,64(s1)
    80002bdc:	2785                	addiw	a5,a5,1
    80002bde:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be0:	00015517          	auipc	a0,0x15
    80002be4:	65850513          	addi	a0,a0,1624 # 80018238 <bcache>
    80002be8:	888fe0ef          	jal	80000c70 <release>
      acquiresleep(&b->lock);
    80002bec:	01048513          	addi	a0,s1,16
    80002bf0:	3c0010ef          	jal	80003fb0 <acquiresleep>
      return b;
    80002bf4:	a889                	j	80002c46 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002bf6:	0001e497          	auipc	s1,0x1e
    80002bfa:	8f24b483          	ld	s1,-1806(s1) # 800204e8 <bcache+0x82b0>
    80002bfe:	0001e797          	auipc	a5,0x1e
    80002c02:	8a278793          	addi	a5,a5,-1886 # 800204a0 <bcache+0x8268>
    80002c06:	00f48863          	beq	s1,a5,80002c16 <bread+0x84>
    80002c0a:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c0c:	40bc                	lw	a5,64(s1)
    80002c0e:	cb91                	beqz	a5,80002c22 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c10:	64a4                	ld	s1,72(s1)
    80002c12:	fee49de3          	bne	s1,a4,80002c0c <bread+0x7a>
  panic("bget: no buffers");
    80002c16:	00004517          	auipc	a0,0x4
    80002c1a:	7aa50513          	addi	a0,a0,1962 # 800073c0 <etext+0x3c0>
    80002c1e:	c17fd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002c22:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c26:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c2a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c2e:	4785                	li	a5,1
    80002c30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c32:	00015517          	auipc	a0,0x15
    80002c36:	60650513          	addi	a0,a0,1542 # 80018238 <bcache>
    80002c3a:	836fe0ef          	jal	80000c70 <release>
      acquiresleep(&b->lock);
    80002c3e:	01048513          	addi	a0,s1,16
    80002c42:	36e010ef          	jal	80003fb0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002c46:	409c                	lw	a5,0(s1)
    80002c48:	cb89                	beqz	a5,80002c5a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	70a2                	ld	ra,40(sp)
    80002c4e:	7402                	ld	s0,32(sp)
    80002c50:	64e2                	ld	s1,24(sp)
    80002c52:	6942                	ld	s2,16(sp)
    80002c54:	69a2                	ld	s3,8(sp)
    80002c56:	6145                	addi	sp,sp,48
    80002c58:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c5a:	4581                	li	a1,0
    80002c5c:	8526                	mv	a0,s1
    80002c5e:	483020ef          	jal	800058e0 <virtio_disk_rw>
    b->valid = 1;
    80002c62:	4785                	li	a5,1
    80002c64:	c09c                	sw	a5,0(s1)
  return b;
    80002c66:	b7d5                	j	80002c4a <bread+0xb8>

0000000080002c68 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
    80002c72:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c74:	0541                	addi	a0,a0,16
    80002c76:	3c6010ef          	jal	8000403c <holdingsleep>
    80002c7a:	c911                	beqz	a0,80002c8e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c7c:	4585                	li	a1,1
    80002c7e:	8526                	mv	a0,s1
    80002c80:	461020ef          	jal	800058e0 <virtio_disk_rw>
}
    80002c84:	60e2                	ld	ra,24(sp)
    80002c86:	6442                	ld	s0,16(sp)
    80002c88:	64a2                	ld	s1,8(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret
    panic("bwrite");
    80002c8e:	00004517          	auipc	a0,0x4
    80002c92:	74a50513          	addi	a0,a0,1866 # 800073d8 <etext+0x3d8>
    80002c96:	b9ffd0ef          	jal	80000834 <panic>

0000000080002c9a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	e426                	sd	s1,8(sp)
    80002ca2:	e04a                	sd	s2,0(sp)
    80002ca4:	1000                	addi	s0,sp,32
    80002ca6:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002ca8:	01050913          	addi	s2,a0,16
    80002cac:	854a                	mv	a0,s2
    80002cae:	38e010ef          	jal	8000403c <holdingsleep>
    80002cb2:	c125                	beqz	a0,80002d12 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002cb4:	854a                	mv	a0,s2
    80002cb6:	34e010ef          	jal	80004004 <releasesleep>

  acquire(&bcache.lock);
    80002cba:	00015517          	auipc	a0,0x15
    80002cbe:	57e50513          	addi	a0,a0,1406 # 80018238 <bcache>
    80002cc2:	f27fd0ef          	jal	80000be8 <acquire>
  b->refcnt--;
    80002cc6:	40bc                	lw	a5,64(s1)
    80002cc8:	37fd                	addiw	a5,a5,-1
    80002cca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ccc:	e79d                	bnez	a5,80002cfa <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cce:	68b8                	ld	a4,80(s1)
    80002cd0:	64bc                	ld	a5,72(s1)
    80002cd2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cd4:	68b8                	ld	a4,80(s1)
    80002cd6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cd8:	0001d797          	auipc	a5,0x1d
    80002cdc:	56078793          	addi	a5,a5,1376 # 80020238 <bcache+0x8000>
    80002ce0:	2b87b703          	ld	a4,696(a5)
    80002ce4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ce6:	0001d717          	auipc	a4,0x1d
    80002cea:	7ba70713          	addi	a4,a4,1978 # 800204a0 <bcache+0x8268>
    80002cee:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cf0:	2b87b703          	ld	a4,696(a5)
    80002cf4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cf6:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002cfa:	00015517          	auipc	a0,0x15
    80002cfe:	53e50513          	addi	a0,a0,1342 # 80018238 <bcache>
    80002d02:	f6ffd0ef          	jal	80000c70 <release>
}
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	64a2                	ld	s1,8(sp)
    80002d0c:	6902                	ld	s2,0(sp)
    80002d0e:	6105                	addi	sp,sp,32
    80002d10:	8082                	ret
    panic("brelse");
    80002d12:	00004517          	auipc	a0,0x4
    80002d16:	6ce50513          	addi	a0,a0,1742 # 800073e0 <etext+0x3e0>
    80002d1a:	b1bfd0ef          	jal	80000834 <panic>

0000000080002d1e <bpin>:

void
bpin(struct buf *b)
{
    80002d1e:	1101                	addi	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	e426                	sd	s1,8(sp)
    80002d26:	1000                	addi	s0,sp,32
    80002d28:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d2a:	00015517          	auipc	a0,0x15
    80002d2e:	50e50513          	addi	a0,a0,1294 # 80018238 <bcache>
    80002d32:	eb7fd0ef          	jal	80000be8 <acquire>
  b->refcnt++;
    80002d36:	40bc                	lw	a5,64(s1)
    80002d38:	2785                	addiw	a5,a5,1
    80002d3a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d3c:	00015517          	auipc	a0,0x15
    80002d40:	4fc50513          	addi	a0,a0,1276 # 80018238 <bcache>
    80002d44:	f2dfd0ef          	jal	80000c70 <release>
}
    80002d48:	60e2                	ld	ra,24(sp)
    80002d4a:	6442                	ld	s0,16(sp)
    80002d4c:	64a2                	ld	s1,8(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret

0000000080002d52 <bunpin>:

void
bunpin(struct buf *b)
{
    80002d52:	1101                	addi	sp,sp,-32
    80002d54:	ec06                	sd	ra,24(sp)
    80002d56:	e822                	sd	s0,16(sp)
    80002d58:	e426                	sd	s1,8(sp)
    80002d5a:	1000                	addi	s0,sp,32
    80002d5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d5e:	00015517          	auipc	a0,0x15
    80002d62:	4da50513          	addi	a0,a0,1242 # 80018238 <bcache>
    80002d66:	e83fd0ef          	jal	80000be8 <acquire>
  b->refcnt--;
    80002d6a:	40bc                	lw	a5,64(s1)
    80002d6c:	37fd                	addiw	a5,a5,-1
    80002d6e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d70:	00015517          	auipc	a0,0x15
    80002d74:	4c850513          	addi	a0,a0,1224 # 80018238 <bcache>
    80002d78:	ef9fd0ef          	jal	80000c70 <release>
}
    80002d7c:	60e2                	ld	ra,24(sp)
    80002d7e:	6442                	ld	s0,16(sp)
    80002d80:	64a2                	ld	s1,8(sp)
    80002d82:	6105                	addi	sp,sp,32
    80002d84:	8082                	ret

0000000080002d86 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d86:	1101                	addi	sp,sp,-32
    80002d88:	ec06                	sd	ra,24(sp)
    80002d8a:	e822                	sd	s0,16(sp)
    80002d8c:	e426                	sd	s1,8(sp)
    80002d8e:	e04a                	sd	s2,0(sp)
    80002d90:	1000                	addi	s0,sp,32
    80002d92:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d94:	00d5d79b          	srliw	a5,a1,0xd
    80002d98:	0001e597          	auipc	a1,0x1e
    80002d9c:	b7c5a583          	lw	a1,-1156(a1) # 80020914 <sb+0x1c>
    80002da0:	9dbd                	addw	a1,a1,a5
    80002da2:	df1ff0ef          	jal	80002b92 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002da6:	0074f713          	andi	a4,s1,7
    80002daa:	4785                	li	a5,1
    80002dac:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002db0:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002db2:	90d9                	srli	s1,s1,0x36
    80002db4:	00950733          	add	a4,a0,s1
    80002db8:	05874703          	lbu	a4,88(a4)
    80002dbc:	00e7f6b3          	and	a3,a5,a4
    80002dc0:	c29d                	beqz	a3,80002de6 <bfree+0x60>
    80002dc2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002dc4:	94aa                	add	s1,s1,a0
    80002dc6:	fff7c793          	not	a5,a5
    80002dca:	8f7d                	and	a4,a4,a5
    80002dcc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dd0:	072010ef          	jal	80003e42 <log_write>
  brelse(bp);
    80002dd4:	854a                	mv	a0,s2
    80002dd6:	ec5ff0ef          	jal	80002c9a <brelse>
}
    80002dda:	60e2                	ld	ra,24(sp)
    80002ddc:	6442                	ld	s0,16(sp)
    80002dde:	64a2                	ld	s1,8(sp)
    80002de0:	6902                	ld	s2,0(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret
    panic("freeing free block");
    80002de6:	00004517          	auipc	a0,0x4
    80002dea:	60250513          	addi	a0,a0,1538 # 800073e8 <etext+0x3e8>
    80002dee:	a47fd0ef          	jal	80000834 <panic>

0000000080002df2 <balloc>:
{
    80002df2:	715d                	addi	sp,sp,-80
    80002df4:	e486                	sd	ra,72(sp)
    80002df6:	e0a2                	sd	s0,64(sp)
    80002df8:	fc26                	sd	s1,56(sp)
    80002dfa:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002dfc:	0001e797          	auipc	a5,0x1e
    80002e00:	b007a783          	lw	a5,-1280(a5) # 800208fc <sb+0x4>
    80002e04:	0e078263          	beqz	a5,80002ee8 <balloc+0xf6>
    80002e08:	f84a                	sd	s2,48(sp)
    80002e0a:	f44e                	sd	s3,40(sp)
    80002e0c:	f052                	sd	s4,32(sp)
    80002e0e:	ec56                	sd	s5,24(sp)
    80002e10:	e85a                	sd	s6,16(sp)
    80002e12:	e45e                	sd	s7,8(sp)
    80002e14:	e062                	sd	s8,0(sp)
    80002e16:	8baa                	mv	s7,a0
    80002e18:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e1a:	0001eb17          	auipc	s6,0x1e
    80002e1e:	adeb0b13          	addi	s6,s6,-1314 # 800208f8 <sb>
      m = 1 << (bi % 8);
    80002e22:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e24:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e26:	6c09                	lui	s8,0x2
    80002e28:	a09d                	j	80002e8e <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e2a:	97ca                	add	a5,a5,s2
    80002e2c:	8e55                	or	a2,a2,a3
    80002e2e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e32:	854a                	mv	a0,s2
    80002e34:	00e010ef          	jal	80003e42 <log_write>
        brelse(bp);
    80002e38:	854a                	mv	a0,s2
    80002e3a:	e61ff0ef          	jal	80002c9a <brelse>
  bp = bread(dev, bno);
    80002e3e:	85a6                	mv	a1,s1
    80002e40:	855e                	mv	a0,s7
    80002e42:	d51ff0ef          	jal	80002b92 <bread>
    80002e46:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e48:	40000613          	li	a2,1024
    80002e4c:	4581                	li	a1,0
    80002e4e:	05850513          	addi	a0,a0,88
    80002e52:	e57fd0ef          	jal	80000ca8 <memset>
  log_write(bp);
    80002e56:	854a                	mv	a0,s2
    80002e58:	7eb000ef          	jal	80003e42 <log_write>
  brelse(bp);
    80002e5c:	854a                	mv	a0,s2
    80002e5e:	e3dff0ef          	jal	80002c9a <brelse>
}
    80002e62:	7942                	ld	s2,48(sp)
    80002e64:	79a2                	ld	s3,40(sp)
    80002e66:	7a02                	ld	s4,32(sp)
    80002e68:	6ae2                	ld	s5,24(sp)
    80002e6a:	6b42                	ld	s6,16(sp)
    80002e6c:	6ba2                	ld	s7,8(sp)
    80002e6e:	6c02                	ld	s8,0(sp)
}
    80002e70:	8526                	mv	a0,s1
    80002e72:	60a6                	ld	ra,72(sp)
    80002e74:	6406                	ld	s0,64(sp)
    80002e76:	74e2                	ld	s1,56(sp)
    80002e78:	6161                	addi	sp,sp,80
    80002e7a:	8082                	ret
    brelse(bp);
    80002e7c:	854a                	mv	a0,s2
    80002e7e:	e1dff0ef          	jal	80002c9a <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002e82:	015c0abb          	addw	s5,s8,s5
    80002e86:	004b2783          	lw	a5,4(s6)
    80002e8a:	04faf863          	bgeu	s5,a5,80002eda <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002e8e:	40dad59b          	sraiw	a1,s5,0xd
    80002e92:	01cb2783          	lw	a5,28(s6)
    80002e96:	9dbd                	addw	a1,a1,a5
    80002e98:	855e                	mv	a0,s7
    80002e9a:	cf9ff0ef          	jal	80002b92 <bread>
    80002e9e:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ea0:	004b2503          	lw	a0,4(s6)
    80002ea4:	84d6                	mv	s1,s5
    80002ea6:	4701                	li	a4,0
    80002ea8:	fca4fae3          	bgeu	s1,a0,80002e7c <balloc+0x8a>
      m = 1 << (bi % 8);
    80002eac:	00777693          	andi	a3,a4,7
    80002eb0:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002eb4:	41f7579b          	sraiw	a5,a4,0x1f
    80002eb8:	01d7d79b          	srliw	a5,a5,0x1d
    80002ebc:	9fb9                	addw	a5,a5,a4
    80002ebe:	4037d79b          	sraiw	a5,a5,0x3
    80002ec2:	00f90633          	add	a2,s2,a5
    80002ec6:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002eca:	00c6f5b3          	and	a1,a3,a2
    80002ece:	ddb1                	beqz	a1,80002e2a <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ed0:	2705                	addiw	a4,a4,1
    80002ed2:	2485                	addiw	s1,s1,1
    80002ed4:	fd471ae3          	bne	a4,s4,80002ea8 <balloc+0xb6>
    80002ed8:	b755                	j	80002e7c <balloc+0x8a>
    80002eda:	7942                	ld	s2,48(sp)
    80002edc:	79a2                	ld	s3,40(sp)
    80002ede:	7a02                	ld	s4,32(sp)
    80002ee0:	6ae2                	ld	s5,24(sp)
    80002ee2:	6b42                	ld	s6,16(sp)
    80002ee4:	6ba2                	ld	s7,8(sp)
    80002ee6:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80002ee8:	00004517          	auipc	a0,0x4
    80002eec:	51850513          	addi	a0,a0,1304 # 80007400 <etext+0x400>
    80002ef0:	e1afd0ef          	jal	8000050a <printk>
  return 0;
    80002ef4:	4481                	li	s1,0
    80002ef6:	bfad                	j	80002e70 <balloc+0x7e>

0000000080002ef8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ef8:	7179                	addi	sp,sp,-48
    80002efa:	f406                	sd	ra,40(sp)
    80002efc:	f022                	sd	s0,32(sp)
    80002efe:	ec26                	sd	s1,24(sp)
    80002f00:	e84a                	sd	s2,16(sp)
    80002f02:	e44e                	sd	s3,8(sp)
    80002f04:	1800                	addi	s0,sp,48
    80002f06:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f08:	47ad                	li	a5,11
    80002f0a:	02b7e363          	bltu	a5,a1,80002f30 <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f0e:	02059793          	slli	a5,a1,0x20
    80002f12:	01e7d593          	srli	a1,a5,0x1e
    80002f16:	00b509b3          	add	s3,a0,a1
    80002f1a:	0509a483          	lw	s1,80(s3)
    80002f1e:	e0b5                	bnez	s1,80002f82 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f20:	4108                	lw	a0,0(a0)
    80002f22:	ed1ff0ef          	jal	80002df2 <balloc>
    80002f26:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f28:	cd29                	beqz	a0,80002f82 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f2a:	04a9a823          	sw	a0,80(s3)
    80002f2e:	a891                	j	80002f82 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f30:	ff45879b          	addiw	a5,a1,-12
    80002f34:	873e                	mv	a4,a5
    80002f36:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80002f38:	0ff00793          	li	a5,255
    80002f3c:	06e7e763          	bltu	a5,a4,80002faa <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f40:	08052483          	lw	s1,128(a0)
    80002f44:	e891                	bnez	s1,80002f58 <bmap+0x60>
      addr = balloc(ip->dev);
    80002f46:	4108                	lw	a0,0(a0)
    80002f48:	eabff0ef          	jal	80002df2 <balloc>
    80002f4c:	84aa                	mv	s1,a0
      if (addr == 0)
    80002f4e:	c915                	beqz	a0,80002f82 <bmap+0x8a>
    80002f50:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f52:	08a92023          	sw	a0,128(s2)
    80002f56:	a011                	j	80002f5a <bmap+0x62>
    80002f58:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f5a:	85a6                	mv	a1,s1
    80002f5c:	00092503          	lw	a0,0(s2)
    80002f60:	c33ff0ef          	jal	80002b92 <bread>
    80002f64:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002f66:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002f6a:	02099713          	slli	a4,s3,0x20
    80002f6e:	01e75593          	srli	a1,a4,0x1e
    80002f72:	97ae                	add	a5,a5,a1
    80002f74:	89be                	mv	s3,a5
    80002f76:	4384                	lw	s1,0(a5)
    80002f78:	cc89                	beqz	s1,80002f92 <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f7a:	8552                	mv	a0,s4
    80002f7c:	d1fff0ef          	jal	80002c9a <brelse>
    return addr;
    80002f80:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f82:	8526                	mv	a0,s1
    80002f84:	70a2                	ld	ra,40(sp)
    80002f86:	7402                	ld	s0,32(sp)
    80002f88:	64e2                	ld	s1,24(sp)
    80002f8a:	6942                	ld	s2,16(sp)
    80002f8c:	69a2                	ld	s3,8(sp)
    80002f8e:	6145                	addi	sp,sp,48
    80002f90:	8082                	ret
      addr = balloc(ip->dev);
    80002f92:	00092503          	lw	a0,0(s2)
    80002f96:	e5dff0ef          	jal	80002df2 <balloc>
    80002f9a:	84aa                	mv	s1,a0
      if (addr) {
    80002f9c:	dd79                	beqz	a0,80002f7a <bmap+0x82>
        a[bn] = addr;
    80002f9e:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002fa2:	8552                	mv	a0,s4
    80002fa4:	69f000ef          	jal	80003e42 <log_write>
    80002fa8:	bfc9                	j	80002f7a <bmap+0x82>
    80002faa:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fac:	00004517          	auipc	a0,0x4
    80002fb0:	46c50513          	addi	a0,a0,1132 # 80007418 <etext+0x418>
    80002fb4:	881fd0ef          	jal	80000834 <panic>

0000000080002fb8 <iget>:
{
    80002fb8:	7179                	addi	sp,sp,-48
    80002fba:	f406                	sd	ra,40(sp)
    80002fbc:	f022                	sd	s0,32(sp)
    80002fbe:	ec26                	sd	s1,24(sp)
    80002fc0:	e84a                	sd	s2,16(sp)
    80002fc2:	e44e                	sd	s3,8(sp)
    80002fc4:	e052                	sd	s4,0(sp)
    80002fc6:	1800                	addi	s0,sp,48
    80002fc8:	892a                	mv	s2,a0
    80002fca:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fcc:	0001e517          	auipc	a0,0x1e
    80002fd0:	94c50513          	addi	a0,a0,-1716 # 80020918 <itable>
    80002fd4:	c15fd0ef          	jal	80000be8 <acquire>
  empty = 0;
    80002fd8:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002fda:	0001e497          	auipc	s1,0x1e
    80002fde:	95648493          	addi	s1,s1,-1706 # 80020930 <itable+0x18>
    80002fe2:	0001f697          	auipc	a3,0x1f
    80002fe6:	3de68693          	addi	a3,a3,990 # 800223c0 <log>
    80002fea:	a809                	j	80002ffc <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002fec:	e781                	bnez	a5,80002ff4 <iget+0x3c>
    80002fee:	00099363          	bnez	s3,80002ff4 <iget+0x3c>
      empty = ip;
    80002ff2:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002ff4:	08848493          	addi	s1,s1,136
    80002ff8:	02d48563          	beq	s1,a3,80003022 <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80002ffc:	449c                	lw	a5,8(s1)
    80002ffe:	fef057e3          	blez	a5,80002fec <iget+0x34>
    80003002:	4098                	lw	a4,0(s1)
    80003004:	ff2718e3          	bne	a4,s2,80002ff4 <iget+0x3c>
    80003008:	40d8                	lw	a4,4(s1)
    8000300a:	ff4715e3          	bne	a4,s4,80002ff4 <iget+0x3c>
      ip->ref++;
    8000300e:	2785                	addiw	a5,a5,1
    80003010:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003012:	0001e517          	auipc	a0,0x1e
    80003016:	90650513          	addi	a0,a0,-1786 # 80020918 <itable>
    8000301a:	c57fd0ef          	jal	80000c70 <release>
      return ip;
    8000301e:	89a6                	mv	s3,s1
    80003020:	a015                	j	80003044 <iget+0x8c>
  if (empty == 0)
    80003022:	02098a63          	beqz	s3,80003056 <iget+0x9e>
  ip->dev = dev;
    80003026:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000302a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000302e:	4785                	li	a5,1
    80003030:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003034:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003038:	0001e517          	auipc	a0,0x1e
    8000303c:	8e050513          	addi	a0,a0,-1824 # 80020918 <itable>
    80003040:	c31fd0ef          	jal	80000c70 <release>
}
    80003044:	854e                	mv	a0,s3
    80003046:	70a2                	ld	ra,40(sp)
    80003048:	7402                	ld	s0,32(sp)
    8000304a:	64e2                	ld	s1,24(sp)
    8000304c:	6942                	ld	s2,16(sp)
    8000304e:	69a2                	ld	s3,8(sp)
    80003050:	6a02                	ld	s4,0(sp)
    80003052:	6145                	addi	sp,sp,48
    80003054:	8082                	ret
    panic("iget: no inodes");
    80003056:	00004517          	auipc	a0,0x4
    8000305a:	3da50513          	addi	a0,a0,986 # 80007430 <etext+0x430>
    8000305e:	fd6fd0ef          	jal	80000834 <panic>

0000000080003062 <iinit>:
{
    80003062:	7179                	addi	sp,sp,-48
    80003064:	f406                	sd	ra,40(sp)
    80003066:	f022                	sd	s0,32(sp)
    80003068:	ec26                	sd	s1,24(sp)
    8000306a:	e84a                	sd	s2,16(sp)
    8000306c:	e44e                	sd	s3,8(sp)
    8000306e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003070:	00004597          	auipc	a1,0x4
    80003074:	3d058593          	addi	a1,a1,976 # 80007440 <etext+0x440>
    80003078:	0001e517          	auipc	a0,0x1e
    8000307c:	8a050513          	addi	a0,a0,-1888 # 80020918 <itable>
    80003080:	ae9fd0ef          	jal	80000b68 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003084:	0001e497          	auipc	s1,0x1e
    80003088:	8bc48493          	addi	s1,s1,-1860 # 80020940 <itable+0x28>
    8000308c:	0001f997          	auipc	s3,0x1f
    80003090:	34498993          	addi	s3,s3,836 # 800223d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003094:	00004917          	auipc	s2,0x4
    80003098:	3b490913          	addi	s2,s2,948 # 80007448 <etext+0x448>
    8000309c:	85ca                	mv	a1,s2
    8000309e:	8526                	mv	a0,s1
    800030a0:	6db000ef          	jal	80003f7a <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    800030a4:	08848493          	addi	s1,s1,136
    800030a8:	ff349ae3          	bne	s1,s3,8000309c <iinit+0x3a>
}
    800030ac:	70a2                	ld	ra,40(sp)
    800030ae:	7402                	ld	s0,32(sp)
    800030b0:	64e2                	ld	s1,24(sp)
    800030b2:	6942                	ld	s2,16(sp)
    800030b4:	69a2                	ld	s3,8(sp)
    800030b6:	6145                	addi	sp,sp,48
    800030b8:	8082                	ret

00000000800030ba <ialloc>:
{
    800030ba:	7139                	addi	sp,sp,-64
    800030bc:	fc06                	sd	ra,56(sp)
    800030be:	f822                	sd	s0,48(sp)
    800030c0:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030c2:	0001e717          	auipc	a4,0x1e
    800030c6:	84272703          	lw	a4,-1982(a4) # 80020904 <sb+0xc>
    800030ca:	4785                	li	a5,1
    800030cc:	06e7f063          	bgeu	a5,a4,8000312c <ialloc+0x72>
    800030d0:	f426                	sd	s1,40(sp)
    800030d2:	f04a                	sd	s2,32(sp)
    800030d4:	ec4e                	sd	s3,24(sp)
    800030d6:	e852                	sd	s4,16(sp)
    800030d8:	e456                	sd	s5,8(sp)
    800030da:	e05a                	sd	s6,0(sp)
    800030dc:	8aaa                	mv	s5,a0
    800030de:	8b2e                	mv	s6,a1
    800030e0:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800030e2:	0001ea17          	auipc	s4,0x1e
    800030e6:	816a0a13          	addi	s4,s4,-2026 # 800208f8 <sb>
    800030ea:	00495593          	srli	a1,s2,0x4
    800030ee:	018a2783          	lw	a5,24(s4)
    800030f2:	9dbd                	addw	a1,a1,a5
    800030f4:	8556                	mv	a0,s5
    800030f6:	a9dff0ef          	jal	80002b92 <bread>
    800030fa:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800030fc:	05850993          	addi	s3,a0,88
    80003100:	00f97793          	andi	a5,s2,15
    80003104:	079a                	slli	a5,a5,0x6
    80003106:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003108:	00099783          	lh	a5,0(s3)
    8000310c:	cb9d                	beqz	a5,80003142 <ialloc+0x88>
    brelse(bp);
    8000310e:	b8dff0ef          	jal	80002c9a <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003112:	0905                	addi	s2,s2,1
    80003114:	00ca2703          	lw	a4,12(s4)
    80003118:	0009079b          	sext.w	a5,s2
    8000311c:	fce7e7e3          	bltu	a5,a4,800030ea <ialloc+0x30>
    80003120:	74a2                	ld	s1,40(sp)
    80003122:	7902                	ld	s2,32(sp)
    80003124:	69e2                	ld	s3,24(sp)
    80003126:	6a42                	ld	s4,16(sp)
    80003128:	6aa2                	ld	s5,8(sp)
    8000312a:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    8000312c:	00004517          	auipc	a0,0x4
    80003130:	32450513          	addi	a0,a0,804 # 80007450 <etext+0x450>
    80003134:	bd6fd0ef          	jal	8000050a <printk>
  return 0;
    80003138:	4501                	li	a0,0
}
    8000313a:	70e2                	ld	ra,56(sp)
    8000313c:	7442                	ld	s0,48(sp)
    8000313e:	6121                	addi	sp,sp,64
    80003140:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003142:	04000613          	li	a2,64
    80003146:	4581                	li	a1,0
    80003148:	854e                	mv	a0,s3
    8000314a:	b5ffd0ef          	jal	80000ca8 <memset>
      dip->type = type;
    8000314e:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003152:	8526                	mv	a0,s1
    80003154:	4ef000ef          	jal	80003e42 <log_write>
      brelse(bp);
    80003158:	8526                	mv	a0,s1
    8000315a:	b41ff0ef          	jal	80002c9a <brelse>
      return iget(dev, inum);
    8000315e:	0009059b          	sext.w	a1,s2
    80003162:	8556                	mv	a0,s5
    80003164:	e55ff0ef          	jal	80002fb8 <iget>
    80003168:	74a2                	ld	s1,40(sp)
    8000316a:	7902                	ld	s2,32(sp)
    8000316c:	69e2                	ld	s3,24(sp)
    8000316e:	6a42                	ld	s4,16(sp)
    80003170:	6aa2                	ld	s5,8(sp)
    80003172:	6b02                	ld	s6,0(sp)
    80003174:	b7d9                	j	8000313a <ialloc+0x80>

0000000080003176 <iupdate>:
{
    80003176:	1101                	addi	sp,sp,-32
    80003178:	ec06                	sd	ra,24(sp)
    8000317a:	e822                	sd	s0,16(sp)
    8000317c:	e426                	sd	s1,8(sp)
    8000317e:	e04a                	sd	s2,0(sp)
    80003180:	1000                	addi	s0,sp,32
    80003182:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003184:	415c                	lw	a5,4(a0)
    80003186:	0047d79b          	srliw	a5,a5,0x4
    8000318a:	0001d597          	auipc	a1,0x1d
    8000318e:	7865a583          	lw	a1,1926(a1) # 80020910 <sb+0x18>
    80003192:	9dbd                	addw	a1,a1,a5
    80003194:	4108                	lw	a0,0(a0)
    80003196:	9fdff0ef          	jal	80002b92 <bread>
    8000319a:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000319c:	05850793          	addi	a5,a0,88
    800031a0:	40d8                	lw	a4,4(s1)
    800031a2:	8b3d                	andi	a4,a4,15
    800031a4:	071a                	slli	a4,a4,0x6
    800031a6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031a8:	04449703          	lh	a4,68(s1)
    800031ac:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031b0:	04649703          	lh	a4,70(s1)
    800031b4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031b8:	04849703          	lh	a4,72(s1)
    800031bc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031c0:	04a49703          	lh	a4,74(s1)
    800031c4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031c8:	44f8                	lw	a4,76(s1)
    800031ca:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031cc:	03400613          	li	a2,52
    800031d0:	05048593          	addi	a1,s1,80
    800031d4:	00c78513          	addi	a0,a5,12
    800031d8:	b31fd0ef          	jal	80000d08 <memmove>
  log_write(bp);
    800031dc:	854a                	mv	a0,s2
    800031de:	465000ef          	jal	80003e42 <log_write>
  brelse(bp);
    800031e2:	854a                	mv	a0,s2
    800031e4:	ab7ff0ef          	jal	80002c9a <brelse>
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6902                	ld	s2,0(sp)
    800031f0:	6105                	addi	sp,sp,32
    800031f2:	8082                	ret

00000000800031f4 <idup>:
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	e426                	sd	s1,8(sp)
    800031fc:	1000                	addi	s0,sp,32
    800031fe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003200:	0001d517          	auipc	a0,0x1d
    80003204:	71850513          	addi	a0,a0,1816 # 80020918 <itable>
    80003208:	9e1fd0ef          	jal	80000be8 <acquire>
  ip->ref++;
    8000320c:	449c                	lw	a5,8(s1)
    8000320e:	2785                	addiw	a5,a5,1
    80003210:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003212:	0001d517          	auipc	a0,0x1d
    80003216:	70650513          	addi	a0,a0,1798 # 80020918 <itable>
    8000321a:	a57fd0ef          	jal	80000c70 <release>
}
    8000321e:	8526                	mv	a0,s1
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	64a2                	ld	s1,8(sp)
    80003226:	6105                	addi	sp,sp,32
    80003228:	8082                	ret

000000008000322a <ilock>:
{
    8000322a:	1101                	addi	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	e426                	sd	s1,8(sp)
    80003232:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003234:	cd19                	beqz	a0,80003252 <ilock+0x28>
    80003236:	84aa                	mv	s1,a0
    80003238:	451c                	lw	a5,8(a0)
    8000323a:	00f05c63          	blez	a5,80003252 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000323e:	0541                	addi	a0,a0,16
    80003240:	571000ef          	jal	80003fb0 <acquiresleep>
  if (ip->valid == 0) {
    80003244:	40bc                	lw	a5,64(s1)
    80003246:	cf89                	beqz	a5,80003260 <ilock+0x36>
}
    80003248:	60e2                	ld	ra,24(sp)
    8000324a:	6442                	ld	s0,16(sp)
    8000324c:	64a2                	ld	s1,8(sp)
    8000324e:	6105                	addi	sp,sp,32
    80003250:	8082                	ret
    80003252:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003254:	00004517          	auipc	a0,0x4
    80003258:	21450513          	addi	a0,a0,532 # 80007468 <etext+0x468>
    8000325c:	dd8fd0ef          	jal	80000834 <panic>
    80003260:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003262:	40dc                	lw	a5,4(s1)
    80003264:	0047d79b          	srliw	a5,a5,0x4
    80003268:	0001d597          	auipc	a1,0x1d
    8000326c:	6a85a583          	lw	a1,1704(a1) # 80020910 <sb+0x18>
    80003270:	9dbd                	addw	a1,a1,a5
    80003272:	4088                	lw	a0,0(s1)
    80003274:	91fff0ef          	jal	80002b92 <bread>
    80003278:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000327a:	05850593          	addi	a1,a0,88
    8000327e:	40dc                	lw	a5,4(s1)
    80003280:	8bbd                	andi	a5,a5,15
    80003282:	079a                	slli	a5,a5,0x6
    80003284:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003286:	00059783          	lh	a5,0(a1)
    8000328a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000328e:	00259783          	lh	a5,2(a1)
    80003292:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003296:	00459783          	lh	a5,4(a1)
    8000329a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000329e:	00659783          	lh	a5,6(a1)
    800032a2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032a6:	459c                	lw	a5,8(a1)
    800032a8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032aa:	03400613          	li	a2,52
    800032ae:	05b1                	addi	a1,a1,12
    800032b0:	05048513          	addi	a0,s1,80
    800032b4:	a55fd0ef          	jal	80000d08 <memmove>
    brelse(bp);
    800032b8:	854a                	mv	a0,s2
    800032ba:	9e1ff0ef          	jal	80002c9a <brelse>
    ip->valid = 1;
    800032be:	4785                	li	a5,1
    800032c0:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    800032c2:	04449783          	lh	a5,68(s1)
    800032c6:	c399                	beqz	a5,800032cc <ilock+0xa2>
    800032c8:	6902                	ld	s2,0(sp)
    800032ca:	bfbd                	j	80003248 <ilock+0x1e>
      panic("ilock: no type");
    800032cc:	00004517          	auipc	a0,0x4
    800032d0:	1a450513          	addi	a0,a0,420 # 80007470 <etext+0x470>
    800032d4:	d60fd0ef          	jal	80000834 <panic>

00000000800032d8 <iunlock>:
{
    800032d8:	1101                	addi	sp,sp,-32
    800032da:	ec06                	sd	ra,24(sp)
    800032dc:	e822                	sd	s0,16(sp)
    800032de:	e426                	sd	s1,8(sp)
    800032e0:	e04a                	sd	s2,0(sp)
    800032e2:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032e4:	c505                	beqz	a0,8000330c <iunlock+0x34>
    800032e6:	84aa                	mv	s1,a0
    800032e8:	01050913          	addi	s2,a0,16
    800032ec:	854a                	mv	a0,s2
    800032ee:	54f000ef          	jal	8000403c <holdingsleep>
    800032f2:	cd09                	beqz	a0,8000330c <iunlock+0x34>
    800032f4:	449c                	lw	a5,8(s1)
    800032f6:	00f05b63          	blez	a5,8000330c <iunlock+0x34>
  releasesleep(&ip->lock);
    800032fa:	854a                	mv	a0,s2
    800032fc:	509000ef          	jal	80004004 <releasesleep>
}
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	64a2                	ld	s1,8(sp)
    80003306:	6902                	ld	s2,0(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret
    panic("iunlock");
    8000330c:	00004517          	auipc	a0,0x4
    80003310:	17450513          	addi	a0,a0,372 # 80007480 <etext+0x480>
    80003314:	d20fd0ef          	jal	80000834 <panic>

0000000080003318 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003318:	7179                	addi	sp,sp,-48
    8000331a:	f406                	sd	ra,40(sp)
    8000331c:	f022                	sd	s0,32(sp)
    8000331e:	ec26                	sd	s1,24(sp)
    80003320:	e84a                	sd	s2,16(sp)
    80003322:	e44e                	sd	s3,8(sp)
    80003324:	1800                	addi	s0,sp,48
    80003326:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003328:	05050493          	addi	s1,a0,80
    8000332c:	08050913          	addi	s2,a0,128
    80003330:	a021                	j	80003338 <itrunc+0x20>
    80003332:	0491                	addi	s1,s1,4
    80003334:	01248b63          	beq	s1,s2,8000334a <itrunc+0x32>
    if (ip->addrs[i]) {
    80003338:	408c                	lw	a1,0(s1)
    8000333a:	dde5                	beqz	a1,80003332 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000333c:	0009a503          	lw	a0,0(s3)
    80003340:	a47ff0ef          	jal	80002d86 <bfree>
      ip->addrs[i] = 0;
    80003344:	0004a023          	sw	zero,0(s1)
    80003348:	b7ed                	j	80003332 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000334a:	0809a583          	lw	a1,128(s3)
    8000334e:	ed89                	bnez	a1,80003368 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003350:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003354:	854e                	mv	a0,s3
    80003356:	e21ff0ef          	jal	80003176 <iupdate>
}
    8000335a:	70a2                	ld	ra,40(sp)
    8000335c:	7402                	ld	s0,32(sp)
    8000335e:	64e2                	ld	s1,24(sp)
    80003360:	6942                	ld	s2,16(sp)
    80003362:	69a2                	ld	s3,8(sp)
    80003364:	6145                	addi	sp,sp,48
    80003366:	8082                	ret
    80003368:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000336a:	0009a503          	lw	a0,0(s3)
    8000336e:	825ff0ef          	jal	80002b92 <bread>
    80003372:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003374:	05850493          	addi	s1,a0,88
    80003378:	45850913          	addi	s2,a0,1112
    8000337c:	a021                	j	80003384 <itrunc+0x6c>
    8000337e:	0491                	addi	s1,s1,4
    80003380:	01248963          	beq	s1,s2,80003392 <itrunc+0x7a>
      if (a[j])
    80003384:	408c                	lw	a1,0(s1)
    80003386:	dde5                	beqz	a1,8000337e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003388:	0009a503          	lw	a0,0(s3)
    8000338c:	9fbff0ef          	jal	80002d86 <bfree>
    80003390:	b7fd                	j	8000337e <itrunc+0x66>
    brelse(bp);
    80003392:	8552                	mv	a0,s4
    80003394:	907ff0ef          	jal	80002c9a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003398:	0809a583          	lw	a1,128(s3)
    8000339c:	0009a503          	lw	a0,0(s3)
    800033a0:	9e7ff0ef          	jal	80002d86 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033a4:	0809a023          	sw	zero,128(s3)
    800033a8:	6a02                	ld	s4,0(sp)
    800033aa:	b75d                	j	80003350 <itrunc+0x38>

00000000800033ac <iput>:
{
    800033ac:	7179                	addi	sp,sp,-48
    800033ae:	f406                	sd	ra,40(sp)
    800033b0:	f022                	sd	s0,32(sp)
    800033b2:	ec26                	sd	s1,24(sp)
    800033b4:	1800                	addi	s0,sp,48
    800033b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033b8:	0001d517          	auipc	a0,0x1d
    800033bc:	56050513          	addi	a0,a0,1376 # 80020918 <itable>
    800033c0:	829fd0ef          	jal	80000be8 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800033c4:	449c                	lw	a5,8(s1)
    800033c6:	4705                	li	a4,1
    800033c8:	00e78f63          	beq	a5,a4,800033e6 <iput+0x3a>
  ip->ref--;
    800033cc:	37fd                	addiw	a5,a5,-1
    800033ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033d0:	0001d517          	auipc	a0,0x1d
    800033d4:	54850513          	addi	a0,a0,1352 # 80020918 <itable>
    800033d8:	899fd0ef          	jal	80000c70 <release>
}
    800033dc:	70a2                	ld	ra,40(sp)
    800033de:	7402                	ld	s0,32(sp)
    800033e0:	64e2                	ld	s1,24(sp)
    800033e2:	6145                	addi	sp,sp,48
    800033e4:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800033e6:	40b8                	lw	a4,64(s1)
    800033e8:	d375                	beqz	a4,800033cc <iput+0x20>
    800033ea:	e84a                	sd	s2,16(sp)
    800033ec:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800033ee:	0004aa03          	lw	s4,0(s1)
    800033f2:	0044a903          	lw	s2,4(s1)
  if (last) {
    800033f6:	04a49703          	lh	a4,74(s1)
    800033fa:	ef3d                	bnez	a4,80003478 <iput+0xcc>
    800033fc:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800033fe:	01048793          	addi	a5,s1,16
    80003402:	89be                	mv	s3,a5
    80003404:	853e                	mv	a0,a5
    80003406:	3ab000ef          	jal	80003fb0 <acquiresleep>
    release(&itable.lock);
    8000340a:	0001d517          	auipc	a0,0x1d
    8000340e:	50e50513          	addi	a0,a0,1294 # 80020918 <itable>
    80003412:	85ffd0ef          	jal	80000c70 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003416:	8526                	mv	a0,s1
    80003418:	f01ff0ef          	jal	80003318 <itrunc>
    ip->valid = 0;
    8000341c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003420:	854e                	mv	a0,s3
    80003422:	3e3000ef          	jal	80004004 <releasesleep>
    acquire(&itable.lock);
    80003426:	0001d517          	auipc	a0,0x1d
    8000342a:	4f250513          	addi	a0,a0,1266 # 80020918 <itable>
    8000342e:	fbafd0ef          	jal	80000be8 <acquire>
  ip->ref--;
    80003432:	449c                	lw	a5,8(s1)
    80003434:	37fd                	addiw	a5,a5,-1
    80003436:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003438:	0001d517          	auipc	a0,0x1d
    8000343c:	4e050513          	addi	a0,a0,1248 # 80020918 <itable>
    80003440:	831fd0ef          	jal	80000c70 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003444:	0049579b          	srliw	a5,s2,0x4
    80003448:	0001d597          	auipc	a1,0x1d
    8000344c:	4c85a583          	lw	a1,1224(a1) # 80020910 <sb+0x18>
    80003450:	9dbd                	addw	a1,a1,a5
    80003452:	8552                	mv	a0,s4
    80003454:	f3eff0ef          	jal	80002b92 <bread>
    80003458:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000345a:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    8000345e:	079a                	slli	a5,a5,0x6
    80003460:	97aa                	add	a5,a5,a0
    80003462:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    80003466:	1dd000ef          	jal	80003e42 <log_write>
  brelse(bp);
    8000346a:	8526                	mv	a0,s1
    8000346c:	82fff0ef          	jal	80002c9a <brelse>
}
    80003470:	6942                	ld	s2,16(sp)
    80003472:	69a2                	ld	s3,8(sp)
    80003474:	6a02                	ld	s4,0(sp)
    80003476:	b79d                	j	800033dc <iput+0x30>
    80003478:	6942                	ld	s2,16(sp)
    8000347a:	6a02                	ld	s4,0(sp)
    8000347c:	bf81                	j	800033cc <iput+0x20>

000000008000347e <iunlockput>:
{
    8000347e:	1101                	addi	sp,sp,-32
    80003480:	ec06                	sd	ra,24(sp)
    80003482:	e822                	sd	s0,16(sp)
    80003484:	e426                	sd	s1,8(sp)
    80003486:	1000                	addi	s0,sp,32
    80003488:	84aa                	mv	s1,a0
  iunlock(ip);
    8000348a:	e4fff0ef          	jal	800032d8 <iunlock>
  iput(ip);
    8000348e:	8526                	mv	a0,s1
    80003490:	f1dff0ef          	jal	800033ac <iput>
}
    80003494:	60e2                	ld	ra,24(sp)
    80003496:	6442                	ld	s0,16(sp)
    80003498:	64a2                	ld	s1,8(sp)
    8000349a:	6105                	addi	sp,sp,32
    8000349c:	8082                	ret

000000008000349e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000349e:	0001d717          	auipc	a4,0x1d
    800034a2:	46672703          	lw	a4,1126(a4) # 80020904 <sb+0xc>
    800034a6:	4785                	li	a5,1
    800034a8:	0ae7fe63          	bgeu	a5,a4,80003564 <ireclaim+0xc6>
{
    800034ac:	7139                	addi	sp,sp,-64
    800034ae:	fc06                	sd	ra,56(sp)
    800034b0:	f822                	sd	s0,48(sp)
    800034b2:	f426                	sd	s1,40(sp)
    800034b4:	f04a                	sd	s2,32(sp)
    800034b6:	ec4e                	sd	s3,24(sp)
    800034b8:	e852                	sd	s4,16(sp)
    800034ba:	e456                	sd	s5,8(sp)
    800034bc:	e05a                	sd	s6,0(sp)
    800034be:	0080                	addi	s0,sp,64
    800034c0:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034c2:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034c4:	0001da17          	auipc	s4,0x1d
    800034c8:	434a0a13          	addi	s4,s4,1076 # 800208f8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    800034cc:	00004b17          	auipc	s6,0x4
    800034d0:	fbcb0b13          	addi	s6,s6,-68 # 80007488 <etext+0x488>
    800034d4:	a099                	j	8000351a <ireclaim+0x7c>
    800034d6:	85ce                	mv	a1,s3
    800034d8:	855a                	mv	a0,s6
    800034da:	830fd0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800034de:	85ce                	mv	a1,s3
    800034e0:	8556                	mv	a0,s5
    800034e2:	ad7ff0ef          	jal	80002fb8 <iget>
    800034e6:	89aa                	mv	s3,a0
    brelse(bp);
    800034e8:	854a                	mv	a0,s2
    800034ea:	fb0ff0ef          	jal	80002c9a <brelse>
    if (ip) {
    800034ee:	00098f63          	beqz	s3,8000350c <ireclaim+0x6e>
      begin_op();
    800034f2:	7a2000ef          	jal	80003c94 <begin_op>
      ilock(ip);
    800034f6:	854e                	mv	a0,s3
    800034f8:	d33ff0ef          	jal	8000322a <ilock>
      iunlock(ip);
    800034fc:	854e                	mv	a0,s3
    800034fe:	ddbff0ef          	jal	800032d8 <iunlock>
      iput(ip);
    80003502:	854e                	mv	a0,s3
    80003504:	ea9ff0ef          	jal	800033ac <iput>
      end_op();
    80003508:	019000ef          	jal	80003d20 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000350c:	0485                	addi	s1,s1,1
    8000350e:	00ca2703          	lw	a4,12(s4)
    80003512:	0004879b          	sext.w	a5,s1
    80003516:	02e7fd63          	bgeu	a5,a4,80003550 <ireclaim+0xb2>
    8000351a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000351e:	0044d593          	srli	a1,s1,0x4
    80003522:	018a2783          	lw	a5,24(s4)
    80003526:	9dbd                	addw	a1,a1,a5
    80003528:	8556                	mv	a0,s5
    8000352a:	e68ff0ef          	jal	80002b92 <bread>
    8000352e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003530:	05850793          	addi	a5,a0,88
    80003534:	00f9f713          	andi	a4,s3,15
    80003538:	071a                	slli	a4,a4,0x6
    8000353a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000353c:	00079703          	lh	a4,0(a5)
    80003540:	c701                	beqz	a4,80003548 <ireclaim+0xaa>
    80003542:	00679783          	lh	a5,6(a5)
    80003546:	dbc1                	beqz	a5,800034d6 <ireclaim+0x38>
    brelse(bp);
    80003548:	854a                	mv	a0,s2
    8000354a:	f50ff0ef          	jal	80002c9a <brelse>
    if (ip) {
    8000354e:	bf7d                	j	8000350c <ireclaim+0x6e>
}
    80003550:	70e2                	ld	ra,56(sp)
    80003552:	7442                	ld	s0,48(sp)
    80003554:	74a2                	ld	s1,40(sp)
    80003556:	7902                	ld	s2,32(sp)
    80003558:	69e2                	ld	s3,24(sp)
    8000355a:	6a42                	ld	s4,16(sp)
    8000355c:	6aa2                	ld	s5,8(sp)
    8000355e:	6b02                	ld	s6,0(sp)
    80003560:	6121                	addi	sp,sp,64
    80003562:	8082                	ret
    80003564:	8082                	ret

0000000080003566 <fsinit>:
{
    80003566:	1101                	addi	sp,sp,-32
    80003568:	ec06                	sd	ra,24(sp)
    8000356a:	e822                	sd	s0,16(sp)
    8000356c:	e426                	sd	s1,8(sp)
    8000356e:	e04a                	sd	s2,0(sp)
    80003570:	1000                	addi	s0,sp,32
    80003572:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003574:	4585                	li	a1,1
    80003576:	e1cff0ef          	jal	80002b92 <bread>
    8000357a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000357c:	02000613          	li	a2,32
    80003580:	05850593          	addi	a1,a0,88
    80003584:	0001d517          	auipc	a0,0x1d
    80003588:	37450513          	addi	a0,a0,884 # 800208f8 <sb>
    8000358c:	f7cfd0ef          	jal	80000d08 <memmove>
  brelse(bp);
    80003590:	8526                	mv	a0,s1
    80003592:	f08ff0ef          	jal	80002c9a <brelse>
  if (sb.magic != FSMAGIC)
    80003596:	0001d717          	auipc	a4,0x1d
    8000359a:	36272703          	lw	a4,866(a4) # 800208f8 <sb>
    8000359e:	102037b7          	lui	a5,0x10203
    800035a2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035a6:	02f71263          	bne	a4,a5,800035ca <fsinit+0x64>
  initlog(dev, &sb);
    800035aa:	0001d597          	auipc	a1,0x1d
    800035ae:	34e58593          	addi	a1,a1,846 # 800208f8 <sb>
    800035b2:	854a                	mv	a0,s2
    800035b4:	65e000ef          	jal	80003c12 <initlog>
  ireclaim(dev);
    800035b8:	854a                	mv	a0,s2
    800035ba:	ee5ff0ef          	jal	8000349e <ireclaim>
}
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	64a2                	ld	s1,8(sp)
    800035c4:	6902                	ld	s2,0(sp)
    800035c6:	6105                	addi	sp,sp,32
    800035c8:	8082                	ret
    panic("invalid file system");
    800035ca:	00004517          	auipc	a0,0x4
    800035ce:	ede50513          	addi	a0,a0,-290 # 800074a8 <etext+0x4a8>
    800035d2:	a62fd0ef          	jal	80000834 <panic>

00000000800035d6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035d6:	1141                	addi	sp,sp,-16
    800035d8:	e406                	sd	ra,8(sp)
    800035da:	e022                	sd	s0,0(sp)
    800035dc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035de:	411c                	lw	a5,0(a0)
    800035e0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035e2:	415c                	lw	a5,4(a0)
    800035e4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035e6:	04451783          	lh	a5,68(a0)
    800035ea:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035ee:	04a51783          	lh	a5,74(a0)
    800035f2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800035f6:	04c56783          	lwu	a5,76(a0)
    800035fa:	e99c                	sd	a5,16(a1)
}
    800035fc:	60a2                	ld	ra,8(sp)
    800035fe:	6402                	ld	s0,0(sp)
    80003600:	0141                	addi	sp,sp,16
    80003602:	8082                	ret

0000000080003604 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003604:	457c                	lw	a5,76(a0)
    80003606:	0ed7e663          	bltu	a5,a3,800036f2 <readi+0xee>
{
    8000360a:	7159                	addi	sp,sp,-112
    8000360c:	f486                	sd	ra,104(sp)
    8000360e:	f0a2                	sd	s0,96(sp)
    80003610:	eca6                	sd	s1,88(sp)
    80003612:	e0d2                	sd	s4,64(sp)
    80003614:	fc56                	sd	s5,56(sp)
    80003616:	f85a                	sd	s6,48(sp)
    80003618:	f45e                	sd	s7,40(sp)
    8000361a:	1880                	addi	s0,sp,112
    8000361c:	8b2a                	mv	s6,a0
    8000361e:	8bae                	mv	s7,a1
    80003620:	8a32                	mv	s4,a2
    80003622:	84b6                	mv	s1,a3
    80003624:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003626:	9f35                	addw	a4,a4,a3
    return 0;
    80003628:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000362a:	0ad76b63          	bltu	a4,a3,800036e0 <readi+0xdc>
    8000362e:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003630:	00e7f463          	bgeu	a5,a4,80003638 <readi+0x34>
    n = ip->size - off;
    80003634:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003638:	080a8b63          	beqz	s5,800036ce <readi+0xca>
    8000363c:	e8ca                	sd	s2,80(sp)
    8000363e:	f062                	sd	s8,32(sp)
    80003640:	ec66                	sd	s9,24(sp)
    80003642:	e86a                	sd	s10,16(sp)
    80003644:	e46e                	sd	s11,8(sp)
    80003646:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003648:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000364c:	5c7d                	li	s8,-1
    8000364e:	a80d                	j	80003680 <readi+0x7c>
    80003650:	020d1d93          	slli	s11,s10,0x20
    80003654:	020ddd93          	srli	s11,s11,0x20
    80003658:	05890613          	addi	a2,s2,88
    8000365c:	86ee                	mv	a3,s11
    8000365e:	963e                	add	a2,a2,a5
    80003660:	85d2                	mv	a1,s4
    80003662:	855e                	mv	a0,s7
    80003664:	c41fe0ef          	jal	800022a4 <either_copyout>
    80003668:	05850363          	beq	a0,s8,800036ae <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000366c:	854a                	mv	a0,s2
    8000366e:	e2cff0ef          	jal	80002c9a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003672:	013d09bb          	addw	s3,s10,s3
    80003676:	009d04bb          	addw	s1,s10,s1
    8000367a:	9a6e                	add	s4,s4,s11
    8000367c:	0559f363          	bgeu	s3,s5,800036c2 <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    80003680:	00a4d59b          	srliw	a1,s1,0xa
    80003684:	855a                	mv	a0,s6
    80003686:	873ff0ef          	jal	80002ef8 <bmap>
    8000368a:	85aa                	mv	a1,a0
    if (addr == 0)
    8000368c:	c139                	beqz	a0,800036d2 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000368e:	000b2503          	lw	a0,0(s6)
    80003692:	d00ff0ef          	jal	80002b92 <bread>
    80003696:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003698:	3ff4f793          	andi	a5,s1,1023
    8000369c:	40fc873b          	subw	a4,s9,a5
    800036a0:	413a86bb          	subw	a3,s5,s3
    800036a4:	8d3a                	mv	s10,a4
    800036a6:	fae6f5e3          	bgeu	a3,a4,80003650 <readi+0x4c>
    800036aa:	8d36                	mv	s10,a3
    800036ac:	b755                	j	80003650 <readi+0x4c>
      brelse(bp);
    800036ae:	854a                	mv	a0,s2
    800036b0:	deaff0ef          	jal	80002c9a <brelse>
      tot = -1;
    800036b4:	59fd                	li	s3,-1
      break;
    800036b6:	6946                	ld	s2,80(sp)
    800036b8:	7c02                	ld	s8,32(sp)
    800036ba:	6ce2                	ld	s9,24(sp)
    800036bc:	6d42                	ld	s10,16(sp)
    800036be:	6da2                	ld	s11,8(sp)
    800036c0:	a831                	j	800036dc <readi+0xd8>
    800036c2:	6946                	ld	s2,80(sp)
    800036c4:	7c02                	ld	s8,32(sp)
    800036c6:	6ce2                	ld	s9,24(sp)
    800036c8:	6d42                	ld	s10,16(sp)
    800036ca:	6da2                	ld	s11,8(sp)
    800036cc:	a801                	j	800036dc <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036ce:	89d6                	mv	s3,s5
    800036d0:	a031                	j	800036dc <readi+0xd8>
    800036d2:	6946                	ld	s2,80(sp)
    800036d4:	7c02                	ld	s8,32(sp)
    800036d6:	6ce2                	ld	s9,24(sp)
    800036d8:	6d42                	ld	s10,16(sp)
    800036da:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036dc:	854e                	mv	a0,s3
    800036de:	69a6                	ld	s3,72(sp)
}
    800036e0:	70a6                	ld	ra,104(sp)
    800036e2:	7406                	ld	s0,96(sp)
    800036e4:	64e6                	ld	s1,88(sp)
    800036e6:	6a06                	ld	s4,64(sp)
    800036e8:	7ae2                	ld	s5,56(sp)
    800036ea:	7b42                	ld	s6,48(sp)
    800036ec:	7ba2                	ld	s7,40(sp)
    800036ee:	6165                	addi	sp,sp,112
    800036f0:	8082                	ret
    return 0;
    800036f2:	4501                	li	a0,0
}
    800036f4:	8082                	ret

00000000800036f6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800036f6:	457c                	lw	a5,76(a0)
    800036f8:	0ed7ee63          	bltu	a5,a3,800037f4 <writei+0xfe>
{
    800036fc:	7159                	addi	sp,sp,-112
    800036fe:	f486                	sd	ra,104(sp)
    80003700:	f0a2                	sd	s0,96(sp)
    80003702:	e8ca                	sd	s2,80(sp)
    80003704:	e0d2                	sd	s4,64(sp)
    80003706:	fc56                	sd	s5,56(sp)
    80003708:	f85a                	sd	s6,48(sp)
    8000370a:	f45e                	sd	s7,40(sp)
    8000370c:	1880                	addi	s0,sp,112
    8000370e:	8aaa                	mv	s5,a0
    80003710:	8bae                	mv	s7,a1
    80003712:	8a32                	mv	s4,a2
    80003714:	8936                	mv	s2,a3
    80003716:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003718:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000371c:	00043737          	lui	a4,0x43
    80003720:	0cf76c63          	bltu	a4,a5,800037f8 <writei+0x102>
    80003724:	0cd7ea63          	bltu	a5,a3,800037f8 <writei+0x102>
    80003728:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000372a:	0a0b0d63          	beqz	s6,800037e4 <writei+0xee>
    8000372e:	eca6                	sd	s1,88(sp)
    80003730:	f062                	sd	s8,32(sp)
    80003732:	ec66                	sd	s9,24(sp)
    80003734:	e86a                	sd	s10,16(sp)
    80003736:	e46e                	sd	s11,8(sp)
    80003738:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000373a:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000373e:	5c7d                	li	s8,-1
    80003740:	a825                	j	80003778 <writei+0x82>
    80003742:	020d1d93          	slli	s11,s10,0x20
    80003746:	020ddd93          	srli	s11,s11,0x20
    8000374a:	05848513          	addi	a0,s1,88
    8000374e:	86ee                	mv	a3,s11
    80003750:	8652                	mv	a2,s4
    80003752:	85de                	mv	a1,s7
    80003754:	953e                	add	a0,a0,a5
    80003756:	b9bfe0ef          	jal	800022f0 <either_copyin>
    8000375a:	05850663          	beq	a0,s8,800037a6 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    8000375e:	8526                	mv	a0,s1
    80003760:	6e2000ef          	jal	80003e42 <log_write>
    brelse(bp);
    80003764:	8526                	mv	a0,s1
    80003766:	d34ff0ef          	jal	80002c9a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    8000376a:	013d09bb          	addw	s3,s10,s3
    8000376e:	012d093b          	addw	s2,s10,s2
    80003772:	9a6e                	add	s4,s4,s11
    80003774:	0369ff63          	bgeu	s3,s6,800037b2 <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    80003778:	00a9559b          	srliw	a1,s2,0xa
    8000377c:	8556                	mv	a0,s5
    8000377e:	f7aff0ef          	jal	80002ef8 <bmap>
    80003782:	85aa                	mv	a1,a0
    if (addr == 0)
    80003784:	c51d                	beqz	a0,800037b2 <writei+0xbc>
    bp = bread(ip->dev, addr);
    80003786:	000aa503          	lw	a0,0(s5)
    8000378a:	c08ff0ef          	jal	80002b92 <bread>
    8000378e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003790:	3ff97793          	andi	a5,s2,1023
    80003794:	40fc873b          	subw	a4,s9,a5
    80003798:	413b06bb          	subw	a3,s6,s3
    8000379c:	8d3a                	mv	s10,a4
    8000379e:	fae6f2e3          	bgeu	a3,a4,80003742 <writei+0x4c>
    800037a2:	8d36                	mv	s10,a3
    800037a4:	bf79                	j	80003742 <writei+0x4c>
      log_write(bp);
    800037a6:	8526                	mv	a0,s1
    800037a8:	69a000ef          	jal	80003e42 <log_write>
      brelse(bp);
    800037ac:	8526                	mv	a0,s1
    800037ae:	cecff0ef          	jal	80002c9a <brelse>
  }

  if (off > ip->size)
    800037b2:	04caa783          	lw	a5,76(s5)
    800037b6:	0327f963          	bgeu	a5,s2,800037e8 <writei+0xf2>
    ip->size = off;
    800037ba:	052aa623          	sw	s2,76(s5)
    800037be:	64e6                	ld	s1,88(sp)
    800037c0:	7c02                	ld	s8,32(sp)
    800037c2:	6ce2                	ld	s9,24(sp)
    800037c4:	6d42                	ld	s10,16(sp)
    800037c6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037c8:	8556                	mv	a0,s5
    800037ca:	9adff0ef          	jal	80003176 <iupdate>

  return tot;
    800037ce:	854e                	mv	a0,s3
    800037d0:	69a6                	ld	s3,72(sp)
}
    800037d2:	70a6                	ld	ra,104(sp)
    800037d4:	7406                	ld	s0,96(sp)
    800037d6:	6946                	ld	s2,80(sp)
    800037d8:	6a06                	ld	s4,64(sp)
    800037da:	7ae2                	ld	s5,56(sp)
    800037dc:	7b42                	ld	s6,48(sp)
    800037de:	7ba2                	ld	s7,40(sp)
    800037e0:	6165                	addi	sp,sp,112
    800037e2:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037e4:	89da                	mv	s3,s6
    800037e6:	b7cd                	j	800037c8 <writei+0xd2>
    800037e8:	64e6                	ld	s1,88(sp)
    800037ea:	7c02                	ld	s8,32(sp)
    800037ec:	6ce2                	ld	s9,24(sp)
    800037ee:	6d42                	ld	s10,16(sp)
    800037f0:	6da2                	ld	s11,8(sp)
    800037f2:	bfd9                	j	800037c8 <writei+0xd2>
    return -1;
    800037f4:	557d                	li	a0,-1
}
    800037f6:	8082                	ret
    return -1;
    800037f8:	557d                	li	a0,-1
    800037fa:	bfe1                	j	800037d2 <writei+0xdc>

00000000800037fc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037fc:	1141                	addi	sp,sp,-16
    800037fe:	e406                	sd	ra,8(sp)
    80003800:	e022                	sd	s0,0(sp)
    80003802:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003804:	4639                	li	a2,14
    80003806:	d76fd0ef          	jal	80000d7c <strncmp>
}
    8000380a:	60a2                	ld	ra,8(sp)
    8000380c:	6402                	ld	s0,0(sp)
    8000380e:	0141                	addi	sp,sp,16
    80003810:	8082                	ret

0000000080003812 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003812:	711d                	addi	sp,sp,-96
    80003814:	ec86                	sd	ra,88(sp)
    80003816:	e8a2                	sd	s0,80(sp)
    80003818:	e4a6                	sd	s1,72(sp)
    8000381a:	e0ca                	sd	s2,64(sp)
    8000381c:	fc4e                	sd	s3,56(sp)
    8000381e:	f852                	sd	s4,48(sp)
    80003820:	f456                	sd	s5,40(sp)
    80003822:	f05a                	sd	s6,32(sp)
    80003824:	ec5e                	sd	s7,24(sp)
    80003826:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003828:	04451703          	lh	a4,68(a0)
    8000382c:	4785                	li	a5,1
    8000382e:	00f71f63          	bne	a4,a5,8000384c <dirlookup+0x3a>
    80003832:	892a                	mv	s2,a0
    80003834:	8aae                	mv	s5,a1
    80003836:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003838:	457c                	lw	a5,76(a0)
    8000383a:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000383c:	fa040a13          	addi	s4,s0,-96
    80003840:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    80003842:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003846:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003848:	e39d                	bnez	a5,8000386e <dirlookup+0x5c>
    8000384a:	a8b9                	j	800038a8 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000384c:	00004517          	auipc	a0,0x4
    80003850:	c7450513          	addi	a0,a0,-908 # 800074c0 <etext+0x4c0>
    80003854:	fe1fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    80003858:	00004517          	auipc	a0,0x4
    8000385c:	c8050513          	addi	a0,a0,-896 # 800074d8 <etext+0x4d8>
    80003860:	fd5fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003864:	24c1                	addiw	s1,s1,16
    80003866:	04c92783          	lw	a5,76(s2)
    8000386a:	02f4fe63          	bgeu	s1,a5,800038a6 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000386e:	874e                	mv	a4,s3
    80003870:	86a6                	mv	a3,s1
    80003872:	8652                	mv	a2,s4
    80003874:	4581                	li	a1,0
    80003876:	854a                	mv	a0,s2
    80003878:	d8dff0ef          	jal	80003604 <readi>
    8000387c:	fd351ee3          	bne	a0,s3,80003858 <dirlookup+0x46>
    if (de.inum == 0)
    80003880:	fa045783          	lhu	a5,-96(s0)
    80003884:	d3e5                	beqz	a5,80003864 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    80003886:	85da                	mv	a1,s6
    80003888:	8556                	mv	a0,s5
    8000388a:	f73ff0ef          	jal	800037fc <namecmp>
    8000388e:	f979                	bnez	a0,80003864 <dirlookup+0x52>
      if (poff)
    80003890:	000b8463          	beqz	s7,80003898 <dirlookup+0x86>
        *poff = off;
    80003894:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003898:	fa045583          	lhu	a1,-96(s0)
    8000389c:	00092503          	lw	a0,0(s2)
    800038a0:	f18ff0ef          	jal	80002fb8 <iget>
    800038a4:	a011                	j	800038a8 <dirlookup+0x96>
  return 0;
    800038a6:	4501                	li	a0,0
}
    800038a8:	60e6                	ld	ra,88(sp)
    800038aa:	6446                	ld	s0,80(sp)
    800038ac:	64a6                	ld	s1,72(sp)
    800038ae:	6906                	ld	s2,64(sp)
    800038b0:	79e2                	ld	s3,56(sp)
    800038b2:	7a42                	ld	s4,48(sp)
    800038b4:	7aa2                	ld	s5,40(sp)
    800038b6:	7b02                	ld	s6,32(sp)
    800038b8:	6be2                	ld	s7,24(sp)
    800038ba:	6125                	addi	sp,sp,96
    800038bc:	8082                	ret

00000000800038be <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    800038be:	711d                	addi	sp,sp,-96
    800038c0:	ec86                	sd	ra,88(sp)
    800038c2:	e8a2                	sd	s0,80(sp)
    800038c4:	e4a6                	sd	s1,72(sp)
    800038c6:	e0ca                	sd	s2,64(sp)
    800038c8:	fc4e                	sd	s3,56(sp)
    800038ca:	f852                	sd	s4,48(sp)
    800038cc:	f456                	sd	s5,40(sp)
    800038ce:	f05a                	sd	s6,32(sp)
    800038d0:	ec5e                	sd	s7,24(sp)
    800038d2:	e862                	sd	s8,16(sp)
    800038d4:	e466                	sd	s9,8(sp)
    800038d6:	e06a                	sd	s10,0(sp)
    800038d8:	1080                	addi	s0,sp,96
    800038da:	84aa                	mv	s1,a0
    800038dc:	8b2e                	mv	s6,a1
    800038de:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800038e0:	00054703          	lbu	a4,0(a0)
    800038e4:	02f00793          	li	a5,47
    800038e8:	00f70f63          	beq	a4,a5,80003906 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038ec:	81cfe0ef          	jal	80001908 <myproc>
    800038f0:	15053503          	ld	a0,336(a0)
    800038f4:	901ff0ef          	jal	800031f4 <idup>
    800038f8:	8a2a                	mv	s4,a0
  while (*path == '/')
    800038fa:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    800038fe:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003900:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003902:	4b85                	li	s7,1
    80003904:	a07d                	j	800039b2 <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003906:	4585                	li	a1,1
    80003908:	852e                	mv	a0,a1
    8000390a:	eaeff0ef          	jal	80002fb8 <iget>
    8000390e:	8a2a                	mv	s4,a0
    80003910:	b7ed                	j	800038fa <namex+0x3c>
      iunlockput(ip);
    80003912:	8552                	mv	a0,s4
    80003914:	b6bff0ef          	jal	8000347e <iunlockput>
      return 0;
    80003918:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000391a:	8552                	mv	a0,s4
    8000391c:	60e6                	ld	ra,88(sp)
    8000391e:	6446                	ld	s0,80(sp)
    80003920:	64a6                	ld	s1,72(sp)
    80003922:	6906                	ld	s2,64(sp)
    80003924:	79e2                	ld	s3,56(sp)
    80003926:	7a42                	ld	s4,48(sp)
    80003928:	7aa2                	ld	s5,40(sp)
    8000392a:	7b02                	ld	s6,32(sp)
    8000392c:	6be2                	ld	s7,24(sp)
    8000392e:	6c42                	ld	s8,16(sp)
    80003930:	6ca2                	ld	s9,8(sp)
    80003932:	6d02                	ld	s10,0(sp)
    80003934:	6125                	addi	sp,sp,96
    80003936:	8082                	ret
      iunlockput(ip);
    80003938:	8552                	mv	a0,s4
    8000393a:	b45ff0ef          	jal	8000347e <iunlockput>
      return 0;
    8000393e:	4a01                	li	s4,0
    80003940:	bfe9                	j	8000391a <namex+0x5c>
      iunlock(ip);
    80003942:	8552                	mv	a0,s4
    80003944:	995ff0ef          	jal	800032d8 <iunlock>
      return ip;
    80003948:	bfc9                	j	8000391a <namex+0x5c>
      iunlockput(ip);
    8000394a:	8552                	mv	a0,s4
    8000394c:	b33ff0ef          	jal	8000347e <iunlockput>
      return 0;
    80003950:	8a4a                	mv	s4,s2
    80003952:	b7e1                	j	8000391a <namex+0x5c>
  len = path - s;
    80003954:	40990633          	sub	a2,s2,s1
    80003958:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    8000395c:	09ac5763          	bge	s8,s10,800039ea <namex+0x12c>
    memmove(name, s, DIRSIZ);
    80003960:	8666                	mv	a2,s9
    80003962:	85a6                	mv	a1,s1
    80003964:	8556                	mv	a0,s5
    80003966:	ba2fd0ef          	jal	80000d08 <memmove>
    8000396a:	84ca                	mv	s1,s2
  while (*path == '/')
    8000396c:	0004c783          	lbu	a5,0(s1)
    80003970:	01379763          	bne	a5,s3,8000397e <namex+0xc0>
    path++;
    80003974:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003976:	0004c783          	lbu	a5,0(s1)
    8000397a:	ff378de3          	beq	a5,s3,80003974 <namex+0xb6>
    ilock(ip);
    8000397e:	8552                	mv	a0,s4
    80003980:	8abff0ef          	jal	8000322a <ilock>
    if (ip->type != T_DIR) {
    80003984:	044a1783          	lh	a5,68(s4)
    80003988:	f97795e3          	bne	a5,s7,80003912 <namex+0x54>
    if (ip->nlink == 0) {
    8000398c:	04aa1783          	lh	a5,74(s4)
    80003990:	d7c5                	beqz	a5,80003938 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003992:	000b0563          	beqz	s6,8000399c <namex+0xde>
    80003996:	0004c783          	lbu	a5,0(s1)
    8000399a:	d7c5                	beqz	a5,80003942 <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    8000399c:	4601                	li	a2,0
    8000399e:	85d6                	mv	a1,s5
    800039a0:	8552                	mv	a0,s4
    800039a2:	e71ff0ef          	jal	80003812 <dirlookup>
    800039a6:	892a                	mv	s2,a0
    800039a8:	d14d                	beqz	a0,8000394a <namex+0x8c>
    iunlockput(ip);
    800039aa:	8552                	mv	a0,s4
    800039ac:	ad3ff0ef          	jal	8000347e <iunlockput>
    ip = next;
    800039b0:	8a4a                	mv	s4,s2
  while (*path == '/')
    800039b2:	0004c783          	lbu	a5,0(s1)
    800039b6:	01379763          	bne	a5,s3,800039c4 <namex+0x106>
    path++;
    800039ba:	0485                	addi	s1,s1,1
  while (*path == '/')
    800039bc:	0004c783          	lbu	a5,0(s1)
    800039c0:	ff378de3          	beq	a5,s3,800039ba <namex+0xfc>
  if (*path == 0)
    800039c4:	cf8d                	beqz	a5,800039fe <namex+0x140>
  while (*path != '/' && *path != 0)
    800039c6:	0004c783          	lbu	a5,0(s1)
    800039ca:	fd178713          	addi	a4,a5,-47
    800039ce:	cb19                	beqz	a4,800039e4 <namex+0x126>
    800039d0:	cb91                	beqz	a5,800039e4 <namex+0x126>
    800039d2:	8926                	mv	s2,s1
    path++;
    800039d4:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    800039d6:	00094783          	lbu	a5,0(s2)
    800039da:	fd178713          	addi	a4,a5,-47
    800039de:	db3d                	beqz	a4,80003954 <namex+0x96>
    800039e0:	fbf5                	bnez	a5,800039d4 <namex+0x116>
    800039e2:	bf8d                	j	80003954 <namex+0x96>
    800039e4:	8926                	mv	s2,s1
  len = path - s;
    800039e6:	4d01                	li	s10,0
    800039e8:	4601                	li	a2,0
    memmove(name, s, len);
    800039ea:	2601                	sext.w	a2,a2
    800039ec:	85a6                	mv	a1,s1
    800039ee:	8556                	mv	a0,s5
    800039f0:	b18fd0ef          	jal	80000d08 <memmove>
    name[len] = 0;
    800039f4:	9d56                	add	s10,s10,s5
    800039f6:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdba00>
    800039fa:	84ca                	mv	s1,s2
    800039fc:	bf85                	j	8000396c <namex+0xae>
  if (nameiparent) {
    800039fe:	f00b0ee3          	beqz	s6,8000391a <namex+0x5c>
    iput(ip);
    80003a02:	8552                	mv	a0,s4
    80003a04:	9a9ff0ef          	jal	800033ac <iput>
    return 0;
    80003a08:	4a01                	li	s4,0
    80003a0a:	bf01                	j	8000391a <namex+0x5c>

0000000080003a0c <dirlink>:
{
    80003a0c:	715d                	addi	sp,sp,-80
    80003a0e:	e486                	sd	ra,72(sp)
    80003a10:	e0a2                	sd	s0,64(sp)
    80003a12:	f84a                	sd	s2,48(sp)
    80003a14:	ec56                	sd	s5,24(sp)
    80003a16:	e85a                	sd	s6,16(sp)
    80003a18:	0880                	addi	s0,sp,80
    80003a1a:	892a                	mv	s2,a0
    80003a1c:	8aae                	mv	s5,a1
    80003a1e:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003a20:	4601                	li	a2,0
    80003a22:	df1ff0ef          	jal	80003812 <dirlookup>
    80003a26:	ed1d                	bnez	a0,80003a64 <dirlink+0x58>
    80003a28:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a2a:	04c92483          	lw	s1,76(s2)
    80003a2e:	c4b9                	beqz	s1,80003a7c <dirlink+0x70>
    80003a30:	f44e                	sd	s3,40(sp)
    80003a32:	f052                	sd	s4,32(sp)
    80003a34:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a36:	fb040a13          	addi	s4,s0,-80
    80003a3a:	49c1                	li	s3,16
    80003a3c:	874e                	mv	a4,s3
    80003a3e:	86a6                	mv	a3,s1
    80003a40:	8652                	mv	a2,s4
    80003a42:	4581                	li	a1,0
    80003a44:	854a                	mv	a0,s2
    80003a46:	bbfff0ef          	jal	80003604 <readi>
    80003a4a:	03351163          	bne	a0,s3,80003a6c <dirlink+0x60>
    if (de.inum == 0)
    80003a4e:	fb045783          	lhu	a5,-80(s0)
    80003a52:	c39d                	beqz	a5,80003a78 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a54:	24c1                	addiw	s1,s1,16
    80003a56:	04c92783          	lw	a5,76(s2)
    80003a5a:	fef4e1e3          	bltu	s1,a5,80003a3c <dirlink+0x30>
    80003a5e:	79a2                	ld	s3,40(sp)
    80003a60:	7a02                	ld	s4,32(sp)
    80003a62:	a829                	j	80003a7c <dirlink+0x70>
    iput(ip);
    80003a64:	949ff0ef          	jal	800033ac <iput>
    return -1;
    80003a68:	557d                	li	a0,-1
    80003a6a:	a83d                	j	80003aa8 <dirlink+0x9c>
      panic("dirlink read");
    80003a6c:	00004517          	auipc	a0,0x4
    80003a70:	a7c50513          	addi	a0,a0,-1412 # 800074e8 <etext+0x4e8>
    80003a74:	dc1fc0ef          	jal	80000834 <panic>
    80003a78:	79a2                	ld	s3,40(sp)
    80003a7a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a7c:	4639                	li	a2,14
    80003a7e:	85d6                	mv	a1,s5
    80003a80:	fb240513          	addi	a0,s0,-78
    80003a84:	b32fd0ef          	jal	80000db6 <strncpy>
  de.inum = inum;
    80003a88:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a8c:	4741                	li	a4,16
    80003a8e:	86a6                	mv	a3,s1
    80003a90:	fb040613          	addi	a2,s0,-80
    80003a94:	4581                	li	a1,0
    80003a96:	854a                	mv	a0,s2
    80003a98:	c5fff0ef          	jal	800036f6 <writei>
    80003a9c:	1541                	addi	a0,a0,-16
    80003a9e:	00a03533          	snez	a0,a0
    80003aa2:	40a0053b          	negw	a0,a0
    80003aa6:	74e2                	ld	s1,56(sp)
}
    80003aa8:	60a6                	ld	ra,72(sp)
    80003aaa:	6406                	ld	s0,64(sp)
    80003aac:	7942                	ld	s2,48(sp)
    80003aae:	6ae2                	ld	s5,24(sp)
    80003ab0:	6b42                	ld	s6,16(sp)
    80003ab2:	6161                	addi	sp,sp,80
    80003ab4:	8082                	ret

0000000080003ab6 <namei>:

struct inode *
namei(char *path)
{
    80003ab6:	1101                	addi	sp,sp,-32
    80003ab8:	ec06                	sd	ra,24(sp)
    80003aba:	e822                	sd	s0,16(sp)
    80003abc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003abe:	fe040613          	addi	a2,s0,-32
    80003ac2:	4581                	li	a1,0
    80003ac4:	dfbff0ef          	jal	800038be <namex>
}
    80003ac8:	60e2                	ld	ra,24(sp)
    80003aca:	6442                	ld	s0,16(sp)
    80003acc:	6105                	addi	sp,sp,32
    80003ace:	8082                	ret

0000000080003ad0 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003ad0:	1141                	addi	sp,sp,-16
    80003ad2:	e406                	sd	ra,8(sp)
    80003ad4:	e022                	sd	s0,0(sp)
    80003ad6:	0800                	addi	s0,sp,16
    80003ad8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ada:	4585                	li	a1,1
    80003adc:	de3ff0ef          	jal	800038be <namex>
}
    80003ae0:	60a2                	ld	ra,8(sp)
    80003ae2:	6402                	ld	s0,0(sp)
    80003ae4:	0141                	addi	sp,sp,16
    80003ae6:	8082                	ret

0000000080003ae8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ae8:	1101                	addi	sp,sp,-32
    80003aea:	ec06                	sd	ra,24(sp)
    80003aec:	e822                	sd	s0,16(sp)
    80003aee:	e426                	sd	s1,8(sp)
    80003af0:	e04a                	sd	s2,0(sp)
    80003af2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003af4:	0001f917          	auipc	s2,0x1f
    80003af8:	8cc90913          	addi	s2,s2,-1844 # 800223c0 <log>
    80003afc:	01892583          	lw	a1,24(s2)
    80003b00:	02492503          	lw	a0,36(s2)
    80003b04:	88eff0ef          	jal	80002b92 <bread>
    80003b08:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b0a:	02c92603          	lw	a2,44(s2)
    80003b0e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b10:	00c05f63          	blez	a2,80003b2e <write_head+0x46>
    80003b14:	0001f717          	auipc	a4,0x1f
    80003b18:	8dc70713          	addi	a4,a4,-1828 # 800223f0 <log+0x30>
    80003b1c:	87aa                	mv	a5,a0
    80003b1e:	060a                	slli	a2,a2,0x2
    80003b20:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b22:	4314                	lw	a3,0(a4)
    80003b24:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b26:	0711                	addi	a4,a4,4
    80003b28:	0791                	addi	a5,a5,4
    80003b2a:	fec79ce3          	bne	a5,a2,80003b22 <write_head+0x3a>
  }
  bwrite(buf);
    80003b2e:	8526                	mv	a0,s1
    80003b30:	938ff0ef          	jal	80002c68 <bwrite>
  brelse(buf);
    80003b34:	8526                	mv	a0,s1
    80003b36:	964ff0ef          	jal	80002c9a <brelse>
}
    80003b3a:	60e2                	ld	ra,24(sp)
    80003b3c:	6442                	ld	s0,16(sp)
    80003b3e:	64a2                	ld	s1,8(sp)
    80003b40:	6902                	ld	s2,0(sp)
    80003b42:	6105                	addi	sp,sp,32
    80003b44:	8082                	ret

0000000080003b46 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b46:	0001f797          	auipc	a5,0x1f
    80003b4a:	8a67a783          	lw	a5,-1882(a5) # 800223ec <log+0x2c>
    80003b4e:	0cf05163          	blez	a5,80003c10 <install_trans+0xca>
{
    80003b52:	715d                	addi	sp,sp,-80
    80003b54:	e486                	sd	ra,72(sp)
    80003b56:	e0a2                	sd	s0,64(sp)
    80003b58:	fc26                	sd	s1,56(sp)
    80003b5a:	f84a                	sd	s2,48(sp)
    80003b5c:	f44e                	sd	s3,40(sp)
    80003b5e:	f052                	sd	s4,32(sp)
    80003b60:	ec56                	sd	s5,24(sp)
    80003b62:	e85a                	sd	s6,16(sp)
    80003b64:	e45e                	sd	s7,8(sp)
    80003b66:	e062                	sd	s8,0(sp)
    80003b68:	0880                	addi	s0,sp,80
    80003b6a:	8b2a                	mv	s6,a0
    80003b6c:	0001fa97          	auipc	s5,0x1f
    80003b70:	884a8a93          	addi	s5,s5,-1916 # 800223f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b74:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b76:	00004c17          	auipc	s8,0x4
    80003b7a:	982c0c13          	addi	s8,s8,-1662 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b7e:	0001fa17          	auipc	s4,0x1f
    80003b82:	842a0a13          	addi	s4,s4,-1982 # 800223c0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003b86:	40000b93          	li	s7,1024
    80003b8a:	a025                	j	80003bb2 <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b8c:	000aa603          	lw	a2,0(s5)
    80003b90:	85ce                	mv	a1,s3
    80003b92:	8562                	mv	a0,s8
    80003b94:	977fc0ef          	jal	8000050a <printk>
    80003b98:	a839                	j	80003bb6 <install_trans+0x70>
    brelse(lbuf);
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	8feff0ef          	jal	80002c9a <brelse>
    brelse(dbuf);
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	8f8ff0ef          	jal	80002c9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba6:	2985                	addiw	s3,s3,1
    80003ba8:	0a91                	addi	s5,s5,4
    80003baa:	02ca2783          	lw	a5,44(s4)
    80003bae:	04f9d563          	bge	s3,a5,80003bf8 <install_trans+0xb2>
    if (recovering) {
    80003bb2:	fc0b1de3          	bnez	s6,80003b8c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003bb6:	018a2583          	lw	a1,24(s4)
    80003bba:	013585bb          	addw	a1,a1,s3
    80003bbe:	2585                	addiw	a1,a1,1
    80003bc0:	024a2503          	lw	a0,36(s4)
    80003bc4:	fcffe0ef          	jal	80002b92 <bread>
    80003bc8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003bca:	000aa583          	lw	a1,0(s5)
    80003bce:	024a2503          	lw	a0,36(s4)
    80003bd2:	fc1fe0ef          	jal	80002b92 <bread>
    80003bd6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003bd8:	865e                	mv	a2,s7
    80003bda:	05890593          	addi	a1,s2,88
    80003bde:	05850513          	addi	a0,a0,88
    80003be2:	926fd0ef          	jal	80000d08 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003be6:	8526                	mv	a0,s1
    80003be8:	880ff0ef          	jal	80002c68 <bwrite>
    if (recovering == 0)
    80003bec:	fa0b17e3          	bnez	s6,80003b9a <install_trans+0x54>
      bunpin(dbuf);
    80003bf0:	8526                	mv	a0,s1
    80003bf2:	960ff0ef          	jal	80002d52 <bunpin>
    80003bf6:	b755                	j	80003b9a <install_trans+0x54>
}
    80003bf8:	60a6                	ld	ra,72(sp)
    80003bfa:	6406                	ld	s0,64(sp)
    80003bfc:	74e2                	ld	s1,56(sp)
    80003bfe:	7942                	ld	s2,48(sp)
    80003c00:	79a2                	ld	s3,40(sp)
    80003c02:	7a02                	ld	s4,32(sp)
    80003c04:	6ae2                	ld	s5,24(sp)
    80003c06:	6b42                	ld	s6,16(sp)
    80003c08:	6ba2                	ld	s7,8(sp)
    80003c0a:	6c02                	ld	s8,0(sp)
    80003c0c:	6161                	addi	sp,sp,80
    80003c0e:	8082                	ret
    80003c10:	8082                	ret

0000000080003c12 <initlog>:
{
    80003c12:	7179                	addi	sp,sp,-48
    80003c14:	f406                	sd	ra,40(sp)
    80003c16:	f022                	sd	s0,32(sp)
    80003c18:	ec26                	sd	s1,24(sp)
    80003c1a:	e84a                	sd	s2,16(sp)
    80003c1c:	e44e                	sd	s3,8(sp)
    80003c1e:	1800                	addi	s0,sp,48
    80003c20:	84aa                	mv	s1,a0
    80003c22:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c24:	0001e917          	auipc	s2,0x1e
    80003c28:	79c90913          	addi	s2,s2,1948 # 800223c0 <log>
    80003c2c:	00004597          	auipc	a1,0x4
    80003c30:	8ec58593          	addi	a1,a1,-1812 # 80007518 <etext+0x518>
    80003c34:	854a                	mv	a0,s2
    80003c36:	f33fc0ef          	jal	80000b68 <initlock>
  log.start = sb->logstart;
    80003c3a:	0149a583          	lw	a1,20(s3)
    80003c3e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c42:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c46:	8526                	mv	a0,s1
    80003c48:	f4bfe0ef          	jal	80002b92 <bread>
  log.lh.n = lh->n;
    80003c4c:	4d30                	lw	a2,88(a0)
    80003c4e:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003c52:	00c05f63          	blez	a2,80003c70 <initlog+0x5e>
    80003c56:	87aa                	mv	a5,a0
    80003c58:	0001e717          	auipc	a4,0x1e
    80003c5c:	79870713          	addi	a4,a4,1944 # 800223f0 <log+0x30>
    80003c60:	060a                	slli	a2,a2,0x2
    80003c62:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c64:	4ff4                	lw	a3,92(a5)
    80003c66:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c68:	0791                	addi	a5,a5,4
    80003c6a:	0711                	addi	a4,a4,4
    80003c6c:	fec79ce3          	bne	a5,a2,80003c64 <initlog+0x52>
  brelse(buf);
    80003c70:	82aff0ef          	jal	80002c9a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c74:	4505                	li	a0,1
    80003c76:	ed1ff0ef          	jal	80003b46 <install_trans>
  log.lh.n = 0;
    80003c7a:	0001e797          	auipc	a5,0x1e
    80003c7e:	7607a923          	sw	zero,1906(a5) # 800223ec <log+0x2c>
  write_head(); // clear the log
    80003c82:	e67ff0ef          	jal	80003ae8 <write_head>
}
    80003c86:	70a2                	ld	ra,40(sp)
    80003c88:	7402                	ld	s0,32(sp)
    80003c8a:	64e2                	ld	s1,24(sp)
    80003c8c:	6942                	ld	s2,16(sp)
    80003c8e:	69a2                	ld	s3,8(sp)
    80003c90:	6145                	addi	sp,sp,48
    80003c92:	8082                	ret

0000000080003c94 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c94:	1101                	addi	sp,sp,-32
    80003c96:	ec06                	sd	ra,24(sp)
    80003c98:	e822                	sd	s0,16(sp)
    80003c9a:	e426                	sd	s1,8(sp)
    80003c9c:	e04a                	sd	s2,0(sp)
    80003c9e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ca0:	0001e517          	auipc	a0,0x1e
    80003ca4:	72050513          	addi	a0,a0,1824 # 800223c0 <log>
    80003ca8:	f41fc0ef          	jal	80000be8 <acquire>
  while (1) {
    if (log.committing) {
    80003cac:	0001e497          	auipc	s1,0x1e
    80003cb0:	71448493          	addi	s1,s1,1812 # 800223c0 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003cb4:	4979                	li	s2,30
    80003cb6:	a821                	j	80003cce <begin_op+0x3a>
      sleep_prepare(&log);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	a58fe0ef          	jal	80001f12 <sleep_prepare>
      release(&log.lock);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	fb1fc0ef          	jal	80000c70 <release>
      sleep();
    80003cc4:	a8afe0ef          	jal	80001f4e <sleep>
      acquire(&log.lock);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	f1ffc0ef          	jal	80000be8 <acquire>
    if (log.committing) {
    80003cce:	509c                	lw	a5,32(s1)
    80003cd0:	f7e5                	bnez	a5,80003cb8 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003cd2:	4cd8                	lw	a4,28(s1)
    80003cd4:	2705                	addiw	a4,a4,1
    80003cd6:	0027179b          	slliw	a5,a4,0x2
    80003cda:	9fb9                	addw	a5,a5,a4
    80003cdc:	0017979b          	slliw	a5,a5,0x1
    80003ce0:	54d4                	lw	a3,44(s1)
    80003ce2:	9fb5                	addw	a5,a5,a3
    80003ce4:	00f95e63          	bge	s2,a5,80003d00 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003ce8:	8526                	mv	a0,s1
    80003cea:	a28fe0ef          	jal	80001f12 <sleep_prepare>
      release(&log.lock);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	f81fc0ef          	jal	80000c70 <release>
      sleep();
    80003cf4:	a5afe0ef          	jal	80001f4e <sleep>
      acquire(&log.lock);
    80003cf8:	8526                	mv	a0,s1
    80003cfa:	eeffc0ef          	jal	80000be8 <acquire>
    80003cfe:	bfc1                	j	80003cce <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d00:	0001e797          	auipc	a5,0x1e
    80003d04:	6ce7ae23          	sw	a4,1756(a5) # 800223dc <log+0x1c>
      release(&log.lock);
    80003d08:	0001e517          	auipc	a0,0x1e
    80003d0c:	6b850513          	addi	a0,a0,1720 # 800223c0 <log>
    80003d10:	f61fc0ef          	jal	80000c70 <release>
      break;
    }
  }
}
    80003d14:	60e2                	ld	ra,24(sp)
    80003d16:	6442                	ld	s0,16(sp)
    80003d18:	64a2                	ld	s1,8(sp)
    80003d1a:	6902                	ld	s2,0(sp)
    80003d1c:	6105                	addi	sp,sp,32
    80003d1e:	8082                	ret

0000000080003d20 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d20:	7139                	addi	sp,sp,-64
    80003d22:	fc06                	sd	ra,56(sp)
    80003d24:	f822                	sd	s0,48(sp)
    80003d26:	f426                	sd	s1,40(sp)
    80003d28:	f04a                	sd	s2,32(sp)
    80003d2a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d2c:	0001e497          	auipc	s1,0x1e
    80003d30:	69448493          	addi	s1,s1,1684 # 800223c0 <log>
    80003d34:	8526                	mv	a0,s1
    80003d36:	eb3fc0ef          	jal	80000be8 <acquire>
  log.outstanding -= 1;
    80003d3a:	4cdc                	lw	a5,28(s1)
    80003d3c:	37fd                	addiw	a5,a5,-1
    80003d3e:	893e                	mv	s2,a5
    80003d40:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003d42:	509c                	lw	a5,32(s1)
    80003d44:	e3b1                	bnez	a5,80003d88 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003d46:	04091a63          	bnez	s2,80003d9a <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003d4a:	0001e497          	auipc	s1,0x1e
    80003d4e:	67648493          	addi	s1,s1,1654 # 800223c0 <log>
    80003d52:	4785                	li	a5,1
    80003d54:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d56:	8526                	mv	a0,s1
    80003d58:	f19fc0ef          	jal	80000c70 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d5c:	54dc                	lw	a5,44(s1)
    80003d5e:	06f04063          	bgtz	a5,80003dbe <end_op+0x9e>
    acquire(&log.lock);
    80003d62:	0001e497          	auipc	s1,0x1e
    80003d66:	65e48493          	addi	s1,s1,1630 # 800223c0 <log>
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	e7dfc0ef          	jal	80000be8 <acquire>
    log.committing = 0;
    80003d70:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003d74:	549c                	lw	a5,40(s1)
    80003d76:	2785                	addiw	a5,a5,1
    80003d78:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003d7a:	8526                	mv	a0,s1
    80003d7c:	a02fe0ef          	jal	80001f7e <wakeup>
    release(&log.lock);
    80003d80:	8526                	mv	a0,s1
    80003d82:	eeffc0ef          	jal	80000c70 <release>
}
    80003d86:	a035                	j	80003db2 <end_op+0x92>
    80003d88:	ec4e                	sd	s3,24(sp)
    80003d8a:	e852                	sd	s4,16(sp)
    80003d8c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d8e:	00003517          	auipc	a0,0x3
    80003d92:	79250513          	addi	a0,a0,1938 # 80007520 <etext+0x520>
    80003d96:	a9ffc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003d9a:	0001e517          	auipc	a0,0x1e
    80003d9e:	62650513          	addi	a0,a0,1574 # 800223c0 <log>
    80003da2:	9dcfe0ef          	jal	80001f7e <wakeup>
  release(&log.lock);
    80003da6:	0001e517          	auipc	a0,0x1e
    80003daa:	61a50513          	addi	a0,a0,1562 # 800223c0 <log>
    80003dae:	ec3fc0ef          	jal	80000c70 <release>
}
    80003db2:	70e2                	ld	ra,56(sp)
    80003db4:	7442                	ld	s0,48(sp)
    80003db6:	74a2                	ld	s1,40(sp)
    80003db8:	7902                	ld	s2,32(sp)
    80003dba:	6121                	addi	sp,sp,64
    80003dbc:	8082                	ret
    80003dbe:	ec4e                	sd	s3,24(sp)
    80003dc0:	e852                	sd	s4,16(sp)
    80003dc2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dc4:	0001ea97          	auipc	s5,0x1e
    80003dc8:	62ca8a93          	addi	s5,s5,1580 # 800223f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003dcc:	0001ea17          	auipc	s4,0x1e
    80003dd0:	5f4a0a13          	addi	s4,s4,1524 # 800223c0 <log>
    80003dd4:	018a2583          	lw	a1,24(s4)
    80003dd8:	012585bb          	addw	a1,a1,s2
    80003ddc:	2585                	addiw	a1,a1,1
    80003dde:	024a2503          	lw	a0,36(s4)
    80003de2:	db1fe0ef          	jal	80002b92 <bread>
    80003de6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003de8:	000aa583          	lw	a1,0(s5)
    80003dec:	024a2503          	lw	a0,36(s4)
    80003df0:	da3fe0ef          	jal	80002b92 <bread>
    80003df4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003df6:	40000613          	li	a2,1024
    80003dfa:	05850593          	addi	a1,a0,88
    80003dfe:	05848513          	addi	a0,s1,88
    80003e02:	f07fc0ef          	jal	80000d08 <memmove>
    bwrite(to); // write the log
    80003e06:	8526                	mv	a0,s1
    80003e08:	e61fe0ef          	jal	80002c68 <bwrite>
    brelse(from);
    80003e0c:	854e                	mv	a0,s3
    80003e0e:	e8dfe0ef          	jal	80002c9a <brelse>
    brelse(to);
    80003e12:	8526                	mv	a0,s1
    80003e14:	e87fe0ef          	jal	80002c9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e18:	2905                	addiw	s2,s2,1
    80003e1a:	0a91                	addi	s5,s5,4
    80003e1c:	02ca2783          	lw	a5,44(s4)
    80003e20:	faf94ae3          	blt	s2,a5,80003dd4 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e24:	cc5ff0ef          	jal	80003ae8 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e28:	4501                	li	a0,0
    80003e2a:	d1dff0ef          	jal	80003b46 <install_trans>
    log.lh.n = 0;
    80003e2e:	0001e797          	auipc	a5,0x1e
    80003e32:	5a07af23          	sw	zero,1470(a5) # 800223ec <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003e36:	cb3ff0ef          	jal	80003ae8 <write_head>
    80003e3a:	69e2                	ld	s3,24(sp)
    80003e3c:	6a42                	ld	s4,16(sp)
    80003e3e:	6aa2                	ld	s5,8(sp)
    80003e40:	b70d                	j	80003d62 <end_op+0x42>

0000000080003e42 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e42:	1101                	addi	sp,sp,-32
    80003e44:	ec06                	sd	ra,24(sp)
    80003e46:	e822                	sd	s0,16(sp)
    80003e48:	e426                	sd	s1,8(sp)
    80003e4a:	1000                	addi	s0,sp,32
    80003e4c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e4e:	0001e517          	auipc	a0,0x1e
    80003e52:	57250513          	addi	a0,a0,1394 # 800223c0 <log>
    80003e56:	d93fc0ef          	jal	80000be8 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e5a:	0001e617          	auipc	a2,0x1e
    80003e5e:	59262603          	lw	a2,1426(a2) # 800223ec <log+0x2c>
    80003e62:	47f5                	li	a5,29
    80003e64:	04c7cd63          	blt	a5,a2,80003ebe <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e68:	0001e797          	auipc	a5,0x1e
    80003e6c:	5747a783          	lw	a5,1396(a5) # 800223dc <log+0x1c>
    80003e70:	04f05d63          	blez	a5,80003eca <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e74:	4781                	li	a5,0
    80003e76:	06c05063          	blez	a2,80003ed6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e7a:	44cc                	lw	a1,12(s1)
    80003e7c:	0001e717          	auipc	a4,0x1e
    80003e80:	57470713          	addi	a4,a4,1396 # 800223f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003e84:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e86:	4314                	lw	a3,0(a4)
    80003e88:	04b68763          	beq	a3,a1,80003ed6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003e8c:	2785                	addiw	a5,a5,1
    80003e8e:	0711                	addi	a4,a4,4
    80003e90:	fef61be3          	bne	a2,a5,80003e86 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e94:	060a                	slli	a2,a2,0x2
    80003e96:	02060613          	addi	a2,a2,32
    80003e9a:	0001e797          	auipc	a5,0x1e
    80003e9e:	52678793          	addi	a5,a5,1318 # 800223c0 <log>
    80003ea2:	97b2                	add	a5,a5,a2
    80003ea4:	44d8                	lw	a4,12(s1)
    80003ea6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	e75fe0ef          	jal	80002d1e <bpin>
    log.lh.n++;
    80003eae:	0001e717          	auipc	a4,0x1e
    80003eb2:	51270713          	addi	a4,a4,1298 # 800223c0 <log>
    80003eb6:	575c                	lw	a5,44(a4)
    80003eb8:	2785                	addiw	a5,a5,1
    80003eba:	d75c                	sw	a5,44(a4)
    80003ebc:	a815                	j	80003ef0 <log_write+0xae>
    panic("too big a transaction");
    80003ebe:	00003517          	auipc	a0,0x3
    80003ec2:	67250513          	addi	a0,a0,1650 # 80007530 <etext+0x530>
    80003ec6:	96ffc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80003eca:	00003517          	auipc	a0,0x3
    80003ece:	67e50513          	addi	a0,a0,1662 # 80007548 <etext+0x548>
    80003ed2:	963fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80003ed6:	00279693          	slli	a3,a5,0x2
    80003eda:	02068693          	addi	a3,a3,32
    80003ede:	0001e717          	auipc	a4,0x1e
    80003ee2:	4e270713          	addi	a4,a4,1250 # 800223c0 <log>
    80003ee6:	9736                	add	a4,a4,a3
    80003ee8:	44d4                	lw	a3,12(s1)
    80003eea:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003eec:	faf60ee3          	beq	a2,a5,80003ea8 <log_write+0x66>
  }
  release(&log.lock);
    80003ef0:	0001e517          	auipc	a0,0x1e
    80003ef4:	4d050513          	addi	a0,a0,1232 # 800223c0 <log>
    80003ef8:	d79fc0ef          	jal	80000c70 <release>
}
    80003efc:	60e2                	ld	ra,24(sp)
    80003efe:	6442                	ld	s0,16(sp)
    80003f00:	64a2                	ld	s1,8(sp)
    80003f02:	6105                	addi	sp,sp,32
    80003f04:	8082                	ret

0000000080003f06 <sys_sync>:

uint64
sys_sync(void)
{
    80003f06:	1101                	addi	sp,sp,-32
    80003f08:	ec06                	sd	ra,24(sp)
    80003f0a:	e822                	sd	s0,16(sp)
    80003f0c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f0e:	0001e517          	auipc	a0,0x1e
    80003f12:	4b250513          	addi	a0,a0,1202 # 800223c0 <log>
    80003f16:	cd3fc0ef          	jal	80000be8 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f1a:	0001e797          	auipc	a5,0x1e
    80003f1e:	4c67a783          	lw	a5,1222(a5) # 800223e0 <log+0x20>
    80003f22:	e799                	bnez	a5,80003f30 <sys_sync+0x2a>
    80003f24:	0001e797          	auipc	a5,0x1e
    80003f28:	4b87a783          	lw	a5,1208(a5) # 800223dc <log+0x1c>
    80003f2c:	02f05c63          	blez	a5,80003f64 <sys_sync+0x5e>
    80003f30:	e426                	sd	s1,8(sp)
    80003f32:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003f34:	0001e917          	auipc	s2,0x1e
    80003f38:	4b492903          	lw	s2,1204(s2) # 800223e8 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003f3c:	0001e497          	auipc	s1,0x1e
    80003f40:	48448493          	addi	s1,s1,1156 # 800223c0 <log>
    80003f44:	8526                	mv	a0,s1
    80003f46:	fcdfd0ef          	jal	80001f12 <sleep_prepare>
      release(&log.lock);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	d25fc0ef          	jal	80000c70 <release>
      sleep();
    80003f50:	ffffd0ef          	jal	80001f4e <sleep>
      acquire(&log.lock);
    80003f54:	8526                	mv	a0,s1
    80003f56:	c93fc0ef          	jal	80000be8 <acquire>
    while (log.ncommit < n) {
    80003f5a:	549c                	lw	a5,40(s1)
    80003f5c:	fef954e3          	bge	s2,a5,80003f44 <sys_sync+0x3e>
    80003f60:	64a2                	ld	s1,8(sp)
    80003f62:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003f64:	0001e517          	auipc	a0,0x1e
    80003f68:	45c50513          	addi	a0,a0,1116 # 800223c0 <log>
    80003f6c:	d05fc0ef          	jal	80000c70 <release>
  return 0;
}
    80003f70:	4501                	li	a0,0
    80003f72:	60e2                	ld	ra,24(sp)
    80003f74:	6442                	ld	s0,16(sp)
    80003f76:	6105                	addi	sp,sp,32
    80003f78:	8082                	ret

0000000080003f7a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f7a:	1101                	addi	sp,sp,-32
    80003f7c:	ec06                	sd	ra,24(sp)
    80003f7e:	e822                	sd	s0,16(sp)
    80003f80:	e426                	sd	s1,8(sp)
    80003f82:	e04a                	sd	s2,0(sp)
    80003f84:	1000                	addi	s0,sp,32
    80003f86:	84aa                	mv	s1,a0
    80003f88:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f8a:	00003597          	auipc	a1,0x3
    80003f8e:	5de58593          	addi	a1,a1,1502 # 80007568 <etext+0x568>
    80003f92:	0521                	addi	a0,a0,8
    80003f94:	bd5fc0ef          	jal	80000b68 <initlock>
  lk->name = name;
    80003f98:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f9c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fa0:	0204a423          	sw	zero,40(s1)
}
    80003fa4:	60e2                	ld	ra,24(sp)
    80003fa6:	6442                	ld	s0,16(sp)
    80003fa8:	64a2                	ld	s1,8(sp)
    80003faa:	6902                	ld	s2,0(sp)
    80003fac:	6105                	addi	sp,sp,32
    80003fae:	8082                	ret

0000000080003fb0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fb0:	1101                	addi	sp,sp,-32
    80003fb2:	ec06                	sd	ra,24(sp)
    80003fb4:	e822                	sd	s0,16(sp)
    80003fb6:	e426                	sd	s1,8(sp)
    80003fb8:	e04a                	sd	s2,0(sp)
    80003fba:	1000                	addi	s0,sp,32
    80003fbc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fbe:	00850913          	addi	s2,a0,8
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	c25fc0ef          	jal	80000be8 <acquire>
  while (lk->locked) {
    80003fc8:	409c                	lw	a5,0(s1)
    80003fca:	cf91                	beqz	a5,80003fe6 <acquiresleep+0x36>
    sleep_prepare(lk);
    80003fcc:	8526                	mv	a0,s1
    80003fce:	f45fd0ef          	jal	80001f12 <sleep_prepare>
    release(&lk->lk);
    80003fd2:	854a                	mv	a0,s2
    80003fd4:	c9dfc0ef          	jal	80000c70 <release>
    sleep();
    80003fd8:	f77fd0ef          	jal	80001f4e <sleep>
    acquire(&lk->lk);
    80003fdc:	854a                	mv	a0,s2
    80003fde:	c0bfc0ef          	jal	80000be8 <acquire>
  while (lk->locked) {
    80003fe2:	409c                	lw	a5,0(s1)
    80003fe4:	f7e5                	bnez	a5,80003fcc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fe6:	4785                	li	a5,1
    80003fe8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fea:	91ffd0ef          	jal	80001908 <myproc>
    80003fee:	591c                	lw	a5,48(a0)
    80003ff0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	c7dfc0ef          	jal	80000c70 <release>
}
    80003ff8:	60e2                	ld	ra,24(sp)
    80003ffa:	6442                	ld	s0,16(sp)
    80003ffc:	64a2                	ld	s1,8(sp)
    80003ffe:	6902                	ld	s2,0(sp)
    80004000:	6105                	addi	sp,sp,32
    80004002:	8082                	ret

0000000080004004 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004004:	1101                	addi	sp,sp,-32
    80004006:	ec06                	sd	ra,24(sp)
    80004008:	e822                	sd	s0,16(sp)
    8000400a:	e426                	sd	s1,8(sp)
    8000400c:	e04a                	sd	s2,0(sp)
    8000400e:	1000                	addi	s0,sp,32
    80004010:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004012:	00850913          	addi	s2,a0,8
    80004016:	854a                	mv	a0,s2
    80004018:	bd1fc0ef          	jal	80000be8 <acquire>
  lk->locked = 0;
    8000401c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004020:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004024:	8526                	mv	a0,s1
    80004026:	f59fd0ef          	jal	80001f7e <wakeup>
  release(&lk->lk);
    8000402a:	854a                	mv	a0,s2
    8000402c:	c45fc0ef          	jal	80000c70 <release>
}
    80004030:	60e2                	ld	ra,24(sp)
    80004032:	6442                	ld	s0,16(sp)
    80004034:	64a2                	ld	s1,8(sp)
    80004036:	6902                	ld	s2,0(sp)
    80004038:	6105                	addi	sp,sp,32
    8000403a:	8082                	ret

000000008000403c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000403c:	7179                	addi	sp,sp,-48
    8000403e:	f406                	sd	ra,40(sp)
    80004040:	f022                	sd	s0,32(sp)
    80004042:	ec26                	sd	s1,24(sp)
    80004044:	e84a                	sd	s2,16(sp)
    80004046:	1800                	addi	s0,sp,48
    80004048:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000404a:	00850913          	addi	s2,a0,8
    8000404e:	854a                	mv	a0,s2
    80004050:	b99fc0ef          	jal	80000be8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004054:	409c                	lw	a5,0(s1)
    80004056:	ef81                	bnez	a5,8000406e <holdingsleep+0x32>
    80004058:	4481                	li	s1,0
  release(&lk->lk);
    8000405a:	854a                	mv	a0,s2
    8000405c:	c15fc0ef          	jal	80000c70 <release>
  return r;
}
    80004060:	8526                	mv	a0,s1
    80004062:	70a2                	ld	ra,40(sp)
    80004064:	7402                	ld	s0,32(sp)
    80004066:	64e2                	ld	s1,24(sp)
    80004068:	6942                	ld	s2,16(sp)
    8000406a:	6145                	addi	sp,sp,48
    8000406c:	8082                	ret
    8000406e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004070:	0284a983          	lw	s3,40(s1)
    80004074:	895fd0ef          	jal	80001908 <myproc>
    80004078:	5904                	lw	s1,48(a0)
    8000407a:	413484b3          	sub	s1,s1,s3
    8000407e:	0014b493          	seqz	s1,s1
    80004082:	69a2                	ld	s3,8(sp)
    80004084:	bfd9                	j	8000405a <holdingsleep+0x1e>

0000000080004086 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004086:	1141                	addi	sp,sp,-16
    80004088:	e406                	sd	ra,8(sp)
    8000408a:	e022                	sd	s0,0(sp)
    8000408c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000408e:	00003597          	auipc	a1,0x3
    80004092:	4ea58593          	addi	a1,a1,1258 # 80007578 <etext+0x578>
    80004096:	0001e517          	auipc	a0,0x1e
    8000409a:	47250513          	addi	a0,a0,1138 # 80022508 <ftable>
    8000409e:	acbfc0ef          	jal	80000b68 <initlock>
}
    800040a2:	60a2                	ld	ra,8(sp)
    800040a4:	6402                	ld	s0,0(sp)
    800040a6:	0141                	addi	sp,sp,16
    800040a8:	8082                	ret

00000000800040aa <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800040aa:	1101                	addi	sp,sp,-32
    800040ac:	ec06                	sd	ra,24(sp)
    800040ae:	e822                	sd	s0,16(sp)
    800040b0:	e426                	sd	s1,8(sp)
    800040b2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040b4:	0001e517          	auipc	a0,0x1e
    800040b8:	45450513          	addi	a0,a0,1108 # 80022508 <ftable>
    800040bc:	b2dfc0ef          	jal	80000be8 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800040c0:	0001e497          	auipc	s1,0x1e
    800040c4:	46048493          	addi	s1,s1,1120 # 80022520 <ftable+0x18>
    800040c8:	0001f717          	auipc	a4,0x1f
    800040cc:	3f870713          	addi	a4,a4,1016 # 800234c0 <disk>
    if (f->ref == 0) {
    800040d0:	40dc                	lw	a5,4(s1)
    800040d2:	cf89                	beqz	a5,800040ec <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    800040d4:	02848493          	addi	s1,s1,40
    800040d8:	fee49ce3          	bne	s1,a4,800040d0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040dc:	0001e517          	auipc	a0,0x1e
    800040e0:	42c50513          	addi	a0,a0,1068 # 80022508 <ftable>
    800040e4:	b8dfc0ef          	jal	80000c70 <release>
  return 0;
    800040e8:	4481                	li	s1,0
    800040ea:	a809                	j	800040fc <filealloc+0x52>
      f->ref = 1;
    800040ec:	4785                	li	a5,1
    800040ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040f0:	0001e517          	auipc	a0,0x1e
    800040f4:	41850513          	addi	a0,a0,1048 # 80022508 <ftable>
    800040f8:	b79fc0ef          	jal	80000c70 <release>
}
    800040fc:	8526                	mv	a0,s1
    800040fe:	60e2                	ld	ra,24(sp)
    80004100:	6442                	ld	s0,16(sp)
    80004102:	64a2                	ld	s1,8(sp)
    80004104:	6105                	addi	sp,sp,32
    80004106:	8082                	ret

0000000080004108 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	1000                	addi	s0,sp,32
    80004112:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004114:	0001e517          	auipc	a0,0x1e
    80004118:	3f450513          	addi	a0,a0,1012 # 80022508 <ftable>
    8000411c:	acdfc0ef          	jal	80000be8 <acquire>
  if (f->ref < 1)
    80004120:	40dc                	lw	a5,4(s1)
    80004122:	02f05063          	blez	a5,80004142 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004126:	2785                	addiw	a5,a5,1
    80004128:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000412a:	0001e517          	auipc	a0,0x1e
    8000412e:	3de50513          	addi	a0,a0,990 # 80022508 <ftable>
    80004132:	b3ffc0ef          	jal	80000c70 <release>
  return f;
}
    80004136:	8526                	mv	a0,s1
    80004138:	60e2                	ld	ra,24(sp)
    8000413a:	6442                	ld	s0,16(sp)
    8000413c:	64a2                	ld	s1,8(sp)
    8000413e:	6105                	addi	sp,sp,32
    80004140:	8082                	ret
    panic("filedup");
    80004142:	00003517          	auipc	a0,0x3
    80004146:	43e50513          	addi	a0,a0,1086 # 80007580 <etext+0x580>
    8000414a:	eeafc0ef          	jal	80000834 <panic>

000000008000414e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000414e:	7139                	addi	sp,sp,-64
    80004150:	fc06                	sd	ra,56(sp)
    80004152:	f822                	sd	s0,48(sp)
    80004154:	f426                	sd	s1,40(sp)
    80004156:	0080                	addi	s0,sp,64
    80004158:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000415a:	0001e517          	auipc	a0,0x1e
    8000415e:	3ae50513          	addi	a0,a0,942 # 80022508 <ftable>
    80004162:	a87fc0ef          	jal	80000be8 <acquire>
  if (f->ref < 1)
    80004166:	40dc                	lw	a5,4(s1)
    80004168:	04f05a63          	blez	a5,800041bc <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000416c:	37fd                	addiw	a5,a5,-1
    8000416e:	c0dc                	sw	a5,4(s1)
    80004170:	06f04063          	bgtz	a5,800041d0 <fileclose+0x82>
    80004174:	f04a                	sd	s2,32(sp)
    80004176:	ec4e                	sd	s3,24(sp)
    80004178:	e852                	sd	s4,16(sp)
    8000417a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000417c:	0004a903          	lw	s2,0(s1)
    80004180:	0094c783          	lbu	a5,9(s1)
    80004184:	89be                	mv	s3,a5
    80004186:	689c                	ld	a5,16(s1)
    80004188:	8a3e                	mv	s4,a5
    8000418a:	6c9c                	ld	a5,24(s1)
    8000418c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000418e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004192:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004196:	0001e517          	auipc	a0,0x1e
    8000419a:	37250513          	addi	a0,a0,882 # 80022508 <ftable>
    8000419e:	ad3fc0ef          	jal	80000c70 <release>

  if (ff.type == FD_PIPE) {
    800041a2:	4785                	li	a5,1
    800041a4:	04f90163          	beq	s2,a5,800041e6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800041a8:	ffe9079b          	addiw	a5,s2,-2
    800041ac:	4705                	li	a4,1
    800041ae:	04f77563          	bgeu	a4,a5,800041f8 <fileclose+0xaa>
    800041b2:	7902                	ld	s2,32(sp)
    800041b4:	69e2                	ld	s3,24(sp)
    800041b6:	6a42                	ld	s4,16(sp)
    800041b8:	6aa2                	ld	s5,8(sp)
    800041ba:	a00d                	j	800041dc <fileclose+0x8e>
    800041bc:	f04a                	sd	s2,32(sp)
    800041be:	ec4e                	sd	s3,24(sp)
    800041c0:	e852                	sd	s4,16(sp)
    800041c2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800041c4:	00003517          	auipc	a0,0x3
    800041c8:	3c450513          	addi	a0,a0,964 # 80007588 <etext+0x588>
    800041cc:	e68fc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    800041d0:	0001e517          	auipc	a0,0x1e
    800041d4:	33850513          	addi	a0,a0,824 # 80022508 <ftable>
    800041d8:	a99fc0ef          	jal	80000c70 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800041dc:	70e2                	ld	ra,56(sp)
    800041de:	7442                	ld	s0,48(sp)
    800041e0:	74a2                	ld	s1,40(sp)
    800041e2:	6121                	addi	sp,sp,64
    800041e4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041e6:	85ce                	mv	a1,s3
    800041e8:	8552                	mv	a0,s4
    800041ea:	360000ef          	jal	8000454a <pipeclose>
    800041ee:	7902                	ld	s2,32(sp)
    800041f0:	69e2                	ld	s3,24(sp)
    800041f2:	6a42                	ld	s4,16(sp)
    800041f4:	6aa2                	ld	s5,8(sp)
    800041f6:	b7dd                	j	800041dc <fileclose+0x8e>
    begin_op();
    800041f8:	a9dff0ef          	jal	80003c94 <begin_op>
    iput(ff.ip);
    800041fc:	8556                	mv	a0,s5
    800041fe:	9aeff0ef          	jal	800033ac <iput>
    end_op();
    80004202:	b1fff0ef          	jal	80003d20 <end_op>
    80004206:	7902                	ld	s2,32(sp)
    80004208:	69e2                	ld	s3,24(sp)
    8000420a:	6a42                	ld	s4,16(sp)
    8000420c:	6aa2                	ld	s5,8(sp)
    8000420e:	b7f9                	j	800041dc <fileclose+0x8e>

0000000080004210 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004210:	715d                	addi	sp,sp,-80
    80004212:	e486                	sd	ra,72(sp)
    80004214:	e0a2                	sd	s0,64(sp)
    80004216:	fc26                	sd	s1,56(sp)
    80004218:	f052                	sd	s4,32(sp)
    8000421a:	0880                	addi	s0,sp,80
    8000421c:	84aa                	mv	s1,a0
    8000421e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004220:	ee8fd0ef          	jal	80001908 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004224:	409c                	lw	a5,0(s1)
    80004226:	37f9                	addiw	a5,a5,-2
    80004228:	4705                	li	a4,1
    8000422a:	04f76463          	bltu	a4,a5,80004272 <filestat+0x62>
    8000422e:	f84a                	sd	s2,48(sp)
    80004230:	f44e                	sd	s3,40(sp)
    80004232:	892a                	mv	s2,a0
    ilock(f->ip);
    80004234:	6c88                	ld	a0,24(s1)
    80004236:	ff5fe0ef          	jal	8000322a <ilock>
    stati(f->ip, &st);
    8000423a:	fb840993          	addi	s3,s0,-72
    8000423e:	85ce                	mv	a1,s3
    80004240:	6c88                	ld	a0,24(s1)
    80004242:	b94ff0ef          	jal	800035d6 <stati>
    iunlock(f->ip);
    80004246:	6c88                	ld	a0,24(s1)
    80004248:	890ff0ef          	jal	800032d8 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    8000424c:	4761                	li	a4,24
    8000424e:	86ce                	mv	a3,s3
    80004250:	8652                	mv	a2,s4
    80004252:	04893583          	ld	a1,72(s2)
    80004256:	05093503          	ld	a0,80(s2)
    8000425a:	ae8fd0ef          	jal	80001542 <copyout>
    8000425e:	41f5551b          	sraiw	a0,a0,0x1f
    80004262:	7942                	ld	s2,48(sp)
    80004264:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004266:	60a6                	ld	ra,72(sp)
    80004268:	6406                	ld	s0,64(sp)
    8000426a:	74e2                	ld	s1,56(sp)
    8000426c:	7a02                	ld	s4,32(sp)
    8000426e:	6161                	addi	sp,sp,80
    80004270:	8082                	ret
  return -1;
    80004272:	557d                	li	a0,-1
    80004274:	bfcd                	j	80004266 <filestat+0x56>

0000000080004276 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004276:	7179                	addi	sp,sp,-48
    80004278:	f406                	sd	ra,40(sp)
    8000427a:	f022                	sd	s0,32(sp)
    8000427c:	e84a                	sd	s2,16(sp)
    8000427e:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004280:	00854783          	lbu	a5,8(a0)
    80004284:	c3dd                	beqz	a5,8000432a <fileread+0xb4>
    80004286:	ec26                	sd	s1,24(sp)
    80004288:	e44e                	sd	s3,8(sp)
    8000428a:	84aa                	mv	s1,a0
    8000428c:	892e                	mv	s2,a1
    8000428e:	89b2                	mv	s3,a2
    80004290:	01f6579b          	srliw	a5,a2,0x1f
    80004294:	ebc9                	bnez	a5,80004326 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    80004296:	411c                	lw	a5,0(a0)
    80004298:	4705                	li	a4,1
    8000429a:	04e78363          	beq	a5,a4,800042e0 <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000429e:	470d                	li	a4,3
    800042a0:	04e78763          	beq	a5,a4,800042ee <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800042a4:	4709                	li	a4,2
    800042a6:	06e79a63          	bne	a5,a4,8000431a <fileread+0xa4>
    ilock(f->ip);
    800042aa:	6d08                	ld	a0,24(a0)
    800042ac:	f7ffe0ef          	jal	8000322a <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042b0:	874e                	mv	a4,s3
    800042b2:	5094                	lw	a3,32(s1)
    800042b4:	864a                	mv	a2,s2
    800042b6:	4585                	li	a1,1
    800042b8:	6c88                	ld	a0,24(s1)
    800042ba:	b4aff0ef          	jal	80003604 <readi>
    800042be:	892a                	mv	s2,a0
    800042c0:	00a05563          	blez	a0,800042ca <fileread+0x54>
      f->off += r;
    800042c4:	509c                	lw	a5,32(s1)
    800042c6:	9fa9                	addw	a5,a5,a0
    800042c8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042ca:	6c88                	ld	a0,24(s1)
    800042cc:	80cff0ef          	jal	800032d8 <iunlock>
    800042d0:	64e2                	ld	s1,24(sp)
    800042d2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800042d4:	854a                	mv	a0,s2
    800042d6:	70a2                	ld	ra,40(sp)
    800042d8:	7402                	ld	s0,32(sp)
    800042da:	6942                	ld	s2,16(sp)
    800042dc:	6145                	addi	sp,sp,48
    800042de:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042e0:	6908                	ld	a0,16(a0)
    800042e2:	3e2000ef          	jal	800046c4 <piperead>
    800042e6:	892a                	mv	s2,a0
    800042e8:	64e2                	ld	s1,24(sp)
    800042ea:	69a2                	ld	s3,8(sp)
    800042ec:	b7e5                	j	800042d4 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042ee:	02451783          	lh	a5,36(a0)
    800042f2:	03079693          	slli	a3,a5,0x30
    800042f6:	92c1                	srli	a3,a3,0x30
    800042f8:	4725                	li	a4,9
    800042fa:	02d76b63          	bltu	a4,a3,80004330 <fileread+0xba>
    800042fe:	0792                	slli	a5,a5,0x4
    80004300:	0001e717          	auipc	a4,0x1e
    80004304:	16870713          	addi	a4,a4,360 # 80022468 <devsw>
    80004308:	97ba                	add	a5,a5,a4
    8000430a:	639c                	ld	a5,0(a5)
    8000430c:	c79d                	beqz	a5,8000433a <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    8000430e:	4505                	li	a0,1
    80004310:	9782                	jalr	a5
    80004312:	892a                	mv	s2,a0
    80004314:	64e2                	ld	s1,24(sp)
    80004316:	69a2                	ld	s3,8(sp)
    80004318:	bf75                	j	800042d4 <fileread+0x5e>
    panic("fileread");
    8000431a:	00003517          	auipc	a0,0x3
    8000431e:	27e50513          	addi	a0,a0,638 # 80007598 <etext+0x598>
    80004322:	d12fc0ef          	jal	80000834 <panic>
    80004326:	64e2                	ld	s1,24(sp)
    80004328:	69a2                	ld	s3,8(sp)
    return -1;
    8000432a:	57fd                	li	a5,-1
    8000432c:	893e                	mv	s2,a5
    8000432e:	b75d                	j	800042d4 <fileread+0x5e>
      return -1;
    80004330:	57fd                	li	a5,-1
    80004332:	893e                	mv	s2,a5
    80004334:	64e2                	ld	s1,24(sp)
    80004336:	69a2                	ld	s3,8(sp)
    80004338:	bf71                	j	800042d4 <fileread+0x5e>
    8000433a:	57fd                	li	a5,-1
    8000433c:	893e                	mv	s2,a5
    8000433e:	64e2                	ld	s1,24(sp)
    80004340:	69a2                	ld	s3,8(sp)
    80004342:	bf49                	j	800042d4 <fileread+0x5e>

0000000080004344 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004344:	00954783          	lbu	a5,9(a0)
    80004348:	12078b63          	beqz	a5,8000447e <filewrite+0x13a>
{
    8000434c:	711d                	addi	sp,sp,-96
    8000434e:	ec86                	sd	ra,88(sp)
    80004350:	e8a2                	sd	s0,80(sp)
    80004352:	e0ca                	sd	s2,64(sp)
    80004354:	f456                	sd	s5,40(sp)
    80004356:	f05a                	sd	s6,32(sp)
    80004358:	1080                	addi	s0,sp,96
    8000435a:	892a                	mv	s2,a0
    8000435c:	8b2e                	mv	s6,a1
    8000435e:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    80004360:	01f6579b          	srliw	a5,a2,0x1f
    80004364:	0e079d63          	bnez	a5,8000445e <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    80004368:	411c                	lw	a5,0(a0)
    8000436a:	4705                	li	a4,1
    8000436c:	02e78a63          	beq	a5,a4,800043a0 <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004370:	470d                	li	a4,3
    80004372:	02e78b63          	beq	a5,a4,800043a8 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004376:	4709                	li	a4,2
    80004378:	0ce79763          	bne	a5,a4,80004446 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    8000437c:	0ec05763          	blez	a2,8000446a <filewrite+0x126>
    80004380:	e4a6                	sd	s1,72(sp)
    80004382:	fc4e                	sd	s3,56(sp)
    80004384:	f852                	sd	s4,48(sp)
    80004386:	ec5e                	sd	s7,24(sp)
    80004388:	e862                	sd	s8,16(sp)
    8000438a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000438c:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    8000438e:	6b85                	lui	s7,0x1
    80004390:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004394:	6785                	lui	a5,0x1
    80004396:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000439a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000439c:	4c05                	li	s8,1
    8000439e:	a8ad                	j	80004418 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800043a0:	6908                	ld	a0,16(a0)
    800043a2:	206000ef          	jal	800045a8 <pipewrite>
    800043a6:	a849                	j	80004438 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043a8:	02451783          	lh	a5,36(a0)
    800043ac:	03079693          	slli	a3,a5,0x30
    800043b0:	92c1                	srli	a3,a3,0x30
    800043b2:	4725                	li	a4,9
    800043b4:	0ad76763          	bltu	a4,a3,80004462 <filewrite+0x11e>
    800043b8:	0792                	slli	a5,a5,0x4
    800043ba:	0001e717          	auipc	a4,0x1e
    800043be:	0ae70713          	addi	a4,a4,174 # 80022468 <devsw>
    800043c2:	97ba                	add	a5,a5,a4
    800043c4:	679c                	ld	a5,8(a5)
    800043c6:	c3c5                	beqz	a5,80004466 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800043c8:	4505                	li	a0,1
    800043ca:	9782                	jalr	a5
    800043cc:	a0b5                	j	80004438 <filewrite+0xf4>
      if (n1 > max)
    800043ce:	2981                	sext.w	s3,s3
      begin_op();
    800043d0:	8c5ff0ef          	jal	80003c94 <begin_op>
      ilock(f->ip);
    800043d4:	01893503          	ld	a0,24(s2)
    800043d8:	e53fe0ef          	jal	8000322a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043dc:	874e                	mv	a4,s3
    800043de:	02092683          	lw	a3,32(s2)
    800043e2:	016a0633          	add	a2,s4,s6
    800043e6:	85e2                	mv	a1,s8
    800043e8:	01893503          	ld	a0,24(s2)
    800043ec:	b0aff0ef          	jal	800036f6 <writei>
    800043f0:	84aa                	mv	s1,a0
    800043f2:	00a05763          	blez	a0,80004400 <filewrite+0xbc>
        f->off += r;
    800043f6:	02092783          	lw	a5,32(s2)
    800043fa:	9fa9                	addw	a5,a5,a0
    800043fc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004400:	01893503          	ld	a0,24(s2)
    80004404:	ed5fe0ef          	jal	800032d8 <iunlock>
      end_op();
    80004408:	919ff0ef          	jal	80003d20 <end_op>

      if (r != n1) {
    8000440c:	00999d63          	bne	s3,s1,80004426 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    80004410:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004414:	015a5963          	bge	s4,s5,80004426 <filewrite+0xe2>
      int n1 = n - i;
    80004418:	414a87bb          	subw	a5,s5,s4
    8000441c:	89be                	mv	s3,a5
      if (n1 > max)
    8000441e:	fafbd8e3          	bge	s7,a5,800043ce <filewrite+0x8a>
    80004422:	89e6                	mv	s3,s9
    80004424:	b76d                	j	800043ce <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004426:	054a9463          	bne	s5,s4,8000446e <filewrite+0x12a>
    8000442a:	8556                	mv	a0,s5
    8000442c:	64a6                	ld	s1,72(sp)
    8000442e:	79e2                	ld	s3,56(sp)
    80004430:	7a42                	ld	s4,48(sp)
    80004432:	6be2                	ld	s7,24(sp)
    80004434:	6c42                	ld	s8,16(sp)
    80004436:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004438:	60e6                	ld	ra,88(sp)
    8000443a:	6446                	ld	s0,80(sp)
    8000443c:	6906                	ld	s2,64(sp)
    8000443e:	7aa2                	ld	s5,40(sp)
    80004440:	7b02                	ld	s6,32(sp)
    80004442:	6125                	addi	sp,sp,96
    80004444:	8082                	ret
    80004446:	e4a6                	sd	s1,72(sp)
    80004448:	fc4e                	sd	s3,56(sp)
    8000444a:	f852                	sd	s4,48(sp)
    8000444c:	ec5e                	sd	s7,24(sp)
    8000444e:	e862                	sd	s8,16(sp)
    80004450:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004452:	00003517          	auipc	a0,0x3
    80004456:	15650513          	addi	a0,a0,342 # 800075a8 <etext+0x5a8>
    8000445a:	bdafc0ef          	jal	80000834 <panic>
    return -1;
    8000445e:	557d                	li	a0,-1
    80004460:	bfe1                	j	80004438 <filewrite+0xf4>
      return -1;
    80004462:	557d                	li	a0,-1
    80004464:	bfd1                	j	80004438 <filewrite+0xf4>
    80004466:	557d                	li	a0,-1
    80004468:	bfc1                	j	80004438 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    8000446a:	8532                	mv	a0,a2
    8000446c:	b7f1                	j	80004438 <filewrite+0xf4>
    8000446e:	557d                	li	a0,-1
    80004470:	64a6                	ld	s1,72(sp)
    80004472:	79e2                	ld	s3,56(sp)
    80004474:	7a42                	ld	s4,48(sp)
    80004476:	6be2                	ld	s7,24(sp)
    80004478:	6c42                	ld	s8,16(sp)
    8000447a:	6ca2                	ld	s9,8(sp)
    8000447c:	bf75                	j	80004438 <filewrite+0xf4>
    return -1;
    8000447e:	557d                	li	a0,-1
}
    80004480:	8082                	ret

0000000080004482 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004482:	7179                	addi	sp,sp,-48
    80004484:	f406                	sd	ra,40(sp)
    80004486:	f022                	sd	s0,32(sp)
    80004488:	ec26                	sd	s1,24(sp)
    8000448a:	e052                	sd	s4,0(sp)
    8000448c:	1800                	addi	s0,sp,48
    8000448e:	84aa                	mv	s1,a0
    80004490:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004492:	0005b023          	sd	zero,0(a1)
    80004496:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000449a:	c11ff0ef          	jal	800040aa <filealloc>
    8000449e:	e088                	sd	a0,0(s1)
    800044a0:	c549                	beqz	a0,8000452a <pipealloc+0xa8>
    800044a2:	c09ff0ef          	jal	800040aa <filealloc>
    800044a6:	00aa3023          	sd	a0,0(s4)
    800044aa:	cd25                	beqz	a0,80004522 <pipealloc+0xa0>
    800044ac:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    800044ae:	e60fc0ef          	jal	80000b0e <kalloc>
    800044b2:	892a                	mv	s2,a0
    800044b4:	c12d                	beqz	a0,80004516 <pipealloc+0x94>
    800044b6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044b8:	4985                	li	s3,1
    800044ba:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044be:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044c2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044c6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044ca:	00003597          	auipc	a1,0x3
    800044ce:	0ee58593          	addi	a1,a1,238 # 800075b8 <etext+0x5b8>
    800044d2:	e96fc0ef          	jal	80000b68 <initlock>
  (*f0)->type = FD_PIPE;
    800044d6:	609c                	ld	a5,0(s1)
    800044d8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044dc:	609c                	ld	a5,0(s1)
    800044de:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044e2:	609c                	ld	a5,0(s1)
    800044e4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800044e8:	609c                	ld	a5,0(s1)
    800044ea:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044ee:	000a3783          	ld	a5,0(s4)
    800044f2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800044f6:	000a3783          	ld	a5,0(s4)
    800044fa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800044fe:	000a3783          	ld	a5,0(s4)
    80004502:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004506:	000a3783          	ld	a5,0(s4)
    8000450a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000450e:	4501                	li	a0,0
    80004510:	6942                	ld	s2,16(sp)
    80004512:	69a2                	ld	s3,8(sp)
    80004514:	a01d                	j	8000453a <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004516:	6088                	ld	a0,0(s1)
    80004518:	c119                	beqz	a0,8000451e <pipealloc+0x9c>
    8000451a:	6942                	ld	s2,16(sp)
    8000451c:	a029                	j	80004526 <pipealloc+0xa4>
    8000451e:	6942                	ld	s2,16(sp)
    80004520:	a029                	j	8000452a <pipealloc+0xa8>
    80004522:	6088                	ld	a0,0(s1)
    80004524:	c10d                	beqz	a0,80004546 <pipealloc+0xc4>
    fileclose(*f0);
    80004526:	c29ff0ef          	jal	8000414e <fileclose>
  if (*f1)
    8000452a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000452e:	557d                	li	a0,-1
  if (*f1)
    80004530:	c789                	beqz	a5,8000453a <pipealloc+0xb8>
    fileclose(*f1);
    80004532:	853e                	mv	a0,a5
    80004534:	c1bff0ef          	jal	8000414e <fileclose>
  return -1;
    80004538:	557d                	li	a0,-1
}
    8000453a:	70a2                	ld	ra,40(sp)
    8000453c:	7402                	ld	s0,32(sp)
    8000453e:	64e2                	ld	s1,24(sp)
    80004540:	6a02                	ld	s4,0(sp)
    80004542:	6145                	addi	sp,sp,48
    80004544:	8082                	ret
  return -1;
    80004546:	557d                	li	a0,-1
    80004548:	bfcd                	j	8000453a <pipealloc+0xb8>

000000008000454a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000454a:	1101                	addi	sp,sp,-32
    8000454c:	ec06                	sd	ra,24(sp)
    8000454e:	e822                	sd	s0,16(sp)
    80004550:	e426                	sd	s1,8(sp)
    80004552:	e04a                	sd	s2,0(sp)
    80004554:	1000                	addi	s0,sp,32
    80004556:	84aa                	mv	s1,a0
    80004558:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000455a:	e8efc0ef          	jal	80000be8 <acquire>
  if (writable) {
    8000455e:	02090763          	beqz	s2,8000458c <pipeclose+0x42>
    pi->writeopen = 0;
    80004562:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004566:	21848513          	addi	a0,s1,536
    8000456a:	a15fd0ef          	jal	80001f7e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000456e:	2204a783          	lw	a5,544(s1)
    80004572:	e781                	bnez	a5,8000457a <pipeclose+0x30>
    80004574:	2244a783          	lw	a5,548(s1)
    80004578:	c38d                	beqz	a5,8000459a <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    8000457a:	8526                	mv	a0,s1
    8000457c:	ef4fc0ef          	jal	80000c70 <release>
}
    80004580:	60e2                	ld	ra,24(sp)
    80004582:	6442                	ld	s0,16(sp)
    80004584:	64a2                	ld	s1,8(sp)
    80004586:	6902                	ld	s2,0(sp)
    80004588:	6105                	addi	sp,sp,32
    8000458a:	8082                	ret
    pi->readopen = 0;
    8000458c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004590:	21c48513          	addi	a0,s1,540
    80004594:	9ebfd0ef          	jal	80001f7e <wakeup>
    80004598:	bfd9                	j	8000456e <pipeclose+0x24>
    release(&pi->lock);
    8000459a:	8526                	mv	a0,s1
    8000459c:	ed4fc0ef          	jal	80000c70 <release>
    kfree((char *)pi);
    800045a0:	8526                	mv	a0,s1
    800045a2:	c84fc0ef          	jal	80000a26 <kfree>
    800045a6:	bfe9                	j	80004580 <pipeclose+0x36>

00000000800045a8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045a8:	7159                	addi	sp,sp,-112
    800045aa:	f486                	sd	ra,104(sp)
    800045ac:	f0a2                	sd	s0,96(sp)
    800045ae:	eca6                	sd	s1,88(sp)
    800045b0:	e8ca                	sd	s2,80(sp)
    800045b2:	e4ce                	sd	s3,72(sp)
    800045b4:	e0d2                	sd	s4,64(sp)
    800045b6:	fc56                	sd	s5,56(sp)
    800045b8:	1880                	addi	s0,sp,112
    800045ba:	84aa                	mv	s1,a0
    800045bc:	8aae                	mv	s5,a1
    800045be:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045c0:	b48fd0ef          	jal	80001908 <myproc>
    800045c4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045c6:	8526                	mv	a0,s1
    800045c8:	e20fc0ef          	jal	80000be8 <acquire>
  while (i < n) {
    800045cc:	0f405a63          	blez	s4,800046c0 <pipewrite+0x118>
    800045d0:	f85a                	sd	s6,48(sp)
    800045d2:	f45e                	sd	s7,40(sp)
    800045d4:	f062                	sd	s8,32(sp)
    800045d6:	ec66                	sd	s9,24(sp)
    800045d8:	e86a                	sd	s10,16(sp)
  int i = 0;
    800045da:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800045dc:	f9f40c13          	addi	s8,s0,-97
    800045e0:	4b85                	li	s7,1
    800045e2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045e4:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    800045e8:	21c48c93          	addi	s9,s1,540
    800045ec:	a0a1                	j	80004634 <pipewrite+0x8c>
      release(&pi->lock);
    800045ee:	8526                	mv	a0,s1
    800045f0:	e80fc0ef          	jal	80000c70 <release>
      return -1;
    800045f4:	597d                	li	s2,-1
    800045f6:	7b42                	ld	s6,48(sp)
    800045f8:	7ba2                	ld	s7,40(sp)
    800045fa:	7c02                	ld	s8,32(sp)
    800045fc:	6ce2                	ld	s9,24(sp)
    800045fe:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004600:	854a                	mv	a0,s2
    80004602:	70a6                	ld	ra,104(sp)
    80004604:	7406                	ld	s0,96(sp)
    80004606:	64e6                	ld	s1,88(sp)
    80004608:	6946                	ld	s2,80(sp)
    8000460a:	69a6                	ld	s3,72(sp)
    8000460c:	6a06                	ld	s4,64(sp)
    8000460e:	7ae2                	ld	s5,56(sp)
    80004610:	6165                	addi	sp,sp,112
    80004612:	8082                	ret
      wakeup(&pi->nread);
    80004614:	856a                	mv	a0,s10
    80004616:	969fd0ef          	jal	80001f7e <wakeup>
      sleep_prepare(&pi->nwrite);
    8000461a:	8566                	mv	a0,s9
    8000461c:	8f7fd0ef          	jal	80001f12 <sleep_prepare>
      release(&pi->lock);
    80004620:	8526                	mv	a0,s1
    80004622:	e4efc0ef          	jal	80000c70 <release>
      sleep();
    80004626:	929fd0ef          	jal	80001f4e <sleep>
      acquire(&pi->lock);
    8000462a:	8526                	mv	a0,s1
    8000462c:	dbcfc0ef          	jal	80000be8 <acquire>
  while (i < n) {
    80004630:	07495b63          	bge	s2,s4,800046a6 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004634:	2204a783          	lw	a5,544(s1)
    80004638:	dbdd                	beqz	a5,800045ee <pipewrite+0x46>
    8000463a:	854e                	mv	a0,s3
    8000463c:	b35fd0ef          	jal	80002170 <killed>
    80004640:	f55d                	bnez	a0,800045ee <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004642:	2184a783          	lw	a5,536(s1)
    80004646:	21c4a703          	lw	a4,540(s1)
    8000464a:	2007879b          	addiw	a5,a5,512
    8000464e:	fcf703e3          	beq	a4,a5,80004614 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004652:	875e                	mv	a4,s7
    80004654:	015906b3          	add	a3,s2,s5
    80004658:	8662                	mv	a2,s8
    8000465a:	0489b583          	ld	a1,72(s3)
    8000465e:	0509b503          	ld	a0,80(s3)
    80004662:	fa7fc0ef          	jal	80001608 <copyin>
    80004666:	03650163          	beq	a0,s6,80004688 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000466a:	21c4a783          	lw	a5,540(s1)
    8000466e:	0017871b          	addiw	a4,a5,1
    80004672:	20e4ae23          	sw	a4,540(s1)
    80004676:	1ff7f793          	andi	a5,a5,511
    8000467a:	97a6                	add	a5,a5,s1
    8000467c:	f9f44703          	lbu	a4,-97(s0)
    80004680:	00e78c23          	sb	a4,24(a5)
      i++;
    80004684:	2905                	addiw	s2,s2,1
    80004686:	b76d                	j	80004630 <pipewrite+0x88>
        if (i == 0)
    80004688:	00090863          	beqz	s2,80004698 <pipewrite+0xf0>
    8000468c:	7b42                	ld	s6,48(sp)
    8000468e:	7ba2                	ld	s7,40(sp)
    80004690:	7c02                	ld	s8,32(sp)
    80004692:	6ce2                	ld	s9,24(sp)
    80004694:	6d42                	ld	s10,16(sp)
    80004696:	a829                	j	800046b0 <pipewrite+0x108>
          i = -1;
    80004698:	892a                	mv	s2,a0
        break;
    8000469a:	7b42                	ld	s6,48(sp)
    8000469c:	7ba2                	ld	s7,40(sp)
    8000469e:	7c02                	ld	s8,32(sp)
    800046a0:	6ce2                	ld	s9,24(sp)
    800046a2:	6d42                	ld	s10,16(sp)
    800046a4:	a031                	j	800046b0 <pipewrite+0x108>
    800046a6:	7b42                	ld	s6,48(sp)
    800046a8:	7ba2                	ld	s7,40(sp)
    800046aa:	7c02                	ld	s8,32(sp)
    800046ac:	6ce2                	ld	s9,24(sp)
    800046ae:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800046b0:	21848513          	addi	a0,s1,536
    800046b4:	8cbfd0ef          	jal	80001f7e <wakeup>
  release(&pi->lock);
    800046b8:	8526                	mv	a0,s1
    800046ba:	db6fc0ef          	jal	80000c70 <release>
  return i;
    800046be:	b789                	j	80004600 <pipewrite+0x58>
  int i = 0;
    800046c0:	4901                	li	s2,0
    800046c2:	b7fd                	j	800046b0 <pipewrite+0x108>

00000000800046c4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046c4:	711d                	addi	sp,sp,-96
    800046c6:	ec86                	sd	ra,88(sp)
    800046c8:	e8a2                	sd	s0,80(sp)
    800046ca:	e4a6                	sd	s1,72(sp)
    800046cc:	e0ca                	sd	s2,64(sp)
    800046ce:	fc4e                	sd	s3,56(sp)
    800046d0:	f852                	sd	s4,48(sp)
    800046d2:	f456                	sd	s5,40(sp)
    800046d4:	1080                	addi	s0,sp,96
    800046d6:	84aa                	mv	s1,a0
    800046d8:	89ae                	mv	s3,a1
    800046da:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046dc:	a2cfd0ef          	jal	80001908 <myproc>
    800046e0:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    800046e2:	8526                	mv	a0,s1
    800046e4:	d04fc0ef          	jal	80000be8 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800046e8:	2184a703          	lw	a4,536(s1)
    800046ec:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    800046f0:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    800046f4:	02f71e63          	bne	a4,a5,80004730 <piperead+0x6c>
    800046f8:	2244a783          	lw	a5,548(s1)
    800046fc:	c3b9                	beqz	a5,80004742 <piperead+0x7e>
    if (killed(pr)) {
    800046fe:	854a                	mv	a0,s2
    80004700:	a71fd0ef          	jal	80002170 <killed>
    80004704:	e915                	bnez	a0,80004738 <piperead+0x74>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004706:	8552                	mv	a0,s4
    80004708:	80bfd0ef          	jal	80001f12 <sleep_prepare>
    release(&pi->lock);
    8000470c:	8526                	mv	a0,s1
    8000470e:	d62fc0ef          	jal	80000c70 <release>
    sleep();
    80004712:	83dfd0ef          	jal	80001f4e <sleep>
    acquire(&pi->lock);
    80004716:	8526                	mv	a0,s1
    80004718:	cd0fc0ef          	jal	80000be8 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000471c:	2184a703          	lw	a4,536(s1)
    80004720:	21c4a783          	lw	a5,540(s1)
    80004724:	fcf70ae3          	beq	a4,a5,800046f8 <piperead+0x34>
    80004728:	f05a                	sd	s6,32(sp)
    8000472a:	ec5e                	sd	s7,24(sp)
    8000472c:	e862                	sd	s8,16(sp)
    8000472e:	a829                	j	80004748 <piperead+0x84>
    80004730:	f05a                	sd	s6,32(sp)
    80004732:	ec5e                	sd	s7,24(sp)
    80004734:	e862                	sd	s8,16(sp)
    80004736:	a809                	j	80004748 <piperead+0x84>
      release(&pi->lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	d36fc0ef          	jal	80000c70 <release>
      return -1;
    8000473e:	5a7d                	li	s4,-1
    80004740:	a0b5                	j	800047ac <piperead+0xe8>
    80004742:	f05a                	sd	s6,32(sp)
    80004744:	ec5e                	sd	s7,24(sp)
    80004746:	e862                	sd	s8,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004748:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000474a:	faf40c13          	addi	s8,s0,-81
    8000474e:	4b85                	li	s7,1
    80004750:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004752:	05505363          	blez	s5,80004798 <piperead+0xd4>
    if (pi->nread == pi->nwrite)
    80004756:	2184a783          	lw	a5,536(s1)
    8000475a:	21c4a703          	lw	a4,540(s1)
    8000475e:	02f70d63          	beq	a4,a5,80004798 <piperead+0xd4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004762:	1ff7f793          	andi	a5,a5,511
    80004766:	97a6                	add	a5,a5,s1
    80004768:	0187c783          	lbu	a5,24(a5)
    8000476c:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004770:	875e                	mv	a4,s7
    80004772:	86e2                	mv	a3,s8
    80004774:	864e                	mv	a2,s3
    80004776:	04893583          	ld	a1,72(s2)
    8000477a:	05093503          	ld	a0,80(s2)
    8000477e:	dc5fc0ef          	jal	80001542 <copyout>
    80004782:	03650f63          	beq	a0,s6,800047c0 <piperead+0xfc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004786:	2184a783          	lw	a5,536(s1)
    8000478a:	2785                	addiw	a5,a5,1
    8000478c:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004790:	2a05                	addiw	s4,s4,1
    80004792:	0985                	addi	s3,s3,1
    80004794:	fd4a91e3          	bne	s5,s4,80004756 <piperead+0x92>
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004798:	21c48513          	addi	a0,s1,540
    8000479c:	fe2fd0ef          	jal	80001f7e <wakeup>
  release(&pi->lock);
    800047a0:	8526                	mv	a0,s1
    800047a2:	ccefc0ef          	jal	80000c70 <release>
    800047a6:	7b02                	ld	s6,32(sp)
    800047a8:	6be2                	ld	s7,24(sp)
    800047aa:	6c42                	ld	s8,16(sp)
  return i;
}
    800047ac:	8552                	mv	a0,s4
    800047ae:	60e6                	ld	ra,88(sp)
    800047b0:	6446                	ld	s0,80(sp)
    800047b2:	64a6                	ld	s1,72(sp)
    800047b4:	6906                	ld	s2,64(sp)
    800047b6:	79e2                	ld	s3,56(sp)
    800047b8:	7a42                	ld	s4,48(sp)
    800047ba:	7aa2                	ld	s5,40(sp)
    800047bc:	6125                	addi	sp,sp,96
    800047be:	8082                	ret
      if (i == 0)
    800047c0:	fc0a1ce3          	bnez	s4,80004798 <piperead+0xd4>
        i = -1;
    800047c4:	8a2a                	mv	s4,a0
    800047c6:	bfc9                	j	80004798 <piperead+0xd4>

00000000800047c8 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800047c8:	1141                	addi	sp,sp,-16
    800047ca:	e406                	sd	ra,8(sp)
    800047cc:	e022                	sd	s0,0(sp)
    800047ce:	0800                	addi	s0,sp,16
    800047d0:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800047d2:	0035151b          	slliw	a0,a0,0x3
    800047d6:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    800047d8:	8b89                	andi	a5,a5,2
    800047da:	c399                	beqz	a5,800047e0 <flags2perm+0x18>
    perm |= PTE_W;
    800047dc:	00456513          	ori	a0,a0,4
  return perm;
}
    800047e0:	60a2                	ld	ra,8(sp)
    800047e2:	6402                	ld	s0,0(sp)
    800047e4:	0141                	addi	sp,sp,16
    800047e6:	8082                	ret

00000000800047e8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047e8:	de010113          	addi	sp,sp,-544
    800047ec:	20113c23          	sd	ra,536(sp)
    800047f0:	20813823          	sd	s0,528(sp)
    800047f4:	20913423          	sd	s1,520(sp)
    800047f8:	21213023          	sd	s2,512(sp)
    800047fc:	1400                	addi	s0,sp,544
    800047fe:	892a                	mv	s2,a0
    80004800:	dea43823          	sd	a0,-528(s0)
    80004804:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004808:	900fd0ef          	jal	80001908 <myproc>
    8000480c:	84aa                	mv	s1,a0

  begin_op();
    8000480e:	c86ff0ef          	jal	80003c94 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004812:	854a                	mv	a0,s2
    80004814:	aa2ff0ef          	jal	80003ab6 <namei>
    80004818:	cd21                	beqz	a0,80004870 <kexec+0x88>
    8000481a:	fbd2                	sd	s4,496(sp)
    8000481c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000481e:	a0dfe0ef          	jal	8000322a <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004822:	04000713          	li	a4,64
    80004826:	4681                	li	a3,0
    80004828:	e5040613          	addi	a2,s0,-432
    8000482c:	4581                	li	a1,0
    8000482e:	8552                	mv	a0,s4
    80004830:	dd5fe0ef          	jal	80003604 <readi>
    80004834:	04000793          	li	a5,64
    80004838:	00f51a63          	bne	a0,a5,8000484c <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    8000483c:	e5042703          	lw	a4,-432(s0)
    80004840:	464c47b7          	lui	a5,0x464c4
    80004844:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004848:	02f70863          	beq	a4,a5,80004878 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    8000484c:	8552                	mv	a0,s4
    8000484e:	c31fe0ef          	jal	8000347e <iunlockput>
    end_op();
    80004852:	cceff0ef          	jal	80003d20 <end_op>
  }
  return -1;
    80004856:	557d                	li	a0,-1
    80004858:	7a5e                	ld	s4,496(sp)
}
    8000485a:	21813083          	ld	ra,536(sp)
    8000485e:	21013403          	ld	s0,528(sp)
    80004862:	20813483          	ld	s1,520(sp)
    80004866:	20013903          	ld	s2,512(sp)
    8000486a:	22010113          	addi	sp,sp,544
    8000486e:	8082                	ret
    end_op();
    80004870:	cb0ff0ef          	jal	80003d20 <end_op>
    return -1;
    80004874:	557d                	li	a0,-1
    80004876:	b7d5                	j	8000485a <kexec+0x72>
    80004878:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    8000487a:	8526                	mv	a0,s1
    8000487c:	992fd0ef          	jal	80001a0e <proc_pagetable>
    80004880:	8b2a                	mv	s6,a0
    80004882:	26050e63          	beqz	a0,80004afe <kexec+0x316>
    80004886:	ffce                	sd	s3,504(sp)
    80004888:	f7d6                	sd	s5,488(sp)
    8000488a:	efde                	sd	s7,472(sp)
    8000488c:	ebe2                	sd	s8,464(sp)
    8000488e:	e7e6                	sd	s9,456(sp)
    80004890:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004892:	e8845783          	lhu	a5,-376(s0)
    80004896:	14078263          	beqz	a5,800049da <kexec+0x1f2>
    8000489a:	ff6e                	sd	s11,440(sp)
    8000489c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048a0:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800048a2:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800048a4:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    800048a8:	6c85                	lui	s9,0x1
    800048aa:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048ae:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800048b2:	6a85                	lui	s5,0x1
    800048b4:	a085                	j	80004914 <kexec+0x12c>
      panic("loadseg: address should exist");
    800048b6:	00003517          	auipc	a0,0x3
    800048ba:	d0a50513          	addi	a0,a0,-758 # 800075c0 <etext+0x5c0>
    800048be:	f77fb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    800048c2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800048c4:	874a                	mv	a4,s2
    800048c6:	009b86bb          	addw	a3,s7,s1
    800048ca:	4581                	li	a1,0
    800048cc:	8552                	mv	a0,s4
    800048ce:	d37fe0ef          	jal	80003604 <readi>
    800048d2:	22a91a63          	bne	s2,a0,80004b06 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    800048d6:	009a84bb          	addw	s1,s5,s1
    800048da:	0334f263          	bgeu	s1,s3,800048fe <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800048de:	02049593          	slli	a1,s1,0x20
    800048e2:	9181                	srli	a1,a1,0x20
    800048e4:	95e2                	add	a1,a1,s8
    800048e6:	855a                	mv	a0,s6
    800048e8:	ef0fc0ef          	jal	80000fd8 <walkaddr>
    800048ec:	862a                	mv	a2,a0
    if (pa == 0)
    800048ee:	d561                	beqz	a0,800048b6 <kexec+0xce>
    if (sz - i < PGSIZE)
    800048f0:	409987bb          	subw	a5,s3,s1
    800048f4:	893e                	mv	s2,a5
    800048f6:	fcfcf6e3          	bgeu	s9,a5,800048c2 <kexec+0xda>
    800048fa:	8956                	mv	s2,s5
    800048fc:	b7d9                	j	800048c2 <kexec+0xda>
    sz = sz1;
    800048fe:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004902:	2d05                	addiw	s10,s10,1
    80004904:	e0843783          	ld	a5,-504(s0)
    80004908:	0387869b          	addiw	a3,a5,56
    8000490c:	e8845783          	lhu	a5,-376(s0)
    80004910:	06fd5d63          	bge	s10,a5,8000498a <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004914:	e0d43423          	sd	a3,-504(s0)
    80004918:	876e                	mv	a4,s11
    8000491a:	e1840613          	addi	a2,s0,-488
    8000491e:	4581                	li	a1,0
    80004920:	8552                	mv	a0,s4
    80004922:	ce3fe0ef          	jal	80003604 <readi>
    80004926:	1db51e63          	bne	a0,s11,80004b02 <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    8000492a:	e1842783          	lw	a5,-488(s0)
    8000492e:	4705                	li	a4,1
    80004930:	fce799e3          	bne	a5,a4,80004902 <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004934:	e4043483          	ld	s1,-448(s0)
    80004938:	e3843783          	ld	a5,-456(s0)
    8000493c:	1ef4e363          	bltu	s1,a5,80004b22 <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004940:	e2843783          	ld	a5,-472(s0)
    80004944:	94be                	add	s1,s1,a5
    80004946:	1ef4e163          	bltu	s1,a5,80004b28 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    8000494a:	de843703          	ld	a4,-536(s0)
    8000494e:	8ff9                	and	a5,a5,a4
    80004950:	1c079f63          	bnez	a5,80004b2e <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004954:	e1c42503          	lw	a0,-484(s0)
    80004958:	e71ff0ef          	jal	800047c8 <flags2perm>
    8000495c:	86aa                	mv	a3,a0
    8000495e:	8626                	mv	a2,s1
    80004960:	85ca                	mv	a1,s2
    80004962:	855a                	mv	a0,s6
    80004964:	94bfc0ef          	jal	800012ae <uvmalloc>
    80004968:	dea43c23          	sd	a0,-520(s0)
    8000496c:	1c050463          	beqz	a0,80004b34 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004970:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004974:	00098863          	beqz	s3,80004984 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004978:	e2843c03          	ld	s8,-472(s0)
    8000497c:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004980:	4481                	li	s1,0
    80004982:	bfb1                	j	800048de <kexec+0xf6>
    sz = sz1;
    80004984:	df843903          	ld	s2,-520(s0)
    80004988:	bfad                	j	80004902 <kexec+0x11a>
    8000498a:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    8000498c:	8552                	mv	a0,s4
    8000498e:	af1fe0ef          	jal	8000347e <iunlockput>
  end_op();
    80004992:	b8eff0ef          	jal	80003d20 <end_op>
  p = myproc();
    80004996:	f73fc0ef          	jal	80001908 <myproc>
    8000499a:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    8000499c:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    800049a0:	6c05                	lui	s8,0x1
    800049a2:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    800049a4:	9c4a                	add	s8,s8,s2
    800049a6:	77fd                	lui	a5,0xfffff
    800049a8:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800049ac:	4691                	li	a3,4
    800049ae:	6609                	lui	a2,0x2
    800049b0:	9662                	add	a2,a2,s8
    800049b2:	85e2                	mv	a1,s8
    800049b4:	855a                	mv	a0,s6
    800049b6:	8f9fc0ef          	jal	800012ae <uvmalloc>
    800049ba:	892a                	mv	s2,a0
    800049bc:	e10d                	bnez	a0,800049de <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    800049be:	85e2                	mv	a1,s8
    800049c0:	855a                	mv	a0,s6
    800049c2:	8d0fd0ef          	jal	80001a92 <proc_freepagetable>
  return -1;
    800049c6:	557d                	li	a0,-1
    800049c8:	79fe                	ld	s3,504(sp)
    800049ca:	7a5e                	ld	s4,496(sp)
    800049cc:	7abe                	ld	s5,488(sp)
    800049ce:	7b1e                	ld	s6,480(sp)
    800049d0:	6bfe                	ld	s7,472(sp)
    800049d2:	6c5e                	ld	s8,464(sp)
    800049d4:	6cbe                	ld	s9,456(sp)
    800049d6:	6d1e                	ld	s10,448(sp)
    800049d8:	b549                	j	8000485a <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049da:	4901                	li	s2,0
    800049dc:	bf45                	j	8000498c <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800049de:	75f9                	lui	a1,0xffffe
    800049e0:	95aa                	add	a1,a1,a0
    800049e2:	855a                	mv	a0,s6
    800049e4:	a9dfc0ef          	jal	80001480 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    800049e8:	80090a13          	addi	s4,s2,-2048
    800049ec:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    800049f0:	e0043783          	ld	a5,-512(s0)
    800049f4:	6388                	ld	a0,0(a5)
    800049f6:	c545                	beqz	a0,80004a9e <kexec+0x2b6>
  sp = sz;
    800049f8:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    800049fa:	4481                	li	s1,0
    ustack[argc] = sp;
    800049fc:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004a00:	c32fc0ef          	jal	80000e32 <strlen>
    80004a04:	0015079b          	addiw	a5,a0,1
    80004a08:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a0c:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004a10:	134c6563          	bltu	s8,s4,80004b3a <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a14:	e0043d03          	ld	s10,-512(s0)
    80004a18:	000d3c83          	ld	s9,0(s10)
    80004a1c:	8566                	mv	a0,s9
    80004a1e:	c14fc0ef          	jal	80000e32 <strlen>
    80004a22:	0015071b          	addiw	a4,a0,1
    80004a26:	86e6                	mv	a3,s9
    80004a28:	8662                	mv	a2,s8
    80004a2a:	85ca                	mv	a1,s2
    80004a2c:	855a                	mv	a0,s6
    80004a2e:	b15fc0ef          	jal	80001542 <copyout>
    80004a32:	10054663          	bltz	a0,80004b3e <kexec+0x356>
    ustack[argc] = sp;
    80004a36:	00349793          	slli	a5,s1,0x3
    80004a3a:	97de                	add	a5,a5,s7
    80004a3c:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdba00>
  for (argc = 0; argv[argc]; argc++) {
    80004a40:	0485                	addi	s1,s1,1
    80004a42:	008d0793          	addi	a5,s10,8
    80004a46:	e0f43023          	sd	a5,-512(s0)
    80004a4a:	008d3503          	ld	a0,8(s10)
    80004a4e:	f94d                	bnez	a0,80004a00 <kexec+0x218>
  ustack[argc] = 0;
    80004a50:	00349793          	slli	a5,s1,0x3
    80004a54:	f9078793          	addi	a5,a5,-112
    80004a58:	97a2                	add	a5,a5,s0
    80004a5a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004a5e:	00349713          	slli	a4,s1,0x3
    80004a62:	0721                	addi	a4,a4,8
    80004a64:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004a68:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004a6c:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004a6e:	f54be8e3          	bltu	s7,s4,800049be <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004a72:	e9040693          	addi	a3,s0,-368
    80004a76:	865e                	mv	a2,s7
    80004a78:	85ca                	mv	a1,s2
    80004a7a:	855a                	mv	a0,s6
    80004a7c:	ac7fc0ef          	jal	80001542 <copyout>
    80004a80:	f2054fe3          	bltz	a0,800049be <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004a84:	0589b783          	ld	a5,88(s3)
    80004a88:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004a8c:	df043783          	ld	a5,-528(s0)
    80004a90:	0007c703          	lbu	a4,0(a5)
    80004a94:	c30d                	beqz	a4,80004ab6 <kexec+0x2ce>
    80004a96:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004a98:	02f00693          	li	a3,47
    80004a9c:	a801                	j	80004aac <kexec+0x2c4>
  sp = sz;
    80004a9e:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004aa0:	4481                	li	s1,0
    80004aa2:	b77d                	j	80004a50 <kexec+0x268>
  for (last = s = path; *s; s++)
    80004aa4:	0785                	addi	a5,a5,1
    80004aa6:	fff7c703          	lbu	a4,-1(a5)
    80004aaa:	c711                	beqz	a4,80004ab6 <kexec+0x2ce>
    if (*s == '/')
    80004aac:	fed71ce3          	bne	a4,a3,80004aa4 <kexec+0x2bc>
      last = s + 1;
    80004ab0:	def43823          	sd	a5,-528(s0)
    80004ab4:	bfc5                	j	80004aa4 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ab6:	4641                	li	a2,16
    80004ab8:	df043583          	ld	a1,-528(s0)
    80004abc:	15898513          	addi	a0,s3,344
    80004ac0:	b3cfc0ef          	jal	80000dfc <safestrcpy>
  oldpagetable = p->pagetable;
    80004ac4:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004ac8:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004acc:	0529b423          	sd	s2,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ad0:	0589b783          	ld	a5,88(s3)
    80004ad4:	e6843703          	ld	a4,-408(s0)
    80004ad8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004ada:	0589b783          	ld	a5,88(s3)
    80004ade:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ae2:	85d6                	mv	a1,s5
    80004ae4:	faffc0ef          	jal	80001a92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ae8:	0004851b          	sext.w	a0,s1
    80004aec:	79fe                	ld	s3,504(sp)
    80004aee:	7a5e                	ld	s4,496(sp)
    80004af0:	7abe                	ld	s5,488(sp)
    80004af2:	7b1e                	ld	s6,480(sp)
    80004af4:	6bfe                	ld	s7,472(sp)
    80004af6:	6c5e                	ld	s8,464(sp)
    80004af8:	6cbe                	ld	s9,456(sp)
    80004afa:	6d1e                	ld	s10,448(sp)
    80004afc:	bbb9                	j	8000485a <kexec+0x72>
    80004afe:	7b1e                	ld	s6,480(sp)
    80004b00:	b3b1                	j	8000484c <kexec+0x64>
    80004b02:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004b06:	df843583          	ld	a1,-520(s0)
    80004b0a:	855a                	mv	a0,s6
    80004b0c:	f87fc0ef          	jal	80001a92 <proc_freepagetable>
  if (ip) {
    80004b10:	79fe                	ld	s3,504(sp)
    80004b12:	7abe                	ld	s5,488(sp)
    80004b14:	7b1e                	ld	s6,480(sp)
    80004b16:	6bfe                	ld	s7,472(sp)
    80004b18:	6c5e                	ld	s8,464(sp)
    80004b1a:	6cbe                	ld	s9,456(sp)
    80004b1c:	6d1e                	ld	s10,448(sp)
    80004b1e:	7dfa                	ld	s11,440(sp)
    80004b20:	b335                	j	8000484c <kexec+0x64>
    80004b22:	df243c23          	sd	s2,-520(s0)
    80004b26:	b7c5                	j	80004b06 <kexec+0x31e>
    80004b28:	df243c23          	sd	s2,-520(s0)
    80004b2c:	bfe9                	j	80004b06 <kexec+0x31e>
    80004b2e:	df243c23          	sd	s2,-520(s0)
    80004b32:	bfd1                	j	80004b06 <kexec+0x31e>
    80004b34:	df243c23          	sd	s2,-520(s0)
    80004b38:	b7f9                	j	80004b06 <kexec+0x31e>
  sz = sz1;
    80004b3a:	8c4a                	mv	s8,s2
    80004b3c:	b549                	j	800049be <kexec+0x1d6>
    80004b3e:	8c4a                	mv	s8,s2
    80004b40:	bdbd                	j	800049be <kexec+0x1d6>

0000000080004b42 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b42:	7179                	addi	sp,sp,-48
    80004b44:	f406                	sd	ra,40(sp)
    80004b46:	f022                	sd	s0,32(sp)
    80004b48:	ec26                	sd	s1,24(sp)
    80004b4a:	e84a                	sd	s2,16(sp)
    80004b4c:	1800                	addi	s0,sp,48
    80004b4e:	892e                	mv	s2,a1
    80004b50:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b52:	fdc40593          	addi	a1,s0,-36
    80004b56:	cfbfd0ef          	jal	80002850 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004b5a:	fdc42703          	lw	a4,-36(s0)
    80004b5e:	47bd                	li	a5,15
    80004b60:	02e7ea63          	bltu	a5,a4,80004b94 <argfd+0x52>
    80004b64:	da5fc0ef          	jal	80001908 <myproc>
    80004b68:	fdc42703          	lw	a4,-36(s0)
    80004b6c:	00371793          	slli	a5,a4,0x3
    80004b70:	0d078793          	addi	a5,a5,208
    80004b74:	953e                	add	a0,a0,a5
    80004b76:	611c                	ld	a5,0(a0)
    80004b78:	c385                	beqz	a5,80004b98 <argfd+0x56>
    return -1;
  if (pfd)
    80004b7a:	00090463          	beqz	s2,80004b82 <argfd+0x40>
    *pfd = fd;
    80004b7e:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004b82:	4501                	li	a0,0
  if (pf)
    80004b84:	c091                	beqz	s1,80004b88 <argfd+0x46>
    *pf = f;
    80004b86:	e09c                	sd	a5,0(s1)
}
    80004b88:	70a2                	ld	ra,40(sp)
    80004b8a:	7402                	ld	s0,32(sp)
    80004b8c:	64e2                	ld	s1,24(sp)
    80004b8e:	6942                	ld	s2,16(sp)
    80004b90:	6145                	addi	sp,sp,48
    80004b92:	8082                	ret
    return -1;
    80004b94:	557d                	li	a0,-1
    80004b96:	bfcd                	j	80004b88 <argfd+0x46>
    80004b98:	557d                	li	a0,-1
    80004b9a:	b7fd                	j	80004b88 <argfd+0x46>

0000000080004b9c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b9c:	1101                	addi	sp,sp,-32
    80004b9e:	ec06                	sd	ra,24(sp)
    80004ba0:	e822                	sd	s0,16(sp)
    80004ba2:	e426                	sd	s1,8(sp)
    80004ba4:	1000                	addi	s0,sp,32
    80004ba6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ba8:	d61fc0ef          	jal	80001908 <myproc>
    80004bac:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004bae:	0d050793          	addi	a5,a0,208
    80004bb2:	4501                	li	a0,0
    80004bb4:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004bb6:	6398                	ld	a4,0(a5)
    80004bb8:	cb19                	beqz	a4,80004bce <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004bba:	2505                	addiw	a0,a0,1
    80004bbc:	07a1                	addi	a5,a5,8
    80004bbe:	fed51ce3          	bne	a0,a3,80004bb6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bc2:	557d                	li	a0,-1
}
    80004bc4:	60e2                	ld	ra,24(sp)
    80004bc6:	6442                	ld	s0,16(sp)
    80004bc8:	64a2                	ld	s1,8(sp)
    80004bca:	6105                	addi	sp,sp,32
    80004bcc:	8082                	ret
      p->ofile[fd] = f;
    80004bce:	00351793          	slli	a5,a0,0x3
    80004bd2:	0d078793          	addi	a5,a5,208
    80004bd6:	963e                	add	a2,a2,a5
    80004bd8:	e204                	sd	s1,0(a2)
      return fd;
    80004bda:	b7ed                	j	80004bc4 <fdalloc+0x28>

0000000080004bdc <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004bdc:	715d                	addi	sp,sp,-80
    80004bde:	e486                	sd	ra,72(sp)
    80004be0:	e0a2                	sd	s0,64(sp)
    80004be2:	fc26                	sd	s1,56(sp)
    80004be4:	f84a                	sd	s2,48(sp)
    80004be6:	f052                	sd	s4,32(sp)
    80004be8:	ec56                	sd	s5,24(sp)
    80004bea:	e85a                	sd	s6,16(sp)
    80004bec:	0880                	addi	s0,sp,80
    80004bee:	8a2e                	mv	s4,a1
    80004bf0:	8ab2                	mv	s5,a2
    80004bf2:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004bf4:	fb040593          	addi	a1,s0,-80
    80004bf8:	ed9fe0ef          	jal	80003ad0 <nameiparent>
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	12050f63          	beqz	a0,80004d3c <create+0x160>
    return 0;

  ilock(dp);
    80004c02:	e28fe0ef          	jal	8000322a <ilock>

  if (dp->nlink == 0) {
    80004c06:	04a49783          	lh	a5,74(s1)
    80004c0a:	cbb9                	beqz	a5,80004c60 <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c0c:	7761                	lui	a4,0xffff8
    80004c0e:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4a01>
    80004c10:	97ba                	add	a5,a5,a4
    80004c12:	e781                	bnez	a5,80004c1a <create+0x3e>
    80004c14:	fffa0793          	addi	a5,s4,-1
    80004c18:	cba9                	beqz	a5,80004c6a <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c1a:	4601                	li	a2,0
    80004c1c:	fb040593          	addi	a1,s0,-80
    80004c20:	8526                	mv	a0,s1
    80004c22:	bf1fe0ef          	jal	80003812 <dirlookup>
    80004c26:	892a                	mv	s2,a0
    80004c28:	c939                	beqz	a0,80004c7e <create+0xa2>
    iunlockput(dp);
    80004c2a:	8526                	mv	a0,s1
    80004c2c:	853fe0ef          	jal	8000347e <iunlockput>
    ilock(ip);
    80004c30:	854a                	mv	a0,s2
    80004c32:	df8fe0ef          	jal	8000322a <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c36:	4789                	li	a5,2
    80004c38:	02fa1e63          	bne	s4,a5,80004c74 <create+0x98>
    80004c3c:	04495783          	lhu	a5,68(s2)
    80004c40:	37f9                	addiw	a5,a5,-2
    80004c42:	17c2                	slli	a5,a5,0x30
    80004c44:	93c1                	srli	a5,a5,0x30
    80004c46:	4705                	li	a4,1
    80004c48:	02f76663          	bltu	a4,a5,80004c74 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c4c:	854a                	mv	a0,s2
    80004c4e:	60a6                	ld	ra,72(sp)
    80004c50:	6406                	ld	s0,64(sp)
    80004c52:	74e2                	ld	s1,56(sp)
    80004c54:	7942                	ld	s2,48(sp)
    80004c56:	7a02                	ld	s4,32(sp)
    80004c58:	6ae2                	ld	s5,24(sp)
    80004c5a:	6b42                	ld	s6,16(sp)
    80004c5c:	6161                	addi	sp,sp,80
    80004c5e:	8082                	ret
    iunlockput(dp);
    80004c60:	8526                	mv	a0,s1
    80004c62:	81dfe0ef          	jal	8000347e <iunlockput>
    return 0;
    80004c66:	4901                	li	s2,0
    80004c68:	b7d5                	j	80004c4c <create+0x70>
    iunlockput(dp);
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	813fe0ef          	jal	8000347e <iunlockput>
    return 0;
    80004c70:	4901                	li	s2,0
    80004c72:	bfe9                	j	80004c4c <create+0x70>
    iunlockput(ip);
    80004c74:	854a                	mv	a0,s2
    80004c76:	809fe0ef          	jal	8000347e <iunlockput>
    return 0;
    80004c7a:	4901                	li	s2,0
    80004c7c:	bfc1                	j	80004c4c <create+0x70>
    80004c7e:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004c80:	85d2                	mv	a1,s4
    80004c82:	4088                	lw	a0,0(s1)
    80004c84:	c36fe0ef          	jal	800030ba <ialloc>
    80004c88:	89aa                	mv	s3,a0
    80004c8a:	cd1d                	beqz	a0,80004cc8 <create+0xec>
  ilock(ip);
    80004c8c:	d9efe0ef          	jal	8000322a <ilock>
  ip->major = major;
    80004c90:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004c94:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004c98:	4705                	li	a4,1
    80004c9a:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004c9e:	854e                	mv	a0,s3
    80004ca0:	cd6fe0ef          	jal	80003176 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004ca4:	4705                	li	a4,1
    80004ca6:	02ea0763          	beq	s4,a4,80004cd4 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004caa:	0049a603          	lw	a2,4(s3)
    80004cae:	fb040593          	addi	a1,s0,-80
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	d59fe0ef          	jal	80003a0c <dirlink>
    80004cb8:	06054563          	bltz	a0,80004d22 <create+0x146>
  iunlockput(dp);
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	fc0fe0ef          	jal	8000347e <iunlockput>
  return ip;
    80004cc2:	894e                	mv	s2,s3
    80004cc4:	79a2                	ld	s3,40(sp)
    80004cc6:	b759                	j	80004c4c <create+0x70>
    iunlockput(dp);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	fb4fe0ef          	jal	8000347e <iunlockput>
    return 0;
    80004cce:	894e                	mv	s2,s3
    80004cd0:	79a2                	ld	s3,40(sp)
    80004cd2:	bfad                	j	80004c4c <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004cd4:	0049a603          	lw	a2,4(s3)
    80004cd8:	00003597          	auipc	a1,0x3
    80004cdc:	90858593          	addi	a1,a1,-1784 # 800075e0 <etext+0x5e0>
    80004ce0:	854e                	mv	a0,s3
    80004ce2:	d2bfe0ef          	jal	80003a0c <dirlink>
    80004ce6:	02054e63          	bltz	a0,80004d22 <create+0x146>
    80004cea:	40d0                	lw	a2,4(s1)
    80004cec:	00003597          	auipc	a1,0x3
    80004cf0:	8fc58593          	addi	a1,a1,-1796 # 800075e8 <etext+0x5e8>
    80004cf4:	854e                	mv	a0,s3
    80004cf6:	d17fe0ef          	jal	80003a0c <dirlink>
    80004cfa:	02054463          	bltz	a0,80004d22 <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004cfe:	0049a603          	lw	a2,4(s3)
    80004d02:	fb040593          	addi	a1,s0,-80
    80004d06:	8526                	mv	a0,s1
    80004d08:	d05fe0ef          	jal	80003a0c <dirlink>
    80004d0c:	00054b63          	bltz	a0,80004d22 <create+0x146>
    dp->nlink++; // for ".."
    80004d10:	04a4d783          	lhu	a5,74(s1)
    80004d14:	2785                	addiw	a5,a5,1
    80004d16:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d1a:	8526                	mv	a0,s1
    80004d1c:	c5afe0ef          	jal	80003176 <iupdate>
    80004d20:	bf71                	j	80004cbc <create+0xe0>
  ip->nlink = 0;
    80004d22:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004d26:	854e                	mv	a0,s3
    80004d28:	c4efe0ef          	jal	80003176 <iupdate>
  iunlockput(ip);
    80004d2c:	854e                	mv	a0,s3
    80004d2e:	f50fe0ef          	jal	8000347e <iunlockput>
  iunlockput(dp);
    80004d32:	8526                	mv	a0,s1
    80004d34:	f4afe0ef          	jal	8000347e <iunlockput>
  return 0;
    80004d38:	79a2                	ld	s3,40(sp)
    80004d3a:	bf09                	j	80004c4c <create+0x70>
    return 0;
    80004d3c:	892a                	mv	s2,a0
    80004d3e:	b739                	j	80004c4c <create+0x70>

0000000080004d40 <sys_dup>:
{
    80004d40:	7179                	addi	sp,sp,-48
    80004d42:	f406                	sd	ra,40(sp)
    80004d44:	f022                	sd	s0,32(sp)
    80004d46:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004d48:	fd840613          	addi	a2,s0,-40
    80004d4c:	4581                	li	a1,0
    80004d4e:	4501                	li	a0,0
    80004d50:	df3ff0ef          	jal	80004b42 <argfd>
    return -1;
    80004d54:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004d56:	02054363          	bltz	a0,80004d7c <sys_dup+0x3c>
    80004d5a:	ec26                	sd	s1,24(sp)
    80004d5c:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004d5e:	fd843483          	ld	s1,-40(s0)
    80004d62:	8526                	mv	a0,s1
    80004d64:	e39ff0ef          	jal	80004b9c <fdalloc>
    80004d68:	892a                	mv	s2,a0
    return -1;
    80004d6a:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004d6c:	00054d63          	bltz	a0,80004d86 <sys_dup+0x46>
  filedup(f);
    80004d70:	8526                	mv	a0,s1
    80004d72:	b96ff0ef          	jal	80004108 <filedup>
  return fd;
    80004d76:	87ca                	mv	a5,s2
    80004d78:	64e2                	ld	s1,24(sp)
    80004d7a:	6942                	ld	s2,16(sp)
}
    80004d7c:	853e                	mv	a0,a5
    80004d7e:	70a2                	ld	ra,40(sp)
    80004d80:	7402                	ld	s0,32(sp)
    80004d82:	6145                	addi	sp,sp,48
    80004d84:	8082                	ret
    80004d86:	64e2                	ld	s1,24(sp)
    80004d88:	6942                	ld	s2,16(sp)
    80004d8a:	bfcd                	j	80004d7c <sys_dup+0x3c>

0000000080004d8c <sys_read>:
{
    80004d8c:	7179                	addi	sp,sp,-48
    80004d8e:	f406                	sd	ra,40(sp)
    80004d90:	f022                	sd	s0,32(sp)
    80004d92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d94:	fd840593          	addi	a1,s0,-40
    80004d98:	4505                	li	a0,1
    80004d9a:	ad3fd0ef          	jal	8000286c <argaddr>
  argint(2, &n);
    80004d9e:	fe440593          	addi	a1,s0,-28
    80004da2:	4509                	li	a0,2
    80004da4:	aadfd0ef          	jal	80002850 <argint>
  if (argfd(0, 0, &f) < 0)
    80004da8:	fe840613          	addi	a2,s0,-24
    80004dac:	4581                	li	a1,0
    80004dae:	4501                	li	a0,0
    80004db0:	d93ff0ef          	jal	80004b42 <argfd>
    80004db4:	87aa                	mv	a5,a0
    return -1;
    80004db6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004db8:	0007ca63          	bltz	a5,80004dcc <sys_read+0x40>
  return fileread(f, p, n);
    80004dbc:	fe442603          	lw	a2,-28(s0)
    80004dc0:	fd843583          	ld	a1,-40(s0)
    80004dc4:	fe843503          	ld	a0,-24(s0)
    80004dc8:	caeff0ef          	jal	80004276 <fileread>
}
    80004dcc:	70a2                	ld	ra,40(sp)
    80004dce:	7402                	ld	s0,32(sp)
    80004dd0:	6145                	addi	sp,sp,48
    80004dd2:	8082                	ret

0000000080004dd4 <sys_write>:
{
    80004dd4:	7179                	addi	sp,sp,-48
    80004dd6:	f406                	sd	ra,40(sp)
    80004dd8:	f022                	sd	s0,32(sp)
    80004dda:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ddc:	fd840593          	addi	a1,s0,-40
    80004de0:	4505                	li	a0,1
    80004de2:	a8bfd0ef          	jal	8000286c <argaddr>
  argint(2, &n);
    80004de6:	fe440593          	addi	a1,s0,-28
    80004dea:	4509                	li	a0,2
    80004dec:	a65fd0ef          	jal	80002850 <argint>
  if (argfd(0, 0, &f) < 0)
    80004df0:	fe840613          	addi	a2,s0,-24
    80004df4:	4581                	li	a1,0
    80004df6:	4501                	li	a0,0
    80004df8:	d4bff0ef          	jal	80004b42 <argfd>
    80004dfc:	87aa                	mv	a5,a0
    return -1;
    80004dfe:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e00:	0007ca63          	bltz	a5,80004e14 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e04:	fe442603          	lw	a2,-28(s0)
    80004e08:	fd843583          	ld	a1,-40(s0)
    80004e0c:	fe843503          	ld	a0,-24(s0)
    80004e10:	d34ff0ef          	jal	80004344 <filewrite>
}
    80004e14:	70a2                	ld	ra,40(sp)
    80004e16:	7402                	ld	s0,32(sp)
    80004e18:	6145                	addi	sp,sp,48
    80004e1a:	8082                	ret

0000000080004e1c <sys_close>:
{
    80004e1c:	1101                	addi	sp,sp,-32
    80004e1e:	ec06                	sd	ra,24(sp)
    80004e20:	e822                	sd	s0,16(sp)
    80004e22:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004e24:	fe040613          	addi	a2,s0,-32
    80004e28:	fec40593          	addi	a1,s0,-20
    80004e2c:	4501                	li	a0,0
    80004e2e:	d15ff0ef          	jal	80004b42 <argfd>
    return -1;
    80004e32:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004e34:	02054163          	bltz	a0,80004e56 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004e38:	ad1fc0ef          	jal	80001908 <myproc>
    80004e3c:	fec42783          	lw	a5,-20(s0)
    80004e40:	078e                	slli	a5,a5,0x3
    80004e42:	0d078793          	addi	a5,a5,208
    80004e46:	953e                	add	a0,a0,a5
    80004e48:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e4c:	fe043503          	ld	a0,-32(s0)
    80004e50:	afeff0ef          	jal	8000414e <fileclose>
  return 0;
    80004e54:	4781                	li	a5,0
}
    80004e56:	853e                	mv	a0,a5
    80004e58:	60e2                	ld	ra,24(sp)
    80004e5a:	6442                	ld	s0,16(sp)
    80004e5c:	6105                	addi	sp,sp,32
    80004e5e:	8082                	ret

0000000080004e60 <sys_fstat>:
{
    80004e60:	1101                	addi	sp,sp,-32
    80004e62:	ec06                	sd	ra,24(sp)
    80004e64:	e822                	sd	s0,16(sp)
    80004e66:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e68:	fe040593          	addi	a1,s0,-32
    80004e6c:	4505                	li	a0,1
    80004e6e:	9fffd0ef          	jal	8000286c <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004e72:	fe840613          	addi	a2,s0,-24
    80004e76:	4581                	li	a1,0
    80004e78:	4501                	li	a0,0
    80004e7a:	cc9ff0ef          	jal	80004b42 <argfd>
    80004e7e:	87aa                	mv	a5,a0
    return -1;
    80004e80:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e82:	0007c863          	bltz	a5,80004e92 <sys_fstat+0x32>
  return filestat(f, st);
    80004e86:	fe043583          	ld	a1,-32(s0)
    80004e8a:	fe843503          	ld	a0,-24(s0)
    80004e8e:	b82ff0ef          	jal	80004210 <filestat>
}
    80004e92:	60e2                	ld	ra,24(sp)
    80004e94:	6442                	ld	s0,16(sp)
    80004e96:	6105                	addi	sp,sp,32
    80004e98:	8082                	ret

0000000080004e9a <sys_link>:
{
    80004e9a:	7169                	addi	sp,sp,-304
    80004e9c:	f606                	sd	ra,296(sp)
    80004e9e:	f222                	sd	s0,288(sp)
    80004ea0:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ea2:	08000613          	li	a2,128
    80004ea6:	ed040593          	addi	a1,s0,-304
    80004eaa:	4501                	li	a0,0
    80004eac:	9ddfd0ef          	jal	80002888 <argstr>
    return -1;
    80004eb0:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eb2:	10054163          	bltz	a0,80004fb4 <sys_link+0x11a>
    80004eb6:	08000613          	li	a2,128
    80004eba:	f5040593          	addi	a1,s0,-176
    80004ebe:	4505                	li	a0,1
    80004ec0:	9c9fd0ef          	jal	80002888 <argstr>
    return -1;
    80004ec4:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ec6:	0e054763          	bltz	a0,80004fb4 <sys_link+0x11a>
    80004eca:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ecc:	dc9fe0ef          	jal	80003c94 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004ed0:	ed040513          	addi	a0,s0,-304
    80004ed4:	be3fe0ef          	jal	80003ab6 <namei>
    80004ed8:	84aa                	mv	s1,a0
    80004eda:	cd35                	beqz	a0,80004f56 <sys_link+0xbc>
  ilock(ip);
    80004edc:	b4efe0ef          	jal	8000322a <ilock>
  if (ip->type == T_DIR) {
    80004ee0:	04449703          	lh	a4,68(s1)
    80004ee4:	4785                	li	a5,1
    80004ee6:	06f70d63          	beq	a4,a5,80004f60 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004eea:	04a49783          	lh	a5,74(s1)
    80004eee:	6721                	lui	a4,0x8
    80004ef0:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004ef2:	06e78f63          	beq	a5,a4,80004f70 <sys_link+0xd6>
    80004ef6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ef8:	2785                	addiw	a5,a5,1
    80004efa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004efe:	8526                	mv	a0,s1
    80004f00:	a76fe0ef          	jal	80003176 <iupdate>
  iunlock(ip);
    80004f04:	8526                	mv	a0,s1
    80004f06:	bd2fe0ef          	jal	800032d8 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f0a:	fd040593          	addi	a1,s0,-48
    80004f0e:	f5040513          	addi	a0,s0,-176
    80004f12:	bbffe0ef          	jal	80003ad0 <nameiparent>
    80004f16:	892a                	mv	s2,a0
    80004f18:	c93d                	beqz	a0,80004f8e <sys_link+0xf4>
  ilock(dp);
    80004f1a:	b10fe0ef          	jal	8000322a <ilock>
  if (dp->nlink == 0) {
    80004f1e:	04a91783          	lh	a5,74(s2)
    80004f22:	cfb9                	beqz	a5,80004f80 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004f24:	854a                	mv	a0,s2
    80004f26:	00092703          	lw	a4,0(s2)
    80004f2a:	409c                	lw	a5,0(s1)
    80004f2c:	04f71e63          	bne	a4,a5,80004f88 <sys_link+0xee>
    80004f30:	40d0                	lw	a2,4(s1)
    80004f32:	fd040593          	addi	a1,s0,-48
    80004f36:	ad7fe0ef          	jal	80003a0c <dirlink>
    80004f3a:	04054763          	bltz	a0,80004f88 <sys_link+0xee>
  iunlockput(dp);
    80004f3e:	854a                	mv	a0,s2
    80004f40:	d3efe0ef          	jal	8000347e <iunlockput>
  iput(ip);
    80004f44:	8526                	mv	a0,s1
    80004f46:	c66fe0ef          	jal	800033ac <iput>
  end_op();
    80004f4a:	dd7fe0ef          	jal	80003d20 <end_op>
  return 0;
    80004f4e:	4781                	li	a5,0
    80004f50:	64f2                	ld	s1,280(sp)
    80004f52:	6952                	ld	s2,272(sp)
    80004f54:	a085                	j	80004fb4 <sys_link+0x11a>
    end_op();
    80004f56:	dcbfe0ef          	jal	80003d20 <end_op>
    return -1;
    80004f5a:	57fd                	li	a5,-1
    80004f5c:	64f2                	ld	s1,280(sp)
    80004f5e:	a899                	j	80004fb4 <sys_link+0x11a>
    iunlockput(ip);
    80004f60:	8526                	mv	a0,s1
    80004f62:	d1cfe0ef          	jal	8000347e <iunlockput>
    end_op();
    80004f66:	dbbfe0ef          	jal	80003d20 <end_op>
    return -1;
    80004f6a:	57fd                	li	a5,-1
    80004f6c:	64f2                	ld	s1,280(sp)
    80004f6e:	a099                	j	80004fb4 <sys_link+0x11a>
    iunlockput(ip);
    80004f70:	8526                	mv	a0,s1
    80004f72:	d0cfe0ef          	jal	8000347e <iunlockput>
    end_op();
    80004f76:	dabfe0ef          	jal	80003d20 <end_op>
    return -1;
    80004f7a:	57fd                	li	a5,-1
    80004f7c:	64f2                	ld	s1,280(sp)
    80004f7e:	a81d                	j	80004fb4 <sys_link+0x11a>
    iunlockput(dp);
    80004f80:	854a                	mv	a0,s2
    80004f82:	cfcfe0ef          	jal	8000347e <iunlockput>
    goto bad;
    80004f86:	a021                	j	80004f8e <sys_link+0xf4>
    iunlockput(dp);
    80004f88:	854a                	mv	a0,s2
    80004f8a:	cf4fe0ef          	jal	8000347e <iunlockput>
  ilock(ip);
    80004f8e:	8526                	mv	a0,s1
    80004f90:	a9afe0ef          	jal	8000322a <ilock>
  ip->nlink--;
    80004f94:	04a4d783          	lhu	a5,74(s1)
    80004f98:	37fd                	addiw	a5,a5,-1
    80004f9a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	9d6fe0ef          	jal	80003176 <iupdate>
  iunlockput(ip);
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	cd8fe0ef          	jal	8000347e <iunlockput>
  end_op();
    80004faa:	d77fe0ef          	jal	80003d20 <end_op>
  return -1;
    80004fae:	57fd                	li	a5,-1
    80004fb0:	64f2                	ld	s1,280(sp)
    80004fb2:	6952                	ld	s2,272(sp)
}
    80004fb4:	853e                	mv	a0,a5
    80004fb6:	70b2                	ld	ra,296(sp)
    80004fb8:	7412                	ld	s0,288(sp)
    80004fba:	6155                	addi	sp,sp,304
    80004fbc:	8082                	ret

0000000080004fbe <sys_unlink>:
{
    80004fbe:	7151                	addi	sp,sp,-240
    80004fc0:	f586                	sd	ra,232(sp)
    80004fc2:	f1a2                	sd	s0,224(sp)
    80004fc4:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004fc6:	08000613          	li	a2,128
    80004fca:	f3040593          	addi	a1,s0,-208
    80004fce:	4501                	li	a0,0
    80004fd0:	8b9fd0ef          	jal	80002888 <argstr>
    80004fd4:	14054d63          	bltz	a0,8000512e <sys_unlink+0x170>
    80004fd8:	eda6                	sd	s1,216(sp)
  begin_op();
    80004fda:	cbbfe0ef          	jal	80003c94 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004fde:	fb040593          	addi	a1,s0,-80
    80004fe2:	f3040513          	addi	a0,s0,-208
    80004fe6:	aebfe0ef          	jal	80003ad0 <nameiparent>
    80004fea:	84aa                	mv	s1,a0
    80004fec:	c955                	beqz	a0,800050a0 <sys_unlink+0xe2>
  ilock(dp);
    80004fee:	a3cfe0ef          	jal	8000322a <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ff2:	00002597          	auipc	a1,0x2
    80004ff6:	5ee58593          	addi	a1,a1,1518 # 800075e0 <etext+0x5e0>
    80004ffa:	fb040513          	addi	a0,s0,-80
    80004ffe:	ffefe0ef          	jal	800037fc <namecmp>
    80005002:	10050b63          	beqz	a0,80005118 <sys_unlink+0x15a>
    80005006:	00002597          	auipc	a1,0x2
    8000500a:	5e258593          	addi	a1,a1,1506 # 800075e8 <etext+0x5e8>
    8000500e:	fb040513          	addi	a0,s0,-80
    80005012:	feafe0ef          	jal	800037fc <namecmp>
    80005016:	10050163          	beqz	a0,80005118 <sys_unlink+0x15a>
    8000501a:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000501c:	f2c40613          	addi	a2,s0,-212
    80005020:	fb040593          	addi	a1,s0,-80
    80005024:	8526                	mv	a0,s1
    80005026:	fecfe0ef          	jal	80003812 <dirlookup>
    8000502a:	892a                	mv	s2,a0
    8000502c:	0e050563          	beqz	a0,80005116 <sys_unlink+0x158>
    80005030:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005032:	9f8fe0ef          	jal	8000322a <ilock>
  if (ip->nlink < 1)
    80005036:	04a91783          	lh	a5,74(s2)
    8000503a:	06f05863          	blez	a5,800050aa <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000503e:	04491703          	lh	a4,68(s2)
    80005042:	4785                	li	a5,1
    80005044:	06f70963          	beq	a4,a5,800050b6 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005048:	fc040993          	addi	s3,s0,-64
    8000504c:	4641                	li	a2,16
    8000504e:	4581                	li	a1,0
    80005050:	854e                	mv	a0,s3
    80005052:	c57fb0ef          	jal	80000ca8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005056:	4741                	li	a4,16
    80005058:	f2c42683          	lw	a3,-212(s0)
    8000505c:	864e                	mv	a2,s3
    8000505e:	4581                	li	a1,0
    80005060:	8526                	mv	a0,s1
    80005062:	e94fe0ef          	jal	800036f6 <writei>
    80005066:	47c1                	li	a5,16
    80005068:	08f51863          	bne	a0,a5,800050f8 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    8000506c:	04491703          	lh	a4,68(s2)
    80005070:	4785                	li	a5,1
    80005072:	08f70963          	beq	a4,a5,80005104 <sys_unlink+0x146>
  iunlockput(dp);
    80005076:	8526                	mv	a0,s1
    80005078:	c06fe0ef          	jal	8000347e <iunlockput>
  ip->nlink--;
    8000507c:	04a95783          	lhu	a5,74(s2)
    80005080:	37fd                	addiw	a5,a5,-1
    80005082:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005086:	854a                	mv	a0,s2
    80005088:	8eefe0ef          	jal	80003176 <iupdate>
  iunlockput(ip);
    8000508c:	854a                	mv	a0,s2
    8000508e:	bf0fe0ef          	jal	8000347e <iunlockput>
  end_op();
    80005092:	c8ffe0ef          	jal	80003d20 <end_op>
  return 0;
    80005096:	4501                	li	a0,0
    80005098:	64ee                	ld	s1,216(sp)
    8000509a:	694e                	ld	s2,208(sp)
    8000509c:	69ae                	ld	s3,200(sp)
    8000509e:	a061                	j	80005126 <sys_unlink+0x168>
    end_op();
    800050a0:	c81fe0ef          	jal	80003d20 <end_op>
    return -1;
    800050a4:	557d                	li	a0,-1
    800050a6:	64ee                	ld	s1,216(sp)
    800050a8:	a8bd                	j	80005126 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800050aa:	00002517          	auipc	a0,0x2
    800050ae:	54650513          	addi	a0,a0,1350 # 800075f0 <etext+0x5f0>
    800050b2:	f82fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800050b6:	04c92703          	lw	a4,76(s2)
    800050ba:	02000793          	li	a5,32
    800050be:	f8e7f5e3          	bgeu	a5,a4,80005048 <sys_unlink+0x8a>
    800050c2:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050c4:	4741                	li	a4,16
    800050c6:	86ce                	mv	a3,s3
    800050c8:	f1840613          	addi	a2,s0,-232
    800050cc:	4581                	li	a1,0
    800050ce:	854a                	mv	a0,s2
    800050d0:	d34fe0ef          	jal	80003604 <readi>
    800050d4:	47c1                	li	a5,16
    800050d6:	00f51b63          	bne	a0,a5,800050ec <sys_unlink+0x12e>
    if (de.inum != 0)
    800050da:	f1845783          	lhu	a5,-232(s0)
    800050de:	ebb1                	bnez	a5,80005132 <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    800050e0:	29c1                	addiw	s3,s3,16
    800050e2:	04c92783          	lw	a5,76(s2)
    800050e6:	fcf9efe3          	bltu	s3,a5,800050c4 <sys_unlink+0x106>
    800050ea:	bfb9                	j	80005048 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800050ec:	00002517          	auipc	a0,0x2
    800050f0:	51c50513          	addi	a0,a0,1308 # 80007608 <etext+0x608>
    800050f4:	f40fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    800050f8:	00002517          	auipc	a0,0x2
    800050fc:	52850513          	addi	a0,a0,1320 # 80007620 <etext+0x620>
    80005100:	f34fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005104:	04a4d783          	lhu	a5,74(s1)
    80005108:	37fd                	addiw	a5,a5,-1
    8000510a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000510e:	8526                	mv	a0,s1
    80005110:	866fe0ef          	jal	80003176 <iupdate>
    80005114:	b78d                	j	80005076 <sys_unlink+0xb8>
    80005116:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005118:	8526                	mv	a0,s1
    8000511a:	b64fe0ef          	jal	8000347e <iunlockput>
  end_op();
    8000511e:	c03fe0ef          	jal	80003d20 <end_op>
  return -1;
    80005122:	557d                	li	a0,-1
    80005124:	64ee                	ld	s1,216(sp)
}
    80005126:	70ae                	ld	ra,232(sp)
    80005128:	740e                	ld	s0,224(sp)
    8000512a:	616d                	addi	sp,sp,240
    8000512c:	8082                	ret
    return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	bfdd                	j	80005126 <sys_unlink+0x168>
    iunlockput(ip);
    80005132:	854a                	mv	a0,s2
    80005134:	b4afe0ef          	jal	8000347e <iunlockput>
    goto bad;
    80005138:	694e                	ld	s2,208(sp)
    8000513a:	69ae                	ld	s3,200(sp)
    8000513c:	bff1                	j	80005118 <sys_unlink+0x15a>

000000008000513e <sys_open>:

uint64
sys_open(void)
{
    8000513e:	7131                	addi	sp,sp,-192
    80005140:	fd06                	sd	ra,184(sp)
    80005142:	f922                	sd	s0,176(sp)
    80005144:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005146:	f4c40593          	addi	a1,s0,-180
    8000514a:	4505                	li	a0,1
    8000514c:	f04fd0ef          	jal	80002850 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005150:	08000613          	li	a2,128
    80005154:	f5040593          	addi	a1,s0,-176
    80005158:	4501                	li	a0,0
    8000515a:	f2efd0ef          	jal	80002888 <argstr>
    8000515e:	87aa                	mv	a5,a0
    return -1;
    80005160:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005162:	0a07c363          	bltz	a5,80005208 <sys_open+0xca>
    80005166:	f526                	sd	s1,168(sp)

  begin_op();
    80005168:	b2dfe0ef          	jal	80003c94 <begin_op>

  if (omode & O_CREATE) {
    8000516c:	f4c42783          	lw	a5,-180(s0)
    80005170:	2007f793          	andi	a5,a5,512
    80005174:	c3dd                	beqz	a5,8000521a <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005176:	4681                	li	a3,0
    80005178:	4601                	li	a2,0
    8000517a:	4589                	li	a1,2
    8000517c:	f5040513          	addi	a0,s0,-176
    80005180:	a5dff0ef          	jal	80004bdc <create>
    80005184:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005186:	c549                	beqz	a0,80005210 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005188:	04449703          	lh	a4,68(s1)
    8000518c:	478d                	li	a5,3
    8000518e:	00f71763          	bne	a4,a5,8000519c <sys_open+0x5e>
    80005192:	0464d703          	lhu	a4,70(s1)
    80005196:	47a5                	li	a5,9
    80005198:	0ae7ee63          	bltu	a5,a4,80005254 <sys_open+0x116>
    8000519c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000519e:	f0dfe0ef          	jal	800040aa <filealloc>
    800051a2:	892a                	mv	s2,a0
    800051a4:	c561                	beqz	a0,8000526c <sys_open+0x12e>
    800051a6:	ed4e                	sd	s3,152(sp)
    800051a8:	9f5ff0ef          	jal	80004b9c <fdalloc>
    800051ac:	89aa                	mv	s3,a0
    800051ae:	0a054b63          	bltz	a0,80005264 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    800051b2:	04449703          	lh	a4,68(s1)
    800051b6:	478d                	li	a5,3
    800051b8:	0cf70363          	beq	a4,a5,8000527e <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800051bc:	4789                	li	a5,2
    800051be:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800051c2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800051c6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800051ca:	f4c42783          	lw	a5,-180(s0)
    800051ce:	0017f713          	andi	a4,a5,1
    800051d2:	00174713          	xori	a4,a4,1
    800051d6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800051da:	0037f713          	andi	a4,a5,3
    800051de:	00e03733          	snez	a4,a4
    800051e2:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    800051e6:	4007f793          	andi	a5,a5,1024
    800051ea:	c791                	beqz	a5,800051f6 <sys_open+0xb8>
    800051ec:	04449703          	lh	a4,68(s1)
    800051f0:	4789                	li	a5,2
    800051f2:	08f70d63          	beq	a4,a5,8000528c <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800051f6:	8526                	mv	a0,s1
    800051f8:	8e0fe0ef          	jal	800032d8 <iunlock>
  end_op();
    800051fc:	b25fe0ef          	jal	80003d20 <end_op>

  return fd;
    80005200:	854e                	mv	a0,s3
    80005202:	74aa                	ld	s1,168(sp)
    80005204:	790a                	ld	s2,160(sp)
    80005206:	69ea                	ld	s3,152(sp)
}
    80005208:	70ea                	ld	ra,184(sp)
    8000520a:	744a                	ld	s0,176(sp)
    8000520c:	6129                	addi	sp,sp,192
    8000520e:	8082                	ret
      end_op();
    80005210:	b11fe0ef          	jal	80003d20 <end_op>
      return -1;
    80005214:	557d                	li	a0,-1
    80005216:	74aa                	ld	s1,168(sp)
    80005218:	bfc5                	j	80005208 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    8000521a:	f5040513          	addi	a0,s0,-176
    8000521e:	899fe0ef          	jal	80003ab6 <namei>
    80005222:	84aa                	mv	s1,a0
    80005224:	c11d                	beqz	a0,8000524a <sys_open+0x10c>
    ilock(ip);
    80005226:	804fe0ef          	jal	8000322a <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    8000522a:	04449703          	lh	a4,68(s1)
    8000522e:	4785                	li	a5,1
    80005230:	f4f71ce3          	bne	a4,a5,80005188 <sys_open+0x4a>
    80005234:	f4c42783          	lw	a5,-180(s0)
    80005238:	d3b5                	beqz	a5,8000519c <sys_open+0x5e>
      iunlockput(ip);
    8000523a:	8526                	mv	a0,s1
    8000523c:	a42fe0ef          	jal	8000347e <iunlockput>
      end_op();
    80005240:	ae1fe0ef          	jal	80003d20 <end_op>
      return -1;
    80005244:	557d                	li	a0,-1
    80005246:	74aa                	ld	s1,168(sp)
    80005248:	b7c1                	j	80005208 <sys_open+0xca>
      end_op();
    8000524a:	ad7fe0ef          	jal	80003d20 <end_op>
      return -1;
    8000524e:	557d                	li	a0,-1
    80005250:	74aa                	ld	s1,168(sp)
    80005252:	bf5d                	j	80005208 <sys_open+0xca>
    iunlockput(ip);
    80005254:	8526                	mv	a0,s1
    80005256:	a28fe0ef          	jal	8000347e <iunlockput>
    end_op();
    8000525a:	ac7fe0ef          	jal	80003d20 <end_op>
    return -1;
    8000525e:	557d                	li	a0,-1
    80005260:	74aa                	ld	s1,168(sp)
    80005262:	b75d                	j	80005208 <sys_open+0xca>
      fileclose(f);
    80005264:	854a                	mv	a0,s2
    80005266:	ee9fe0ef          	jal	8000414e <fileclose>
    8000526a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000526c:	8526                	mv	a0,s1
    8000526e:	a10fe0ef          	jal	8000347e <iunlockput>
    end_op();
    80005272:	aaffe0ef          	jal	80003d20 <end_op>
    return -1;
    80005276:	557d                	li	a0,-1
    80005278:	74aa                	ld	s1,168(sp)
    8000527a:	790a                	ld	s2,160(sp)
    8000527c:	b771                	j	80005208 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000527e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005282:	04649783          	lh	a5,70(s1)
    80005286:	02f91223          	sh	a5,36(s2)
    8000528a:	bf35                	j	800051c6 <sys_open+0x88>
    itrunc(ip);
    8000528c:	8526                	mv	a0,s1
    8000528e:	88afe0ef          	jal	80003318 <itrunc>
    80005292:	b795                	j	800051f6 <sys_open+0xb8>

0000000080005294 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005294:	7175                	addi	sp,sp,-144
    80005296:	e506                	sd	ra,136(sp)
    80005298:	e122                	sd	s0,128(sp)
    8000529a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000529c:	9f9fe0ef          	jal	80003c94 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800052a0:	08000613          	li	a2,128
    800052a4:	f7040593          	addi	a1,s0,-144
    800052a8:	4501                	li	a0,0
    800052aa:	ddefd0ef          	jal	80002888 <argstr>
    800052ae:	02054363          	bltz	a0,800052d4 <sys_mkdir+0x40>
    800052b2:	4681                	li	a3,0
    800052b4:	4601                	li	a2,0
    800052b6:	4585                	li	a1,1
    800052b8:	f7040513          	addi	a0,s0,-144
    800052bc:	921ff0ef          	jal	80004bdc <create>
    800052c0:	c911                	beqz	a0,800052d4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052c2:	9bcfe0ef          	jal	8000347e <iunlockput>
  end_op();
    800052c6:	a5bfe0ef          	jal	80003d20 <end_op>
  return 0;
    800052ca:	4501                	li	a0,0
}
    800052cc:	60aa                	ld	ra,136(sp)
    800052ce:	640a                	ld	s0,128(sp)
    800052d0:	6149                	addi	sp,sp,144
    800052d2:	8082                	ret
    end_op();
    800052d4:	a4dfe0ef          	jal	80003d20 <end_op>
    return -1;
    800052d8:	557d                	li	a0,-1
    800052da:	bfcd                	j	800052cc <sys_mkdir+0x38>

00000000800052dc <sys_mknod>:

uint64
sys_mknod(void)
{
    800052dc:	7135                	addi	sp,sp,-160
    800052de:	ed06                	sd	ra,152(sp)
    800052e0:	e922                	sd	s0,144(sp)
    800052e2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800052e4:	9b1fe0ef          	jal	80003c94 <begin_op>
  argint(1, &major);
    800052e8:	f6c40593          	addi	a1,s0,-148
    800052ec:	4505                	li	a0,1
    800052ee:	d62fd0ef          	jal	80002850 <argint>
  argint(2, &minor);
    800052f2:	f6840593          	addi	a1,s0,-152
    800052f6:	4509                	li	a0,2
    800052f8:	d58fd0ef          	jal	80002850 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800052fc:	08000613          	li	a2,128
    80005300:	f7040593          	addi	a1,s0,-144
    80005304:	4501                	li	a0,0
    80005306:	d82fd0ef          	jal	80002888 <argstr>
    8000530a:	02054563          	bltz	a0,80005334 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000530e:	f6841683          	lh	a3,-152(s0)
    80005312:	f6c41603          	lh	a2,-148(s0)
    80005316:	458d                	li	a1,3
    80005318:	f7040513          	addi	a0,s0,-144
    8000531c:	8c1ff0ef          	jal	80004bdc <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005320:	c911                	beqz	a0,80005334 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005322:	95cfe0ef          	jal	8000347e <iunlockput>
  end_op();
    80005326:	9fbfe0ef          	jal	80003d20 <end_op>
  return 0;
    8000532a:	4501                	li	a0,0
}
    8000532c:	60ea                	ld	ra,152(sp)
    8000532e:	644a                	ld	s0,144(sp)
    80005330:	610d                	addi	sp,sp,160
    80005332:	8082                	ret
    end_op();
    80005334:	9edfe0ef          	jal	80003d20 <end_op>
    return -1;
    80005338:	557d                	li	a0,-1
    8000533a:	bfcd                	j	8000532c <sys_mknod+0x50>

000000008000533c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000533c:	7135                	addi	sp,sp,-160
    8000533e:	ed06                	sd	ra,152(sp)
    80005340:	e922                	sd	s0,144(sp)
    80005342:	e14a                	sd	s2,128(sp)
    80005344:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005346:	dc2fc0ef          	jal	80001908 <myproc>
    8000534a:	892a                	mv	s2,a0

  begin_op();
    8000534c:	949fe0ef          	jal	80003c94 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    80005350:	08000613          	li	a2,128
    80005354:	f6040593          	addi	a1,s0,-160
    80005358:	4501                	li	a0,0
    8000535a:	d2efd0ef          	jal	80002888 <argstr>
    8000535e:	04054363          	bltz	a0,800053a4 <sys_chdir+0x68>
    80005362:	e526                	sd	s1,136(sp)
    80005364:	f6040513          	addi	a0,s0,-160
    80005368:	f4efe0ef          	jal	80003ab6 <namei>
    8000536c:	84aa                	mv	s1,a0
    8000536e:	c915                	beqz	a0,800053a2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005370:	ebbfd0ef          	jal	8000322a <ilock>
  if (ip->type != T_DIR) {
    80005374:	04449703          	lh	a4,68(s1)
    80005378:	4785                	li	a5,1
    8000537a:	02f71963          	bne	a4,a5,800053ac <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000537e:	8526                	mv	a0,s1
    80005380:	f59fd0ef          	jal	800032d8 <iunlock>
  iput(p->cwd);
    80005384:	15093503          	ld	a0,336(s2)
    80005388:	824fe0ef          	jal	800033ac <iput>
  end_op();
    8000538c:	995fe0ef          	jal	80003d20 <end_op>
  p->cwd = ip;
    80005390:	14993823          	sd	s1,336(s2)
  return 0;
    80005394:	4501                	li	a0,0
    80005396:	64aa                	ld	s1,136(sp)
}
    80005398:	60ea                	ld	ra,152(sp)
    8000539a:	644a                	ld	s0,144(sp)
    8000539c:	690a                	ld	s2,128(sp)
    8000539e:	610d                	addi	sp,sp,160
    800053a0:	8082                	ret
    800053a2:	64aa                	ld	s1,136(sp)
    end_op();
    800053a4:	97dfe0ef          	jal	80003d20 <end_op>
    return -1;
    800053a8:	557d                	li	a0,-1
    800053aa:	b7fd                	j	80005398 <sys_chdir+0x5c>
    iunlockput(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	8d0fe0ef          	jal	8000347e <iunlockput>
    end_op();
    800053b2:	96ffe0ef          	jal	80003d20 <end_op>
    return -1;
    800053b6:	557d                	li	a0,-1
    800053b8:	64aa                	ld	s1,136(sp)
    800053ba:	bff9                	j	80005398 <sys_chdir+0x5c>

00000000800053bc <sys_exec>:

uint64
sys_exec(void)
{
    800053bc:	7105                	addi	sp,sp,-480
    800053be:	ef86                	sd	ra,472(sp)
    800053c0:	eba2                	sd	s0,464(sp)
    800053c2:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800053c4:	e2840593          	addi	a1,s0,-472
    800053c8:	4505                	li	a0,1
    800053ca:	ca2fd0ef          	jal	8000286c <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800053ce:	08000613          	li	a2,128
    800053d2:	f3040593          	addi	a1,s0,-208
    800053d6:	4501                	li	a0,0
    800053d8:	cb0fd0ef          	jal	80002888 <argstr>
    800053dc:	87aa                	mv	a5,a0
    return -1;
    800053de:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800053e0:	0e07c063          	bltz	a5,800054c0 <sys_exec+0x104>
    800053e4:	e7a6                	sd	s1,456(sp)
    800053e6:	e3ca                	sd	s2,448(sp)
    800053e8:	ff4e                	sd	s3,440(sp)
    800053ea:	fb52                	sd	s4,432(sp)
    800053ec:	f756                	sd	s5,424(sp)
    800053ee:	f35a                	sd	s6,416(sp)
    800053f0:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800053f2:	e3040a13          	addi	s4,s0,-464
    800053f6:	10000613          	li	a2,256
    800053fa:	4581                	li	a1,0
    800053fc:	8552                	mv	a0,s4
    800053fe:	8abfb0ef          	jal	80000ca8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005402:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005404:	89d2                	mv	s3,s4
    80005406:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005408:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000540c:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    8000540e:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005412:	00391513          	slli	a0,s2,0x3
    80005416:	85d6                	mv	a1,s5
    80005418:	e2843783          	ld	a5,-472(s0)
    8000541c:	953e                	add	a0,a0,a5
    8000541e:	ba6fd0ef          	jal	800027c4 <fetchaddr>
    80005422:	02054663          	bltz	a0,8000544e <sys_exec+0x92>
    if (uarg == 0) {
    80005426:	e2043783          	ld	a5,-480(s0)
    8000542a:	c7a1                	beqz	a5,80005472 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000542c:	ee2fb0ef          	jal	80000b0e <kalloc>
    80005430:	85aa                	mv	a1,a0
    80005432:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005436:	cd01                	beqz	a0,8000544e <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005438:	865a                	mv	a2,s6
    8000543a:	e2043503          	ld	a0,-480(s0)
    8000543e:	bd0fd0ef          	jal	8000280e <fetchstr>
    80005442:	00054663          	bltz	a0,8000544e <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    80005446:	0905                	addi	s2,s2,1
    80005448:	09a1                	addi	s3,s3,8
    8000544a:	fd7914e3          	bne	s2,s7,80005412 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000544e:	100a0a13          	addi	s4,s4,256
    80005452:	6088                	ld	a0,0(s1)
    80005454:	cd31                	beqz	a0,800054b0 <sys_exec+0xf4>
    kfree(argv[i]);
    80005456:	dd0fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000545a:	04a1                	addi	s1,s1,8
    8000545c:	ff449be3          	bne	s1,s4,80005452 <sys_exec+0x96>
  return -1;
    80005460:	557d                	li	a0,-1
    80005462:	64be                	ld	s1,456(sp)
    80005464:	691e                	ld	s2,448(sp)
    80005466:	79fa                	ld	s3,440(sp)
    80005468:	7a5a                	ld	s4,432(sp)
    8000546a:	7aba                	ld	s5,424(sp)
    8000546c:	7b1a                	ld	s6,416(sp)
    8000546e:	6bfa                	ld	s7,408(sp)
    80005470:	a881                	j	800054c0 <sys_exec+0x104>
      argv[i] = 0;
    80005472:	0009079b          	sext.w	a5,s2
    80005476:	e3040593          	addi	a1,s0,-464
    8000547a:	078e                	slli	a5,a5,0x3
    8000547c:	97ae                	add	a5,a5,a1
    8000547e:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005482:	f3040513          	addi	a0,s0,-208
    80005486:	b62ff0ef          	jal	800047e8 <kexec>
    8000548a:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000548c:	100a0a13          	addi	s4,s4,256
    80005490:	6088                	ld	a0,0(s1)
    80005492:	c511                	beqz	a0,8000549e <sys_exec+0xe2>
    kfree(argv[i]);
    80005494:	d92fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005498:	04a1                	addi	s1,s1,8
    8000549a:	ff449be3          	bne	s1,s4,80005490 <sys_exec+0xd4>
  return ret;
    8000549e:	854a                	mv	a0,s2
    800054a0:	64be                	ld	s1,456(sp)
    800054a2:	691e                	ld	s2,448(sp)
    800054a4:	79fa                	ld	s3,440(sp)
    800054a6:	7a5a                	ld	s4,432(sp)
    800054a8:	7aba                	ld	s5,424(sp)
    800054aa:	7b1a                	ld	s6,416(sp)
    800054ac:	6bfa                	ld	s7,408(sp)
    800054ae:	a809                	j	800054c0 <sys_exec+0x104>
  return -1;
    800054b0:	557d                	li	a0,-1
    800054b2:	64be                	ld	s1,456(sp)
    800054b4:	691e                	ld	s2,448(sp)
    800054b6:	79fa                	ld	s3,440(sp)
    800054b8:	7a5a                	ld	s4,432(sp)
    800054ba:	7aba                	ld	s5,424(sp)
    800054bc:	7b1a                	ld	s6,416(sp)
    800054be:	6bfa                	ld	s7,408(sp)
}
    800054c0:	60fe                	ld	ra,472(sp)
    800054c2:	645e                	ld	s0,464(sp)
    800054c4:	613d                	addi	sp,sp,480
    800054c6:	8082                	ret

00000000800054c8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800054c8:	7139                	addi	sp,sp,-64
    800054ca:	fc06                	sd	ra,56(sp)
    800054cc:	f822                	sd	s0,48(sp)
    800054ce:	f426                	sd	s1,40(sp)
    800054d0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800054d2:	c36fc0ef          	jal	80001908 <myproc>
    800054d6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800054d8:	fd840593          	addi	a1,s0,-40
    800054dc:	4501                	li	a0,0
    800054de:	b8efd0ef          	jal	8000286c <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800054e2:	fc840593          	addi	a1,s0,-56
    800054e6:	fd040513          	addi	a0,s0,-48
    800054ea:	f99fe0ef          	jal	80004482 <pipealloc>
    return -1;
    800054ee:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800054f0:	0a054963          	bltz	a0,800055a2 <sys_pipe+0xda>
  fd0 = -1;
    800054f4:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800054f8:	fd043503          	ld	a0,-48(s0)
    800054fc:	ea0ff0ef          	jal	80004b9c <fdalloc>
    80005500:	fca42223          	sw	a0,-60(s0)
    80005504:	08054663          	bltz	a0,80005590 <sys_pipe+0xc8>
    80005508:	fc843503          	ld	a0,-56(s0)
    8000550c:	e90ff0ef          	jal	80004b9c <fdalloc>
    80005510:	fca42023          	sw	a0,-64(s0)
    80005514:	06054463          	bltz	a0,8000557c <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005518:	4711                	li	a4,4
    8000551a:	fc440693          	addi	a3,s0,-60
    8000551e:	fd843603          	ld	a2,-40(s0)
    80005522:	64ac                	ld	a1,72(s1)
    80005524:	68a8                	ld	a0,80(s1)
    80005526:	81cfc0ef          	jal	80001542 <copyout>
    8000552a:	00054f63          	bltz	a0,80005548 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    8000552e:	4711                	li	a4,4
    80005530:	fc040693          	addi	a3,s0,-64
    80005534:	fd843603          	ld	a2,-40(s0)
    80005538:	963a                	add	a2,a2,a4
    8000553a:	64ac                	ld	a1,72(s1)
    8000553c:	68a8                	ld	a0,80(s1)
    8000553e:	804fc0ef          	jal	80001542 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005542:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005544:	04055f63          	bgez	a0,800055a2 <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    80005548:	fc442783          	lw	a5,-60(s0)
    8000554c:	078e                	slli	a5,a5,0x3
    8000554e:	0d078793          	addi	a5,a5,208
    80005552:	97a6                	add	a5,a5,s1
    80005554:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005558:	fc042783          	lw	a5,-64(s0)
    8000555c:	078e                	slli	a5,a5,0x3
    8000555e:	0d078793          	addi	a5,a5,208
    80005562:	94be                	add	s1,s1,a5
    80005564:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005568:	fd043503          	ld	a0,-48(s0)
    8000556c:	be3fe0ef          	jal	8000414e <fileclose>
    fileclose(wf);
    80005570:	fc843503          	ld	a0,-56(s0)
    80005574:	bdbfe0ef          	jal	8000414e <fileclose>
    return -1;
    80005578:	57fd                	li	a5,-1
    8000557a:	a025                	j	800055a2 <sys_pipe+0xda>
    if (fd0 >= 0)
    8000557c:	fc442783          	lw	a5,-60(s0)
    80005580:	0007c863          	bltz	a5,80005590 <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    80005584:	078e                	slli	a5,a5,0x3
    80005586:	0d078793          	addi	a5,a5,208
    8000558a:	97a6                	add	a5,a5,s1
    8000558c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005590:	fd043503          	ld	a0,-48(s0)
    80005594:	bbbfe0ef          	jal	8000414e <fileclose>
    fileclose(wf);
    80005598:	fc843503          	ld	a0,-56(s0)
    8000559c:	bb3fe0ef          	jal	8000414e <fileclose>
    return -1;
    800055a0:	57fd                	li	a5,-1
}
    800055a2:	853e                	mv	a0,a5
    800055a4:	70e2                	ld	ra,56(sp)
    800055a6:	7442                	ld	s0,48(sp)
    800055a8:	74a2                	ld	s1,40(sp)
    800055aa:	6121                	addi	sp,sp,64
    800055ac:	8082                	ret
	...

00000000800055b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800055b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800055b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800055b4:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    800055b6:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800055b8:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800055ba:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800055bc:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800055be:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800055c0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800055c2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800055c4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800055c6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800055c8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800055ca:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800055cc:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800055ce:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800055d0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800055d2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800055d4:	8fefd0ef          	jal	800026d2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800055d8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800055da:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800055dc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800055de:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800055e0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800055e2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800055e4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800055e6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800055e8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800055ea:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800055ec:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800055ee:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800055f0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800055f2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800055f4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800055f6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800055f8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800055fa:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800055fc:	10200073          	sret
    80005600:	0001                	nop
    80005602:	00000013          	nop
    80005606:	00000013          	nop
    8000560a:	00000013          	nop

000000008000560e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000560e:	1141                	addi	sp,sp,-16
    80005610:	e406                	sd	ra,8(sp)
    80005612:	e022                	sd	s0,0(sp)
    80005614:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005616:	0c000737          	lui	a4,0xc000
    8000561a:	4785                	li	a5,1
    8000561c:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000561e:	c35c                	sw	a5,4(a4)
}
    80005620:	60a2                	ld	ra,8(sp)
    80005622:	6402                	ld	s0,0(sp)
    80005624:	0141                	addi	sp,sp,16
    80005626:	8082                	ret

0000000080005628 <plicinithart>:

void
plicinithart(void)
{
    80005628:	1141                	addi	sp,sp,-16
    8000562a:	e406                	sd	ra,8(sp)
    8000562c:	e022                	sd	s0,0(sp)
    8000562e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005630:	aa4fc0ef          	jal	800018d4 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005634:	0085171b          	slliw	a4,a0,0x8
    80005638:	0c0027b7          	lui	a5,0xc002
    8000563c:	97ba                	add	a5,a5,a4
    8000563e:	40200713          	li	a4,1026
    80005642:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005646:	00d5151b          	slliw	a0,a0,0xd
    8000564a:	0c2017b7          	lui	a5,0xc201
    8000564e:	97aa                	add	a5,a5,a0
    80005650:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005654:	60a2                	ld	ra,8(sp)
    80005656:	6402                	ld	s0,0(sp)
    80005658:	0141                	addi	sp,sp,16
    8000565a:	8082                	ret

000000008000565c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000565c:	1141                	addi	sp,sp,-16
    8000565e:	e406                	sd	ra,8(sp)
    80005660:	e022                	sd	s0,0(sp)
    80005662:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005664:	a70fc0ef          	jal	800018d4 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005668:	00d5151b          	slliw	a0,a0,0xd
    8000566c:	0c2017b7          	lui	a5,0xc201
    80005670:	97aa                	add	a5,a5,a0
  return irq;
}
    80005672:	43c8                	lw	a0,4(a5)
    80005674:	60a2                	ld	ra,8(sp)
    80005676:	6402                	ld	s0,0(sp)
    80005678:	0141                	addi	sp,sp,16
    8000567a:	8082                	ret

000000008000567c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000567c:	1101                	addi	sp,sp,-32
    8000567e:	ec06                	sd	ra,24(sp)
    80005680:	e822                	sd	s0,16(sp)
    80005682:	e426                	sd	s1,8(sp)
    80005684:	1000                	addi	s0,sp,32
    80005686:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005688:	a4cfc0ef          	jal	800018d4 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000568c:	00d5179b          	slliw	a5,a0,0xd
    80005690:	0c201737          	lui	a4,0xc201
    80005694:	97ba                	add	a5,a5,a4
    80005696:	c3c4                	sw	s1,4(a5)
}
    80005698:	60e2                	ld	ra,24(sp)
    8000569a:	6442                	ld	s0,16(sp)
    8000569c:	64a2                	ld	s1,8(sp)
    8000569e:	6105                	addi	sp,sp,32
    800056a0:	8082                	ret

00000000800056a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056a2:	1141                	addi	sp,sp,-16
    800056a4:	e406                	sd	ra,8(sp)
    800056a6:	e022                	sd	s0,0(sp)
    800056a8:	0800                	addi	s0,sp,16
  if (i >= NUM)
    800056aa:	479d                	li	a5,7
    800056ac:	04a7ca63          	blt	a5,a0,80005700 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    800056b0:	0001e797          	auipc	a5,0x1e
    800056b4:	e1078793          	addi	a5,a5,-496 # 800234c0 <disk>
    800056b8:	97aa                	add	a5,a5,a0
    800056ba:	0187c783          	lbu	a5,24(a5)
    800056be:	e7b9                	bnez	a5,8000570c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056c0:	00451693          	slli	a3,a0,0x4
    800056c4:	0001e797          	auipc	a5,0x1e
    800056c8:	dfc78793          	addi	a5,a5,-516 # 800234c0 <disk>
    800056cc:	6398                	ld	a4,0(a5)
    800056ce:	9736                	add	a4,a4,a3
    800056d0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800056d4:	6398                	ld	a4,0(a5)
    800056d6:	9736                	add	a4,a4,a3
    800056d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800056dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056e4:	97aa                	add	a5,a5,a0
    800056e6:	4705                	li	a4,1
    800056e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056ec:	0001e517          	auipc	a0,0x1e
    800056f0:	dec50513          	addi	a0,a0,-532 # 800234d8 <disk+0x18>
    800056f4:	88bfc0ef          	jal	80001f7e <wakeup>
}
    800056f8:	60a2                	ld	ra,8(sp)
    800056fa:	6402                	ld	s0,0(sp)
    800056fc:	0141                	addi	sp,sp,16
    800056fe:	8082                	ret
    panic("free_desc 1");
    80005700:	00002517          	auipc	a0,0x2
    80005704:	f3050513          	addi	a0,a0,-208 # 80007630 <etext+0x630>
    80005708:	92cfb0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    8000570c:	00002517          	auipc	a0,0x2
    80005710:	f3450513          	addi	a0,a0,-204 # 80007640 <etext+0x640>
    80005714:	920fb0ef          	jal	80000834 <panic>

0000000080005718 <virtio_disk_init>:
{
    80005718:	1101                	addi	sp,sp,-32
    8000571a:	ec06                	sd	ra,24(sp)
    8000571c:	e822                	sd	s0,16(sp)
    8000571e:	e426                	sd	s1,8(sp)
    80005720:	e04a                	sd	s2,0(sp)
    80005722:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005724:	00002597          	auipc	a1,0x2
    80005728:	f2c58593          	addi	a1,a1,-212 # 80007650 <etext+0x650>
    8000572c:	0001e517          	auipc	a0,0x1e
    80005730:	ebc50513          	addi	a0,a0,-324 # 800235e8 <disk+0x128>
    80005734:	c34fb0ef          	jal	80000b68 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005738:	100017b7          	lui	a5,0x10001
    8000573c:	4398                	lw	a4,0(a5)
    8000573e:	2701                	sext.w	a4,a4
    80005740:	747277b7          	lui	a5,0x74727
    80005744:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005748:	14f71863          	bne	a4,a5,80005898 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000574c:	100017b7          	lui	a5,0x10001
    80005750:	43dc                	lw	a5,4(a5)
    80005752:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005754:	4709                	li	a4,2
    80005756:	14e79163          	bne	a5,a4,80005898 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000575a:	100017b7          	lui	a5,0x10001
    8000575e:	479c                	lw	a5,8(a5)
    80005760:	2781                	sext.w	a5,a5
    80005762:	12e79b63          	bne	a5,a4,80005898 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005766:	100017b7          	lui	a5,0x10001
    8000576a:	47d8                	lw	a4,12(a5)
    8000576c:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000576e:	554d47b7          	lui	a5,0x554d4
    80005772:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005776:	12f71163          	bne	a4,a5,80005898 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000577a:	100017b7          	lui	a5,0x10001
    8000577e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005782:	4705                	li	a4,1
    80005784:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005786:	470d                	li	a4,3
    80005788:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000578a:	10001737          	lui	a4,0x10001
    8000578e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005790:	c7ffe6b7          	lui	a3,0xc7ffe
    80005794:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdaf5f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005798:	8f75                	and	a4,a4,a3
    8000579a:	100016b7          	lui	a3,0x10001
    8000579e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057a0:	472d                	li	a4,11
    800057a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057a4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057a8:	439c                	lw	a5,0(a5)
    800057aa:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057ae:	8ba1                	andi	a5,a5,8
    800057b0:	0e078a63          	beqz	a5,800058a4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057b4:	100017b7          	lui	a5,0x10001
    800057b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800057bc:	43fc                	lw	a5,68(a5)
    800057be:	2781                	sext.w	a5,a5
    800057c0:	0e079863          	bnez	a5,800058b0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800057c4:	100017b7          	lui	a5,0x10001
    800057c8:	5bdc                	lw	a5,52(a5)
    800057ca:	2781                	sext.w	a5,a5
  if (max == 0)
    800057cc:	0e078863          	beqz	a5,800058bc <virtio_disk_init+0x1a4>
  if (max < NUM)
    800057d0:	471d                	li	a4,7
    800057d2:	0ef77b63          	bgeu	a4,a5,800058c8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800057d6:	b38fb0ef          	jal	80000b0e <kalloc>
    800057da:	0001e497          	auipc	s1,0x1e
    800057de:	ce648493          	addi	s1,s1,-794 # 800234c0 <disk>
    800057e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800057e4:	b2afb0ef          	jal	80000b0e <kalloc>
    800057e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800057ea:	b24fb0ef          	jal	80000b0e <kalloc>
    800057ee:	87aa                	mv	a5,a0
    800057f0:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800057f2:	6088                	ld	a0,0(s1)
    800057f4:	0e050063          	beqz	a0,800058d4 <virtio_disk_init+0x1bc>
    800057f8:	0001e717          	auipc	a4,0x1e
    800057fc:	cd073703          	ld	a4,-816(a4) # 800234c8 <disk+0x8>
    80005800:	cb71                	beqz	a4,800058d4 <virtio_disk_init+0x1bc>
    80005802:	cbe9                	beqz	a5,800058d4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005804:	6605                	lui	a2,0x1
    80005806:	4581                	li	a1,0
    80005808:	ca0fb0ef          	jal	80000ca8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000580c:	0001e497          	auipc	s1,0x1e
    80005810:	cb448493          	addi	s1,s1,-844 # 800234c0 <disk>
    80005814:	6605                	lui	a2,0x1
    80005816:	4581                	li	a1,0
    80005818:	6488                	ld	a0,8(s1)
    8000581a:	c8efb0ef          	jal	80000ca8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000581e:	6605                	lui	a2,0x1
    80005820:	4581                	li	a1,0
    80005822:	6888                	ld	a0,16(s1)
    80005824:	c84fb0ef          	jal	80000ca8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005828:	100017b7          	lui	a5,0x10001
    8000582c:	4721                	li	a4,8
    8000582e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005830:	4098                	lw	a4,0(s1)
    80005832:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005836:	40d8                	lw	a4,4(s1)
    80005838:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000583c:	649c                	ld	a5,8(s1)
    8000583e:	0007869b          	sext.w	a3,a5
    80005842:	10001737          	lui	a4,0x10001
    80005846:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000584a:	9781                	srai	a5,a5,0x20
    8000584c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005850:	689c                	ld	a5,16(s1)
    80005852:	0007869b          	sext.w	a3,a5
    80005856:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000585a:	9781                	srai	a5,a5,0x20
    8000585c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005860:	4785                	li	a5,1
    80005862:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005864:	00f48c23          	sb	a5,24(s1)
    80005868:	00f48ca3          	sb	a5,25(s1)
    8000586c:	00f48d23          	sb	a5,26(s1)
    80005870:	00f48da3          	sb	a5,27(s1)
    80005874:	00f48e23          	sb	a5,28(s1)
    80005878:	00f48ea3          	sb	a5,29(s1)
    8000587c:	00f48f23          	sb	a5,30(s1)
    80005880:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005884:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005888:	07272823          	sw	s2,112(a4)
}
    8000588c:	60e2                	ld	ra,24(sp)
    8000588e:	6442                	ld	s0,16(sp)
    80005890:	64a2                	ld	s1,8(sp)
    80005892:	6902                	ld	s2,0(sp)
    80005894:	6105                	addi	sp,sp,32
    80005896:	8082                	ret
    panic("could not find virtio disk");
    80005898:	00002517          	auipc	a0,0x2
    8000589c:	dc850513          	addi	a0,a0,-568 # 80007660 <etext+0x660>
    800058a0:	f95fa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058a4:	00002517          	auipc	a0,0x2
    800058a8:	ddc50513          	addi	a0,a0,-548 # 80007680 <etext+0x680>
    800058ac:	f89fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    800058b0:	00002517          	auipc	a0,0x2
    800058b4:	df050513          	addi	a0,a0,-528 # 800076a0 <etext+0x6a0>
    800058b8:	f7dfa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    800058bc:	00002517          	auipc	a0,0x2
    800058c0:	e0450513          	addi	a0,a0,-508 # 800076c0 <etext+0x6c0>
    800058c4:	f71fa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    800058c8:	00002517          	auipc	a0,0x2
    800058cc:	e1850513          	addi	a0,a0,-488 # 800076e0 <etext+0x6e0>
    800058d0:	f65fa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    800058d4:	00002517          	auipc	a0,0x2
    800058d8:	e2c50513          	addi	a0,a0,-468 # 80007700 <etext+0x700>
    800058dc:	f59fa0ef          	jal	80000834 <panic>

00000000800058e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800058e0:	711d                	addi	sp,sp,-96
    800058e2:	ec86                	sd	ra,88(sp)
    800058e4:	e8a2                	sd	s0,80(sp)
    800058e6:	e4a6                	sd	s1,72(sp)
    800058e8:	e0ca                	sd	s2,64(sp)
    800058ea:	fc4e                	sd	s3,56(sp)
    800058ec:	f852                	sd	s4,48(sp)
    800058ee:	f456                	sd	s5,40(sp)
    800058f0:	f05a                	sd	s6,32(sp)
    800058f2:	ec5e                	sd	s7,24(sp)
    800058f4:	e862                	sd	s8,16(sp)
    800058f6:	1080                	addi	s0,sp,96
    800058f8:	89aa                	mv	s3,a0
    800058fa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800058fc:	00c52b83          	lw	s7,12(a0)
    80005900:	001b9b9b          	slliw	s7,s7,0x1
    80005904:	1b82                	slli	s7,s7,0x20
    80005906:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000590a:	0001e517          	auipc	a0,0x1e
    8000590e:	cde50513          	addi	a0,a0,-802 # 800235e8 <disk+0x128>
    80005912:	ad6fb0ef          	jal	80000be8 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005916:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005918:	0001ea97          	auipc	s5,0x1e
    8000591c:	ba8a8a93          	addi	s5,s5,-1112 # 800234c0 <disk>
  for (int i = 0; i < 3; i++) {
    80005920:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005922:	5c7d                	li	s8,-1
    80005924:	a8a5                	j	8000599c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005926:	00fa8733          	add	a4,s5,a5
    8000592a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000592e:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005930:	0207c563          	bltz	a5,8000595a <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005934:	2905                	addiw	s2,s2,1
    80005936:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005938:	07490663          	beq	s2,s4,800059a4 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    8000593c:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    8000593e:	0001e717          	auipc	a4,0x1e
    80005942:	b8270713          	addi	a4,a4,-1150 # 800234c0 <disk>
    80005946:	4781                	li	a5,0
    if (disk.free[i]) {
    80005948:	01874683          	lbu	a3,24(a4)
    8000594c:	fee9                	bnez	a3,80005926 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    8000594e:	2785                	addiw	a5,a5,1
    80005950:	0705                	addi	a4,a4,1
    80005952:	fe979be3          	bne	a5,s1,80005948 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005956:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    8000595a:	01205d63          	blez	s2,80005974 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000595e:	fa042503          	lw	a0,-96(s0)
    80005962:	d41ff0ef          	jal	800056a2 <free_desc>
      for (int j = 0; j < i; j++)
    80005966:	4785                	li	a5,1
    80005968:	0127d663          	bge	a5,s2,80005974 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000596c:	fa442503          	lw	a0,-92(s0)
    80005970:	d33ff0ef          	jal	800056a2 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005974:	0001e517          	auipc	a0,0x1e
    80005978:	b6450513          	addi	a0,a0,-1180 # 800234d8 <disk+0x18>
    8000597c:	d96fc0ef          	jal	80001f12 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005980:	0001e517          	auipc	a0,0x1e
    80005984:	c6850513          	addi	a0,a0,-920 # 800235e8 <disk+0x128>
    80005988:	ae8fb0ef          	jal	80000c70 <release>
    sleep();
    8000598c:	dc2fc0ef          	jal	80001f4e <sleep>
    acquire(&disk.vdisk_lock);
    80005990:	0001e517          	auipc	a0,0x1e
    80005994:	c5850513          	addi	a0,a0,-936 # 800235e8 <disk+0x128>
    80005998:	a50fb0ef          	jal	80000be8 <acquire>
  for (int i = 0; i < 3; i++) {
    8000599c:	fa040613          	addi	a2,s0,-96
    800059a0:	4901                	li	s2,0
    800059a2:	bf69                	j	8000593c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059a4:	fa042503          	lw	a0,-96(s0)
    800059a8:	00451693          	slli	a3,a0,0x4

  if (write)
    800059ac:	0001e797          	auipc	a5,0x1e
    800059b0:	b1478793          	addi	a5,a5,-1260 # 800234c0 <disk>
    800059b4:	00451713          	slli	a4,a0,0x4
    800059b8:	0a070713          	addi	a4,a4,160
    800059bc:	973e                	add	a4,a4,a5
    800059be:	01603633          	snez	a2,s6
    800059c2:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800059c4:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800059c8:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    800059cc:	6398                	ld	a4,0(a5)
    800059ce:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059d0:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800059d4:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800059d6:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800059d8:	6390                	ld	a2,0(a5)
    800059da:	00d60833          	add	a6,a2,a3
    800059de:	4741                	li	a4,16
    800059e0:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800059e4:	4585                	li	a1,1
    800059e6:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800059ea:	fa442703          	lw	a4,-92(s0)
    800059ee:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800059f2:	0712                	slli	a4,a4,0x4
    800059f4:	963a                	add	a2,a2,a4
    800059f6:	05898813          	addi	a6,s3,88
    800059fa:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800059fe:	0007b883          	ld	a7,0(a5)
    80005a02:	9746                	add	a4,a4,a7
    80005a04:	40000613          	li	a2,1024
    80005a08:	c710                	sw	a2,8(a4)
  if (write)
    80005a0a:	001b3613          	seqz	a2,s6
    80005a0e:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a12:	8e4d                	or	a2,a2,a1
    80005a14:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a18:	fa842603          	lw	a2,-88(s0)
    80005a1c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a20:	00451813          	slli	a6,a0,0x4
    80005a24:	02080813          	addi	a6,a6,32
    80005a28:	983e                	add	a6,a6,a5
    80005a2a:	577d                	li	a4,-1
    80005a2c:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005a30:	0612                	slli	a2,a2,0x4
    80005a32:	98b2                	add	a7,a7,a2
    80005a34:	03068713          	addi	a4,a3,48
    80005a38:	973e                	add	a4,a4,a5
    80005a3a:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a3e:	6398                	ld	a4,0(a5)
    80005a40:	9732                	add	a4,a4,a2
    80005a42:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a44:	4689                	li	a3,2
    80005a46:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a4a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a4e:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005a52:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a56:	6794                	ld	a3,8(a5)
    80005a58:	0026d703          	lhu	a4,2(a3)
    80005a5c:	8b1d                	andi	a4,a4,7
    80005a5e:	0706                	slli	a4,a4,0x1
    80005a60:	96ba                	add	a3,a3,a4
    80005a62:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005a66:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a6a:	6798                	ld	a4,8(a5)
    80005a6c:	00275783          	lhu	a5,2(a4)
    80005a70:	2785                	addiw	a5,a5,1
    80005a72:	00f71123          	sh	a5,2(a4)
    80005a76:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a7a:	100017b7          	lui	a5,0x10001
    80005a7e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005a82:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005a86:	0001e497          	auipc	s1,0x1e
    80005a8a:	b6248493          	addi	s1,s1,-1182 # 800235e8 <disk+0x128>
  while (b->disk == 1) {
    80005a8e:	892e                	mv	s2,a1
    80005a90:	02b79163          	bne	a5,a1,80005ab2 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005a94:	854e                	mv	a0,s3
    80005a96:	c7cfc0ef          	jal	80001f12 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	9d4fb0ef          	jal	80000c70 <release>
    sleep();
    80005aa0:	caefc0ef          	jal	80001f4e <sleep>
    acquire(&disk.vdisk_lock);
    80005aa4:	8526                	mv	a0,s1
    80005aa6:	942fb0ef          	jal	80000be8 <acquire>
  while (b->disk == 1) {
    80005aaa:	0049a783          	lw	a5,4(s3)
    80005aae:	ff2783e3          	beq	a5,s2,80005a94 <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005ab2:	fa042903          	lw	s2,-96(s0)
    80005ab6:	00491713          	slli	a4,s2,0x4
    80005aba:	02070713          	addi	a4,a4,32
    80005abe:	0001e797          	auipc	a5,0x1e
    80005ac2:	a0278793          	addi	a5,a5,-1534 # 800234c0 <disk>
    80005ac6:	97ba                	add	a5,a5,a4
    80005ac8:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005acc:	0001e997          	auipc	s3,0x1e
    80005ad0:	9f498993          	addi	s3,s3,-1548 # 800234c0 <disk>
    80005ad4:	00491713          	slli	a4,s2,0x4
    80005ad8:	0009b783          	ld	a5,0(s3)
    80005adc:	97ba                	add	a5,a5,a4
    80005ade:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005ae2:	854a                	mv	a0,s2
    80005ae4:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ae8:	bbbff0ef          	jal	800056a2 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005aec:	8885                	andi	s1,s1,1
    80005aee:	f0fd                	bnez	s1,80005ad4 <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005af0:	0001e517          	auipc	a0,0x1e
    80005af4:	af850513          	addi	a0,a0,-1288 # 800235e8 <disk+0x128>
    80005af8:	978fb0ef          	jal	80000c70 <release>
}
    80005afc:	60e6                	ld	ra,88(sp)
    80005afe:	6446                	ld	s0,80(sp)
    80005b00:	64a6                	ld	s1,72(sp)
    80005b02:	6906                	ld	s2,64(sp)
    80005b04:	79e2                	ld	s3,56(sp)
    80005b06:	7a42                	ld	s4,48(sp)
    80005b08:	7aa2                	ld	s5,40(sp)
    80005b0a:	7b02                	ld	s6,32(sp)
    80005b0c:	6be2                	ld	s7,24(sp)
    80005b0e:	6c42                	ld	s8,16(sp)
    80005b10:	6125                	addi	sp,sp,96
    80005b12:	8082                	ret

0000000080005b14 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b14:	1101                	addi	sp,sp,-32
    80005b16:	ec06                	sd	ra,24(sp)
    80005b18:	e822                	sd	s0,16(sp)
    80005b1a:	e426                	sd	s1,8(sp)
    80005b1c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b1e:	0001e497          	auipc	s1,0x1e
    80005b22:	9a248493          	addi	s1,s1,-1630 # 800234c0 <disk>
    80005b26:	0001e517          	auipc	a0,0x1e
    80005b2a:	ac250513          	addi	a0,a0,-1342 # 800235e8 <disk+0x128>
    80005b2e:	8bafb0ef          	jal	80000be8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b32:	100017b7          	lui	a5,0x10001
    80005b36:	53bc                	lw	a5,96(a5)
    80005b38:	8b8d                	andi	a5,a5,3
    80005b3a:	10001737          	lui	a4,0x10001
    80005b3e:	d37c                	sw	a5,100(a4)
    80005b40:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005b44:	689c                	ld	a5,16(s1)
    80005b46:	0204d703          	lhu	a4,32(s1)
    80005b4a:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b4e:	04f70863          	beq	a4,a5,80005b9e <virtio_disk_intr+0x8a>
    80005b52:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b56:	6898                	ld	a4,16(s1)
    80005b58:	0204d783          	lhu	a5,32(s1)
    80005b5c:	8b9d                	andi	a5,a5,7
    80005b5e:	078e                	slli	a5,a5,0x3
    80005b60:	97ba                	add	a5,a5,a4
    80005b62:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005b64:	00479713          	slli	a4,a5,0x4
    80005b68:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005b6c:	9726                	add	a4,a4,s1
    80005b6e:	01074703          	lbu	a4,16(a4)
    80005b72:	e329                	bnez	a4,80005bb4 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b74:	0792                	slli	a5,a5,0x4
    80005b76:	02078793          	addi	a5,a5,32
    80005b7a:	97a6                	add	a5,a5,s1
    80005b7c:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005b7e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b82:	bfcfc0ef          	jal	80001f7e <wakeup>

    disk.used_idx += 1;
    80005b86:	0204d783          	lhu	a5,32(s1)
    80005b8a:	2785                	addiw	a5,a5,1
    80005b8c:	17c2                	slli	a5,a5,0x30
    80005b8e:	93c1                	srli	a5,a5,0x30
    80005b90:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005b94:	6898                	ld	a4,16(s1)
    80005b96:	00275703          	lhu	a4,2(a4)
    80005b9a:	faf71ce3          	bne	a4,a5,80005b52 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b9e:	0001e517          	auipc	a0,0x1e
    80005ba2:	a4a50513          	addi	a0,a0,-1462 # 800235e8 <disk+0x128>
    80005ba6:	8cafb0ef          	jal	80000c70 <release>
}
    80005baa:	60e2                	ld	ra,24(sp)
    80005bac:	6442                	ld	s0,16(sp)
    80005bae:	64a2                	ld	s1,8(sp)
    80005bb0:	6105                	addi	sp,sp,32
    80005bb2:	8082                	ret
      panic("virtio_disk_intr status");
    80005bb4:	00002517          	auipc	a0,0x2
    80005bb8:	b6450513          	addi	a0,a0,-1180 # 80007718 <etext+0x718>
    80005bbc:	c79fa0ef          	jal	80000834 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
