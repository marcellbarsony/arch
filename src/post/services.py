import logging
import subprocess
import sys


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Services():

    """
    Docstring for managing services
    https://wiki.archlinux.org/title/Systemd
    """

    @staticmethod
    def enable():
        services = ['spotifyd'] # ly
        for service in services:
            cmd = f'sudo systemctl enable {service}.service'
            try:
                subprocess.run(cmd, shell=True, check=True)
                logger.info(f'Service: Enable <{service}>')
            except Exception as err:
                logger.error(f'Service: Enable <{service}> {err}')
                sys.exit(1)
