import logging
import subprocess
import sys
from .bitwarden import *


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class GitSetup():

    """
    GitHub setup with SSH
    https://docs.github.com/en/authentication/connecting-to-github-with-ssh
    """

    @staticmethod
    def get_user(gh_user: str):
        return Bitwarden().rbw_get('github', gh_user)

    @staticmethod
    def auth_login(gh_token: str):
        cmd = 'gh auth login --with-token'
        token = Bitwarden().rbw_get('github', gh_token)
        try:
            subprocess.run(cmd, shell=True, check=True, input=token.encode())
            logger.info('Auth login')
        except subprocess.CalledProcessError as err:
            logger.error(f'Auth login', err)
            sys.exit(1)

    @staticmethod
    def auth_status():
        cmd = 'gh auth status'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Auth status')
        except subprocess.CalledProcessError as err:
            print(err)
            sys.exit(1)

    @staticmethod
    def add_pubkey(user: str, gh_pubkey: str):
        cmd = f'gh ssh-key add /home/{user}/.ssh/id_ed25519.pub -t {gh_pubkey}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Add public key')
        except subprocess.CalledProcessError as err:
            logger.error('Add public key', err)
            sys.exit(1)

    @staticmethod
    def known_hosts():
        cmd = 'ssh-keyscan github.com >> ~/.ssh/known_hosts'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Known hosts')
        except subprocess.CalledProcessError as err:
            logger.error('Known hosts', err)
            sys.exit(1)

    @staticmethod
    def ssh_test():
        cmd = 'ssh -T git@github.com'
        res = subprocess.run(cmd, shell=True)
        if res.returncode in [0, 1]:
            logger.info('SSH test')
        else:
            logger.error('SSH test')
            sys.exit(res.returncode)

    @staticmethod
    def config(gh_user: str, git_mail: str):
        user_mail = Bitwarden().rbw_get('github', git_mail)
        cmd_list = [f'git config --global user.name "{gh_user}"',
                    f'git config --global user.email "{user_mail}"',
                    f'git config --global init.defaultBranch main']
        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True)
            except subprocess.CalledProcessError as err:
                logger.error('Git config', err)
                sys.exit(1)
        logger.info('Git config')
