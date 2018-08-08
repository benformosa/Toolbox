#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(description='Extract values for a single key from a yaml sequence of mappings')
parser.add_argument('key', help='Extract values for this key.')
args = parser.parse_args()

# Load YAML from standard in
data = yaml.safe_load(sys.stdin)

# List comprehension to extract value by key
values = [d[args.key] for d in data if args.key in d]

# Print values
for v in values:
    print(v)
