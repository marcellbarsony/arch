#!/usr/bin/env python3
"""
Author  : FName SName <mail@domain.com>
Date    : 2023-05
"""


import argparse
import configparser
import getpass
import os


from src.install import Btrfs
from src.install import Check
from src.install import Chroot
from src.install import CryptSetup
from src.install import Disk
from src.install import Efi
from src.install import Fstab
from src.install import Initialize
from src.install import Install
from src.install import Keyring
from src.install import Pacman


class Main():

    @staticmethod
    def check():
        c = Check()
        c.boot_mode()
        c.network(network_ip, network_port)

    @staticmethod
    def init():
        i = Initialize()
        i.time_zone()
        i.sys_time()
        i.loadkeys(keys)
        i.keymaps(keymap)

    @staticmethod
    def file_system():
        d = Disk()
        d.wipe()
        d.create_efi(efisize)
        d.create_system()
        d.partprobe()

    @staticmethod
    def encryption():
        c = CryptSetup(cryptpassword)
        c.encrypt()
        c.open()

    @staticmethod
    def btrfs():
        b = Btrfs(rootdir)
        b.mkfs()
        b.mountfs()
        b.mksubvols()
        b.unmount()
        b.mount_root()
        b.mkdir()
        b.mount_subvolumes()

    @staticmethod
    def efi():
        e = Efi(efidir)
        e.mkdir()
        e.format()
        e.mount()

    @staticmethod
    def fstab():
        f = Fstab()
        f.mkdir()
        f.genfstab()

    @staticmethod
    def pacman():
        p = Pacman()
        p.config()
        k = Keyring()
        k.init()

    @staticmethod
    def pacstrap():
        p = Install()
        p.bug()
        pkgs = p.get_packages()
        pkgs = p.get_packages_dmi(pkgs)
        p.install(pkgs)

    @staticmethod
    def arch_chroot():
        c = Chroot(current_dir)
        c.copy_sources()
        c.chroot()
        c.clear()


if __name__ == '__main__':

    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='python3 setup.py',
                        description='Arch base system',
                        epilog='TODO'  # TODO
                        )

    args = parser.parse_args()

    """ Initialize variables """

    # Config
    config = configparser.ConfigParser()
    config.read('_config.ini')

    # EFI
    efisize = config.get('efi', 'efisize')

    # Encryption
    cryptpassword = config.get('encryption', 'cryptpassword')

    # Filesystem (BTRFS)
    rootdir = config.get('btrfs', 'rootdir')
    efidir = config.get('btrfs', 'efidir')

    # Keys
    font = config.get('keyset', 'font')
    keys = config.get('keyset', 'keys')
    keymap = config.get('keyset', 'keymap')

    # Network
    network_ip = config.get('network', 'ip')
    network_port = config.get('network', 'port')

    # User
    user = getpass.getuser()

    # Directory
    current_dir = os.getcwd()

    m = Main()
    m.check()
    m.init()
    m.file_system()
    m.encryption()
    m.btrfs()
    m.efi()
    m.fstab()
    m.pacman()
    m.pacstrap()
    m.arch_chroot()
