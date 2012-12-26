# -*- Mode: python -*-
# This file is read automatically by interactive python sessions
# at startup.

import sys
is_jython = (sys.platform[0:4] == 'java')
is_py3k = (sys.version_info[0] == 3)

# Import common modules.
import os
import re
try:
    import subprocess
    run = subprocess.call
except ImportError:
    # Emulate subprocess.call.
    _run_rx = re.compile("'")
    def run(args):
        args = ["'"+_run_rx.sub(r"'\''", s)+"'" for s in args]
        cmd = " ".join(args)
        return os.system(cmd)

# Home directory.
HOME = os.environ["HOME"]

if not is_jython:
    # Restart python easily.
    def repy(*args):
        os.execl(sys.executable, sys.executable, *args)

# Change current directory.
PWD = OLDPWD = os.getcwd()
def cd(dir_=None):
    global OLDPWD, PWD
    if dir_ == '-':
        dir_ = OLDPWD
    elif dir_ == None or dir_ == '~':
        dir_ = HOME
    elif dir_[0:2] == '~/':
        dir_ = HOME + '/' + dir_[2:]
    _oldpwd = os.getcwd()
    os.chdir(dir_)
    OLDPWD = _oldpwd
    PWD = os.getcwd()

# Factory function, using closures.
def shwrap(cmd=None, opts=None, retbool=None):
    if cmd is None:
        cmd = "echo"
    if opts is None:
        opts = []
    def _f(*args):
        args = [cmd] + list(opts) + map(str, args)
        ret = run(args)
        if ret == 0:
            if retbool: return True
            else: return None
        elif ret == 1:
            if retbool: return False
        raise OSError("cmd '%s' failed with status %d" % (cmd, ret))
    _f.__name__ = cmd
    _f.__doc__ = "Wrapper around command '%s'" % cmd
    return _f

# Some UNIX utilities exposed.
for u in ('pwd', 'ls', 'll', 'la', 'cat', 'cp', 'mv', 'rm', 'mkdir',
          'rmdir'):
    exec('%s = shwrap(cmd="%s")' % (u,u))
for u in ('grep', 'egrep', 'fgrep'):
    exec('%s = shwrap(cmd="%s", retbool=True)' % (u,u))
del u
_sh = shwrap(cmd="/bin/sh", opts=["-c"])
_bash = shwrap(cmd="/bin/bash", opts=["-c"])
def sh(cmd='echo $*', *args):
    _sh(*((cmd, 'sh-from-python') + args))
def bash(cmd='echo $*', *args):
    _bash(*((cmd, 'bash-from-python') + args))

# List opened file descriptors.
def dumpfds():
    ls("-l", "/proc/" + str(os.getpid()) + "/fd")

# Enable tab completion on variable/function/module names!
try:
    import rlcompleter, readline
    readline.read_init_file(HOME + "/" + ".inputrc")
except ImportError:
    pass

# vim: ft=python sw=4 ts=4 et
