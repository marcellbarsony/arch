import subprocess

from base.s02_config import disk


class WipeDisk():

    """Docstring for WipeDisk"""

    def __init__(self):
        super(WipeDisk, self).__init__()

    def filesystem(self):
        cmd = subprocess.run([
            'wipefs',
            '-af',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] Wipe filesystem')
            exit(cmd.returncode)

    def partition_data(self):
        cmd = subprocess.run([
            'sgdisk',
            '-o',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] Partition data')
            exit(cmd.returncode)

    def gpt_data(self):
        cmd = subprocess.run([
            'sgdisk',
            '--zap-all',
            '--clear',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] GPT data')
            exit(cmd.returncode)

    def partprobe(self):
        cmd = subprocess.run([
            'partprobe',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] Partprobe')
            exit(cmd.returncode)

class Partitions():

    """Docstring for Partitions"""

    def __init__(self):
        super(Partitions, self).__init__()

    def create_efi(self):
        cmd = subprocess.run([
            'sgdisk',
            '-n', '0:0:+750MiB',
            '-t', '0:ef00',
            '-c', '0:efi',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] Create partition [EFI]')
            exit(cmd.returncode)

    def create_system(self):
        cmd = subprocess.run([
            'sgdisk',
            '-n', '0:0:0',
            '-t', '0:8e00',
            '-c', '0:cryptsystem',
            disk
            ])
        if cmd.returncode != 0:
            print('[-] Create partition [System]')
            exit(cmd.returncode)


w = WipeDisk()
w.filesystem()
w.partition_data()
w.gpt_data()
w.partprobe()

p = Partitions()
p.create_efi()
p.create_system()
