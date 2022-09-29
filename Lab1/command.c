#include "command.h"
#include "strextra.h"
#include <stdio.h>
#include <stdlib.h>
#include <glib-2.0/glib.h>
#include <stdbool.h> 
#include <assert.h>


/* scommand: comando simple.
 * Ejemplo: ls -l ej1.c > out < in
 * Se presenta como una secuencia de cadenas donde la primera se denomina
 * comando y desde la segunda se denominan argumentos.
 * Almacena dos cadenas que representan los redirectores de entrada y salida.
 * Cualquiera de ellos puede estar NULL indicando que no hay redirección.
 *
 * En general, todas las operaciones hacen que el TAD adquiera propiedad de
 * los argumentos que le pasan. Es decir, el llamador queda desligado de la
 * memoria utilizada, y el TAD se encarga de liberarla.
 *
 * Externamente se presenta como una secuencia de strings donde:
 *           _________________________________
 *  front -> | cmd | arg1 | arg2 | ... | argn | <-back
 *           ---------------------------------
 *
 * La interfaz es esencialmente la de una cola. A eso se le
 * agrega dos accesores/modificadores para redirección de entrada y salida.
 */

struct scommand_s
{
    GList* command;
    char* in;
    char* out;
};

scommand scommand_new(void){
    scommand command_new = malloc(sizeof(struct scommand_s));
    if(command_new == NULL){
		printf("Error : malloc");
		exit(-1);
	}
    command_new->command = NULL;
    command_new->out = NULL;
    command_new->in = NULL;
    assert(command_new != NULL && scommand_is_empty(command_new) && scommand_get_redir_in(command_new) == NULL &&
    scommand_get_redir_out(command_new) == NULL);
    return command_new;
}

scommand scommand_destroy(scommand self){
    assert(self != NULL);
    g_list_free_full(self->command, free);
    free(self->in);
    free(self->out);
    self->in=NULL;
    self->out=NULL;
    free(self);
    self = NULL;
    assert(self == NULL);
    return self;
}

/* Modificadores */
void scommand_push_back(scommand self, char * argument){
    assert(self != NULL && argument!=NULL);
    self->command=g_list_append(self->command, argument);
    assert(!scommand_is_empty(self));
}

void scommand_pop_front(scommand self){
    assert(self!=NULL && !scommand_is_empty(self));
    GList* aux = NULL;
    aux = self->command;
    self->command = self->command->next;
    free(aux->data);
    g_list_free_1(aux);
    aux = NULL;
    
}
void scommand_set_redir_in(scommand self, char * filename){
    assert(self!=NULL);
    self->in = filename;
}
void scommand_set_redir_out(scommand self, char * filename){
    assert(self!=NULL);
    self->out = filename;
}

/* Proyectores */
unsigned int scommand_length(const scommand self){
    assert(self != NULL);
    return g_list_length(self->command);
    assert((scommand_length(self)==0) == scommand_is_empty(self));
}

bool scommand_is_empty(const scommand self){
    assert(self != NULL);
    return scommand_length(self) == 0;
}

char * scommand_front(scommand self){
    assert(self!=NULL && !scommand_is_empty(self));
    char* first = g_list_nth_data(self->command,0u);
    assert(first != NULL);
    return first;
}

char * scommand_get_redir_in(const scommand self){
    assert(self!=NULL);
    char* redir_in= self->in;
    return redir_in;
}
char * scommand_get_redir_out(const scommand self){
    assert(self!=NULL);
    char* redir_out= self->out;
    return redir_out;
}

static char* scommand_frontpop(scommand self) {
    assert(self != NULL && !scommand_is_empty(self));

    char* result = g_list_nth_data(self->command, 0);

    self->command = g_list_remove(self->command, result);

    assert(result != NULL);
    return (result);
}

char * scommand_to_string(const scommand self){
    unsigned int len=scommand_length(self);
    char* res=strdup("");
    if (!scommand_is_empty(self))
    {
        res = strreallocmerge(res, g_list_nth_data(self->command, 0));
        res = strreallocmerge(res, " ");

        for (unsigned int i = 1; i < len; i++)
        {
            res = strreallocmerge(res, g_list_nth_data(self->command, i));
            res = strreallocmerge(res, " ");

        }
        if (self->in !=NULL)
        {
            res = strreallocmerge(res, " < ");
            res = strreallocmerge(res, self->in);
        }
        if (self->out!=NULL)
        {
            res = strreallocmerge(res, " > ");
            res = strreallocmerge(res, self->out);
        }
    }
    assert(res == NULL || scommand_is_empty(self) ||
               scommand_get_redir_in(self) == NULL ||
               scommand_get_redir_out(self) == NULL || strlen(res) > 0);
    return res;   
}

char ** scommand_to_argv(const scommand self){
    assert(self!=NULL);
    unsigned int n = scommand_length(self);
    char ** argv = malloc(sizeof(char *) * n + 1);
    for (unsigned int i = 0; i < n; i++)
    {
        char* arg= scommand_frontpop(self);
        argv[i] = arg;
    }
    argv[n]= NULL;

    assert(argv != NULL) ;
    return argv;
}

/*
 * pipeline: tubería de comandos.
 * Ejemplo: ls -l *.c > out < in  |  wc  |  grep -i glibc  &
 * Secuencia de comandos simples que se ejecutarán en un pipeline,
 *  más un booleano que indica si hay que esperar o continuar.
 *
 * Una vez que un comando entra en el pipeline, la memoria pasa a ser propiedad
 * del TAD. El llamador no debe intentar liberar la memoria de los comandos que
 * insertó, ni de los comandos devueltos por pipeline_front().
 * pipeline_to_string() pide memoria internamente y debe ser liberada
 * externamente.
 *
 * Externamente se presenta como una secuencia de comandos simples donde:
 *           ______________________________
 *  front -> | scmd1 | scmd2 | ... | scmdn | <-back
 *           ------------------------------
 */

struct pipeline_s
{
    GList *cmds;
    bool wait;
};

pipeline pipeline_new(void)
{
    pipeline res = malloc(sizeof(struct pipeline_s));
    if(res == NULL){
		printf("Error : malloc");
		exit(-1);
	}
    res->cmds = NULL;
    res->wait = true;
    assert(res!=NULL && pipeline_is_empty(res) && pipeline_get_wait(res));
    return res;
}

static void scommand_destroy_void(void* self)
{
    scommand delself = self;
    delself = scommand_destroy(delself);
}
pipeline pipeline_destroy(pipeline self)
{
    assert(self!=NULL);
    g_list_free_full(self->cmds,scommand_destroy_void);
    self->cmds = NULL;
    free(self);
    self = NULL;
    assert(self == NULL);
    return self;
}

void pipeline_push_back(pipeline self, scommand sc)
{
    assert(self!=NULL && sc!=NULL);

    self->cmds = g_list_append(self->cmds,sc);

    assert(!pipeline_is_empty(self));
}

void pipeline_pop_front(pipeline self)
{
    assert(self != NULL && !pipeline_is_empty(self));
    GList * aux = NULL;
    aux = self->cmds;
    self->cmds = self->cmds->next;
    aux->data = scommand_destroy(aux->data);
    g_list_free_1(aux);
    aux = NULL;
}

void pipeline_set_wait(pipeline self, const bool w){
 assert(self != NULL);
 self->wait = w;
}

bool pipeline_is_empty(const pipeline self){
    assert(self != NULL);
    return g_list_length(self->cmds) == 0;
}

unsigned int pipeline_length(const pipeline self)
{
 assert(self != NULL);
 unsigned int len = g_list_length(self->cmds);
 assert((len == 0) == pipeline_is_empty(self));
 return len;
}

scommand pipeline_front(const pipeline self){
 assert(self!=NULL && !pipeline_is_empty(self));
 scommand first = g_list_nth_data(self->cmds,0);
 assert(first!=NULL);
 return first;
}
bool pipeline_get_wait(const pipeline self){
    assert(self != NULL);

    return self->wait;
}
char * pipeline_to_string(const pipeline self)
{
    assert(self != NULL);
    GList* commands = self->cmds;
    char* str_c = NULL;
    str_c = strdup("");
    if(commands != NULL)
    {
        char *fst_command = scommand_to_string( g_list_nth_data(commands, 0));
        //obtengo el primer elemento de commands y lo paso a string 
        str_c = strreallocmerge(str_c,fst_command);
        free(fst_command);
        //incializo str_c con el primer comando(asigna memoria para ese solo string y lo guarda en str_c);
        commands = g_list_next(commands);
        while (commands != NULL)
        {
            char *conc_cmd = scommand_to_string( g_list_nth_data(commands, 0));//comando a concatenar
            assert(conc_cmd != NULL);
           str_c = strreallocmerge(str_c, " | ");
           //si commands no es null tengo otro comando adelante que estara conectado con un pipe
           str_c = strreallocmerge(str_c,conc_cmd);
            free(conc_cmd);
           commands = g_list_next(commands);

        }
        if (!pipeline_get_wait(self)) {
            str_c = strreallocmerge(str_c, " &");
        }
    }

    assert(pipeline_is_empty(self) || pipeline_get_wait(self) || strlen(str_c)>0);
    return str_c;
}