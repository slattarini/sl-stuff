# -*- bash -*-
# Color scheme for ls(1).

[[ ${TERM-dumb} != dumb ]] && W dircolors || return $SUCCESS

for f in ~/.dircolors ~/.dir_colors; do
  if [[ -f $f ]]; then
    eval $(dircolors -b "$f")
    break
  fi
done
unset f

# vim: ft=sh ts=4 sw=4 et
