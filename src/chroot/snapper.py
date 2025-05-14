import logging
import re
import subprocess
import sys


"""
Docstring for Snapper
https://wiki.archlinux.org/title/snapper
"""

def config_init(btrfs_cfg: str):
    cmd = ["snapper", "--no-dbus", "-c", btrfs_cfg, "create-config", f"/{btrfs_cfg}"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: BTRFS ::", err)
    else:
        logging.info(cmd)
        print(":: [+] :: BTRFS ::", cmd)

def config_set(btrfs_cfg: str):
    file = f"/etc/snapper/configs/{btrfs_cfg}"
    pattern_1 = re.compile(r"^TIMELINE_CREATE=")
    pattern_2 = re.compile(r"^TIMELINE_LIMIT_HOURLY=")
    pattern_3 = re.compile(r"^TIMELINE_LIMIT_DAILY=")
    pattern_4 = re.compile(r"^TIMELINE_LIMIT_WEEKLY=")
    pattern_5 = re.compile(r"^TIMELINE_LIMIT_MONTHLY=")
    pattern_6 = re.compile(r"^TIMELINE_LIMIT_QUARTERLY=")
    pattern_7 = re.compile(r"^TIMELINE_LIMIT_YEARLY=")

    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error(f"Reading {file}\n{err}")
        print(f":: [-] :: BTRFS :: Reading {file} ::", err)
        sys.exit(1)

    updated_lines = []
    for line in lines:
        if pattern_1.match(line):
            updated_lines.append("TIMELINE_CREATE=no\n")
        elif pattern_2.match(line):
            updated_lines.append("TIMELINE_LIMIT_HOURLY=0\n")
        elif pattern_3.match(line):
            updated_lines.append("TIMELINE_LIMIT_DAILY=0\n")
        elif pattern_4.match(line):
            updated_lines.append("TIMELINE_LIMIT_WEEKLY=0\n")
        elif pattern_5.match(line):
            updated_lines.append("TIMELINE_LIMIT_MONTHLY=0\n")
        elif pattern_6.match(line):
            updated_lines.append("TIMELINE_LIMIT_QUARTERLY=0\n")
        elif pattern_7.match(line):
            updated_lines.append("TIMELINE_LIMIT_YEARLY=0\n")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(updated_lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: BTRFS ::", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] :: BTRFS ::", file)
