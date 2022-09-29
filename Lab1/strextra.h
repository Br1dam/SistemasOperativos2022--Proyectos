#ifndef _STREXTRA_H_
#define _STREXTRA_H_


char * strmerge(char *s1, char *s2);
/*
 * Concatena las cadenas en s1 y s2 devolviendo nueva memoria (debe ser
 * liberada por el llamador con free())
 *
 * USAGE:
 *
 * merge = strmerge(s1, s2);
 *
 * REQUIRES:
 *     s1 != NULL &&  s2 != NULL
 *
 * ENSURES:
 *     merge != NULL && strlen(merge) == strlen(s1) + strlen(s2)
 *
 */

char * strreallocmerge(char *s1, const char *s2);
/*
 * concatena las cadenas s1 y s2 y guarda el resultado en s1,
 * se asume que la cadena de destino s1 no tiene suficiente espacio
 * para agregar otra cadena adelante por lo que se usa realloc para asignar mas memoria a s1.
 *(debe ser liberada por el llamador con free())
 * 
 * 
 * 
 * 
 * 
 * 
 */

#endif
