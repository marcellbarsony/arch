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
        print(f":: [-] LOCALE :: Reading {file}", err)
        logging.error(f"Reading {file}\n{err}")
        sys.exit(1)

    lines[170] = "en_US.UTF-8 UTF-8\n"
    lines[295] = "ja_JP.UTF-8 UTF-8\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
        print(":: [+] LOCALE :: ", file)
        logging.info(file)
    except Exception as err:
        print(":: [-] LOCALE :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

def conf():
    locale = "LANG=en_US.UTF-8"
    file = "/etc/locale.conf"
    try:
        with open(file, "a") as f:
            f.write(f"{locale}\n")
        print(":: [+] LOCALE :: ", file)
        logging.info(file)
    except Exception as err:
        print(":: [-] LOCALE :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

def gen():
    cmd = "locale-gen"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] LOCALE :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] LOCALE :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
