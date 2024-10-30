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
        print(":: [-] :: PACMAN :: Read :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

    pattern_1 = re.compile(r"^#\sMisc\soptions")
    # TODO: Test pattern_2
    pattern_2 = re.compile(r"^#\[multilib\]\n#Include\s=s\\/etc\/pacman.d\/mirrorlist")

    updated_lines = []
    insert_lines = [
        "Color\n",
        "ILoveCandy\n",
        "VerbosePkgLists\n",
        "ParallelDownloads=5\n",
    ]

    for line in lines:
        if pattern_1.match(line):
            updated_lines.extend(insert_lines)

        # TODO: Test pattern_2
        if pattern_2.match(line):
            updated_lines.append("Include = /etc/pacman.d/mirrorlist\n")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        print(":: [-] :: PACMAN :: Write :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)
    else:
        print(":: [+] :: PACMAN :: Write :: ", file)
        logging.info(file)
