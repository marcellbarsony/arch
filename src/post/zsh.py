import logging
import os
import subprocess
import sys


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Zsh():

    """Docstring for Shell"""

    def __init__(self, user: str):
        self.user = user

    def set(self):
        cmd = 'chsh -s /usr/bin/zsh'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Zsh: Change to /usr/bin/zsh')
        except Exception as err:
            logger.error('Zsh: Change to /usr/bin/zsh', {err})
            sys.exit(1)

    def config(self):
        src = f'/home/{self.user}/.config/zsh/global/'
        dst = '/etc/zsh/'

        for file in os.listdir(src):
            src_file = os.path.join(src, file)
            dst_file = os.path.join(dst, file)
            cmd_copy = f'sudo cp -r {src_file} {dst_file}'
            cmd_chmod = f'sudo chmod 644 {dst_file}'
            try:
                subprocess.run(cmd_copy, shell=True, check=True)
                subprocess.run(cmd_chmod, shell=True, check=True)
                logger.info('Zsh: Startup file')
            except Exception as err:
                logger.error('Zsh: Startup file', {err})
                sys.exit(1)

    def tools(self):
        repositories = {'marlonrichert/zsh-autocomplete': 'zsh-autocomplete',
                        'zsh-users/zsh-completions':      'zsh-completions',
                        'zsh-users/zsh-autosuggestions':      'zsh-autosuggestions',
                        'zsh-users/zsh-syntax-highlighting':      'zsh-syntax-highlighting'}
        for repo, dir in repositories.items():
            dst = f'/home/{self.user}/.local/src/{dir}'
            cmd = f'git clone --depth 1 git@github.com:{repo}.git {dst}'
            try:
                subprocess.run(cmd, shell=True, check=True)
                logger.info('Zsh: Tools')
            except Exception as err:
                logger.error('Zsh: Tools ', {err})
                sys.exit(1)
