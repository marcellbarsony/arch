#!/usr/bin/env python3
"""
Author  : Marcell Barsony <marcellbarsony@protonmail.com>
Date    : 2023-03
"""


import configparser

from chroot import Bugfix
from chroot import Finalize
from chroot import Grub
from chroot import Host
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
    def set_keys():
        k = Keymaps(keys)
        k.loadkeys()
        k.keymap()

    @staticmethod
    def user_mgmt():
        r = Root()
        r.password(root_pw)
        u = User(user)
        u.add()
        u.password(user_pw)
        u.group()

    @staticmethod
    def host():
        h = Host(hostname)
        h.set_hostname()
        h.hosts()

    @staticmethod
    def security():
        s = Security()
        s.sudoers()
        s.login_delay(logindelay)
        s.automatic_logout()

    @staticmethod
    def set_locale():
        l = Locale()
        l.locale()
        l.locale_conf()
        l.locale_gen()

    @staticmethod
    def bug():
        b = Bugfix()
        b.watchdog()
        b.pc_speaker()

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

    @staticmethod
    def filesystem():
        s = Snapper()
        s.config()

    @staticmethod
    def secure_shell():
        s = SecureShell()
        s.bashrc(user)

    @staticmethod
    def package_manager():
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


if __name__ == '__main__':

    # Config
    config = configparser.ConfigParser()
    config.read('/_config.ini') # TODO: check dir location

    # Grub
    efi_directory = config.get('grub', 'efi_directory')
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

    m = Main()
    m.set_keys()
    m.user_mgmt()
    m.host()
    m.security()
    m.set_locale()
    m.bug()
    m.initramdisk()
    m.bootloader()
    m.systemd()
    m.filesystem()
    m.secure_shell()
    m.package_manager()
    m.finalize()
