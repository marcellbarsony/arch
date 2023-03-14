import os
import subprocess
import shutil
import sys


class Pacman():

    """Initialize Arch base installer"""

    @staticmethod
    def config():
        cfg = '/cfg/pacman.conf'
        src = os.path.dirname(__file__) + cfg
        dst = '/etc/pacman.conf'
        try:
            shutil.copy(src, dst)
            print('[+] Pacman config')
        except PermissionError as err:
            print('[-] Pacman config', err)
            sys.exit(1)

    @staticmethod
    def mirrors():
        # TODO: Pacman mirrors
        print('[TODO] Check Pacman mirrors')
        pass

    @staticmethod
    def keyring():
        cmd = 'sudo pacman -Sy --noconfirm archlinux-keyring'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print('[+] Arch keyring update')
        except subprocess.CalledProcessError as err:
            print('[-] Arch keyring update', err)
            sys.exit(1)
