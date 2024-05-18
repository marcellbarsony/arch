import logging
import os
import subprocess
import sys


"""Docstring for Btrfs filesystem"""

def mkfs(rootdir: str):
    cmd = f"mkfs.btrfs --quiet -L System {rootdir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def mountfs(rootdir: str):
    cmd = f"mount {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS :: ", err)
        logging.error(f"{cmd}\n{err}")
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
            print(":: [+] BTRFS :: ", cmd)
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(":: [-] BTRFS :: ", err)
            logging.error(f"{cmd}\n{err}")
            sys.exit(1)

def unmount():
    cmd = "umount -R /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def mount_root(rootdir: str):
    cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ {rootdir} /mnt"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS :: Mount @/ >> /mnt")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS :: Mount @/ >> /mnt :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def mkdir(subvolumes):
    for subvolume in subvolumes:
        path = "/mnt/" + subvolume
        if not os.path.exists(path):
            os.makedirs(path)
            print(":: [+] BTRFS :: mkdir :: ", path)
            logging.info(path)
        else:
            print(":: [-] BTRFS :: mkdir :: ", path)
            logging.error(path)
            sys.exit(1)

def mount_subvolumes(subvolumes, rootdir: str):
    for subvolume in subvolumes:
        cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume} {rootdir} /mnt/{subvolume}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f":: [+] BTRFS :: Mount @{subvolume} >> /mnt/{subvolume}")
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(f":: [-] BTRFS :: Mount @{subvolume} >> /mnt/{subvolume} :: ", err)
            logging.error(f"{cmd}\n{err}")
            sys.exit(1)
