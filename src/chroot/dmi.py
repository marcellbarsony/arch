import subprocess
import sys


class DMI():

    """Docstring for DMI"""

    @staticmethod
    def check():
        cmd = 'dmidecode -s system-product-name'
        try:
            out = subprocess.run(cmd, shell=True, check=True, capture_output=True)
            if 'VirtualBox' in str(out.stdout):
                return 'vbox'
            if 'VMware Virtual Platform' in str(out.stdout):
                return 'vmware'
            else:
                return 'pm'
        except subprocess.CalledProcessError as err:
            print('[-]', repr(err))
            sys.exit(1)
