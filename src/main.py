#!/usr/bin/env python3
"""
Author  : Marcell Barsony <marcellbarsony@protonmail.com>
Date    : March 2023
"""


import configparser
import logging

from chroot import Finalize
from chroot import Grub
from chroot import Host
from chroot import DomainNameSystem
from chroot import Initramfs
from chroot import Keymaps
from chroot import Locale
from chroot import Mirrorlist
from chroot import Pacman
from chroot import Root
from chroot import SecureShell
from chroot import Security
from chroot import Snapper
from chroot import Systemd
from chroot import User


class Main():

    @staticmethod
    def run():
        m.set_keys()
        m.set_locale()
        m.network()
        m.user_mgmt()
        m.security()
        m.initramdisk()
        m.bootloader()
        m.systemd()
        m.filesystem()
        m.ssh()
        m.pacman()
        m.finalize()

    @staticmethod
    def set_keys():
        k = Keymaps(keys)
        k.loadkeys()
        k.keymap()

    @staticmethod
    def set_locale():
        l = Locale()
        l.locale()
        l.locale_conf()
        l.locale_gen()

    @staticmethod
    def network():
        h = Host(hostname)
        h.set_hostname()
        h.hosts()
        d = DomainNameSystem()
        d.networkmanager()
        d.resolvconf()

    @staticmethod
    def user_mgmt():
        r = Root()
        r.password(root_pw)
        u = User(user)
        u.add()
        u.password(user_pw)
        u.group()

    @staticmethod
    def security():
        s = Security()
        s.sudoers()
        s.login_delay(logindelay)
        s.automatic_logout()

    @staticmethod
    def initramdisk():
        i = Initramfs()
        i.initramfs()
        i.mkinitcpio()

    @staticmethod
    def bootloader():
        g = Grub()
        g.setup()
        g.install(secureboot, efi_directory)
        g.password(grub_password, user)
        g.mkconfig()

    @staticmethod
    def systemd():
        s = Systemd()
        s.logind()
        s.services()
        s.watchdog()
        s.pc_speaker()

    @staticmethod
    def filesystem():
        s = Snapper()
        s.config()

    @staticmethod
    def ssh():
        s = SecureShell()
        s.bashrc(user)

    @staticmethod
    def pacman():
        m = Mirrorlist()
        m.backup()
        m.update()
        p = Pacman()
        p.config()

    @staticmethod
    def finalize():
        f = Finalize(user)
        f.ownership()
        f.remove_dirs()

if __name__ == "__main__":

    """ Initialize Global variables """
    config = configparser.ConfigParser()
    config.read("/config.ini") # TODO: check dir location

    efi_directory = config.get("grub", "efi_directory")
    grub_password = config.get("auth", "grub")
    hostname = config.get("network", "hostname")
    keys = config.get("keyset", "keys")
    logindelay = config.get("security", "logindelay")
    root_pw = config.get("auth", "root_pw")
    secureboot = config.get("grub", "secureboot")
    user = config.get("auth", "user")
    user_pw = config.get("auth", "user_pw")

    """ Initialize logging """
    logging.basicConfig(
        level=logging.INFO, filename="logs.log", filemode="w",
        format="%(levelname)-7s :: %(module)s - %(funcName)s - %(lineno)d :: %(message)s"
    )

    """ Run script """
    m = Main()
    m.run()
