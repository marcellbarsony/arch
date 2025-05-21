import logging
import os
import socket
import sys


def boot_mode():
    """
    Verify the boot mode
    https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
    """
    os.system("clear")
    path = "/sys/firmware/efi/efivars/"
    if not os.path.exists(path):
        logging.error("BIOS")
        sys.exit(1)
    else:
        logging.info("UEFI")

def network(ip: str, port: str):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect((ip, int(port)))
    except socket.error:
        logging.error("disconnected")
        sys.exit(1)
    else:
        logging.info("connected")
