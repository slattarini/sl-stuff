# -*- bash -*-
# Look for GNU versions of some common programs

for prog in ls grep; do
  eval "have_gnu_$prog=false"
  for prefix in '' gnu-; do
    abspath=$(type -P $prefix$prog) \
      && [[ -n $abspath ]] \
      && ($abspath --version </dev/null | grep GNU) >/dev/null 2>&1 \
      || continue
    eval "gnu_$prog=$abspath"
    eval "have_gnu_$prog=true"
    break
  done
done
unset abspath prog prefix

# vim: ft=sh et ts=4 sw=4
