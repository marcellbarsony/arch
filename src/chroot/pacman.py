import shutil
import subprocess
import sys


class Mirrorlist():

    """Update & back-up mirrolist"""

    @staticmethod
    def backup():
        src='/etc/pacman.d/mirrorlist'
        dst='/etc/pacman.d/mirrorlist.bak'
        shutil.copy2(src, dst)

    @staticmethod
    def update():
        file = '/etc/pacman.d/mirrorlist'
        cmd = f'reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save {file}'
        try:
            print('[/] Updating Pacman mirrorlist...')
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] PACMAN: System install')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACMAN: System install', err)
            sys.exit(1)

    @staticmethod
    def config():
        config = '/etc/pacman.conf'
        try:
            with open(config, 'r') as file:
                lines = file.readlines()
            print(f'[+] Read {config}')
        except Exception as err:
            print(f'[-] Read {config}', err)
            sys.exit(1)

        lines.insert(37, "ParallelDownloads=5\n")
        lines[37] = f'ILoveCandy\n'
        lines[38] = f'Color\n'

        try:
            with open(config, 'w') as file:
                file.writelines(lines)
            print(f'[+] Write {config}')
        except Exception as err:
            print(f'[-] Write {config}', err)
            sys.exit(1)

