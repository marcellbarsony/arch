import os
import subprocess
import sys

class Btrfs():

    """Docstring for Filesystem"""

    @staticmethod
    def mkfs(rootdir):
        cmd = f'mkfs.btrfs --quiet -L System {rootdir}'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print('[+] BTRFS: Make filesystem')
        except subprocess.CalledProcessError as err:
            print('[-] BTRFS: Make filesystem', err)
            sys.exit(1)

    @staticmethod
    def mountfs(rootdir):
        cmd = f'mount {rootdir} /mnt'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print('[+] BTRFS: Mount cryptroot >> /mnt')
        except subprocess.CalledProcessError as err:
            print('[-] BTRFS: Mount cryptroot >> /mnt', err)
            sys.exit(1)

    @staticmethod
    def subvolumes():
        subvolumes = ['/mnt/@', '/mnt/@home', '/mnt/@var', '/mnt/@snapshots']
        for subvolume in subvolumes:
            cmd = f'btrfs subvolume create {subvolume}'
            try:
                subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
                print(f'[+] BTRFS: Create subvolume {subvolume}')
            except subprocess.CalledProcessError as err:
                print(f'[-] BTRFS: Create subvolume {subvolume}', err)
                sys.exit(1)

    @staticmethod
    def unmount():
        cmd = 'umount -R /mnt'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] Unmount')
        except subprocess.CalledProcessError as err:
            print(f'[-] Unmount', err)
            sys.exit(1)

    @staticmethod
    def mount_root(rootdir):
        cmd = f'mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ {rootdir} /mnt'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] BTRFS: Mount @/ >> /mnt')
        except subprocess.CalledProcessError as err:
            print(f'[-] BTRFS: Mount @/ >> /mnt', err)
            sys.exit(1)

    @staticmethod
    def mkdir():
        subvolumes = ['home', 'var', 'snapshots']
        for subvolume in subvolumes:
            path = '/mnt/' + subvolume
            if not os.path.exists(path):
                os.makedirs(path)
                print(f'[+] BTRFS: Create directory {path}')
            else:
                print(f'[-] BTRFS: Create directory {path}')
                sys.exit(1)

    @staticmethod
    def mount_subvolumes(rootdir):
        subvolumes = ['home', 'var', 'snapshots']
        for subvolume in subvolumes:
            cmd = f'mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume} {rootdir} /mnt/{subvolume}'
            try:
                subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
                print(f'[+] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}')
            except subprocess.CalledProcessError as err:
                print(f'[-] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}', err)
                sys.exit(1)
