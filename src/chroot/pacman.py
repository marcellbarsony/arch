import shutil
import subprocess
import sys


class Mirrorlist():

    """
    Update & back-up mirrolist
    https://wiki.archlinux.org/title/Reflector
    """

    def __init__(self):
        self.mirrorlist = "/etc/pacman.d/mirrorlist"

    def backup(self):
        dst = "/etc/pacman.d/mirrorlist.bak"
        shutil.copy2(self.mirrorlist, dst)

    def update(self):
        cmd = f"sudo reflector \
        --latest 25 \
        --protocol https \
        --connection-timeout 5 \
        --sort rate \
        --save {self.mirrorlist}"
        try:
            print("[i] REFLECTOR: Updating Pacman mirrorlist...")
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print("[+] REFLECTOR: Mirrorlist update")
        except subprocess.CalledProcessError as err:
            print("[-] REFLECTOR: Mirorlist update", err)
            sys.exit(1)

class Pacman():

    """
    Pacman configuration
    https://wiki.archlinux.org/title/Pacman
    """

    @staticmethod
    def config():
        config = "/etc/pacman.conf"
        try:
            with open(config, "r") as file:
                lines = file.readlines()
        except Exception as err:
            print(f"[-] PACMAN: Read {config}", err)
            sys.exit(1)

        lines[32] = f"Color\n"
        lines[33] = f"ILoveCandy\n"
        lines[35] = f"VerbosePkgLists\n"
        lines[36] = f"ParallelDownloads=5\n"
        try:
            with open(config, "w") as file:
                file.writelines(lines)
            print(f"[+] PACMAN: Write {config}")
        except Exception as err:
            print(f"[-] PACMAN: Write {config}", err)
            sys.exit(1)
