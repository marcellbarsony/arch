import logging
import os
import socket
import sys


def boot_mode():
    os.system("clear")
    path = "/sys/firmware/efi/efivars/"
    if os.path.exists(path):
        logging.info("UEFI")
        print(":: [+] CHECK :: Boot mode [UEFI]")
    else:
        logging.error("BIOS")
        print(":: [-] CHECK :: Boot mode [BIOS]")
        sys.exit(1)

def network(ip: str, port: str):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect((ip, int(port)))
    except socket.error:
        logging.error("Disconnected")
        print(":: [-] CHECK :: Network connection", socket.error)
        sys.exit(1)
    else:
        logging.info("Connected")
        print(":: [+] CHECK :: Network connection")
