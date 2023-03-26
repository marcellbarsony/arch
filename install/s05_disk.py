import subprocess
import sys

class Disk():

    """Docstring for Disk"""

    @staticmethod
    def wipe(disk):
        cmd_list = [f'sgdisk -o {disk}', # Filesystem
                    f'wipefs -af {disk}', # Partition data
                    f'sgdisk --zap-all --clear {disk}'] # GPT data
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print('[+] FILESYSTEM: Wipe')
            except subprocess.CalledProcessError as err:
                print('[-] FILESYSTEM: ', err)
                sys.exit(1)

    @staticmethod
    def partprobe(disk):
        cmd = f'partprobe {disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Partprobe')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Partprobe', err)
            sys.exit(1)
