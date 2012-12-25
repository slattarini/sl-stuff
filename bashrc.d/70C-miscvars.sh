# -*- bash -*-
# Definitions of miscellaneous variables.

case $UID in
  0)
    if test -d "$HOME/tmp" || mkdir -p "$HOME/tmp"; then
      export TMPDIR=$HOME/tmp
    else
      mwarn "cannot create directory '$HOME/tmp'."
      mwarn "'/tmp' will be used as your temporary directory."
      export TMPDIR=/tmp
    fi
    ;;
  *)
    export TMPDIR=/tmp
    ;;
esac

export PAGER=less

[[ -f $HOME/.inputrc ]] && export INPUTRC=$HOME/.inputrc

d=/var/local/cache/radio-classica-bresciana.cache
[[ -d $d ]] && export RADIO_CLASSICA_BRESCIANA_CACHE=$d
unset d

# Filters for less(1).  Not for the superuser.
[ $UID -gt 0 ] && W lesspipe && eval "$(lesspipe)"

# Location of a checked-out copy of gnulib.  Not for the superuser.
if [ $UID -gt 0 ]; then
  if [[ -z $GNULIB_SRCDIR && -d $HOME/src/gnulib ]]; then
    GNULIB_SRCDIR=$HOME/src/gnulib
  fi
  # For bootstrapping (at least) GNU Gettext.
  GNULIB_TOOL=$GNULIB_SRCDIR/gnulib-tool
  export GNULIB_SRCDIR GNULIB_TOOL
fi

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
