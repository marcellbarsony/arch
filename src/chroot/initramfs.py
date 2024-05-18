import logging
import sys
import subprocess


"""
Docstring for Initramfs & KMS
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

    if "AuthenticAMD" in kms:
        return "amdgpu"
    if "GenuineIntel" in kms:
        return "i915"
    else:
        return "vboxvideo"

def initramfs(kms: str):
    file = "/etc/mkinitcpio.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print(":: [-] INITRAMFS :: ", err)
        logging.error(f"Reading {file}\n{err}")
        sys.exit(1)

    lines[6] = f"MODULES=(btrfs {kms})\n"
    lines[54] = "HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
        print(":: [+] INITRAMFS :: ", file)
        logging.info(f"{file}")
    except Exception as err:
        print(":: [-] INITRAMFS :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

def mkinitcpio():
    cmd = "mkinitcpio -p linux"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] INITRAMFS :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] INITRAMFS :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
