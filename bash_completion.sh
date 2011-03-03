#-*- bash -*-
# Personal bash completion file.  Should get automatically sourced by
# /etc/bash_completion (or similar).

# Sanity checks
[[ -n $UNAME ]] || {
  echo "${BASH_SOURCE[1]}: \$UNAME unset or empty" >&2
  return 1
}

declare -F have &>/dev/null || {
  echo "${BASH_SOURCE[1]}: have() function undefined" >&2
  return 1
}

copy_completion() {
    local x c o
    o=$1
    shift
    if x=$(complete -p "$o" 2>/dev/null) && [[ $x == *" $o" ]]; then
        for c in "$@"; do
            have $c && eval "${x%% $o} $c"
        done
    fi
}

# XXX ???
if declare -F _command &>/dev/null; then
    for x in bleeding heirloom; do
        _require_xcmd=0
        if have "$x"; then
            _require_xcmd=1
            eval "_$x() { _xcmd $x; } && complete -F _$x $x"
        fi
    done
    if ((_require_xcmd)); then
        _xcmd() {
            eval "$("$1" | sed 's/^/declare -x /')"
            _command
        }
    fi
    unset x _require_xcmd
fi


for x in wh where whcat whed whfl whpkg whdpkg; do
    have $x && complete -c command $x
done
unset -v x

# Wrapper/aliases civclient program.
copy_completion civclient civ freeciv

# `chdir' is aliased to `cd'.
copy_completion cd chdir

# Aliases for gzip and bzip2: `gz' and `bz2'.
copy_completion gzip gz
copy_completion bzip2 bz2

# Aliases for vi/vim.
copy_completion vim v
copy_completion gvim g
copy_completion view vw
copy_completion gview gw

# Wrappers around `man'.
copy_completion man cman mman
# Wrappers around `info'.
copy_completion info cinfo minfo
# "Extensions" for `ls'.
copy_completion ls la ll lls
# Alias for builtin `command'.
copy_completion command cmd
# "Extensions" for `cp', `mv' and `rm'.
copy_completion cp cpf
copy_completion mv mvf
copy_completion rm rmf
# Aliases for rmdir and mkdir.
copy_completion rmdir rd
copy_completion mkdir md

# KView and aliases.
have kview && complete -o dirnames -f -X '!*.@(gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|GIF|JP?(E)G|MIFF|TIF?(F)|PN[GM]|P[BGP]M|BMP|XPM|ICO|XWD|TGA|PCX)' kview
copy_completion kview kv

# Extra user completions.
for _extra_bash_completion_user_file in ~/.bash_completion.d/*; do
  test -f "${_extra_bash_completion_user_file}" || continue
  . "${_extra_bash_completion_user_file}"
done
unset _extra_bash_completion_user_file

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
