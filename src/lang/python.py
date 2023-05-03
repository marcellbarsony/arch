
import logging
import subprocess
import sys


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Python():

    """Docstring for Python"""

    @staticmethod
    def venv():
        print('[TODO] PYTHON venv')
        pass

    @staticmethod
    def modules(modules: list):
        for module in modules:
            cmd = f'pip install {module}'
            try:
                subprocess.run(cmd, shell=True, check=True)
                print('[+] PYTHON modules')
            except Exception as err:
                print('[-] PYTHON modules', err)
                sys.exit(1)
