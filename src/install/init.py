import logging
import subprocess
import sys


def time_zone(zone: str):
    """
    Set time zone
    https://wiki.archlinux.org/title/Installation_guide#Update_the_system_clock
    """
    cmd = ["timedatectl", "set-timezone", zone]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def loadkeys(keys: str):
    """
    Load keys
    https://wiki.archlinux.org/title/Installation_guide#Set_the_console_keyboard_layout_and_font
    """
    cmd = ["loadkeys", keys]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def keymaps(keymap: str):
    cmd = ["localectl", "set-keymap", "--no-convert", keymap]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)
