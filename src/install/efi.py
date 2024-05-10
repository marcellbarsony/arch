import logging
import os
import subprocess
import sys


"""Docstring for EFI partition"""

def mkdir(efidir: str):
    if not os.path.exists(efidir):
        os.makedirs(efidir)
        logging.info(efidir)
        print(f"[+] EFI: Make directory {efidir}")
    else:
        print(f"[-] EFI: Make directory {efidir}")
        logging.error(efidir)
        sys.exit(1)

def format(device_efi: str):
    cmd = f"mkfs.fat -F32 {device_efi}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f"[+] EFI: Format {device_efi} to F32")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(f"[-] EFI: Format {device_efi} to F32", err)
        sys.exit(1)

def mount(device_efi: str, efidir: str):
    cmd = f"mount {device_efi} {efidir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f"[+] EFI: Mount {device_efi} to {efidir}")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(f"[-] EFI: Mount {device_efi} to {efidir}", err)
        sys.exit(1)
