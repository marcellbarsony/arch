import logging
import re
import subprocess


"""
Locale
https://wiki.archlinux.org/title/locale
"""

def locale():
    file = "/etc/locale.gen"
    pattern_1 = re.compile(r"^#en_US\.UTF-8\sUTF-8")
    pattern_2 = re.compile(r"^#ja_JP\.UTF-8\sUTF-8")
    pattern_3 = re.compile(r"^#zh_CN\.UTF-8\sUTF-8")
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return

    updated_lines = []
    for line in lines:
        if pattern_1.match(line):
            updated_lines.append("en_US.UTF-8 UTF-8\n")
        elif pattern_2.match(line):
            updated_lines.append("ja_JP.UTF-8 UTF-8\n")
        elif pattern_3.match(line):
            updated_lines.append("zh_CN.UTF-8 UTF-8\n")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(updated_lines)
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)

def conf():
    locale = "LANG=en_US.UTF-8"
    file = "/etc/locale.conf"
    try:
        with open(file, "a") as f:
            f.write(f"{locale}\n")
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)

def gen():
    cmd = ["locale-gen"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.warning("%s\n%s", cmd, err)
        return
    else:
        logging.info(cmd)
