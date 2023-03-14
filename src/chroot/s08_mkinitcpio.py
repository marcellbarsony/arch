import subprocess
import sys


class Mkinitcpio():

    @staticmethod
    def mkinitcpio():
        cmd = 'mkinitcpio -p linux-hardened'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] Mkinitcpio: linux-hardened')
        except subprocess.CalledProcessError as err:
            print(f'[-] Mkinitcpio: linux-hardened', err)
            sys.exit(1)
