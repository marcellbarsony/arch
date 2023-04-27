import subprocess
import sys


class Service():

    """Docstring for Services"""

    @staticmethod
    def enable():
        cmds = ['systemctl enable fstrim.timer',
                'systemctl enable NetworkManager.service',
                'systemctl enable ntpd.service',
                'systemctl enable reflector.service',
                'systemctl enable vboxservice.service']
        for cmd in cmds:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                print('[+]', cmd)
            except subprocess.CalledProcessError as err:
                print('[-]', err)

    # @staticmethod
    # def enableDmi():
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
