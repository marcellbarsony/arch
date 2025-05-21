#!/usr/bin/env python3


# Imports {{{
import configparser
import logging
import sys
import threading

from chroot import snapper
from chroot import dmi
from chroot import dns
from chroot import finalize
from chroot import grub
from chroot import host
from chroot import initramfs
from chroot import locale
from chroot import mirrorlist
from chroot import pacman
from chroot import ssh
from chroot import security
from chroot import systemd
from chroot import users
from chroot import x11
# }}}


if __name__ == "__main__":

    # Logging {{{
    logging.basicConfig(
        level = logging.INFO,
        filename = "logs.log",
        filemode = "w",
        format = ":: %(levelname)s :: %(module)s :: %(funcName)s :: %(lineno)d\n%(message)-1s"
    )

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(logging.Formatter(
        ":: %(levelname)s :: %(module)s :: %(funcName)s :: %(message)-1s"
    ))

    logging.getLogger().addHandler(console_handler)
    # }}}

    # Global variables {{{
    config = configparser.ConfigParser()
    config.read("/config.ini")

    btrfs_cfg       = config.get("btrfs", "btrfs_cfg")
    efi_directory   = config.get("grub", "efi_directory")
    grub_password   = config.get("auth", "grub")
    hostname        = config.get("network", "hostname")
    keys            = config.get("keyset", "keys")
    nextdns_profile = config.get("nextdns", "profile")
    root_pw         = config.get("auth", "root_pw")
    secureboot      = config.get("grub", "secureboot")
    user            = config.get("auth", "user")
    user_pw         = config.get("auth", "user_pw")

    # DMI table decoder
    device, device_efi, device_root = dmi.disk()
    # }}}

    # Pacman {{{
    mirrorlist.systemd()
    mirrorlist.backup()
    mirrorlist_thread = threading.Thread(target=mirrorlist.update)
    mirrorlist_thread.start()

    pacman.config()
    # }}}

    # Locale {{{
    locale.locale()
    locale.conf()
    locale.gen()
    # }}}

    # Hosts {{{
    host.hostname(hostname)
    host.hosts(hostname)
    # }}}

    # Users {{{
    users.root_password(root_pw)
    users.user_add(user)
    users.user_password(user, user_pw)
    users.user_group_create()
    users.user_group_add(user)
    # }}}

    # Security {{{
    security.sudoers()
    security.login_delay()
    # }}}

    # Initramfs (mkinitcpio) {{{
    kms = initramfs.kernel_mode_setting()
    initramfs.initramfs(kms)
    initramfs.mkinitcpio()
    # }}}

    # GRUB {{{
    uuid = grub.get_uuid(device_root)
    grub.config(uuid)
    grub.install(secureboot, efi_directory)
    # grub.password(grub_password, user)
    grub.mkconfig()
    # }}}

    # Systemd {{{
    systemd.logind()
    systemd.watchdog()
    systemd.pc_speaker()
    systemd.services()
    if dmi.check() == "vbox":
        systemd.services_dmi()
    # }}}

    # DNS (DoH) {{{
    dns.networkmanager()
    dns.resolvconf()
    dns.doh(nextdns_profile)
    # }}}

    # Btrfs {{{
    snapper.config_init(btrfs_cfg)
    snapper.config_set(btrfs_cfg)
    # }}}

    # SSH {{{
    ssh.bashrc(user)
    # }}}

    # X11 {{{
    x11.keymaps()
    # }}}

    # Finalize {{{
    mirrorlist_thread.join()

    finalize.change_ownership(user)
    finalize.remove_xdg_dirs(user)
    # }}}
