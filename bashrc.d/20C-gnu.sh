# -*- bash -*-
# Look for GNU versions of some common programs.

have_gnu_program ()
{
  local var=gnu_$1
  if [[ ${!var+set} != set ]]; then
    return 77
  elif [[ ${!var} && ${!var} != [nN]o ]]; then
    return 0
  else
    return 1
  fi
}
have_gnu () { have_gnu_program "$@"; }

look_for_gnu_program ()
{
  local program=$1
  have_gnu_program "$program"
  case $? in 77);; *) return $?;; esac
  local prefix abspath
  for prefix in '' gnu-; do
    abspath=$(type -P $prefix$program) \
      && [[ -n $abspath ]] \
      && ($abspath --version </dev/null | grep GNU) >/dev/null 2>&1 \
      || continue
    eval "gnu_$program=$abspath"
    return 0
  done
  return 1
}

look_for_gnu_program ls
look_for_gnu_program grep

# vim: ft=sh et ts=4 sw=4
