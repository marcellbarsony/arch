#!/usr/bin/env python3
"""
Author  : FName SName <mail@domain.com>
Date    : 2023-03
"""


import argparse
import configparser
import getpass
from install.s01_init import *
from install.s02_network import *
from install.s03_pacman import *
from install.s04_config import *
from install.s05_disk import *
from install.s06_partitions import *
from install.s07_crypt import *
from install.s08_btrfs import *
from install.s09_efi import *
from install.s10_fstab import *
from install.s11_install import *
from install.s12_chroot import *


class Main():

    @staticmethod
    def Init():
        Initialize.set_font(font)
        Initialize.boot_mode()
        global dmidata
        dmidata = Initialize.dmi_data()
        Initialize.timezone()
        Initialize.sys_clock()
        Initialize.loadkeys(keys)
        Initialize.keymaps(keymap)

    @staticmethod
    def NetworkConfiguration():
        while True:
            if dmidata != 'virtualbox' and 'vmware':
                Network.wifi_connect(network_toggle, network_ssid, network_key)
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
        Disk.wipe(disk)
        Disk.partprobe(disk)
        Partitions.create_efi(disk, efisize)
        Partitions.create_system(disk)

    @staticmethod
    def Encryption():
        CryptSetup.encrypt(rootdevice, cryptpassword)
        CryptSetup.open(rootdevice, cryptpassword)

    @staticmethod
    def Btreefs():
        Btrfs.mkfs(rootdir)
        Btrfs.mountfs(rootdir)
        Btrfs.subvolumes()
        Btrfs.unmount()
        Btrfs.mount_root(rootdir)
        Btrfs.mkdir()
        Btrfs.mount_subvolumes(rootdir)

    @staticmethod
    def EfiPartition():
        Efi.mkdir(efidir)
        Efi.format(efidevice)
        Efi.mount(efidir, efidevice)

    @staticmethod
    def FsTable():
        Fstab.mkdir()
        Fstab.genfstab()

    @staticmethod
    def Pacstrap():
        Install.bug()
        Install.install()
        Install.install_dmi(dmidata)

    @staticmethod
    def ArchChroot():
        Chroot.copy_sources()
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

    Main.Init()
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
