import os
import subprocess
from .dmi import DMI


class Install():

    """Pacstrap system packages"""

    @staticmethod
    def bug():
        # Pacstrap doesn't work properly until pacman-init.service in the live system is done
        cmd = f'systemctl --no-pager status -n0 pacman-init.service'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] PACSTRAP: pacman-init.service')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACSTRAP: pacman-init.service', err)
            pass

    @staticmethod
    def get_packages():
        packages = ''
        with open('_packages.ini', 'r') as file:
            for line in file:
                if not line.startswith('[') and not line.startswith('#') and line.strip() != '':
                    packages += f'{line.rstrip()} '
        return packages

    @staticmethod
    def get_packages_dmi(packages: str):
        dmi = DMI.check()
        if dmi == 'vbox':
            packages += 'virtualbox-guest-utils'
        if dmi == 'vmware':
            packages += 'open-vm-tools'
        if dmi == 'intel':
            packages += 'intel-ucode xf86-video-intel'
        if dmi == 'AMD':
            packages += 'amd-ucode xf86-video-amdgpu'
        return packages

    @staticmethod
    def install(packages: str):
        os.system('clear')
        cmd = f'pacstrap -K /mnt {packages}'
        try:
            subprocess.run(cmd.rstrip(), shell=True, check=True)
            print(f'[+] PACSTRAP install')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACSTRAP install', err)
