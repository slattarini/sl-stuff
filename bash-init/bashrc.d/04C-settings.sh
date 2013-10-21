# -*- bash -*-

set_preferred_shell_options ()
{
    # Do *not* notify of job termination immediately (that is
    # really irritating!)
    set +b
    # Do *not* remember the location of commands as they are looked up.
    set +h
    # Enable !-style history substitution.
    set -H
    # Follow symbolic links when executing commands (such as cd)
    # which change the current directory.
    set +P
    # Do not exit when an EOF is read from terminal.
    set -o ignoreeof
    # The return value of a pipeline is the status of the last command
    # to exit with a non-zero status, or zero if no command exited with
    # a non-zero status.
    set -o pipefail

    # Trying to execute a directory will cd into that directory.
    shopt -s autocd
    # Check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS environment variables.
    shopt -s checkwinsize
    # File globbing.
    shopt -u dotglob
    shopt -u failglob  # don't complain if a glob expansion fails
    shopt -s globstar  # globbing '**' expands recursively, a la' zsh
    shopt -u nullglob
    # Extended globbing for files and the 'case' statement.
    shopt -s extglob
    # Shell history and history editing.
    shopt -s cmdhist
    shopt -u lithist
    shopt -s histreedit
    shopt -s histverify
    shopt -u hostcomplete # no generic hostname completion
    shopt -s no_empty_cmd_completion
    # No annoying legacy checking for mail.
    shopt -u mailwarn
    # Print an error message when the shift count exceeds the number of
    # positional parameters.
    shopt -s shift_verbose
    # The 'echo' builtin should not expand backslash-escape sequences.
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
set_preferred_shell_options

# vim: ft=sh et sw=4 ts=4
