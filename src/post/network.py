import logging
import socket
import subprocess
import sys


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class WiFi():

    """WiFi settings"""

    def toggle(self, status: str) -> None:
        cmd = f'sudo nmcli radio wifi {status}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            print('most')
            logger.info(f'Wi-Fi status: {status}')
        except subprocess.CalledProcessError as err:
            print(repr(err))
            sys.exit(1)

    def connect(self, ssid, password):
        cmd = f'nmcli device wifi connect {ssid} password {password}'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f'Wi-Fi connected {ssid}')
        except subprocess.CalledProcessError as err:
            print(repr(err))
            pass

class Network():

    """Network settings"""

    def check(self, ip: str, port: str) -> bool:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect((ip, int(port)))
            logger.info('Network: Connected')
            return True
        except socket.error:
            logger.info('Network: Disconnected')
            print(socket.error)
            return False
