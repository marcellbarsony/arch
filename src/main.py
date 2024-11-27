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

# Locale {{{
def set_locale():
    locale.locale()
    locale.conf()
    locale.gen()
# }}}

# Hosts {{{
def set_hosts():
    host.hostname(hostname)
    host.hosts(hostname)
# }}}

# Users {{{
def set_users():
    users.root_password(root_pw)
    users.user_add(user)
    users.user_password(user, user_pw)
    users.user_group(user)
# }}}

# Security {{{
def set_security():
    security.sudoers()
    security.login_delay()
# }}}

# Initramfs (mkinitcpio) {{{
def set_initramfs():
    kms = initramfs.kernel_mode_setting()
    initramfs.initramfs(kms)
    initramfs.mkinitcpio()
# }}}

# GRUB {{{
def set_bootloader():
    uuid = grub.get_uuid(device_root)
    grub.setup(uuid)
    grub.install(secureboot, efi_directory)
    # grub.password(grub_password, user)
    grub.mkconfig()
# }}}

# Systemd {{{
def set_systemd():
    systemd.logind()
    dmi_res = dmi.check()
    systemd.services(dmi_res)
    systemd.watchdog()
    systemd.pc_speaker()
# }}}

# DNS (DoH) {{{
def set_dns():
    dns.networkmanager()
    dns.resolvconf()
    dns.doh(nextdns_profile)
# }}}

# Btrfs {{{
def set_btrfs():
    snapper.config_init(btrfs_cfg)
    snapper.config_set(btrfs_cfg)
    snapper.systemd_services()
# }}}

# SSH {{{
def set_ssh():
    ssh.bashrc(user)
# }}}

# Pacman {{{
def set_pacman():
    mirrorlist.backup()
    mirrorlist.update()
    mirrorlist.systemd()
    pacman.config()
# }}}

# X11 {{{
def set_xorg():
    x11.keymaps()
# }}}

# Post script {{{
def arch_post():
    post.clone(user)
    post.chown(user)
# }}}

# Finalize {{{
def set_finalize():
    finalize.change_ownership(user)
    finalize.remove_xdg_dirs(user)
# }}}


if __name__ == "__main__":

    # Initialize Global variables {{{
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

    # Initialize Logging {{{
    logging.basicConfig(
        level = logging.INFO, filename="logs.log", filemode="w",
        format = ":: %(levelname)s :: %(module)s - %(funcName)s: %(lineno)d\n%(message)-1s\n"
    )
    # }}}

    # Run script {{{
    set_locale()
    set_hosts()
    set_users()
    set_security()
    set_initramfs()
    set_bootloader()
    set_systemd()
    set_dns()
    set_btrfs()
    set_ssh()
    set_pacman()
    # set_xorg()
    set_finalize()
    # }}}
