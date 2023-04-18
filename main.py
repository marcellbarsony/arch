#!/usr/bin/env python3
"""
Author  : FName SName <mail@domain.com>
Date    : 2023-04
"""


import argparse
import configparser
import getpass

from install import Init
from install import Network
from install import Pacman
from install import Keyring
from install import Config
from install import Disk
from install import Partitions
from install import CryptSetup
from install import Btrfs
from install import Efi
from install import Fstab
from install import Install
from install import Chroot


class Main():

    @staticmethod
    def Initialize():
        Init.setFont(font)
        Init.bootMode()
        Init.timezone()
        Init.sysClock()
        Init.loadkeys(keys)
        Init.keymaps(keymap)

    @staticmethod
    def network_configuration():
        dmidata = Init.dmiData()
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
        Config.main()

    @staticmethod
    def FileSystem():
        d = Disk(disk)
        d.wipe()
        d.partprobe()
        p = Partitions(disk)
        p.createEfi(efisize)
        p.createSystem()

    @staticmethod
    def Encryption():
        crypt = CryptSetup(rootdevice, cryptpassword)
        crypt.encrypt()
        crypt.open()

    @staticmethod
    def Btreefs():
        fs = Btrfs(rootdir)
        fs.mkfs()
        fs.mountfs()
        fs.subvolumes()
        fs.unmount()
        fs.mountRoot()
        fs.mkdir()
        fs.mountSubvolumes()

    @staticmethod
    def efi_partition():
        efi = Efi(efidir, efidevice)
        efi.mkdir()
        efi.format()
        efi.mount()

    @staticmethod
    def fs_table():
        Fstab.mkdir()
        Fstab.genfstab()

    @staticmethod
    def pacstrap():
        Install.bug()
        Install.install()
        Install.installDmi()

    @staticmethod
    def arch_chroot():
        Chroot.copySources()
        Chroot.chroot()
        Chroot.clear()


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
