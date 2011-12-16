# -*- bash -*-

if [ -d $HOME/src/go ]; then
    if [[ $SYSTEM_UNAME == ?(freebsd|linux) ]]; then
        export GOROOT=$HOME/src/go
        export GOBIN=$GOROOT/bin
        export GOOS=$SYSTEM_UNAME
        export GOARCH=386
    else
        mwarn "unrecognized system uname \`$SYSTEM_UNAME'"
        mwarn "go environment won't be activated"
    fi
    add_to_path -B "$GOBIN"
fi

# vim: ft=sh ts=4 sw=4 et
