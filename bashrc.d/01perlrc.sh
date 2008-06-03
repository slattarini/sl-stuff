# -*- bash -*-

# Set PERL5LIB variable (for search of perl modules).

PERL5LIB=""
add_to_path -B -p 'PERL5LIB'                            \
    /usr/local/lib/perl /opt/lib/perl "$HOME/lib/perl"  \
      2>/dev/null

[ -n "$PERL5LIB" ] && export PERL5LIB || unset PERL5LIB

# vim: ft=sh ts=4 sw=4 et
