import subprocess
import sys

class WipeDisk():

    """Docstring for WipeDisk"""

    @staticmethod
    def filesystem(disk):
        cmd = f'wipefs -af {disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Wipe')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Wipe', err)
            sys.exit(1)

    @staticmethod
    def partition_data(disk):
        cmd = f'sgdisk -o {disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Wipe partition data')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Wipe partition data', err)
            sys.exit(1)

    @staticmethod
    def gpt_data(disk):
        cmd = f'sgdisk --zap-all --clear {disk}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print('[+] FILESYSTEM: Wipe GPT data')
        except subprocess.CalledProcessError as err:
            print('[-] FILESYSTEM: Wipe GPT data', err)
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
