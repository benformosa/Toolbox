#!/usr/bin/python
import argparse
import socket
import sys

parser = argparse.ArgumentParser(description='Simple netcat in pure python.')
parser.add_argument('-s', '--source', metavar='ADDRESS')
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('-w', '--wait', metavar='SECONDS', type=int)
parser.add_argument('-z', '--zero', action='store_true')
parser.add_argument('host')
parser.add_argument('port')
args = parser.parse_args()


# Set a souce address for socket connection
source = ('', 0)
if args.source:
    source = (args.source, 0) # port 0 specifies that the OS will choose a port

# exit successfully if the connection succeeds
if args.zero:
    try:
        connection = socket.create_connection((args.host, args.port), args.wait, source)
        if args.verbose:
            print("Connection to {} {} port (tcp) succeeded!".format(args.host, args.port))
        sys.exit(0)
    except socket.error as msg:
        if args.verbose:
            print("Connection to {} {} port (tcp) failed. {}".format(args.host, args.port, msg))
        sys.exit(1)
else:
    print('Not implemented')
