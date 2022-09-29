#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "builtin.h"
#include "command.h"
#include "strextra.h"
#include <unistd.h>
#include <libgen.h>
#include "tests/syscall_mock.h"

#define SIZE 1024

bool builtin_is_exit(scommand cmd){
	return strcmp(scommand_front(cmd),"exit")==0;
}

bool builtin_is_cd(scommand cmd){
	return strcmp(scommand_front(cmd),"cd")==0;
}

bool builtin_is_help(scommand cmd){
	return strcmp(scommand_front(cmd),"help")==0;
}

bool builtin_is_internal(scommand cmd){
	return builtin_is_exit(cmd) || builtin_is_cd(cmd)|| builtin_is_help(cmd);
}


bool builtin_alone(pipeline p){
    assert(p != NULL);
    assert (pipeline_length(p) == 1 && 
            builtin_is_internal(pipeline_front(p)));

    return pipeline_length(p) == 1 && 
            builtin_is_internal(pipeline_front(p));
}

/***  para correr cd ***/
static bool es_solo_espacio(char *path){
    unsigned int len = strlen(path);
    bool cond = true;
    unsigned int i = 0;
    while (i < len && cond){
        cond = cond && path[i] == ' ';
        i++;
    }
    return cond;
    
}
static bool path_special(unsigned int len_path,char *path){
    return (len_path== 2 && path[0] == path[1] && path[0]=='.') || es_solo_espacio(path) || ( len_path == 1 && (path[0] == '.' || path[0] == '/' || path[0] == '~'));
}


static void run_cd(scommand cmd){
    assert(cmd != NULL);
    /*Varibles Necesarias, NO TOCAR*/
    char * cwd = NULL;
    char * path = NULL;
    cwd = getcwd(cwd, SIZE);
    char *final_path = dirname(cwd);
    bool is_root_file = false;
    /*!!!!!!!!!!!*/

    /* consumo commando cd */
    scommand_pop_front(cmd);
    

    if(scommand_is_empty(cmd))
    { 
    final_path = getenv("HOME");
    } 
    else
    {
    /** INPUT -- donde quiero ir **/
    path = scommand_front(cmd);
        
    unsigned int len_path = strlen(path);

	bool is_special = path_special(len_path, path);
    
    /*Revisar si el path comienza con barra inclinada o si es un archivo especial*/
    if (path[0] != '/' && !is_special){
        path = strmerge("/",path);
    }else{
        is_root_file = true;
    }
    
    /* ir al path que quiero ir */
    if (is_special){
        /*los path especiales son:
        * . --> no va a ningun lado
        * / --> va al root
        * ~  o (uno o mas espacios) --> va al home
        * .. --> ve a la carpeta padre
        */
       
        if ( (len_path == 1 && path[0] == '.') || len_path == 0){
            final_path = getcwd(cwd, SIZE);// no va a ningun lado
        }else if (path[0] == '/' ){
            final_path = "/";
        }else if(len_path == 2 && path[0] == path[1] && path[0]=='.'){
        	;
        }else{
            final_path = getenv("HOME");
        }
        
    }else{ /*no es especial*/
        if (is_root_file){
            final_path = path;
        }else{
            cwd = getcwd(cwd, SIZE);
           
            final_path = strcat(cwd, path);
        }  
    }
    }

        int did_it_go = chdir(final_path);
        /*Checkeo si salio bien*/

        if (did_it_go != 0){
            perror("MyBash");
        }
}
/***  fin correr cd ***/


void builtin_run(scommand cmd){
    assert(builtin_is_internal(cmd));
    if (builtin_is_cd(cmd))
    {
        run_cd(cmd);
    }else if (builtin_is_exit(cmd))
    {
        exit(0);
    }else{
        printf("\nBienvenido a nuestro shell,\n  Mybash\n  (wow)(*apalusos*)\n \nlos creadores de esta (posible catastrofe) terminal son \n \nBruno D'Ambrosio\nBenjamín Ceballos\nAgustin Zarzur\nFederico Lucero\nTodos ellos sueñan con ser computologos recibidos de las ciencias de la computacion en famaf,unc (pero a eso lo decidiran los profes). \nvolvamos a lo que nos compete, las funciones que poseemos, las cuales no son muchas\n\n\n\t exit: termina de correr la terminal liberando la memoria usada\n\t help: buscaste los 3 comandos locos que poseemos o algun error nuestro (si es asi, mea culpa)\n\t cd: se pasa de la localizacion actual a la que pondra como argumento\n\nesperamos que tenga un hermoso dia y que disfrute de su estadia en este shell\n");
    
    }
    
    
}
