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

add_to_path -B /usr/ucb

add_to_path -B \
    /usr/xpg4/bin \
    /usr/xpg6/bin \
    /usr/ccs/bin \
    /opt/SUNWspro/bin \
    /opt/SUNWspro/extra/bin \
    /usr/games \
    /usr/pkg/bin \
    /opt/java/sun-java/bin \
    /opt/bin \
    /usr/local64/bin \
    /usr/local/bin

if [ $UID -eq 0 ]; then
  add_to_path -B /usr/local/bin /usr/local/sbin
else
  add_to_path -B /usr/local/sbin /usr/local/bin
fi

add_to_path -B "/usr/local/opt/bin" "$HOME/bin" "$HOME/bin/local"

export PATH

# vim: ft=sh ts=4 sw=4 et
