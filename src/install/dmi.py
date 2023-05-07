import subprocess


class DMI():

    """Docstring for DMI"""

    @staticmethod
    def check() -> str:
        cmd = 'sudo dmidecode -s system-product-name'
        out = subprocess.run(cmd, shell=True, check=True, capture_output=True)
        if 'VirtualBox' in str(out.stdout):
            return 'vbox'
        if 'VMware Virtual Platform' in str(out.stdout):
            return 'vmware'
        else:
            return 'pm'

    @staticmethod
    def disk() -> tuple[str, str, str]:
        # lsblk -p -n -l -o NAME,SIZE -e 7,11
        dmi = DMI.check()
        if dmi == 'pm':
            device = '/dev/nvme0n1'
            device_efi = '/dev/nvme0n1p1'
            device_root = '/dev/nvme0n1p2'
            return device, device_efi, device_root
        else:
            device = '/dev/sda'
            device_efi = '/dev/sda1'
            device_root = '/dev/sda2'
            return device, device_efi, device_root
