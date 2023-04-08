import subprocess
import sys

class CryptSetup():

    """Docstring for Encryption"""

    def __init__(self, rootdevice: str, cryptpassword: str):
        self.rootdevice = rootdevice
        self.cryptpassword = cryptpassword

    def encrypt(self):
        cmd = f'cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat {self.rootdevice}'
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: {self.rootdevice}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: {self.rootdevice}', err)
            sys.exit(1)

    def open(self):
        cmd = f'cryptsetup open --type luks2 {self.rootdevice} cryptroot'
        try:
            subprocess.run(cmd, shell=True, check=True, input=self.cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: Open {self.rootdevice}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: Open {self.rootdevice}', err)
            sys.exit(1)
