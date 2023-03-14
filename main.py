#!/usr/bin/env python3
"""
Author  : Name Surname <mail@domain.com>
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


def main():

    def Init():
        Initialize.boot_mode()
        global dmidata
        dmidata = Initialize.dmi_data()
        Initialize.sys_clock()
        Initialize.loadkeys(keys)
        Initialize.keymaps(keymap)

    def NetConf():
        while True:
            if dmidata != 'virtualbox' and 'vmware':
                Network.wifi_activate(network_toggle)
                Network.wifi_connect(network_ssid, network_key)
            status = Network.check(network_ip, network_port)
            if status == True:
                break

    def PacConf():
        Pacman.config()
        Pacman.mirrors()
        Pacman.keyring()

    def Configuration():
        Config.main()

    def Filesystem():
        WipeDisk.filesystem(disk)
        WipeDisk.partition_data(disk)
        WipeDisk.gpt_data(disk)
        WipeDisk.partprobe(disk)
        Partitions.create_efi(disk, efisize)
        Partitions.create_system(disk)

    def Encryption():
        CryptSetup.encrypt(rootdevice, cryptpassword)
        CryptSetup.open(rootdevice, cryptpassword)

    def Btreefs():
        Btrfs.mkfs(rootdir)
        Btrfs.mountfs(rootdir)
        Btrfs.subvolumes()
        Btrfs.unmount()
        Btrfs.mount_root(rootdir)
        Btrfs.mkdir()
        Btrfs.mount_subvolumes(rootdir)

    def Efipart():
        Efi.mkdir(efidir)
        Efi.format(efidevice)
        Efi.mount(efidir, efidevice)

    def FsTable():
        Fstab.mkdir()
        Fstab.genfstab()

    def Pacstrap():
        Mirrorlist.backup()
        Mirrorlist.update()
        Install.bug()
        Install.install(pacmanconf)
        Install.install_dmi(pacmanconf)

    def ArchChroot():
        Chroot.copy_pacconf()
        Chroot.copy_script()
        Chroot.chroot()
        Chroot.clear()


    Init()
    NetConf()
    PacConf()
    Configuration()
    Filesystem()
    Encryption()
    Btreefs()
    Efipart()
    FsTable()
    Pacstrap()
    ArchChroot()


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

    # Efi
    efisize = config.get('efi', 'efisize')

    # Encryption
    cryptpassword = config.get('encryption', 'cryptpassword')

    # Filesystem (BTRFS)
    rootdir = config.get('btrfs', 'rootdir')
    efidir = config.get('btrfs', 'efidir')

    # Keys
    keys = config.get('keyset', 'keys')
    keymap = config.get('keyset', 'keymap')

    # Network
    network_ip = config.get('network', 'ip')
    network_port = config.get('network', 'port')
    network_toggle = config.get('network', 'wifi')
    network_key = config.get('network', 'wifi_key')
    network_ssid = config.get('network', 'wifi_ssid')

    # Pacman
    pacmanconf = config.get('pacman', 'pacmanconf')

    # User
    user = getpass.getuser()

    main()
