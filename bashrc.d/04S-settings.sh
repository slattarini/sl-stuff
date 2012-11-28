# -*- bash -*-

set_defualt_shell_options ()
{

    # Do not mark variables which are modified or created for export.
    set +a

    # Do *not* notify of job termination immediately (that is
    # really irritating!)
    set +b

    # The shell will perform brace expansion.
    set -B

    # Allow existing regular files to be overwritten by redirection
    # of output
    set +C

    # Do not exit immediately if a command exits with a non-zero status.
    set +e

    # Enable file name generation (globbing).
    set +f

    # Do *not* remember the location of commands as they are looked up.
    set +h

    # Enable !-style history substitution.
    set -H

    # Enable job control.
    set -m

    # Follow symbolic links when executing commands (such as cd)
    # which change the current directory.
    set +P

    # Do not treat unset variables as an error when substituting.
    set +u

    # Do not print shell input lines as they are read.
    set +v

    # Do not print commands and their arguments as they are executed.
    set +x

    # Do not exit when an EOF is read from terminal.
    set -o ignoreeof

    # The return value of a pipeline is the status of the last command
    # to exit with a non-zero status, or zero if no command exited with
    # a non-zero status.
    set -o pipefail

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
    shopt -u failglob  # Doesn't complain if a glob expansion fails
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

    # History behaviour.
    HISTIGNORE="&:[el]l:ls:[bf]g:exit"

    # Number of commands remembered by the shell at runtime.
    HISTSIZE=5000
    # Number of commands remembered on the history file on disk.
    HISTFILESIZE=0
    # File where to save shell history.
    HISTFILE=$HOME/.bash_history
}

# Set default options.
set_defualt_shell_options

# vim: ft=sh et sw=4 ts=4
