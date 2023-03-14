import socket
import subprocess
import sys


class Network():

    """Network settings"""

    @staticmethod
    def wifi_activate(status):
        cmd = f'sudo nmcli radio wifi {status}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print('[+] Wi-Fi activate')
        except subprocess.CalledProcessError as err:
            print('[-]', repr(err))
            sys.exit(1)

    @staticmethod
    def wifi_connect(ssid, password):
        cmd = f'nmcli device wifi connect {ssid} password {password}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print('[+] Wi-Fi connect')
        except subprocess.CalledProcessError as err:
            print('[-]', repr(err))
            pass

    @staticmethod
    def check(ip, port):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect((ip, int(port)))
            print('[+] Internet connection')
            return True
        except socket.error:
            print('[-] Internet connection', socket.error)
            return False
