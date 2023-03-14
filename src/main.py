#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-02
"""


import argparse
import configparser
from chroot.s01_keymaps import *
from chroot.s02_account import *
from chroot.s03_host import *
from chroot.s04_security import *
from chroot.s05_localization import *
from chroot.s06_bugfix import *
from chroot.s07_initramfs import *
from chroot.s08_mkinitcpio import *
from chroot.s09_bootloader import *
from chroot.s10_btrfs import *
from chroot.s11_services import *


def main():

    def Keys():
        Keymaps.loadkeys(keys)
        Keymaps.keymap(keys)

    def Accounts():
        Root.password(root_pw)
        User.add(user)
        User.password(user, user_pw)
        User.group(user)

    def Hostname():
        Host.set_hostname(hostname)
        Host.hosts(hostname)

    def Sec():
        Security.sudoers()
        Security.login_delay(logindelay)

    def Loc():
        Locale.locale()
        Locale.locale_conf()
        Locale.locale_gen()

    def Bug():
        Bugfix.watchdog_error()

    def Initram():
        Initramfs.initramfs()

    def Mkinitcp():
        Mkinitcpio.mkinitcpio()

    def Bootloader():
        Grub.config(resolution)
        Grub.install(secureboot, efi_directory)
        Grub.password(grub_password)
        Grub.mkconfig()

    def Filesystem():
        Btrfs.snapper()

    def Services():
        Service.enable()

    Keys()
    Accounts()
    Hostname()
    Sec()
    Loc()
    Bug()
    Initram()
    Mkinitcp()
    Bootloader()
    Filesystem()
    Services()


if __name__ == '__main__':
    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='python3 chroot.py',
                        description='Arch base system [chroot]',
                        epilog='TODO'  # TODO
                        )

    args = parser.parse_args()

    # Config
    config = configparser.ConfigParser()
    config.read('/config.ini')

    # Grub
    efi_directory = config.get('grub', 'efi_directory')
    resolution = config.get('grub', 'resolution')
    secureboot = config.get('grub', 'secureboot')
    grub_password = config.get('grub', 'password')

    # Keys
    keys = config.get('keyset', 'keys')

    # User
    hostname = config.get('user', 'hostname')
    root_pw = config.get('user', 'root_pw')
    user = config.get('user', 'user')
    user_pw = config.get('user', 'user_pw')

    # Security
    logindelay = config.get('security', 'logindelay')

    main()
