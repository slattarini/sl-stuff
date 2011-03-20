# -*- bash -*-

# Set PATH variable (for search of executable files).

tPATH=''
add_to_path -p tPATH -B /usr/ucb /sbin /bin /usr/sbin /usr/bin
PATH=$tPATH
unset tPATH

if [[ $SYSTEM_UNAME == solaris ]]; then
    add_to_path -B \
        /usr/xpg4/bin \
        /usr/xpg6/bin \
        /usr/ccs/bin
        /usr/sfw/bin \
        /opt/sfw/bin \
        /opt/SUNWspro/bin \
        /opt/SUNWspro/extra/bin
fi

add_to_path -B \
    /usr/X11R6/bin \
    /usr/bin/X11R6 \
    /usr/X11/bin \
    /usr/bin/X11 \
    /usr/games \
    /opt/java/sun-java/bin \
    /opt/bin \
    /usr/local64/bin \
    /usr/local/bin

# On FreeBSD, /usr/local/sbin contains important binaries like pkg_which,
# which should be easily available also to non-root users.
if [[ $SYSTEM_UNAME == freebsd ]]; then
    add_to_path -B '/usr/local/sbin'
fi

if [[ -n "$KDE_FULL_SESSION" && -n "$KDE_SESSION_VERSION" ]]; then
    if [ -d "/usr/local/kde$KDE_SESSION_VERSION/bin" ]; then
        add_to_path -B "/usr/local/kde$KDE_SESSION_VERSION/bin"
    fi
    if W kde4-config; then
        d="$(kde4-config --qt-binaries)"
        case ":$PATH:" in
            *:$d:*);;
            *) add_to_path -B "$d";;
        esac
        unset d
    fi
fi

add_to_path -B "/usr/local/opt/bin" "$HOME/bin" "$HOME/bin/utils"

declare -a a=("$SYSTEM_UNAME")
if [[ $SYSTEM_DISTRIBUTOR != UNKNOWN ]]; then
    a=("${a[@]}" "$SYSTEM_DISTRIBUTOR")
fi
for x in "${a[@]}"; do
    d=$HOME/bin/$(normalize_name "$x")
    if [ -d "$d" ]; then
        add_to_path -B "$d"
    fi
done
unset a x d

export PATH

# vim: ft=sh ts=4 sw=4 et
