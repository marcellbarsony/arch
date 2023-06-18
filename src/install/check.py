import os
import socket
import sys


class Check():

    """Check install requirements"""

    @staticmethod
    def boot_mode():
        path = '/sys/firmware/efi/efivars/'
        if os.path.exists(path):
            print('[+] Boot mode <UEFI>')
        else:
            print('[-] Boot mode <BIOS>')
            sys.exit(1)

    @staticmethod
    def network(ip: str, port: str):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect((ip, int(port)))
            print('[+] Network connection')
        except socket.error:
            print('[-] Network connection', socket.error)
            sys.exit(1)
