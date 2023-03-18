#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int sem_ping;
int sem_pong;
/*
Version con 2 semaforos
*/
int ping_proc(int n_pings)
{
  int ping_pid = fork();
    if(ping_pid == -1)
    {
      printf("error de fork");
      exit(1);
    }
    else if(ping_pid == 0)
    {
      for (int i = 0; i < n_pings; i++)
      {
        sem_ping = sem_down(sem_ping);
        printf("ping\n");
        sem_pong = sem_up(sem_pong);
      }

      exit(0);
    }

  return ping_pid;
}
int pong_proc(int n_pongs)
{
  int pong_pid = fork();
    if(pong_pid == -1)
    {
      printf("error de fork");
      exit(1);
    }
    else if(pong_pid == 0)
    {
      for (int i = 0; i < n_pongs; i++)
      {
        sem_pong = sem_down(sem_pong);
        printf("\tpong\n");
        sem_ping = sem_up(sem_ping);
      }

      exit(0);
    }
  
  return pong_pid;
}

int
main(int argc, char *argv[])
{
  int n_pingpong = atoi(argv[1]);

  sem_ping = sem_open(10,1);
  sem_pong = sem_open(4,0);


  //printf("sem_ping :%d  sem_pong:%d\n",sem_ping, sem_pong);
 
  ping_proc(n_pingpong);
  pong_proc(n_pingpong);

  sem_ping = sem_close(sem_ping);
  sem_pong = sem_close(sem_pong);

  wait(0);
  wait(0);// para esperar a los ping y pongs (?)
  
  //printf("sem_ping :%d  sem_pong:%d\n",sem_ping, sem_pong);

  //printf("el padre de nuevo\n");
  // si se usan los waits en las funciones ping_proc y pong_proc 
  // se esperan entre sí y se aprecia que se esta imprimiendo ping y pong de manera correcta
  // como los procesos se pisan parece que hace cualquier cosa (para eso necesitamos el semaforo)
  exit(0);
}
