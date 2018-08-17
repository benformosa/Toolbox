#!/usr/bin/env python2

import argparse
import yaml
import sys

parser = argparse.ArgumentParser(description='Load and dump YAML file')
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

data = yaml.safe_load(args.file)

if not args.skip_doc_start:
    print "---"
print(yaml.safe_dump(data, default_flow_style=False))
