import logging
import subprocess
import sys


def time_zone(zone: str):
    cmd = f"timedatectl set-timezone {zone}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] INIT :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] INIT :: ", cmd)

def loadkeys(keys: str):
    cmd = f"loadkeys {keys}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] INIT :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] INIT :: ", cmd)

def keymaps(keymap: str):
    cmd = f"localectl set-keymap --no-convert {keymap}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] INIT :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] INIT :: ", cmd)
