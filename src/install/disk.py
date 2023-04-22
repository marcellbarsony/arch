import subprocess
import sys

class Disk():

    """Docstring for Disk"""

    def __init__(self, disk: str):
        self.disk = disk

    def wipe(self):
        cmd_list = [f'sgdisk -o {self.disk}', # Filesystem
                    f'wipefs -af {self.disk}', # Partition data
                    f'sgdisk --zap-all --clear {self.disk}'] # GPT data
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print('[+] FILESYSTEM: Wipe')
            except subprocess.CalledProcessError as err:
                print('[-] FILESYSTEM: ', err)
                sys.exit(1)

    def partprobe(self):
        cmd = f'partprobe {self.disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Partprobe')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Partprobe', err)
            sys.exit(1)
