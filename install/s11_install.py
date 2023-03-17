import shutil
import subprocess
import sys


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
            sys.exit(1)

        # while True:
        #     cmd = 'systemctl show pacman-init.service | grep SubState=exited'
        #     try:
        #         subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        #         print(f'[+] PACSTRAP: pacman-init.service')
        #         break
        #     except subprocess.CalledProcessError as err:
        #         cmd = f'systemctl --no-pager status -n0 pacman-init.service'
        #         subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        #         print(f'[-] PACSTRAP: pacman-init.service', err)

    @staticmethod
    def install(pacmanconf):
        pkg_linux = 'linux-hardened linux-hardened-headers linux-firmware'
        pkg_base = 'base base-devel'
        pkg_btrfs = 'btrfs-progs snapper'
        pkg_git = 'git github-cli'
        pkg_grub = 'grub grub-btrfs efibootmgr'
        pkg_network = 'networkmanager ntp'
        pkg_etc = 'openssh python reflector vim virtualbox-guest-utils'
        cmd = f'pacstrap -K -C {pacmanconf} /mnt {pkg_linux} {pkg_base} {pkg_git} {pkg_grub} {pkg_network} {pkg_btrfs} {pkg_etc}'
        try:
            subprocess.run(cmd, shell=True)
            print(f'[+] PACSTRAP install')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACSTRAP install', err)
            sys.exit(1)

    @staticmethod
    def install_dmi(pacmanconf):
        print('[TODO] Install DMI packages')
        # TODO
        # Install DMI packages
        # pacstrap -C ${pacmanconf} /mnt virtualbox-guest-utils
        # pacstrap -C ${pacmancfg} /mnt open-vm-tools
        pass
