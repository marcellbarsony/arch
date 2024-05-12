import logging
import subprocess
import sys


"""Docstring for Encryption"""

def encrypt(device_root: str, cryptpassword: str):

    """
    Device encryption
    https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
    """

    cmd = f"cryptsetup \
    --batch-mode luksFormat \
    --cipher aes-xts-plain64 \
    --hash sha512 \
    --iter-time 5000 \
    --key-size 512 \
    --pbkdf pbkdf2 \
    --type luks2 \
    --use-random \
    {device_root}"
    try:
        subprocess.run(cmd, shell=True, check=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f":: [+] CRYPTSETUP: {device_root}")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(f":: [-] CRYPTSETUP: {device_root}", err)
        sys.exit(1)

def open(device_root: str, cryptpassword: str):
    cmd = f"cryptsetup open --type luks2 {device_root} cryptroot"
    try:
        subprocess.run(cmd, shell=True, check=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f":: [+] CRYPTSETUP: Open {device_root}")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(f":: [-] CRYPTSETUP: Open {device_root}", err)
        sys.exit(1)
