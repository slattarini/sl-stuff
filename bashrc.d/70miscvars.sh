# -*- bash -*-

# Definitions of miscellaneous variables.

export TMPDIR=/tmp
export PAGER=less

[ -f "$HOME/.bash_inputrc" ] && INPUTRC="$HOME/.bash_inputrc"

if IsHost bigio; then
    d=/var/local/cache/radio-classica-bresciana.cache
    [ -d "$d" ] && export RADIO_CLASSICA_BRESCIANA_CACHE=$d
    unset d
fi

# Filters for less(1).
W lesspipe && eval "$(lesspipe)"

# Location of a checked-out copy of gnulib.
[ -d "$HOME/src/gnulib" ] && export GNULIB_SRCDIR=$HOME/src/gnulib

# Override defaults for autoconf-generated configure scripts.
test -f $HOME/config.site && export CONFIG_SITE=$HOME/config.site

# W3C (X)HTML/CSS validator.
export HTML_VALIDATOR_URL=http://validator.w3.org/check
export CSS_VALIDATOR_URL=http://jigsaw.w3.org/css-validator/validator

# Device used by cdda2wav (with `cooked_ioctl' interface).
IsHost bigio && export CDDA_DEVICE='/dev/dvd'

# Used by ~/bin/svo.
IsHost bigio && export SVN_BASEURL="https://svn.bigio/svn"

# Editors used by whed(1) and its links.
case $hostname in
  bpserv|freddy)
    WH_GVIM='vim -p'
    WH_VIM='vim -p'
    ;;
  bigio|bplab)
    WH_GVIM='gvim -p'
    WH_VIM='vim -p'
    ;;
esac
export WH_VIM WH_GVIM

# Root directory of the sandboxed testing environments used by the
# `test-in-sandbox' script.
export SANDBOX_TESTING_ENVIRONMENTS=$HOME/src/sandboxed-testing/sandboxes/$hostname-$SYSTEM_UNAME
# Directory of the plugins used by the sandboxed testing environments.
export SANDBOX_TESTING_PLUGINS=$HOME/src/sandboxed-testing/test-in-sandbox/plugins

# Trash directory used by my del(1) utility.
if IsHost freddy; then
    # So that the trash dir won't be uselessly backupped.
    export TRASH_DIRECTORY="$HOME/scratch/.trash"
else
    export TRASH_DIRECTORY="$HOME/.trash"
fi

# vim: ft=sh et sw=4 ts=4
