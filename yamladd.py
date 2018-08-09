#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(
        description='Insert a key-value pair into each mapping '
        'in a YAML sequence of mappings')
parser.add_argument('key', help='Add this key')
parser.add_argument('value', help='with this value')
args = parser.parse_args()

# Load YAML from standard in
data = yaml.safe_load(sys.stdin)

if type(data) is list:
    for d in data:
        d[args.key] = args.value

    print "---"
    print(yaml.safe_dump(data, default_flow_style=False))

else:
    print("Error: data is not a YAML sequence")
    sys.exit(1)
