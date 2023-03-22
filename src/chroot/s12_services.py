import subprocess
import sys


class Service():

    """Docstring for Services"""

    @staticmethod
    def enable():
        services = ['ntpd.service',
                    'sshd.service',
                    'NetworkManager',
                    'fstrim.timer',
                    'vboxservice.service']
        for service in services:
            cmd = f'systemctl enable {service}'
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f'[+] SERVICE enable {service}')
            except subprocess.CalledProcessError as err:
                print(f'[-] SERVICE enable {service}', err)
                sys.exit(1)

    # @staticmethod
    # def enable_dmi():
    #     cmd = f'pacman -Qi virtualbox-guest-utils'
    #     if dmidata == "VirtualBox":
    #         cmd = 'modprobe -a vboxguest vboxsf vboxvideo'
    #         try:
    #             subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    #             print(f'[+] DMI: VirtualBox modprove')
    #         except subprocess.CalledProcessError as err:
    #             print(f'[-] DMI: VirtualBox modprobe', err)
    #             sys.exit(1)
    #     if dmidata == "VMware Virtual Platform":
    #         services = ['vmtoolsd.service', 'vmware-vmblock-fuse.service']
    #         for service in services:
    #             cmd = f'systemctl enable {service}'
    #             try:
    #                 subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    #                 print(f'[+] DMI: VMware {service}')
    #             except subprocess.CalledProcessError as err:
    #                 print(f'[-] DMI: VMware {service}', err)
    #                 sys.exit(1)
    #     else:
    #         print(f'[-] DMI data: {dmidata}')
