import logging
import subprocess


"""
DMI table decoder
https://man.archlinux.org/man/dmidecode.8.en
"""

def check() -> str:
    cmd = ["dmidecode", "-s", "system-product-name"]
    out = subprocess.run(cmd, check=True, capture_output=True)
    logging.info(cmd)
    if "VirtualBox" in str(out.stdout):
        return "vbox"
    if "VMware Virtual Platform" in str(out.stdout):
        return "vmware"
    if "Intel(R) Corporation" in str(out.stdout):
        return "intel"
    else:
        return "pm"

def disk(dmidecode: str) -> tuple[str, str, str]:
    # lsblk -p -n -l -o NAME,SIZE -e 7,11
    logging.info(dmidecode)
    if dmidecode == "pm":
        device = "/dev/nvme0n1"
        device_efi = "/dev/nvme0n1p1"
        device_root = "/dev/nvme0n1p2"
        return device, device_efi, device_root
    else:
        device = "/dev/sda"
        device_efi = "/dev/sda1"
        device_root = "/dev/sda2"
        return device, device_efi, device_root
