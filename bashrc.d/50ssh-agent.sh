# -*- bash -*-

if ! IsHost bigio; then
    # ssh-agent machinery is not to be run
    return $SUCCESS
elif [[ ${SSH_AGENT_PID+set} == set ]]; then
    # ssh-agent machinery has been already started
    return $SUCCESS
fi
eval "$(ssh-agent -s)" || return $FAILURE;
ExecOnExit 'eval "$(ssh-agent -k)"' || { ssh-agent -k; return $FAILURE; }

# vim: ft=sh ts=4 sw=4 et
