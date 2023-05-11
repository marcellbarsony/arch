import subprocess
import sys
from .dmi import DMI


class Systemd():

    """Docstring for Systemd"""

    @staticmethod
    def acpi_events():
        file = '/etc/systemd/logind.conf'
        with open(file, 'r') as f:
            lines = f.readlines()
        lines[27] = 'HandleLidSwitch=ignore'
        lines[28] = 'HandleLidSwitchExternalPower=ignore'
        lines[29] = 'HandleLidSwitchDocked=ignore'
        try:
            with open(file, 'w') as f:
                 f.writelines(lines)
            print(f'[+] ACPI events')
        except Exception as err:
            print(f'[-] ACPI events', err)

    @staticmethod
    def services():
        cmds = ['systemctl enable fstrim.timer',
                'systemctl enable NetworkManager.service',
                'systemctl enable ntpd.service',
                'systemctl enable reflector.service']
        for cmd in cmds:
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                print('[+]', cmd)
            except subprocess.CalledProcessError as err:
                print('[-]', err)

        if DMI.check() == 'vbox':
            cmd = 'systemctl enable vboxservice.service'
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f'[+] User group [DMI]')
            except subprocess.CalledProcessError as err:
                print(f'[-] User group [DMI]', err)
                sys.exit(1)

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
