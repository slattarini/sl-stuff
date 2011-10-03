#-*- bash -*-
# General-purpose .bashrc file for interactive bash(1) shells.
#
# This file is meant to be installed at global, system level if
# possible, and to be used by all the users of the system (by being
# *explicitly* sourced by their ~/.bashrc).  It can also be installed
# in the home directory, though, fore example on systems where one
# lacks root access.
#
# This file is *not* a substitute for /etc/bash.bashrc; it rather strives
# to complement that file, by defining useful extensions, functions and
# aliases that are either system-agnostic, or tries to adaptively work on
# a quite large range of systems.  OTOH, /etc/bash.bashrc is usually meant
# to be tailored for, or even tied to, a specific system or machine.

# Shell must be interactive.
case "$-" in *i*) ;; *) return 0;; esac

# The shell must have an associate tty.
LC_ALL=C tty | grep -i 'not.*tty' >/dev/null && return 0

# The shell standard output and error must be associated to terminals.
{ test -t 1 && test -t 2; } || return 0

# Refuse to run with non-bash shells.
if [ -z "${BASH-}" ] || [ -z "${BASH_VERSION-}" ]; then
    echo "$0: this shell is not Bash, ~/.bashrc initialization won't" \
         "be available" >&2
    return 0
fi

# Refuse to run with older bash version.
case $BASH_VERSION in
    [12].*)
        echo "$0: Bash version \`$BASH_VERSION' too old, ~/.bashrc" \
             "initialization won't be available" >&2
        return 0;;
esac

# Protect against multiple inclusion
[ x${BASHSHRC_INCLUDED+"set"} = x"set" ] && return 0
readonly BASHSHRC_INCLUDED=1

# Explicitly read system-wide profile (needed in case we're not a login
# shell).
. /etc/profile

# Check the window size after each command and, if necessary, update the
# values of LINES and COLUMNS.
shopt -s checkwinsize

PS1='\u@\h[bash-\v]$ '

BASHRC_DIR="$HOME/.bashrc.d"

# Real shell configuration is done here.
if test -d "$BASHRC_DIR"; then
    declare -rx BASHRC_DIR
    # Source the real initialization scripts.
    for shrc_file in "$BASHRC_DIR"/[0-9][0-9]*.sh; do
        test -f "$shrc_file" || continue # In case of broken symlinks.
        echo "** SHINIT: including $shrc_file"
        . "$shrc_file" || {
            echo "$0: error while loading file \`$shrc_file'" >&2
            return 1
        }
    done
    unset shrc_file
else
    echo "$0: $BASHRC_DIR: not a directory." >&2
    echo "$0: no shell personalization available." >&2
    unset BASHRC_DIR
    return 1
fi

# vim: ft=sh ts=4 sw=4 et
