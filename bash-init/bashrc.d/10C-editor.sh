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

# Editor used by TeX/LaTeX.
export TEXEDIT="$EDITOR +%d %s"

# Editor used by Git.
export GIT_EDITOR=$EDITOR

# vim: ft=sh et ts=4 sw=4
