# -*- bash -*-
# I18N

export LC_COLLATE=C
export LC_NUMERIC=C

locale -a &>/dev/null || return $SUCCESS

setlang ()
{
  local vardef errs
  # Use dirty tricks to try to make language setting atomic.
  if ! ((_avoid_setlang_checks)); then
    errs=$(_avoid_setlang_checks=1; setlang "$1" 2>&1) || return 1
    [[ -z $errs ]] || { xecho "$errs" >&2; return 1; }
  fi
  declare -r rc=0
  for x in $(locale); do
    eval "${x%%=*}=$1" || rc=1
  done
  case $1 in C) export LC_ALL=C;; *) unset LC_ALL;; esac || rc=1
  export LC_COLLATE=C && export LC_NUMERIC=C || rc=1
  return $rc
}

clearlang ()
{
  setlang "C"
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

setlang en_US.UTF-8 || {
  mwarn "failed setting locale to en_US.UTF-8, falling back to C locale"
  clearlang
}

return 0

# vim: ft=sh ts=4 sw=4 et
