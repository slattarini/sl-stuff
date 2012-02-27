# -*- bash -*-
# Shell aliases and functions to play doom, and doom-related
# environmental variables.  These are system-specific.

W wdoom || return $SUCCESS
test -f /usr/local/etc/bashrc.d/doom.bash || return $SUCCESS

. /usr/local/etc/bashrc.d/doom.bash

# vim: ft=sh et ts=4 sw=4
