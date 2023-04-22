import os
import subprocess
import sys


class Efi():

    """Docstring for Efi partition"""

    def __init__(self, efidir: str, efidevice: str):
        self.efidir = efidir
        self.efidevice = efidevice

    def mkdir(self):
        if not os.path.exists(self.efidir):
            os.makedirs(self.efidir)
            print(f'[+] EFI: Make directory {self.efidir}')
        else:
            print(f'[-] EFI: Make directory {self.efidir}')
            sys.exit(1)

    def format(self):
        cmd = f'mkfs.fat -F32 {self.efidevice}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] EFI: Format {self.efidevice} to F32')
        except subprocess.CalledProcessError as err:
            print(f'[-] EFI: Format {self.efidevice} to F32', err)
            sys.exit(1)

    def mount(self):
        cmd = f'mount {self.efidevice} {self.efidir}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] EFI: Mount {self.efidevice} to {self.efidir}')
        except subprocess.CalledProcessError as err:
            print(f'[-] EFI: Mount {self.efidevice} to {self.efidir}', err)
            sys.exit(1)
