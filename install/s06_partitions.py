import subprocess
import sys


class Partitions():

    """Docstring for Partitions"""

    @staticmethod
    def create_efi(disk, efisize):
        cmd = f'sgdisk -n 0:0:+{efisize}MiB -t 0:ef00 -c 0:efi {disk}'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print('[+] PARTITION: Create EFI')
        except subprocess.CalledProcessError as err:
            print('[-] PARTITION: Create EFI', err)
            sys.exit(1)

    @staticmethod
    def create_system(disk):
        system = 'cryptsystem'
        cmd = f'sgdisk -n 0:0:0 -t 0:8e00 -c 0:{system} {disk}'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] PARTITION: Create {system}')
        except subprocess.CalledProcessError as err:
            print(f'[-] PARTITION: Create {system}', err)
            sys.exit(1)
