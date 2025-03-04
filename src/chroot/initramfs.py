import logging
import sys
import subprocess


"""
Initramfs & KMS config
https://wiki.archlinux.org/mkinitcpio
https://wiki.archlinux.org/Kernel_mode_setting
"""

def kernel_mode_setting() -> str:
    kms = ""
    with open("/proc/cpuinfo") as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("vendor_id"):
                _, kms = line.split(":")
                kms = kms.strip()
                logging.info(kms)

    match kms.lower():
        case "authenticamd":
            return "amdgpu"
        case "genuineintel":
            return "i915"
        case _:
            return "vboxvideo"

def initramfs(kms: str):
    file = "/etc/mkinitcpio.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error(f"Reading {file}\n{err}")
        print(":: [-] :: INITRAMFS ::", err)
        sys.exit(1)

    lines[6] = f"MODULES=(btrfs {kms})\n"
    lines[54] = "HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"

    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: INITRAMFS ::", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] :: INITRAMFS ::", file)

def mkinitcpio():
    cmd = "mkinitcpio -p linux"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: INITRAMFS ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: INITRAMFS ::", cmd)
