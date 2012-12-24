# -*- bash -*-
# I18N

export LC_COLLATE=C
export LC_NUMERIC=C

locale -a &>/dev/null || return $SUCCESS

_setlang_cmd ()
{
  locale | sed -e 's/=\(.*\)$/='"${1-}"';/' -e 's/^/export /'
  case $1 in C) echo export LC_ALL=C;; *) echo unset LC_ALL;; esac
}

setlang ()
{
    eval $(_setlang_cmd "$@")
    export LC_COLLATE=C
    export LC_NUMERIC=C
}

resetlang ()
{
    eval "${_restore_lang_cmd}" && _restore_lang_cmd=
}

clearlang ()
{
    eval $(_setlang_cmd C)
}

speak ()
{
    case ${1-} in
        en|USA)     set en_US.UTF-8;;
        uk|british) set en_GB.UTF-8;;
        de|german)  set de_DE.UTF-8;;
        fr|french)  set fr_FR.UTF-8;;
        it|italian) set it_IT.UTF-8;;
    esac
    setlang "$1"
}

setlang en_US.UTF-8

# vim: ft=sh ts=4 sw=4 et
