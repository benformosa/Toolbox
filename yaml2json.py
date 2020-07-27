#!/usr/bin/env python2

import argparse
import json
import sys
import yaml

parser = argparse.ArgumentParser(description='Convert YAML to JSON')
parser.add_argument(
        '-f', '--file',
        type=argparse.FileType('r'),
        default=sys.stdin,
        help='YAML file to process',
    )
args = parser.parse_args()

data = yaml.safe_load(args.file)

print(json.dumps(data))
