import logging
import subprocess
import sys


"""
Encryption
https://wiki.archlinux.org/title/Dm-crypt/Device_encryption
"""

def modprobe():
    """
    Load kernel modules
    https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Preparation
    """
    cmds = [
        ["modprobe", "dm-crypt"],
        ["modprobe", "dm-mod"]
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.warning("%s\n%s", cmd, err)
            pass
        else:
            logging.info(cmd)

def encrypt(device_root: str, cryptpassword: str):
    """
    Device encryption
    https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Encryption_options
    https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
    """
    cmd = [
        "cryptsetup",
        "--batch-mode", "luksFormat",
        "--cipher", "aes-xts-plain64",
        "--hash", "sha512",
        "--iter-time", "5000",
        "--key-size", "512",
        "--pbkdf", "pbkdf2",
        "--type", "luks2",
        "--use-random",
        device_root
    ]
    try:
        subprocess.run(cmd, check=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def open(device_root: str, cryptpassword: str):
    """
    Unlock & Map LUKS partition
    https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Unlocking/Mapping_LUKS_partitions_with_the_device_mapper
    """
    cmd = [
        "cryptsetup", "open",
        "--type", "luks2",
        device_root, "cryptroot"
    ]
    try:
        subprocess.run(cmd, check=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)
