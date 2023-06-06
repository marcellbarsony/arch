import subprocess
import sys


class Initialize():

    """
    Initialize Arch base installer
    """

    @staticmethod
    def time_zone():
        cmd = 'timedatectl set-timezone Europe/Amsterdam' # TODO: softcode
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] Timezone')
        except subprocess.CalledProcessError as err:
            print('[-] Timezone', {err})
            sys.exit(1)

    @staticmethod
    def sys_time():
        cmd = 'timedatectl set-ntp true --no-ask-password'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] Set NTP')
        except subprocess.CalledProcessError as err:
            print('[-] Set NTP', {err})
            sys.exit(1)

    @staticmethod
    def loadkeys(keys: str):
        cmd = f'loadkeys {keys}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] Loadkeys <{keys}>')
        except subprocess.CalledProcessError as err:
            print(f'[-] loadkeys <{keys}>', {err})
            sys.exit(1)

    @staticmethod
    def keymaps(keymap: str):
        cmd = f'localectl set-keymap --no-convert {keymap}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] Keymaps <{keymap}>')
        except subprocess.CalledProcessError as err:
            print(f'[-] Keymaps <{keymap}>', {err})
            sys.exit(1)