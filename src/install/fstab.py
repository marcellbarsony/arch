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
    cmd = ["genfstab", "-U", "/mnt",  ">>", "/mnt/etc/fstab"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)
