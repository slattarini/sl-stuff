#!/usr/bin/env bash
# Install a GNU package (or one with compatible build system)
# in a way that satisfy my needs.

set -u
set -o pipefail
shopt -s extglob

readonly me=${0##*/}
readonly version=0.1

xecho ()
{
  printf '%s\n' "$*"
}

print_usage ()
{
  xecho "Usage: $me TARBALL"
}

warn ()
{
  printf '%s: %s\n' "$me" "$*" >&2;
}

fatal ()
{
  warn "$@"
  exit 1
}

usage_error ()
{
  warn "$@"
  print_usage >&2
  exit 2
}

case ${1-} in
  --help) print_usage; exit $?;;
  --version) xecho "$version"; exit $?;;
esac

case $# in
  0) usage_error "missing argument";;
  1) tarball=$1;;
  *) usage_error "too many arguments";;
esac

case $tarball in
   *.tar.gz) cmd=gzip;;
  *.tar.bz2) cmd=bzip2;;
   *.tar.xz) cmd=xz;;
          *) fatal "invalid tarball name '$tarball'";;
esac

tarname=${tarball%%.tar.+([a-z])}

test -f "$tarball" || fatal "tarball '$tarball' does not exists"

set -e
set -x

mkdir "$tarname" 
$cmd -dc "$tarball" | (cd "$tarname" && tar xf -)
cd "$tarname"
prefix=$(pwd -L)
mv "$tarname" src
cd src
./configure --disable-nls --prefix="$prefix"
make
make install
make clean

exit 0
