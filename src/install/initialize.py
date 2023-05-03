import os
import subprocess
import sys


class Init():

    """Initialize Arch base installer"""

    @staticmethod
    def set_font(font):
        print('TODO', font)
        # cmd = f'setfont {font}'
        # try:
        #     subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        #     print(f'[+] Set font <{font}>')
        # except subprocess.CalledProcessError as err:
        #     print(f'[-] Set font <{font}>', {err})
        #     sys.exit(1)
        pass

    @staticmethod
    def boot_mode():
        path = '/sys/firmware/efi/efivars/'
        if os.path.exists(path):
            print('[+] Boot mode <UEFI>')
        else:
            print('[-] Boot mode <BIOS>')
            sys.exit(1)

    @staticmethod
    def dmi_data():
        cmd = 'dmidecode -s system-product-name'
        try:
            out = subprocess.run(cmd, shell=True, check=True, capture_output=True)
            if 'VirtualBox' in str(out.stdout):
                print('[+] DMI <VirtualBox>')
                return 'virtualbox'
            if 'VMware Virtual Platform' in str(out.stdout):
                print('[+] DMI <VMWare>')
                return 'vmware'
        except subprocess.CalledProcessError as err:
            print('[-]', repr(err))
            sys.exit(1)

    @staticmethod
    def timezone():
        cmd = 'timedatectl set-timezone Europe/Amsterdam'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] Timezone')
        except subprocess.CalledProcessError as err:
            print('[-] Timezone', {err})
            sys.exit(1)

    @staticmethod
    def sys_clock():
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
