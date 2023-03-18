
user/_iobench:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
static char path[] = "12iops";
static char data[OPSIZE];

int
main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  int rfd, wfd;
  int pid = getpid();
  1e:	00000097          	auipc	ra,0x0
  22:	410080e7          	jalr	1040(ra) # 42e <getpid>
  26:	f8a43423          	sd	a0,-120(s0)
  int i;

  path[0] = '0' + (pid / 10);
  2a:	00001697          	auipc	a3,0x1
  2e:	fd668693          	addi	a3,a3,-42 # 1000 <path>
  32:	47a9                	li	a5,10
  34:	02f5473b          	divw	a4,a0,a5
  38:	0307071b          	addiw	a4,a4,48
  3c:	00e68023          	sb	a4,0(a3)
  path[1] = '0' + (pid % 10);
  40:	02f567bb          	remw	a5,a0,a5
  44:	0307879b          	addiw	a5,a5,48
  48:	00f680a3          	sb	a5,1(a3)

  memset(data, 'a', sizeof(data));
  4c:	4641                	li	a2,16
  4e:	06100593          	li	a1,97
  52:	00001517          	auipc	a0,0x1
  56:	fce50513          	addi	a0,a0,-50 # 1020 <data>
  5a:	00000097          	auipc	ra,0x0
  5e:	15a080e7          	jalr	346(ra) # 1b4 <memset>

  int start = uptime();
  62:	00000097          	auipc	ra,0x0
  66:	3e4080e7          	jalr	996(ra) # 446 <uptime>
  6a:	8c2a                	mv	s8,a0
  int ops = 0;
  6c:	4a81                	li	s5,0
  for(;;) {
    int end = uptime();
    int elapsed = end - start;
    if (elapsed >= MINTICKS) {
  6e:	06300d13          	li	s10,99
        printf("\t\t\t\t\t%d: %d IOP%dT\n", pid, (int) (ops * MINTICKS / elapsed), MINTICKS);
  72:	06400d93          	li	s11,100

        start = end;
        ops = 0;
  76:	4c81                	li	s9,0
    }

    wfd = open(path, O_CREATE | O_WRONLY);
  78:	00001b17          	auipc	s6,0x1
  7c:	f88b0b13          	addi	s6,s6,-120 # 1000 <path>
    rfd = open(path, O_RDONLY);
  80:	02000b93          	li	s7,32

    for(i = 0; i < TIMES; ++i) {
      write(wfd, data, OPSIZE);
  84:	00001917          	auipc	s2,0x1
  88:	f9c90913          	addi	s2,s2,-100 # 1020 <data>
  8c:	a085                	j	ec <main+0xec>
    wfd = open(path, O_CREATE | O_WRONLY);
  8e:	20100593          	li	a1,513
  92:	855a                	mv	a0,s6
  94:	00000097          	auipc	ra,0x0
  98:	35a080e7          	jalr	858(ra) # 3ee <open>
  9c:	8a2a                	mv	s4,a0
    rfd = open(path, O_RDONLY);
  9e:	85e6                	mv	a1,s9
  a0:	855a                	mv	a0,s6
  a2:	00000097          	auipc	ra,0x0
  a6:	34c080e7          	jalr	844(ra) # 3ee <open>
  aa:	89aa                	mv	s3,a0
  ac:	84de                	mv	s1,s7
      write(wfd, data, OPSIZE);
  ae:	4641                	li	a2,16
  b0:	85ca                	mv	a1,s2
  b2:	8552                	mv	a0,s4
  b4:	00000097          	auipc	ra,0x0
  b8:	31a080e7          	jalr	794(ra) # 3ce <write>
    for(i = 0; i < TIMES; ++i) {
  bc:	34fd                	addiw	s1,s1,-1
  be:	f8e5                	bnez	s1,ae <main+0xae>
  c0:	84de                	mv	s1,s7
    }
    for(i = 0; i < TIMES; ++i) {
      read(rfd, data, OPSIZE);
  c2:	4641                	li	a2,16
  c4:	85ca                	mv	a1,s2
  c6:	854e                	mv	a0,s3
  c8:	00000097          	auipc	ra,0x0
  cc:	2fe080e7          	jalr	766(ra) # 3c6 <read>
    for(i = 0; i < TIMES; ++i) {
  d0:	34fd                	addiw	s1,s1,-1
  d2:	f8e5                	bnez	s1,c2 <main+0xc2>
    }
    close(wfd);
  d4:	8552                	mv	a0,s4
  d6:	00000097          	auipc	ra,0x0
  da:	300080e7          	jalr	768(ra) # 3d6 <close>
    close(rfd);
  de:	854e                	mv	a0,s3
  e0:	00000097          	auipc	ra,0x0
  e4:	2f6080e7          	jalr	758(ra) # 3d6 <close>
    ops += 2 * TIMES;
  e8:	040a8a9b          	addiw	s5,s5,64
    int end = uptime();
  ec:	00000097          	auipc	ra,0x0
  f0:	35a080e7          	jalr	858(ra) # 446 <uptime>
  f4:	84aa                	mv	s1,a0
    int elapsed = end - start;
  f6:	418507bb          	subw	a5,a0,s8
  fa:	0007871b          	sext.w	a4,a5
    if (elapsed >= MINTICKS) {
  fe:	f8ed58e3          	bge	s10,a4,8e <main+0x8e>
        printf("\t\t\t\t\t%d: %d IOP%dT\n", pid, (int) (ops * MINTICKS / elapsed), MINTICKS);
 102:	035d863b          	mulw	a2,s11,s5
 106:	06400693          	li	a3,100
 10a:	02f6463b          	divw	a2,a2,a5
 10e:	f8843583          	ld	a1,-120(s0)
 112:	00000517          	auipc	a0,0x0
 116:	7be50513          	addi	a0,a0,1982 # 8d0 <malloc+0xf0>
 11a:	00000097          	auipc	ra,0x0
 11e:	60e080e7          	jalr	1550(ra) # 728 <printf>
        start = end;
 122:	8c26                	mv	s8,s1
        ops = 0;
 124:	8ae6                	mv	s5,s9
 126:	b7a5                	j	8e <main+0x8e>

0000000000000128 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 128:	1141                	addi	sp,sp,-16
 12a:	e406                	sd	ra,8(sp)
 12c:	e022                	sd	s0,0(sp)
 12e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 130:	00000097          	auipc	ra,0x0
 134:	ed0080e7          	jalr	-304(ra) # 0 <main>
  exit(0);
 138:	4501                	li	a0,0
 13a:	00000097          	auipc	ra,0x0
 13e:	274080e7          	jalr	628(ra) # 3ae <exit>

0000000000000142 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 148:	87aa                	mv	a5,a0
 14a:	0585                	addi	a1,a1,1
 14c:	0785                	addi	a5,a5,1
 14e:	fff5c703          	lbu	a4,-1(a1)
 152:	fee78fa3          	sb	a4,-1(a5)
 156:	fb75                	bnez	a4,14a <strcpy+0x8>
    ;
  return os;
}
 158:	6422                	ld	s0,8(sp)
 15a:	0141                	addi	sp,sp,16
 15c:	8082                	ret

000000000000015e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 164:	00054783          	lbu	a5,0(a0)
 168:	cb91                	beqz	a5,17c <strcmp+0x1e>
 16a:	0005c703          	lbu	a4,0(a1)
 16e:	00f71763          	bne	a4,a5,17c <strcmp+0x1e>
    p++, q++;
 172:	0505                	addi	a0,a0,1
 174:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 176:	00054783          	lbu	a5,0(a0)
 17a:	fbe5                	bnez	a5,16a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 17c:	0005c503          	lbu	a0,0(a1)
}
 180:	40a7853b          	subw	a0,a5,a0
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strlen>:

uint
strlen(const char *s)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 190:	00054783          	lbu	a5,0(a0)
 194:	cf91                	beqz	a5,1b0 <strlen+0x26>
 196:	0505                	addi	a0,a0,1
 198:	87aa                	mv	a5,a0
 19a:	4685                	li	a3,1
 19c:	9e89                	subw	a3,a3,a0
 19e:	00f6853b          	addw	a0,a3,a5
 1a2:	0785                	addi	a5,a5,1
 1a4:	fff7c703          	lbu	a4,-1(a5)
 1a8:	fb7d                	bnez	a4,19e <strlen+0x14>
    ;
  return n;
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  for(n = 0; s[n]; n++)
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strlen+0x20>

00000000000001b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ba:	ca19                	beqz	a2,1d0 <memset+0x1c>
 1bc:	87aa                	mv	a5,a0
 1be:	1602                	slli	a2,a2,0x20
 1c0:	9201                	srli	a2,a2,0x20
 1c2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ca:	0785                	addi	a5,a5,1
 1cc:	fee79de3          	bne	a5,a4,1c6 <memset+0x12>
  }
  return dst;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strchr>:

char*
strchr(const char *s, char c)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cb99                	beqz	a5,1f6 <strchr+0x20>
    if(*s == c)
 1e2:	00f58763          	beq	a1,a5,1f0 <strchr+0x1a>
  for(; *s; s++)
 1e6:	0505                	addi	a0,a0,1
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	fbfd                	bnez	a5,1e2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ee:	4501                	li	a0,0
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  return 0;
 1f6:	4501                	li	a0,0
 1f8:	bfe5                	j	1f0 <strchr+0x1a>

00000000000001fa <gets>:

char*
gets(char *buf, int max)
{
 1fa:	711d                	addi	sp,sp,-96
 1fc:	ec86                	sd	ra,88(sp)
 1fe:	e8a2                	sd	s0,80(sp)
 200:	e4a6                	sd	s1,72(sp)
 202:	e0ca                	sd	s2,64(sp)
 204:	fc4e                	sd	s3,56(sp)
 206:	f852                	sd	s4,48(sp)
 208:	f456                	sd	s5,40(sp)
 20a:	f05a                	sd	s6,32(sp)
 20c:	ec5e                	sd	s7,24(sp)
 20e:	1080                	addi	s0,sp,96
 210:	8baa                	mv	s7,a0
 212:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 214:	892a                	mv	s2,a0
 216:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 218:	4aa9                	li	s5,10
 21a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 21c:	89a6                	mv	s3,s1
 21e:	2485                	addiw	s1,s1,1
 220:	0344d863          	bge	s1,s4,250 <gets+0x56>
    cc = read(0, &c, 1);
 224:	4605                	li	a2,1
 226:	faf40593          	addi	a1,s0,-81
 22a:	4501                	li	a0,0
 22c:	00000097          	auipc	ra,0x0
 230:	19a080e7          	jalr	410(ra) # 3c6 <read>
    if(cc < 1)
 234:	00a05e63          	blez	a0,250 <gets+0x56>
    buf[i++] = c;
 238:	faf44783          	lbu	a5,-81(s0)
 23c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 240:	01578763          	beq	a5,s5,24e <gets+0x54>
 244:	0905                	addi	s2,s2,1
 246:	fd679be3          	bne	a5,s6,21c <gets+0x22>
  for(i=0; i+1 < max; ){
 24a:	89a6                	mv	s3,s1
 24c:	a011                	j	250 <gets+0x56>
 24e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 250:	99de                	add	s3,s3,s7
 252:	00098023          	sb	zero,0(s3)
  return buf;
}
 256:	855e                	mv	a0,s7
 258:	60e6                	ld	ra,88(sp)
 25a:	6446                	ld	s0,80(sp)
 25c:	64a6                	ld	s1,72(sp)
 25e:	6906                	ld	s2,64(sp)
 260:	79e2                	ld	s3,56(sp)
 262:	7a42                	ld	s4,48(sp)
 264:	7aa2                	ld	s5,40(sp)
 266:	7b02                	ld	s6,32(sp)
 268:	6be2                	ld	s7,24(sp)
 26a:	6125                	addi	sp,sp,96
 26c:	8082                	ret

000000000000026e <stat>:

int
stat(const char *n, struct stat *st)
{
 26e:	1101                	addi	sp,sp,-32
 270:	ec06                	sd	ra,24(sp)
 272:	e822                	sd	s0,16(sp)
 274:	e426                	sd	s1,8(sp)
 276:	e04a                	sd	s2,0(sp)
 278:	1000                	addi	s0,sp,32
 27a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27c:	4581                	li	a1,0
 27e:	00000097          	auipc	ra,0x0
 282:	170080e7          	jalr	368(ra) # 3ee <open>
  if(fd < 0)
 286:	02054563          	bltz	a0,2b0 <stat+0x42>
 28a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28c:	85ca                	mv	a1,s2
 28e:	00000097          	auipc	ra,0x0
 292:	178080e7          	jalr	376(ra) # 406 <fstat>
 296:	892a                	mv	s2,a0
  close(fd);
 298:	8526                	mv	a0,s1
 29a:	00000097          	auipc	ra,0x0
 29e:	13c080e7          	jalr	316(ra) # 3d6 <close>
  return r;
}
 2a2:	854a                	mv	a0,s2
 2a4:	60e2                	ld	ra,24(sp)
 2a6:	6442                	ld	s0,16(sp)
 2a8:	64a2                	ld	s1,8(sp)
 2aa:	6902                	ld	s2,0(sp)
 2ac:	6105                	addi	sp,sp,32
 2ae:	8082                	ret
    return -1;
 2b0:	597d                	li	s2,-1
 2b2:	bfc5                	j	2a2 <stat+0x34>

00000000000002b4 <atoi>:

int
atoi(const char *s)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ba:	00054683          	lbu	a3,0(a0)
 2be:	fd06879b          	addiw	a5,a3,-48
 2c2:	0ff7f793          	zext.b	a5,a5
 2c6:	4625                	li	a2,9
 2c8:	02f66863          	bltu	a2,a5,2f8 <atoi+0x44>
 2cc:	872a                	mv	a4,a0
  n = 0;
 2ce:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d0:	0705                	addi	a4,a4,1
 2d2:	0025179b          	slliw	a5,a0,0x2
 2d6:	9fa9                	addw	a5,a5,a0
 2d8:	0017979b          	slliw	a5,a5,0x1
 2dc:	9fb5                	addw	a5,a5,a3
 2de:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e2:	00074683          	lbu	a3,0(a4)
 2e6:	fd06879b          	addiw	a5,a3,-48
 2ea:	0ff7f793          	zext.b	a5,a5
 2ee:	fef671e3          	bgeu	a2,a5,2d0 <atoi+0x1c>
  return n;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  n = 0;
 2f8:	4501                	li	a0,0
 2fa:	bfe5                	j	2f2 <atoi+0x3e>

00000000000002fc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 302:	02b57463          	bgeu	a0,a1,32a <memmove+0x2e>
    while(n-- > 0)
 306:	00c05f63          	blez	a2,324 <memmove+0x28>
 30a:	1602                	slli	a2,a2,0x20
 30c:	9201                	srli	a2,a2,0x20
 30e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 312:	872a                	mv	a4,a0
      *dst++ = *src++;
 314:	0585                	addi	a1,a1,1
 316:	0705                	addi	a4,a4,1
 318:	fff5c683          	lbu	a3,-1(a1)
 31c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 320:	fee79ae3          	bne	a5,a4,314 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
    dst += n;
 32a:	00c50733          	add	a4,a0,a2
    src += n;
 32e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 330:	fec05ae3          	blez	a2,324 <memmove+0x28>
 334:	fff6079b          	addiw	a5,a2,-1
 338:	1782                	slli	a5,a5,0x20
 33a:	9381                	srli	a5,a5,0x20
 33c:	fff7c793          	not	a5,a5
 340:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 342:	15fd                	addi	a1,a1,-1
 344:	177d                	addi	a4,a4,-1
 346:	0005c683          	lbu	a3,0(a1)
 34a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34e:	fee79ae3          	bne	a5,a4,342 <memmove+0x46>
 352:	bfc9                	j	324 <memmove+0x28>

0000000000000354 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 35a:	ca05                	beqz	a2,38a <memcmp+0x36>
 35c:	fff6069b          	addiw	a3,a2,-1
 360:	1682                	slli	a3,a3,0x20
 362:	9281                	srli	a3,a3,0x20
 364:	0685                	addi	a3,a3,1
 366:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 368:	00054783          	lbu	a5,0(a0)
 36c:	0005c703          	lbu	a4,0(a1)
 370:	00e79863          	bne	a5,a4,380 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 374:	0505                	addi	a0,a0,1
    p2++;
 376:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 378:	fed518e3          	bne	a0,a3,368 <memcmp+0x14>
  }
  return 0;
 37c:	4501                	li	a0,0
 37e:	a019                	j	384 <memcmp+0x30>
      return *p1 - *p2;
 380:	40e7853b          	subw	a0,a5,a4
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  return 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <memcmp+0x30>

000000000000038e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 396:	00000097          	auipc	ra,0x0
 39a:	f66080e7          	jalr	-154(ra) # 2fc <memmove>
}
 39e:	60a2                	ld	ra,8(sp)
 3a0:	6402                	ld	s0,0(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a6:	4885                	li	a7,1
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ae:	4889                	li	a7,2
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b6:	488d                	li	a7,3
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3be:	4891                	li	a7,4
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <read>:
.global read
read:
 li a7, SYS_read
 3c6:	4895                	li	a7,5
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <write>:
.global write
write:
 li a7, SYS_write
 3ce:	48c1                	li	a7,16
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <close>:
.global close
close:
 li a7, SYS_close
 3d6:	48d5                	li	a7,21
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <kill>:
.global kill
kill:
 li a7, SYS_kill
 3de:	4899                	li	a7,6
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e6:	489d                	li	a7,7
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <open>:
.global open
open:
 li a7, SYS_open
 3ee:	48bd                	li	a7,15
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f6:	48c5                	li	a7,17
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fe:	48c9                	li	a7,18
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 406:	48a1                	li	a7,8
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <link>:
.global link
link:
 li a7, SYS_link
 40e:	48cd                	li	a7,19
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 416:	48d1                	li	a7,20
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41e:	48a5                	li	a7,9
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <dup>:
.global dup
dup:
 li a7, SYS_dup
 426:	48a9                	li	a7,10
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42e:	48ad                	li	a7,11
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 436:	48b1                	li	a7,12
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43e:	48b5                	li	a7,13
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 446:	48b9                	li	a7,14
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	1000                	addi	s0,sp,32
 456:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45a:	4605                	li	a2,1
 45c:	fef40593          	addi	a1,s0,-17
 460:	00000097          	auipc	ra,0x0
 464:	f6e080e7          	jalr	-146(ra) # 3ce <write>
}
 468:	60e2                	ld	ra,24(sp)
 46a:	6442                	ld	s0,16(sp)
 46c:	6105                	addi	sp,sp,32
 46e:	8082                	ret

0000000000000470 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 470:	7139                	addi	sp,sp,-64
 472:	fc06                	sd	ra,56(sp)
 474:	f822                	sd	s0,48(sp)
 476:	f426                	sd	s1,40(sp)
 478:	f04a                	sd	s2,32(sp)
 47a:	ec4e                	sd	s3,24(sp)
 47c:	0080                	addi	s0,sp,64
 47e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 480:	c299                	beqz	a3,486 <printint+0x16>
 482:	0805c963          	bltz	a1,514 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 486:	2581                	sext.w	a1,a1
  neg = 0;
 488:	4881                	li	a7,0
 48a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 490:	2601                	sext.w	a2,a2
 492:	00000517          	auipc	a0,0x0
 496:	4b650513          	addi	a0,a0,1206 # 948 <digits>
 49a:	883a                	mv	a6,a4
 49c:	2705                	addiw	a4,a4,1
 49e:	02c5f7bb          	remuw	a5,a1,a2
 4a2:	1782                	slli	a5,a5,0x20
 4a4:	9381                	srli	a5,a5,0x20
 4a6:	97aa                	add	a5,a5,a0
 4a8:	0007c783          	lbu	a5,0(a5)
 4ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4b0:	0005879b          	sext.w	a5,a1
 4b4:	02c5d5bb          	divuw	a1,a1,a2
 4b8:	0685                	addi	a3,a3,1
 4ba:	fec7f0e3          	bgeu	a5,a2,49a <printint+0x2a>
  if(neg)
 4be:	00088c63          	beqz	a7,4d6 <printint+0x66>
    buf[i++] = '-';
 4c2:	fd070793          	addi	a5,a4,-48
 4c6:	00878733          	add	a4,a5,s0
 4ca:	02d00793          	li	a5,45
 4ce:	fef70823          	sb	a5,-16(a4)
 4d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d6:	02e05863          	blez	a4,506 <printint+0x96>
 4da:	fc040793          	addi	a5,s0,-64
 4de:	00e78933          	add	s2,a5,a4
 4e2:	fff78993          	addi	s3,a5,-1
 4e6:	99ba                	add	s3,s3,a4
 4e8:	377d                	addiw	a4,a4,-1
 4ea:	1702                	slli	a4,a4,0x20
 4ec:	9301                	srli	a4,a4,0x20
 4ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f2:	fff94583          	lbu	a1,-1(s2)
 4f6:	8526                	mv	a0,s1
 4f8:	00000097          	auipc	ra,0x0
 4fc:	f56080e7          	jalr	-170(ra) # 44e <putc>
  while(--i >= 0)
 500:	197d                	addi	s2,s2,-1
 502:	ff3918e3          	bne	s2,s3,4f2 <printint+0x82>
}
 506:	70e2                	ld	ra,56(sp)
 508:	7442                	ld	s0,48(sp)
 50a:	74a2                	ld	s1,40(sp)
 50c:	7902                	ld	s2,32(sp)
 50e:	69e2                	ld	s3,24(sp)
 510:	6121                	addi	sp,sp,64
 512:	8082                	ret
    x = -xx;
 514:	40b005bb          	negw	a1,a1
    neg = 1;
 518:	4885                	li	a7,1
    x = -xx;
 51a:	bf85                	j	48a <printint+0x1a>

000000000000051c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 51c:	7119                	addi	sp,sp,-128
 51e:	fc86                	sd	ra,120(sp)
 520:	f8a2                	sd	s0,112(sp)
 522:	f4a6                	sd	s1,104(sp)
 524:	f0ca                	sd	s2,96(sp)
 526:	ecce                	sd	s3,88(sp)
 528:	e8d2                	sd	s4,80(sp)
 52a:	e4d6                	sd	s5,72(sp)
 52c:	e0da                	sd	s6,64(sp)
 52e:	fc5e                	sd	s7,56(sp)
 530:	f862                	sd	s8,48(sp)
 532:	f466                	sd	s9,40(sp)
 534:	f06a                	sd	s10,32(sp)
 536:	ec6e                	sd	s11,24(sp)
 538:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 53a:	0005c903          	lbu	s2,0(a1)
 53e:	18090f63          	beqz	s2,6dc <vprintf+0x1c0>
 542:	8aaa                	mv	s5,a0
 544:	8b32                	mv	s6,a2
 546:	00158493          	addi	s1,a1,1
  state = 0;
 54a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 54c:	02500a13          	li	s4,37
 550:	4c55                	li	s8,21
 552:	00000c97          	auipc	s9,0x0
 556:	39ec8c93          	addi	s9,s9,926 # 8f0 <malloc+0x110>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 55a:	02800d93          	li	s11,40
  putc(fd, 'x');
 55e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 560:	00000b97          	auipc	s7,0x0
 564:	3e8b8b93          	addi	s7,s7,1000 # 948 <digits>
 568:	a839                	j	586 <vprintf+0x6a>
        putc(fd, c);
 56a:	85ca                	mv	a1,s2
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	ee0080e7          	jalr	-288(ra) # 44e <putc>
 576:	a019                	j	57c <vprintf+0x60>
    } else if(state == '%'){
 578:	01498d63          	beq	s3,s4,592 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 57c:	0485                	addi	s1,s1,1
 57e:	fff4c903          	lbu	s2,-1(s1)
 582:	14090d63          	beqz	s2,6dc <vprintf+0x1c0>
    if(state == 0){
 586:	fe0999e3          	bnez	s3,578 <vprintf+0x5c>
      if(c == '%'){
 58a:	ff4910e3          	bne	s2,s4,56a <vprintf+0x4e>
        state = '%';
 58e:	89d2                	mv	s3,s4
 590:	b7f5                	j	57c <vprintf+0x60>
      if(c == 'd'){
 592:	11490c63          	beq	s2,s4,6aa <vprintf+0x18e>
 596:	f9d9079b          	addiw	a5,s2,-99
 59a:	0ff7f793          	zext.b	a5,a5
 59e:	10fc6e63          	bltu	s8,a5,6ba <vprintf+0x19e>
 5a2:	f9d9079b          	addiw	a5,s2,-99
 5a6:	0ff7f713          	zext.b	a4,a5
 5aa:	10ec6863          	bltu	s8,a4,6ba <vprintf+0x19e>
 5ae:	00271793          	slli	a5,a4,0x2
 5b2:	97e6                	add	a5,a5,s9
 5b4:	439c                	lw	a5,0(a5)
 5b6:	97e6                	add	a5,a5,s9
 5b8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5ba:	008b0913          	addi	s2,s6,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000b2583          	lw	a1,0(s6)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ea8080e7          	jalr	-344(ra) # 470 <printint>
 5d0:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b765                	j	57c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	008b0913          	addi	s2,s6,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000b2583          	lw	a1,0(s6)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e8c080e7          	jalr	-372(ra) # 470 <printint>
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b771                	j	57c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5f2:	008b0913          	addi	s2,s6,8
 5f6:	4681                	li	a3,0
 5f8:	866a                	mv	a2,s10
 5fa:	000b2583          	lw	a1,0(s6)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e70080e7          	jalr	-400(ra) # 470 <printint>
 608:	8b4a                	mv	s6,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bf85                	j	57c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 60e:	008b0793          	addi	a5,s6,8
 612:	f8f43423          	sd	a5,-120(s0)
 616:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 61a:	03000593          	li	a1,48
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e2e080e7          	jalr	-466(ra) # 44e <putc>
  putc(fd, 'x');
 628:	07800593          	li	a1,120
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	e20080e7          	jalr	-480(ra) # 44e <putc>
 636:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 638:	03c9d793          	srli	a5,s3,0x3c
 63c:	97de                	add	a5,a5,s7
 63e:	0007c583          	lbu	a1,0(a5)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e0a080e7          	jalr	-502(ra) # 44e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 64c:	0992                	slli	s3,s3,0x4
 64e:	397d                	addiw	s2,s2,-1
 650:	fe0914e3          	bnez	s2,638 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 654:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 658:	4981                	li	s3,0
 65a:	b70d                	j	57c <vprintf+0x60>
        s = va_arg(ap, char*);
 65c:	008b0913          	addi	s2,s6,8
 660:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 664:	02098163          	beqz	s3,686 <vprintf+0x16a>
        while(*s != 0){
 668:	0009c583          	lbu	a1,0(s3)
 66c:	c5ad                	beqz	a1,6d6 <vprintf+0x1ba>
          putc(fd, *s);
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	dde080e7          	jalr	-546(ra) # 44e <putc>
          s++;
 678:	0985                	addi	s3,s3,1
        while(*s != 0){
 67a:	0009c583          	lbu	a1,0(s3)
 67e:	f9e5                	bnez	a1,66e <vprintf+0x152>
        s = va_arg(ap, char*);
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bde5                	j	57c <vprintf+0x60>
          s = "(null)";
 686:	00000997          	auipc	s3,0x0
 68a:	26298993          	addi	s3,s3,610 # 8e8 <malloc+0x108>
        while(*s != 0){
 68e:	85ee                	mv	a1,s11
 690:	bff9                	j	66e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 692:	008b0913          	addi	s2,s6,8
 696:	000b4583          	lbu	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	db2080e7          	jalr	-590(ra) # 44e <putc>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bdd1                	j	57c <vprintf+0x60>
        putc(fd, c);
 6aa:	85d2                	mv	a1,s4
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	da0080e7          	jalr	-608(ra) # 44e <putc>
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b5d1                	j	57c <vprintf+0x60>
        putc(fd, '%');
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	d90080e7          	jalr	-624(ra) # 44e <putc>
        putc(fd, c);
 6c6:	85ca                	mv	a1,s2
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	d84080e7          	jalr	-636(ra) # 44e <putc>
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	b565                	j	57c <vprintf+0x60>
        s = va_arg(ap, char*);
 6d6:	8b4a                	mv	s6,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b54d                	j	57c <vprintf+0x60>
    }
  }
}
 6dc:	70e6                	ld	ra,120(sp)
 6de:	7446                	ld	s0,112(sp)
 6e0:	74a6                	ld	s1,104(sp)
 6e2:	7906                	ld	s2,96(sp)
 6e4:	69e6                	ld	s3,88(sp)
 6e6:	6a46                	ld	s4,80(sp)
 6e8:	6aa6                	ld	s5,72(sp)
 6ea:	6b06                	ld	s6,64(sp)
 6ec:	7be2                	ld	s7,56(sp)
 6ee:	7c42                	ld	s8,48(sp)
 6f0:	7ca2                	ld	s9,40(sp)
 6f2:	7d02                	ld	s10,32(sp)
 6f4:	6de2                	ld	s11,24(sp)
 6f6:	6109                	addi	sp,sp,128
 6f8:	8082                	ret

00000000000006fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6fa:	715d                	addi	sp,sp,-80
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	1000                	addi	s0,sp,32
 702:	e010                	sd	a2,0(s0)
 704:	e414                	sd	a3,8(s0)
 706:	e818                	sd	a4,16(s0)
 708:	ec1c                	sd	a5,24(s0)
 70a:	03043023          	sd	a6,32(s0)
 70e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 712:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 716:	8622                	mv	a2,s0
 718:	00000097          	auipc	ra,0x0
 71c:	e04080e7          	jalr	-508(ra) # 51c <vprintf>
}
 720:	60e2                	ld	ra,24(sp)
 722:	6442                	ld	s0,16(sp)
 724:	6161                	addi	sp,sp,80
 726:	8082                	ret

0000000000000728 <printf>:

void
printf(const char *fmt, ...)
{
 728:	711d                	addi	sp,sp,-96
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	e40c                	sd	a1,8(s0)
 732:	e810                	sd	a2,16(s0)
 734:	ec14                	sd	a3,24(s0)
 736:	f018                	sd	a4,32(s0)
 738:	f41c                	sd	a5,40(s0)
 73a:	03043823          	sd	a6,48(s0)
 73e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	00840613          	addi	a2,s0,8
 746:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 74a:	85aa                	mv	a1,a0
 74c:	4505                	li	a0,1
 74e:	00000097          	auipc	ra,0x0
 752:	dce080e7          	jalr	-562(ra) # 51c <vprintf>
}
 756:	60e2                	ld	ra,24(sp)
 758:	6442                	ld	s0,16(sp)
 75a:	6125                	addi	sp,sp,96
 75c:	8082                	ret

000000000000075e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75e:	1141                	addi	sp,sp,-16
 760:	e422                	sd	s0,8(sp)
 762:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 764:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	00001797          	auipc	a5,0x1
 76c:	8a87b783          	ld	a5,-1880(a5) # 1010 <freep>
 770:	a02d                	j	79a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 772:	4618                	lw	a4,8(a2)
 774:	9f2d                	addw	a4,a4,a1
 776:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77a:	6398                	ld	a4,0(a5)
 77c:	6310                	ld	a2,0(a4)
 77e:	a83d                	j	7bc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 780:	ff852703          	lw	a4,-8(a0)
 784:	9f31                	addw	a4,a4,a2
 786:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 788:	ff053683          	ld	a3,-16(a0)
 78c:	a091                	j	7d0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78e:	6398                	ld	a4,0(a5)
 790:	00e7e463          	bltu	a5,a4,798 <free+0x3a>
 794:	00e6ea63          	bltu	a3,a4,7a8 <free+0x4a>
{
 798:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79a:	fed7fae3          	bgeu	a5,a3,78e <free+0x30>
 79e:	6398                	ld	a4,0(a5)
 7a0:	00e6e463          	bltu	a3,a4,7a8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a4:	fee7eae3          	bltu	a5,a4,798 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7a8:	ff852583          	lw	a1,-8(a0)
 7ac:	6390                	ld	a2,0(a5)
 7ae:	02059813          	slli	a6,a1,0x20
 7b2:	01c85713          	srli	a4,a6,0x1c
 7b6:	9736                	add	a4,a4,a3
 7b8:	fae60de3          	beq	a2,a4,772 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7bc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c0:	4790                	lw	a2,8(a5)
 7c2:	02061593          	slli	a1,a2,0x20
 7c6:	01c5d713          	srli	a4,a1,0x1c
 7ca:	973e                	add	a4,a4,a5
 7cc:	fae68ae3          	beq	a3,a4,780 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d2:	00001717          	auipc	a4,0x1
 7d6:	82f73f23          	sd	a5,-1986(a4) # 1010 <freep>
}
 7da:	6422                	ld	s0,8(sp)
 7dc:	0141                	addi	sp,sp,16
 7de:	8082                	ret

00000000000007e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e0:	7139                	addi	sp,sp,-64
 7e2:	fc06                	sd	ra,56(sp)
 7e4:	f822                	sd	s0,48(sp)
 7e6:	f426                	sd	s1,40(sp)
 7e8:	f04a                	sd	s2,32(sp)
 7ea:	ec4e                	sd	s3,24(sp)
 7ec:	e852                	sd	s4,16(sp)
 7ee:	e456                	sd	s5,8(sp)
 7f0:	e05a                	sd	s6,0(sp)
 7f2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f4:	02051493          	slli	s1,a0,0x20
 7f8:	9081                	srli	s1,s1,0x20
 7fa:	04bd                	addi	s1,s1,15
 7fc:	8091                	srli	s1,s1,0x4
 7fe:	0014899b          	addiw	s3,s1,1
 802:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 804:	00001517          	auipc	a0,0x1
 808:	80c53503          	ld	a0,-2036(a0) # 1010 <freep>
 80c:	c515                	beqz	a0,838 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 810:	4798                	lw	a4,8(a5)
 812:	02977f63          	bgeu	a4,s1,850 <malloc+0x70>
 816:	8a4e                	mv	s4,s3
 818:	0009871b          	sext.w	a4,s3
 81c:	6685                	lui	a3,0x1
 81e:	00d77363          	bgeu	a4,a3,824 <malloc+0x44>
 822:	6a05                	lui	s4,0x1
 824:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 828:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82c:	00000917          	auipc	s2,0x0
 830:	7e490913          	addi	s2,s2,2020 # 1010 <freep>
  if(p == (char*)-1)
 834:	5afd                	li	s5,-1
 836:	a895                	j	8aa <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 838:	00000797          	auipc	a5,0x0
 83c:	7f878793          	addi	a5,a5,2040 # 1030 <base>
 840:	00000717          	auipc	a4,0x0
 844:	7cf73823          	sd	a5,2000(a4) # 1010 <freep>
 848:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 84e:	b7e1                	j	816 <malloc+0x36>
      if(p->s.size == nunits)
 850:	02e48c63          	beq	s1,a4,888 <malloc+0xa8>
        p->s.size -= nunits;
 854:	4137073b          	subw	a4,a4,s3
 858:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85a:	02071693          	slli	a3,a4,0x20
 85e:	01c6d713          	srli	a4,a3,0x1c
 862:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 864:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 868:	00000717          	auipc	a4,0x0
 86c:	7aa73423          	sd	a0,1960(a4) # 1010 <freep>
      return (void*)(p + 1);
 870:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 874:	70e2                	ld	ra,56(sp)
 876:	7442                	ld	s0,48(sp)
 878:	74a2                	ld	s1,40(sp)
 87a:	7902                	ld	s2,32(sp)
 87c:	69e2                	ld	s3,24(sp)
 87e:	6a42                	ld	s4,16(sp)
 880:	6aa2                	ld	s5,8(sp)
 882:	6b02                	ld	s6,0(sp)
 884:	6121                	addi	sp,sp,64
 886:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 888:	6398                	ld	a4,0(a5)
 88a:	e118                	sd	a4,0(a0)
 88c:	bff1                	j	868 <malloc+0x88>
  hp->s.size = nu;
 88e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 892:	0541                	addi	a0,a0,16
 894:	00000097          	auipc	ra,0x0
 898:	eca080e7          	jalr	-310(ra) # 75e <free>
  return freep;
 89c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a0:	d971                	beqz	a0,874 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	fa9775e3          	bgeu	a4,s1,850 <malloc+0x70>
    if(p == freep)
 8aa:	00093703          	ld	a4,0(s2)
 8ae:	853e                	mv	a0,a5
 8b0:	fef719e3          	bne	a4,a5,8a2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8b4:	8552                	mv	a0,s4
 8b6:	00000097          	auipc	ra,0x0
 8ba:	b80080e7          	jalr	-1152(ra) # 436 <sbrk>
  if(p == (char*)-1)
 8be:	fd5518e3          	bne	a0,s5,88e <malloc+0xae>
        return 0;
 8c2:	4501                	li	a0,0
 8c4:	bf45                	j	874 <malloc+0x94>
