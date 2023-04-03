#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-02
"""


import argparse
import configparser
from chroot.s01_keymaps import *
from chroot.s02_pacman import *
from chroot.s03_account import *
from chroot.s04_host import *
from chroot.s05_security import *
from chroot.s06_localization import *
from chroot.s07_bugfix import *
from chroot.s08_initramfs import *
from chroot.s09_mkinitcpio import *
from chroot.s10_bootloader import *
from chroot.s11_btrfs import *
from chroot.s12_services import *


class Main():

    @staticmethod
    def Keys():
        Keymaps.loadkeys(keys)
        Keymaps.keymap(keys)

    @staticmethod
    def PackageManager():
        Mirrorlist.backup()
        Mirrorlist.update()
        Pacman.config()

    @staticmethod
    def Accounts():
        Root.password(root_pw)
        User.add(user)
        User.password(user, user_pw)
        User.group(user)

    @staticmethod
    def Hostname():
        Host.set_hostname(hostname)
        Host.hosts(hostname)

    @staticmethod
    def Sec():
        Security.sudoers()
        Security.login_delay(logindelay)
        Security.automatic_logout()

    @staticmethod
    def Loc():
        Locale.locale()
        Locale.locale_conf()
        Locale.locale_gen()

    @staticmethod
    def Bug():
        Bugfix.watchdog_error()

    @staticmethod
    def Initram():
        Initramfs.initramfs()

    @staticmethod
    def Mkinitcp():
        Mkinitcpio.mkinitcpio()

    @staticmethod
    def Bootloader():
        Grub.config(resolution)
        Grub.install(secureboot, efi_directory)
        Grub.password(grub_password, user)
        Grub.mkconfig()

    @staticmethod
    def Filesystem():
        Snapper.config()

    @staticmethod
    def Services():
        Service.enable()


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

    Main.Keys()
    Main.PackageManager()
    Main.Accounts()
    Main.Hostname()
    Main.Sec()
    Main.Loc()
    Main.Bug()
    Main.Initram()
    Main.Mkinitcp()
    Main.Bootloader()
    Main.Filesystem()
    Main.Services()