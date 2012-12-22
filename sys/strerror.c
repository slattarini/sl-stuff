/* Take an errno number as input and print the associated error
   message on stderr. */
#include <stdio.h>
#include <stdlib.h> /* for atoi */
#include <string.h> /* for strerror */
#include <errno.h>
int main (int argc, char **argv)
{
    int errnum;
    if (argc == 1) {
      fprintf (stderr, "%s: missing argument\n", argv[0]);
      return 2;
    }
    while (--argc > 0) {
        errnum = atoi(*++argv);
        printf ("strerror(%d) = %s\n", errnum, strerror (errnum));
    }
    return 0;
}
