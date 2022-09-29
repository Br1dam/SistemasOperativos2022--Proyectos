#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"


int a[2] = {-1,-1};
int sem;
int value;
struct spinlock slock; // Nose si se puede, o esta bien usar el spinlock asi

uint64
sys_sem_open(void){
        argint(0, &sem);
        argint(1, &value);
        a[sem]=value;
        initlock(&slock , "semaphore");
        return sem;
    }

uint64
sys_sem_up(void){
    
    argint(0, &sem);
    if(a[sem]==0){    
        int pid_t = myproc()->pid;
        wakeup(&pid_t);  //  No se si es el "channel" correcto
        release(&slock);
        }
    a[sem]=a[sem]+1;
    return sem;
}

uint64
sys_sem_down(void){
    argint(0, &sem);
    acquire(&slock); //adquiere el lock
        if(a[sem]>0){
            a[sem]=a[sem]-1;
        }else{
            while(a[sem] == 0){
                int pid_t = myproc()->pid; // No se si es el "channel" correcto
                sleep(&pid_t, &slock);
            }
        }
    return sem;   
}

uint64
sys_sem_close(void){
    argint(0, &sem);
        while(a[sem]>0){
            a[sem] = a[sem] - 1; //Nose si hay que despertar/liberar procesos y si el spinlock que venimos usando se puede/hay que resetearlo
        }
        //release(slock);
        return sem;
    }