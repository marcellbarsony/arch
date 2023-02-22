#!/usr/bin/env python3
"""
Author: Name
Date  : 02/12/23
Desc  : Description
"""

import re
import subprocess
import textwrap


KEYMAP='us'
ROOT_PASSWORD='admin'
USER_PASSWORD='marci'
USERNAME='marci'
HOSTNAME='arch'


class Locale():

    """Docstring for Setup"""

    def __init__(self):
        super(Locale, self).__init__()

    def loadkeys(self):
        cmd = subprocess.run([
                'sudo',
                'loadkeys',
                KEYMAP
                ], stdout=subprocess.DEVNULL)
        if cmd.returncode == 0:
            print(f'[+] Loadkeys {KEYMAP}')
        else:
            print(f'[-] Loadkeys {KEYMAP}')
            exit(cmd.returncode)

    def keymap(self):
        conf = '/etc/vconsole.conf'
        content = f"KEYMAP={KEYMAP}"
        try:
            with open(conf, 'r') as file:
                print(f'[+] {conf} already exists')
        except FileNotFoundError:
            with open(conf, 'w') as file:
                file.write(content)

class Useradd():

    """Docstring for Setup"""

    def __init__(self):
        super(Useradd, self).__init__()

    def root_pw(self):
        cmd = subprocess.run([
                'chpasswd',
                '2>&1',
                ], input=f'root:{ROOT_PASSWORD}'.encode())
        if cmd.returncode == 0:
            print('[+] Root password')
        else:
            print(f'[-] Root password')
            exit(cmd.returncode)

    def user_add(self):
        cmd = subprocess.run([
                'useradd',
                '-m',
                USERNAME
                ])
        if cmd.returncode == 0:
            print(f'[+] User add {USERNAME}')
        else:
            print(f'[-] User add {USERNAME}')
            exit(cmd.returncode)

    def user_pw(self):
        cmd = subprocess.run([
                'chpasswd'
                ], input=f'{USERNAME}:{USER_PASSWORD}'.encode())
        if cmd.returncode == 0:
            print(f'[+] User password [{USERNAME}]')
        else:
            print(f'[-] User password [{USERNAME}]')
            exit(cmd.returncode)

    def user_group(self):
        cmd = subprocess.run([
                'usermod',
                '-aG',
                'wheel,audio,video,optical,storage,vboxsf',
                USERNAME
                ])
        if cmd.returncode == 0:
            print('[+] User group')
        else:
            print('[-] User group')
            exit(cmd.returncode)

    def hostname(self):
        conf = '/etc/hostname'
        with open(conf, 'w') as file:
            file.write(HOSTNAME)
            print('[+] /etc/hostname')

    def hosts(self):
        conf = '/etc/hosts'
        content = textwrap.dedent(f"""\
                    127.0.0.1        localhost
                    ::1              localhost
                    127.0.1.1        {HOSTNAME}""")
        with open(conf, 'w') as file:
            file.write(content)
            print('[+] /etc/hosts')

    def sudoers(self):
        with open('/etc/sudoers', 'r') as file:
            lines = file.readlines()
        lines.insert(73, "Defaults:%wheel insults\n")
        lines.insert(74, "Defaults passwd_timeout=0\n")
        lines[86] = "%wheel ALL=(ALL:ALL) ALL\n"
        with open('/etc/sudoers', 'w') as file:
            file.writelines(lines)


class Sysadmin():

    """Docstring for Sysadmin"""

    def locale(self):
        with open('/etc/locale.gen', 'r') as file:
            lines = file.readlines()
        lines[170] = "en_US.UTF-8 UTF-8\n"
        with open('/etc/locale.gen', 'w') as file:
            file.writelines(lines)
            print('[+] /etc/locale.gen')

        locale = "LANG=en_US.UTF-8"
        conf = '/etc/locale.conf'
        with open(conf, 'w') as file:
            file.write(locale)
            print('[+] /etc/locale.conf')

        cmd = subprocess.run([
                'locale-gen'
                ])
        if cmd.returncode == 0:
            print('[+] Locale-gen')
        else:
            print('[-] Locale-gen')
            exit(cmd.returncode)

    def logindelay(self):
        with open('/etc/pam.d/system-login', 'r') as file:
            lines = file.readlines()
        lines.insert(5, "auth       optional   pam_faildelay.so     delay=5000000")
        with open('/etc/pam.d/system-login', 'w') as file:
            file.writelines(lines)

    def watchdog_error(self):
        with open('/etc/systemd/system.conf', 'r') as file:
            lines = file.readlines()
        lines[34] = "RebootWatchdogSec=0\n"
        with open('/etc/systemd/system.conf', 'w') as file:
            file.writelines(lines)

    def initramfs(self):
        with open('/etc/mkinitcpio.conf', 'r') as file:
            lines = file.readlines()
        lines[6] = "MODULES=(btrfs)\n"
        lines[51] = "HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"
        with open('/etc/mkinitcpio.conf', 'w') as file:
            file.writelines(lines)

    def mkinitcpio(self):
        cmd = subprocess.run([
                'mkinitcpio',
                '-p',
                'linux-hardened'
                ])
        if cmd.returncode == 0:
            print('[+] Mkinitcpio')
        else:
            print('[-] Mkinitcpio')
            exit(cmd.returncode)


class Bootloader():

    """Docstring for ClassName"""

    def grub_opt(self):
        # Root partition UUID
        cmd = subprocess.run(['blkid'], stdout=subprocess.PIPE)
        regex = r'"([^"]*)"'
        matches = re.findall(regex, cmd.stdout.decode('utf-8'))
        uuid = matches[12]

        # /etc/default/grub
        with open('/etc/default/grub', 'r') as file:
            lines = file.readlines()
        lines[5] = f'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID={uuid}:cryptroot:allow-discards root=/dev/mapper/cryptroot video=1920x1080"\n'
        lines[9] = f'GRUB_PRELOAD_MODULES="part_gpt part_msdos luks2"\n'
        lines[12] = f'GRUB_ENABLE_CRYPTODISK=y\n'
        with open('/etc/default/grub', 'w') as file:
            file.writelines(lines)

    def grub_install(self):
        cmd = subprocess.run([
                'grub-install',
                '--target=x86_64-efi',
                '--bootloader-id=GRUB',
                '--efi-directory=/boot'
                ])
        if cmd.returncode != 0:
            print('[-] GRUB install')
            exit(cmd.returncode)

    def grub_cfg(self):
        cmd = subprocess.run([
                'grub-mkconfig',
                '-o',
                '/boot/grub/grub.cfg'
                ])
        if cmd.returncode != 0:
            print('[-] GRUB config')
            exit(cmd.returncode)


class Btrfs():

    """Docstring for Btrfs"""

    def btrfs_snapper(self):
        cmd = subprocess.run([
                'snapper',
                '--no-dbus',
                '-c',
                'home',
                'create-config',
                '/home'
                ])
        if cmd.returncode == 0:
            print('[+] BTRFS-Snapper')
        else:
            print('[-] BTRFS-Snapper')
            exit(cmd.returncode)


class Services():

    """Docstring for Services"""

    def services(self):
        services = [
            'ntpd.service',
            'sshd.service',
            'NetworkManager',
            'fstrim.timer',
            'vboxservice.service'
            ]
        for service in services:
            cmd = subprocess.run([
                    'systemctl',
                    'enable',
                    service
                    ])
            if cmd.returncode == 0:
                print(f'[+] Service {service}')
            else:
                print(f'[-] Service {service}')
                exit(cmd.returncode)

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

l = Locale()
l.loadkeys()
l.keymap()

a = Useradd()
a.root_pw()
a.user_add()
a.user_pw()
a.user_group()
a.hostname()
a.hosts()
a.sudoers()

c = Sysadmin()
c.locale()
c.logindelay()
c.watchdog_error()
c.initramfs()
c.mkinitcpio()

g = Bootloader()
g.grub_opt()
g.grub_install()
g.grub_cfg()

b = Btrfs()
b.btrfs_snapper()

s = Services()
s.services()
# s.services_dmi()
