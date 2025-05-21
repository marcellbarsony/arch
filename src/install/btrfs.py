import logging
import os
import subprocess
import sys


"""
Btrfs file system
https://wiki.archlinux.org/title/Btrfs
"""

def mkfs(rootdir: str):
    """
    Create BTRFS file system
    https://wiki.archlinux.org/title/Btrfs#File_system_creation
    """
    cmd = [
        "mkfs.btrfs",
        "--quiet",
        "-L", "System",
        rootdir
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def mountfs(rootdir: str):
    """
    Mount file system
    https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems
    """
    cmd = ["mount", rootdir, "/mnt"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def mksubvols():
    """
    Create subvolumes
    https://wiki.archlinux.org/title/Btrfs#Creating_a_subvolume
    """
    subvolumes = [
        "/mnt/@",
        "/mnt/@home",
        "/mnt/@var",
        "/mnt/@snapshots"
    ]
    for subvolume in subvolumes:
        cmd = ["btrfs",  "subvolume",  "create", subvolume]
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error("%s\n%s", cmd, err)
            sys.exit(1)
        else:
            logging.info(cmd)

def unmount():
    cmd = ["umount", "-R", "/mnt"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def mount_root(rootdir: str):
    cmd = [
        "mount",
        "-o", "noatime,compress=zstd,space_cache=v2,discard=async,subvol=@",
        rootdir,
        "/mnt"
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def mkdir(subvolumes: list):
    for subvolume in subvolumes:
        path = "/mnt/" + subvolume
        if os.path.exists(path):
            logging.error(path)
            sys.exit(1)
        else:
            os.makedirs(path)
            logging.info(path)

def mount_subvolumes(subvolumes: list, rootdir: str):
    """
    Mounting subvolumes
    https://wiki.archlinux.org/title/Btrfs#Mounting_subvolumes
    """
    for subvolume in subvolumes:
        cmd = [
            "mount",
            "-o", f"noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume}",
            rootdir,
            f"/mnt/{subvolume}"
        ]
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error("%s\n%s", cmd, err)
            sys.exit(1)
        else:
            logging.info(cmd)
