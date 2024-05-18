import logging
import sys


"""
Pacman configuration
https://wiki.archlinux.org/title/Pacman
"""

def config():
    file = "/etc/pacman.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print("[-] PACMAN: Read ", file, err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

    lines[32] = "Color\n"
    lines[33] = "ILoveCandy\n"
    lines[35] = "VerbosePkgLists\n"
    lines[36] = "ParallelDownloads=5\n"
    lines[89] = "[multilib]\n"
    lines[90] = "Include = /etc/pacman.d/mirrorlist\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
        print(":: [+] PACMAN: ", file)
        logging.info(file)
    except Exception as err:
        print(":: [-] PACMAN: ", file, err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)
