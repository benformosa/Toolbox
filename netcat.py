#!/usr/bin/python2
import argparse
import socket
import sys

parser = argparse.ArgumentParser(description='Simple netcat in pure python.')
parser.add_argument('-z', '--scan', action='store_true')
parser.add_argument('-w', '--timeout', metavar='SECONDS', type=int)
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('host')
parser.add_argument('port', type=int)
args = parser.parse_args()

if args.scan:
    try:
        connection = socket.create_connection((args.host, args.port), args.timeout)
        if args.verbose:
            print "Connection to {} {} port (tcp) succeeded!".format(args.host, args.port)
        sys.exit(0)
    except socket.error as msg:
        if args.verbose:
            print "Connection to {} {} port (tcp) failed. {}".format(args.host, args.port, msg)
        sys.exit(1)
else:
    print 'Not implemented'
