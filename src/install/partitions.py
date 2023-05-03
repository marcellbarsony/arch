import subprocess
import sys


class Partitions():

    """Docstring for Partitions"""

    def __init__(self, disk: str):
        self.disk = disk

    def efi(self, efisize):
        cmd = f'sgdisk -n 0:0:+{efisize}MiB -t 0:ef00 -c 0:efi {self.disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] PARTITION: Create EFI')
        except subprocess.CalledProcessError as err:
            print('[-] PARTITION: Create EFI', err)
            sys.exit(1)

    def system(self):
        system = 'cryptsystem'
        cmd = f'sgdisk -n 0:0:0 -t 0:8e00 -c 0:{system} {self.disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] PARTITION: Create {system}')
        except subprocess.CalledProcessError as err:
            print(f'[-] PARTITION: Create {system}', err)
            sys.exit(1)
