#!sh
MAKE=${MAKE-make} GIT=${GIT-git}
$GIT clean -fdx && $MAKE bootstrap && $MAKE dist && exec am-ft "$@"
