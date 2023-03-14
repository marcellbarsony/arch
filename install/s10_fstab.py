import os
import sys
import subprocess


class Fstab():

    """Docstring for Fstab"""

    @staticmethod
    def mkdir():
        dir = '/mnt/etc'
        try:
            os.mkdir(dir)
            print(f'[+] FSTAB: Create directory')
        except Exception as err:
            print(f'[+] FSTAB: Create directory', err)
            sys.exit(1)

    @staticmethod
    def genfstab():
        cmd = 'genfstab -U /mnt >> /mnt/etc/fstab'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print('[+] FSTAB: Genfstab')
        except subprocess.CalledProcessError as err:
            print('[-] FSTAB: Genfstab', err)
            sys.exit(1)
