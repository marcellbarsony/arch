#!/usr/bin/env python3
# TODO remove


import os
import shutil
import sys


class SecureShell():

    """
    Docstring for SSH configuration
    https://wiki.archlinux.org/title/SSH_keys
    """

    def __init__(self, user):
        self.user = user
        self.sshdir = '/temporary/src/ssh' # TODO: relative directory

    def agentService(self):
        src = f'{self.sshdir}/ssh-agent.service'
        dst = f'/home/{self.user}/.config/systemd/user/'
        os.makedirs(dst, exist_ok=True)
        shutil.copy(src, dst)

    def agentConfig(self):
        src = f'{self.sshdir}/config'
        dst = f'/home/{self.user}/.ssh/config'
        try:
            shutil.copy(src, dst)
            os.chmod(dst, 0o600)
        except Exception as err:
            print('[-]', err)
            sys.exit(1)


shell = SecureShell('marci')
shell.agentConfig()
shell.agentConfig()
