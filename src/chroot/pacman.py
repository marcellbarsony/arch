import logging
import sys


"""
Pacman configuration
https://wiki.archlinux.org/title/Pacman
"""

def config():
    config = "/etc/pacman.conf"
    try:
        with open(config, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(f"[-] PACMAN: Read {config}", err)
        logging.error(f"{config}\n{err}")
        sys.exit(1)

    lines[32] = "Color\n"
    lines[33] = "ILoveCandy\n"
    lines[35] = "VerbosePkgLists\n"
    lines[36] = "ParallelDownloads=5\n"
    lines[89] = "[multilib]\n"
    lines[90] = "Include = /etc/pacman.d/mirrorlist\n"
    try:
        with open(config, "w") as file:
            file.writelines(lines)
        print(f":: [+] PACMAN: Write {config}")
        logging.info(config)
    except Exception as err:
        print(f":: [-] PACMAN: Write {config}", err)
        logging.error(f"{config}\n{err}")
        sys.exit(1)
