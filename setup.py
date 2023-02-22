#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-02
"""


import argparse
import importlib


modules = [
    's01_init',
    's02_config',
    's03_disk',
    's04_crypt',
    's05_btrfs',
    's06_fstab',
    's07_install'
    ]


def main():
    for module in modules:
        importlib.import_module(f'base.{module}')
        # imported_module = importlib.import_module(f'base.{module}')
        # func = getattr(imported_module, 'setup')
        # func()


if __name__ == '__main__':
    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='python3 setup.py',
                        description='Arch base system',
                        epilog='TODO'  # TODO
                        )

    args = parser.parse_args()
    main()

