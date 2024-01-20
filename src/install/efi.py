import logging
import os
import subprocess
import sys
from .dmi import DMI


class Efi():

    """Docstring for EFI partition"""

    def __init__(self, efidir: str):
        dmi = DMI()
        _, device_efi, _ = dmi.disk()
        self.device_efi = device_efi
        self.efidir = efidir

    def mkdir(self):
        if not os.path.exists(self.efidir):
            os.makedirs(self.efidir)
            logging.info(self.efidir)
            print(f"[+] EFI: Make directory {self.efidir}")
        else:
            print(f"[-] EFI: Make directory {self.efidir}")
            logging.error(self.efidir)
            sys.exit(1)

    def format(self):
        cmd = f"mkfs.fat -F32 {self.device_efi}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print(f"[+] EFI: Format {self.device_efi} to F32")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(f"[-] EFI: Format {self.device_efi} to F32", err)
            sys.exit(1)

    def mount(self):
        cmd = f"mount {self.device_efi} {self.efidir}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print(f"[+] EFI: Mount {self.device_efi} to {self.efidir}")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(f"[-] EFI: Mount {self.device_efi} to {self.efidir}", err)
            sys.exit(1)
