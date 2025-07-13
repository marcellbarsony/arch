import logging
import os
import subprocess
import sys

"""Pacstrap system packages"""

def bug():
    """
    Fixing Pacstrap error: Keyring is not writable
    Pacstrap doesn't work properly until pacman-init.service in the live system is done
    https://bbs.archlinux.org/viewtopic.php?pid=2081392#p2081392
    """
    cmd = [
        "systemctl",
        "--no-pager",  # Prevent output from being piped
        "status",  # Status of systemd unit
        "-n0",  # 0 journal lines
        "pacman-init.service",
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.warning("%s\n%s", cmd, err)
        return
    else:
        logging.info(cmd)

def get_pkgs(extra: str):
    packages = ""
    with open("packages.ini", "r") as file:
        for line in file:
            if not line.startswith("[") and not line.startswith(";") and line.strip() != "":
                packages += f"{line.rstrip()} "

    if extra == "True":
        with open("packages-extra.ini", "r") as file:
            for line in file:
                if not line.startswith("[") and not line.startswith(";") and line.strip() != "":
                    packages += f"{line.rstrip()} "

    return packages

def get_pkgs_dmi(dmidecode: str) -> str:
    match dmidecode.lower():
        case "vbox":
            return "virtualbox-guest-utils"
        case "vmware":
            return "open-vm-tools"
        case "intel":
            return "intel-ucode xf86-video-intel"
        case "amd":
            return "amd-ucode xf86-video-amdgpu"
        case _:
            return ""

def install(packages: str):
    os.system("clear")
    cmd = ["pacstrap", "-K", "/mnt"] + packages.split()
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)
