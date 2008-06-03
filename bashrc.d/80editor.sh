# -*- bash -*-

W vim && VI=vim || VI=vi
W view && VIEW=view || VIEW=$VI
declare -rx VI VIEW

W editor && EDITOR=editor || EDITOR="$VI"
export EDITOR

export SVN_EDITOR="$EDITOR" VISUAL="$EDITOR" FCEDIT="$EDITOR"

# editor used by tex/latex
export TEXEDIT="$EDITOR +%d %s"

if W vim; then
    if IsHost bplab; then
        export VIMRUNTIME="$HOME/.vim-bplab"
    elif IsHost bpserv; then
        export VIMRUNTIME="$HOME/.vim-bpserv"
    fi
fi

# vim: ft=sh et ts=4 sw=4
