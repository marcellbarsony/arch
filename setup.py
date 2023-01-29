#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-01
"""

import argparse

from src import init


def main():
    init.init()


if __name__ == '__main__':
    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='Arch installer',
                        description='Program description',  # TODO
                        epilog='Bottom text'  # TODO
                        )

    args = parser.parse_args()
    main()
