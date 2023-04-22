import socket
import subprocess
import sys


class Network():

    """Network settings"""

    @staticmethod
    def wifiConnect(status, ssid, password):
        cmd_list = [f'sudo nmcli radio wifi {status}',
                    f'nmcli device wifi connect {ssid} password {password}']

        for cmd in cmd_list:
            try:
                subprocess.run(cmd, shell=True, check=True)
                print('[+] Wi-Fi Connection')
            except subprocess.CalledProcessError as err:
                print('[-]', repr(err))
                sys.exit(1)

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
