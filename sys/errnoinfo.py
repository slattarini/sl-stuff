#!python
# Translate between error symbolic names and error numbers, and from
# both of these to system error messages.

import errno as Errno
import os, sys

EXIT_SUCCESS = 0
EXIT_FAILURE = 1
E_USAGE = 2

progname = os.path.basename(sys.argv[0])

# ---

class ErrnoException(Exception):
    pass

# ---

class ErrnoInfo(object):

    __slots__ = ('errno', 'errname', 'strerror')

    def __init__(self, value):
        try:
            value = int(value)
        except ValueError:
            # value is a symbolic name.
            self.set_errnoinfo_from_symbolic_name(value)
        else:
            # value is an error number.
            self.set_errnoinfo_from_error_number(value)
        self.strerror = os.strerror(self.errno)

    def set_errnoinfo_from_symbolic_name(self, errname):
        exc = ErrnoException("invalid error symbol '%s'" % errname)
        if not isinstance (errname, basestring):
            raise TypeError("value has bad type %s" % type(errname))
        elif not errname.startswith('E'):
            raise exc
        else:
            try:
                self.errname = errname
                self.errno = getattr(Errno, errname)
            except AttributeError:
                raise exc

    def set_errnoinfo_from_error_number(self, errno):
        self.errno = errno
        try:
            self.errname = Errno.errorcode[errno]
        except KeyError:
            raise ErrnoException("invalid error number '%d'" % errno)

    def __str__(self):
       return ('errname=%s, errno=%d, strerror="%s"' %
               (self.errname, self.errno, self.strerror))

# ---

def warn(msg):
    print >>sys.stderr, "%s: %s" % (progname, msg)

# ---

def main(args=None):
    exit_status = EXIT_SUCCESS
    if args is None:
        args = sys.argv[1:]
    if not args:
        args = sorted(Errno.errorcode.keys())
    for x in args:
        try:
            print ErrnoInfo(x)
        except ErrnoException, e:
            warn(e.message)
            exit_status = EXIT_FAILURE
    sys.exit(exit_status)

def close_standard_streams():
    fail = False
    try:
        sys.stdin.close()
    except IOError, e:
        fail = True
        warn("cannot close standard input: %s" % e.strerror)
    try:
        sys.stdout.close()
    except IOError, e:
        fail = True
        warn("write error on standard output: %s" % e.strerror)
    try:
        sys.stderr.close()
    except IOError, e:
        fail = True
        warn("write error on standard error: %s" % e.strerror)
    if fail:
        sys.exit(EXIT_FAILURE)

# ---

if __name__ == '__main__':
    try:
        main()
        # If the code flow is still here, main() failed to set a proper
        # exit status.
        raise SystemExit(EXIT_FAILURE)
    except SystemExit, e:
        close_standard_streams()
        sys.exit(e.code)

# vim: ft=python ts=4 sw=4 et
