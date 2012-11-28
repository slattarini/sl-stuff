# -*- bash -*-

# Colori per ls.
if [[ ${TERM-dumb} != dumb && -f $HOME/.dir_colors ]] && W dircolors; then
    eval $(dircolors -b "$HOME/.dir_colors")
fi

# vim: ft=sh ts=4 sw=4 et
