# -*- bash -*-
# Set PATH variable (for search of executable files).

# The add_to_path subroutine might rely on basic external programs,
# so we cannot modify PATH directly here.  We use this temporary
# variable instead.
tPATH=''
if [ $UID -eq 0 ]; then
  add_to_path -B /bin /sbin /usr/bin /usr/sbin
else
  add_to_path -B /sbin /bin /usr/sbin /usr/bin
fi
PATH=$tPATH
unset tPATH

# These are for Solaris, mostly.
add_to_path -B \
    /usr/ucb \
    /usr/xpg4/bin \
    /usr/xpg6/bin \
    /usr/ccs/bin \
    /opt/SUNWspro/bin \
    /opt/SUNWspro/extra/bin \

# For NetBSD.
add_to_path -B /usr/pkg/bin

# Hack for my Debian desktop.
add_to_path -B /opt/java/sun-java/bin

if [ $UID -eq 0 ]; then
  add_to_path -B /usr/local/bin /usr/local/sbin
  add_to_path -B /usr/local64/bin /usr/local64/sbin
else
  add_to_path -B /usr/games
  add_to_path -B /opt/bin
  add_to_path -B /usr/local/sbin /usr/local/bin
  add_to_path -B /usr/local64/sbin /usr/local64/bin
fi

add_to_path -B "$HOME/bin" "$HOME/bin/local"

export PATH

# vim: ft=sh ts=4 sw=4 et
