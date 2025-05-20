import logging
import subprocess
import sys


"""Docstring for Disk"""

def wipe(disk: str):
    """
    Wipe GPT header data
    https://man.archlinux.org/man/sgdisk.8.en
    https://man.archlinux.org/man/wipefs.8.en
    """
    cmds = [
        ["sgdisk", "--zap-all", disk], # Wipe GPT and MBR data (GUID table)
        ["wipefs", "-af", disk],       # Wipe filesystem signatures
        ["sgdisk", "--clear", disk]    # Clear GPT partition table (GUID table)
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] :: FILESYSTEM :: Wipe ::", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(":: [+] :: FILESYSTEM :: Wipe ::", cmd)

def create_efi(device: str, efisize: str):
    """
    Create new EFI GPT partition
    https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
    """
    cmd = [
        "sgdisk",
        "-n", f"0:0:+{efisize}MiB", # New partition
        "-t", "0:ef00", # Type
        "-c", "0:efi", # Name
        device
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Create EFI ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Create EFI")

def create_system(device: str):
    """
    Create new LVM partition
    https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
    """
    cmd = [
        "sgdisk",
        "-n", "0:0:0", # New partition
        "-t", "0:8e00", # Type
        "-c", "0:cryptsystem", # Name
        device
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Create cryptsystem ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Create cryptsystem")

def partprobe(device: str):
    """
    Inform the OS of partition table changes
    https://man.archlinux.org/man/partprobe.8.en
    """
    cmd = ["partprobe", device]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: FILESYSTEM :: Partprobe ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: FILESYSTEM :: Partprobe")
