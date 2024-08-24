import logging
import os
import subprocess
import sys


"""Docstring for EFI partition"""

def mkdir(efidir: str):
    if not os.path.exists(efidir):
        os.makedirs(efidir)
        logging.info(efidir)
        print(":: [+] EFI :: Mkdir :: ", efidir)
    else:
        logging.error(efidir)
        print(":: [-] EFI :: Mkdir :: ", efidir)
        sys.exit(1)

def format(device_efi: str):
    cmd = f"mkfs.fat -F32 {device_efi}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(f":: [-] EFI :: {cmd} :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] EFI :: ", cmd)

def mount(device_efi: str, efidir: str):
    cmd = f"mount {device_efi} {efidir}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(f":: [-] EFI :: Mount {device_efi} >> {efidir} :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(f":: [+] EFI :: Mount {device_efi} >> {efidir}")
