import logging
import os
import subprocess
import sys


"""Docstring for EFI partition"""

def mkdir(efidir: str):
    if not os.path.exists(efidir):
        os.makedirs(efidir)
        print(":: [+] EFI :: Mkdir :: ", efidir)
        logging.info(efidir)
    else:
        print(":: [-] EFI :: Mkdir :: ", efidir)
        logging.error(efidir)
        sys.exit(1)

def format(device_efi: str):
    cmd = f"mkfs.fat -F32 {device_efi}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] EFI :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(f":: [-] EFI :: {cmd} :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def mount(device_efi: str, efidir: str):
    cmd = f"mount {device_efi} {efidir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(f":: [+] EFI :: Mount {device_efi} >> {efidir}")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(f":: [-] EFI :: Mount {device_efi} >> {efidir} ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
