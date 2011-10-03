# -*- bash -*-

# Simplified name of the current host.
case "$(id -un)@$(uname -n)" in
    (stefano@bigio|stefano@bigio.localdomain)
        hostname=bigio;;
    (ste496@bpserv?(2)?(.*))
        hostname=bpserv;;
    (ste496@bplab?(.*))
        hostname=bplab;;
    (latta@freddy)
        hostname=freddy;;
    (*)
        mwarn "cannot determine simplified name of current system"
        hostname=UNKNOWN;;
esac

IsHost() {
    [[ $hostname == $1 ]]
}

declare -r hostname
declare -rf IsHost

# vim: ft=sh ts=4 sw=4 et
