# -*- bash -*-

# Definiamo la variabile "BROWSER" (browser preferito).
if [ -z "${DISPLAY-}" ]; then
    BROWSER=$(which lynx)
else
    BROWSER=$({ IsRunningKDE && which konqueror; } 2>/dev/null) \
      || BROWSER=$(
            for browser in iceweasel firefox opera lynx; do \
                which "$browser" 2>/dev/null && break;      \
            done)
fi

[ -n "${BROWSER-}" ] && export BROWSER || unset BROWSER

# vim: ft=sh et ts=4 sw=4
