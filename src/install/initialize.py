import logging
import subprocess
import sys


def time_zone():
    timezone = "Europe/Amsterdam"
    cmd = f"timedatectl set-timezone {timezone}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f":: [+] Timezone {timezone}")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] Timezone", {err})
        sys.exit(1)

def loadkeys(keys: str):
    cmd = f"loadkeys {keys}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f":: [+] Loadkeys <{keys}>")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(f":: [-] loadkeys <{keys}>", {err})
        sys.exit(1)

def keymaps(keymap: str):
    cmd = f"localectl set-keymap --no-convert {keymap}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(f":: [+] Keymaps <{keymap}>")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(f":: [-] Keymaps <{keymap}>", {err})
        sys.exit(1)
