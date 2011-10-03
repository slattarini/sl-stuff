# -*- bash -*-

# FIXME: this file is an hack that would be nice to remove.

if W vim; then
    if IsHost bplab; then
        export VIMRUNTIME="$HOME/.vim-bplab"
    elif IsHost bpserv; then
        export VIMRUNTIME="$HOME/.vim-bpserv"
    fi
fi

# vim: ft=sh et ts=4 sw=4
