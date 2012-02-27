# -*- bash -*-

#--------------------------------------------------------------------------

# Funzione per mantenere settate opportunamente certe opzioni
# della shell (adatte quando si opera in maniera interattiva).
RestoreDefualtInteractiveShellOptions()
{

    # do not mark variables which are modified or created for export
    set +a

    # do *not* notify of job termination immediately
    # (that is really irritating!)
    set +b

    # the shell will perform brace expansion
    set -B

    # allow existing regular files to be overwritten
    # by redirection of output
    set +C

    # do not exit immediately if a command exits with a non-zero status
    set +e

    # enable file name generation (globbing)
    set +f

    # do *not* remember the location of commands as they are looked up
    set +h

    # enable ! style history substitution
    set -H

    # enable job control
    set -m

    # follow symbolic links when executing commands
    # (such as cd) which change the current directory
    set +P

    # do not treat unset variables as an error when substituting
    set +u

    # do not print shell input lines as they are read
    set +v

    # do not print commands and their arguments as they are executed
    #   set +x

    # do not exit when an eof is read from terminal.
    set -o ignoreeof

    # the return value of a pipeline is the status of  the last command
    # to exit with a non-zero status, or zero if no command exited with
    # a non-zero status
    set -o pipefail

    # do not wan user about new mails
    set +o mailwarn

    # various `shopt' options
    shopt -u cdable_vars
    shopt -u cdspell
    shopt -u checkhash
    shopt -s checkwinsize
    shopt -s cmdhist
    shopt -u dotglob
    shopt -u execfail
    shopt -s expand_aliases
    shopt -u extdebug
    shopt -s extglob
    shopt -s extquote
    shopt -u failglob  # does not compels if a glob expansion fails
    shopt -s force_fignore
    shopt -u gnu_errfmt
    shopt -u histreedit
    shopt -u histappend
    shopt -u histverify
    shopt -u hostcomplete
    shopt -u huponexit
    shopt -s interactive_comments
    shopt -u lithist
    shopt -u login_shell
    shopt -u mailwarn
    shopt -s no_empty_cmd_completion
    shopt -u nocaseglob
    shopt -u nullglob
    shopt -s progcomp
    shopt -s promptvars
    shopt -u restricted_shell
    shopt -u shift_verbose
    shopt -s sourcepath
    shopt -u xpg_echo

    # history behaviour
    HISTIGNORE="&:[el]l:ls:[bf]g:exit"

    # $HISTSIZE: numero di comandi "ricordati" dalla shell in runtime.
    HISTSIZE=5000
    # $HISTSIZE: numero di comandi "ricordati" dalla shell su disco.
    HISTFILESIZE=0
    # $HISTFILE: dove i comandi della history vengono salvati su disco.
    HISTFILE="$HOME/.bash_history"

}

declare -rf RestoreDefualtInteractiveShellOptions

#--------------------------------------------------------------------------

# Set default options.
RestoreDefualtInteractiveShellOptions

# vim: ft=sh et sw=4 ts=4
