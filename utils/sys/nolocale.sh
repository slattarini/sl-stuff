#!sh
# Run the given program with the locale set to C. If no program to run is
# given, emits shell code that can be eval'd to set the locale to C.
case $# in
    0) do=echo;;
    *) do=eval;;
esac
locale_vars=$(locale 2>/dev/null | sed -e 's/=.*$//')
locale_vars="LANG LANGUAGE LC_ALL $locale_vars"
for var in $locale_vars; do
    $do "export $var=C" || exit 1
done
[ $# -gt 0 ] || exit 0
exec "$@" || exit 255
# vim: et sw=4 ts=4 ft=sh
