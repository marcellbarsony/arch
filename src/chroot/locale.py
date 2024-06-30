import logging
import subprocess
import sys


"""
Docstring for Locale
https://wiki.archlinux.org/title/locale
"""

def locale():
    file = "/etc/locale.gen"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error(f"Reading {file}\n{err}")
        print(f":: [-] LOCALE :: Reading {file}", err)
        sys.exit(1)

    lines[170] = "en_US.UTF-8 UTF-8\n"
    lines[295] = "ja_JP.UTF-8 UTF-8\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] LOCALE :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] LOCALE :: ", file)

def conf():
    locale = "LANG=en_US.UTF-8"
    file = "/etc/locale.conf"
    try:
        with open(file, "a") as f:
            f.write(f"{locale}\n")
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] LOCALE :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] LOCALE :: ", file)

def gen():
    cmd = "locale-gen"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] LOCALE :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] LOCALE :: ", cmd)
