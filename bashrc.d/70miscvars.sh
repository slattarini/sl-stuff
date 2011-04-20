# -*- bash -*-

# Definitions of miscellaneous variables.

[ -f "$HOME/.bash_inputrc" ] && INPUTRC="$HOME/.bash_inputrc"

if IsHost bigio; then
    d=/var/local/cache/radio-classica-bresciana.cache
    [ -d "$d" ] && export RADIO_CLASSICA_BRESCIANA_CACHE=$d
    unset d
fi

# filters for less(1)
W lesspipe && eval "$(lesspipe)"

# location of checkedout copy of gnulib
[ -d "$HOME/src/gnulib" ] && export GNULIB_SRCDIR=$HOME/src/gnulib

# personal config.site file, to override configure defaults
export CONFIG_SITE=./config.site # always prefer local copy

# W3C (X)HTML/CSS validator
export HTML_VALIDATOR_URL=http://validator.w3.org/check
export CSS_VALIDATOR_URL=http://jigsaw.w3.org/css-validator/validator

# device used by cdda2wav (with `cooked_ioctl' interface).
IsHost bigio && export CDDA_DEVICE='/dev/dvd'

# used by ~/bin/svo
IsHost bigio && export SVN_BASEURL="https://svn.bigio/svn"

# directory of temporary files.
export TMPDIR='/tmp'

# best pager avaible.
export PAGER='less'

# editors used by whed(1) and its links.
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

# Root directory of the sandboxed testing environment used by the
# `test-in-sandbox' script.
export SANDBOX_ENVIRONMENTS_ROOT="$HOME/src/sandboxed-testing/sandboxes/$SYSTEM_UNAME-$hostname"

# trash directory used by my del(1) utility
if IsHost freddy; then
    # so that the trash dir won't be uselessly backupped
    export TRASH_DIRECTORY="$HOME/scratch/.trash"
else
    export TRASH_DIRECTORY="$HOME/.trash"
fi

# vim: ft=sh et sw=4 ts=4
