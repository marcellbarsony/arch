import subprocess
import sys


class Root():

    """Docstring for Setup"""

    @staticmethod
    def password(root_pw):
        cmd = f'chpasswd 2>&1'
        try:
            subprocess.run(cmd, shell=True, check=True, input=f'root:{root_pw}'.encode())
            print('[+] Root password')
        except subprocess.CalledProcessError as err:
            print('[+] Root password', err)
            sys.exit(1)


class User():

    @staticmethod
    def add(user):
        cmd = f'useradd -m {user}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] User add {user}')
        except subprocess.CalledProcessError as err:
            print(f'[+] User add {user}', err)
            sys.exit(1)

    @staticmethod
    def password(user, user_pw):
        cmd = f'chpasswd'
        try:
            subprocess.run(cmd, input=f'{user}:{user_pw}'.encode())
            print(f'[+] User password [{user}]')
        except subprocess.CalledProcessError as err:
            print(f'[-] User password [{user}]', err)
            sys.exit(1)

    @staticmethod
    def group(user):
        cmd = f'usermod -aG wheel,audio,video,optical,storage,vboxsf {user}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] User group')
        except subprocess.CalledProcessError as err:
            print(f'[-] User group', err)
            sys.exit(1)
