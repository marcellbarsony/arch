import logging
import subprocess
import sys
import dmi



class Disk():

    """Docstring for Disk"""

    def __init__(self):
        disk, _, _ = dmi.disk()
        self.disk = disk

    def wipe(self):
        cmd_list = [
            f"sgdisk --zap-all --clear {self.disk}", # GUID table
            f"wipefs -af {self.disk}", # Filesystem signature
            f"sgdisk -o {self.disk}" # New GUID table
            ]
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                logging.info(cmd)
            except subprocess.CalledProcessError as err:
                logging.error(f"{cmd}: {err}")
                print("[-] FILESYSTEM: ", err)
                sys.exit(1)
        print("[+] FILESYSTEM: Wipe")

    def create_efi(self, efisize: str):
        cmd = f"sgdisk -n 0:0:+{efisize}MiB -t 0:ef00 -c 0:efi {self.disk}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print("[+] FILESYSTEM: Create EFI")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print("[-] FILESYSTEM: Create EFI", err)
            sys.exit(1)

    def create_system(self):
        cmd = f"sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem {self.disk}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print(f"[+] FILESYSTEM: Create cryptsystem")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(f"[-] FILESYSTEM: Create cryptsystem", err)
            sys.exit(1)

    def partprobe(self):
        cmd = f"partprobe {self.disk}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print("[+] FILESYSTEM: Partprobe")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print("[-] FILESYSTEM: Partprobe", err)
            sys.exit(1)
