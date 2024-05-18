import logging
import subprocess
import sys


def time_zone(zone: str):
    cmd = f"timedatectl set-timezone {zone}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] INIT :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] INIT :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def loadkeys(keys: str):
    cmd = f"loadkeys {keys}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] INIT :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] INIT :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def keymaps(keymap: str):
    cmd = f"localectl set-keymap --no-convert {keymap}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] INIT :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] INIT :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
