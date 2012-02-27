# -*- bash -*-

if test -z "$EDITOR"; then
  if W editor; then
    EDITOR=editor
  elif W vim; then
    EDITOR=vim
  else
    EDITOR=vi
  fi
fi
export EDITOR

# Editor used by tex/latex.
export TEXEDIT="$EDITOR +%d %s"

# vim: ft=sh et ts=4 sw=4
