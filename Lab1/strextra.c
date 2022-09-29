#include <stdlib.h>    /* calloc()...                        */
#include <string.h>    /* strlen(), strncat, strcopy()...    */
#include <assert.h>    /* assert()...                        */
#include "strextra.h"  /* Interfaz                           */

char * strmerge(char *s1, char *s2) {
    char *merge=NULL;
    size_t len_s1=strlen(s1);
    size_t len_s2=strlen(s2);
    assert(s1 != NULL && s2 != NULL);
    merge = calloc(len_s1 + len_s2 + 1, sizeof(char));
    strncpy(merge, s1, len_s1);
    merge = strncat(merge, s2, len_s2);
    assert(merge != NULL && strlen(merge) == strlen(s1) + strlen(s2));
    return merge;
}

char * strreallocmerge(char *s1, const char *s2)
{
    assert(s1 != NULL && s2 != NULL);
    const size_t a = strlen(s1);
    const size_t b = strlen(s2);
    const size_t size_ab = a + b + 1;

    s1 = reallocarray(s1, size_ab,sizeof(char));

    memcpy(s1 + a, s2, b + 1);

    return s1;
}