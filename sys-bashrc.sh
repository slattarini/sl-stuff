# -*- bash -*-
# General-purpose .bashrc file for interactive bash(1) shells.
#
# This file is meant to be installed at global, system level if
# possible, and to be used by all the users of the system (by being
# *explicitly* sourced by their ~/.bashrc).  It can also be installed
# in the home directory, though, fore example on systems where one
# lacks root access.
#
# This file is *not* a substitute for /etc/bash.bashrc; it rather strives
# to complement that file, by defining useful extensions, functions and
# aliases that are either system-agnostic, or tries to adaptively work on
# a quite large range of systems.  OTOH, /etc/bash.bashrc is usually meant
# to be tailored for, or even tied to, a specific system or machine.

# Explicitly read system-wide profile (needed in case we're not a login
# shell).
. /etc/profile

# Check the window size after each command and, if necessary, update the
# values of LINES and COLUMNS.
shopt -s checkwinsize

# vim: ft=sh ts=4 sw=4 et
