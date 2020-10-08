#!/usr/bin/env python

from __future__ import absolute_import, division, print_function

import argparse
import json
import sys

import yaml


def main():
    parser = argparse.ArgumentParser(description="Convert JSON to YAML")
    parser.add_argument(
        "-f",
        "--file",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="JSON file to process",
    )
    args = parser.parse_args()

    data = json.load(args.file)

    print(
        (yaml.safe_dump(data, default_flow_style=False, indent=2, explicit_start=True)),
    )


if __name__ == "__main__":
    main()
