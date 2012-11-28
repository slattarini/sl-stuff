# -*- bash -*-

# ssh-agent machinery is not to be run be default.
if [ ! -f ~/.ssh-agent-is-to-be-run ]; then
  return $SUCCESS
fi

# ssh-agent machinery might have already been started.
if [[ ${SSH_AGENT_PID+set} == set ]]; then
    return $SUCCESS
fi

eval "$(ssh-agent -s)" || return $FAILURE;
atexit 'eval "$(ssh-agent -k)"' || { ssh-agent -k; return $FAILURE; }

# vim: ft=sh ts=4 sw=4 et
