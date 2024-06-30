import logging
import subprocess
import sys


"""Initialize Pacman config"""

def config():
    config = "/etc/pacman.conf"
    try:
        with open(config, "r") as file:
            lines = file.readlines()
    except Exception as err:
        logging.error(f"{config}\n{err}")
        print(f":: [-] Read {config} :: ", err)
        sys.exit(1)
    else:
        logging.info(config)

    lines.insert(36, f"ParallelDownloads=5\n")
    lines[37] = f"ILoveCandy\n"
    lines[38] = f"Color\n"

    try:
        with open(config, "w") as file:
            file.writelines(lines)
    except Exception as err:
        logging.error(f"{config}\n{err}")
        print(":: [-] PACMAN :: Write ", err)
        sys.exit(1)
    else:
        logging.info(config)
        print(":: [+] PACMAN :: Write ", config)

def mirrorlist():
    cmd = f"reflector \
        --latest 25 \
        --protocol https \
        --connection-timeout 5 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist"
    try:
        print(":: [i] PACMAN :: Updating mirrorlist...")
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] PACMAN :: Mirrorlist :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] PACMAN :: Mirrorlist")


"""
Initialize Keyring config
https://wiki.archlinux.org/title/Pacman/
"""

def keyring_init():
    cmds = [
        "pacman -Sy",
        "pacman -Sy --noconfirm archlinux-keyring",
        "pacman-key --init",
        # "pacman-key --refresh-keys",
        # "gpg --refresh-keys",
        "pacman-key --populate"
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] PACMAN :: Keyring :: ", err)
            pass
        else:
            logging.info(cmd)
            print(":: [+] PACMAN :: ", cmd)
