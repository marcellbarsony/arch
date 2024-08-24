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
    cmd = "systemctl --no-pager status -n0 pacman-init.service"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.warn(f"{cmd}\n{err}")
        print(":: [W] PACSTRAP :: pacman-init.service :: ", err)
        pass
    else:
        logging.info(cmd)
        print(":: [+] PACSTRAP :: pacman-init.service")

def get_pkgs():
    packages = ""
    with open("packages.ini", "r") as file:
        for line in file:
            if not line.startswith("[") and not line.startswith("#") and line.strip() != "":
                packages += f"{line.rstrip()} "
    logging.info(packages)
    return packages

def get_pkgs_dmi(dmi: str):
    packages = ""
    if dmi == "vbox":
        packages = "virtualbox-guest-utils"
    if dmi == "vmware":
        packages = "open-vm-tools"
    if dmi == "intel":
        packages = "intel-ucode xf86-video-intel"
    if dmi == "AMD":
        packages = "amd-ucode xf86-video-amdgpu"
    logging.info(packages)
    return packages

def install(packages: str):
    os.system("clear")
    cmd = f"pacstrap -K /mnt {packages}"
    try:
        subprocess.run(cmd.rstrip(), shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] PACSTRAP :: Install :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] PACSTRAP :: Install")
