#!/usr/bin/env python2

import argparse
import csv
import itertools
import sys
import yaml

def main():
    parser = argparse.ArgumentParser(
            description='Convert a YAML mapping or sequence of mappings to a CSV'
            )
    parser.add_argument(
            'file',
            type=argparse.FileType('r'),
            default=sys.stdin,
            help='YAML file to process',
        )
    parser.add_argument(
            '-s', '--sort-headers',
            action='store_true',
            help='Sort headers',
        )
    parser.add_argument(
            '-e', '--headers',
            type=str,
            default=None,
            help='Comma-separated list of headers',
        )
    args = parser.parse_args()

    data = yaml.safe_load(args.file)
    if type(data) is dict:
        data = [data]
    if type(data) is list:
        if not args.headers:
            headers = set(flatten([d.keys() for d in data]))
        else:
            headers = args.headers.split(',')
        if args.sort_headers:
            headers = sorted(headers)
        writer = csv.DictWriter(sys.stdout, fieldnames=headers)
        writer.writeheader()
        writer.writerows(data)

    else:
        print("Error: data is not a YAML sequence or mapping")
        sys.exit(1)

def flatten(list_of_lists):
    """Flatten one level of nesting
    
    From itertools docs
    """
    return list(itertools.chain.from_iterable(list_of_lists))

if __name__ == '__main__':
    main()
