import logging
import os
import shutil
import subprocess
import sys
from .bitwarden import *


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Git():

    """Repository setup"""

    def __init__(self, user: str, gh_user: str, repo: str):
        self.dir = f'/home/{user}/src/{repo}'
        self.gh_user = gh_user
        self.repo = repo

    def repo_clone(self):
        cmd = f'git clone git@github.com:{self.gh_user}/{self.repo}.git {self.dir}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logger.info(f'Clone {self.repo}')
        except subprocess.CalledProcessError as err:
            if err.returncode == 128:
                logger.warning(f'Directory exists: {self.repo}')
                pass
            else:
                logger.error(f'Clone {self.repo}')
                print(repr(err))
                sys.exit(1)

    def repo_chdir(self):
        try:
            os.chdir(self.dir)
        except Exception as err:
            logger.error(f'chdir >> {self.dir} {err}')
            sys.exit(1)

    def repo_cfg(self):
        cmd = f'git remote set-url origin git@github.com:{self.gh_user}/{self.repo}.git'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logger.info(f'Set-url {self.repo}')
        except Exception as err:
            logger.error(f'Set-url {self.repo} {err}')
            sys.exit(1)


class Dotfiles(Git):

    """Dotfiles setup"""

    def __init__(self, user: str, gh_user: str):
        self.dir = f'/home/{user}/.config'
        self.tmp = f'/tmp/config'
        self.repo = 'dotfiles'
        self.gh_user = gh_user # TODO: duplicated

    def temp_dir(self):
        os.makedirs(self.tmp, exist_ok=True)

    def move(self):
        for item in os.listdir(self.dir):
            item_path = os.path.join(self.dir, item)
            if os.path.isfile(item_path):
                try:
                    shutil.move(item_path, self.tmp)
                except shutil.Error as err:
                    if 'already exists' in str(err):
                        pass
                    else:
                        sys.exit(1)
            else:
                try:
                    shutil.move(item_path, os.path.join(self.tmp, item))
                except shutil.Error as err:
                    if 'already exists' in str(err):
                        pass
                    else:
                        sys.exit(1)

    def move_back(self):
        for item in os.listdir(self.tmp):
            item_path = os.path.join(self.tmp, item)
            if os.path.isfile(item_path):
                try:
                    shutil.move(item_path, self.dir)
                except shutil.Error as err:
                    if 'already exists' in str(err):
                        logger.info(f'File or directory already exists >> skipping')
                        pass
                    else:
                        sys.exit(1)
            else:
                try:
                    shutil.move(item_path, os.path.join(self.dir, item))
                except shutil.Error as err:
                    if 'already exists' in str(err):
                        logger.info(f'File or directory already exists >> skipping')
                        pass
                    else:
                        sys.exit(1)
