import logging
import os
import subprocess
import sys


"""Docstring for Btrfs filesystem"""

def mkfs(rootdir: str):
    cmd = f"mkfs.btrfs --quiet -L System {rootdir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] BTRFS: Make filesystem")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] BTRFS: Make filesystem", err)
        sys.exit(1)

def mountfs(rootdir: str):
    cmd = f"mount {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] BTRFS: Mount cryptroot >> /mnt")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] BTRFS: Mount cryptroot >> /mnt", err)
        sys.exit(1)

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
            logging.info(cmd)
            print(f":: [+] BTRFS: Create subvolume {subvolume}")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(f":: [-] BTRFS: Create subvolume {subvolume}", err)
            sys.exit(1)

def unmount():
    cmd = "umount -R /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] Umount")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] Umount", err)
        sys.exit(1)

def mount_root(rootdir: str):
    cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] BTRFS: Mount @/ >> /mnt")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] BTRFS: Mount @/ >> /mnt", err)
        sys.exit(1)

def mkdir(subvolumes):
    for subvolume in subvolumes:
        path = "/mnt/" + subvolume
        if not os.path.exists(path):
            os.makedirs(path)
            logging.info(path)
            print(f":: [+] BTRFS: mkdir {path}")
        else:
            logging.error(path)
            print(f":: [-] BTRFS: mkdir {path}")
            sys.exit(1)

def mount_subvolumes(subvolumes, rootdir: str):
    for subvolume in subvolumes:
        cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume} {rootdir} /mnt/{subvolume}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print(f":: [+] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(f":: [-] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}", err)
            sys.exit(1)
