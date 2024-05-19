#!/usr/bin/env python3


# {{{ Imports
import argparse
import configparser
import getpass
import logging
import os

from src.install import check
from src.install import initialize
from src.install import dmi
from src.install import disk
from src.install import encrypt
from src.install import btrfs
from src.install import efi
from src.install import fstab
from src.install import pacman
from src.install import install
from src.install import chroot
# }}}


# {{{ Check
def run_check():
    check.boot_mode()
    check.network(network_ip, network_port)
# }}}

# {{{ Init
def init():
    initialize.time_zone(zone)
    initialize.loadkeys(keys)
    initialize.keymaps(keymap)
# }}}

# {{{ Filesystem
def file_system():
    device, _, _ = dmi.disk()
    disk.wipe(device)
    disk.create_efi(device, efisize)
    disk.create_system(device)
    disk.partprobe(device)
# }}}

# {{{ Encryption
def encryption():
    _, _, device_root = dmi.disk()
    encrypt.modprobe()
    encrypt.encrypt(device_root, cryptpassword)
    encrypt.open(device_root, cryptpassword)
# }}}

# {{{ BTRFS
def init_btrfs():
    subvolumes = ["home", "var", "snapshots"]
    btrfs.mkfs(rootdir)
    btrfs.mountfs(rootdir)
    btrfs.mksubvols()
    btrfs.unmount()
    btrfs.mount_root(rootdir)
    btrfs.mkdir(subvolumes)
    btrfs.mount_subvolumes(subvolumes, rootdir)
# }}}

# {{{ EFI
def init_efi():
    _, device_efi, _ = dmi.disk()
    efi.mkdir(efidir)
    efi.format(device_efi)
    efi.mount(device_efi, efidir)
# }}}

# {{{ Fstab
def gen_fstab():
    fstab.mkdir()
    fstab.genfstab()
# }}}

# {{{ Pacman
def packages():
    pacman.config()
    pacman.mirrorlist()
    pacman.keyring_init()
# }}}

# {{{ Pacstrap
def pacstrap():
    install.bug()

    pkgs = install.get_pkgs()
    install.install(pkgs)

    pkgs_dmi = install.get_pkgs_dmi(dmi.check())
    install.install(pkgs_dmi)
# }}}

# {{{ Chroot
def arch_chroot():
    cfg_src = f"{current_dir}/config.ini"
    cfg_dst = "/mnt/config.ini"
    scr_src = f"{current_dir}/src/"
    scr_dst = "/mnt/temporary"
    chroot.copy_sources(scr_src, scr_dst, cfg_src, cfg_dst)
    chroot.chroot()
    chroot.clear(scr_dst, cfg_dst)
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
        format=":: %(levelname)s :: %(module)s - %(funcName)s: %(lineno)d\n%(message)-1s\n"
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
    zone = config.get("timezone", "zone")

    user = getpass.getuser()
    current_dir = os.getcwd()
    # }}}

    # {{{ """ Run """
    run_check()
    init()
    file_system()
    encryption()
    init_btrfs()
    init_efi()
    gen_fstab()
    packages()
    pacstrap()
    arch_chroot()
    # }}}
