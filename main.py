#!/usr/bin/env python3
"""
Author  : FName SName <mail@domain.com>
Date    : 2023-04
"""


import argparse
import configparser
import getpass
import os

from src.install import Init
from src.install import Network
from src.install import Pacman
from src.install import Keyring
from src.install import Config
from src.install import Disk
from src.install import Partitions
from src.install import CryptSetup
from src.install import Btrfs
from src.install import Efi
from src.install import Fstab
from src.install import Install
from src.install import Chroot


class Main():

    @staticmethod
    def Initialize():
        init = Init()
        init.set_font(font)
        init.boot_mode()
        init.timezone()
        init.sys_clock()
        init.loadkeys(keys)
        init.keymaps(keymap)

    @staticmethod
    def network_configuration():
        dmidata = Init.dmi_data()
        while True:
            if dmidata != 'virtualbox' and 'vmware':
                Network.wifiConnect(network_toggle, network_ssid, network_key)
            status = Network.check(network_ip, network_port)
            if status == True:
                break

    @staticmethod
    def package_manager():
        Pacman.config()
        Keyring.init()

    @staticmethod
    def Configuration():
        c = Config()
        c.main()

    @staticmethod
    def FileSystem():
        d = Disk(disk)
        d.wipe()
        d.partprobe()
        p = Partitions(disk)
        p.efi(efisize)
        p.system()

    @staticmethod
    def Encryption():
        c = CryptSetup(rootdevice, cryptpassword)
        c.encrypt()
        c.open()

    @staticmethod
    def Btreefs():
        fs = Btrfs(rootdir)
        fs.mkfs()
        fs.mountfs()
        fs.mksubvols()
        fs.unmount()
        fs.mount_root()
        fs.mkdir()
        fs.mount_subvolumes()

    @staticmethod
    def efi_partition():
        efi = Efi(efidir, efidevice)
        efi.mkdir()
        efi.format()
        efi.mount()

    @staticmethod
    def fs_table():
        fstab = Fstab()
        fstab.mkdir()
        fstab.genfstab()

    @staticmethod
    def pacstrap():
        pac = Install()
        pac.bug()
        pac.install()
        pac.install_dmi()

    @staticmethod
    def arch_chroot():
        chrt = Chroot(current_dir)
        chrt.copySources()
        chrt.chroot()
        chrt.clear()


if __name__ == '__main__':
    """ Initialize argparse """

    parser = argparse.ArgumentParser(
                        prog='python3 setup.py',
                        description='Arch base system',
                        epilog='TODO'  # TODO
                        )

    args = parser.parse_args()

    # Config
    config = configparser.ConfigParser()
    config.read('config.ini')

    # Disk
    disk = config.get('drive', 'disk')
    efidevice = config.get('drive', 'efidevice')
    rootdevice = config.get('drive', 'rootdevice')

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
    network_toggle = config.get('network', 'wifi')
    network_key = config.get('network', 'wifi_key')
    network_ssid = config.get('network', 'wifi_ssid')

    # User
    user = getpass.getuser()

    # Directory
    current_dir = os.getcwd()

    Main.Initialize()
    Main.network_configuration()
    Main.package_manager()
    Main.Configuration()
    Main.FileSystem()
    Main.Encryption()
    Main.Btreefs()
    Main.efi_partition()
    Main.fs_table()
    Main.pacstrap()
    Main.arch_chroot()
