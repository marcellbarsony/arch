import subprocess
import sys


class Btrfs():

    """Docstring for Btrfs"""

    @staticmethod
    def snapper():
        cmd = 'snapper --no-dbus -c home create-config /home'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] BTRFS Snapper')
        except subprocess.CalledProcessError as err:
            print(f'[-] BTRFS Snapper', err)
            sys.exit(1)
