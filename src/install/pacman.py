import subprocess
import sys


class Pacman():

    """
    Initialize Pacman config
    """

    @staticmethod
    def config():
        config = '/etc/pacman.conf'
        try:
            with open(config, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print(f'[-] Read {config}', err)
            sys.exit(1)

        lines.insert(36, f'ParallelDownloads=5\n')
        lines[37] = f'ILoveCandy\n'
        lines[38] = f'Color\n'

        try:
            with open(config, 'w') as file:
                file.writelines(lines)
            print(f'[+] PACMAN: Write {config}')
        except Exception as err:
            print(f'[-] PACMAN: Write {config}', err)
            sys.exit(1)


class Keyring():

    """
    Initialize keyring config
    https://wiki.archlinux.org/title/Pacman/
    """

    @staticmethod
    def init():
        cmd_list = ['pacman -Sy --noconfirm archlinux-keyring',
                    'pacman-key --init',
                    #'pacman-key --refresh-keys',
                    # gpg --refresh-keys,
                    'pacman-key --populate']
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print('[+] PACMAN: Arch keyring update')
            except subprocess.CalledProcessError as err:
                print('[-] PACMAN: Arch keyring update', err)
                pass
