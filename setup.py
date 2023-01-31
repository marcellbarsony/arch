#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-01
"""
import argparse
from base import s01_init as one
from base import s02_menu as two


def main():
    one.setup()
    two.setup()


if __name__ == '__main__':
    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='python3 setup.py',
                        description='Arch base system',
                        epilog='TODO'  # TODO
                        )

    args = parser.parse_args()
    main()
