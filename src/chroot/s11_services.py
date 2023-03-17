import subprocess
import sys


class Service():

    """Docstring for Services"""

    @staticmethod
    def enable():
        services = [
            'ntpd.service',
            'sshd.service',
            'NetworkManager',
            'fstrim.timer',
            'vboxservice.service'
            ]
        for service in services:
            cmd = f'systemctl enable {service}'
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f'[+] SERVICE enable {service}')
            except subprocess.CalledProcessError as err:
                print(f'[-] SERVICE enable {service}', err)
                sys.exit(1)

    # def services_dmi(self):
    #     if dmidata == "VirtualBox":
    #         cmd = subprocess.run([
    #             'modprobe',
    #             '-a',
    #             'vboxguest',
    #             'vboxsf',
    #             'vboxvideo'
    #             ])
    #     if dmidata == "VMware Virtual Platform":
    #         services = ['vmtoolsd.service', 'vmware-vmblock-fuse.service']
    #         for service in services:
    #             cmd = subprocess.run([
    #                     'systemctl',
    #                     'enable',
    #                     service
    #                     ])
    #             if cmd.returncode == 0:
    #                 print(f'[+] Service {service}')
    #             else:
    #                 print(f'[-] Service {service}')
    #     else:
    #         print(f'[-] DMI data: {dmidata}')
