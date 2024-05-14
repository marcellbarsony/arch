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
    cmd = f"systemctl --no-pager status -n0 pacman-init.service"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] PACSTRAP: pacman-init.service")
    except subprocess.CalledProcessError as err:
        print(":: [-] PACSTRAP: pacman-init.service", err)
        logging.error(f"{cmd}\n{err}")
        pass

def get_packages():
    packages = ""
    with open("packages.ini", "r") as file:
        for line in file:
            if not line.startswith("[") and not line.startswith("#") and line.strip() != "":
                packages += f"{line.rstrip()} "
    logging.info(packages)
    return packages

def get_packages_dmi(packages: str, dmi: str):
    if dmi == "vbox":
        packages += "virtualbox-guest-utils"
    if dmi == "vmware":
        packages += "open-vm-tools"
    if dmi == "intel":
        packages += "intel-ucode xf86-video-intel"
    if dmi == "AMD":
        packages += "amd-ucode xf86-video-amdgpu"
    return packages

def install(packages: str):
    os.system("clear")
    cmd = f"pacstrap -K /mnt {packages}"
    try:
        subprocess.run(cmd.rstrip(), shell=True, check=True)
        logging.info(cmd)
        print(":: [+] PACSTRAP install")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] PACSTRAP install", err)
        sys.exit(1)
