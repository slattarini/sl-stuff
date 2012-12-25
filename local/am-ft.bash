#!bash
# Remote testing of Automake tarballs made easy.

set -u
me=${0##*/}

fatal () { echo "$me: $*" >&2; exit 1; }

remote=
interactive=1
while test $# -gt 0; do
  case $1 in
   -b|--batch) interactive=0;;
   -*) fatal "'$1': invalid option";;
    *) remote=$1; shift; break;;
  esac
  shift
done
[[ -n $remote ]] || fatal_ "no remote given"

if ((interactive)); then
  do_on_error='exec bash --login -i'
else
  do_on_error='exit $?' 
fi

tarball=$(echo automake*.tar.xz)

case $tarball in
  *' '*) fatal "too many automake tarballs: $tarball";;
esac

test -f $tarball || fatal "no automake tarball found"

distdir=${tarball%%.tar.xz}

env='PATH=~/bin:$PATH'
if test -t 1; then
  env+=" TERM='$TERM' AM_COLOR_TESTS=always"
fi

# This is tempting:
#   $ ssh "command" arg-1 ... arg-2 
# but doesn't work as expected.  So we need the following hack
# to propagate the command line arguments to the remote shell.
quoted_args=--
while (($# > 0)); do
  case $1 in 
    *\'*) quoted_args+=" "$(printf '%s\n' "$1" | sed "s/'/'\\''/g");;
       *) quoted_args+=" '$1'";;
  esac
  shift
done

set -e
set -x

scp $tarball $remote:tmp/

# Multiple '-t' to force tty allocation.
ssh -t -t $remote "
  set -x; set -e;
  set $quoted_args
  cd tmp
  if test -e $distdir; then
    # Use 'perl', not only 'rm -rf', to correctly handle read-only
    # files or directory.  Fall back to 'rm' if something goes awry.
    perl -e 'use File::Path qw/rmtree/; rmtree(\"$distdir\")' \
      || rm -rf $distdir || exit 1
    test ! -e $distdir
  fi
  xz -dc $tarball | tar xf -
  cd $distdir
  if test -d \$HOME/.am-test/extra-aclocal; then
      export ACLOCAL_PATH=\$HOME/.am-test/extra-aclocal
  fi
  if test -d \$HOME/.am-test/extra-bin; then
      export extra_bindir=\$HOME/.am-test/extra-bin
  fi
  export $env"'
  test_script=$HOME/.am-test/run
  st=0
  # FIXME: allow the command to be defined from the command line?
  if test -f $test_script && test -x $test_script; then
    $test_script "$@" || rc=$?
  else
    nice -n19 ./configure && nice -n19 make -j10 check || rc=$?
  fi'"
  ((rc == 0)) || $do_on_error
"
