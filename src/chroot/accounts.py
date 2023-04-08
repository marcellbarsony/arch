import subprocess
import sys


class Root():

    """Docstring for root user setup"""

    @staticmethod
    def password(root_pw: str):
        cmd = f'chpasswd'
        try:
            subprocess.run(cmd, shell=True, check=True, input=f'root:{root_pw}'.encode())
            print('[+] Root password')
        except subprocess.CalledProcessError as err:
            print('[+] Root password', err)
            sys.exit(1)


class User():

    """Docstring for user setup"""

    def __init__(self, user: str):
        self.user = user

    def add(self):
        cmd = f'useradd -m {self.user}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] User add {self.user}')
        except subprocess.CalledProcessError as err:
            print(f'[+] User add {self.user}', err)
            sys.exit(1)

    def password(self, user_pw: str):
        cmd = f'chpasswd'
        try:
            subprocess.run(cmd, input=f'{self.user}:{user_pw}'.encode())
            print(f'[+] User password [{self.user}]')
        except subprocess.CalledProcessError as err:
            print(f'[-] User password [{self.user}]', err)
            sys.exit(1)

    def group(self):
        cmd = f'usermod -aG wheel,audio,video,optical,storage,vboxsf {self.user}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] User group')
        except subprocess.CalledProcessError as err:
            print(f'[-] User group', err)
            sys.exit(1)
