# Informe: Laboratorio 4 #

#### Preguntas ####

•    **Cuando se ejecuta el main con la opción -d, ¿qué se está mostrando en la pantalla?**

Cuando se ejecuta el main con la opcion -d, lo hace en modo debug y podemos ver informacion relevate como mensaje de errores y las fat_fuse_operations (operaciones del fat fuse) que se utilizan mientras se opera con el filesystem, por ejemplo, RELEASEDIR, READDIR, GETATTR, 



•   **¿Hay alguna manera de saber el nombre del archivo guardado en el cluster 157?**

Si. De la forma en que nosotros buscamos el archivo fs.log damos por hecho de que si el cluster existe debe haber un directorio, por lo que llamamos a fat_file_init_orphan_dir para luego usar
fat_file_read_children y asi, en el caso de que la ultima funcion haya leido algo, checkeamos el nombre de el/los archivos que leyó.
Otra forma que pensamos pero no terminamos de implementar fue usar la funcion fat_table_cluster_offset y a partir de la informacion que nos da esta funcion buscar la dentry. Por último se podría ver, partiendo del directorio root que archivo toca que cluster, ya que sabemos el start_cluster de cada archivo esto se puede aproximar.




•   **¿Dónde se guardan las entradas de directorio? ¿Cuántos archivos puede tener adentro un directorio en FAT32?**

A la hora de guardar los archivos se les asigna la primera ubicación abierta en la unidad, No hay ninguna organización en la estructura de directorios FAT
(https://learn.microsoft.com/es-es/troubleshoot/windows-client/backup-and-storage/fat-hpfs-and-ntfs-file-systems)

El Numero maximo de archivos que puede tener un directorio adentro es el tamaño del cluster/la cantidas de bits utilizados en cada campo; 512bytes/32bytes(por direntry) = 16 archivos posibles en un directorio

•   **Cuando se ejecuta el comando como ls -l, el sistema operativo, ¿llama a algún programa de usuario? ¿A alguna llamada al sistema? ¿Cómo se conecta esto con FUSE? ¿Qué funciones de su código se ejecutan finalmente?**

Para descubir que es lo que hace ls -l usamos la opcion de debug -d.
Ls llama a una funcion LOOKUP de usuario, para despues usar syscall del FUSEspace (GETATTR, OPENDIR, READDIR, LOOKUP, RELEASEDIR y GETXATTR) donde recurre a las definiciones dadas por fat_fuse_ops.c, es decir, que siempre que use una syscall del FUSEspace usa las syscalls definidas en nuestro fatfuse.
Finalmente no usa ninguna funcion escrita por nosotros, si no las dadas en el esqueleto principal


•   **¿Por qué tienen que escribir las entradas de directorio manualmente pero no tienen que guardar la tabla FAT cada vez que la modifican?**

Actualizar la tabla FAT es muy importante, esto se realiza cada vez que uses las funciones de fat_table.c. No necesariamente se guarda la tabla FAT cada vez que se modifica porque la tabla ya está mapeada en memoria, por lo que se puede modificar la tabla sin guardar en el disco.
Lleva mucho tiempo porque los cabezales de lectura del disco deben cambiar de posición a la pista lógica cero de la unidad cada vez que se actualiza la tabla FAT.
(https://learn.microsoft.com/es-es/troubleshoot/windows-client/backup-and-storage/fat-hpfs-and-ntfs-file-systems)



•   **Para los sistemas de archivos FAT32, la tabla FAT, ¿siempre tiene el mismo tamaño? En caso de que sí, ¿qué tamaño tiene?**

FAT32 posee la ventaja de no tener un tamaño fijo en la table a comparacion de FAT16, lo que permite introducir cualquier número de sub directorios y archivos en el directorio raíz.
El tamaño de la FAT table depende principalmente de la cantidad de clusters.
La contrapartida es que se aprecia una considerable pérdida de prestaciones, en concreto, del orden de un 5% de prestaciones al convertir un disco de FAT 16 a FAT 32
(https://www.zator.com/Hardware/H8_1_2a1.htm)