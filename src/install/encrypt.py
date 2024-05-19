import logging
import subprocess
import sys


"""Docstring for Encryption"""


def modprobe():
    cmds = [
        "modprobe dm-cpryt"
        "modprobe dm-mod"
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(":: [+] CRYPTSETUP :: ", cmd)
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(":: [-] CRYPTSETUP :: ", err)
            logging.error(f"{cmd}\n{err}")
            pass

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
        print(":: [+] CRYPTSETUP :: Encrypt :: ", device_root)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] CRYPTSETUP :: Encrypt :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def open(device_root: str, cryptpassword: str):
    cmd = f"cryptsetup open --type luks2 {device_root} cryptroot"
    try:
        subprocess.run(cmd, shell=True, check=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
        print(":: [+] CRYPTSETUP :: Open :: ", device_root)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] CRYPTSETUP :: Open :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
