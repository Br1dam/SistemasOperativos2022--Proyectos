#include <stdlib.h>
#include <stdbool.h>

#include "parsing.h"
#include "parser.h"
#include "command.h"
#include <string.h>
#include <assert.h>

//verifica si posee dichos simbolos
bool has_no_symbols (char* argument){
    bool res = true;
    
    char toCheck[7] = {',','#','!','$','%','?','*'}; 
    
    char * toCheckstr[6] = {"[]","{}","()","¡","¿",";"};
    int i = 0;
    int k = 0;

    
    while((i<7) && res){
         //si posee dichos simbolos
         if(strchr(argument,toCheck[i])!=NULL){
             res = false;
         }
        i++;
     }

    while((k<6) && res){
         if(strstr(argument,toCheckstr[k])!=NULL){ 
             res = false;
         }
        k++;
     }
    return res;
}

//lee el comando entero para devolver un comndo valido y si no NULL
static scommand parse_scommand(Parser p) 
{
    arg_kind_t arg_type;
    char *new_arg = parser_next_argument(p,&arg_type);
    bool error = false;
    scommand res = new_arg == NULL ? NULL : scommand_new();
    
    while(new_arg != NULL && !error)
    {   
        switch(arg_type)
        {
            case(ARG_NORMAL):
                
                if (has_no_symbols(new_arg)) 
                {
                    scommand_push_back(res,new_arg);
                    break;
                }
                else 
                {
                    res = scommand_destroy(res);
                    error = true;
                }
                break;

            case(ARG_INPUT): 
                // si hay > o < y no tiene archivo para redireccionar o hay doble >> o << o <> o ><
                if (new_arg!=NULL && has_no_symbols(new_arg)) 
                {
                    scommand_set_redir_in(res,new_arg);  
                }
                else 
                {
                    res = scommand_destroy(res);
                    error = true;
                }
                break;

            case(ARG_OUTPUT):
                // si posee simbolos "raros"
                if (new_arg!=NULL && has_no_symbols(new_arg))
                {
                    scommand_set_redir_out(res,new_arg);                 
                }
                else 
                {
                    res = scommand_destroy(res);
                    error = true;
                }
                break;

            default:
                break;
        }
        new_arg = parser_next_argument(p,&arg_type);    }
    
    if(error)
    {
        printf("error: símbolos inválidos\n");
    }

    return res;
}

pipeline parse_pipeline(Parser p) {
    assert( (p != NULL) && (!parser_at_eof(p)) );
    pipeline result = pipeline_new();
    scommand cmd = NULL;
    bool error = false, another_pipe=true, is_background= false , has_garbage = false;

    cmd = parse_scommand(p);                                           
    error = (cmd==NULL); /* Comando inválido al empezar */

    if(!error){
    pipeline_push_back(result,cmd);                         
    parser_op_pipe(p, &another_pipe);
    }
                                                         
    while (another_pipe && !error) {
      cmd = parse_scommand(p);
      error = (cmd==NULL);
      pipeline_push_back(result,cmd);
      parser_op_pipe(p, &another_pipe);
    }

    parser_skip_blanks(p); /* Tolerancia a espacios posteriores */

    parser_op_background(p, &is_background);
        if (is_background){
            pipeline_set_wait(result,false);
    }

    parser_garbage(p, &has_garbage); /*Consumir todo lo que hay inclusive el \n*/
    
    if(has_garbage) /* Si hubo error, hacemos cleanup */
    {
        pipeline_destroy(result);
        result = NULL;
        fprintf(stderr,"bash: syntax error\n");
    }

    return result;
}


