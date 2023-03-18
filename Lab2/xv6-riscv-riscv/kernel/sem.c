#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#define N_SEM 10

int sem;
int value;

struct semaphore 
{
    int active; // Indica si el semáforo está siendo utilizado o no
    int value;  // Indica el valor actual del semáforo                                    
    struct spinlock slock;  
                            // Spinlock que asegura que las operaciones sean átomicas y 
                            // no ocurran interrupciones durante ellas 
                            //(Por esto siempre se hacen acquire y release al principio y al final)
};

struct semaphore a[N_SEM];


uint64
sys_sem_open(void){
        argint(0, &sem);
        argint(1, &value);
        int b = sem;
                
        if (b > N_SEM ){
            printf("semaphore non-exist, max-amount of semaphores : %d\n", N_SEM);
            exit(1);   
        }
        
        initlock(&a[b].slock,"semaphore");

        acquire(&a[b].slock);

        if(a[b].active == 0) // Si el semáforo ya estaba activo no hago nada
        {
            a[b].active = 1;  // Indico que el semáforo esta activo
            a[b].value=value; // Seteo el semaforo con el value pasado como argumento 
            release(&a[b].slock);
        }

        return b;
    }

uint64
sys_sem_up(void){
    argint(0, &sem);
    int b = sem;
       
    acquire(&a[b].slock); 
   

    if(a[b].value>=0)
        wakeup(&a[b]);  // Si el valor previo del semáforo era 0, despierto a todos los procesos bloqueados
    
    a[b].value=a[b].value+1;
    
    release(&a[b].slock);  

    return b;
}

uint64
sys_sem_down(void){
    argint(0, &sem);
    int b = sem;
      
    acquire(&a[b].slock);
        
    while(a[b].value <= 0)
        sleep(&a[b], &a[b].slock);  // Si la sección critica a la que se quiere acceder no está disponible se suspende el proceso
        
    a[b].value=a[b].value-1;

   
    release(&a[b].slock);
    return b;
}

uint64
sys_sem_close(void){
    argint(0, &sem);
    int b = sem;
    acquire(&a[b].slock);
    a[b].active = 0;
    
    release(&a[b].slock);
    return b;
    }