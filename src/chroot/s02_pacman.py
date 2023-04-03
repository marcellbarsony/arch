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
            print('[/] PACMAN: Updating Pacman mirrorlist...')
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] PACMAN: Mirrorlist update')
        except subprocess.CalledProcessError as err:
            print(f'[-] PACMAN: Mirorlist update', err)
            sys.exit(1)

class Pacman():

    """Pacman configuration"""

    @staticmethod
    def config():
        config = '/etc/pacman.conf'
        try:
            with open(config, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print(f'[-] PACMAN: Read {config}', err)
            sys.exit(1)

        lines[32] = f'Color\n'
        lines[33] = f'ILoveCandy\n'
        lines[36] = f'ParallelDownloads=5\n'

        try:
            with open(config, 'w') as file:
                file.writelines(lines)
            print(f'[+] PACMAN: Write {config}')
        except Exception as err:
            print(f'[-] PACMAN: Write {config}', err)
            sys.exit(1)