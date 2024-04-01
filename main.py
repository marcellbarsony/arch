#!/usr/bin/env python3
"""
Author  : Marcell Barsony
Date    : 2023 January
Desc    : Arch Linux base installer
"""


# {{{ Imports
import argparse
import configparser
import getpass
import logging
import os

from src.install import Btrfs
from src.install import check
from src.install import Chroot
from src.install import CryptSetup
from src.install import Disk
from src.install import Efi
from src.install import fstab
from src.install import initialize
from src.install import Install
from src.install import pacman
# }}}


# {{{ Check
def run_check():
    check.boot_mode()
    check.network(network_ip, network_port)
# }}}

# {{{ Init
def init():
    initialize.time_zone()
    initialize.loadkeys(keys)
    initialize.keymaps(keymap)
# }}}

# {{{ Filesystem
def file_system():
    d = Disk()
    d.wipe()
    d.create_efi(efisize)
    d.create_system()
    d.partprobe()
# }}}

# {{{ Encryption
def encryption():
    c = CryptSetup(cryptpassword)
    c.encrypt()
    c.open()
# }}}

# {{{ BTRFS
def btrfs():
    b = Btrfs(rootdir)
    b.mkfs()
    b.mountfs()
    b.mksubvols()
    b.unmount()
    b.mount_root()
    b.mkdir()
    b.mount_subvolumes()
# }}}

# {{{ EFI
def efi():
    e = Efi(efidir)
    e.mkdir()
    e.format()
    e.mount()
# }}}

# {{{ Fstab
def gen_fstab():
    fstab.mkdir()
    fstab.genfstab()
# }}}

# {{{ Pacman
def set_pacman():
    pacman.config()
    pacman.mirrorlist()
    pacman.keyring_init()
# }}}

# {{{ Pacstrap
def pacstrap():
    p = Install()
    p.bug()
    pkgs = p.get_packages()
    pkgs = p.get_packages_dmi(pkgs)
    p.install(pkgs)
# }}}

# {{{ Chroot
def arch_chroot():
    c = Chroot(current_dir)
    c.copy_sources()
    c.chroot()
    c.clear()
# }}}


if __name__ == "__main__":

    # {{{ """ Initialize Argparse """
    parser = argparse.ArgumentParser(
        prog="python3 setup.py",
        description="Arch base system",
        epilog="TODO"
        )
    args = parser.parse_args()
    # }}}

    # {{{ """ Initialize Logging """
    logging.basicConfig(
        level=logging.INFO, filename="logs.log", filemode="w",
        format="%(levelname)-7s :: %(module)s - %(funcName)s - %(lineno)d :: %(message)s"
    )
    # }}}

    # {{{ """ Initialize Global variables """
    config = configparser.ConfigParser()
    config.read("config.ini")

    efisize = config.get("disk", "efisize")
    cryptpassword = config.get("auth", "crypt")
    rootdir = config.get("disk", "rootdir")
    efidir = config.get("disk", "efidir")
    font = config.get("keyset", "font")
    keys = config.get("keyset", "keys")
    keymap = config.get("keyset", "keymap")
    network_ip = config.get("network", "ip")
    network_port = config.get("network", "port")

    user = getpass.getuser()
    current_dir = os.getcwd()
    # }}}

    # {{{ """ Run """
    run_check()
    init()
    file_system()
    encryption()
    btrfs()
    efi()
    gen_fstab()
    set_pacman()
    pacstrap()
    arch_chroot()
    # }}}
