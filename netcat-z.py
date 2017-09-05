#!/usr/bin/python
"""Minimal netcat in python"""
import socket, sys

host = sys.argv[1]
port = sys.argv[2]

try:
    c = socket.create_connection((host, port), 2)
    print("Connection to " + host + " " + port + " port (tcp) succeeded!")
    c.close()
    sys.exit(0)
except socket.error as m:
    print("Connection to " + host + " " + port + " port (tcp) failed. ")
    print(m)
    sys.exit(1)
