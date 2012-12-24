#-*- bash -*-
# Set MANPATH variable (for search of man pages).

MANPATH=''
add_to_path -B -p 'MANPATH' \
  /usr/man \
  /usr/share/man \
  /usr/local/man \
  /opt/man \
  /opt/java/sun-java/man \
  "$HOME"/man

if [ -n "$MANPATH" ]; then
    export MANPATH
else
    unset MANPATH
fi

# vim: ft=sh ts=4 sw=4 et
