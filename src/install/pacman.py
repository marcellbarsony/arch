import logging
import re
import subprocess
import sys


"""
Pacman config
https://wiki.archlinux.org/title/Pacman
"""

def config():
    config = "/etc/pacman.conf"
    try:
        with open(config, "r") as file:
            lines = file.readlines()
    except Exception as err:
        logging.error("%s\n%s", config, err)
        sys.exit(1)
    else:
        logging.info(config)

    pattern = re.compile(r"^#\sMisc\soptions")

    updated_lines = []
    insert_lines = [
        "ParallelDownloads=5\n",
        "ILoveCandy\n",
        "Color\n",
    ]

    for line in lines:
        updated_lines.append(line)
        if pattern.match(line):
            updated_lines.extend(insert_lines)

    try:
        with open(config, "w") as file:
            file.writelines(lines)
    except Exception as err:
        logging.error("%s\n%s", config, err)
        sys.exit(1)
    else:
        logging.info(config)

def mirrorlist():
    cmd = [
        "reflector",
        "--latest", "25",
        "--protocol", "https",
        "--connection-timeout", "5",
        "--sort", "rate",
        "--save", "/etc/pacman.d/mirrorlist"
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)


"""
Initialize Keyring config
https://wiki.archlinux.org/title/Pacman/
"""

def keyring_init():
    cmds = [
        ["pacman", "-Sy"],
        ["pacman", "-Sy", "--noconfirm", "archlinux-keyring"],
        ["pacman-key", "--init"],
        ["pacman-key", "--populate"]
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error("%s\n%s", cmd, err)
            pass
        else:
            logging.info(cmd)
