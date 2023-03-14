import subprocess
import sys

class CryptSetup():

    """Docstring for Encryption"""

    @staticmethod
    def encrypt(rootdevice, cryptpassword):
        cmd = f'cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat {rootdevice}'
        try:
            subprocess.run(cmd, shell=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: {rootdevice}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: {rootdevice}', err)
            sys.exit(1)

    @staticmethod
    def open(rootdevice, cryptpassword):
        cmd = f'cryptsetup open --type luks2 {rootdevice} cryptroot'
        try:
            subprocess.run(cmd, shell=True, input=cryptpassword.encode(), stdout=subprocess.DEVNULL)
            print(f'[+] CRYPTSETUP: Open {rootdevice}')
        except subprocess.CalledProcessError as err:
            print(f'[-] CRYPTSETUP: Open {rootdevice}', err)
            sys.exit(1)
