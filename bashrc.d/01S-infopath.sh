# -*- bash -*-
# Set INFOPATH variable (for search of documentation in info format).

if W info; then
    INFOPATH=""
    add_to_path -B -p 'INFOPATH' \
      /usr/info /usr/share/info /usr/local/info /usr/local/share/info \
      /opt/info "$HOME"/info "$HOME"/share/info
    if [ -n "$INFOPATH" ]; then
        export INFOPATH
    else
        unset INFOPATH
    fi
else
    mwarn "program info(1) not found, thus simply unsetting INFOPATH"
    unset INFOPATH
fi

# vim: ft=sh ts=4 sw=4 et
