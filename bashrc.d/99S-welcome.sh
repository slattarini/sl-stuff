# -*- bash -*-

readonly print_stripe=$(which 'print_stripe' 2>/dev/null || echo ':')

tput reset
clear

if W fortune && IsHost bigio; then
    welcome() {
        clear
        echo
        $print_stripe '-' ' '
        echo
        fortune
        echo
        $print_stripe '-' ' '
        echo
        return $SUCCESS
    }
    welcome
fi

# vim: ft=sh et ts=4 sw=4
