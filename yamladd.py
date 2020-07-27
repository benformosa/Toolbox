#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(
        description='Insert a key-value pair into each mapping '
        'in a YAML sequence of mappings')
parser.add_argument('key', type=str, help='Add this key')
parser.add_argument('value', help='with this value')
parser.add_argument(
        '-f', '--file',
        type=argparse.FileType('r'),
        default=sys.stdin,
        help='YAML file to process',
    )
parser.add_argument(
        '-s', '--skip-doc-start',
        action='store_true',
        help='Do not include document start sequence "---"',
    )
args = parser.parse_args()

# Load YAML from standard in
data = yaml.safe_load(args.file)

if type(data) is list:
    for d in data:
        d[args.key] = args.value

    if not args.skip_doc_start:
        print "---"
    print(yaml.safe_dump(data, default_flow_style=False))

else:
    print("Error: data is not a YAML sequence")
    sys.exit(1)
