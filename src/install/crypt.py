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
        cmd = f'cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat {self.device_root}'
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: {self.device_root}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: {self.device_root}', err)
            sys.exit(1)

    def open(self):
        cmd = f'cryptsetup open --type luks2 {self.device_root} cryptroot'
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: Open {self.device_root}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: Open {self.device_root}', err)
            sys.exit(1)
