#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(
        description='Extract values for a single key '
        'from a YAML mapping or sequence of mappings'
        )
parser.add_argument(
        'key',
        type=str,
        help='Extract values for this key.'
        )
parser.add_argument(
        '-f', '--file',
        type=argparse.FileType('r'),
        default=sys.stdin,
        help='YAML file to process',
    )
args = parser.parse_args()

data = yaml.safe_load(args.file)
if type(data) is list:
    # List comprehension to extract value by key
    values = [d[args.key] for d in data if args.key in d]

    for v in values:
        print(v)
elif type(data) is dict:
    print(data[args.key])
else:
    print("Error: data is not a YAML sequence or mapping")
    sys.exit(1)
