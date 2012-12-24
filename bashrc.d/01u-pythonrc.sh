# -*- bash -*-

# Set file executed at startup by interactive python interpreter.
if [[ -f $HOME/.pythonrc ]]; then
  export PYTHONSTARTUP=$HOME/.pythonrc
fi

# vim: ft=sh ts=4 sw=4 et
