#!/usr/bin/env python3
"""
Author  : Marcell Barsony <marcellbarsony@protonmail.com>
Date    : March 2023
"""


# {{{ Imports
import configparser
import logging

from chroot import snapper
from chroot import dns
from chroot import dmi
from chroot import finalize
from chroot import grub
from chroot import host
from chroot import initramfs
from chroot import keymaps
from chroot import locale
from chroot import mirrorlist
from chroot import pacman
from chroot import ssh
from chroot import security
from chroot import systemd
from chroot import users
# }}}

# {{{ Locale
def set_locale():
    locale.locale()
    locale.conf()
    locale.gen()
# }}}

# {{{ Network
def set_hosts():
    host.hostname(hostname)
    host.hosts(hostname)

def set_dns():
    dns.networkmanager()
    dns.resolvconf()
# }}}

# {{{ Users
def set_users():
    users.root_password(root_pw)

    users.user_add(user)
    users.user_password(user, user_pw)
    users.user_group(user)
# }}}

# {{{ Security
def set_security():
    security.sudoers()
    security.login_delay(logindelay)
    security.automatic_logout()
# }}}

# {{{ Initramfs (mkinitcpio)
def set_initramfs():
    initramfs.mkinitcpio()
    initramfs.initramfs()
# }}}

# {{{ GRUB
def set_bootloader():
    grub.setup()
    grub.install(secureboot, efi_directory)
    grub.password(grub_password, user)
    grub.mkconfig()
# }}}

# {{{ Systemd
def set_systemd():
    systemd.logind()
    dmi_res = dmi.check()
    systemd.services(dmi_res)
    systemd.watchdog()
    systemd.pc_speaker()
# }}}

# {{{ Btrfs
def set_btrfs():
    snapper.config_init()
    snapper.config_set()
    snapper.systemd_services()
# }}}

# {{{ SSH
def set_ssh():
    ssh.bashrc(user)
# }}}

# {{{ Pacman
def set_pacman():
    mirrorlist.backup()
    mirrorlist.update()
    pacman.config()
# }}}

# {{{ X11: Keymaps
def x11_keys():
    keymaps.x11_keymaps()
# }}}


# {{{ Finalize
def set_finalize():
    finalize.change_ownership(user)
    finalize.remove_xdg_dirs(user)
# }}}

if __name__ == "__main__":

    # {{{ """ Initialize Global variables """
    config = configparser.ConfigParser()
    config.read("/config.ini") # TODO: check dir location

    efi_directory = config.get("grub", "efi_directory")
    grub_password = config.get("auth", "grub")
    hostname = config.get("network", "hostname")
    keys = config.get("keyset", "keys")
    logindelay = config.get("security", "logindelay")
    root_pw = config.get("auth", "root_pw")
    secureboot = config.get("grub", "secureboot")
    user = config.get("auth", "user")
    user_pw = config.get("auth", "user_pw")
    # }}}

    # {{{ """ Initialize logging """
    logging.basicConfig(
        level=logging.INFO, filename="logs.log", filemode="w",
        format="%(levelname)-7s :: %(module)s - %(funcName)s - %(lineno)d :: %(message)s"
    )
    # }}}

    # {{{ """ Run script """
    set_locale()
    set_hosts()
    set_users()
    set_security()
    set_initramfs()
    set_bootloader()
    set_systemd()
    set_btrfs()
    set_ssh()
    set_pacman()
    x11_keys()
    set_finalize()
    # }}}
