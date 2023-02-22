import os
import requests
import shutil
import subprocess


class Initialize():

    """Initialize Arch base installer"""

    def __init__(self):
        super(Initialize, self).__init__()
        pass

    def network(self):
        url = 'https://archlinux.org'
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
        virtualbox = "b'VirtualBox\n'"
        vmware = 'VMware Virtual Platform'
        cmd = subprocess.run(
                ['sudo', 'dmidecode', '-s', 'system-product-name'],
                capture_output=True)
        if cmd.returncode == 0:
            if cmd.stdout == virtualbox or vmware:
                print('[+] DMI <VM>')
            else:
                print('[+] DMI <HW>')
        else:
            print('[-] DMI')
            exit()
        return cmd.stdout

    def sys_clock(self):
        cmd = subprocess.run(
                ['sudo', 'timedatectl', 'set-ntp', 'true', '--no-ask-password'],
                stdout=subprocess.DEVNULL)
        if cmd.returncode == 0:
            print('[+] System clock')
        else:
            print('[-] System clock')
            exit()

    def loadkeys(self):
        cmd = subprocess.run(
                ['sudo', 'loadkeys', 'us'],
                stdout=subprocess.DEVNULL)
        if cmd.returncode == 0:
            print('[+] Loadkeys <us>')
        else:
            print('[-] Loadkeys <us>')
            exit()

    def keymap(self):
        cmd = subprocess.run(
                ['localectl', 'set-keymap', '--no-convert', 'us'],
                stdout=subprocess.DEVNULL)
        if cmd.returncode == 0:
            print('[+] Set keymap <us>')
        else:
            print('[-] Set keymap <us>')
            exit()

    def pacman(self):
        pac = '/cfg/pacman.conf'
        src = os.path.dirname(__file__) + pac
        dst = '/etc/pacman.conf'
        try:
            shutil.copy(src, dst)
        except PermissionError as err:
            print('[-] Pacman config', err)

    def mirrors(self):
        # TODO: Pacman mirrors
        print('[TODO]: Check Pacman mirrors')
        pass

    def keyring(self):
        cmd = subprocess.run(
                ['sudo', 'pacman', '-Sy', '--noconfirm', 'archlinux-keyring'],
                stdout=subprocess.DEVNULL)
        if cmd.returncode == 0:
            print('[+] Arch keyring update')
        else:
            print('[-] Arch keyring update')

    def dependencies(self):
        # TODO: Install dependencies (pip, libraries)
        print('[TODO]: Check dependencies')
        pass

c = Initialize()
c.network()
c.boot_mode()
dmidata = c.dmi_data()
c.sys_clock()
c.loadkeys()
c.keymap()
# c.pacman()
# c.mirrors()
# c.keyring()
# c.dependencies()
