import logging
import subprocess
import sys


"""Docstring for Disk"""

def wipe(disk: str):
    cmd_list = [
        f"sgdisk --zap-all --clear {disk}", # GUID table
        f"wipefs -af {disk}", # Filesystem signature
        f"sgdisk -o {disk}" # New GUID table
        ]
    for cmd in cmd_list:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(":: [-] FILESYSTEM: ", err)
            sys.exit(1)
    print(":: [+] FILESYSTEM: Wipe")

def create_efi(device: str, efisize: str):
    cmd = f"sgdisk -n 0:0:+{efisize}MiB -t 0:ef00 -c 0:efi {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] FILESYSTEM: Create EFI")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(":: [-] FILESYSTEM: Create EFI", err)
        sys.exit(1)

def create_system(device: str):
    cmd = f"sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] FILESYSTEM: Create cryptsystem")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(":: [-] FILESYSTEM: Create cryptsystem", err)
        sys.exit(1)

def partprobe(device: str):
    cmd = f"partprobe {device}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] FILESYSTEM: Partprobe")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(":: [-] FILESYSTEM: Partprobe", err)
        sys.exit(1)
