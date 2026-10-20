
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

void find(char *path, char *target) {
   0:	da010113          	addi	sp,sp,-608
   4:	24113c23          	sd	ra,600(sp)
   8:	24813823          	sd	s0,592(sp)
   c:	25213023          	sd	s2,576(sp)
  10:	23313c23          	sd	s3,568(sp)
  14:	1480                	addi	s0,sp,608
  16:	892a                	mv	s2,a0
  18:	89ae                	mv	s3,a1
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if ((fd = open(path, 0)) < 0) {
  1a:	4581                	li	a1,0
  1c:	494000ef          	jal	4b0 <open>
  20:	04054063          	bltz	a0,60 <find+0x60>
  24:	24913423          	sd	s1,584(sp)
  28:	84aa                	mv	s1,a0
    fprintf(2, "find: cannot open %s\n", path);
    return;
  }

  if (fstat(fd, &st) < 0) {
  2a:	da840593          	addi	a1,s0,-600
  2e:	49a000ef          	jal	4c8 <fstat>
  32:	04054063          	bltz	a0,72 <find+0x72>
    fprintf(2, "find: cannot stat %s\n", path);
    close(fd);
    return;
  }

  if (st.type != T_DIR) {
  36:	db041703          	lh	a4,-592(s0)
  3a:	4785                	li	a5,1
  3c:	04f70963          	beq	a4,a5,8e <find+0x8e>
    close(fd);
  40:	8526                	mv	a0,s1
  42:	456000ef          	jal	498 <close>
    return;
  46:	24813483          	ld	s1,584(sp)
    if (st.type == T_DIR) {
      find(buf, target);
    }
  }
  close(fd);
}
  4a:	25813083          	ld	ra,600(sp)
  4e:	25013403          	ld	s0,592(sp)
  52:	24013903          	ld	s2,576(sp)
  56:	23813983          	ld	s3,568(sp)
  5a:	26010113          	addi	sp,sp,608
  5e:	8082                	ret
    fprintf(2, "find: cannot open %s\n", path);
  60:	864a                	mv	a2,s2
  62:	00001597          	auipc	a1,0x1
  66:	a0e58593          	addi	a1,a1,-1522 # a70 <malloc+0xfa>
  6a:	4509                	li	a0,2
  6c:	029000ef          	jal	894 <fprintf>
    return;
  70:	bfe9                	j	4a <find+0x4a>
    fprintf(2, "find: cannot stat %s\n", path);
  72:	864a                	mv	a2,s2
  74:	00001597          	auipc	a1,0x1
  78:	a1c58593          	addi	a1,a1,-1508 # a90 <malloc+0x11a>
  7c:	4509                	li	a0,2
  7e:	017000ef          	jal	894 <fprintf>
    close(fd);
  82:	8526                	mv	a0,s1
  84:	414000ef          	jal	498 <close>
    return;
  88:	24813483          	ld	s1,584(sp)
  8c:	bf7d                	j	4a <find+0x4a>
  if (strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)) {
  8e:	854a                	mv	a0,s2
  90:	18a000ef          	jal	21a <strlen>
  94:	2541                	addiw	a0,a0,16
  96:	20000793          	li	a5,512
  9a:	0aa7ea63          	bltu	a5,a0,14e <find+0x14e>
  9e:	23413823          	sd	s4,560(sp)
  strcpy(buf, path);
  a2:	85ca                	mv	a1,s2
  a4:	dd040513          	addi	a0,s0,-560
  a8:	122000ef          	jal	1ca <strcpy>
  p = buf + strlen(buf);
  ac:	dd040513          	addi	a0,s0,-560
  b0:	16a000ef          	jal	21a <strlen>
  b4:	1502                	slli	a0,a0,0x20
  b6:	9101                	srli	a0,a0,0x20
  b8:	dd040793          	addi	a5,s0,-560
  bc:	00a78733          	add	a4,a5,a0
  c0:	893a                	mv	s2,a4
  *p++ = '/';
  c2:	00170793          	addi	a5,a4,1
  c6:	8a3e                	mv	s4,a5
  c8:	02f00793          	li	a5,47
  cc:	00f70023          	sb	a5,0(a4)
  while (read(fd, &de, sizeof(de)) == sizeof(de)) {
  d0:	4641                	li	a2,16
  d2:	dc040593          	addi	a1,s0,-576
  d6:	8526                	mv	a0,s1
  d8:	3b0000ef          	jal	488 <read>
  dc:	47c1                	li	a5,16
  de:	08f51d63          	bne	a0,a5,178 <find+0x178>
    if (de.inum == 0) continue;
  e2:	dc045783          	lhu	a5,-576(s0)
  e6:	d7ed                	beqz	a5,d0 <find+0xd0>
    if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;
  e8:	00001597          	auipc	a1,0x1
  ec:	9d858593          	addi	a1,a1,-1576 # ac0 <malloc+0x14a>
  f0:	dc240513          	addi	a0,s0,-574
  f4:	0f6000ef          	jal	1ea <strcmp>
  f8:	dd61                	beqz	a0,d0 <find+0xd0>
  fa:	00001597          	auipc	a1,0x1
  fe:	9ce58593          	addi	a1,a1,-1586 # ac8 <malloc+0x152>
 102:	dc240513          	addi	a0,s0,-574
 106:	0e4000ef          	jal	1ea <strcmp>
 10a:	d179                	beqz	a0,d0 <find+0xd0>
    memmove(p, de.name, DIRSIZ);
 10c:	4639                	li	a2,14
 10e:	dc240593          	addi	a1,s0,-574
 112:	8552                	mv	a0,s4
 114:	27e000ef          	jal	392 <memmove>
    p[DIRSIZ] = 0;
 118:	000907a3          	sb	zero,15(s2)
    if (stat(buf, &st) < 0) {
 11c:	da840593          	addi	a1,s0,-600
 120:	dd040513          	addi	a0,s0,-560
 124:	1e6000ef          	jal	30a <stat>
 128:	fa0544e3          	bltz	a0,d0 <find+0xd0>
    if (strcmp(de.name, target) == 0) {
 12c:	85ce                	mv	a1,s3
 12e:	dc240513          	addi	a0,s0,-574
 132:	0b8000ef          	jal	1ea <strcmp>
 136:	c905                	beqz	a0,166 <find+0x166>
    if (st.type == T_DIR) {
 138:	db041703          	lh	a4,-592(s0)
 13c:	4785                	li	a5,1
 13e:	f8f719e3          	bne	a4,a5,d0 <find+0xd0>
      find(buf, target);
 142:	85ce                	mv	a1,s3
 144:	dd040513          	addi	a0,s0,-560
 148:	eb9ff0ef          	jal	0 <find>
 14c:	b751                	j	d0 <find+0xd0>
    printf("find: path too long\n");
 14e:	00001517          	auipc	a0,0x1
 152:	95a50513          	addi	a0,a0,-1702 # aa8 <malloc+0x132>
 156:	768000ef          	jal	8be <printf>
    close(fd);
 15a:	8526                	mv	a0,s1
 15c:	33c000ef          	jal	498 <close>
    return;
 160:	24813483          	ld	s1,584(sp)
 164:	b5dd                	j	4a <find+0x4a>
      printf("%s\n", buf);
 166:	dd040593          	addi	a1,s0,-560
 16a:	00001517          	auipc	a0,0x1
 16e:	96650513          	addi	a0,a0,-1690 # ad0 <malloc+0x15a>
 172:	74c000ef          	jal	8be <printf>
 176:	b7c9                	j	138 <find+0x138>
  close(fd);
 178:	8526                	mv	a0,s1
 17a:	31e000ef          	jal	498 <close>
 17e:	24813483          	ld	s1,584(sp)
 182:	23013a03          	ld	s4,560(sp)
 186:	b5d1                	j	4a <find+0x4a>

0000000000000188 <main>:

int main(int argc, char *argv[]) {
 188:	1141                	addi	sp,sp,-16
 18a:	e406                	sd	ra,8(sp)
 18c:	e022                	sd	s0,0(sp)
 18e:	0800                	addi	s0,sp,16
  if (argc < 3) {
 190:	4709                	li	a4,2
 192:	00a74c63          	blt	a4,a0,1aa <main+0x22>
    fprintf(2, "Usage: find <dir> <target>\n");
 196:	00001597          	auipc	a1,0x1
 19a:	94258593          	addi	a1,a1,-1726 # ad8 <malloc+0x162>
 19e:	853a                	mv	a0,a4
 1a0:	6f4000ef          	jal	894 <fprintf>
    exit(1);
 1a4:	4505                	li	a0,1
 1a6:	2ca000ef          	jal	470 <exit>
 1aa:	87ae                	mv	a5,a1
  }
  find(argv[1], argv[2]);
 1ac:	698c                	ld	a1,16(a1)
 1ae:	6788                	ld	a0,8(a5)
 1b0:	e51ff0ef          	jal	0 <find>
  exit(0);
 1b4:	4501                	li	a0,0
 1b6:	2ba000ef          	jal	470 <exit>

00000000000001ba <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e406                	sd	ra,8(sp)
 1be:	e022                	sd	s0,0(sp)
 1c0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1c2:	fc7ff0ef          	jal	188 <main>
  exit(r);
 1c6:	2aa000ef          	jal	470 <exit>

00000000000001ca <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e406                	sd	ra,8(sp)
 1ce:	e022                	sd	s0,0(sp)
 1d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 1d2:	87aa                	mv	a5,a0
 1d4:	0585                	addi	a1,a1,1
 1d6:	0785                	addi	a5,a5,1
 1d8:	fff5c703          	lbu	a4,-1(a1)
 1dc:	fee78fa3          	sb	a4,-1(a5)
 1e0:	fb75                	bnez	a4,1d4 <strcpy+0xa>
    ;
  return os;
}
 1e2:	60a2                	ld	ra,8(sp)
 1e4:	6402                	ld	s0,0(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cb91                	beqz	a5,20a <strcmp+0x20>
 1f8:	0005c703          	lbu	a4,0(a1)
 1fc:	00f71763          	bne	a4,a5,20a <strcmp+0x20>
    p++, q++;
 200:	0505                	addi	a0,a0,1
 202:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	fbe5                	bnez	a5,1f8 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 20a:	0005c503          	lbu	a0,0(a1)
}
 20e:	40a7853b          	subw	a0,a5,a0
 212:	60a2                	ld	ra,8(sp)
 214:	6402                	ld	s0,0(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret

000000000000021a <strlen>:

uint
strlen(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e406                	sd	ra,8(sp)
 21e:	e022                	sd	s0,0(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 222:	00054783          	lbu	a5,0(a0)
 226:	cf91                	beqz	a5,242 <strlen+0x28>
 228:	00150793          	addi	a5,a0,1
 22c:	86be                	mv	a3,a5
 22e:	0785                	addi	a5,a5,1
 230:	fff7c703          	lbu	a4,-1(a5)
 234:	ff65                	bnez	a4,22c <strlen+0x12>
 236:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 23a:	60a2                	ld	ra,8(sp)
 23c:	6402                	ld	s0,0(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
  for (n = 0; s[n]; n++)
 242:	4501                	li	a0,0
 244:	bfdd                	j	23a <strlen+0x20>

0000000000000246 <memset>:

void *
memset(void *dst, int c, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e406                	sd	ra,8(sp)
 24a:	e022                	sd	s0,0(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 24e:	ca19                	beqz	a2,264 <memset+0x1e>
 250:	87aa                	mv	a5,a0
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 25e:	0785                	addi	a5,a5,1
 260:	fee79de3          	bne	a5,a4,25a <memset+0x14>
  }
  return dst;
}
 264:	60a2                	ld	ra,8(sp)
 266:	6402                	ld	s0,0(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret

000000000000026c <strchr>:

char *
strchr(const char *s, char c)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  for (; *s; s++)
 274:	00054783          	lbu	a5,0(a0)
 278:	cf81                	beqz	a5,290 <strchr+0x24>
    if (*s == c)
 27a:	00f58763          	beq	a1,a5,288 <strchr+0x1c>
  for (; *s; s++)
 27e:	0505                	addi	a0,a0,1
 280:	00054783          	lbu	a5,0(a0)
 284:	fbfd                	bnez	a5,27a <strchr+0xe>
      return (char *)s;
  return 0;
 286:	4501                	li	a0,0
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  return 0;
 290:	4501                	li	a0,0
 292:	bfdd                	j	288 <strchr+0x1c>

0000000000000294 <gets>:

char *
gets(char *buf, int max)
{
 294:	711d                	addi	sp,sp,-96
 296:	ec86                	sd	ra,88(sp)
 298:	e8a2                	sd	s0,80(sp)
 29a:	e4a6                	sd	s1,72(sp)
 29c:	e0ca                	sd	s2,64(sp)
 29e:	fc4e                	sd	s3,56(sp)
 2a0:	f852                	sd	s4,48(sp)
 2a2:	f456                	sd	s5,40(sp)
 2a4:	f05a                	sd	s6,32(sp)
 2a6:	ec5e                	sd	s7,24(sp)
 2a8:	e862                	sd	s8,16(sp)
 2aa:	1080                	addi	s0,sp,96
 2ac:	8baa                	mv	s7,a0
 2ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 2b0:	892a                	mv	s2,a0
 2b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2b4:	faf40b13          	addi	s6,s0,-81
 2b8:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 2ba:	8c26                	mv	s8,s1
 2bc:	0014899b          	addiw	s3,s1,1
 2c0:	84ce                	mv	s1,s3
 2c2:	0349d463          	bge	s3,s4,2ea <gets+0x56>
    cc = read(0, &c, 1);
 2c6:	8656                	mv	a2,s5
 2c8:	85da                	mv	a1,s6
 2ca:	4501                	li	a0,0
 2cc:	1bc000ef          	jal	488 <read>
    if (cc < 1)
 2d0:	00a05d63          	blez	a0,2ea <gets+0x56>
      break;
    buf[i++] = c;
 2d4:	faf44783          	lbu	a5,-81(s0)
 2d8:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 2dc:	0905                	addi	s2,s2,1
 2de:	ff678713          	addi	a4,a5,-10
 2e2:	c319                	beqz	a4,2e8 <gets+0x54>
 2e4:	17cd                	addi	a5,a5,-13
 2e6:	fbf1                	bnez	a5,2ba <gets+0x26>
    buf[i++] = c;
 2e8:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2ea:	9c5e                	add	s8,s8,s7
 2ec:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2f0:	855e                	mv	a0,s7
 2f2:	60e6                	ld	ra,88(sp)
 2f4:	6446                	ld	s0,80(sp)
 2f6:	64a6                	ld	s1,72(sp)
 2f8:	6906                	ld	s2,64(sp)
 2fa:	79e2                	ld	s3,56(sp)
 2fc:	7a42                	ld	s4,48(sp)
 2fe:	7aa2                	ld	s5,40(sp)
 300:	7b02                	ld	s6,32(sp)
 302:	6be2                	ld	s7,24(sp)
 304:	6c42                	ld	s8,16(sp)
 306:	6125                	addi	sp,sp,96
 308:	8082                	ret

000000000000030a <stat>:

int
stat(const char *n, struct stat *st)
{
 30a:	1101                	addi	sp,sp,-32
 30c:	ec06                	sd	ra,24(sp)
 30e:	e822                	sd	s0,16(sp)
 310:	e04a                	sd	s2,0(sp)
 312:	1000                	addi	s0,sp,32
 314:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 316:	4581                	li	a1,0
 318:	198000ef          	jal	4b0 <open>
  if (fd < 0)
 31c:	02054263          	bltz	a0,340 <stat+0x36>
 320:	e426                	sd	s1,8(sp)
 322:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 324:	85ca                	mv	a1,s2
 326:	1a2000ef          	jal	4c8 <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	16a000ef          	jal	498 <close>
  return r;
 332:	64a2                	ld	s1,8(sp)
}
 334:	854a                	mv	a0,s2
 336:	60e2                	ld	ra,24(sp)
 338:	6442                	ld	s0,16(sp)
 33a:	6902                	ld	s2,0(sp)
 33c:	6105                	addi	sp,sp,32
 33e:	8082                	ret
    return -1;
 340:	57fd                	li	a5,-1
 342:	893e                	mv	s2,a5
 344:	bfc5                	j	334 <stat+0x2a>

0000000000000346 <atoi>:

int
atoi(const char *s)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 34e:	00054683          	lbu	a3,0(a0)
 352:	fd06879b          	addiw	a5,a3,-48
 356:	0ff7f793          	zext.b	a5,a5
 35a:	4625                	li	a2,9
 35c:	02f66963          	bltu	a2,a5,38e <atoi+0x48>
 360:	872a                	mv	a4,a0
  n = 0;
 362:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 364:	0705                	addi	a4,a4,1
 366:	0025179b          	slliw	a5,a0,0x2
 36a:	9fa9                	addw	a5,a5,a0
 36c:	0017979b          	slliw	a5,a5,0x1
 370:	9fb5                	addw	a5,a5,a3
 372:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 376:	00074683          	lbu	a3,0(a4)
 37a:	fd06879b          	addiw	a5,a3,-48
 37e:	0ff7f793          	zext.b	a5,a5
 382:	fef671e3          	bgeu	a2,a5,364 <atoi+0x1e>
  return n;
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  n = 0;
 38e:	4501                	li	a0,0
 390:	bfdd                	j	386 <atoi+0x40>

0000000000000392 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e406                	sd	ra,8(sp)
 396:	e022                	sd	s0,0(sp)
 398:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39a:	02b57563          	bgeu	a0,a1,3c4 <memmove+0x32>
    while (n-- > 0)
 39e:	00c05f63          	blez	a2,3bc <memmove+0x2a>
 3a2:	1602                	slli	a2,a2,0x20
 3a4:	9201                	srli	a2,a2,0x20
 3a6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3aa:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ac:	0585                	addi	a1,a1,1
 3ae:	0705                	addi	a4,a4,1
 3b0:	fff5c683          	lbu	a3,-1(a1)
 3b4:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 3b8:	fee79ae3          	bne	a5,a4,3ac <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
    while (n-- > 0)
 3c4:	fec05ce3          	blez	a2,3bc <memmove+0x2a>
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
 3ce:	fff6079b          	addiw	a5,a2,-1
 3d2:	1782                	slli	a5,a5,0x20
 3d4:	9381                	srli	a5,a5,0x20
 3d6:	fff7c793          	not	a5,a5
 3da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3dc:	15fd                	addi	a1,a1,-1
 3de:	177d                	addi	a4,a4,-1
 3e0:	0005c683          	lbu	a3,0(a1)
 3e4:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 3e8:	fef71ae3          	bne	a4,a5,3dc <memmove+0x4a>
 3ec:	bfc1                	j	3bc <memmove+0x2a>

00000000000003ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e406                	sd	ra,8(sp)
 3f2:	e022                	sd	s0,0(sp)
 3f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f6:	c61d                	beqz	a2,424 <memcmp+0x36>
 3f8:	1602                	slli	a2,a2,0x20
 3fa:	9201                	srli	a2,a2,0x20
 3fc:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 400:	00054783          	lbu	a5,0(a0)
 404:	0005c703          	lbu	a4,0(a1)
 408:	00e79863          	bne	a5,a4,418 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 40c:	0505                	addi	a0,a0,1
    p2++;
 40e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 410:	fed518e3          	bne	a0,a3,400 <memcmp+0x12>
  }
  return 0;
 414:	4501                	li	a0,0
 416:	a019                	j	41c <memcmp+0x2e>
      return *p1 - *p2;
 418:	40e7853b          	subw	a0,a5,a4
}
 41c:	60a2                	ld	ra,8(sp)
 41e:	6402                	ld	s0,0(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
  return 0;
 424:	4501                	li	a0,0
 426:	bfdd                	j	41c <memcmp+0x2e>

0000000000000428 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e406                	sd	ra,8(sp)
 42c:	e022                	sd	s0,0(sp)
 42e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 430:	f63ff0ef          	jal	392 <memmove>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <sbrk>:

char *
sbrk(int n)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e406                	sd	ra,8(sp)
 440:	e022                	sd	s0,0(sp)
 442:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 444:	4585                	li	a1,1
 446:	0b2000ef          	jal	4f8 <sys_sbrk>
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <sbrklazy>:

char *
sbrklazy(int n)
{
 452:	1141                	addi	sp,sp,-16
 454:	e406                	sd	ra,8(sp)
 456:	e022                	sd	s0,0(sp)
 458:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 45a:	4589                	li	a1,2
 45c:	09c000ef          	jal	4f8 <sys_sbrk>
}
 460:	60a2                	ld	ra,8(sp)
 462:	6402                	ld	s0,0(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret

0000000000000468 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 468:	4885                	li	a7,1
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <exit>:
.global exit
exit:
 li a7, SYS_exit
 470:	4889                	li	a7,2
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <wait>:
.global wait
wait:
 li a7, SYS_wait
 478:	488d                	li	a7,3
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 480:	4891                	li	a7,4
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <read>:
.global read
read:
 li a7, SYS_read
 488:	4895                	li	a7,5
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <write>:
.global write
write:
 li a7, SYS_write
 490:	48c1                	li	a7,16
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <close>:
.global close
close:
 li a7, SYS_close
 498:	48d5                	li	a7,21
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a0:	4899                	li	a7,6
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a8:	489d                	li	a7,7
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <open>:
.global open
open:
 li a7, SYS_open
 4b0:	48bd                	li	a7,15
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b8:	48c5                	li	a7,17
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c0:	48c9                	li	a7,18
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c8:	48a1                	li	a7,8
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <link>:
.global link
link:
 li a7, SYS_link
 4d0:	48cd                	li	a7,19
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d8:	48d1                	li	a7,20
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e0:	48a5                	li	a7,9
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e8:	48a9                	li	a7,10
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f0:	48ad                	li	a7,11
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4f8:	48b1                	li	a7,12
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <pause>:
.global pause
pause:
 li a7, SYS_pause
 500:	48b5                	li	a7,13
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 508:	48b9                	li	a7,14
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sync>:
.global sync
sync:
 li a7, SYS_sync
 510:	48d9                	li	a7,22
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 518:	1101                	addi	sp,sp,-32
 51a:	ec06                	sd	ra,24(sp)
 51c:	e822                	sd	s0,16(sp)
 51e:	1000                	addi	s0,sp,32
 520:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 524:	4605                	li	a2,1
 526:	fef40593          	addi	a1,s0,-17
 52a:	f67ff0ef          	jal	490 <write>
}
 52e:	60e2                	ld	ra,24(sp)
 530:	6442                	ld	s0,16(sp)
 532:	6105                	addi	sp,sp,32
 534:	8082                	ret

0000000000000536 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 536:	715d                	addi	sp,sp,-80
 538:	e486                	sd	ra,72(sp)
 53a:	e0a2                	sd	s0,64(sp)
 53c:	f84a                	sd	s2,48(sp)
 53e:	f44e                	sd	s3,40(sp)
 540:	0880                	addi	s0,sp,80
 542:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 544:	c6d1                	beqz	a3,5d0 <printint+0x9a>
 546:	0805d563          	bgez	a1,5d0 <printint+0x9a>
    neg = 1;
    x = -xx;
 54a:	40b005b3          	neg	a1,a1
    neg = 1;
 54e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 550:	fb840993          	addi	s3,s0,-72
  neg = 0;
 554:	86ce                	mv	a3,s3
  i = 0;
 556:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 558:	00000817          	auipc	a6,0x0
 55c:	5a880813          	addi	a6,a6,1448 # b00 <digits>
 560:	88ba                	mv	a7,a4
 562:	0017051b          	addiw	a0,a4,1
 566:	872a                	mv	a4,a0
 568:	02c5f7b3          	remu	a5,a1,a2
 56c:	97c2                	add	a5,a5,a6
 56e:	0007c783          	lbu	a5,0(a5)
 572:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 576:	87ae                	mv	a5,a1
 578:	02c5d5b3          	divu	a1,a1,a2
 57c:	0685                	addi	a3,a3,1
 57e:	fec7f1e3          	bgeu	a5,a2,560 <printint+0x2a>
  if (neg)
 582:	00030c63          	beqz	t1,59a <printint+0x64>
    buf[i++] = '-';
 586:	fd050793          	addi	a5,a0,-48
 58a:	00878533          	add	a0,a5,s0
 58e:	02d00793          	li	a5,45
 592:	fef50423          	sb	a5,-24(a0)
 596:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 59a:	02e05563          	blez	a4,5c4 <printint+0x8e>
 59e:	fc26                	sd	s1,56(sp)
 5a0:	377d                	addiw	a4,a4,-1
 5a2:	00e984b3          	add	s1,s3,a4
 5a6:	19fd                	addi	s3,s3,-1
 5a8:	99ba                	add	s3,s3,a4
 5aa:	1702                	slli	a4,a4,0x20
 5ac:	9301                	srli	a4,a4,0x20
 5ae:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b2:	0004c583          	lbu	a1,0(s1)
 5b6:	854a                	mv	a0,s2
 5b8:	f61ff0ef          	jal	518 <putc>
  while (--i >= 0)
 5bc:	14fd                	addi	s1,s1,-1
 5be:	ff349ae3          	bne	s1,s3,5b2 <printint+0x7c>
 5c2:	74e2                	ld	s1,56(sp)
}
 5c4:	60a6                	ld	ra,72(sp)
 5c6:	6406                	ld	s0,64(sp)
 5c8:	7942                	ld	s2,48(sp)
 5ca:	79a2                	ld	s3,40(sp)
 5cc:	6161                	addi	sp,sp,80
 5ce:	8082                	ret
  neg = 0;
 5d0:	4301                	li	t1,0
 5d2:	bfbd                	j	550 <printint+0x1a>

00000000000005d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d4:	711d                	addi	sp,sp,-96
 5d6:	ec86                	sd	ra,88(sp)
 5d8:	e8a2                	sd	s0,80(sp)
 5da:	e4a6                	sd	s1,72(sp)
 5dc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 5de:	0005c483          	lbu	s1,0(a1)
 5e2:	22048363          	beqz	s1,808 <vprintf+0x234>
 5e6:	e0ca                	sd	s2,64(sp)
 5e8:	fc4e                	sd	s3,56(sp)
 5ea:	f852                	sd	s4,48(sp)
 5ec:	f456                	sd	s5,40(sp)
 5ee:	f05a                	sd	s6,32(sp)
 5f0:	ec5e                	sd	s7,24(sp)
 5f2:	e862                	sd	s8,16(sp)
 5f4:	8b2a                	mv	s6,a0
 5f6:	8a2e                	mv	s4,a1
 5f8:	8bb2                	mv	s7,a2
  state = 0;
 5fa:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 5fc:	4901                	li	s2,0
 5fe:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 600:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 604:	06400c13          	li	s8,100
 608:	a00d                	j	62a <vprintf+0x56>
        putc(fd, c0);
 60a:	85a6                	mv	a1,s1
 60c:	855a                	mv	a0,s6
 60e:	f0bff0ef          	jal	518 <putc>
 612:	a019                	j	618 <vprintf+0x44>
    } else if (state == '%') {
 614:	03598363          	beq	s3,s5,63a <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 618:	0019079b          	addiw	a5,s2,1
 61c:	893e                	mv	s2,a5
 61e:	873e                	mv	a4,a5
 620:	97d2                	add	a5,a5,s4
 622:	0007c483          	lbu	s1,0(a5)
 626:	1c048a63          	beqz	s1,7fa <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 62a:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 62e:	fe0993e3          	bnez	s3,614 <vprintf+0x40>
      if (c0 == '%') {
 632:	fd579ce3          	bne	a5,s5,60a <vprintf+0x36>
        state = '%';
 636:	89be                	mv	s3,a5
 638:	b7c5                	j	618 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 63a:	00ea06b3          	add	a3,s4,a4
 63e:	0016c603          	lbu	a2,1(a3)
      if (c1)
 642:	1c060863          	beqz	a2,812 <vprintf+0x23e>
      if (c0 == 'd') {
 646:	03878763          	beq	a5,s8,674 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 64a:	f9478693          	addi	a3,a5,-108
 64e:	0016b693          	seqz	a3,a3
 652:	f9c60593          	addi	a1,a2,-100
 656:	e99d                	bnez	a1,68c <vprintf+0xb8>
 658:	ca95                	beqz	a3,68c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	008b8493          	addi	s1,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	ecfff0ef          	jal	536 <printint>
        i += 1;
 66c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 66e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 670:	4981                	li	s3,0
 672:	b75d                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 674:	008b8493          	addi	s1,s7,8
 678:	4685                	li	a3,1
 67a:	4629                	li	a2,10
 67c:	000ba583          	lw	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	eb5ff0ef          	jal	536 <printint>
 686:	8ba6                	mv	s7,s1
      state = 0;
 688:	4981                	li	s3,0
 68a:	b779                	j	618 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 68c:	9752                	add	a4,a4,s4
 68e:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 692:	f9460713          	addi	a4,a2,-108
 696:	00173713          	seqz	a4,a4
 69a:	8f75                	and	a4,a4,a3
 69c:	f9c58513          	addi	a0,a1,-100
 6a0:	18051363          	bnez	a0,826 <vprintf+0x252>
 6a4:	18070163          	beqz	a4,826 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	008b8493          	addi	s1,s7,8
 6ac:	4685                	li	a3,1
 6ae:	4629                	li	a2,10
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e81ff0ef          	jal	536 <printint>
        i += 2;
 6ba:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	8ba6                	mv	s7,s1
      state = 0;
 6be:	4981                	li	s3,0
        i += 2;
 6c0:	bfa1                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6c2:	008b8493          	addi	s1,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4629                	li	a2,10
 6ca:	000be583          	lwu	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	e67ff0ef          	jal	536 <printint>
 6d4:	8ba6                	mv	s7,s1
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b781                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b8493          	addi	s1,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e4fff0ef          	jal	536 <printint>
        i += 1;
 6ec:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	8ba6                	mv	s7,s1
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b71d                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	008b8493          	addi	s1,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	e35ff0ef          	jal	536 <printint>
        i += 2;
 706:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 708:	8ba6                	mv	s7,s1
      state = 0;
 70a:	4981                	li	s3,0
        i += 2;
 70c:	b731                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 70e:	008b8493          	addi	s1,s7,8
 712:	4681                	li	a3,0
 714:	4641                	li	a2,16
 716:	000be583          	lwu	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	e1bff0ef          	jal	536 <printint>
 720:	8ba6                	mv	s7,s1
      state = 0;
 722:	4981                	li	s3,0
 724:	bdd5                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 726:	008b8493          	addi	s1,s7,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	e03ff0ef          	jal	536 <printint>
        i += 1;
 738:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 73a:	8ba6                	mv	s7,s1
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bde9                	j	618 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 740:	008b8493          	addi	s1,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000bb583          	ld	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	de9ff0ef          	jal	536 <printint>
        i += 2;
 752:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 754:	8ba6                	mv	s7,s1
      state = 0;
 756:	4981                	li	s3,0
        i += 2;
 758:	b5c1                	j	618 <vprintf+0x44>
 75a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 75c:	008b8793          	addi	a5,s7,8
 760:	8cbe                	mv	s9,a5
 762:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 766:	03000593          	li	a1,48
 76a:	855a                	mv	a0,s6
 76c:	dadff0ef          	jal	518 <putc>
  putc(fd, 'x');
 770:	07800593          	li	a1,120
 774:	855a                	mv	a0,s6
 776:	da3ff0ef          	jal	518 <putc>
 77a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77c:	00000b97          	auipc	s7,0x0
 780:	384b8b93          	addi	s7,s7,900 # b00 <digits>
 784:	03c9d793          	srli	a5,s3,0x3c
 788:	97de                	add	a5,a5,s7
 78a:	0007c583          	lbu	a1,0(a5)
 78e:	855a                	mv	a0,s6
 790:	d89ff0ef          	jal	518 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 794:	0992                	slli	s3,s3,0x4
 796:	34fd                	addiw	s1,s1,-1
 798:	f4f5                	bnez	s1,784 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 79a:	8be6                	mv	s7,s9
      state = 0;
 79c:	4981                	li	s3,0
 79e:	6ca2                	ld	s9,8(sp)
 7a0:	bda5                	j	618 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7a2:	008b8493          	addi	s1,s7,8
 7a6:	000bc583          	lbu	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	d6dff0ef          	jal	518 <putc>
 7b0:	8ba6                	mv	s7,s1
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b595                	j	618 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7b6:	008b8993          	addi	s3,s7,8
 7ba:	000bb483          	ld	s1,0(s7)
 7be:	cc91                	beqz	s1,7da <vprintf+0x206>
        for (; *s; s++)
 7c0:	0004c583          	lbu	a1,0(s1)
 7c4:	c985                	beqz	a1,7f4 <vprintf+0x220>
          putc(fd, *s);
 7c6:	855a                	mv	a0,s6
 7c8:	d51ff0ef          	jal	518 <putc>
        for (; *s; s++)
 7cc:	0485                	addi	s1,s1,1
 7ce:	0004c583          	lbu	a1,0(s1)
 7d2:	f9f5                	bnez	a1,7c6 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 7d4:	8bce                	mv	s7,s3
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	b581                	j	618 <vprintf+0x44>
          s = "(null)";
 7da:	00000497          	auipc	s1,0x0
 7de:	31e48493          	addi	s1,s1,798 # af8 <malloc+0x182>
        for (; *s; s++)
 7e2:	02800593          	li	a1,40
 7e6:	b7c5                	j	7c6 <vprintf+0x1f2>
        putc(fd, '%');
 7e8:	85be                	mv	a1,a5
 7ea:	855a                	mv	a0,s6
 7ec:	d2dff0ef          	jal	518 <putc>
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b51d                	j	618 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 7f4:	8bce                	mv	s7,s3
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	b505                	j	618 <vprintf+0x44>
 7fa:	6906                	ld	s2,64(sp)
 7fc:	79e2                	ld	s3,56(sp)
 7fe:	7a42                	ld	s4,48(sp)
 800:	7aa2                	ld	s5,40(sp)
 802:	7b02                	ld	s6,32(sp)
 804:	6be2                	ld	s7,24(sp)
 806:	6c42                	ld	s8,16(sp)
    }
  }
}
 808:	60e6                	ld	ra,88(sp)
 80a:	6446                	ld	s0,80(sp)
 80c:	64a6                	ld	s1,72(sp)
 80e:	6125                	addi	sp,sp,96
 810:	8082                	ret
      if (c0 == 'd') {
 812:	06400713          	li	a4,100
 816:	e4e78fe3          	beq	a5,a4,674 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 81a:	f9478693          	addi	a3,a5,-108
 81e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 822:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 824:	4701                	li	a4,0
      } else if (c0 == 'u') {
 826:	07500513          	li	a0,117
 82a:	e8a78ce3          	beq	a5,a0,6c2 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 82e:	f8b60513          	addi	a0,a2,-117
 832:	e119                	bnez	a0,838 <vprintf+0x264>
 834:	ea0693e3          	bnez	a3,6da <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 838:	f8b58513          	addi	a0,a1,-117
 83c:	e119                	bnez	a0,842 <vprintf+0x26e>
 83e:	ea071be3          	bnez	a4,6f4 <vprintf+0x120>
      } else if (c0 == 'x') {
 842:	07800513          	li	a0,120
 846:	eca784e3          	beq	a5,a0,70e <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 84a:	f8860613          	addi	a2,a2,-120
 84e:	e219                	bnez	a2,854 <vprintf+0x280>
 850:	ec069be3          	bnez	a3,726 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 854:	f8858593          	addi	a1,a1,-120
 858:	e199                	bnez	a1,85e <vprintf+0x28a>
 85a:	ee0713e3          	bnez	a4,740 <vprintf+0x16c>
      } else if (c0 == 'p') {
 85e:	07000713          	li	a4,112
 862:	eee78ce3          	beq	a5,a4,75a <vprintf+0x186>
      } else if (c0 == 'c') {
 866:	06300713          	li	a4,99
 86a:	f2e78ce3          	beq	a5,a4,7a2 <vprintf+0x1ce>
      } else if (c0 == 's') {
 86e:	07300713          	li	a4,115
 872:	f4e782e3          	beq	a5,a4,7b6 <vprintf+0x1e2>
      } else if (c0 == '%') {
 876:	02500713          	li	a4,37
 87a:	f6e787e3          	beq	a5,a4,7e8 <vprintf+0x214>
        putc(fd, '%');
 87e:	02500593          	li	a1,37
 882:	855a                	mv	a0,s6
 884:	c95ff0ef          	jal	518 <putc>
        putc(fd, c0);
 888:	85a6                	mv	a1,s1
 88a:	855a                	mv	a0,s6
 88c:	c8dff0ef          	jal	518 <putc>
      state = 0;
 890:	4981                	li	s3,0
 892:	b359                	j	618 <vprintf+0x44>

0000000000000894 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 894:	715d                	addi	sp,sp,-80
 896:	ec06                	sd	ra,24(sp)
 898:	e822                	sd	s0,16(sp)
 89a:	1000                	addi	s0,sp,32
 89c:	e010                	sd	a2,0(s0)
 89e:	e414                	sd	a3,8(s0)
 8a0:	e818                	sd	a4,16(s0)
 8a2:	ec1c                	sd	a5,24(s0)
 8a4:	03043023          	sd	a6,32(s0)
 8a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ac:	8622                	mv	a2,s0
 8ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b2:	d23ff0ef          	jal	5d4 <vprintf>
}
 8b6:	60e2                	ld	ra,24(sp)
 8b8:	6442                	ld	s0,16(sp)
 8ba:	6161                	addi	sp,sp,80
 8bc:	8082                	ret

00000000000008be <printf>:

void
printf(const char *fmt, ...)
{
 8be:	711d                	addi	sp,sp,-96
 8c0:	ec06                	sd	ra,24(sp)
 8c2:	e822                	sd	s0,16(sp)
 8c4:	1000                	addi	s0,sp,32
 8c6:	e40c                	sd	a1,8(s0)
 8c8:	e810                	sd	a2,16(s0)
 8ca:	ec14                	sd	a3,24(s0)
 8cc:	f018                	sd	a4,32(s0)
 8ce:	f41c                	sd	a5,40(s0)
 8d0:	03043823          	sd	a6,48(s0)
 8d4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8d8:	00840613          	addi	a2,s0,8
 8dc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8e0:	85aa                	mv	a1,a0
 8e2:	4505                	li	a0,1
 8e4:	cf1ff0ef          	jal	5d4 <vprintf>
}
 8e8:	60e2                	ld	ra,24(sp)
 8ea:	6442                	ld	s0,16(sp)
 8ec:	6125                	addi	sp,sp,96
 8ee:	8082                	ret

00000000000008f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f0:	1141                	addi	sp,sp,-16
 8f2:	e406                	sd	ra,8(sp)
 8f4:	e022                	sd	s0,0(sp)
 8f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 8f8:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fc:	00000797          	auipc	a5,0x0
 900:	7047b783          	ld	a5,1796(a5) # 1000 <freep>
 904:	a039                	j	912 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 906:	6398                	ld	a4,0(a5)
 908:	00e7e463          	bltu	a5,a4,910 <free+0x20>
 90c:	00e6ea63          	bltu	a3,a4,920 <free+0x30>
{
 910:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	fed7fae3          	bgeu	a5,a3,906 <free+0x16>
 916:	6398                	ld	a4,0(a5)
 918:	00e6e463          	bltu	a3,a4,920 <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91c:	fee7eae3          	bltu	a5,a4,910 <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 920:	ff852583          	lw	a1,-8(a0)
 924:	6390                	ld	a2,0(a5)
 926:	02059813          	slli	a6,a1,0x20
 92a:	01c85713          	srli	a4,a6,0x1c
 92e:	9736                	add	a4,a4,a3
 930:	02e60563          	beq	a2,a4,95a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 934:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 938:	4790                	lw	a2,8(a5)
 93a:	02061593          	slli	a1,a2,0x20
 93e:	01c5d713          	srli	a4,a1,0x1c
 942:	973e                	add	a4,a4,a5
 944:	02e68263          	beq	a3,a4,968 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 948:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 94a:	00000717          	auipc	a4,0x0
 94e:	6af73b23          	sd	a5,1718(a4) # 1000 <freep>
}
 952:	60a2                	ld	ra,8(sp)
 954:	6402                	ld	s0,0(sp)
 956:	0141                	addi	sp,sp,16
 958:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 95a:	4618                	lw	a4,8(a2)
 95c:	9f2d                	addw	a4,a4,a1
 95e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 962:	6398                	ld	a4,0(a5)
 964:	6310                	ld	a2,0(a4)
 966:	b7f9                	j	934 <free+0x44>
    p->s.size += bp->s.size;
 968:	ff852703          	lw	a4,-8(a0)
 96c:	9f31                	addw	a4,a4,a2
 96e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 970:	ff053683          	ld	a3,-16(a0)
 974:	bfd1                	j	948 <free+0x58>

0000000000000976 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 976:	7139                	addi	sp,sp,-64
 978:	fc06                	sd	ra,56(sp)
 97a:	f822                	sd	s0,48(sp)
 97c:	f04a                	sd	s2,32(sp)
 97e:	ec4e                	sd	s3,24(sp)
 980:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 982:	02051993          	slli	s3,a0,0x20
 986:	0209d993          	srli	s3,s3,0x20
 98a:	09bd                	addi	s3,s3,15
 98c:	0049d993          	srli	s3,s3,0x4
 990:	2985                	addiw	s3,s3,1
 992:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 994:	00000517          	auipc	a0,0x0
 998:	66c53503          	ld	a0,1644(a0) # 1000 <freep>
 99c:	c905                	beqz	a0,9cc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 99e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9a0:	4798                	lw	a4,8(a5)
 9a2:	09377663          	bgeu	a4,s3,a2e <malloc+0xb8>
 9a6:	f426                	sd	s1,40(sp)
 9a8:	e852                	sd	s4,16(sp)
 9aa:	e456                	sd	s5,8(sp)
 9ac:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9ae:	8a4e                	mv	s4,s3
 9b0:	6705                	lui	a4,0x1
 9b2:	00e9f363          	bgeu	s3,a4,9b8 <malloc+0x42>
 9b6:	6a05                	lui	s4,0x1
 9b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 9c0:	00000497          	auipc	s1,0x0
 9c4:	64048493          	addi	s1,s1,1600 # 1000 <freep>
  if (p == SBRK_ERROR)
 9c8:	5afd                	li	s5,-1
 9ca:	a83d                	j	a08 <malloc+0x92>
 9cc:	f426                	sd	s1,40(sp)
 9ce:	e852                	sd	s4,16(sp)
 9d0:	e456                	sd	s5,8(sp)
 9d2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9d4:	00000797          	auipc	a5,0x0
 9d8:	63c78793          	addi	a5,a5,1596 # 1010 <base>
 9dc:	00000717          	auipc	a4,0x0
 9e0:	62f73223          	sd	a5,1572(a4) # 1000 <freep>
 9e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9e6:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 9ea:	b7d1                	j	9ae <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9ec:	6398                	ld	a4,0(a5)
 9ee:	e118                	sd	a4,0(a0)
 9f0:	a899                	j	a46 <malloc+0xd0>
  hp->s.size = nu;
 9f2:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 9f6:	0541                	addi	a0,a0,16
 9f8:	ef9ff0ef          	jal	8f0 <free>
  return freep;
 9fc:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 9fe:	c125                	beqz	a0,a5e <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a00:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a02:	4798                	lw	a4,8(a5)
 a04:	03277163          	bgeu	a4,s2,a26 <malloc+0xb0>
    if (p == freep)
 a08:	6098                	ld	a4,0(s1)
 a0a:	853e                	mv	a0,a5
 a0c:	fef71ae3          	bne	a4,a5,a00 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a10:	8552                	mv	a0,s4
 a12:	a2bff0ef          	jal	43c <sbrk>
  if (p == SBRK_ERROR)
 a16:	fd551ee3          	bne	a0,s5,9f2 <malloc+0x7c>
        return 0;
 a1a:	4501                	li	a0,0
 a1c:	74a2                	ld	s1,40(sp)
 a1e:	6a42                	ld	s4,16(sp)
 a20:	6aa2                	ld	s5,8(sp)
 a22:	6b02                	ld	s6,0(sp)
 a24:	a03d                	j	a52 <malloc+0xdc>
 a26:	74a2                	ld	s1,40(sp)
 a28:	6a42                	ld	s4,16(sp)
 a2a:	6aa2                	ld	s5,8(sp)
 a2c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a2e:	fae90fe3          	beq	s2,a4,9ec <malloc+0x76>
        p->s.size -= nunits;
 a32:	4137073b          	subw	a4,a4,s3
 a36:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a38:	02071693          	slli	a3,a4,0x20
 a3c:	01c6d713          	srli	a4,a3,0x1c
 a40:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a42:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a46:	00000717          	auipc	a4,0x0
 a4a:	5aa73d23          	sd	a0,1466(a4) # 1000 <freep>
      return (void *)(p + 1);
 a4e:	01078513          	addi	a0,a5,16
  }
}
 a52:	70e2                	ld	ra,56(sp)
 a54:	7442                	ld	s0,48(sp)
 a56:	7902                	ld	s2,32(sp)
 a58:	69e2                	ld	s3,24(sp)
 a5a:	6121                	addi	sp,sp,64
 a5c:	8082                	ret
 a5e:	74a2                	ld	s1,40(sp)
 a60:	6a42                	ld	s4,16(sp)
 a62:	6aa2                	ld	s5,8(sp)
 a64:	6b02                	ld	s6,0(sp)
 a66:	b7f5                	j	a52 <malloc+0xdc>
