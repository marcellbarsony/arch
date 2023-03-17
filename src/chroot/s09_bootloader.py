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
            out = subprocess.run(cmd, shell=True, check=True, stdout=subprocess.PIPE)
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
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory} --modules="tpm" --disable-shim-lock'
        else:
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB install <')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB install', err)
            sys.exit(1)

    @staticmethod
    def secure_boot():
        # https://www.reddit.com/r/archlinux/comments/10pq74e/my_easy_method_for_setting_up_secure_boot_with/
        # https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot
        # Secured-core PCs only
        # Set Secure Boot mode to setup mode in UEFI settings

        # sudo pacman -S sbctl

        # Verify setup mode:
        # sudo sbctl status

        # Create custom Secure Boot keys:
        # sudo sbctl create-keys

        # Enroll custom keys:
        # sudo sbctl enroll-keys -m

        # Verify enrolled keys:
        # sudo sbctl status

        # Check which files need to be signed for Secure Boot to work:
        # sudo sbctl verify

        # Sign unsigned files:
        # sudo sbctl -s /path/to/file
        # sudo sbctl -s /efi/EFI/GRUB/grubx64.efi

        # Make immutable files mutable, then resign files again:
        # sudo chattr -i /sys/firmware/efi/efivars/<filename>

        # Check which files need to be signed for Secure Boot to work:
        # sudo sbctl verify

        # Enable Secure Boot in UEFI settings
        # Reboot

        # Verify Secure Boot
        # sbctl status

        pass

    @staticmethod
    def password(grub_password):
        print('[TODO] GRUB password')
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
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB config')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB config', err)
            sys.exit(1)

