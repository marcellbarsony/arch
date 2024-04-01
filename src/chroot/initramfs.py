import sys
import subprocess


"""
Docstring for Initramfs & KMS
https://wiki.archlinux.org/mkinitcpio
https://wiki.archlinux.org/Kernel_mode_setting
"""

def kernel_mode_setting() -> str:
    """
    TODO: 2.1 Early KMS start
    """
    kms = ""
    with open("/proc/cpuinfo") as file:
        lines = file.readlines()
        for line in lines:
            if line.startswith("vendor_id"):
                _, kms = line.split(":")
                kms = kms.strip()

    if "AuthenticAMD" in kms:
        return "amdgpu"
    if "GenuineIntel" in kms:
        return "i915"
    else:
        return "vboxvideo"

def initramfs():
    kms = kernel_mode_setting()
    conf = "/etc/mkinitcpio.conf"
    try:
        with open(conf, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(f"[-] Read {conf}", err)
        sys.exit(1)

    lines[6] = f"MODULES=(btrfs {kms})\n"
    lines[51] = "HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"
    try:
        with open(conf, "w") as file:
            file.writelines(lines)
        print(f"[+] Mkinitcpio.conf {conf}")
    except Exception as err:
        print(f"[-] Mkinitcpio.conf {conf}", err)
        sys.exit(1)

def mkinitcpio():
    cmd = "mkinitcpio -p linux-hardened"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print("[+] Mkinitcpio: linux-hardened")
    except subprocess.CalledProcessError as err:
        print("[-] Mkinitcpio: linux-hardened", err)
        sys.exit(1)
