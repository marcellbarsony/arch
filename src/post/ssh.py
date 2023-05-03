import logging
import os
import shutil
import subprocess
import sys
from .bitwarden import Bitwarden


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SecureShell():

    """
    SSH Agent setup
    https://wiki.archlinux.org/title/SSH_keys
    """

    def __init__(self, user: str, current_dir: str):
        self.user = user
        self.sshdir = f'{current_dir}/src/ssh'

    def config(self):
        src = f'{self.sshdir}/config'
        dst = f'/home/{self.user}/.ssh/'
        try:
            os.makedirs(dst, exist_ok=True)
            shutil.copy(src, dst)
            dst_path = os.path.join(dst, os.path.basename(src))
            os.chmod(dst_path, 0o600)
        except Exception as err:
            logger.error(err)
            sys.exit(1)

    def service_set(self):
        src = f'{self.sshdir}/ssh-agent.service'
        dst = f'/home/{self.user}/.config/systemd/user/'
        try:
            os.makedirs(dst, exist_ok=True)
            shutil.copy(src, dst)
        except Exception as err:
            logger.error(err)
            sys.exit(1)

    def service_start(self):
        cmd1 = 'systemctl --user enable ssh-agent.service'
        cmd2 = 'systemctl --user start ssh-agent.service'
        try:
            subprocess.run(cmd1, shell=True, check=True)
            subprocess.run(cmd2, shell=True, check=True)
            logger.info('Enable & Start SSH-Agent')
        except Exception as err:
            logger.error('Enable SSH-Agent', err)
            sys.exit(1)

    def key_gen(self, ssh_key: str, gh_mail: str):
        gh_mail = Bitwarden().rbw_get('github', gh_mail)
        file = f'/home/{self.user}/.ssh/id_ed25519'
        cmd = f'ssh-keygen -q -t ed25519 -N {ssh_key} -C {gh_mail} -f {file}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Keygen')
        except Exception as err:
            logger.error('Keygen', err)
            sys.exit(1)

    @staticmethod
    def key_add():
        cmd = 'ssh-add -q ~/.ssh/id_ed25519'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('SSH Add key')
        except Exception as err:
            logger.error('SSH Add key', err)
            sys.exit(1)
