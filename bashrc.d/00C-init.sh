# -*- bash -*-
# Common shell initialization.

shopt -s extglob

declare -ir SUCCESS=0
declare -ir FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

IFS=' '$'\t'$'\n'

xecho () { printf '%s\n' "$*"; }

warn ()  { xecho "$0: $*" >&2; }
mwarn () { xecho "$(modulname 2): $*" >&2; }
fwarn () { xecho "$(funcname 2): $*" >&2; }

funcname()  { xecho "${FUNCNAME[${1-1}]:-(main)}"; }
modulname() { xecho "${BASH_SOURCE[${1-1}]:-$0}"; }

is_function() { declare -F "$1" &>/dev/null; }

# Abstraction layer for lowercase/uppercase conversions.  Mostly meant
# for systems with limited 'tr' utility.
tolower()
{
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}
toupper()
{
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

# 'which' utilities on different systems have too many incompatibilities
# between different, so use the 'type' bash builtin instead.  Also, some
# systems (e.g., Fedora 16) pre-define a 'which' alias that interferes
# with our usage; get rid of it beforehand.
unalias which &>/dev/null

which ()
{
    local opts=''
    while (($#)); do
        case $1 in
            --) shift; break;;
            -a|--all) opts='-a'; shift;;
            -*) echo "which: invalid option: '$1'" >&2; return $E_USAGE;;
             *) break;;
        esac
    done
    (($#)) || { echo "which: missing argument" >&2; return $E_USAGE; }
    type -P $opts -- "$@"
}

W() { which "$@" >/dev/null 2>&1; }

# On non-FreeBSD and non-Linux systems, some binaries we are looking for
# can be stashed in weird/unusual locations.
declare -ra extra_gnu_path=(
    "$HOME"/bin
    /usr/local/bin
    /usr/local/gnu/bin
    /opt/gnu/bin
    /usr/gnu/bin
    /opt/sfw/bin
    /usr/sfw/bin
    /opt/bin
)

# The given command must support the '--help' option and have the string
# "GNU" in its help screen to be considered a GNU program.
is_gnu_program ()
{
   (set -o pipefail; "$1" --help | grep GNU) </dev/null >/dev/null 2>&1
}

# Usage: find_better_program PROGRAM-NAME VARIABLE-NAME
#                            [TEST-FUNCTION=is_gnu_program]
# VARIABLE-NAME will be unconditionally clobbered.
find_better_program ()
{
  case $# in
    0|1) fwarn "too few arguments ($#)";  return $E_USAGE;;
    2|3) ;;
      *) fwarn "too many arguments ($#)"; return $E_USAGE;;
  esac
  local program=$1; shift
  local varname=$1; shift
  unset "$varname" || return $E_USAGE
  local test_function=${1-is_gnu_program}; shift
  local oIFS=$IFS
  local IFS=:
  local dir
  for dir in "${extra_gnu_path[@]}" $PATH; do
    IFS=$oIFS
    [[ -f $dir/$program && -x $dir/$program ]] || continue
    $test_function "$dir/$program" || continue
    eval "$varname"='$dir/$program' || return $FAILURE
    return $SUCCESS
  done
  return $FAILURE
}

# Let's try to set the path of our default Bourne-compatible shell to the
# absolute path of the running bash shell.  $BASH id documented to be set
# as an absolute path, so simply use it.
if ! [[ ${BASH:0:1} == '/' && -f $BASH && -x $BASH ]]; then
  mwarn "\$BASH ($BASH) is not an absolute path of an executable file"
else
  export SHELL=$BASH
fi

# Temporary subroutine, used by the check right below.
_check_realpath()
{
  [[ $("$1" /.//../ 2>/dev/null) == / ]]
}
# Internal subroutine '_weak_realpath', used by '_fixdir_for_path'.
if find_better_program realpath REALPATH_CMD _check_realpath; then
  _weak_realpath() { $REALPATH_CMD "$@"; }
else
  _weak_realpath() { xecho "$1"; }
fi
# Get rid of this temporary subroutine.
unset -f _check_realpath

# Internal subroutine, used by '_add_dir_to_path()'.
_fixdir_for_path() {
    case "$1" in
        .|..) xecho "$1";;
        *) _weak_realpath "$1";;
    esac
}

# Internal subroutine, used by 'add_to_path()'.
# Usage: _add_dir_to_path [-B] DIRECTORY [PATH-VARIABLE='PATH'] [PATHSEP=:]
_add_dir_to_path () {
    declare -i prepend=0
    if [ x"${1-}" = x'-B' ]; then
        prepend=1
        shift
    fi
    # Be sure to use the "real" path of the directory to add.
    local dir_to_add=$(_fixdir_for_path "$1")
    local path_var=${2-'PATH'}
    local path_sep=${3-':'}
    if [[ -z ${!path_var} ]]; then
        # Just create the PATH from scratch.
        eval "$path_var=\$dir_to_add"
    elif ((prepend)); then
        local reset_glob new_path
        [[ $- == *f* ]] && reset_glob=: || reset_glob='set +f'
        set -f # temporarily disable globbing
        # Remove from PATH any pre-existing copy of the directory to add.
        oIFS=$IFS; IFS=$path_sep
        for d in ${!path_var}; do # for every directory in the old PATH...
            IFS=$oIFS
            d=$(_fixdir_for_path "${d:-.}") # ... take its "real" path ...
            # ... filter it out if it's equal to the directory to add ...
            [[ $d == $dir_to_add ]] && continue
            # ... else add it back to the new value of PATH.
            new_path=${new_path:+"${new_path}${path_sep}"}$d
        done
        IFS=$oIFS; $reset_glob;
        new_path=${dir_to_add}${new_path:+"${path_sep}${new_path}"}
        eval "$path_var=\$new_path"
    else
        # It's useless to append the new directory to path if it's
        # already there.
        case "${path_sep}${dir_to_add}${path_sep}" in
            "${!path_var}");;
            *) eval "$path_var=\$$path_var\$path_sep\$dir_to_add";;
        esac
    fi
}

# Usage: add_to_path [-B] [-c PATH-SEPARATOR] [-B PATH-VARIABLE] [DIRS]
# Append (or prepend, if given '-B' option) '$2', ... '$n' to the search
# path whose variable name is given by the '-p' option (default to 'PATH').
# The path separator is assumed to be ':', unless differently specified by
# the '-c' option.
add_to_path()
{
    local prepend_opt=''
    local path_sep=':' path_var='PATH'
    local OPTION OPTARG OPTIND OPTERR
    while getopts ":Bc:p:" OPTION; do
        case "$OPTION" in
            B) prepend_opt=-B;;
            c) path_sep=$OPTARG;;
            p) path_var=$OPTARG;;
            \?) fwarn "unknown option '-$OPTARG'";;
            :) fwarn "option '-$OPTARG': missing argument";;
        esac
    done
    shift $((OPTIND - 1))
    unset OPTION OPTARG OPTIND OPTERR

    # TODO: check $path_var to see if it's a valid name?

    local d
    for d in "$@"; do
        if [[ ! -e $d ]]; then
            # It's not unusual, when having to work on several different
            # systems, to try to add a directory that only exists on few
            # of those systems.  Printing a warning in such cases is
            # mostly just noise.
            continue
        elif [[ $d == *"$path_sep"* ]]; then
            fwarn "'$d': directory name contains the path separator" \
                  "'$path_sep'"
        elif [[ ! -d $d ]]; then
            fwarn "'$d': not a directory."
        elif ! [[ -r $d && -x $d ]]; then
            fwarn "'$d': directory not fully readable."
        else
            _add_dir_to_path $prepend_opt "$d" "$path_var" "$path_sep"
        fi
    done
}

return $SUCCESS

# vim: ft=sh ts=4 sw=4 et
