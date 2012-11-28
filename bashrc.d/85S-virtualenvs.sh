# -*- bash -*-

# The `bin/activate' script generated by virtualenv is suboptimal
# in some respects, and need some workarounds.  Since we are at
# it, provide some wrappers with some additional goodies (above
# all, PATH-like search of virtual environments).

# For internal use only.
_activate_virtualenv()
{
    # bin/activate uses the `hash' builtin, but we might have disabled
    # the builtin or the hashing of commands.
    local alias_hash_restore=$(alias hash 2>/dev/null)
    if builtin hash -l >/dev/null 2>&1; then
        alias hash='builtin hash'
    else
        alias hash=':'
    fi
    local rc=$SUCCESS
    . $1/bin/activate || rc=$?
    unalias hash || rc=$FAILURE
    eval "$alias_hash_restore" || rc=$FAILURE
    # bin/activate might export PS1. Yikes!
    export -n PS1 || rc=$FAILURE
    return $rc
}

activate_virtualenv()
{
    local venv_name=${1-generic}
    local oIFS=$IFS
    local IFS=:
    local d0 d1
    for d0 in $VIRTUALENV_PATH; do
        d1=$d0/$venv_name
        IFS=$oIFS
        if [[ -f $d1/bin/activate_this.py && -f $d1/bin/activate ]]; then
            if _activate_virtualenv "$d1"; then
                return $SUCCESS
            else
                fwarn "failed to activate virtualenv $venv_name (in $d1)"
                return $FAILURE
            fi
        fi
    done
    IFS=$oIFS
    fwarn "$venv_name: virtualenv not found"
    return $FAILURE
}

# For consistency with `deactivate', and to avoid to voluntarily trigger
# e.g. the /sbin/activate command.
alias activate=activate_virtualenv

export VIRTUAL_ENV_DISABLE_PROMPT=yes

add_to_path -B -p VIRTUALENV_PATH ~/virtualenvs

atexit 'if declare -F deactivate &>/dev/null; then deactivate; fi'

# vim: ft=sh ts=4 sw=4 et
