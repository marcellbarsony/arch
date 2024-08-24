import logging
import re
import sys
import subprocess
import textwrap


"""Docstring for GRUB"""

def get_uuid(device_root: str):
    out = subprocess.check_output(["blkid"]).decode("utf-8")
    for line in out.splitlines():
        if line.startswith(device_root):
            match = re.search(r'UUID="([\w-]+)"', line)
            if match:
                uuid = match.group(1)
                logging.info(uuid)
                return uuid

def setup(uuid):
    file = "/etc/default/grub"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] GRUB :: ", err)
        sys.exit(1)

    # Timeout
    lines[3] = "GRUB_TIMEOUT=0\n"
    lines[16] = "GRUB_TIMEOUT_STYLE=countdown"
    # Btrfs & Encryption
    lines[5] = f'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID={uuid}:cryptroot:allow-discards root=/dev/mapper/cryptroot"\n'
    lines[9] = f'GRUB_PRELOAD_MODULES="part_gpt part_msdos luks2"\n'
    lines[12] = f"GRUB_ENABLE_CRYPTODISK=y\n"
    # Colors
    lines[41] = f'GRUB_COLOR_NORMAL="white/black"\n'
    lines[42] = f'GRUB_COLOR_HIGHLIGHT="white/black"\n'
    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] GRUB :: Write ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] GRUB :: Write ", file)

def install(secureboot: str, efi_directory: str):
    if secureboot:
        cmd = f'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory}"  --modules="tpm" --disable-shim-lock'
    else:
        cmd = f"grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory={efi_directory}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] GRUB :: Install ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] GRUB :: Install")

def password(grub_password: str, user: str):
    pbkdf2_hash = ""
    cmd = f"grub-mkpasswd-pbkdf2"
    stdin = f"{grub_password}\n{grub_password}"
    try:
        out = subprocess.run(cmd, shell=True, check=True, input=stdin.encode(), stdout=subprocess.PIPE)
        pbkdf2_hash = out.stdout.decode("utf-8")[67:].strip()
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] GRUB :: Password :: ", err)
    else:
        logging.info(cmd)
        print(":: [+] GRUB :: Password")

    file = "/etc/grub.d/00_header"
    content = textwrap.dedent(
        f"""\
        cat << EOF
        set superusers="{user}"
        password_pbkdf2 {user} {pbkdf2_hash}
        EOF
        """
    )
    with open(file, "a") as f:
        f.write(content)
    logging.info(f"{file}\n{content}")

def mkconfig():
    cmd = "grub-mkconfig -o /boot/grub/grub.cfg"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] GRUB :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] GRUB :: ", cmd)

def secure_boot():
    # https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot
    # https://www.reddit.com/r/archlinux/comments/10pq74e/my_easy_method_for_setting_up_secure_boot_with/

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
