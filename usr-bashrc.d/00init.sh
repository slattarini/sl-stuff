# -*- bash -*-

#
# Common shell initialization.
#

shopt -s extglob

declare -ir SUCCESS=0
declare -ir FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

declare -r bool='declare -i'
declare -ir FALSE=0
declare -ir TRUE=1

readonly TAB=$'\t'
readonly NL=$'\n'

IFS=" ${TAB}${NL}"

enable 'printf' 'echo'  # just to be sure

xecho() {
    printf '%s\n' "$*"
}
declare -rf xecho

shell_quote() {
    case $* in
        0) cat;;
        *) xecho "$*";;
    esac | sed -e "s/'/'\\\\''/" -e "s/^/'/" -e "s/$/'/"
}
declare -rf shell_quote

warn() {
    xecho "$0: $*" >&2
}
declare -rf warn

mwarn() {
    xecho "$(modulname 2): $*" >&2
}
declare -rf mwarn

fwarn() {
    xecho "$(funcname 2): $*" >&2
}
declare -rf fwarn

funcname() {
    xecho "${FUNCNAME[${1-1}]:-(main)}"
}
declare -rf funcname

modulname() {
    xecho "${BASH_SOURCE[${1-1}]:-$0}"
}
declare -rf funcname

is_function() {
    declare -F "$1" >/dev/null 2>&1
}
declare -rf is_function

# Abstraction layer for lowercase/uppercase conversions.  Mostly meant
# for systems with limited `tr' utility.
tolower() {
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}
toupper() {
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}
declare -rf tolower toupper

normalize_name() {
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | \
      tolower | tr "$TAB" " " | \
      sed -e 's/^ *//' -e 's/ *$//' -e 's/[^a-z0-9][^a-z0-9]*/-/g'
}
normalize_version() {
    case $# in
        0) cat;;
        *) xecho "$*";;
    esac | \
      tolower | tr "$TAB" " " | \
      sed -e 's/^ *//' -e 's/ *$//' -e 's/[^a-z0-9.][^a-z0-9.]*/-/g'
}
declare -rf normalize_name normalize_version

# Simple sanity checks.
[[ -d /etc && -r /etc && -x /etc && ! -h /etc ]] || {
    warn "/etc is not a fully readable non-symlink directory"
    return $FAILURE
}
[[ -f /bin/cat && -x /bin/cat ]] || {
    warn "/bin/cat not found as a regular executable file"
    return $FAILURE
}

# Identify the running system.

SYSTEM_UNAME=$(uname -s)
# strip OS type and version under Cygwin (e.g. CYGWIN_NT-5.1 => Cygwin)
SYSTEM_UNAME=${SYSTEM_UNAME/CYGWIN_*/Cygwin}
# Prefer Solaris over SunOS as system name
SYSTEM_UNAME=${SYSTEM_UNAME/SunOS/Solaris}
# normalize the name
SYSTEM_UNAME=$(xecho "$SYSTEM_UNAME" | normalize_name)

SYSTEM_RELEASE=$(uname -r | normalize_version)
# Newer Solaris systems drop the major version, e.g. Solaris 5.7
# is known simply as "Solaris 7", etc.
if [[ $SYSTEM_UNAME == solaris && $SYSTEM_RELEASE == 5.* ]]; then
    t=${SYSTEM_RELEASE#5.}
    [ 7 -le "$t" ] >/dev/null 2>&1 && SYSTEM_RELEASE=$t
    unset t
fi

if [[ $SYSTEM_UNAME == linux ]]; then
    SYSTEM_DISTRIBUTOR=$(lsb_release -i 2>/dev/null | \
                           sed -n -e "s/^Distributor ID://p" | \
                           normalize_name)
fi
[ -n "${SYSTEM_DISTRIBUTOR-}" ] || SYSTEM_DISTRIBUTOR=UNKNOWN

declare -r SYSTEM_UNAME SYSTEM_RELEASE SYSTEM_DISTRIBUTOR

case $SYSTEM_UNAME,$SYSTEM_RELEASE,$SYSTEM_DISTRIBUTOR in
  freebsd,*|solaris,10,*|linux,*,debian)
    # System fully recognized
    ;;
  *)
    mwarn "***"
    mwarn "*** WARNING WARNING!!!"
    mwarn "*** ('$SYSTEM_UNAME'," \
               "'$SYSTEM_RELEASE'," \
               "'$SYSTEM_DISTRIBUTOR'):" \
               "Invalid triplet (\$uname, \$release, \$distributor)"
    mwarn "*** Something might not work as expected, so be careful"
    mwarn "***"
    ;;
esac

# The `which' utilities on different systems have too much
# incompatibilities between different, so use the `type' bash
# builtin.

which() {
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

declare -rf which W

# We'll need the realpath(1) and readlink(1) programs: locate them and
# test them thoroughly.

t=/tmp/_bashrc-tst-$$-$RANDOM
mkdir $t \
  && echo foo > $t/f.txt \
  && ln -s $t/f.txt $t/f.lnk \
  && ln -s $t/f.lnk $t/f.rlnk \
  && ln -s f.txt $t/f.lnk2 \
  || {
    warn "cannot create/setup temporary directory \`$t'"
    unset t
    return $FAILURE
}

# On non-FreeBSD ad non-Linux systems, binaries we are looking for can be
# stashed in weird/unusual locations.
declare -a extended_path=()
oIFS=$IFS; IFS=:; extended_path=( $PATH ); IFS=$oIFS
extended_path=(
    $HOME/bin
    /usr/local/gnu/bin
    /opt/gnu/bin
    /usr/gnu/bin
    /opt/sfw/bin
    /usr/sfw/bin
    /opt/bin
    /usr/local/bin
    "${extended_path[@]}"
)

# Temporary subroutines used to check readlink and realpath.

_readlink_works() {
    [[ -z $("$@" $t) ]] \
      && [[ -z $("$@" $t/f.txt) ]] \
      && [[ $("$@" $t/f.lnk) == $t/f.txt ]] \
      && [[ $("$@" $t/f.lnk2) == f.txt ]] \
      && [[ $("$@" $t/f.rlnk) == $t/f.lnk ]]
}

_realpath_works() {
    [[ $("$@" $t) == $t ]] \
      && [[ $("$@" /etc/../../$t/) == $t ]] \
      && [[ $("$@" /etc/../$t/.//f.txt) == $t/f.txt ]] \
      && [[ $("$@" /$t/f.lnk) == $t/f.txt ]] \
      && [[ $("$@" /$t/f.lnk2) == $t/f.txt ]] \
      && [[ $("$@" /$t/f.rlnk) == $t/f.txt ]] \
      && [[ $("$@" //etc/../$t/./f.rlnk) == $t/f.txt ]]
}

# Here we go with the search.

as_readlink=""
as_realpath=""

for d in "${extended_path[@]}"; do
    if [[ -f $d/readlink && -x $d/readlink ]]; then
        if [ -z "$as_readlink" ] && _readlink_works $d/readlink; then
            as_readlink=$d/readlink
        fi
        if [ -z "$as_realpath" ] && _realpath_works $d/readlink -f; then
            as_realpath="$d/readlink -f"
        fi
    fi
    [[ -n $as_readlink && -n $as_realpath ]] && break
done

if [ -z "$as_realpath" ]; then
    for d in "${extended_path[@]}"; do
        [[ -f $d/realpath && -x $d/realpath ]] \
           && _realpath_works "$d/realpath" \
           && as_realpath=$d/realpath
        [[ -n $as_realpath ]] && break
    done
fi

# Cleanup temporary files and variables.

rm -rf "$t"
unset t d oIFS extended_path
unset -f _readlink_works _realpath_works

# If we dind't find a proper `readlink' and `realpath' program, give up...

[ -n "$as_readlink" ] || {
    warn "cannot find a working \`readlink' command"
    return $FAILURE
}
[ -n "$as_realpath" ] || {
    warn "cannot find a working \`realpath' command"
    return $FAILURE
}

# ... else save them.

readlink() { $as_readlink "$@"; }
realpath() { $as_realpath "$@"; }
declare -rf realpath readlink
readonly as_realpath as_readlink

# Let's try to set the path of our default Bourne-compatible shell to the
# absolute path of the running bash shell.

if [[ $SYSTEM_UNAME == linux && -h /proc/$$/exe ]]; then
    SHELL=$(readlink /proc/$$/exe)
elif [[ $SYSTEM_UNAME == freebsd && -h /proc/$$/file ]]; then
    SHELL=$(readlink /proc/$$/file)
elif [[ $SYSTEM_UNAME == solaris && -h /proc/$$/path/a.out ]]; then
    SHELL=$(readlink /proc/$$/path/a.out)
else
    SHELL=$(ps hx | awk '($1==PID){print $5}' PID=$$) # rustic fallback
fi

# If $SHELL begins with a `-' character, usually is is not part of its
# name, but is there to means that $SHELL is a login shell; so remove
# such a `-' character, if necessary.
SHELL=${SHELL#-}

case "$SHELL" in
    ""|/*) ;;
    *) SHELL=$(which "$SHELL" 2>/dev/null);;
esac

[ -n "$SHELL" ] || SHELL=/bin/sh

if { [ x"${SHELL:0:1}" = x"/" ] \
     && "$SHELL" -c 'exit 0' \
     && "$SHELL" -c ': && exit 0;' \
     && { "$SHELL" -c 'exit 13;'; [ $? = 13 ]; } \
     && [[ $("$SHELL" -c 'v=foo; echo "$v";') == foo ]] \
     && [[ $("$SHELL" -c 'echo bar | /bin/cat') == bar ]]
   } >/dev/null 2>&1; then
    : # ok, we got it
else
    SHELL=/bin/sh  # fallback to the default system shell
fi

export SHELL

# This variables are set by smart terminal and passed to the shell, so
# pass them to shell child as well.
[ -n "${COLUMNS-}" ] && export COLUMNS
[ -n "${LINES-}" ] && export LINES


# Internal subroutine, used by '_add_dir_to_path()'.
_fixdir_for_path() {
    case "$1" in
        .|..) xecho "$1";;
        *) realpath "$1";;
    esac
}
declare -rf _fixdir_for_path

# Internal subroutine, used by 'add_to_path()'.
# Usage: _add_dir_to_path [-B] DIRECTORY [PATH-VARIABLE='PATH'] [PATHSEP=:]
_add_dir_to_path () {
    $bool prepend=$FALSE
    if [ x"${1-}" = x'-B' ]; then
        prepend=$TRUE
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
declare -rf _add_dir_to_path

# Usage: add_to_path [-B] [-c PATH-SEPARATOR] [-B PATH-VARIABLE] [DIRS]
# Append (or prepend, if given `-B' option) `$2', ... `$n' to the search
# path whose variable name is given by the `-p' option (default to 'PATH').
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
        if [[ "$d" == *"$path_sep"* ]]; then
            fwarn "\`$d': directory name contains the path separator" \
                  "\`$path_sep'"
        elif ! [[ -d $d ]]; then
            fwarn "\`$d': not a directory."
        elif ! [[ -r $d && -x $d ]]; then
            fwarn "\`$d': directory not fully readable."
        else
            _add_dir_to_path $prepend_opt "$d" "$path_var" "$path_sep"
        fi
    done
}
declare -rf add_to_path

return $SUCCESS

# vim: ft=sh ts=4 sw=4 et
