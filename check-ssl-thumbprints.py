#!/usr/bin/python3
"""
Given a list of hostnames, get the thumbprint of the SSL certificate
"""
import OpenSSL
import fileinput
import socket
import ssl
import sys

# Print column names
print('hostname,ipaddress,cert_cn,cert_sha1,error')

for line in fileinput.input():
    hostname = line.rstrip()
    try:
        ip = socket.gethostbyname(hostname)
        # Create the ssl socket
        timeout = 2
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        conn = context.wrap_socket(
                socket.socket(socket.AF_INET),
                )
        conn.settimeout(timeout)
        conn.connect((hostname, 443))

        # Get the certificate as a DER-encoded byte sequence
        cert = conn.getpeercert(binary_form=True)
        # Load the certificate
        x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_ASN1, cert)
        # Get the certificate details
        cn = x509.get_subject().commonName
        digest = x509.digest('sha1').decode("utf-8")
        print('{},{},{},{},'.format(hostname, ip, cn, digest))
    except:
        err = sys.exc_info()
        print("{},,,,No connection: {}".format(hostname, err))
