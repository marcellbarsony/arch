import os
import subprocess
import sys


class Efi():

    """Docstring for Efi partition"""

    @staticmethod
    def mkdir(efidir):
        if not os.path.exists(efidir):
            os.makedirs(efidir)
            print(f'[+] EFI: Make directory {efidir}')
        else:
            print(f'[-] EFI: Make directory {efidir}')
            sys.exit(1)

    @staticmethod
    def format(efidevice):
        cmd = f'mkfs.fat -F32 {efidevice}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] EFI: Format {efidevice} to F32')
        except subprocess.CalledProcessError as err:
            print(f'[-] EFI: Format {efidevice} to F32', err)
            sys.exit(1)

    @staticmethod
    def mount(efidir, efidevice):
        cmd = f'mount {efidevice} {efidir}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] EFI: Mount {efidevice} to {efidir}')
        except subprocess.CalledProcessError as err:
            print(f'[-] EFI: Mount {efidevice} to {efidir}', err)
            sys.exit(1)
