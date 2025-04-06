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
    except Exception as err:
        logging.error(f"{dir}\n{err}")
        print(":: [-] :: FSTAB :: Mkdir ::", err)
        sys.exit(1)
    else:
        logging.info(dir)
        print(":: [+] :: FSTAB :: Mkdir ::", dir)

def genfstab():
    """
    Generate fstab file
    https://wiki.archlinux.org/title/Genfstab
    """
    cmd = "genfstab -U /mnt >> /mnt/etc/fstab"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FSTAB ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FSTAB ::", cmd)
