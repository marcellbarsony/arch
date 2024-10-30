import logging
import subprocess
import sys


"""Docstring for Disk"""

def wipe(disk: str):
    cmds = [
        f"sgdisk --zap-all --clear {disk}", # GUID table
        f"wipefs -af {disk}", # Filesystem signature
        f"sgdisk -o {disk}" # New GUID table
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] :: FILESYSTEM :: Wipe ::", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(":: [+] :: FILESYSTEM :: Wipe ::", cmd)

def create_efi(device: str, efisize: str):
    cmd = f"sgdisk -n 0:0:+{efisize}MiB -t 0:ef00 -c 0:efi {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Create EFI ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Create EFI")

def create_system(device: str):
    cmd = f"sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Create cryptsystem ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Create cryptsystem")

def partprobe(device: str):
    cmd = f"partprobe {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Partprobe ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Partprobe")
