
user/_mystat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <typename>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char* typename(int t) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (t == T_DIR) return "directory";
   8:	4705                	li	a4,1
   a:	02e50963          	beq	a0,a4,3c <typename+0x3c>
   e:	87aa                	mv	a5,a0
  if (t == T_FILE) return "file";
  10:	4709                	li	a4,2
  12:	00001517          	auipc	a0,0x1
  16:	98e50513          	addi	a0,a0,-1650 # 9a0 <malloc+0x110>
  1a:	00e78d63          	beq	a5,a4,34 <typename+0x34>
  if (t == T_DEVICE) return "device";
  1e:	470d                	li	a4,3
  20:	00001517          	auipc	a0,0x1
  24:	98850513          	addi	a0,a0,-1656 # 9a8 <malloc+0x118>
  28:	00e78663          	beq	a5,a4,34 <typename+0x34>
  return "?";
  2c:	00001517          	auipc	a0,0x1
  30:	98450513          	addi	a0,a0,-1660 # 9b0 <malloc+0x120>
}
  34:	60a2                	ld	ra,8(sp)
  36:	6402                	ld	s0,0(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret
  if (t == T_DIR) return "directory";
  3c:	00001517          	auipc	a0,0x1
  40:	95450513          	addi	a0,a0,-1708 # 990 <malloc+0x100>
  44:	bfc5                	j	34 <typename+0x34>

0000000000000046 <main>:

int main(int argc, char *argv[]) {
  46:	7159                	addi	sp,sp,-112
  48:	f486                	sd	ra,104(sp)
  4a:	f0a2                	sd	s0,96(sp)
  4c:	eca6                	sd	s1,88(sp)
  4e:	e8ca                	sd	s2,80(sp)
  50:	e4ce                	sd	s3,72(sp)
  52:	e0d2                	sd	s4,64(sp)
  54:	fc56                	sd	s5,56(sp)
  56:	f85a                	sd	s6,48(sp)
  58:	f45e                	sd	s7,40(sp)
  5a:	1880                	addi	s0,sp,112
  struct stat st;
  for (int i = 1; i < argc; i++) {
  5c:	4785                	li	a5,1
  5e:	06a7d863          	bge	a5,a0,ce <main+0x88>
  62:	00858493          	addi	s1,a1,8
  66:	ffe5091b          	addiw	s2,a0,-2
  6a:	02091793          	slli	a5,s2,0x20
  6e:	01d7d913          	srli	s2,a5,0x1d
  72:	05c1                	addi	a1,a1,16
  74:	992e                	add	s2,s2,a1
    if (stat(argv[i], &st) < 0) {
  76:	f9840a13          	addi	s4,s0,-104
      fprintf(2, "mystat: cannot stat %s\n", argv[i]);
      continue;
    }
    printf("%s: %s, inode %d, links %d, size %ld bytes\n",
  7a:	00001a97          	auipc	s5,0x1
  7e:	956a8a93          	addi	s5,s5,-1706 # 9d0 <malloc+0x140>
      fprintf(2, "mystat: cannot stat %s\n", argv[i]);
  82:	00001b97          	auipc	s7,0x1
  86:	936b8b93          	addi	s7,s7,-1738 # 9b8 <malloc+0x128>
  8a:	4b09                	li	s6,2
  8c:	a809                	j	9e <main+0x58>
  8e:	6090                	ld	a2,0(s1)
  90:	85de                	mv	a1,s7
  92:	855a                	mv	a0,s6
  94:	71a000ef          	jal	7ae <fprintf>
  for (int i = 1; i < argc; i++) {
  98:	04a1                	addi	s1,s1,8
  9a:	03248a63          	beq	s1,s2,ce <main+0x88>
    if (stat(argv[i], &st) < 0) {
  9e:	85d2                	mv	a1,s4
  a0:	6088                	ld	a0,0(s1)
  a2:	182000ef          	jal	224 <stat>
  a6:	fe0544e3          	bltz	a0,8e <main+0x48>
    printf("%s: %s, inode %d, links %d, size %ld bytes\n",
  aa:	0004b983          	ld	s3,0(s1)
  ae:	fa041503          	lh	a0,-96(s0)
  b2:	f4fff0ef          	jal	0 <typename>
  b6:	862a                	mv	a2,a0
  b8:	fa843783          	ld	a5,-88(s0)
  bc:	fa241703          	lh	a4,-94(s0)
  c0:	f9c42683          	lw	a3,-100(s0)
  c4:	85ce                	mv	a1,s3
  c6:	8556                	mv	a0,s5
  c8:	710000ef          	jal	7d8 <printf>
  cc:	b7f1                	j	98 <main+0x52>
           argv[i], typename(st.type), st.ino, st.nlink, st.size);
  }
  exit(0);
  ce:	4501                	li	a0,0
  d0:	2ba000ef          	jal	38a <exit>

00000000000000d4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e406                	sd	ra,8(sp)
  d8:	e022                	sd	s0,0(sp)
  da:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  dc:	f6bff0ef          	jal	46 <main>
  exit(r);
  e0:	2aa000ef          	jal	38a <exit>

00000000000000e4 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  ec:	87aa                	mv	a5,a0
  ee:	0585                	addi	a1,a1,1
  f0:	0785                	addi	a5,a5,1
  f2:	fff5c703          	lbu	a4,-1(a1)
  f6:	fee78fa3          	sb	a4,-1(a5)
  fa:	fb75                	bnez	a4,ee <strcpy+0xa>
    ;
  return os;
}
  fc:	60a2                	ld	ra,8(sp)
  fe:	6402                	ld	s0,0(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	1141                	addi	sp,sp,-16
 106:	e406                	sd	ra,8(sp)
 108:	e022                	sd	s0,0(sp)
 10a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 10c:	00054783          	lbu	a5,0(a0)
 110:	cb91                	beqz	a5,124 <strcmp+0x20>
 112:	0005c703          	lbu	a4,0(a1)
 116:	00f71763          	bne	a4,a5,124 <strcmp+0x20>
    p++, q++;
 11a:	0505                	addi	a0,a0,1
 11c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 11e:	00054783          	lbu	a5,0(a0)
 122:	fbe5                	bnez	a5,112 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 124:	0005c503          	lbu	a0,0(a1)
}
 128:	40a7853b          	subw	a0,a5,a0
 12c:	60a2                	ld	ra,8(sp)
 12e:	6402                	ld	s0,0(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strlen>:

uint
strlen(const char *s)
{
 134:	1141                	addi	sp,sp,-16
 136:	e406                	sd	ra,8(sp)
 138:	e022                	sd	s0,0(sp)
 13a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf91                	beqz	a5,15c <strlen+0x28>
 142:	00150793          	addi	a5,a0,1
 146:	86be                	mv	a3,a5
 148:	0785                	addi	a5,a5,1
 14a:	fff7c703          	lbu	a4,-1(a5)
 14e:	ff65                	bnez	a4,146 <strlen+0x12>
 150:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 154:	60a2                	ld	ra,8(sp)
 156:	6402                	ld	s0,0(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  for (n = 0; s[n]; n++)
 15c:	4501                	li	a0,0
 15e:	bfdd                	j	154 <strlen+0x20>

0000000000000160 <memset>:

void *
memset(void *dst, int c, uint n)
{
 160:	1141                	addi	sp,sp,-16
 162:	e406                	sd	ra,8(sp)
 164:	e022                	sd	s0,0(sp)
 166:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 168:	ca19                	beqz	a2,17e <memset+0x1e>
 16a:	87aa                	mv	a5,a0
 16c:	1602                	slli	a2,a2,0x20
 16e:	9201                	srli	a2,a2,0x20
 170:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 174:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 178:	0785                	addi	a5,a5,1
 17a:	fee79de3          	bne	a5,a4,174 <memset+0x14>
  }
  return dst;
}
 17e:	60a2                	ld	ra,8(sp)
 180:	6402                	ld	s0,0(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strchr>:

char *
strchr(const char *s, char c)
{
 186:	1141                	addi	sp,sp,-16
 188:	e406                	sd	ra,8(sp)
 18a:	e022                	sd	s0,0(sp)
 18c:	0800                	addi	s0,sp,16
  for (; *s; s++)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cf81                	beqz	a5,1aa <strchr+0x24>
    if (*s == c)
 194:	00f58763          	beq	a1,a5,1a2 <strchr+0x1c>
  for (; *s; s++)
 198:	0505                	addi	a0,a0,1
 19a:	00054783          	lbu	a5,0(a0)
 19e:	fbfd                	bnez	a5,194 <strchr+0xe>
      return (char *)s;
  return 0;
 1a0:	4501                	li	a0,0
}
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  return 0;
 1aa:	4501                	li	a0,0
 1ac:	bfdd                	j	1a2 <strchr+0x1c>

00000000000001ae <gets>:

char *
gets(char *buf, int max)
{
 1ae:	711d                	addi	sp,sp,-96
 1b0:	ec86                	sd	ra,88(sp)
 1b2:	e8a2                	sd	s0,80(sp)
 1b4:	e4a6                	sd	s1,72(sp)
 1b6:	e0ca                	sd	s2,64(sp)
 1b8:	fc4e                	sd	s3,56(sp)
 1ba:	f852                	sd	s4,48(sp)
 1bc:	f456                	sd	s5,40(sp)
 1be:	f05a                	sd	s6,32(sp)
 1c0:	ec5e                	sd	s7,24(sp)
 1c2:	e862                	sd	s8,16(sp)
 1c4:	1080                	addi	s0,sp,96
 1c6:	8baa                	mv	s7,a0
 1c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 1ca:	892a                	mv	s2,a0
 1cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ce:	faf40b13          	addi	s6,s0,-81
 1d2:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 1d4:	8c26                	mv	s8,s1
 1d6:	0014899b          	addiw	s3,s1,1
 1da:	84ce                	mv	s1,s3
 1dc:	0349d463          	bge	s3,s4,204 <gets+0x56>
    cc = read(0, &c, 1);
 1e0:	8656                	mv	a2,s5
 1e2:	85da                	mv	a1,s6
 1e4:	4501                	li	a0,0
 1e6:	1bc000ef          	jal	3a2 <read>
    if (cc < 1)
 1ea:	00a05d63          	blez	a0,204 <gets+0x56>
      break;
    buf[i++] = c;
 1ee:	faf44783          	lbu	a5,-81(s0)
 1f2:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1f6:	0905                	addi	s2,s2,1
 1f8:	ff678713          	addi	a4,a5,-10
 1fc:	c319                	beqz	a4,202 <gets+0x54>
 1fe:	17cd                	addi	a5,a5,-13
 200:	fbf1                	bnez	a5,1d4 <gets+0x26>
    buf[i++] = c;
 202:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 204:	9c5e                	add	s8,s8,s7
 206:	000c0023          	sb	zero,0(s8)
  return buf;
}
 20a:	855e                	mv	a0,s7
 20c:	60e6                	ld	ra,88(sp)
 20e:	6446                	ld	s0,80(sp)
 210:	64a6                	ld	s1,72(sp)
 212:	6906                	ld	s2,64(sp)
 214:	79e2                	ld	s3,56(sp)
 216:	7a42                	ld	s4,48(sp)
 218:	7aa2                	ld	s5,40(sp)
 21a:	7b02                	ld	s6,32(sp)
 21c:	6be2                	ld	s7,24(sp)
 21e:	6c42                	ld	s8,16(sp)
 220:	6125                	addi	sp,sp,96
 222:	8082                	ret

0000000000000224 <stat>:

int
stat(const char *n, struct stat *st)
{
 224:	1101                	addi	sp,sp,-32
 226:	ec06                	sd	ra,24(sp)
 228:	e822                	sd	s0,16(sp)
 22a:	e04a                	sd	s2,0(sp)
 22c:	1000                	addi	s0,sp,32
 22e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 230:	4581                	li	a1,0
 232:	198000ef          	jal	3ca <open>
  if (fd < 0)
 236:	02054263          	bltz	a0,25a <stat+0x36>
 23a:	e426                	sd	s1,8(sp)
 23c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23e:	85ca                	mv	a1,s2
 240:	1a2000ef          	jal	3e2 <fstat>
 244:	892a                	mv	s2,a0
  close(fd);
 246:	8526                	mv	a0,s1
 248:	16a000ef          	jal	3b2 <close>
  return r;
 24c:	64a2                	ld	s1,8(sp)
}
 24e:	854a                	mv	a0,s2
 250:	60e2                	ld	ra,24(sp)
 252:	6442                	ld	s0,16(sp)
 254:	6902                	ld	s2,0(sp)
 256:	6105                	addi	sp,sp,32
 258:	8082                	ret
    return -1;
 25a:	57fd                	li	a5,-1
 25c:	893e                	mv	s2,a5
 25e:	bfc5                	j	24e <stat+0x2a>

0000000000000260 <atoi>:

int
atoi(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 268:	00054683          	lbu	a3,0(a0)
 26c:	fd06879b          	addiw	a5,a3,-48
 270:	0ff7f793          	zext.b	a5,a5
 274:	4625                	li	a2,9
 276:	02f66963          	bltu	a2,a5,2a8 <atoi+0x48>
 27a:	872a                	mv	a4,a0
  n = 0;
 27c:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 27e:	0705                	addi	a4,a4,1
 280:	0025179b          	slliw	a5,a0,0x2
 284:	9fa9                	addw	a5,a5,a0
 286:	0017979b          	slliw	a5,a5,0x1
 28a:	9fb5                	addw	a5,a5,a3
 28c:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 290:	00074683          	lbu	a3,0(a4)
 294:	fd06879b          	addiw	a5,a3,-48
 298:	0ff7f793          	zext.b	a5,a5
 29c:	fef671e3          	bgeu	a2,a5,27e <atoi+0x1e>
  return n;
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  n = 0;
 2a8:	4501                	li	a0,0
 2aa:	bfdd                	j	2a0 <atoi+0x40>

00000000000002ac <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b4:	02b57563          	bgeu	a0,a1,2de <memmove+0x32>
    while (n-- > 0)
 2b8:	00c05f63          	blez	a2,2d6 <memmove+0x2a>
 2bc:	1602                	slli	a2,a2,0x20
 2be:	9201                	srli	a2,a2,0x20
 2c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c6:	0585                	addi	a1,a1,1
 2c8:	0705                	addi	a4,a4,1
 2ca:	fff5c683          	lbu	a3,-1(a1)
 2ce:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 2d2:	fee79ae3          	bne	a5,a4,2c6 <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
    while (n-- > 0)
 2de:	fec05ce3          	blez	a2,2d6 <memmove+0x2a>
    dst += n;
 2e2:	00c50733          	add	a4,a0,a2
    src += n;
 2e6:	95b2                	add	a1,a1,a2
 2e8:	fff6079b          	addiw	a5,a2,-1
 2ec:	1782                	slli	a5,a5,0x20
 2ee:	9381                	srli	a5,a5,0x20
 2f0:	fff7c793          	not	a5,a5
 2f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f6:	15fd                	addi	a1,a1,-1
 2f8:	177d                	addi	a4,a4,-1
 2fa:	0005c683          	lbu	a3,0(a1)
 2fe:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 302:	fef71ae3          	bne	a4,a5,2f6 <memmove+0x4a>
 306:	bfc1                	j	2d6 <memmove+0x2a>

0000000000000308 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	c61d                	beqz	a2,33e <memcmp+0x36>
 312:	1602                	slli	a2,a2,0x20
 314:	9201                	srli	a2,a2,0x20
 316:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 31a:	00054783          	lbu	a5,0(a0)
 31e:	0005c703          	lbu	a4,0(a1)
 322:	00e79863          	bne	a5,a4,332 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 326:	0505                	addi	a0,a0,1
    p2++;
 328:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32a:	fed518e3          	bne	a0,a3,31a <memcmp+0x12>
  }
  return 0;
 32e:	4501                	li	a0,0
 330:	a019                	j	336 <memcmp+0x2e>
      return *p1 - *p2;
 332:	40e7853b          	subw	a0,a5,a4
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
  return 0;
 33e:	4501                	li	a0,0
 340:	bfdd                	j	336 <memcmp+0x2e>

0000000000000342 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 342:	1141                	addi	sp,sp,-16
 344:	e406                	sd	ra,8(sp)
 346:	e022                	sd	s0,0(sp)
 348:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34a:	f63ff0ef          	jal	2ac <memmove>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <sbrk>:

char *
sbrk(int n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35e:	4585                	li	a1,1
 360:	0b2000ef          	jal	412 <sys_sbrk>
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <sbrklazy>:

char *
sbrklazy(int n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 374:	4589                	li	a1,2
 376:	09c000ef          	jal	412 <sys_sbrk>
}
 37a:	60a2                	ld	ra,8(sp)
 37c:	6402                	ld	s0,0(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret

0000000000000382 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 382:	4885                	li	a7,1
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exit>:
.global exit
exit:
 li a7, SYS_exit
 38a:	4889                	li	a7,2
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <wait>:
.global wait
wait:
 li a7, SYS_wait
 392:	488d                	li	a7,3
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39a:	4891                	li	a7,4
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <read>:
.global read
read:
 li a7, SYS_read
 3a2:	4895                	li	a7,5
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <write>:
.global write
write:
 li a7, SYS_write
 3aa:	48c1                	li	a7,16
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <close>:
.global close
close:
 li a7, SYS_close
 3b2:	48d5                	li	a7,21
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ba:	4899                	li	a7,6
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c2:	489d                	li	a7,7
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <open>:
.global open
open:
 li a7, SYS_open
 3ca:	48bd                	li	a7,15
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d2:	48c5                	li	a7,17
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3da:	48c9                	li	a7,18
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e2:	48a1                	li	a7,8
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <link>:
.global link
link:
 li a7, SYS_link
 3ea:	48cd                	li	a7,19
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f2:	48d1                	li	a7,20
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fa:	48a5                	li	a7,9
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <dup>:
.global dup
dup:
 li a7, SYS_dup
 402:	48a9                	li	a7,10
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40a:	48ad                	li	a7,11
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 412:	48b1                	li	a7,12
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <pause>:
.global pause
pause:
 li a7, SYS_pause
 41a:	48b5                	li	a7,13
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 422:	48b9                	li	a7,14
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sync>:
.global sync
sync:
 li a7, SYS_sync
 42a:	48d9                	li	a7,22
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	1000                	addi	s0,sp,32
 43a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43e:	4605                	li	a2,1
 440:	fef40593          	addi	a1,s0,-17
 444:	f67ff0ef          	jal	3aa <write>
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	6105                	addi	sp,sp,32
 44e:	8082                	ret

0000000000000450 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 450:	715d                	addi	sp,sp,-80
 452:	e486                	sd	ra,72(sp)
 454:	e0a2                	sd	s0,64(sp)
 456:	f84a                	sd	s2,48(sp)
 458:	f44e                	sd	s3,40(sp)
 45a:	0880                	addi	s0,sp,80
 45c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 45e:	c6d1                	beqz	a3,4ea <printint+0x9a>
 460:	0805d563          	bgez	a1,4ea <printint+0x9a>
    neg = 1;
    x = -xx;
 464:	40b005b3          	neg	a1,a1
    neg = 1;
 468:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 46a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 46e:	86ce                	mv	a3,s3
  i = 0;
 470:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 472:	00000817          	auipc	a6,0x0
 476:	59680813          	addi	a6,a6,1430 # a08 <digits>
 47a:	88ba                	mv	a7,a4
 47c:	0017051b          	addiw	a0,a4,1
 480:	872a                	mv	a4,a0
 482:	02c5f7b3          	remu	a5,a1,a2
 486:	97c2                	add	a5,a5,a6
 488:	0007c783          	lbu	a5,0(a5)
 48c:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 490:	87ae                	mv	a5,a1
 492:	02c5d5b3          	divu	a1,a1,a2
 496:	0685                	addi	a3,a3,1
 498:	fec7f1e3          	bgeu	a5,a2,47a <printint+0x2a>
  if (neg)
 49c:	00030c63          	beqz	t1,4b4 <printint+0x64>
    buf[i++] = '-';
 4a0:	fd050793          	addi	a5,a0,-48
 4a4:	00878533          	add	a0,a5,s0
 4a8:	02d00793          	li	a5,45
 4ac:	fef50423          	sb	a5,-24(a0)
 4b0:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 4b4:	02e05563          	blez	a4,4de <printint+0x8e>
 4b8:	fc26                	sd	s1,56(sp)
 4ba:	377d                	addiw	a4,a4,-1
 4bc:	00e984b3          	add	s1,s3,a4
 4c0:	19fd                	addi	s3,s3,-1
 4c2:	99ba                	add	s3,s3,a4
 4c4:	1702                	slli	a4,a4,0x20
 4c6:	9301                	srli	a4,a4,0x20
 4c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4cc:	0004c583          	lbu	a1,0(s1)
 4d0:	854a                	mv	a0,s2
 4d2:	f61ff0ef          	jal	432 <putc>
  while (--i >= 0)
 4d6:	14fd                	addi	s1,s1,-1
 4d8:	ff349ae3          	bne	s1,s3,4cc <printint+0x7c>
 4dc:	74e2                	ld	s1,56(sp)
}
 4de:	60a6                	ld	ra,72(sp)
 4e0:	6406                	ld	s0,64(sp)
 4e2:	7942                	ld	s2,48(sp)
 4e4:	79a2                	ld	s3,40(sp)
 4e6:	6161                	addi	sp,sp,80
 4e8:	8082                	ret
  neg = 0;
 4ea:	4301                	li	t1,0
 4ec:	bfbd                	j	46a <printint+0x1a>

00000000000004ee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ee:	711d                	addi	sp,sp,-96
 4f0:	ec86                	sd	ra,88(sp)
 4f2:	e8a2                	sd	s0,80(sp)
 4f4:	e4a6                	sd	s1,72(sp)
 4f6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 4f8:	0005c483          	lbu	s1,0(a1)
 4fc:	22048363          	beqz	s1,722 <vprintf+0x234>
 500:	e0ca                	sd	s2,64(sp)
 502:	fc4e                	sd	s3,56(sp)
 504:	f852                	sd	s4,48(sp)
 506:	f456                	sd	s5,40(sp)
 508:	f05a                	sd	s6,32(sp)
 50a:	ec5e                	sd	s7,24(sp)
 50c:	e862                	sd	s8,16(sp)
 50e:	8b2a                	mv	s6,a0
 510:	8a2e                	mv	s4,a1
 512:	8bb2                	mv	s7,a2
  state = 0;
 514:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 516:	4901                	li	s2,0
 518:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 51a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 51e:	06400c13          	li	s8,100
 522:	a00d                	j	544 <vprintf+0x56>
        putc(fd, c0);
 524:	85a6                	mv	a1,s1
 526:	855a                	mv	a0,s6
 528:	f0bff0ef          	jal	432 <putc>
 52c:	a019                	j	532 <vprintf+0x44>
    } else if (state == '%') {
 52e:	03598363          	beq	s3,s5,554 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 532:	0019079b          	addiw	a5,s2,1
 536:	893e                	mv	s2,a5
 538:	873e                	mv	a4,a5
 53a:	97d2                	add	a5,a5,s4
 53c:	0007c483          	lbu	s1,0(a5)
 540:	1c048a63          	beqz	s1,714 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 544:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 548:	fe0993e3          	bnez	s3,52e <vprintf+0x40>
      if (c0 == '%') {
 54c:	fd579ce3          	bne	a5,s5,524 <vprintf+0x36>
        state = '%';
 550:	89be                	mv	s3,a5
 552:	b7c5                	j	532 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 554:	00ea06b3          	add	a3,s4,a4
 558:	0016c603          	lbu	a2,1(a3)
      if (c1)
 55c:	1c060863          	beqz	a2,72c <vprintf+0x23e>
      if (c0 == 'd') {
 560:	03878763          	beq	a5,s8,58e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 564:	f9478693          	addi	a3,a5,-108
 568:	0016b693          	seqz	a3,a3
 56c:	f9c60593          	addi	a1,a2,-100
 570:	e99d                	bnez	a1,5a6 <vprintf+0xb8>
 572:	ca95                	beqz	a3,5a6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 574:	008b8493          	addi	s1,s7,8
 578:	4685                	li	a3,1
 57a:	4629                	li	a2,10
 57c:	000bb583          	ld	a1,0(s7)
 580:	855a                	mv	a0,s6
 582:	ecfff0ef          	jal	450 <printint>
        i += 1;
 586:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 588:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58a:	4981                	li	s3,0
 58c:	b75d                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 58e:	008b8493          	addi	s1,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000ba583          	lw	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	eb5ff0ef          	jal	450 <printint>
 5a0:	8ba6                	mv	s7,s1
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b779                	j	532 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 5a6:	9752                	add	a4,a4,s4
 5a8:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5ac:	f9460713          	addi	a4,a2,-108
 5b0:	00173713          	seqz	a4,a4
 5b4:	8f75                	and	a4,a4,a3
 5b6:	f9c58513          	addi	a0,a1,-100
 5ba:	18051363          	bnez	a0,740 <vprintf+0x252>
 5be:	18070163          	beqz	a4,740 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c2:	008b8493          	addi	s1,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000bb583          	ld	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	e81ff0ef          	jal	450 <printint>
        i += 2;
 5d4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	8ba6                	mv	s7,s1
      state = 0;
 5d8:	4981                	li	s3,0
        i += 2;
 5da:	bfa1                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5dc:	008b8493          	addi	s1,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000be583          	lwu	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	e67ff0ef          	jal	450 <printint>
 5ee:	8ba6                	mv	s7,s1
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b781                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f4:	008b8493          	addi	s1,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000bb583          	ld	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e4fff0ef          	jal	450 <printint>
        i += 1;
 606:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	8ba6                	mv	s7,s1
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b71d                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60e:	008b8493          	addi	s1,s7,8
 612:	4681                	li	a3,0
 614:	4629                	li	a2,10
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e35ff0ef          	jal	450 <printint>
        i += 2;
 620:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	8ba6                	mv	s7,s1
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	b731                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 628:	008b8493          	addi	s1,s7,8
 62c:	4681                	li	a3,0
 62e:	4641                	li	a2,16
 630:	000be583          	lwu	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e1bff0ef          	jal	450 <printint>
 63a:	8ba6                	mv	s7,s1
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bdd5                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	008b8493          	addi	s1,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e03ff0ef          	jal	450 <printint>
        i += 1;
 652:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	8ba6                	mv	s7,s1
      state = 0;
 656:	4981                	li	s3,0
 658:	bde9                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 65a:	008b8493          	addi	s1,s7,8
 65e:	4681                	li	a3,0
 660:	4641                	li	a2,16
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	de9ff0ef          	jal	450 <printint>
        i += 2;
 66c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66e:	8ba6                	mv	s7,s1
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	b5c1                	j	532 <vprintf+0x44>
 674:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 676:	008b8793          	addi	a5,s7,8
 67a:	8cbe                	mv	s9,a5
 67c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 680:	03000593          	li	a1,48
 684:	855a                	mv	a0,s6
 686:	dadff0ef          	jal	432 <putc>
  putc(fd, 'x');
 68a:	07800593          	li	a1,120
 68e:	855a                	mv	a0,s6
 690:	da3ff0ef          	jal	432 <putc>
 694:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 696:	00000b97          	auipc	s7,0x0
 69a:	372b8b93          	addi	s7,s7,882 # a08 <digits>
 69e:	03c9d793          	srli	a5,s3,0x3c
 6a2:	97de                	add	a5,a5,s7
 6a4:	0007c583          	lbu	a1,0(a5)
 6a8:	855a                	mv	a0,s6
 6aa:	d89ff0ef          	jal	432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ae:	0992                	slli	s3,s3,0x4
 6b0:	34fd                	addiw	s1,s1,-1
 6b2:	f4f5                	bnez	s1,69e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6b4:	8be6                	mv	s7,s9
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	6ca2                	ld	s9,8(sp)
 6ba:	bda5                	j	532 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6bc:	008b8493          	addi	s1,s7,8
 6c0:	000bc583          	lbu	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	d6dff0ef          	jal	432 <putc>
 6ca:	8ba6                	mv	s7,s1
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b595                	j	532 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 6d0:	008b8993          	addi	s3,s7,8
 6d4:	000bb483          	ld	s1,0(s7)
 6d8:	cc91                	beqz	s1,6f4 <vprintf+0x206>
        for (; *s; s++)
 6da:	0004c583          	lbu	a1,0(s1)
 6de:	c985                	beqz	a1,70e <vprintf+0x220>
          putc(fd, *s);
 6e0:	855a                	mv	a0,s6
 6e2:	d51ff0ef          	jal	432 <putc>
        for (; *s; s++)
 6e6:	0485                	addi	s1,s1,1
 6e8:	0004c583          	lbu	a1,0(s1)
 6ec:	f9f5                	bnez	a1,6e0 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b581                	j	532 <vprintf+0x44>
          s = "(null)";
 6f4:	00000497          	auipc	s1,0x0
 6f8:	30c48493          	addi	s1,s1,780 # a00 <malloc+0x170>
        for (; *s; s++)
 6fc:	02800593          	li	a1,40
 700:	b7c5                	j	6e0 <vprintf+0x1f2>
        putc(fd, '%');
 702:	85be                	mv	a1,a5
 704:	855a                	mv	a0,s6
 706:	d2dff0ef          	jal	432 <putc>
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b51d                	j	532 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	b505                	j	532 <vprintf+0x44>
 714:	6906                	ld	s2,64(sp)
 716:	79e2                	ld	s3,56(sp)
 718:	7a42                	ld	s4,48(sp)
 71a:	7aa2                	ld	s5,40(sp)
 71c:	7b02                	ld	s6,32(sp)
 71e:	6be2                	ld	s7,24(sp)
 720:	6c42                	ld	s8,16(sp)
    }
  }
}
 722:	60e6                	ld	ra,88(sp)
 724:	6446                	ld	s0,80(sp)
 726:	64a6                	ld	s1,72(sp)
 728:	6125                	addi	sp,sp,96
 72a:	8082                	ret
      if (c0 == 'd') {
 72c:	06400713          	li	a4,100
 730:	e4e78fe3          	beq	a5,a4,58e <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 734:	f9478693          	addi	a3,a5,-108
 738:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 73c:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 73e:	4701                	li	a4,0
      } else if (c0 == 'u') {
 740:	07500513          	li	a0,117
 744:	e8a78ce3          	beq	a5,a0,5dc <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 748:	f8b60513          	addi	a0,a2,-117
 74c:	e119                	bnez	a0,752 <vprintf+0x264>
 74e:	ea0693e3          	bnez	a3,5f4 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 752:	f8b58513          	addi	a0,a1,-117
 756:	e119                	bnez	a0,75c <vprintf+0x26e>
 758:	ea071be3          	bnez	a4,60e <vprintf+0x120>
      } else if (c0 == 'x') {
 75c:	07800513          	li	a0,120
 760:	eca784e3          	beq	a5,a0,628 <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 764:	f8860613          	addi	a2,a2,-120
 768:	e219                	bnez	a2,76e <vprintf+0x280>
 76a:	ec069be3          	bnez	a3,640 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 76e:	f8858593          	addi	a1,a1,-120
 772:	e199                	bnez	a1,778 <vprintf+0x28a>
 774:	ee0713e3          	bnez	a4,65a <vprintf+0x16c>
      } else if (c0 == 'p') {
 778:	07000713          	li	a4,112
 77c:	eee78ce3          	beq	a5,a4,674 <vprintf+0x186>
      } else if (c0 == 'c') {
 780:	06300713          	li	a4,99
 784:	f2e78ce3          	beq	a5,a4,6bc <vprintf+0x1ce>
      } else if (c0 == 's') {
 788:	07300713          	li	a4,115
 78c:	f4e782e3          	beq	a5,a4,6d0 <vprintf+0x1e2>
      } else if (c0 == '%') {
 790:	02500713          	li	a4,37
 794:	f6e787e3          	beq	a5,a4,702 <vprintf+0x214>
        putc(fd, '%');
 798:	02500593          	li	a1,37
 79c:	855a                	mv	a0,s6
 79e:	c95ff0ef          	jal	432 <putc>
        putc(fd, c0);
 7a2:	85a6                	mv	a1,s1
 7a4:	855a                	mv	a0,s6
 7a6:	c8dff0ef          	jal	432 <putc>
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b359                	j	532 <vprintf+0x44>

00000000000007ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ae:	715d                	addi	sp,sp,-80
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e010                	sd	a2,0(s0)
 7b8:	e414                	sd	a3,8(s0)
 7ba:	e818                	sd	a4,16(s0)
 7bc:	ec1c                	sd	a5,24(s0)
 7be:	03043023          	sd	a6,32(s0)
 7c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	8622                	mv	a2,s0
 7c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7cc:	d23ff0ef          	jal	4ee <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6161                	addi	sp,sp,80
 7d6:	8082                	ret

00000000000007d8 <printf>:

void
printf(const char *fmt, ...)
{
 7d8:	711d                	addi	sp,sp,-96
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e40c                	sd	a1,8(s0)
 7e2:	e810                	sd	a2,16(s0)
 7e4:	ec14                	sd	a3,24(s0)
 7e6:	f018                	sd	a4,32(s0)
 7e8:	f41c                	sd	a5,40(s0)
 7ea:	03043823          	sd	a6,48(s0)
 7ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	00840613          	addi	a2,s0,8
 7f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fa:	85aa                	mv	a1,a0
 7fc:	4505                	li	a0,1
 7fe:	cf1ff0ef          	jal	4ee <vprintf>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e406                	sd	ra,8(sp)
 80e:	e022                	sd	s0,0(sp)
 810:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 812:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	00000797          	auipc	a5,0x0
 81a:	7ea7b783          	ld	a5,2026(a5) # 1000 <freep>
 81e:	a039                	j	82c <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	6398                	ld	a4,0(a5)
 822:	00e7e463          	bltu	a5,a4,82a <free+0x20>
 826:	00e6ea63          	bltu	a3,a4,83a <free+0x30>
{
 82a:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	fed7fae3          	bgeu	a5,a3,820 <free+0x16>
 830:	6398                	ld	a4,0(a5)
 832:	00e6e463          	bltu	a3,a4,83a <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	fee7eae3          	bltu	a5,a4,82a <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 83a:	ff852583          	lw	a1,-8(a0)
 83e:	6390                	ld	a2,0(a5)
 840:	02059813          	slli	a6,a1,0x20
 844:	01c85713          	srli	a4,a6,0x1c
 848:	9736                	add	a4,a4,a3
 84a:	02e60563          	beq	a2,a4,874 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 852:	4790                	lw	a2,8(a5)
 854:	02061593          	slli	a1,a2,0x20
 858:	01c5d713          	srli	a4,a1,0x1c
 85c:	973e                	add	a4,a4,a5
 85e:	02e68263          	beq	a3,a4,882 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 862:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 864:	00000717          	auipc	a4,0x0
 868:	78f73e23          	sd	a5,1948(a4) # 1000 <freep>
}
 86c:	60a2                	ld	ra,8(sp)
 86e:	6402                	ld	s0,0(sp)
 870:	0141                	addi	sp,sp,16
 872:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 874:	4618                	lw	a4,8(a2)
 876:	9f2d                	addw	a4,a4,a1
 878:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	6398                	ld	a4,0(a5)
 87e:	6310                	ld	a2,0(a4)
 880:	b7f9                	j	84e <free+0x44>
    p->s.size += bp->s.size;
 882:	ff852703          	lw	a4,-8(a0)
 886:	9f31                	addw	a4,a4,a2
 888:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88a:	ff053683          	ld	a3,-16(a0)
 88e:	bfd1                	j	862 <free+0x58>

0000000000000890 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 890:	7139                	addi	sp,sp,-64
 892:	fc06                	sd	ra,56(sp)
 894:	f822                	sd	s0,48(sp)
 896:	f04a                	sd	s2,32(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 89c:	02051993          	slli	s3,a0,0x20
 8a0:	0209d993          	srli	s3,s3,0x20
 8a4:	09bd                	addi	s3,s3,15
 8a6:	0049d993          	srli	s3,s3,0x4
 8aa:	2985                	addiw	s3,s3,1
 8ac:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 8ae:	00000517          	auipc	a0,0x0
 8b2:	75253503          	ld	a0,1874(a0) # 1000 <freep>
 8b6:	c905                	beqz	a0,8e6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8b8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8ba:	4798                	lw	a4,8(a5)
 8bc:	09377663          	bgeu	a4,s3,948 <malloc+0xb8>
 8c0:	f426                	sd	s1,40(sp)
 8c2:	e852                	sd	s4,16(sp)
 8c4:	e456                	sd	s5,8(sp)
 8c6:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 8c8:	8a4e                	mv	s4,s3
 8ca:	6705                	lui	a4,0x1
 8cc:	00e9f363          	bgeu	s3,a4,8d2 <malloc+0x42>
 8d0:	6a05                	lui	s4,0x1
 8d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 8da:	00000497          	auipc	s1,0x0
 8de:	72648493          	addi	s1,s1,1830 # 1000 <freep>
  if (p == SBRK_ERROR)
 8e2:	5afd                	li	s5,-1
 8e4:	a83d                	j	922 <malloc+0x92>
 8e6:	f426                	sd	s1,40(sp)
 8e8:	e852                	sd	s4,16(sp)
 8ea:	e456                	sd	s5,8(sp)
 8ec:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ee:	00000797          	auipc	a5,0x0
 8f2:	72278793          	addi	a5,a5,1826 # 1010 <base>
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70f73523          	sd	a5,1802(a4) # 1000 <freep>
 8fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 900:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 904:	b7d1                	j	8c8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	a899                	j	960 <malloc+0xd0>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	ef9ff0ef          	jal	80a <free>
  return freep;
 916:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 918:	c125                	beqz	a0,978 <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 91a:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 91c:	4798                	lw	a4,8(a5)
 91e:	03277163          	bgeu	a4,s2,940 <malloc+0xb0>
    if (p == freep)
 922:	6098                	ld	a4,0(s1)
 924:	853e                	mv	a0,a5
 926:	fef71ae3          	bne	a4,a5,91a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 92a:	8552                	mv	a0,s4
 92c:	a2bff0ef          	jal	356 <sbrk>
  if (p == SBRK_ERROR)
 930:	fd551ee3          	bne	a0,s5,90c <malloc+0x7c>
        return 0;
 934:	4501                	li	a0,0
 936:	74a2                	ld	s1,40(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
 93e:	a03d                	j	96c <malloc+0xdc>
 940:	74a2                	ld	s1,40(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 948:	fae90fe3          	beq	s2,a4,906 <malloc+0x76>
        p->s.size -= nunits;
 94c:	4137073b          	subw	a4,a4,s3
 950:	c798                	sw	a4,8(a5)
        p += p->s.size;
 952:	02071693          	slli	a3,a4,0x20
 956:	01c6d713          	srli	a4,a3,0x1c
 95a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 960:	00000717          	auipc	a4,0x0
 964:	6aa73023          	sd	a0,1696(a4) # 1000 <freep>
      return (void *)(p + 1);
 968:	01078513          	addi	a0,a5,16
  }
}
 96c:	70e2                	ld	ra,56(sp)
 96e:	7442                	ld	s0,48(sp)
 970:	7902                	ld	s2,32(sp)
 972:	69e2                	ld	s3,24(sp)
 974:	6121                	addi	sp,sp,64
 976:	8082                	ret
 978:	74a2                	ld	s1,40(sp)
 97a:	6a42                	ld	s4,16(sp)
 97c:	6aa2                	ld	s5,8(sp)
 97e:	6b02                	ld	s6,0(sp)
 980:	b7f5                	j	96c <malloc+0xdc>
