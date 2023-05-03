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
from chroot import SecureShell
from chroot import Service
from chroot import Finalize


class Main():

    @staticmethod
    def Keys():
        key = Keymaps(keys)
        key.loadkeys()
        key.keymap()

    @staticmethod
    def package_manager():
        ml = Mirrorlist()
        ml.backup()
        ml.update()
        Pacman.config()

    @staticmethod
    def accounts():
        Root.password(root_pw)
        usr = User(user)
        usr.add()
        usr.password(user_pw)
        usr.group()

    @staticmethod
    def host_setup():
        host = Host(hostname)
        host.setHostname()
        host.hosts()

    @staticmethod
    def security():
        sec = Security()
        sec.sudoers()
        sec.loginDelay(logindelay)
        sec.automaticLogout()

    @staticmethod
    def Loc():
        loc = Locale()
        loc.locale()
        loc.localeConf()
        loc.localeGen()

    @staticmethod
    def bug():
        Bugfix.watchdogError()

    @staticmethod
    def initram():
        Initramfs.initramfs()

    @staticmethod
    def mkinit():
        Mkinitcpio.mkinitcpio()

    @staticmethod
    def bootloader():
        Grub.config(resolution)
        Grub.install(secureboot, efi_directory)
        Grub.password(grub_password, user)
        Grub.mkconfig()

    @staticmethod
    def filesystem():
        Snapper.config()

    @staticmethod
    def secureshell():
        SecureShell.bashrc(user)

    @staticmethod
    def services():
        Service.enable()

    @staticmethod
    def finalize():
        Finalize.ownership(user)


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
    config.read('/config.ini') # TODO: check dir location

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
    Main.package_manager()
    Main.accounts()
    Main.host_setup()
    Main.security()
    Main.Loc()
    Main.bug()
    Main.initram()
    Main.mkinit()
    Main.bootloader()
    Main.filesystem()
    Main.secureshell()
    Main.services()
    Main.finalize()
