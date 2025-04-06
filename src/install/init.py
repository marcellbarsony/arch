import logging
import subprocess
import sys


def time_zone(zone: str):
    """
    Set time zone
    https://wiki.archlinux.org/title/Installation_guide#Update_the_system_clock
    """
    cmd = f"timedatectl set-timezone {zone}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: INIT ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: INIT ::", cmd)

def loadkeys(keys: str):
    """
    Load keys
    https://wiki.archlinux.org/title/Installation_guide#Set_the_console_keyboard_layout_and_font
    """
    cmd = f"loadkeys {keys}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: INIT ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: INIT ::", cmd)

def keymaps(keymap: str):
    cmd = f"localectl set-keymap --no-convert {keymap}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: INIT ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: INIT ::", cmd)
