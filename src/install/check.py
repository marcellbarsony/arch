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
        print(":: [-] :: CHECK :: Boot mode [BIOS]")
        sys.exit(1)
    else:
        logging.info("UEFI")
        print(":: [+] :: CHECK :: Boot mode [UEFI]")

def network(ip: str, port: str):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect((ip, int(port)))
    except socket.error:
        logging.error("Disconnected")
        print(":: [-] :: CHECK :: Network connection ::", socket.error)
        sys.exit(1)
    else:
        logging.info("Connected")
        print(":: [+] :: CHECK :: Network connection")
