#!/usr/bin/env python3


# Imports {{{
import argparse
import configparser
import getpass
import logging
import os

from src.install import check
from src.install import init
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


if __name__ == "__main__":

    # Argparse {{{
    parser = argparse.ArgumentParser(
        prog = "python3 setup.py",
        description = "Arch base system",
        epilog = "Arch base system setup script"
    )
    args = parser.parse_args()
    # }}}

    # Logging {{{
    logging.basicConfig(
        level = logging.INFO, filename="logs.log", filemode="w",
        format = ":: %(levelname)s :: %(module)s - %(funcName)s: %(lineno)d\n%(message)-1s\n"
    )
    # }}}

    # Global variables {{{
    user = getpass.getuser()
    cwd = os.getcwd()

    # DMI table decoder
    device, device_efi, device_root = dmi.disk()
    dmidecode = dmi.check()
    # }}}

    # Config {{{
    config = configparser.ConfigParser()
    config.read("config.ini")

    # Auth {{{
    cryptpassword = config.get("auth", "crypt")
    # }}}

    # Btrfs {{{
    subvolumes    = config.get("btrfs", "subvolumes").split(", ")
    # }}}

    # Disk {{{
    efisize       = config.get("disk", "efisize")
    rootdir       = config.get("disk", "rootdir")
    efidir        = config.get("disk", "efidir")
    # }}}

    # Keyset {{{
    font          = config.get("keyset", "font")
    keys          = config.get("keyset", "keys")
    keymap        = config.get("keyset", "keymap")
    # }}}

    # Network {{{
    network_ip    = config.get("network", "ip")
    network_port  = config.get("network", "port")
    network_host  = config.get("network", "hostname")
    # }}}

    # Timezone {{{
    timezone      = config.get("timezone", "zone")
    # }}}

    for section in config.sections():
        for key, value in config.items(section):
            if not key.strip():
                print(":: [-] :: ConfigParser :: Empty key")
                raise ValueError(f"Empty key found :: [{section}]")
            if not value.strip():
                print(":: [-] :: ConfigParser :: Empty value")
                raise ValueError(f"Empty value '{key}' in section [{section}]")
    # }}}

    # Run {{{
    # Check {{{
    check.boot_mode()
    check.network(network_ip, network_port)
    # }}}

    # Init {{{
    init.time_zone(timezone)
    init.loadkeys(keys)
    init.keymaps(keymap)
    # }}}

    # File system {{{
    disk.wipe(device)
    disk.create_efi(device, efisize)
    disk.create_system(device)
    disk.partprobe(device)
    # }}}

    # Encryption {{{
    encrypt.modprobe()
    encrypt.encrypt(device_root, cryptpassword)
    encrypt.open(device_root, cryptpassword)
    # }}}

    # BTRFS {{{
    btrfs.mkfs(rootdir)
    btrfs.mountfs(rootdir)
    btrfs.mksubvols()
    btrfs.unmount()
    btrfs.mount_root(rootdir)
    btrfs.mkdir(subvolumes)
    btrfs.mount_subvolumes(subvolumes, rootdir)
    # }}}

    # EFI {{{
    efi.mkdir(efidir)
    efi.format(device_efi)
    efi.mount(device_efi, efidir)
    # }}}

    # Fstab {{{
    fstab.mkdir()
    fstab.genfstab()
    # }}}

    # Pacman {{{
    pacman.config()
    pacman.mirrorlist()
    pacman.keyring_init()
    # }}}

    # Pacstrap {{{
    install.bug()
    pkgs = install.get_pkgs()
    install.install(pkgs)
    pkgs_dmi = install.get_pkgs_dmi(dmidecode)
    install.install(pkgs_dmi)
    # }}}

    # Chroot {{{
    cfg_src = f"{cwd}/config.ini"
    cfg_dst = "/mnt/config.ini"
    scr_src = f"{cwd}/src/"
    scr_dst = "/mnt/temporary"
    chroot.copy(scr_src, scr_dst, cfg_src, cfg_dst)
    chroot.chroot()
    chroot.clear(scr_dst, cfg_dst)
    # }}}
    # }}}
