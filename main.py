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
    def NetworkConfiguration():
        dmidata = Init.dmiData()
        while True:
            if dmidata != 'virtualbox' and 'vmware':
                Network.wifiConnect(network_toggle, network_ssid, network_key)
            status = Network.check(network_ip, network_port)
            if status == True:
                break

    @staticmethod
    def PackageManager():
        Pacman.config()
        Pacman.bug()

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
    def EfiPartition():
        efi = Efi(efidir, efidevice)
        efi.mkdir()
        efi.format()
        efi.mount()

    @staticmethod
    def FsTable():
        Fstab.mkdir()
        Fstab.genfstab()

    @staticmethod
    def Pacstrap():
        Install.bug()
        Install.install()
        Install.installDmi()

    @staticmethod
    def ArchChroot():
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
    Main.NetworkConfiguration()
    Main.PackageManager()
    Main.Configuration()
    Main.FileSystem()
    Main.Encryption()
    Main.Btreefs()
    Main.EfiPartition()
    Main.FsTable()
    Main.Pacstrap()
    Main.ArchChroot()
