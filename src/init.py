import os
import requests
import subprocess


class Initialize():

    """Initialize Arch base installer"""

    def __init__(self):
        super(Initialize, self).__init__()

    def network(self):
        url = "https://archlinux.org"
        timeout = 5
        try:
            request = requests.get(url, timeout=timeout)
            print('[+] Internet connection', request)
        except (requests.ConnectionError, requests.Timeout):
            print('[-] Internet connection')
            exit()

    def boot_mode(self):
        path = '/sys/firmware/efi/efivars/'
        result = os.path.exists(path)
        if result is True:
            print('[+] Boot mode <UEFI>')
        else:
            print('[-] Boot mode <BIOS>')
            exit()

    def dmi_data(self):
        command = subprocess.run([
                                'sudo',
                                'dmidecode',
                                '-s',
                                'system-product-name'],
                                stdout=subprocess.DEVNULL)
        if command.returncode == 0:
            if command == "VirtualBox" or "VMware Virtual Platform":
                print('[+] DMI <VM>')
            else:
                print('[+] DMI')
        else:
            print('[-] DMI')

    def sys_clock(self):
        command = subprocess.run([
                                'sudo',
                                'timedatectl',
                                'set-ntp',
                                'true',
                                '--no-ask-password'])
        if command.returncode == 0:
            print('[+] System clock')
        else:
            print('[-] System clock')
            exit()

    def loadkeys(self):
        command = subprocess.run([
                                'sudo',
                                'loadkeys',
                                'us'])
        if command.returncode == 0:
            print('[+] Loadkeys')
        else:
            print('[-] Loadkeys')
            exit()

    def keymap(self):
        command = subprocess.run([
                                'localectl',
                                'set-keymap',
                                '--no-convert',
                                'us'])
        if command.returncode == 0:
            print('[+] Set keymap')
        else:
            print('[-] Set keymap')
            exit()

    def configs(self):
        # copy pacman conf
        pass

    # TODO: Arch-keyring
    # TODO: Pacman mirrors


def init():
    Initialize().network()
    Initialize().boot_mode()
    Initialize().dmi_data()
    Initialize().sys_clock()
    Initialize().loadkeys()
    Initialize().keymap()
    Initialize().configs()
