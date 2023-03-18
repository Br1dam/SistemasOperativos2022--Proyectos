#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

#define N 128
#define TIMES 32
#define MINTICKS 100

static float a[N][N];
static float b[N][N];
static float c[N][N];

static void init(void) {
  int x, y;
  for (y = 0; y < N; ++y) {
    for (x = 0; x < N; ++x) {
      a[y][x] = y - x;
      b[y][x] = x - y;
      c[y][x] = 0.0f;
    }
  }
}

static void matmul(float beta) {
  int x, y, k;
  for (y = 0; y < N; ++y) {
    for (x = 0; x < N; ++x) {
      for (k = 0; k < N; ++k) {
        c[y][x] += beta * a[y][k] * b[k][x];
      }
    }
  }
}

int
main(int argc, char *argv[])
{
  int pid = getpid();
  float beta = 1.0f;

  init();
  int start = uptime();
  long ops = 0;
  for(;;) {
    int end = uptime();
    int elapsed = end - start;
    if (elapsed >= MINTICKS) {
        printf("%d: %d KFLOP%dT\n", pid, (int) ((ops / 1000) / elapsed), MINTICKS);

        start = end;
        ops = 0;
    }

    for(int i = 0; i < TIMES; ++i) {
        matmul(beta);
        beta = -beta;
        ops += 3 * N * N * N;
    }
  }

  printf("%x\n", c[0][0]);
  exit(0);
}

