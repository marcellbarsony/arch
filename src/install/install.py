import subprocess
import sys
from .initialize import Init


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
    def install():
        pkg_linux = 'linux-hardened linux-hardened-headers linux-firmware'
        pkg_base = 'base base-devel'
        pkg_btrfs = 'btrfs-progs snapper'
        pkg_git = 'git github-cli'
        pkg_grub = 'grub grub-btrfs efibootmgr'
        pkg_network = 'networkmanager ntp'
        pkg_etc = 'neovim openssh python python-pip reflector'
        cmd = f'pacstrap -K /mnt {pkg_linux} {pkg_base} {pkg_git} {pkg_grub} {pkg_network} {pkg_btrfs} {pkg_etc}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print(f'[+] PACSTRAP install')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACSTRAP install', err)
            sys.exit(1)

    @staticmethod
    def installDmi():
        dmi = Init.dmiData()
        cmd = 'pacstrap -K /mnt '
        if dmi == 'virtualbox':
            cmd += 'virtualbox-guest-utils'
        if dmi == 'vmware':
            cmd += 'open-vm-tools'
        else:
            print('[TODO]: PACSTRAP DMI packages')
            # https://wiki.archlinux.org/title/Microcode
            # amd-ucode
            # intel-ucode
            pass
        try:
            subprocess.run(cmd, shell=True, check=True)
            print(f'[+] PACSTRAP: DMI packages <{dmi}>')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACSTRAP: DMI packages <{dmi}>', err)
            sys.exit(1)
        pass
