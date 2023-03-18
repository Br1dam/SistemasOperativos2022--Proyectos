# Informe del Lab 02

## Integrantes:

*Agustín Zarzur - agustin.zarzur@mi.unc.edu.ar -

*Bruno D'Ambrosio - bruno.dambrosio@mi.unc.edu.ar -

*Federico Agustín Lucero - federicoagustinlucero@sanluis.edu.ar

*Ignacio Benjamin Ceballos - benjamin.ceballos@mi.unc.edu.ar -

## Que hicimos? 
1 - Implementamos una estructura de datos conocido como **semaphores** (semaforos), que nos permite controlar el acceso a 
recursos compartidos en un entorno de  multiprocesamiento.

para ello implementamos 4 llamadas a systema :

**sem_open(a, b):** inicializa el semaforo, *a* es uno de los N semaforos disponibles y *b* representa "cuantos procesos puede manejar a la vez". 

**sem_close(a):** cierra o libera el semaforo *a*.

**sem_up(a):** Incrementa el semáforo *a*, desbloqueando los procesos cuando su valor se incrementa de 0 a 1.

**sem_down(a):** Decrementa el semáforo *a* bloqueando los procesos cuando su valor es 0.

	
2 - Implementamos un programa que puede usar el usuario llamado “ping_pong”.

**ping_pong(n):**  Funciona con el semaforo que diseñamos, donde internamente hay un proceso que imprime *n* veces en pantalla "ping" y otro imprime *n* veces en pantalla "pong".

por ejemplo: si ejecuto ping_pong 5, en pantalla resulta asi:

	$ ping_pong 5
	ping
			pong
	ping
			pong
	ping
			pong
	ping
			pong
	ping
			pong
	$ 


Utiliza 2 semaforos. De esta forma puedo tener un mejor control de que proceso sera quien se ejecute. Al tener un semaforo que bloquea un proceso y otro que "cede el paso", siempre se ejecutará en el orden correcto.
	
### Breve explicaciones de acquire(), release(), sleep(), wakeup() y argint()

#### acquire()

acquire() asegura que las interrupciones estén desactivadas en el procesador local usando la instrucción cli (a través de pushcli() ),
y que las interrupciones permanezcan desactivadas hasta que se libere el último bloqueo retenido por ese procesador (momento en el cual se habilitan usando sti ).


#### release()

Libera un lock estableciendo su valor en false. 
Es es solo una instrucción, por lo que es automáticamente atómica. (hay otras cosas ocurriendo en el fondo pero se entiende la idea)


#### argint

Pasar argumentos de funciones de nivel de usuario a funciones de nivel de kernel no se puede hacer en XV6. XV6 tiene sus propias 
funciones integradas para pasar argumentos a una función del kernel. ***argint*** es una de esas funciones y recibe un entero


#### Wake and sleep (despertar y dormir)

Actúan como mecanismos de coordinación de secuencias o sincronización condicional, que permite que los procesos se comuniquen 
entre sí, poniendo a dormir ciertos procesos mientras esperan que se cumplan las condiciones y despertando a otros procesos cuando
se cumplen esas condiciones.

sleep(): El kernel llamará a sleep() para los procesos que necesitan esperar mientras sucede algo más,
p.ej. esperando un disco para leer o escribir datos. De esa manera, los procesos no terminan dando vueltas sin hacer nada en un 
bucle y desperdiciando tiempo de CPU.
wakeup(): Despierta a los procesos que estaban previamente esperando.

### Conclusiones

Lo más complicado de este lab fue  poder entender los conceptos que luego utilizamos en la implementación (La syscalls que utilizamos, el funcionamiento de los spinlocks, etc)
y el hecho de que a la hora de revisar errores no hay una forma precisa de debuggear, por lo que nos manejamos colocando prints, y corriendo el codigo en nuestra cabeza.
