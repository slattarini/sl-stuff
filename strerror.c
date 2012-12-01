/* Take an errno number as input and print the associated error
   message on stderr. */
#include <stdio.h>
#include <string.h>
#include <errno.h>
int main (int argc, char **argv)
{
    int errnum;
    while (--argc > 0) {
        errnum = atoi(*++argv);
        printf ("strerror(%d) = %s\n", errnum, strerror (errnum));
    }
    return 0;
}
