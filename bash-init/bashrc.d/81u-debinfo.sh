# -*- bash -*-
# Info used when creating Debian packages.

[ -f /etc/debian_version ] || return $SUCCESS

DEBEMAIL=stefano.lattarini@gmail.com
DEBFULLNAME="Stefano Lattarini"

# vim: ft=sh et ts=4 sw=4
