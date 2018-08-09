#!/usr/bin/env python2
"""Minimal netcat in python"""
import socket
import sys

host = sys.argv[1]
port = sys.argv[2]

try:
    c = socket.create_connection((host, port), 2)
    print("Connection to {} {} port (tcp) succeeded!".format(host, port))
    c.close()
    sys.exit(0)
except socket.error as m:
    print("Connection to {} {} port (tcp) failed. {}".format(host, port, m))
    sys.exit(1)
