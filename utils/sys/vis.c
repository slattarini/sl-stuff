/* vis: make funny/non-printing characters visible (version 3)
 * From Kernighan-Pike book. */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#define E_USAGE 2

int strip = 0; /* 0 => escape special chars; 1 => discard special chars */
const char *progname;

int parse_opt (int, char **);
void vis (FILE *);

int
main (int argc, char **argv)
{
    int i, optshift;
    FILE *fp;

    progname = argv[0];

    optshift = parse_opt (argc, argv);
    argc -= optshift;
    argv += optshift;

    if (argc == 1) {
        vis (stdin);
    } else {
        for (i = 1; i < argc; i++)
            if ((fp = fopen (argv[i], "r" )) == NULL ) {
                fprintf (stderr, "%s: can't open file '%s': %s",
                         progname, argv[i], strerror (errno));
                exit (EXIT_FAILURE);
            } else {
                vis (fp);
                fclose (fp);
            }
    }
    exit (EXIT_SUCCESS);
}

void
vis (FILE *fp)
{
    int c;
    while ((c = getc (fp)) != EOF)
        if (c == '\\')
            printf ("%s", strip ? "\\": "\\\\");
        else if (isascii (c)
                 && (isprint (c) || c == '\n' || c == '\t' || c == ' '))
            putchar (c);
        else if (!strip)
            printf ("\\%03o", c);
}

int
parse_opt (int argc, char **argv)
{
    char option;
    opterr = 0; /* global */
    while ((option = getopt (argc, argv, "s")) != -1) {
        switch (option) {
            case 's':
                /* strip funny characters */
                strip = 1;
                break;
            case '?':
                /* bad option */
                if (isprint (optopt)) {
                    fprintf (stderr,
                             "%s: unknown option '-%c'\n",
                             progname, optopt);
                    exit (E_USAGE);
                } else {
                    fprintf (stderr,
                             "%s: unknown option character '\\x%x'\n",
                             progname, optopt);
                    exit (E_USAGE);
                }
                break;
            default:
                abort ();
                break;

        } /* end switch */
    } /* end while */
    return (optind - 1);
}

/* vim: set ft=c ts=4 sw=4 et: */
