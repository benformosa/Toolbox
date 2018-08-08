#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(description='Extract values for a single key from a YAML sequence of mappings')
parser.add_argument('key', help='Extract values for this key.')
args = parser.parse_args()

# Load YAML from standard in
data = yaml.safe_load(sys.stdin)

if type(data) is list:
    # List comprehension to extract value by key
    values = [d[args.key] for d in data if args.key in d]

    # Print values
    for v in values:
        print(v)
else:
    print("Error: data is not a YAML sequence")
    sys.exit(1)
