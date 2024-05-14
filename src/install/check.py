import logging
import os
import socket
import sys


def boot_mode():
    os.system("clear")
    path = "/sys/firmware/efi/efivars/"
    if os.path.exists(path):
        print(":: [+] Boot mode <UEFI>")
        logging.info("UEFI")
    else:
        print(":: [-] Boot mode <BIOS>")
        logging.error("BIOS")
        sys.exit(1)

def network(ip: str, port: str):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect((ip, int(port)))
        print(":: [+] Network connection")
        logging.info("Connected")
    except socket.error:
        print(":: [-] Network connection", socket.error)
        logging.error("Disconnected")
        sys.exit(1)
