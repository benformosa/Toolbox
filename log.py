#!/usr/bin/env python
"""Demonstrates configurable logging output"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import logging


def main():
    """Main function

    Set arguments, configure logging, run test"""

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-l', '--loglevel',
        metavar='LEVEL',
        type=str.lower,
        choices=['critical', 'error', 'warning', 'info', 'debug', 'notset'],
        default='notset',
        help="Highest level of log message to display",
    )
    args = parser.parse_args()

    loglevel = getattr(logging, args.loglevel.upper(), None)
    if not isinstance(loglevel, int):
        raise ValueError('Invalid log level: {}'.format(loglevel))
    logging.basicConfig(
        format='%(levelname)s:%(message)s',
        level=loglevel
    )

    test()


def test():
    """Function to test each log level"""
    logging.critical('This is a CRITICAL message')
    logging.error('This is an ERROR message')
    logging.warning('This is a WARNING message')
    logging.info('This is an INFO message')
    logging.debug('This is a DEBUG message')


if __name__ == '__main__':
    main()
