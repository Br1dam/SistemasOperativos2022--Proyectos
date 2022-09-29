#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

#include "tests/syscall_mock.h"

#include "builtin.h"
#include "command.h"
#include "strextra.h"
#include "execute.h"

typedef int fd_t;

// cierra todas las pipes abiertas
static void close_all(fd_t fds[], unsigned int length){
    for (unsigned int i = 0; i < length * 2; i++){
        close(fds[i]);
    }
}

//ejecuta un comando externo
 static void exec_ext(scommand cmd) {
    assert(cmd != NULL && !scommand_is_empty(cmd));
    char * dir_in = scommand_get_redir_in(cmd);
    // Se cambia stdin por el archivo de redirecci�n de entrada
    if (dir_in!=NULL){

        int file_in= open(dir_in, O_RDONLY, S_IRUSR );

        if (file_in == -1) {
            perror(dir_in);
            exit (EXIT_FAILURE);
        }

        int dup2_ = dup2(file_in, STDIN_FILENO);

        if (dup2_ == -1) {
            perror("dup2");
            exit (EXIT_FAILURE);
        }

        int close_ = close(file_in);

        if (close_ == -1) {
            perror("close");
            exit (EXIT_FAILURE);
        }
        
    }

    char * dir_out = scommand_get_redir_out(cmd);
    // Se cambia stdout por el archivo de redirecci�n de salida
    if (dir_out !=NULL){

        int file_out= open(dir_out, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
        
        if (file_out == -1) {
            perror(dir_in);
            exit (EXIT_FAILURE);
        }

        int dup2_ = dup2(file_out,STDOUT_FILENO);

        if (dup2_ == -1) {
            perror("dup2");
            exit (EXIT_FAILURE);
        }

        int close_ = close(file_out);

        if (close_ == -1) {
            perror("close");
            exit (EXIT_FAILURE);
        }
    }

    char** argv = scommand_to_argv(cmd);

    if (argv == NULL) {
        perror("calloc");
        exit(EXIT_FAILURE);
    }

    execvp(argv[0], argv);

    /* Si execvp falla (y por ende retorna) se imprime un mensaje
      y se termina el programa */


    printf("%s : Command not found!\n", argv[0]); // La idea era usar perror pero imprime el mensaje "Error: : No such file or directory" y queremos indicar que el comando es invalido

    exit(EXIT_FAILURE);
}

//ejecuta el comando
static void execute_command(scommand cmd){

    assert(cmd != NULL);

    //si es interno
    if (builtin_is_internal(cmd))
        {
        builtin_run(cmd);
        exit(EXIT_SUCCESS);
        }
    // si es externo
    else if (!scommand_is_empty(cmd))
        {
        exec_ext(cmd);
        }
        else // Caso Vacio
        {
            exit(EXIT_SUCCESS);
        }
    
    
}

//ejecuta un  comando de una pipeline (solo posee un comando apipe length = 1)
static void execute_single(pipeline apipe){
    //requires:
    assert(pipeline_length(apipe) == 1 && apipe != NULL);
     
    scommand cmd = pipeline_front(apipe);

    // si es interno
    if (builtin_is_internal(cmd))
        {
            builtin_run(cmd);
        }

    else
    {
    pid_t pid =fork(); 

    // en caso de error del fork
    if (pid < 0)
    {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid == 0)
    {
    exec_ext(cmd);
    }
    }
    
}

// ejecuta una pipeline arbitraria de las de un comando (apipe length >= 2)
static void execute_multiple(pipeline apipe){
    //requires:
    assert(apipe != NULL && pipeline_length(apipe) >= 2);

    unsigned int len_pipe = pipeline_length(apipe) - 1;

    fd_t *fds = malloc(sizeof(fd_t)*len_pipe * 2);
    // error malloc
    if (fds == NULL) {
        perror("calloc");
        exit (EXIT_FAILURE);
    }

    for (unsigned int i = 0; i < len_pipe; i++){
        int pipe_ = pipe(fds + i * 2);
        if (pipe_ < 0){
            perror("pipe");
            close_all(fds,len_pipe);
            free(fds);
            fds = NULL;
            exit(EXIT_SUCCESS);
        }
    }

    //creacion de los pipes

    unsigned int i = 0;
    bool error = false;

    // ejecucion de los comandos
    while(!pipeline_is_empty(apipe) && !error) {   
        
        pid_t pid = fork();

        //error del fork
        if (pid < 0){
        perror("fork");
        error = true;
        }

        //hijo
        if (pid == 0){
        
        if(pipeline_length(apipe) > 1){
         int dup2_ = dup2(fds[i + 1], STDOUT_FILENO);
         if (dup2_ == -1) {
            perror("dup2");
            exit (EXIT_FAILURE);
         }
        }

        if(i != 0){
         int dup2_ = dup2(fds[i - 2], STDIN_FILENO);  
         if (dup2_ == -1) {
            perror("dup2");
            exit (EXIT_FAILURE);
        }
        }

        close_all(fds,len_pipe); 

        execute_command(pipeline_front(apipe));
        
        }

        else if (pid > 0)
        {
         i = i + 2;
         pipeline_pop_front(apipe);
        }
    }

    close_all(fds,len_pipe); 

    free(fds);

    fds = NULL;
}

// ejecuta cualquier pipeline
static void execute_pipeline_type(pipeline apipe){
    assert(apipe!=NULL);
    int pipe_len = pipeline_length(apipe);
    if(pipe_len == 1){
        execute_single(apipe);
    }
    else if(pipe_len >= 2) {
        execute_multiple(apipe);
    }

}

// ejecucion ya sea background o foreground de un pipe
void execute_pipeline(pipeline apipe){
    assert(apipe!=NULL);
    int i = pipeline_length(apipe);

    //caso foreground
    if(pipeline_get_wait(apipe)){
        execute_pipeline_type(apipe); // CAMBIAR A: amount_of_builtin_commands = execute_pipeline_type -- i = i - amount_of_builtin_commands
        while (i > 0) {
        wait(NULL);
        i--;
     }
    }
    //caso background
    else {
        
        /*pid_t pid = fork();
        if (pid < 0) {
            perror("fork");
        }
        if (pid == 0) {
            execute_pipeline_type(apipe);
            exit(EXIT_SUCCESS);
        }
        else
        {
           wait(NULL);
        }*/
       execute_pipeline_type(apipe);

    }

}