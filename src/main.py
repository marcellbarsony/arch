#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
Date    : 2023-04
"""


import argparse
import configparser
from chroot import Keymaps
from chroot import Mirrorlist
from chroot import Pacman
from chroot import Root
from chroot import User
from chroot import Host
from chroot import Security
from chroot import Locale
from chroot import Bugfix
from chroot import Initramfs
from chroot import Mkinitcpio
from chroot import Grub
from chroot import Snapper
from chroot import Service


class Main():

    @staticmethod
    def Keys():
        key = Keymaps(keys)
        key.loadkeys()
        key.keymap()

    @staticmethod
    def PackageManager():
        ml = Mirrorlist()
        ml.backup()
        ml.update()
        Pacman.config()

    @staticmethod
    def Accounts():
        Root.password(root_pw)
        usr = User(user)
        usr.add()
        usr.password(user_pw)
        usr.group()

    @staticmethod
    def Hosts():
        host = Host(hostname)
        host.setHostname()
        host.hosts()

    @staticmethod
    def Sec():
        Security.sudoers()
        Security.loginDelay(logindelay)
        Security.automatic_logout()

    @staticmethod
    def Loc():
        Locale.locale()
        Locale.localeConf()
        Locale.localeGen()

    @staticmethod
    def Bug():
        Bugfix.watchdogError()

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
    Main.Hosts()
    Main.Sec()
    Main.Loc()
    Main.Bug()
    Main.Initram()
    Main.Mkinitcp()
    Main.Bootloader()
    Main.Filesystem()
    Main.Services()
