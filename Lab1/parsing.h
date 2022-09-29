#ifndef _PARSING_H_
#define _PARSING_H_

#include "command.h"
#include "parser.h"

bool has_no_symbols (char* argument);
/*
 *
 * Indica si el char* argment es invalido porque posee los simbolos especificados 
 *
 *REQUIRES:
 *     argument != NULL
 *
 * ENSURES:
 *          command is valid
 * 
*/

pipeline parse_pipeline(Parser parser);
/*
 * Lee todo un pipeline de `parser' hasta llegar a un fin de línea (inclusive)
 * o de archivo.
 * Devuelve un nuevo pipeline (a liberar por el llamador), o NULL en caso
 * de error.
 * REQUIRES:
 *     parser != NULL
 *     ! parser_at_eof (parser)
 * ENSURES:
 *     No se consumió más entrada de la necesaria
 *     El parser esta detenido justo luego de un \n o en el fin de archivo.
 *     Si lo que se consumió es un pipeline valido, el resultado contiene la
 *     estructura correspondiente.
 */

#endif
