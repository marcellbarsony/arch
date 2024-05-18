import logging
import os
import sys
import subprocess


"""
Docstring for Fstab
https://wiki.archlinux.org/title/Fstab
"""

def mkdir():
    dir = "/mnt/etc"
    try:
        os.mkdir(dir)
        print(":: [+] FSTAB :: Mkdir :: ", dir)
        logging.info(dir)
    except Exception as err:
        print(":: [-] FSTAB :: Mkdir :: ", err)
        logging.error(f"{dir}\n{err}")
        sys.exit(1)

def genfstab():
    cmd = "genfstab -U /mnt >> /mnt/etc/fstab"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] FSTAB :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] FSTAB :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
