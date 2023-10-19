import subprocess
import sys
from .dmi import DMI


class CryptSetup():

    """Docstring for Encryption"""

    def __init__(self, cryptpassword: str):
        dmi = DMI()
        _, _, device_root = dmi.disk()
        self.device_root = device_root
        self.cryptpassword = cryptpassword

    def encrypt(self):

        """
        Device encryption
        https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
        """

        cmd = f"cryptsetup \
        --batch-mode luksFormat \
        --cipher aes-xts-plain64 \
        --hash sha512 \
        --iter-time 5000 \
        --key-size 512 \
        --pbkdf pbkdf2 \
        --type luks2 \
        --use-random \
        {self.device_root}"
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f"[+] CRYPTSETUP: {self.device_root}")
        except subprocess.CalledProcessError as err:
            print(f"[-] CRYPTSETUP: {self.device_root}", err)
            sys.exit(1)

    def open(self):
        cmd = f"cryptsetup open --type luks2 {self.device_root} cryptroot"
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f"[+] CRYPTSETUP: Open {self.device_root}")
        except subprocess.CalledProcessError as err:
            print(f"[-] CRYPTSETUP: Open {self.device_root}", err)
            sys.exit(1)
