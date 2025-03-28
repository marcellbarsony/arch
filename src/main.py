#!/usr/bin/env python3


# Imports {{{
import configparser
import logging

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
from chroot import post
from chroot import ssh
from chroot import security
from chroot import systemd
from chroot import users
from chroot import x11
# }}}


if __name__ == "__main__":

    # Logging {{{
    logging.basicConfig(
        level = logging.INFO, filename = "logs.log", filemode = "w",
        format = ":: %(levelname)s :: %(module)s - %(funcName)s: %(lineno)d\n%(message)-1s\n"
    )
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

    # Run {{{
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
    users.user_group(user)
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
    grub.setup(uuid)
    grub.install(secureboot, efi_directory)
    # grub.password(grub_password, user)
    grub.mkconfig()
    # }}}

    # Systemd {{{
    systemd.logind()
    dmi_res = dmi.check()
    systemd.services(dmi_res)
    systemd.watchdog()
    systemd.pc_speaker()
    # }}}

    # DNS (DoH) {{{
    dns.networkmanager()
    dns.resolvconf()
    dns.doh(nextdns_profile)
    # }}}

    # Btrfs {{{
    snapper.config_init(btrfs_cfg)
    snapper.config_set(btrfs_cfg)
    snapper.systemd_services()
    # }}}

    # SSH {{{
    ssh.bashrc(user)
    # }}}

    # Pacman {{{
    mirrorlist.backup()
    mirrorlist.update()
    mirrorlist.systemd()
    pacman.config()
    # }}}

    # X11 {{{
    x11.keymaps()
    # }}}

    # Post script {{{
    post.clone(user)
    post.chown(user)
    # }}}

    # Finalize {{{
    finalize.change_ownership(user)
    finalize.remove_xdg_dirs(user)
    # }}}
    # }}}
