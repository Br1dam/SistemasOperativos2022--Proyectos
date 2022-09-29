# Informe Lab 1

##### Integrantes: 

  * Agustín Zarzur - agustin.zarzur@mi.unc.edu.ar - </li>
  * Ignacio Benjamin Ceballos - benjamin.ceballos@mi.unc.edu.ar - </li>
  * Bruno D'Ambrosio - bruno.dambrosio@mi.unc.edu.ar - </li>
  * Federico Agustín Lucero - federicoagustinlucero@sanluis.edu.ar </li>

## Como compilar y correrlo
  Para correr el programa hay que escribir el comando make desde el directorio so22lab101. Este comando compila y crea el ejecutable "mybash"
  Luego ese ejecutable se puede ejecutar con ./mybash.
  
  1. make
  2. ./mybash

## Introducción

  En este informe daremos una breve descripción de cada módulo, asi como también la forma en que implementamos cada uno de ellos. Ademas indicaremos 
 la división de tareas entre los distintos integrantes del grupo para así agilizar y optimizar nuestro trabajo.


## Modularización
  La idea general del proyecto es codificar un shell al estilo de bash (Bourne Again SHell),
 cuya implementación se divide en los modulos listados a continuación:

  
#### Command.c

  Este módulo contiene los 2 tipos de datos mas importantes para el desarrollo del Bash.

   - ***Scommand*** : Este tipo de dato contiene todo lo que representa un comando. Esta implementado con una lista "command" que contiene todos los argumentos del comando,
                      y 2 punteros a char, "in" y "out" , donde se guardan la redireccion de entrada y salida respectivamente (si es que el comando lo tiene). 

   - ***Pipeline*** : Este tipo de dato contiene todo lo que representa una linea de comandos con multiples pipes (|). Esta implementado con una lista que contiene elementos 
                      de tipo scommand y 1 booleano "wait" que indica si el pipeline debe ejecutarse en backgroud o foreground.

  En este módulo trabajamos los 4 integrantes, 2 hicimos el TAD scommand y 2 el TAD pipeline.
 Lo que generó mas dificultades fueron las funciones scommand_to_string y pipeline_to_string, para su solucion creamos una nueva función en le módulo strextra.c que se encarga unir 2 strings evitando 
 problemas de memory leaks, entre otras cosas. Posteriormente nos dimos cuenta que otra implementacion posible de esta funcion puede utilizar la funcion strmerge  ya dada por la cátedra. decidimos 
 dejar la version que ya teniamos implementada por cuestiones de tiempo.
 Luego en el modulo execute nesecitabamos convertir esa lista de strings a un **char para pasarle a la funcion execvp la cual genero bastantes inconvenientas ya que era dificil pasarle los strings sin que se eliminaran.
   
   
#### Parsing.c

  Este módulo es el encargado del procesamiento de los datos, de lo que ingresa el usuario. El procesamiento
  consiste transformar lo obtenido en parser en pipelines con sus respectivos comandos.
  contiene 3 funciones:
  
  - ***parse_pipeline*** : Esta función,procesa lo que posteriormente se transformara en un pipeline, en su implementación se utiliza parse_scommand para identificar y transformar cada comando. 
                           Luego, es cuestion de crear un pipeline vacío, y una vez tenemos tenemos un comando utilizamos la funcion pipeline_push_back del TAD pipeline para ir agregándolo al pipeline
                           creado. Se utiliza el TAD parser y las funciones de parser.o implementadas para avanzar sobre los datos obtenidos. Para setear el bool "wait" se busca el caracter "&".
  
  - ***parse_scommand*** : Esta funcion procesa lo que se transformará en un comando, se identifica cada argumento utilizando la función parser_next_argument. Luego, según el tipo de argumento el 
                           procedimiento cambia. Se chequea que no tenga ciertos símbolos y en el caso de que haya redirección que no sea NULL. Si es un comando normal se van agregando los 
                           argumentos con scommand_push_back y si es redirección con set_redir_in y set_redir_out del TAD scommand.
                           
  - ***has_no_symbols*** : La funcion chequea si hay ciertos símbolos que generan problemas. Para hacerlo se utilizan funciones de la librería string.h como strchr y strstr para comparar strings.
  
  Gran parte de las complicaciones de este módulo fueron enteder algunas funciones de parser y su manejo de memoria dinámica. Sobre todo en parser_next_argument.
  
#### Builtin.c
  
  En este modulo se ejecutan los propios de <b>mybash<b> 
  
  - ***builtin_is_exit*** : Devuelve si el comando es exit, usa strcmp para verificarlo.
 
  -  ***builtin_is_cd*** : Devuelve si el comando es cd, usa strcmp para verificarlo.
 
  -  ***builtin_is_help*** : Devuelve si el comando es help, usa strcmp para verificarlo.
     
  -  ***builtin_is_internal*** : Devuelve si el comando es exit, cd, help. usa las tres funciones anteriores con || ("o" logico).
  
  - ***builtin_alone*** : Verifica si un pipe tiene un solo comando y si es interno. (no fue necesitado su uso).
  
  - ***run_cd*** : como su nombre indica se usa para correr cd, usa dos funciones staticas que modularizamos es_solo_espacio(si solo pusieron espacio como argumento), path_special (verifica si tene caracteres especiales como : "..", "./", etc).
  
  - ***builtin_run*** : corre cualquiera de los 3 comando internos:
                                                                   **help** : Muestra en pantalla los comandos internos de mybash, introduce a los creadores del proyecto
                                                                   **exit** : sale del bash.
                                                                   **cd** : cambia es directorio actual
  
   En un principio parecio facil este modulo, pero tuvo varios cambios, por ej las 3 funciones de si es un comando interno las hicimos en uno solo que no funcionaba. la funcion mas dificil de correr fue la cd
  ya que no podiamos hacer que funcionaran los directorios, por el resto de esos pequeños cambios y el cd, fue un modulo rapido. 

   
#### Execute.c

   Este módulo se encarga de la ejecución de cada pipeline, fue el módulo mas extenso de desarrollar. Todos los integrantes participamos e implementamos una version de este módulo hasta encontrar 
  la forma correcta de hacer la ejecucíon.Las syscalls usadas son fork() para la creación de procesos hijos, execvp para "transformar" los procesos hijos creados en nuevos programas segun lo que 
  indica cada comando. dup2 y pipe para manipulacion de filedescriptors y comunicación entre procesos (para poder implementar los pipes(|)). open y close para poder implementar redirecciones.
  Y wait en el caso de la ejecucion en modo foreground.
  Las funciones usadas: 
  
  - ***execute_pipeline*** : Ejecucion con la función execute_pipeline_type ya sea en modo background o foreground de un pipe. Si se va a ejecutar en background se crea un hijo idéntico al padre que hará la ejecucion, 
    y el proceso padre queda libre para continuar con otro pipeline. Si es en modo foreground se utiliza la funcion wait para que el padre espere los procesos hijos.
  
  - ***execute_pipeline_type*** : La funcion distingue entre comandos simples y ,multiples comandos conectados con pipelines. En cada caso se utilizan las funciones execute_single y execute multiple respectivamente.
  
  - ***execute_single*** : Ejecuta un comando simple distinguiendo si es interno de builtin o externo. Utiliza builtin_run si es interno y si no se crea un proceso hijo que llamara a la función exec_ext.
  
  - ***execute_multiple***: Este comando fue el mas dificil ya que era muy dificil ejecutara un pipe de tamaño arbitrario, la pipe la hicimos con un array dinamico (ya que un array simple no funciono).
                           que usamos para guardar y pasar informacion de una funcion a otra y la ejecutamos con execute_command.
  
  - ***exec_ext*** : Se cambian los filedescriptors en caso de redirección y se usa una función que se agregó en command exclusivamente para esto, scommand_to_argv que dado un scommand devuelve un array de strings
                    que seran los argumentos que recibirá execvp. Finalmente llama a execvp.
  
  - ***execute_command*** : Muy parecida a single command pero no realiza fork, esta pensada para ser utilizada por multiple_command. Se distingue entre comando interno o externo, se llama la funcion que corresponde en cada caso,
                            como en single command. 
  
  - ***close_all*** : Cierra todas las puntas de lectura y escritura.
    
  Todo el módulo fue muy costoso. Para poder lograr que se ejecuten los pipelines estuvimos muchos dias y nos enfrentamos a gran variedad de errores.

#### MyBash.c
  
  Este modulo es el resultado de todos los modulos anteriores, se lo podria pensar como el ejecutable de myBash, Este modulo lo completo un solo
  integrante, cuenta con dos (2) funciones estaticas y el main :
  
  - ***show_prompt*** : show_prompt muestra en pantalla un **prompt** (indicador) para hacer saber al usuario que se esta ejecutando el Bash, 
  aqui se le da color a las diferentes partes del **prompt**, por cuestiones de personalizacion se le pasa como parametros el **cwd** (Current Working Directory, tipo string) y un 
  limite numerico (*lim*, tipo entero positivo). Usa a su vez como una funcion auxiliar prom_cwd_write.

  - ***prom_cwd_write*** :  prom_cwd_write tiene como objetivo darle el formato esperado al **cwd**, parecido a un SO Unix/Linux.

  - ***main*** : Aqui ocurre toda la magia.
  Entra en un loop (hasta que el usuario desea dejar de usar myBash, puede dejar de usarlo ingresando el comando exit) que a medida que el 
  usuario va ingresando y ejecutando comandos, transforma los comandos del usuario en el tipo pipeline para luego ser ejecutado 
  (usando todos los modulos anteriores ).

  De todos los modulos fue el que tuvo menos dificultades.
     

  
  Para comunicarnos e intercambiar ideas utilizamos whatsapp y Discord. Para el desorrollo y correccion de errores se utilizó Git, Gdb,Vscode y Valgrind.
  
### Comandos probados
  - xeyes&
  - ls
  - ls | wc
  - ls -l mybash.c
  - ls 1 2 3 4 5 6 7 8 9 10 11 12 ... 194 (Tira error, ya que no existen los archivos 1 2 3 4 5 6 7 .. 194)
  - wc -l > out < in
  - /usr/bin/xeyes &
  - ls | wc -l

## Desarrollo

  Para dividirnos el trabajo decidimos seguir el diagrama provisto por el enunciado del laboratorio, comenzando por los modulos mas esenciales
  para el proyecto y finalizando con los mas dependendientes con respecto al resto. 
  El orden en que fuimos completando el proyecto coincide con el orden en el que se enuncian los modulos de la sección de modularización. 
  Cabe aclarar que si bien comenzamos con command.c, ya que lo consideramos escencial para el resto del proyecto, luego decidimos dividirnos en 2 grupos.
  Por una parte 2 integrantes implementaron Parsing.c, mientras que los demás se encargaron de implementar Bulltin.c. 
  Por último volvimos a trabajar en conjunto a la hora de completar los módulos Execute.c y MyBash.c ya que estos envuelven todo lo implementado anteriormente
  y son mas complejos.

## Requisitos y puntos estrella

 Por último destacaremos las funcionalidades pedidas y las mejoras opcionales propuestas en el enunciado del laboratorio, 

aquellas marcadas son las que efectivamente implementamos:

  *Funcionalidades pedidas:

  

- [x] Implementar los comandos internos  cd, help y exit.

- [x] Poder salir con CTRL-D, el caracter de fin de transmisión (EOT).

- [x] Ser robusto ante entradas incompletas y/o inválidas.

- [x] Utilizar TADs opacos.

- [x] No perder memoria, salvo casos debidamente reportados en el informe (de bibliotecas externas, por supuesto).(Cabe aclarar que quedaron memory leaks en la funcion scommand_to_argv,
      ya que al liberar los argumentos del comando, execvp no ejecutaba correctamente, por lo que decidimos liberar el nodo pero no el elemento. Este no se puede liberar 
      ya que es usado por un proceso hijo que posteriormente ejecutaa execvp, la solución implica muchos cambios y no alcanzó el tiempo.)

- [x] Seguir buenas prácticas de programación (coding style, modularización, buenos comentarios, buenos nombres de variables, uniformidad idiomática, etc).

  

  *Mejoras opcionales:

  

- [x] Generalizar el comando pipeline “|” a una cantidad arbitraria de comandos simples.

- [_] Implementar el comando secuencial “&&” entre comandos simples.

- [x] Imprimir un prompt con información relevante, por ejemplo, nombre del host, nombre de usuario y camino relativo.

- [_] Implementar toda la generalidad para aceptar la gramática de list según la sección SHELL GRAMMAR de man bash. 


## Conclusion

  En general, el proyecto cumple con el objetivo de poder comprender el funcionamiento y la implementacion de un SHELL básico. Si bien por cuestiones de tiempo 
  no pudimos implementar todo lo que nos hubiese gustado, nos parecio sobre todo interesante y una buena forma de trabajo en equipo ayudandonos a encontrar fallas y errores.


