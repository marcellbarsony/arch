import subprocess
import sys
import logging


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Initialize():

    """Initialize Arch base installer"""

    @staticmethod
    def dmi_data():
        cmd = 'sudo dmidecode -s system-product-name'
        try:
            out = subprocess.run(cmd, shell=True, check=True, capture_output=True)
            if 'VirtualBox' in str(out.stdout):
                logger.info('DMI data: VirtualBox')
                return 'virtualbox'
            if 'VMware Virtual Platform' in str(out.stdout):
                logger.info('DMI data: VMWare')
                return 'vmware'
        except subprocess.CalledProcessError as err:
            logger.error('DMI: Cannot fetch DMI information')
            print(repr(err))
            sys.exit(1)

    @staticmethod
    def sys_timezone(timezone: str):
        cmd = f'sudo timedatectl set-timezone {timezone}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Time & Date: Timezone')
        except subprocess.CalledProcessError as err:
            logger.error('Time & Date: Timezone')
            print(repr(err))
            sys.exit(1)

    @staticmethod
    def sys_clock():
        cmd = 'sudo timedatectl set-ntp true --no-ask-password'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            logger.info('Time & Date: System clock')
        except subprocess.CalledProcessError as err:
            logger.error('Time & Date: System clock')
            print(repr(err))
            sys.exit(1)
