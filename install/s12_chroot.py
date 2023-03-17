import os
import shutil
import subprocess
import sys


class Chroot():

    """Change root to system"""

    @staticmethod
    def copy_sources():
        cfg_src = '/media/sf_arch/config.ini'
        cfg_dst = '/mnt/config.ini'
        script_src = '/media/sf_arch/src/'
        script_dst = '/mnt/temporary'
        try:
            shutil.copytree(script_src, script_dst)
            shutil.copy(cfg_src, cfg_dst)
            os.chmod('/mnt/temporary/main.py', 0o755)
            print('[+] CHROOT: Copy script')
        except FileExistsError as err:
            pass
        except Exception as err:
            print('[-] CHROOT: Copy script', err)
            sys.exit(1)

    @staticmethod
    def chroot():
        cmd = 'arch-chroot /mnt ./temporary/main.py'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print(f'[+] CHROOT')
        except subprocess.CalledProcessError as err:
            print(f'[-] CHROOT', err)
            sys.exit(1)

    @staticmethod
    def clear():
        shutil.rmtree('/mnt/temporary')
        os.remove('/mnt/config.ini')
