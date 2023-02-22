import subprocess

from base.s02_config import cryptpassword, rootdevice

class Encryption():

    """Docstring for Encryption"""

    def __init__(self):
        super(Encryption, self).__init__()

    def encrypt(self):
        cmd = subprocess.run([
                'cryptsetup',
                '--type', 'luks2',
                '--cipher', 'aes-xts-plain64',
                '--hash', 'sha512',
                '--key-size', '256',
                '--pbkdf', 'pbkdf2',
                '--batch-mode',
                'luksFormat',
                rootdevice
                ], input=cryptpassword.encode())
        if cmd.returncode != 0:
            print(f'[-] Cryptsetup {rootdevice}')
            exit(cmd.returncode)

    def open(self):
        cmd = subprocess.run([
                'cryptsetup',
                'open',
                '--type', 'luks2',
                rootdevice,
                'cryptroot'
                ], input=cryptpassword.encode())
        if cmd.returncode != 0:
            print(f'[-] Cryptsetup open {rootdevice}')
            exit(cmd.returncode)

c = Encryption()
c.encrypt()
c.open()
