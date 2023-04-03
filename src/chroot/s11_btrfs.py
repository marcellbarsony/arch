import subprocess
import sys


class Btrfs():

    """Docstring for Btrfs"""



class Snapper():

    """Docstring for Snapper"""

    @staticmethod
    def config():
        # cmd = 'snapper -c config create-config /path/to/subvolume'
        cmd = 'snapper --no-dbus -c home create-config /home'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] BTRFS Snapper')
        except subprocess.CalledProcessError as err:
            print(f'[-] BTRFS Snapper', err)
            sys.exit(1)