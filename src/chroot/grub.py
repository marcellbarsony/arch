import re
import sys
import subprocess
from .dmi import DMI


class Grub():

    """Docstring for GRUB"""

    @staticmethod
    def get_uuid():
        _, _, device_root = DMI().disk()
        out = subprocess.check_output(['blkid']).decode('utf-8')
        for line in out.splitlines():
            if line.startswith(device_root):
                match = re.search(r'UUID="([\w-]+)"', line)
                if match:
                    uuid = match.group(1)
                    return uuid
                else:
                    pass

    @staticmethod
    def config(resolution: str):
        uuid = Grub().get_uuid()
        grub_cfg = '/etc/default/grub'
        try:
            with open(grub_cfg, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print(f'[-] Read {grub_cfg}', err)
            sys.exit(1)
        # Configuration
        lines[3] = 'GRUB_TIMEOUT=5\n'
        # Btrfs & Encryption
        lines[5] = f'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID={uuid}:cryptroot:allow-discards root=/dev/mapper/cryptroot video={resolution}"\n'
        lines[9] = f'GRUB_PRELOAD_MODULES="part_gpt part_msdos luks2"\n'
        lines[12] = f'GRUB_ENABLE_CRYPTODISK=y\n'
        # Colors
        lines[41] = f'GRUB_COLOR_NORMAL="white/black"\n'
        lines[42] = f'GRUB_COLOR_HIGHLIGHT="white/black"\n'
        try:
            with open(grub_cfg, 'w') as file:
                file.writelines(lines)
            print(f'[+] Write {grub_cfg}')
        except Exception as err:
            print(f'[-] Write {grub_cfg}', err)
            sys.exit(1)

    @staticmethod
    def install(secureboot: str, efi_directory: str):
        if secureboot:
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory} --modules="tpm" --disable-shim-lock'
        else:
            cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB install')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB install', err)
            sys.exit(1)

    @staticmethod
    def password(grub_password: str, user: str):
        pbkdf2_hash = ''
        cmd = f'grub-mkpasswd-pbkdf2'
        sin = f'{grub_password}\n{grub_password}'
        try:
            out = subprocess.run(cmd, shell=True, check=True, input=sin.encode(), stdout=subprocess.PIPE)
            pbkdf2_hash = out.stdout.decode('utf-8')[67:].strip()
            print(f'[+] GRUB password')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB password', err)

        file = '/etc/grub.d/00_header'
        content = f'\ncat << EOF\nset superusers="{user}"\npassword_pbkdf2 {user} {pbkdf2_hash}\nEOF'
        with open(file, 'a') as f:
            f.write(content)

    @staticmethod
    def mkconfig():
        cmd = f'grub-mkconfig -o /boot/grub/grub.cfg'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] GRUB config')
        except subprocess.CalledProcessError as err:
            print(f'[-] GRUB config', err)
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
