import grp
import os
import pwd
import shutil
import sys


class SecureShell():

    """
    Docstring for SSH configuration
    https://wiki.archlinux.org/title/SSH_keys
    """

    def __init__(self, user: str):
        self.user = user
        self.sshdir = '/temporary/ssh' # TODO: relative dir (/)

    def agent_service(self):
        src = f'{self.sshdir}/ssh-agent.service'
        dst = f'/home/{self.user}/.config/systemd/user/'
        try:
            os.makedirs(dst, exist_ok=True)
            shutil.copy(src, dst)
        except Exception as err:
            print('[-]', err)
            sys.exit(1)

    def agent_config(self):
        src = f'{self.sshdir}/config'
        dst = f'/home/{self.user}/.ssh/'
        try:
            os.makedirs(dst, exist_ok=True)
            shutil.copy(src, dst)
            dst_path = os.path.join(dst, os.path.basename(src))
            os.chmod(dst_path, 0o600)
        except Exception as err:
            print('[-]', err)
            sys.exit(1)

    def bashrc(self):
        src = f'{self.sshdir}/.bashrc'
        dst = f'/home/{self.user}/'
        try:
            shutil.copy(src, dst)
            dst_path = os.path.join(dst, os.path.basename(src))
            os.chmod(dst_path, 0o644)
        except Exception as err:
            print('[-]', err)
            sys.exit(1)

    def ownership(self):
        target = f'/home/{self.user}/'
        uid = pwd.getpwnam(self.user).pw_uid # Owner
        gid = grp.getgrnam(self.user).gr_gid # Group
        for dirpath, dirnames, filenames in os.walk(target):
            for dirname in dirnames:
                dir_path = os.path.join(dirpath, dirname)
                os.chown(dir_path, uid, gid)
            for filename in filenames:
                file_path = os.path.join(dirpath, filename)
                os.chown(file_path, uid, gid)
