# -*- bash -*-

# Support for bleeding-edge development tools.
# This must go after any initialization of PATH, INFOPATH, MANPATH
# and ACLOCAL_PATH.

if test x"$shiny_new_tools" = x"yes"; then
  . bleeding
fi

bleed ()
{
  export shiny_new_tools=yes
  exec "$BASH"
}

# vim: ft=sh ts=4 sw=4 et
