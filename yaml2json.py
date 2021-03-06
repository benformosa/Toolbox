#!/usr/bin/env python

from __future__ import absolute_import, division, print_function

import argparse
import json
import sys

import yaml


def main():
    parser = argparse.ArgumentParser(description="Convert YAML to JSON")
    parser.add_argument(
        "-f",
        "--file",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="YAML file to process",
    )
    args = parser.parse_args()

    data = yaml.safe_load(args.file)

    print((json.dumps(data)))


if __name__ == "__main__":
    main()
