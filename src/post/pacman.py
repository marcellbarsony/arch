import logging
import subprocess
import sys
import os


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Pacman():

    """Package manager setup"""

    @staticmethod
    def install(current_dir: str):
        src_dir = f'{current_dir}/src/pkgtest/' # TODO: change test dir to prod
        for file in os.listdir(src_dir):
            file_path = os.path.join(src_dir, file)
            if os.path.isfile(file_path):
                cmd = f'sudo pacman -S --needed --noconfirm - < {file_path}'
                try:
                    subprocess.run(cmd, shell=True, check=True, text=True)
                    logger.info('Pacman: Install')
                except Exception as err:
                    logger.error(f'Pacman: Install {err}')
                    sys.exit(1)

    @staticmethod
    def install_package(package):
        cmd = f'sudo pacman -S --needed --noconfirm {package}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f'[+] Installed {package}')
        except Exception as err:
            logger.error(f'[-] {err}')
            sys.exit(1)
