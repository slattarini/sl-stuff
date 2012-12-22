/* vis: make funny/non-printing characters visible (version 3)
 * From Kernighan-Pike book. */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <error.h> /* glib specific */
#include <errno.h>
#define E_USAGE 2

int strip = 0; /* 0 => escape special chars; 1 => discard special chars */

int
main (int argc, char **argv)
{
    int parse_opt(int, char **);
    void vis(FILE *);

    int i, optshift;
    FILE *fp;

    optshift = parse_opt (argc, argv);
    argc -= optshift;
    argv += optshift;

    if (argc == 1) {
        vis (stdin);
    } else {
        for (i = 1; i < argc; i++)
            if ((fp = fopen (argv[i], "r" )) == NULL ) {
                error (EXIT_FAILURE, errno, "can't open file '%s'",
                       argv[i]);
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
            putchar(c);
        else if (!strip)
            printf("\\%03o", c);
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
                if (isprint (optopt))
                    error (E_USAGE, 0, "unknown option '-%c'", optopt);
                else
                    error (E_USAGE, 0, "unknown option character '\\x%x'",
                           optopt);
                break;
            default:
                abort ();
                break;

        } /* end switch */
    } /* end while */
    return (optind - 1);
}

/* vim: set ft=c ts=4 sw=4 et: */
