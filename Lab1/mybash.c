#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <sys/wait.h>



#include "command.h"
#include "execute.h"
#include "parser.h"
#include "parsing.h"
#include "builtin.h"

#define SIZE 1024
#define BLUE(string) "\x1b[34m" string "\x1b[0m"
#define RED(string) "\x1b[31m" string "\x1b[0m"


static char *prom_cwd_write(unsigned int n, char *word){
    assert(strlen(word) >= n);
    unsigned int lim = strlen(word) - n + 1;
    char *new = malloc(sizeof(char)*(lim));
    new[0] = '~';
    for (unsigned int i = 1; i < lim; i++){
        new[i] = word[i+n-1];
    }
    return new;
}

static void show_prompt(char *cwd, unsigned int lim) {
    if (strlen(cwd) > lim){
        char *prompt_cwd = prom_cwd_write(lim, cwd);
        printf (BLUE("mybash:") RED("%s")" > ", prompt_cwd);        
    }else{
        printf (BLUE("mybash:")RED("%s") " > ", cwd);
    }
    fflush (stdout);
}

int main(int argc, char *argv[]) {
    pipeline pipe;
    Parser input = parser_new(stdin);
    bool quit = false;

    
    char *cwd=malloc(sizeof(char)*SIZE);
    
    unsigned int cwd_lim = strlen(getenv("HOME"));

    while (!quit) {
        getcwd(cwd, SIZE);
        show_prompt(cwd, cwd_lim);
        while(waitpid(-1, NULL, WNOHANG) > 0); // ELimina Procesos Zombie
        pipe = parse_pipeline(input);

        /* Hay que salir luego de ejecutar */
        quit = parser_at_eof(input);
        
        if (pipe != NULL) {
            execute_pipeline(pipe);
            pipe = pipeline_destroy(pipe);
        }

    }

    if(input != NULL)
    {
        parser_destroy(input); 
        input = NULL;
    }

    free(cwd);
    return EXIT_SUCCESS;
}
