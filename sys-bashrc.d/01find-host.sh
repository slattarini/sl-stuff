# -*- bash -*-

# Name of the current host, "normalized" if possible.
hostname=$(uname -n)
case $hostname in
    (bigio|bigio.localdomain)   hostname=bigio  ;;
    (bpserv?(2)?(.*))           hostname=bpserv ;;
    (bplab?(.*))                hostname=bplab  ;;
    (latta@freddy)              hostname=freddy ;;
esac
declare -r hostname

IsHost() { [[ $hostname == $1 ]]; }

declare -rf IsHost

# vim: ft=sh ts=4 sw=4 et
