import os
import subprocess
import sys

from base.s02_config import efidevice


class Filesystem():

    """Docstring for Filesystem"""


    def __init__(self):
        self.subvolumes = ['home', 'var', 'snapshots']
        self.rootdir = '/dev/mapper/cryptroot'

    def btrfs_mkfs(self):
        cmd = subprocess.run([
                'mkfs.btrfs',
                '--quiet',
                '-L', 'System',
                self.rootdir
                ])
        if cmd.returncode == 0:
            print(f'[+] BTRFS: Make filesystem {cmd.returncode}')
        else:
            print(f'[-] BTRFS: Make filesystem {cmd.returncode}')
            exit(cmd.returncode)

        # Mount
        cmd = subprocess.run([
                'mount',
                self.rootdir,
                '/mnt'
                ])
        if cmd.returncode == 0:
            print(f'[+] BTRFS: Mount cryptroot to /mnt {cmd.returncode}')
        else:
            print(f'[-] BTRFS: Mount cryptroot to /mnt {cmd.returncode}')
            exit(cmd.returncode)

    def btrfs_mksub(self):
        subvolumes = [
            '/mnt/@',
            '/mnt/@home',
            '/mnt/@var',
            '/mnt/@snapshots'
            ]
        for subvolume in subvolumes:
            cmd = subprocess.run(['btrfs', 'subvolume', 'create', subvolume])
            if cmd.returncode != 0:
                print(f'[-] BTRFS: Create subvolume {subvolume}')
                exit(cmd.returncode)

    def fs_unmount(self):
        cmd = subprocess.run([
                'umount',
                '-R',
                '/mnt'
                ])
        if cmd.returncode == 0:
            print(f'[+] Unmount')
        else:
            print(f'[-] Unmount')
            exit(cmd.returncode)

    def root_mount(self):
        cmd = subprocess.run([
                'mount', '-o',
                'noatime,compress=zstd,space_cache=v2,discard=async,subvol=@',
                self.rootdir,
                '/mnt'
                ])
        if cmd.returncode == 0:
            print(f'[+] BTRFS: mount @/ to /mnt')
        else:
            print(f'[-] BTRFS: mount @/ to /mnt')
            exit(cmd.returncode)

    def btrfs_dir(self):
        for subvolume in self.subvolumes:
            path = '/mnt/' + subvolume
            if not os.path.exists(path):
                os.makedirs(path)
                print(f'[+] BTRFS: Directory created {path}')
            else:
                print(f'[-] BTRFS: Directory created {path}')
                sys.exit(1)

    def btrfs_mount(self):
        for subvolume in self.subvolumes:
            mount_options = f"noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume}"
            mount_point = f"/mnt/{subvolume}"
            out = subprocess.run([
                    'mount', '-o',
                    mount_options,
                    self.rootdir,
                    mount_point
                    ])
            if out.returncode == 0:
                print(f'[+] BTRFS: mount @{subvolume} to /mnt/{subvolume}')
            else:
                print(f'[-] BTRFS: mount @{subvolume} to /mnt/{subvolume}')
                exit(out.returncode)


class Efi():

    """Docstring for Efi partition"""

    def __init__(self):
        self.efidir = '/mnt/boot'

    def efi_dir(self):
        if not os.path.exists(self.efidir):
            os.makedirs(self.efidir)
            print(f'[+] EFI: Directory {self.efidir}')
        else:
            print(f'[-] EFI: Directory {self.efidir}')

    def efi_format(self):
        cmd = subprocess.run([
                'mkfs.fat',
                '-F32',
                efidevice
                ])
        if cmd.returncode == 0:
            print(f'[+] EFI: Format {efidevice} to F32')
        else:
            print(f'[-] EFI: Format {efidevice} to F32')
            exit(cmd.returncode)

    def efi_mount(self):
        cmd = subprocess.run([
                'mount',
                efidevice,
                self.efidir
                ])
        if cmd.returncode == 0:
            print(f'[+] EFI: Mount {efidevice} to {self.efidir}')
        else:
            print(f'[-] EFI: Mount {efidevice} to {self.efidir}')
            exit(cmd.returncode)


f = Filesystem()
f.btrfs_mkfs()
f.btrfs_mksub()
f.fs_unmount()
f.root_mount()
f.btrfs_dir()
f.btrfs_mount()

e = Efi()
e.efi_dir()
e.efi_format()
e.efi_mount()
