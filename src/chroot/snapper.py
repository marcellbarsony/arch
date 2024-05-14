import logging
import subprocess
import sys


"""
Docstring for Snapper
https://wiki.archlinux.org/title/snapper
"""

def config_init():
    cmd = "snapper --no-dbus -c home create-config /home"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS: Snapper config init")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS: Snapper config init", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def config_set():
    cfgs = [
        "TIMELINE_CREATE=no",
        "TIMELINE_LIMIT_HOURLY=0"
        "TIMELINE_LIMIT_DAILY=1",
        "TIMELINE_LIMIT_WEEKLY=1",
        "TIMELINE_LIMIT_MONTHLY=0",
        "TIMELINE_LIMIT_YEARLY=0",
    ]
    for cfg in cfgs:
        cmd = f"snapper -c home set-config {cfg}"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(":: [+] BTRFS: Snapper config set")
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(":: [-] BTRFS: Snapper config set", err)
            logging.error(f"{cmd}\n{err}")
            sys.exit(1)

def systemd_services():
    cmds = [
        "systemctl enable snapper-timeline.timer",
        "systemctl enable snapper-cleanup.timer"
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(":: [+] BTRFS: Snapper service")
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(":: [-] BTRFS: Snapper service", err)
            logging.error(f"{cmd}\n{err}")
            sys.exit(1)
