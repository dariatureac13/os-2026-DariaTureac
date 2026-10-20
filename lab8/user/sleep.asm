
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(argc != 2){
   8:	4789                	li	a5,2
   a:	00f50c63          	beq	a0,a5,22 <main+0x22>
    fprintf(2, "usage: sleep <ticks>\n");
   e:	00001597          	auipc	a1,0x1
  12:	8d258593          	addi	a1,a1,-1838 # 8e0 <malloc+0xf2>
  16:	853e                	mv	a0,a5
  18:	6f4000ef          	jal	70c <fprintf>
    exit(1);
  1c:	4505                	li	a0,1
  1e:	2ca000ef          	jal	2e8 <exit>
  }
  pause(atoi(argv[1]));
  22:	6588                	ld	a0,8(a1)
  24:	19a000ef          	jal	1be <atoi>
  28:	350000ef          	jal	378 <pause>
  exit(0);
  2c:	4501                	li	a0,0
  2e:	2ba000ef          	jal	2e8 <exit>

0000000000000032 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  32:	1141                	addi	sp,sp,-16
  34:	e406                	sd	ra,8(sp)
  36:	e022                	sd	s0,0(sp)
  38:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  3a:	fc7ff0ef          	jal	0 <main>
  exit(r);
  3e:	2aa000ef          	jal	2e8 <exit>

0000000000000042 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0xa>
    ;
  return os;
}
  5a:	60a2                	ld	ra,8(sp)
  5c:	6402                	ld	s0,0(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e406                	sd	ra,8(sp)
  66:	e022                	sd	s0,0(sp)
  68:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  6a:	00054783          	lbu	a5,0(a0)
  6e:	cb91                	beqz	a5,82 <strcmp+0x20>
  70:	0005c703          	lbu	a4,0(a1)
  74:	00f71763          	bne	a4,a5,82 <strcmp+0x20>
    p++, q++;
  78:	0505                	addi	a0,a0,1
  7a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  7c:	00054783          	lbu	a5,0(a0)
  80:	fbe5                	bnez	a5,70 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  82:	0005c503          	lbu	a0,0(a1)
}
  86:	40a7853b          	subw	a0,a5,a0
  8a:	60a2                	ld	ra,8(sp)
  8c:	6402                	ld	s0,0(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret

0000000000000092 <strlen>:

uint
strlen(const char *s)
{
  92:	1141                	addi	sp,sp,-16
  94:	e406                	sd	ra,8(sp)
  96:	e022                	sd	s0,0(sp)
  98:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  9a:	00054783          	lbu	a5,0(a0)
  9e:	cf91                	beqz	a5,ba <strlen+0x28>
  a0:	00150793          	addi	a5,a0,1
  a4:	86be                	mv	a3,a5
  a6:	0785                	addi	a5,a5,1
  a8:	fff7c703          	lbu	a4,-1(a5)
  ac:	ff65                	bnez	a4,a4 <strlen+0x12>
  ae:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  b2:	60a2                	ld	ra,8(sp)
  b4:	6402                	ld	s0,0(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret
  for (n = 0; s[n]; n++)
  ba:	4501                	li	a0,0
  bc:	bfdd                	j	b2 <strlen+0x20>

00000000000000be <memset>:

void *
memset(void *dst, int c, uint n)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e406                	sd	ra,8(sp)
  c2:	e022                	sd	s0,0(sp)
  c4:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  c6:	ca19                	beqz	a2,dc <memset+0x1e>
  c8:	87aa                	mv	a5,a0
  ca:	1602                	slli	a2,a2,0x20
  cc:	9201                	srli	a2,a2,0x20
  ce:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d2:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
  d6:	0785                	addi	a5,a5,1
  d8:	fee79de3          	bne	a5,a4,d2 <memset+0x14>
  }
  return dst;
}
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strchr>:

char *
strchr(const char *s, char c)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  for (; *s; s++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf81                	beqz	a5,108 <strchr+0x24>
    if (*s == c)
  f2:	00f58763          	beq	a1,a5,100 <strchr+0x1c>
  for (; *s; s++)
  f6:	0505                	addi	a0,a0,1
  f8:	00054783          	lbu	a5,0(a0)
  fc:	fbfd                	bnez	a5,f2 <strchr+0xe>
      return (char *)s;
  return 0;
  fe:	4501                	li	a0,0
}
 100:	60a2                	ld	ra,8(sp)
 102:	6402                	ld	s0,0(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  return 0;
 108:	4501                	li	a0,0
 10a:	bfdd                	j	100 <strchr+0x1c>

000000000000010c <gets>:

char *
gets(char *buf, int max)
{
 10c:	711d                	addi	sp,sp,-96
 10e:	ec86                	sd	ra,88(sp)
 110:	e8a2                	sd	s0,80(sp)
 112:	e4a6                	sd	s1,72(sp)
 114:	e0ca                	sd	s2,64(sp)
 116:	fc4e                	sd	s3,56(sp)
 118:	f852                	sd	s4,48(sp)
 11a:	f456                	sd	s5,40(sp)
 11c:	f05a                	sd	s6,32(sp)
 11e:	ec5e                	sd	s7,24(sp)
 120:	e862                	sd	s8,16(sp)
 122:	1080                	addi	s0,sp,96
 124:	8baa                	mv	s7,a0
 126:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 128:	892a                	mv	s2,a0
 12a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 12c:	faf40b13          	addi	s6,s0,-81
 130:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 132:	8c26                	mv	s8,s1
 134:	0014899b          	addiw	s3,s1,1
 138:	84ce                	mv	s1,s3
 13a:	0349d463          	bge	s3,s4,162 <gets+0x56>
    cc = read(0, &c, 1);
 13e:	8656                	mv	a2,s5
 140:	85da                	mv	a1,s6
 142:	4501                	li	a0,0
 144:	1bc000ef          	jal	300 <read>
    if (cc < 1)
 148:	00a05d63          	blez	a0,162 <gets+0x56>
      break;
    buf[i++] = c;
 14c:	faf44783          	lbu	a5,-81(s0)
 150:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 154:	0905                	addi	s2,s2,1
 156:	ff678713          	addi	a4,a5,-10
 15a:	c319                	beqz	a4,160 <gets+0x54>
 15c:	17cd                	addi	a5,a5,-13
 15e:	fbf1                	bnez	a5,132 <gets+0x26>
    buf[i++] = c;
 160:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 162:	9c5e                	add	s8,s8,s7
 164:	000c0023          	sb	zero,0(s8)
  return buf;
}
 168:	855e                	mv	a0,s7
 16a:	60e6                	ld	ra,88(sp)
 16c:	6446                	ld	s0,80(sp)
 16e:	64a6                	ld	s1,72(sp)
 170:	6906                	ld	s2,64(sp)
 172:	79e2                	ld	s3,56(sp)
 174:	7a42                	ld	s4,48(sp)
 176:	7aa2                	ld	s5,40(sp)
 178:	7b02                	ld	s6,32(sp)
 17a:	6be2                	ld	s7,24(sp)
 17c:	6c42                	ld	s8,16(sp)
 17e:	6125                	addi	sp,sp,96
 180:	8082                	ret

0000000000000182 <stat>:

int
stat(const char *n, struct stat *st)
{
 182:	1101                	addi	sp,sp,-32
 184:	ec06                	sd	ra,24(sp)
 186:	e822                	sd	s0,16(sp)
 188:	e04a                	sd	s2,0(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18e:	4581                	li	a1,0
 190:	198000ef          	jal	328 <open>
  if (fd < 0)
 194:	02054263          	bltz	a0,1b8 <stat+0x36>
 198:	e426                	sd	s1,8(sp)
 19a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19c:	85ca                	mv	a1,s2
 19e:	1a2000ef          	jal	340 <fstat>
 1a2:	892a                	mv	s2,a0
  close(fd);
 1a4:	8526                	mv	a0,s1
 1a6:	16a000ef          	jal	310 <close>
  return r;
 1aa:	64a2                	ld	s1,8(sp)
}
 1ac:	854a                	mv	a0,s2
 1ae:	60e2                	ld	ra,24(sp)
 1b0:	6442                	ld	s0,16(sp)
 1b2:	6902                	ld	s2,0(sp)
 1b4:	6105                	addi	sp,sp,32
 1b6:	8082                	ret
    return -1;
 1b8:	57fd                	li	a5,-1
 1ba:	893e                	mv	s2,a5
 1bc:	bfc5                	j	1ac <stat+0x2a>

00000000000001be <atoi>:

int
atoi(const char *s)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e406                	sd	ra,8(sp)
 1c2:	e022                	sd	s0,0(sp)
 1c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 1c6:	00054683          	lbu	a3,0(a0)
 1ca:	fd06879b          	addiw	a5,a3,-48
 1ce:	0ff7f793          	zext.b	a5,a5
 1d2:	4625                	li	a2,9
 1d4:	02f66963          	bltu	a2,a5,206 <atoi+0x48>
 1d8:	872a                	mv	a4,a0
  n = 0;
 1da:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1dc:	0705                	addi	a4,a4,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb5                	addw	a5,a5,a3
 1ea:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1ee:	00074683          	lbu	a3,0(a4)
 1f2:	fd06879b          	addiw	a5,a3,-48
 1f6:	0ff7f793          	zext.b	a5,a5
 1fa:	fef671e3          	bgeu	a2,a5,1dc <atoi+0x1e>
  return n;
}
 1fe:	60a2                	ld	ra,8(sp)
 200:	6402                	ld	s0,0(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
  n = 0;
 206:	4501                	li	a0,0
 208:	bfdd                	j	1fe <atoi+0x40>

000000000000020a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e406                	sd	ra,8(sp)
 20e:	e022                	sd	s0,0(sp)
 210:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 212:	02b57563          	bgeu	a0,a1,23c <memmove+0x32>
    while (n-- > 0)
 216:	00c05f63          	blez	a2,234 <memmove+0x2a>
 21a:	1602                	slli	a2,a2,0x20
 21c:	9201                	srli	a2,a2,0x20
 21e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 222:	872a                	mv	a4,a0
      *dst++ = *src++;
 224:	0585                	addi	a1,a1,1
 226:	0705                	addi	a4,a4,1
 228:	fff5c683          	lbu	a3,-1(a1)
 22c:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 234:	60a2                	ld	ra,8(sp)
 236:	6402                	ld	s0,0(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
    while (n-- > 0)
 23c:	fec05ce3          	blez	a2,234 <memmove+0x2a>
    dst += n;
 240:	00c50733          	add	a4,a0,a2
    src += n;
 244:	95b2                	add	a1,a1,a2
 246:	fff6079b          	addiw	a5,a2,-1
 24a:	1782                	slli	a5,a5,0x20
 24c:	9381                	srli	a5,a5,0x20
 24e:	fff7c793          	not	a5,a5
 252:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 254:	15fd                	addi	a1,a1,-1
 256:	177d                	addi	a4,a4,-1
 258:	0005c683          	lbu	a3,0(a1)
 25c:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 260:	fef71ae3          	bne	a4,a5,254 <memmove+0x4a>
 264:	bfc1                	j	234 <memmove+0x2a>

0000000000000266 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e406                	sd	ra,8(sp)
 26a:	e022                	sd	s0,0(sp)
 26c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26e:	c61d                	beqz	a2,29c <memcmp+0x36>
 270:	1602                	slli	a2,a2,0x20
 272:	9201                	srli	a2,a2,0x20
 274:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 278:	00054783          	lbu	a5,0(a0)
 27c:	0005c703          	lbu	a4,0(a1)
 280:	00e79863          	bne	a5,a4,290 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 284:	0505                	addi	a0,a0,1
    p2++;
 286:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 288:	fed518e3          	bne	a0,a3,278 <memcmp+0x12>
  }
  return 0;
 28c:	4501                	li	a0,0
 28e:	a019                	j	294 <memcmp+0x2e>
      return *p1 - *p2;
 290:	40e7853b          	subw	a0,a5,a4
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfdd                	j	294 <memcmp+0x2e>

00000000000002a0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a8:	f63ff0ef          	jal	20a <memmove>
}
 2ac:	60a2                	ld	ra,8(sp)
 2ae:	6402                	ld	s0,0(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <sbrk>:

char *
sbrk(int n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2bc:	4585                	li	a1,1
 2be:	0b2000ef          	jal	370 <sys_sbrk>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <sbrklazy>:

char *
sbrklazy(int n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d2:	4589                	li	a1,2
 2d4:	09c000ef          	jal	370 <sys_sbrk>
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e0:	4885                	li	a7,1
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e8:	4889                	li	a7,2
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f0:	488d                	li	a7,3
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f8:	4891                	li	a7,4
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <read>:
.global read
read:
 li a7, SYS_read
 300:	4895                	li	a7,5
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <write>:
.global write
write:
 li a7, SYS_write
 308:	48c1                	li	a7,16
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <close>:
.global close
close:
 li a7, SYS_close
 310:	48d5                	li	a7,21
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <kill>:
.global kill
kill:
 li a7, SYS_kill
 318:	4899                	li	a7,6
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exec>:
.global exec
exec:
 li a7, SYS_exec
 320:	489d                	li	a7,7
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <open>:
.global open
open:
 li a7, SYS_open
 328:	48bd                	li	a7,15
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 330:	48c5                	li	a7,17
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 338:	48c9                	li	a7,18
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 340:	48a1                	li	a7,8
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <link>:
.global link
link:
 li a7, SYS_link
 348:	48cd                	li	a7,19
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 350:	48d1                	li	a7,20
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 358:	48a5                	li	a7,9
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <dup>:
.global dup
dup:
 li a7, SYS_dup
 360:	48a9                	li	a7,10
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 368:	48ad                	li	a7,11
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 370:	48b1                	li	a7,12
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <pause>:
.global pause
pause:
 li a7, SYS_pause
 378:	48b5                	li	a7,13
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 380:	48b9                	li	a7,14
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sync>:
.global sync
sync:
 li a7, SYS_sync
 388:	48d9                	li	a7,22
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 390:	1101                	addi	sp,sp,-32
 392:	ec06                	sd	ra,24(sp)
 394:	e822                	sd	s0,16(sp)
 396:	1000                	addi	s0,sp,32
 398:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39c:	4605                	li	a2,1
 39e:	fef40593          	addi	a1,s0,-17
 3a2:	f67ff0ef          	jal	308 <write>
}
 3a6:	60e2                	ld	ra,24(sp)
 3a8:	6442                	ld	s0,16(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret

00000000000003ae <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3ae:	715d                	addi	sp,sp,-80
 3b0:	e486                	sd	ra,72(sp)
 3b2:	e0a2                	sd	s0,64(sp)
 3b4:	f84a                	sd	s2,48(sp)
 3b6:	f44e                	sd	s3,40(sp)
 3b8:	0880                	addi	s0,sp,80
 3ba:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 3bc:	c6d1                	beqz	a3,448 <printint+0x9a>
 3be:	0805d563          	bgez	a1,448 <printint+0x9a>
    neg = 1;
    x = -xx;
 3c2:	40b005b3          	neg	a1,a1
    neg = 1;
 3c6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3c8:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3cc:	86ce                	mv	a3,s3
  i = 0;
 3ce:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 3d0:	00000817          	auipc	a6,0x0
 3d4:	53080813          	addi	a6,a6,1328 # 900 <digits>
 3d8:	88ba                	mv	a7,a4
 3da:	0017051b          	addiw	a0,a4,1
 3de:	872a                	mv	a4,a0
 3e0:	02c5f7b3          	remu	a5,a1,a2
 3e4:	97c2                	add	a5,a5,a6
 3e6:	0007c783          	lbu	a5,0(a5)
 3ea:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 3ee:	87ae                	mv	a5,a1
 3f0:	02c5d5b3          	divu	a1,a1,a2
 3f4:	0685                	addi	a3,a3,1
 3f6:	fec7f1e3          	bgeu	a5,a2,3d8 <printint+0x2a>
  if (neg)
 3fa:	00030c63          	beqz	t1,412 <printint+0x64>
    buf[i++] = '-';
 3fe:	fd050793          	addi	a5,a0,-48
 402:	00878533          	add	a0,a5,s0
 406:	02d00793          	li	a5,45
 40a:	fef50423          	sb	a5,-24(a0)
 40e:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 412:	02e05563          	blez	a4,43c <printint+0x8e>
 416:	fc26                	sd	s1,56(sp)
 418:	377d                	addiw	a4,a4,-1
 41a:	00e984b3          	add	s1,s3,a4
 41e:	19fd                	addi	s3,s3,-1
 420:	99ba                	add	s3,s3,a4
 422:	1702                	slli	a4,a4,0x20
 424:	9301                	srli	a4,a4,0x20
 426:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 42a:	0004c583          	lbu	a1,0(s1)
 42e:	854a                	mv	a0,s2
 430:	f61ff0ef          	jal	390 <putc>
  while (--i >= 0)
 434:	14fd                	addi	s1,s1,-1
 436:	ff349ae3          	bne	s1,s3,42a <printint+0x7c>
 43a:	74e2                	ld	s1,56(sp)
}
 43c:	60a6                	ld	ra,72(sp)
 43e:	6406                	ld	s0,64(sp)
 440:	7942                	ld	s2,48(sp)
 442:	79a2                	ld	s3,40(sp)
 444:	6161                	addi	sp,sp,80
 446:	8082                	ret
  neg = 0;
 448:	4301                	li	t1,0
 44a:	bfbd                	j	3c8 <printint+0x1a>

000000000000044c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44c:	711d                	addi	sp,sp,-96
 44e:	ec86                	sd	ra,88(sp)
 450:	e8a2                	sd	s0,80(sp)
 452:	e4a6                	sd	s1,72(sp)
 454:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 456:	0005c483          	lbu	s1,0(a1)
 45a:	22048363          	beqz	s1,680 <vprintf+0x234>
 45e:	e0ca                	sd	s2,64(sp)
 460:	fc4e                	sd	s3,56(sp)
 462:	f852                	sd	s4,48(sp)
 464:	f456                	sd	s5,40(sp)
 466:	f05a                	sd	s6,32(sp)
 468:	ec5e                	sd	s7,24(sp)
 46a:	e862                	sd	s8,16(sp)
 46c:	8b2a                	mv	s6,a0
 46e:	8a2e                	mv	s4,a1
 470:	8bb2                	mv	s7,a2
  state = 0;
 472:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 474:	4901                	li	s2,0
 476:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 478:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 47c:	06400c13          	li	s8,100
 480:	a00d                	j	4a2 <vprintf+0x56>
        putc(fd, c0);
 482:	85a6                	mv	a1,s1
 484:	855a                	mv	a0,s6
 486:	f0bff0ef          	jal	390 <putc>
 48a:	a019                	j	490 <vprintf+0x44>
    } else if (state == '%') {
 48c:	03598363          	beq	s3,s5,4b2 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 490:	0019079b          	addiw	a5,s2,1
 494:	893e                	mv	s2,a5
 496:	873e                	mv	a4,a5
 498:	97d2                	add	a5,a5,s4
 49a:	0007c483          	lbu	s1,0(a5)
 49e:	1c048a63          	beqz	s1,672 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4a2:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 4a6:	fe0993e3          	bnez	s3,48c <vprintf+0x40>
      if (c0 == '%') {
 4aa:	fd579ce3          	bne	a5,s5,482 <vprintf+0x36>
        state = '%';
 4ae:	89be                	mv	s3,a5
 4b0:	b7c5                	j	490 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 4b2:	00ea06b3          	add	a3,s4,a4
 4b6:	0016c603          	lbu	a2,1(a3)
      if (c1)
 4ba:	1c060863          	beqz	a2,68a <vprintf+0x23e>
      if (c0 == 'd') {
 4be:	03878763          	beq	a5,s8,4ec <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4c2:	f9478693          	addi	a3,a5,-108
 4c6:	0016b693          	seqz	a3,a3
 4ca:	f9c60593          	addi	a1,a2,-100
 4ce:	e99d                	bnez	a1,504 <vprintf+0xb8>
 4d0:	ca95                	beqz	a3,504 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4d2:	008b8493          	addi	s1,s7,8
 4d6:	4685                	li	a3,1
 4d8:	4629                	li	a2,10
 4da:	000bb583          	ld	a1,0(s7)
 4de:	855a                	mv	a0,s6
 4e0:	ecfff0ef          	jal	3ae <printint>
        i += 1;
 4e4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4e6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4e8:	4981                	li	s3,0
 4ea:	b75d                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 4ec:	008b8493          	addi	s1,s7,8
 4f0:	4685                	li	a3,1
 4f2:	4629                	li	a2,10
 4f4:	000ba583          	lw	a1,0(s7)
 4f8:	855a                	mv	a0,s6
 4fa:	eb5ff0ef          	jal	3ae <printint>
 4fe:	8ba6                	mv	s7,s1
      state = 0;
 500:	4981                	li	s3,0
 502:	b779                	j	490 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 504:	9752                	add	a4,a4,s4
 506:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 50a:	f9460713          	addi	a4,a2,-108
 50e:	00173713          	seqz	a4,a4
 512:	8f75                	and	a4,a4,a3
 514:	f9c58513          	addi	a0,a1,-100
 518:	18051363          	bnez	a0,69e <vprintf+0x252>
 51c:	18070163          	beqz	a4,69e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 520:	008b8493          	addi	s1,s7,8
 524:	4685                	li	a3,1
 526:	4629                	li	a2,10
 528:	000bb583          	ld	a1,0(s7)
 52c:	855a                	mv	a0,s6
 52e:	e81ff0ef          	jal	3ae <printint>
        i += 2;
 532:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 534:	8ba6                	mv	s7,s1
      state = 0;
 536:	4981                	li	s3,0
        i += 2;
 538:	bfa1                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 53a:	008b8493          	addi	s1,s7,8
 53e:	4681                	li	a3,0
 540:	4629                	li	a2,10
 542:	000be583          	lwu	a1,0(s7)
 546:	855a                	mv	a0,s6
 548:	e67ff0ef          	jal	3ae <printint>
 54c:	8ba6                	mv	s7,s1
      state = 0;
 54e:	4981                	li	s3,0
 550:	b781                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 552:	008b8493          	addi	s1,s7,8
 556:	4681                	li	a3,0
 558:	4629                	li	a2,10
 55a:	000bb583          	ld	a1,0(s7)
 55e:	855a                	mv	a0,s6
 560:	e4fff0ef          	jal	3ae <printint>
        i += 1;
 564:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 566:	8ba6                	mv	s7,s1
      state = 0;
 568:	4981                	li	s3,0
 56a:	b71d                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 56c:	008b8493          	addi	s1,s7,8
 570:	4681                	li	a3,0
 572:	4629                	li	a2,10
 574:	000bb583          	ld	a1,0(s7)
 578:	855a                	mv	a0,s6
 57a:	e35ff0ef          	jal	3ae <printint>
        i += 2;
 57e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 580:	8ba6                	mv	s7,s1
      state = 0;
 582:	4981                	li	s3,0
        i += 2;
 584:	b731                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 586:	008b8493          	addi	s1,s7,8
 58a:	4681                	li	a3,0
 58c:	4641                	li	a2,16
 58e:	000be583          	lwu	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	e1bff0ef          	jal	3ae <printint>
 598:	8ba6                	mv	s7,s1
      state = 0;
 59a:	4981                	li	s3,0
 59c:	bdd5                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 59e:	008b8493          	addi	s1,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4641                	li	a2,16
 5a6:	000bb583          	ld	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	e03ff0ef          	jal	3ae <printint>
        i += 1;
 5b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b2:	8ba6                	mv	s7,s1
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bde9                	j	490 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b8:	008b8493          	addi	s1,s7,8
 5bc:	4681                	li	a3,0
 5be:	4641                	li	a2,16
 5c0:	000bb583          	ld	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	de9ff0ef          	jal	3ae <printint>
        i += 2;
 5ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5cc:	8ba6                	mv	s7,s1
      state = 0;
 5ce:	4981                	li	s3,0
        i += 2;
 5d0:	b5c1                	j	490 <vprintf+0x44>
 5d2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5d4:	008b8793          	addi	a5,s7,8
 5d8:	8cbe                	mv	s9,a5
 5da:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5de:	03000593          	li	a1,48
 5e2:	855a                	mv	a0,s6
 5e4:	dadff0ef          	jal	390 <putc>
  putc(fd, 'x');
 5e8:	07800593          	li	a1,120
 5ec:	855a                	mv	a0,s6
 5ee:	da3ff0ef          	jal	390 <putc>
 5f2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f4:	00000b97          	auipc	s7,0x0
 5f8:	30cb8b93          	addi	s7,s7,780 # 900 <digits>
 5fc:	03c9d793          	srli	a5,s3,0x3c
 600:	97de                	add	a5,a5,s7
 602:	0007c583          	lbu	a1,0(a5)
 606:	855a                	mv	a0,s6
 608:	d89ff0ef          	jal	390 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 60c:	0992                	slli	s3,s3,0x4
 60e:	34fd                	addiw	s1,s1,-1
 610:	f4f5                	bnez	s1,5fc <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 612:	8be6                	mv	s7,s9
      state = 0;
 614:	4981                	li	s3,0
 616:	6ca2                	ld	s9,8(sp)
 618:	bda5                	j	490 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 61a:	008b8493          	addi	s1,s7,8
 61e:	000bc583          	lbu	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	d6dff0ef          	jal	390 <putc>
 628:	8ba6                	mv	s7,s1
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b595                	j	490 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 62e:	008b8993          	addi	s3,s7,8
 632:	000bb483          	ld	s1,0(s7)
 636:	cc91                	beqz	s1,652 <vprintf+0x206>
        for (; *s; s++)
 638:	0004c583          	lbu	a1,0(s1)
 63c:	c985                	beqz	a1,66c <vprintf+0x220>
          putc(fd, *s);
 63e:	855a                	mv	a0,s6
 640:	d51ff0ef          	jal	390 <putc>
        for (; *s; s++)
 644:	0485                	addi	s1,s1,1
 646:	0004c583          	lbu	a1,0(s1)
 64a:	f9f5                	bnez	a1,63e <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 64c:	8bce                	mv	s7,s3
      state = 0;
 64e:	4981                	li	s3,0
 650:	b581                	j	490 <vprintf+0x44>
          s = "(null)";
 652:	00000497          	auipc	s1,0x0
 656:	2a648493          	addi	s1,s1,678 # 8f8 <malloc+0x10a>
        for (; *s; s++)
 65a:	02800593          	li	a1,40
 65e:	b7c5                	j	63e <vprintf+0x1f2>
        putc(fd, '%');
 660:	85be                	mv	a1,a5
 662:	855a                	mv	a0,s6
 664:	d2dff0ef          	jal	390 <putc>
      state = 0;
 668:	4981                	li	s3,0
 66a:	b51d                	j	490 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 66c:	8bce                	mv	s7,s3
      state = 0;
 66e:	4981                	li	s3,0
 670:	b505                	j	490 <vprintf+0x44>
 672:	6906                	ld	s2,64(sp)
 674:	79e2                	ld	s3,56(sp)
 676:	7a42                	ld	s4,48(sp)
 678:	7aa2                	ld	s5,40(sp)
 67a:	7b02                	ld	s6,32(sp)
 67c:	6be2                	ld	s7,24(sp)
 67e:	6c42                	ld	s8,16(sp)
    }
  }
}
 680:	60e6                	ld	ra,88(sp)
 682:	6446                	ld	s0,80(sp)
 684:	64a6                	ld	s1,72(sp)
 686:	6125                	addi	sp,sp,96
 688:	8082                	ret
      if (c0 == 'd') {
 68a:	06400713          	li	a4,100
 68e:	e4e78fe3          	beq	a5,a4,4ec <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 692:	f9478693          	addi	a3,a5,-108
 696:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 69a:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 69c:	4701                	li	a4,0
      } else if (c0 == 'u') {
 69e:	07500513          	li	a0,117
 6a2:	e8a78ce3          	beq	a5,a0,53a <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 6a6:	f8b60513          	addi	a0,a2,-117
 6aa:	e119                	bnez	a0,6b0 <vprintf+0x264>
 6ac:	ea0693e3          	bnez	a3,552 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 6b0:	f8b58513          	addi	a0,a1,-117
 6b4:	e119                	bnez	a0,6ba <vprintf+0x26e>
 6b6:	ea071be3          	bnez	a4,56c <vprintf+0x120>
      } else if (c0 == 'x') {
 6ba:	07800513          	li	a0,120
 6be:	eca784e3          	beq	a5,a0,586 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 6c2:	f8860613          	addi	a2,a2,-120
 6c6:	e219                	bnez	a2,6cc <vprintf+0x280>
 6c8:	ec069be3          	bnez	a3,59e <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 6cc:	f8858593          	addi	a1,a1,-120
 6d0:	e199                	bnez	a1,6d6 <vprintf+0x28a>
 6d2:	ee0713e3          	bnez	a4,5b8 <vprintf+0x16c>
      } else if (c0 == 'p') {
 6d6:	07000713          	li	a4,112
 6da:	eee78ce3          	beq	a5,a4,5d2 <vprintf+0x186>
      } else if (c0 == 'c') {
 6de:	06300713          	li	a4,99
 6e2:	f2e78ce3          	beq	a5,a4,61a <vprintf+0x1ce>
      } else if (c0 == 's') {
 6e6:	07300713          	li	a4,115
 6ea:	f4e782e3          	beq	a5,a4,62e <vprintf+0x1e2>
      } else if (c0 == '%') {
 6ee:	02500713          	li	a4,37
 6f2:	f6e787e3          	beq	a5,a4,660 <vprintf+0x214>
        putc(fd, '%');
 6f6:	02500593          	li	a1,37
 6fa:	855a                	mv	a0,s6
 6fc:	c95ff0ef          	jal	390 <putc>
        putc(fd, c0);
 700:	85a6                	mv	a1,s1
 702:	855a                	mv	a0,s6
 704:	c8dff0ef          	jal	390 <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	b359                	j	490 <vprintf+0x44>

000000000000070c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70c:	715d                	addi	sp,sp,-80
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e010                	sd	a2,0(s0)
 716:	e414                	sd	a3,8(s0)
 718:	e818                	sd	a4,16(s0)
 71a:	ec1c                	sd	a5,24(s0)
 71c:	03043023          	sd	a6,32(s0)
 720:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	8622                	mv	a2,s0
 726:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72a:	d23ff0ef          	jal	44c <vprintf>
}
 72e:	60e2                	ld	ra,24(sp)
 730:	6442                	ld	s0,16(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <printf>:

void
printf(const char *fmt, ...)
{
 736:	711d                	addi	sp,sp,-96
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e40c                	sd	a1,8(s0)
 740:	e810                	sd	a2,16(s0)
 742:	ec14                	sd	a3,24(s0)
 744:	f018                	sd	a4,32(s0)
 746:	f41c                	sd	a5,40(s0)
 748:	03043823          	sd	a6,48(s0)
 74c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 750:	00840613          	addi	a2,s0,8
 754:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 758:	85aa                	mv	a1,a0
 75a:	4505                	li	a0,1
 75c:	cf1ff0ef          	jal	44c <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e406                	sd	ra,8(sp)
 76c:	e022                	sd	s0,0(sp)
 76e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 770:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	00001797          	auipc	a5,0x1
 778:	88c7b783          	ld	a5,-1908(a5) # 1000 <freep>
 77c:	a039                	j	78a <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	6398                	ld	a4,0(a5)
 780:	00e7e463          	bltu	a5,a4,788 <free+0x20>
 784:	00e6ea63          	bltu	a3,a4,798 <free+0x30>
{
 788:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78a:	fed7fae3          	bgeu	a5,a3,77e <free+0x16>
 78e:	6398                	ld	a4,0(a5)
 790:	00e6e463          	bltu	a3,a4,798 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 794:	fee7eae3          	bltu	a5,a4,788 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 798:	ff852583          	lw	a1,-8(a0)
 79c:	6390                	ld	a2,0(a5)
 79e:	02059813          	slli	a6,a1,0x20
 7a2:	01c85713          	srli	a4,a6,0x1c
 7a6:	9736                	add	a4,a4,a3
 7a8:	02e60563          	beq	a2,a4,7d2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7ac:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 7b0:	4790                	lw	a2,8(a5)
 7b2:	02061593          	slli	a1,a2,0x20
 7b6:	01c5d713          	srli	a4,a1,0x1c
 7ba:	973e                	add	a4,a4,a5
 7bc:	02e68263          	beq	a3,a4,7e0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7c0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c2:	00001717          	auipc	a4,0x1
 7c6:	82f73f23          	sd	a5,-1986(a4) # 1000 <freep>
}
 7ca:	60a2                	ld	ra,8(sp)
 7cc:	6402                	ld	s0,0(sp)
 7ce:	0141                	addi	sp,sp,16
 7d0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7d2:	4618                	lw	a4,8(a2)
 7d4:	9f2d                	addw	a4,a4,a1
 7d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7da:	6398                	ld	a4,0(a5)
 7dc:	6310                	ld	a2,0(a4)
 7de:	b7f9                	j	7ac <free+0x44>
    p->s.size += bp->s.size;
 7e0:	ff852703          	lw	a4,-8(a0)
 7e4:	9f31                	addw	a4,a4,a2
 7e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e8:	ff053683          	ld	a3,-16(a0)
 7ec:	bfd1                	j	7c0 <free+0x58>

00000000000007ee <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 7ee:	7139                	addi	sp,sp,-64
 7f0:	fc06                	sd	ra,56(sp)
 7f2:	f822                	sd	s0,48(sp)
 7f4:	f04a                	sd	s2,32(sp)
 7f6:	ec4e                	sd	s3,24(sp)
 7f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 7fa:	02051993          	slli	s3,a0,0x20
 7fe:	0209d993          	srli	s3,s3,0x20
 802:	09bd                	addi	s3,s3,15
 804:	0049d993          	srli	s3,s3,0x4
 808:	2985                	addiw	s3,s3,1
 80a:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 80c:	00000517          	auipc	a0,0x0
 810:	7f453503          	ld	a0,2036(a0) # 1000 <freep>
 814:	c905                	beqz	a0,844 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 816:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 818:	4798                	lw	a4,8(a5)
 81a:	09377663          	bgeu	a4,s3,8a6 <malloc+0xb8>
 81e:	f426                	sd	s1,40(sp)
 820:	e852                	sd	s4,16(sp)
 822:	e456                	sd	s5,8(sp)
 824:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 826:	8a4e                	mv	s4,s3
 828:	6705                	lui	a4,0x1
 82a:	00e9f363          	bgeu	s3,a4,830 <malloc+0x42>
 82e:	6a05                	lui	s4,0x1
 830:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 834:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 838:	00000497          	auipc	s1,0x0
 83c:	7c848493          	addi	s1,s1,1992 # 1000 <freep>
  if (p == SBRK_ERROR)
 840:	5afd                	li	s5,-1
 842:	a83d                	j	880 <malloc+0x92>
 844:	f426                	sd	s1,40(sp)
 846:	e852                	sd	s4,16(sp)
 848:	e456                	sd	s5,8(sp)
 84a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 84c:	00000797          	auipc	a5,0x0
 850:	7c478793          	addi	a5,a5,1988 # 1010 <base>
 854:	00000717          	auipc	a4,0x0
 858:	7af73623          	sd	a5,1964(a4) # 1000 <freep>
 85c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85e:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 862:	b7d1                	j	826 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 864:	6398                	ld	a4,0(a5)
 866:	e118                	sd	a4,0(a0)
 868:	a899                	j	8be <malloc+0xd0>
  hp->s.size = nu;
 86a:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 86e:	0541                	addi	a0,a0,16
 870:	ef9ff0ef          	jal	768 <free>
  return freep;
 874:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 876:	c125                	beqz	a0,8d6 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 878:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 87a:	4798                	lw	a4,8(a5)
 87c:	03277163          	bgeu	a4,s2,89e <malloc+0xb0>
    if (p == freep)
 880:	6098                	ld	a4,0(s1)
 882:	853e                	mv	a0,a5
 884:	fef71ae3          	bne	a4,a5,878 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 888:	8552                	mv	a0,s4
 88a:	a2bff0ef          	jal	2b4 <sbrk>
  if (p == SBRK_ERROR)
 88e:	fd551ee3          	bne	a0,s5,86a <malloc+0x7c>
        return 0;
 892:	4501                	li	a0,0
 894:	74a2                	ld	s1,40(sp)
 896:	6a42                	ld	s4,16(sp)
 898:	6aa2                	ld	s5,8(sp)
 89a:	6b02                	ld	s6,0(sp)
 89c:	a03d                	j	8ca <malloc+0xdc>
 89e:	74a2                	ld	s1,40(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 8a6:	fae90fe3          	beq	s2,a4,864 <malloc+0x76>
        p->s.size -= nunits;
 8aa:	4137073b          	subw	a4,a4,s3
 8ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b0:	02071693          	slli	a3,a4,0x20
 8b4:	01c6d713          	srli	a4,a3,0x1c
 8b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8be:	00000717          	auipc	a4,0x0
 8c2:	74a73123          	sd	a0,1858(a4) # 1000 <freep>
      return (void *)(p + 1);
 8c6:	01078513          	addi	a0,a5,16
  }
}
 8ca:	70e2                	ld	ra,56(sp)
 8cc:	7442                	ld	s0,48(sp)
 8ce:	7902                	ld	s2,32(sp)
 8d0:	69e2                	ld	s3,24(sp)
 8d2:	6121                	addi	sp,sp,64
 8d4:	8082                	ret
 8d6:	74a2                	ld	s1,40(sp)
 8d8:	6a42                	ld	s4,16(sp)
 8da:	6aa2                	ld	s5,8(sp)
 8dc:	6b02                	ld	s6,0(sp)
 8de:	b7f5                	j	8ca <malloc+0xdc>
