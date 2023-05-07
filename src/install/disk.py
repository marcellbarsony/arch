import subprocess
import sys
from .dmi import DMI


class Disk():

    """Docstring for Disk"""

    def __init__(self):
        dmi = DMI()
        device, _, _ = dmi.disk()
        self.device = device

    def wipe(self):
        cmd_list = [f'sgdisk -o {self.device}', # Filesystem
                    f'wipefs -af {self.device}', # Partition data
                    f'sgdisk --zap-all --clear {self.device}'] # GPT data
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print('[+] FILESYSTEM: Wipe')
            except subprocess.CalledProcessError as err:
                print('[-] FILESYSTEM: ', err)
                sys.exit(1)

    def partprobe(self):
        cmd = f'partprobe {self.device}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Partprobe')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Partprobe', err)
            sys.exit(1)
