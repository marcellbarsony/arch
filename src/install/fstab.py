import logging
import os
import sys
import subprocess


"""
Fstab
https://wiki.archlinux.org/title/Fstab
"""

def mkdir():
    dir = "/mnt/etc"
    try:
        os.mkdir(dir)
    except Exception as err:
        logging.error("%s\n%s", dir, err)
        sys.exit(1)
    else:
        logging.info(dir)

def genfstab():
    """
    Generate fstab file
    https://wiki.archlinux.org/title/Genfstab
    """
    try:
        with open("/mnt/etc/fstab", "a") as fstab:
            subprocess.run(["genfstab", "-U", "/mnt"], stdout=fstab, check=True)
    except subprocess.CalledProcessError as err:
        logging.error("\n%s", err)
        sys.exit(1)
    else:
        logging.info("fstab")
