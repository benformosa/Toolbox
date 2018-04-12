#!/usr/bin/env python
"""Demonstrates verbose option for script output

Based on https://stackoverflow.com/a/14763540/813821"""
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbosity', action="count",
            help="Increase output verbosity (e.g., -vv is more than -v)")
    args = parser.parse_args()

    # Set up v_print function for verbose output
    if args.verbosity:
        def _v_print(*verb_args):
            if verb_args[0] > (3 - args.verbosity):
                print(verb_args[1])
    else:
        _v_print = lambda *a: None # do-nothing function

    global v_print
    v_print = _v_print

    test()

def test():
    """Function to test each level of verbosity"""
    v_print(1, "-vvv Verbose 1 - INFO")
    v_print(2, "-vv  Verbose 2 - WARN")
    v_print(3, "-v   Verbose 3 - ERROR")

if __name__ == '__main__':
    main()
