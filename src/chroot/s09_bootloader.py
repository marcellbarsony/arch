import re
import sys
import subprocess


class Grub():

    """Docstring for Bootloader"""

    @staticmethod
    def config(resolution):
        # Root partition UUID
        cmd = 'blkid'
        try:
            out = subprocess.run(cmd, stdout=subprocess.PIPE)
            print(f'[+] GRUB: Root partition UUID')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB: Root partition UUID', err)
            sys.exit(1)

        regex = r'"([^"]*)"'
        matches = re.findall(regex, out.stdout.decode('utf-8'))
        uuid = matches[12]
        # /etc/default/grub
        grub_cfg = '/etc/default/grub'
        try:
            with open(grub_cfg, 'r') as file:
                lines = file.readlines()
            print(f'[+] Read {grub_cfg}')
        except Exception as err:
            print(f'[-] Read {grub_cfg}', err)
            sys.exit(1)

        lines[5] = f'GRUB_CMDLINE_LINUX_DEFAULT=" cryptdevice=UUID={uuid}:cryptroot:allow-discards root=/dev/mapper/cryptroot video={resolution}"\n'
        lines[9] = f'GRUB_PRELOAD_MODULES="part_gpt part_msdos luks2"\n'
        lines[12] = f'GRUB_ENABLE_CRYPTODISK=y\n'
        try:
            with open(grub_cfg, 'w') as file:
                file.writelines(lines)
            print(f'[+] Write {grub_cfg}')
        except Exception as err:
            print(f'[-] Write {grub_cfg}', err)
            sys.exit(1)

    @staticmethod
    def install(secureboot, efi_directory):
        if secureboot == True:
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory} --modulkes="tpm" --disable-shim-lock'
        else:
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory}'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB install')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB install', err)
            sys.exit(1)

    @staticmethod
    def password(grub_password):
        # TODO
        # grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')
        # echo "cat << EOF" >>/etc/grub.d/00_header
        # echo "set superusers=\"${username}\"" >>/etc/grub.d/00_header
        # echo "password_pbkdf2 ${username} ${grubpass}" >>/etc/grub.d/00_header
        # echo "EOF" >>/etc/grub.d/00_header
        pass

    @staticmethod
    def mkconfig():
        cmd = f'grub-mkconfig -o /boot/grub/grub.cfg'
        try:
            subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB config')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB config', err)
            sys.exit(1)

