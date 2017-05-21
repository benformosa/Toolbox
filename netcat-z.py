#!/usr/bin/python
"""Minimal netcat in python"""
import argparse, socket, sys

p = argparse.ArgumentParser()
p.add_argument('-s', default='')
p.add_argument('host')
p.add_argument('port')
a = p.parse_args()

try:
    c = socket.create_connection((a.host, a.port), 2, (a.s, 0))
    print("Connection to {} {} port (tcp) succeeded!".format(a.host, a.port))
    c.close()
    sys.exit(0)
except socket.error as m:
    print("Connection to {} {} port (tcp) failed. {}".format(a.host, a.port, m))
    sys.exit(1)
