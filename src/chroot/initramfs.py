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
    with open("/proc/cpuinfo") as file:
        lines = file.readlines()
        for line in lines:
            if line.startswith("vendor_id"):
                _, kms = line.split(":")
                kms = kms.strip()

    if "AuthenticAMD" in kms:
        logging.info("AuthenticAMD (amdgpu)")
        return "amdgpu"
    if "GenuineIntel" in kms:
        logging.info("GenuineIntel (i915)")
        return "i915"
    else:
        logging.info("VirtualBox (vboxvideo)")
        return "vboxvideo"

def initramfs():
    kms = kernel_mode_setting()
    conf = "/etc/mkinitcpio.conf"
    try:
        with open(conf, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(f":: [-] Reading {conf}", err)
        logging.error(f"Reading {conf}\n{err}")
        sys.exit(1)

    lines[6] = f"MODULES=(btrfs {kms})\n"
    lines[53] = "HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"
    try:
        with open(conf, "w") as file:
            file.writelines(lines)
        print(f":: [+] INITRAMFS: {conf}")
        logging.info(f"{conf}")
    except Exception as err:
        print(f":: [-] INITRAMFS: {conf}", err)
        logging.error(f"{conf}\n{err}")
        sys.exit(1)

def mkinitcpio():
    cmd = "mkinitcpio -p linux"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] INITRAMFS: mkinitcpio")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] INITRAMFS: mkinitcpio", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
