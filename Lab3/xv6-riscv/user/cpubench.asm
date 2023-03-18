
user/_cpubench:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
  }
}

int
main(int argc, char *argv[])
{
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	fca6                	sd	s1,120(sp)
   8:	f8ca                	sd	s2,112(sp)
   a:	f4ce                	sd	s3,104(sp)
   c:	f0d2                	sd	s4,96(sp)
   e:	ecd6                	sd	s5,88(sp)
  10:	e8da                	sd	s6,80(sp)
  12:	e4de                	sd	s7,72(sp)
  14:	e0e2                	sd	s8,64(sp)
  16:	fc66                	sd	s9,56(sp)
  18:	f86a                	sd	s10,48(sp)
  1a:	f46e                	sd	s11,40(sp)
  1c:	ac22                	fsd	fs0,24(sp)
  1e:	0900                	addi	s0,sp,144
  int pid = getpid();
  20:	00000097          	auipc	ra,0x0
  24:	448080e7          	jalr	1096(ra) # 468 <getpid>
  28:	f6a43c23          	sd	a0,-136(s0)
  for (y = 0; y < N; ++y) {
  2c:	00021d97          	auipc	s11,0x21
  30:	fe4d8d93          	addi	s11,s11,-28 # 21010 <a>
  34:	00011d17          	auipc	s10,0x11
  38:	fdcd0d13          	addi	s10,s10,-36 # 11010 <b>
  3c:	00001997          	auipc	s3,0x1
  40:	fd498993          	addi	s3,s3,-44 # 1010 <c>
  int pid = getpid();
  44:	854e                	mv	a0,s3
  46:	85ea                	mv	a1,s10
  48:	866e                	mv	a2,s11
  for (y = 0; y < N; ++y) {
  4a:	4681                	li	a3,0
  4c:	08000e13          	li	t3,128
  50:	a811                	j	64 <main+0x64>
  52:	2685                	addiw	a3,a3,1
  54:	20060613          	addi	a2,a2,512
  58:	20058593          	addi	a1,a1,512
  5c:	20050513          	addi	a0,a0,512
  60:	03c68d63          	beq	a3,t3,9a <main+0x9a>
    for (x = 0; x < N; ++x) {
  64:	0006879b          	sext.w	a5,a3
{
  68:	832a                	mv	t1,a0
  6a:	88ae                	mv	a7,a1
  6c:	8832                	mv	a6,a2
  6e:	873e                	mv	a4,a5
    for (x = 0; x < N; ++x) {
  70:	f807879b          	addiw	a5,a5,-128
      a[y][x] = y - x;
  74:	d00777d3          	fcvt.s.w	fa5,a4
  78:	00f82027          	fsw	fa5,0(a6)
      b[y][x] = x - y;
  7c:	40e00ebb          	negw	t4,a4
  80:	d00ef7d3          	fcvt.s.w	fa5,t4
  84:	00f8a027          	fsw	fa5,0(a7)
      c[y][x] = 0.0f;
  88:	00032023          	sw	zero,0(t1)
    for (x = 0; x < N; ++x) {
  8c:	377d                	addiw	a4,a4,-1
  8e:	0811                	addi	a6,a6,4
  90:	0891                	addi	a7,a7,4
  92:	0311                	addi	t1,t1,4
  94:	fee790e3          	bne	a5,a4,74 <main+0x74>
  98:	bf6d                	j	52 <main+0x52>
  float beta = 1.0f;

  init();
  int start = uptime();
  9a:	00000097          	auipc	ra,0x0
  9e:	3e6080e7          	jalr	998(ra) # 480 <uptime>
  a2:	8caa                	mv	s9,a0
  long ops = 0;
  a4:	4481                	li	s1,0
  float beta = 1.0f;
  a6:	00001797          	auipc	a5,0x1
  aa:	85a7a407          	flw	fs0,-1958(a5) # 900 <malloc+0xe6>
  for(;;) {
    int end = uptime();
    int elapsed = end - start;
    if (elapsed >= MINTICKS) {
  ae:	06300b13          	li	s6,99
        printf("%d: %d KFLOP%dT\n", pid, (int) ((ops / 1000) / elapsed), MINTICKS);
  b2:	3e800a93          	li	s5,1000
  b6:	00001c17          	auipc	s8,0x1
  ba:	85ac0c13          	addi	s8,s8,-1958 # 910 <malloc+0xf6>
  be:	6941                	lui	s2,0x10
  c0:	20090913          	addi	s2,s2,512 # 10200 <c+0xf1f0>
  c4:	994e                	add	s2,s2,s3
    }

    for(int i = 0; i < TIMES; ++i) {
        matmul(beta);
        beta = -beta;
        ops += 3 * N * N * N;
  c6:	0c000a37          	lui	s4,0xc000
  ca:	a041                	j	14a <main+0x14a>
        printf("%d: %d KFLOP%dT\n", pid, (int) ((ops / 1000) / elapsed), MINTICKS);
  cc:	0354c633          	div	a2,s1,s5
  d0:	02f64633          	div	a2,a2,a5
  d4:	06400693          	li	a3,100
  d8:	2601                	sext.w	a2,a2
  da:	f7843583          	ld	a1,-136(s0)
  de:	8562                	mv	a0,s8
  e0:	00000097          	auipc	ra,0x0
  e4:	682080e7          	jalr	1666(ra) # 762 <printf>
        start = end;
  e8:	8cde                	mv	s9,s7
        ops = 0;
  ea:	4481                	li	s1,0
  ec:	a885                	j	15c <main+0x15c>
  for (y = 0; y < N; ++y) {
  ee:	20078793          	addi	a5,a5,512
  f2:	05278363          	beq	a5,s2,138 <main+0x138>
  f6:	85c6                	mv	a1,a7
    for (x = 0; x < N; ++x) {
  f8:	e0078713          	addi	a4,a5,-512
        ops = 0;
  fc:	856a                	mv	a0,s10
  fe:	20058893          	addi	a7,a1,512
      for (k = 0; k < N; ++k) {
 102:	833a                	mv	t1,a4
 104:	00072707          	flw	fa4,0(a4)
        ops = 0;
 108:	882a                	mv	a6,a0
 10a:	86ae                	mv	a3,a1
        c[y][x] += beta * a[y][k] * b[k][x];
 10c:	0006a787          	flw	fa5,0(a3)
 110:	10f477d3          	fmul.s	fa5,fs0,fa5
 114:	00082687          	flw	fa3,0(a6)
 118:	10d7f7d3          	fmul.s	fa5,fa5,fa3
 11c:	00f77753          	fadd.s	fa4,fa4,fa5
      for (k = 0; k < N; ++k) {
 120:	0691                	addi	a3,a3,4
 122:	20080813          	addi	a6,a6,512
 126:	ff1693e3          	bne	a3,a7,10c <main+0x10c>
 12a:	00e32027          	fsw	fa4,0(t1)
    for (x = 0; x < N; ++x) {
 12e:	0711                	addi	a4,a4,4
 130:	0511                	addi	a0,a0,4
 132:	fcf718e3          	bne	a4,a5,102 <main+0x102>
 136:	bf65                	j	ee <main+0xee>
        beta = -beta;
 138:	20841453          	fneg.s	fs0,fs0
    for(int i = 0; i < TIMES; ++i) {
 13c:	367d                	addiw	a2,a2,-1
 13e:	c609                	beqz	a2,148 <main+0x148>
  for (y = 0; y < N; ++y) {
 140:	20098793          	addi	a5,s3,512
 144:	85ee                	mv	a1,s11
 146:	bf4d                	j	f8 <main+0xf8>
        ops += 3 * N * N * N;
 148:	94d2                	add	s1,s1,s4
    int end = uptime();
 14a:	00000097          	auipc	ra,0x0
 14e:	336080e7          	jalr	822(ra) # 480 <uptime>
 152:	8baa                	mv	s7,a0
    int elapsed = end - start;
 154:	419507bb          	subw	a5,a0,s9
    if (elapsed >= MINTICKS) {
 158:	f6fb4ae3          	blt	s6,a5,cc <main+0xcc>
    for(int i = 0; i < TIMES; ++i) {
 15c:	02000613          	li	a2,32
 160:	b7c5                	j	140 <main+0x140>

0000000000000162 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 162:	1141                	addi	sp,sp,-16
 164:	e406                	sd	ra,8(sp)
 166:	e022                	sd	s0,0(sp)
 168:	0800                	addi	s0,sp,16
  extern int main();
  main();
 16a:	00000097          	auipc	ra,0x0
 16e:	e96080e7          	jalr	-362(ra) # 0 <main>
  exit(0);
 172:	4501                	li	a0,0
 174:	00000097          	auipc	ra,0x0
 178:	274080e7          	jalr	628(ra) # 3e8 <exit>

000000000000017c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 182:	87aa                	mv	a5,a0
 184:	0585                	addi	a1,a1,1
 186:	0785                	addi	a5,a5,1
 188:	fff5c703          	lbu	a4,-1(a1)
 18c:	fee78fa3          	sb	a4,-1(a5)
 190:	fb75                	bnez	a4,184 <strcpy+0x8>
    ;
  return os;
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cb91                	beqz	a5,1b6 <strcmp+0x1e>
 1a4:	0005c703          	lbu	a4,0(a1)
 1a8:	00f71763          	bne	a4,a5,1b6 <strcmp+0x1e>
    p++, q++;
 1ac:	0505                	addi	a0,a0,1
 1ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbe5                	bnez	a5,1a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b6:	0005c503          	lbu	a0,0(a1)
}
 1ba:	40a7853b          	subw	a0,a5,a0
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret

00000000000001c4 <strlen>:

uint
strlen(const char *s)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	cf91                	beqz	a5,1ea <strlen+0x26>
 1d0:	0505                	addi	a0,a0,1
 1d2:	87aa                	mv	a5,a0
 1d4:	4685                	li	a3,1
 1d6:	9e89                	subw	a3,a3,a0
 1d8:	00f6853b          	addw	a0,a3,a5
 1dc:	0785                	addi	a5,a5,1
 1de:	fff7c703          	lbu	a4,-1(a5)
 1e2:	fb7d                	bnez	a4,1d8 <strlen+0x14>
    ;
  return n;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <strlen+0x20>

00000000000001ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f4:	ca19                	beqz	a2,20a <memset+0x1c>
 1f6:	87aa                	mv	a5,a0
 1f8:	1602                	slli	a2,a2,0x20
 1fa:	9201                	srli	a2,a2,0x20
 1fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 200:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 204:	0785                	addi	a5,a5,1
 206:	fee79de3          	bne	a5,a4,200 <memset+0x12>
  }
  return dst;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strchr>:

char*
strchr(const char *s, char c)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cb99                	beqz	a5,230 <strchr+0x20>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1a>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xc>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  return 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <strchr+0x1a>

0000000000000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	711d                	addi	sp,sp,-96
 236:	ec86                	sd	ra,88(sp)
 238:	e8a2                	sd	s0,80(sp)
 23a:	e4a6                	sd	s1,72(sp)
 23c:	e0ca                	sd	s2,64(sp)
 23e:	fc4e                	sd	s3,56(sp)
 240:	f852                	sd	s4,48(sp)
 242:	f456                	sd	s5,40(sp)
 244:	f05a                	sd	s6,32(sp)
 246:	ec5e                	sd	s7,24(sp)
 248:	1080                	addi	s0,sp,96
 24a:	8baa                	mv	s7,a0
 24c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24e:	892a                	mv	s2,a0
 250:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 252:	4aa9                	li	s5,10
 254:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 256:	89a6                	mv	s3,s1
 258:	2485                	addiw	s1,s1,1
 25a:	0344d863          	bge	s1,s4,28a <gets+0x56>
    cc = read(0, &c, 1);
 25e:	4605                	li	a2,1
 260:	faf40593          	addi	a1,s0,-81
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	19a080e7          	jalr	410(ra) # 400 <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x56>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x54>
 27e:	0905                	addi	s2,s2,1
 280:	fd679be3          	bne	a5,s6,256 <gets+0x22>
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	a011                	j	28a <gets+0x56>
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3)
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e426                	sd	s1,8(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	170080e7          	jalr	368(ra) # 428 <open>
  if(fd < 0)
 2c0:	02054563          	bltz	a0,2ea <stat+0x42>
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	178080e7          	jalr	376(ra) # 440 <fstat>
 2d0:	892a                	mv	s2,a0
  close(fd);
 2d2:	8526                	mv	a0,s1
 2d4:	00000097          	auipc	ra,0x0
 2d8:	13c080e7          	jalr	316(ra) # 410 <close>
  return r;
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	64a2                	ld	s1,8(sp)
 2e4:	6902                	ld	s2,0(sp)
 2e6:	6105                	addi	sp,sp,32
 2e8:	8082                	ret
    return -1;
 2ea:	597d                	li	s2,-1
 2ec:	bfc5                	j	2dc <stat+0x34>

00000000000002ee <atoi>:

int
atoi(const char *s)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f4:	00054683          	lbu	a3,0(a0)
 2f8:	fd06879b          	addiw	a5,a3,-48
 2fc:	0ff7f793          	zext.b	a5,a5
 300:	4625                	li	a2,9
 302:	02f66863          	bltu	a2,a5,332 <atoi+0x44>
 306:	872a                	mv	a4,a0
  n = 0;
 308:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 30a:	0705                	addi	a4,a4,1
 30c:	0025179b          	slliw	a5,a0,0x2
 310:	9fa9                	addw	a5,a5,a0
 312:	0017979b          	slliw	a5,a5,0x1
 316:	9fb5                	addw	a5,a5,a3
 318:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31c:	00074683          	lbu	a3,0(a4)
 320:	fd06879b          	addiw	a5,a3,-48
 324:	0ff7f793          	zext.b	a5,a5
 328:	fef671e3          	bgeu	a2,a5,30a <atoi+0x1c>
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  n = 0;
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <atoi+0x3e>

0000000000000336 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33c:	02b57463          	bgeu	a0,a1,364 <memmove+0x2e>
    while(n-- > 0)
 340:	00c05f63          	blez	a2,35e <memmove+0x28>
 344:	1602                	slli	a2,a2,0x20
 346:	9201                	srli	a2,a2,0x20
 348:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
    dst += n;
 364:	00c50733          	add	a4,a0,a2
    src += n;
 368:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36a:	fec05ae3          	blez	a2,35e <memmove+0x28>
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	fff7c793          	not	a5,a5
 37a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37c:	15fd                	addi	a1,a1,-1
 37e:	177d                	addi	a4,a4,-1
 380:	0005c683          	lbu	a3,0(a1)
 384:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 388:	fee79ae3          	bne	a5,a4,37c <memmove+0x46>
 38c:	bfc9                	j	35e <memmove+0x28>

000000000000038e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 394:	ca05                	beqz	a2,3c4 <memcmp+0x36>
 396:	fff6069b          	addiw	a3,a2,-1
 39a:	1682                	slli	a3,a3,0x20
 39c:	9281                	srli	a3,a3,0x20
 39e:	0685                	addi	a3,a3,1
 3a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x14>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x30>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	bfe5                	j	3be <memcmp+0x30>

00000000000003c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d0:	00000097          	auipc	ra,0x0
 3d4:	f66080e7          	jalr	-154(ra) # 336 <memmove>
}
 3d8:	60a2                	ld	ra,8(sp)
 3da:	6402                	ld	s0,0(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e0:	4885                	li	a7,1
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e8:	4889                	li	a7,2
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f0:	488d                	li	a7,3
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f8:	4891                	li	a7,4
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <read>:
.global read
read:
 li a7, SYS_read
 400:	4895                	li	a7,5
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <write>:
.global write
write:
 li a7, SYS_write
 408:	48c1                	li	a7,16
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <close>:
.global close
close:
 li a7, SYS_close
 410:	48d5                	li	a7,21
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <kill>:
.global kill
kill:
 li a7, SYS_kill
 418:	4899                	li	a7,6
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <exec>:
.global exec
exec:
 li a7, SYS_exec
 420:	489d                	li	a7,7
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <open>:
.global open
open:
 li a7, SYS_open
 428:	48bd                	li	a7,15
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 430:	48c5                	li	a7,17
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 438:	48c9                	li	a7,18
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 440:	48a1                	li	a7,8
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <link>:
.global link
link:
 li a7, SYS_link
 448:	48cd                	li	a7,19
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 450:	48d1                	li	a7,20
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 458:	48a5                	li	a7,9
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <dup>:
.global dup
dup:
 li a7, SYS_dup
 460:	48a9                	li	a7,10
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 468:	48ad                	li	a7,11
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 470:	48b1                	li	a7,12
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 478:	48b5                	li	a7,13
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 480:	48b9                	li	a7,14
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 488:	1101                	addi	sp,sp,-32
 48a:	ec06                	sd	ra,24(sp)
 48c:	e822                	sd	s0,16(sp)
 48e:	1000                	addi	s0,sp,32
 490:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 494:	4605                	li	a2,1
 496:	fef40593          	addi	a1,s0,-17
 49a:	00000097          	auipc	ra,0x0
 49e:	f6e080e7          	jalr	-146(ra) # 408 <write>
}
 4a2:	60e2                	ld	ra,24(sp)
 4a4:	6442                	ld	s0,16(sp)
 4a6:	6105                	addi	sp,sp,32
 4a8:	8082                	ret

00000000000004aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4aa:	7139                	addi	sp,sp,-64
 4ac:	fc06                	sd	ra,56(sp)
 4ae:	f822                	sd	s0,48(sp)
 4b0:	f426                	sd	s1,40(sp)
 4b2:	f04a                	sd	s2,32(sp)
 4b4:	ec4e                	sd	s3,24(sp)
 4b6:	0080                	addi	s0,sp,64
 4b8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ba:	c299                	beqz	a3,4c0 <printint+0x16>
 4bc:	0805c963          	bltz	a1,54e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c0:	2581                	sext.w	a1,a1
  neg = 0;
 4c2:	4881                	li	a7,0
 4c4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ca:	2601                	sext.w	a2,a2
 4cc:	00000517          	auipc	a0,0x0
 4d0:	4bc50513          	addi	a0,a0,1212 # 988 <digits>
 4d4:	883a                	mv	a6,a4
 4d6:	2705                	addiw	a4,a4,1
 4d8:	02c5f7bb          	remuw	a5,a1,a2
 4dc:	1782                	slli	a5,a5,0x20
 4de:	9381                	srli	a5,a5,0x20
 4e0:	97aa                	add	a5,a5,a0
 4e2:	0007c783          	lbu	a5,0(a5)
 4e6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ea:	0005879b          	sext.w	a5,a1
 4ee:	02c5d5bb          	divuw	a1,a1,a2
 4f2:	0685                	addi	a3,a3,1
 4f4:	fec7f0e3          	bgeu	a5,a2,4d4 <printint+0x2a>
  if(neg)
 4f8:	00088c63          	beqz	a7,510 <printint+0x66>
    buf[i++] = '-';
 4fc:	fd070793          	addi	a5,a4,-48
 500:	00878733          	add	a4,a5,s0
 504:	02d00793          	li	a5,45
 508:	fef70823          	sb	a5,-16(a4)
 50c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 510:	02e05863          	blez	a4,540 <printint+0x96>
 514:	fc040793          	addi	a5,s0,-64
 518:	00e78933          	add	s2,a5,a4
 51c:	fff78993          	addi	s3,a5,-1
 520:	99ba                	add	s3,s3,a4
 522:	377d                	addiw	a4,a4,-1
 524:	1702                	slli	a4,a4,0x20
 526:	9301                	srli	a4,a4,0x20
 528:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 52c:	fff94583          	lbu	a1,-1(s2)
 530:	8526                	mv	a0,s1
 532:	00000097          	auipc	ra,0x0
 536:	f56080e7          	jalr	-170(ra) # 488 <putc>
  while(--i >= 0)
 53a:	197d                	addi	s2,s2,-1
 53c:	ff3918e3          	bne	s2,s3,52c <printint+0x82>
}
 540:	70e2                	ld	ra,56(sp)
 542:	7442                	ld	s0,48(sp)
 544:	74a2                	ld	s1,40(sp)
 546:	7902                	ld	s2,32(sp)
 548:	69e2                	ld	s3,24(sp)
 54a:	6121                	addi	sp,sp,64
 54c:	8082                	ret
    x = -xx;
 54e:	40b005bb          	negw	a1,a1
    neg = 1;
 552:	4885                	li	a7,1
    x = -xx;
 554:	bf85                	j	4c4 <printint+0x1a>

0000000000000556 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 556:	7119                	addi	sp,sp,-128
 558:	fc86                	sd	ra,120(sp)
 55a:	f8a2                	sd	s0,112(sp)
 55c:	f4a6                	sd	s1,104(sp)
 55e:	f0ca                	sd	s2,96(sp)
 560:	ecce                	sd	s3,88(sp)
 562:	e8d2                	sd	s4,80(sp)
 564:	e4d6                	sd	s5,72(sp)
 566:	e0da                	sd	s6,64(sp)
 568:	fc5e                	sd	s7,56(sp)
 56a:	f862                	sd	s8,48(sp)
 56c:	f466                	sd	s9,40(sp)
 56e:	f06a                	sd	s10,32(sp)
 570:	ec6e                	sd	s11,24(sp)
 572:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 574:	0005c903          	lbu	s2,0(a1)
 578:	18090f63          	beqz	s2,716 <vprintf+0x1c0>
 57c:	8aaa                	mv	s5,a0
 57e:	8b32                	mv	s6,a2
 580:	00158493          	addi	s1,a1,1
  state = 0;
 584:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 586:	02500a13          	li	s4,37
 58a:	4c55                	li	s8,21
 58c:	00000c97          	auipc	s9,0x0
 590:	3a4c8c93          	addi	s9,s9,932 # 930 <malloc+0x116>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 594:	02800d93          	li	s11,40
  putc(fd, 'x');
 598:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59a:	00000b97          	auipc	s7,0x0
 59e:	3eeb8b93          	addi	s7,s7,1006 # 988 <digits>
 5a2:	a839                	j	5c0 <vprintf+0x6a>
        putc(fd, c);
 5a4:	85ca                	mv	a1,s2
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ee0080e7          	jalr	-288(ra) # 488 <putc>
 5b0:	a019                	j	5b6 <vprintf+0x60>
    } else if(state == '%'){
 5b2:	01498d63          	beq	s3,s4,5cc <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5b6:	0485                	addi	s1,s1,1
 5b8:	fff4c903          	lbu	s2,-1(s1)
 5bc:	14090d63          	beqz	s2,716 <vprintf+0x1c0>
    if(state == 0){
 5c0:	fe0999e3          	bnez	s3,5b2 <vprintf+0x5c>
      if(c == '%'){
 5c4:	ff4910e3          	bne	s2,s4,5a4 <vprintf+0x4e>
        state = '%';
 5c8:	89d2                	mv	s3,s4
 5ca:	b7f5                	j	5b6 <vprintf+0x60>
      if(c == 'd'){
 5cc:	11490c63          	beq	s2,s4,6e4 <vprintf+0x18e>
 5d0:	f9d9079b          	addiw	a5,s2,-99
 5d4:	0ff7f793          	zext.b	a5,a5
 5d8:	10fc6e63          	bltu	s8,a5,6f4 <vprintf+0x19e>
 5dc:	f9d9079b          	addiw	a5,s2,-99
 5e0:	0ff7f713          	zext.b	a4,a5
 5e4:	10ec6863          	bltu	s8,a4,6f4 <vprintf+0x19e>
 5e8:	00271793          	slli	a5,a4,0x2
 5ec:	97e6                	add	a5,a5,s9
 5ee:	439c                	lw	a5,0(a5)
 5f0:	97e6                	add	a5,a5,s9
 5f2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b0913          	addi	s2,s6,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000b2583          	lw	a1,0(s6)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ea8080e7          	jalr	-344(ra) # 4aa <printint>
 60a:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b765                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	008b0913          	addi	s2,s6,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000b2583          	lw	a1,0(s6)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e8c080e7          	jalr	-372(ra) # 4aa <printint>
 626:	8b4a                	mv	s6,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b771                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 62c:	008b0913          	addi	s2,s6,8
 630:	4681                	li	a3,0
 632:	866a                	mv	a2,s10
 634:	000b2583          	lw	a1,0(s6)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e70080e7          	jalr	-400(ra) # 4aa <printint>
 642:	8b4a                	mv	s6,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	bf85                	j	5b6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 648:	008b0793          	addi	a5,s6,8
 64c:	f8f43423          	sd	a5,-120(s0)
 650:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 654:	03000593          	li	a1,48
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e2e080e7          	jalr	-466(ra) # 488 <putc>
  putc(fd, 'x');
 662:	07800593          	li	a1,120
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e20080e7          	jalr	-480(ra) # 488 <putc>
 670:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 672:	03c9d793          	srli	a5,s3,0x3c
 676:	97de                	add	a5,a5,s7
 678:	0007c583          	lbu	a1,0(a5)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e0a080e7          	jalr	-502(ra) # 488 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 686:	0992                	slli	s3,s3,0x4
 688:	397d                	addiw	s2,s2,-1
 68a:	fe0914e3          	bnez	s2,672 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 68e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 692:	4981                	li	s3,0
 694:	b70d                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 696:	008b0913          	addi	s2,s6,8
 69a:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 69e:	02098163          	beqz	s3,6c0 <vprintf+0x16a>
        while(*s != 0){
 6a2:	0009c583          	lbu	a1,0(s3)
 6a6:	c5ad                	beqz	a1,710 <vprintf+0x1ba>
          putc(fd, *s);
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	dde080e7          	jalr	-546(ra) # 488 <putc>
          s++;
 6b2:	0985                	addi	s3,s3,1
        while(*s != 0){
 6b4:	0009c583          	lbu	a1,0(s3)
 6b8:	f9e5                	bnez	a1,6a8 <vprintf+0x152>
        s = va_arg(ap, char*);
 6ba:	8b4a                	mv	s6,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bde5                	j	5b6 <vprintf+0x60>
          s = "(null)";
 6c0:	00000997          	auipc	s3,0x0
 6c4:	26898993          	addi	s3,s3,616 # 928 <malloc+0x10e>
        while(*s != 0){
 6c8:	85ee                	mv	a1,s11
 6ca:	bff9                	j	6a8 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6cc:	008b0913          	addi	s2,s6,8
 6d0:	000b4583          	lbu	a1,0(s6)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	db2080e7          	jalr	-590(ra) # 488 <putc>
 6de:	8b4a                	mv	s6,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bdd1                	j	5b6 <vprintf+0x60>
        putc(fd, c);
 6e4:	85d2                	mv	a1,s4
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	da0080e7          	jalr	-608(ra) # 488 <putc>
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b5d1                	j	5b6 <vprintf+0x60>
        putc(fd, '%');
 6f4:	85d2                	mv	a1,s4
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	d90080e7          	jalr	-624(ra) # 488 <putc>
        putc(fd, c);
 700:	85ca                	mv	a1,s2
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	d84080e7          	jalr	-636(ra) # 488 <putc>
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b565                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 710:	8b4a                	mv	s6,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	b54d                	j	5b6 <vprintf+0x60>
    }
  }
}
 716:	70e6                	ld	ra,120(sp)
 718:	7446                	ld	s0,112(sp)
 71a:	74a6                	ld	s1,104(sp)
 71c:	7906                	ld	s2,96(sp)
 71e:	69e6                	ld	s3,88(sp)
 720:	6a46                	ld	s4,80(sp)
 722:	6aa6                	ld	s5,72(sp)
 724:	6b06                	ld	s6,64(sp)
 726:	7be2                	ld	s7,56(sp)
 728:	7c42                	ld	s8,48(sp)
 72a:	7ca2                	ld	s9,40(sp)
 72c:	7d02                	ld	s10,32(sp)
 72e:	6de2                	ld	s11,24(sp)
 730:	6109                	addi	sp,sp,128
 732:	8082                	ret

0000000000000734 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 734:	715d                	addi	sp,sp,-80
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e010                	sd	a2,0(s0)
 73e:	e414                	sd	a3,8(s0)
 740:	e818                	sd	a4,16(s0)
 742:	ec1c                	sd	a5,24(s0)
 744:	03043023          	sd	a6,32(s0)
 748:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 750:	8622                	mv	a2,s0
 752:	00000097          	auipc	ra,0x0
 756:	e04080e7          	jalr	-508(ra) # 556 <vprintf>
}
 75a:	60e2                	ld	ra,24(sp)
 75c:	6442                	ld	s0,16(sp)
 75e:	6161                	addi	sp,sp,80
 760:	8082                	ret

0000000000000762 <printf>:

void
printf(const char *fmt, ...)
{
 762:	711d                	addi	sp,sp,-96
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e40c                	sd	a1,8(s0)
 76c:	e810                	sd	a2,16(s0)
 76e:	ec14                	sd	a3,24(s0)
 770:	f018                	sd	a4,32(s0)
 772:	f41c                	sd	a5,40(s0)
 774:	03043823          	sd	a6,48(s0)
 778:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	00840613          	addi	a2,s0,8
 780:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 784:	85aa                	mv	a1,a0
 786:	4505                	li	a0,1
 788:	00000097          	auipc	ra,0x0
 78c:	dce080e7          	jalr	-562(ra) # 556 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6125                	addi	sp,sp,96
 796:	8082                	ret

0000000000000798 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 798:	1141                	addi	sp,sp,-16
 79a:	e422                	sd	s0,8(sp)
 79c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	00001797          	auipc	a5,0x1
 7a6:	85e7b783          	ld	a5,-1954(a5) # 1000 <freep>
 7aa:	a02d                	j	7d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ac:	4618                	lw	a4,8(a2)
 7ae:	9f2d                	addw	a4,a4,a1
 7b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b4:	6398                	ld	a4,0(a5)
 7b6:	6310                	ld	a2,0(a4)
 7b8:	a83d                	j	7f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ba:	ff852703          	lw	a4,-8(a0)
 7be:	9f31                	addw	a4,a4,a2
 7c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c2:	ff053683          	ld	a3,-16(a0)
 7c6:	a091                	j	80a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c8:	6398                	ld	a4,0(a5)
 7ca:	00e7e463          	bltu	a5,a4,7d2 <free+0x3a>
 7ce:	00e6ea63          	bltu	a3,a4,7e2 <free+0x4a>
{
 7d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	fed7fae3          	bgeu	a5,a3,7c8 <free+0x30>
 7d8:	6398                	ld	a4,0(a5)
 7da:	00e6e463          	bltu	a3,a4,7e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7de:	fee7eae3          	bltu	a5,a4,7d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e2:	ff852583          	lw	a1,-8(a0)
 7e6:	6390                	ld	a2,0(a5)
 7e8:	02059813          	slli	a6,a1,0x20
 7ec:	01c85713          	srli	a4,a6,0x1c
 7f0:	9736                	add	a4,a4,a3
 7f2:	fae60de3          	beq	a2,a4,7ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fa:	4790                	lw	a2,8(a5)
 7fc:	02061593          	slli	a1,a2,0x20
 800:	01c5d713          	srli	a4,a1,0x1c
 804:	973e                	add	a4,a4,a5
 806:	fae68ae3          	beq	a3,a4,7ba <free+0x22>
    p->s.ptr = bp->s.ptr;
 80a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80c:	00000717          	auipc	a4,0x0
 810:	7ef73a23          	sd	a5,2036(a4) # 1000 <freep>
}
 814:	6422                	ld	s0,8(sp)
 816:	0141                	addi	sp,sp,16
 818:	8082                	ret

000000000000081a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81a:	7139                	addi	sp,sp,-64
 81c:	fc06                	sd	ra,56(sp)
 81e:	f822                	sd	s0,48(sp)
 820:	f426                	sd	s1,40(sp)
 822:	f04a                	sd	s2,32(sp)
 824:	ec4e                	sd	s3,24(sp)
 826:	e852                	sd	s4,16(sp)
 828:	e456                	sd	s5,8(sp)
 82a:	e05a                	sd	s6,0(sp)
 82c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82e:	02051493          	slli	s1,a0,0x20
 832:	9081                	srli	s1,s1,0x20
 834:	04bd                	addi	s1,s1,15
 836:	8091                	srli	s1,s1,0x4
 838:	0014899b          	addiw	s3,s1,1
 83c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 83e:	00000517          	auipc	a0,0x0
 842:	7c253503          	ld	a0,1986(a0) # 1000 <freep>
 846:	c515                	beqz	a0,872 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	02977f63          	bgeu	a4,s1,88a <malloc+0x70>
 850:	8a4e                	mv	s4,s3
 852:	0009871b          	sext.w	a4,s3
 856:	6685                	lui	a3,0x1
 858:	00d77363          	bgeu	a4,a3,85e <malloc+0x44>
 85c:	6a05                	lui	s4,0x1
 85e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 862:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 866:	00000917          	auipc	s2,0x0
 86a:	79a90913          	addi	s2,s2,1946 # 1000 <freep>
  if(p == (char*)-1)
 86e:	5afd                	li	s5,-1
 870:	a895                	j	8e4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 872:	00030797          	auipc	a5,0x30
 876:	79e78793          	addi	a5,a5,1950 # 31010 <base>
 87a:	00000717          	auipc	a4,0x0
 87e:	78f73323          	sd	a5,1926(a4) # 1000 <freep>
 882:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 884:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 888:	b7e1                	j	850 <malloc+0x36>
      if(p->s.size == nunits)
 88a:	02e48c63          	beq	s1,a4,8c2 <malloc+0xa8>
        p->s.size -= nunits;
 88e:	4137073b          	subw	a4,a4,s3
 892:	c798                	sw	a4,8(a5)
        p += p->s.size;
 894:	02071693          	slli	a3,a4,0x20
 898:	01c6d713          	srli	a4,a3,0x1c
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74a73f23          	sd	a0,1886(a4) # 1000 <freep>
      return (void*)(p + 1);
 8aa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	7902                	ld	s2,32(sp)
 8b6:	69e2                	ld	s3,24(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
 8be:	6121                	addi	sp,sp,64
 8c0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	e118                	sd	a4,0(a0)
 8c6:	bff1                	j	8a2 <malloc+0x88>
  hp->s.size = nu;
 8c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8cc:	0541                	addi	a0,a0,16
 8ce:	00000097          	auipc	ra,0x0
 8d2:	eca080e7          	jalr	-310(ra) # 798 <free>
  return freep;
 8d6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8da:	d971                	beqz	a0,8ae <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	fa9775e3          	bgeu	a4,s1,88a <malloc+0x70>
    if(p == freep)
 8e4:	00093703          	ld	a4,0(s2)
 8e8:	853e                	mv	a0,a5
 8ea:	fef719e3          	bne	a4,a5,8dc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8ee:	8552                	mv	a0,s4
 8f0:	00000097          	auipc	ra,0x0
 8f4:	b80080e7          	jalr	-1152(ra) # 470 <sbrk>
  if(p == (char*)-1)
 8f8:	fd5518e3          	bne	a0,s5,8c8 <malloc+0xae>
        return 0;
 8fc:	4501                	li	a0,0
 8fe:	bf45                	j	8ae <malloc+0x94>
