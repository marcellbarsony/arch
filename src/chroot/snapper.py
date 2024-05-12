import subprocess
import sys


"""
Docstring for Snapper
https://wiki.archlinux.org/title/snapper
"""

def config_init():
    """https://wiki.archlinux.org/title/snapper#Creating_a_new_configuration"""
    cmd = "snapper --no-dbus -c home create-config /home"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] BTRFS Snapper config init")
    except subprocess.CalledProcessError as err:
        print(":: [-] BTRFS Snapper config init", err)
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
            print(":: [+] BTRFS Snapper config set")
        except subprocess.CalledProcessError as err:
            print(":: [-] BTRFS Snapper config set", err)
            sys.exit(1)

def systemd_services():
    """https://wiki.archlinux.org/title/snapper#Enable/disable"""
    cmds = [
        "systemctl enable snapper-timeline.timer",
        "systemctl enable snapper-cleanup.timer"
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(":: [+] BTRFS Snapper service")
        except subprocess.CalledProcessError as err:
            print(":: [-] BTRFS Snapper service", err)
            sys.exit(1)
