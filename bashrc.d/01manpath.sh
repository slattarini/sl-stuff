#-*- bash -*-

# Set MANPATH variable (for search of man pages).

MANPATH=""
add_to_path -B -p 'MANPATH' \
  /usr/man /usr/share/man /usr/local/man /opt/man \
  /opt/java/sun-java/man "$HOME"/man \
    2>/dev/null
[ -n "$MANPATH" ] && export MANPATH || unset MANPATH

# vim: ft=sh ts=4 sw=4 et
