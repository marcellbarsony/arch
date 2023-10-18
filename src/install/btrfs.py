import os
import subprocess
import sys


class Btrfs():

    """Docstring for Btrfs filesystem"""

    def __init__(self, rootdir: str):
        self.rootdir = rootdir
        self.volumes = ["home", "var", "snapshots"]

    def mkfs(self):
        cmd = f"mkfs.btrfs --quiet -L System {self.rootdir}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print("[+] BTRFS: Make filesystem")
        except subprocess.CalledProcessError as err:
            print("[-] BTRFS: Make filesystem", err)
            sys.exit(1)

    def mountfs(self):
        cmd = f"mount {self.rootdir} /mnt"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print("[+] BTRFS: Mount cryptroot >> /mnt")
        except subprocess.CalledProcessError as err:
            print("[-] BTRFS: Mount cryptroot >> /mnt", err)
            sys.exit(1)

    @staticmethod
    def mksubvols():
        subvolumes = [
            "/mnt/@",
            "/mnt/@home",
            "/mnt/@var",
            "/mnt/@snapshots"
        ]
        for subvolume in subvolumes:
            cmd = f"btrfs subvolume create {subvolume}"
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f"[+] BTRFS: Create subvolume {subvolume}")
            except subprocess.CalledProcessError as err:
                print(f"[-] BTRFS: Create subvolume {subvolume}", err)
                sys.exit(1)

    @staticmethod
    def unmount():
        cmd = "umount -R /mnt"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f"[+] Unmount")
        except subprocess.CalledProcessError as err:
            print(f"[-] Unmount", err)
            sys.exit(1)

    def mount_root(self):
        cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ {self.rootdir} /mnt"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f"[+] BTRFS: Mount @/ >> /mnt")
        except subprocess.CalledProcessError as err:
            print(f"[-] BTRFS: Mount @/ >> /mnt", err)
            sys.exit(1)

    def mkdir(self):
        for subvolume in self.volumes:
            path = "/mnt/" + subvolume
            if not os.path.exists(path):
                os.makedirs(path)
                print(f"[+] BTRFS: mkdir {path}")
            else:
                print(f"[-] BTRFS: mkdir {path}")
                sys.exit(1)

    def mount_subvolumes(self):
        for subvolume in self.volumes:
            cmd = f"mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@{subvolume} {self.rootdir} /mnt/{subvolume}"
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f"[+] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}")
            except subprocess.CalledProcessError as err:
                print(f"[-] BTRFS: Mount @{subvolume} >> /mnt/{subvolume}", err)
                sys.exit(1)
