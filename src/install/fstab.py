import logging
import os
import sys
import subprocess


class Fstab():

    """Docstring for Fstab"""

    @staticmethod
    def mkdir():
        dir = "/mnt/etc"
        try:
            os.mkdir(dir)
            logging.info(dir)
            print("[+] FSTAB: Mkdir")
        except Exception as err:
            logging.error(f"{dir}: {err}")
            print("[+] FSTAB: Mkdir", err)
            sys.exit(1)

    @staticmethod
    def genfstab():
        cmd = "genfstab -U /mnt >> /mnt/etc/fstab"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logging.info(cmd)
            print("[+] FSTAB: Genfstab")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print("[-] FSTAB: Genfstab", err)
            sys.exit(1)
