# -*- bash -*-
# Set PATH variable (for search of executable files).

tPATH=''
add_to_path -p tPATH -B /usr/ucb /sbin /bin /usr/sbin /usr/bin
PATH=$tPATH
unset tPATH

add_to_path -B \
    /usr/xpg4/bin \
    /usr/xpg6/bin \
    /usr/ccs/bin \
    /usr/sfw/bin \
    /opt/sfw/bin \
    /opt/SUNWspro/bin \
    /opt/SUNWspro/extra/bin \
    /usr/games \
    /usr/pkg/bin \
    /opt/java/sun-java/bin \
    /opt/bin \
    /usr/local64/bin \
    /usr/local/bin

# On FreeBSD, /usr/local/sbin contains important binaries like pkg_which,
# which should be easily available also to non-root users.
if [[ -f /usr/local/sbin/pkg_which ]]; then
    add_to_path -B /usr/local/sbin
fi

add_to_path -B "/usr/local/opt/bin" "$HOME/bin" "$HOME/bin/utils"

export PATH

# vim: ft=sh ts=4 sw=4 et
