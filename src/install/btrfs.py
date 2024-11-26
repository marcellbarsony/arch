import logging
import os
import subprocess
import sys


"""Docstring for Btrfs file system"""

def mkfs(rootdir: str):
    cmd = f"mkfs.btrfs --quiet -L System {rootdir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: BTRFS ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: BTRFS ::", cmd)

def mountfs(rootdir: str):
    cmd = f"mount {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: BTRFS ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: BTRFS ::", cmd)

def mksubvols():
    subvolumes = [
        "/mnt/@",
        "/mnt/@home",
        "/mnt/@var",
        "/mnt/@snapshots"
    ]
    for subvolume in subvolumes:
        cmd = f"btrfs subvolume create {subvolume}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] :: BTRFS ::", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(":: [+] :: BTRFS ::", cmd)

def unmount():
    cmd = "umount -R /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: BTRFS ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: BTRFS ::", cmd)

def mount_root(rootdir: str):
    cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: BTRFS :: Mount @/ >> /mnt ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: BTRFS :: Mount @/ >> /mn")

def mkdir(subvolumes: list):
    for subvolume in subvolumes:
        path = "/mnt/" + subvolume
        if os.path.exists(path):
            logging.error(path)
            print(":: [-] :: BTRFS :: mkdir ::", path)
            sys.exit(1)
        else:
            os.makedirs(path)
            logging.info(path)
            print(":: [+] :: BTRFS :: mkdir ::", path)

def mount_subvolumes(subvolumes: list, rootdir: str):
    for subvolume in subvolumes:
        cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume} {rootdir} /mnt/{subvolume}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(f":: [-] :: BTRFS :: Mount @{subvolume} >> /mnt/{subvolume} ::", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(f":: [+] :: BTRFS :: Mount @{subvolume} >> /mnt/{subvolume}")
