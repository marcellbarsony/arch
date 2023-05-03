import logging
import subprocess
import sys


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Ruby():

    """Docstring for Ruby"""

    @staticmethod
    def install():
        cmd = 'sudo pacman -Q ruby'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print('[+] RUBY install')
        except Exception as err:
            print('[-] RUBY install', err)
            sys.exit(1)

    @staticmethod
    def gems():
        print('[TODO] RUBY gems')
        # cd ${HOME}/.local/git/blog
        # gem update
        # gem install jekyll bundler
        # bundle update
        # cd ${HOME}
        pass
