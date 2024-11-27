import logging
import re
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
        logging.error(f"{file}\n{err}")
        print(":: [-] :: PACMAN :: Read ::", err)
        sys.exit(1)

    pattern_1 = re.compile(r"^#\sMisc\soptions")
    pattern_2 = re.compile(r"^#\[multilib\]")
    pattern_3 = re.compile(r"^#Include.*")

    insert_lines = [
        "Color\n",
        "ILoveCandy\n",
        "VerbosePkgLists\n",
        "ParallelDownloads=5\n",
    ]

    multilib_section = False
    updated_lines = []

    for line in lines:
        if pattern_1.match(line):
            updated_lines.append(line)
            updated_lines.extend(insert_lines)
        elif pattern_2.match(line):
            updated_lines.append("[multilib]\n")
            multilib_section = True
        elif multilib_section and pattern_3.match(line):
            updated_lines.append(line.lstrip('#').lstrip())
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(updated_lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: PACMAN :: Write ::", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] :: PACMAN :: Write ::", file)
