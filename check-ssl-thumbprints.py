#!/usr/bin/python
"""
Given a list of hostnames, get the thumbprint of the SSL certificate
"""
from socket import *
import OpenSSL
import ssl
import sys

# Print column names
print('hostname,ipaddress,cert_cn,cert_sha1,error')

filename = sys.argv[1]
with open(filename, 'r') as f:
    for line in f:
        hostname = line.rstrip()
        ip = gethostbyname(hostname)
        try:
            # Test if we can connect to port 443
            # I don't know how to set a timeout on ssl.get_server_certificate!
            timeout = 2
            connection = create_connection((hostname, 443), timeout)
            connection.close()

            cert = ssl.get_server_certificate((hostname, 443))
            x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert)
            cn = x509.get_subject().commonName
            digest = x509.digest('sha1')
            print('{},{},{},{},'.format(hostname, ip, cn, digest))
        except(error, timeout) as err:
            print "{},{},,,No connection: {}".format(hostname, ip, err)
