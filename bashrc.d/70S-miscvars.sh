# -*- bash -*-
# Definitions of miscellaneous variables.

export TMPDIR=/tmp
export PAGER=less

[[ -f $HOME/.bash_inputrc ]] && export INPUTRC=$HOME/.bash_inputrc

d=/var/local/cache/radio-classica-bresciana.cache
[[ -d $d ]] && export RADIO_CLASSICA_BRESCIANA_CACHE=$d
unset d

# Filters for less(1).
W lesspipe && eval "$(lesspipe)"

# Location of a checked-out copy of gnulib.
[[ -d $HOME/src/gnulib ]] && export GNULIB_SRCDIR=$HOME/src/gnulib

# Override defaults for autoconf-generated configure scripts.
[[ -f $HOME/config.site ]] && export CONFIG_SITE=$HOME/config.site

# Trash directory used by my del(1) utility.
if [[ -d $HOME/scratch/.trash ]]; then
    # Avoid backup pf deleted files on systems having a dedicated
    # scratch area.
    export TRASH_DIRECTORY=$HOME/scratch/.trash
else
    export TRASH_DIRECTORY=$HOME/.trash
fi

# vim: ft=sh et sw=4 ts=4
