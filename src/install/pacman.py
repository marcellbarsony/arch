import logging
import subprocess
import sys


"""Initialize Pacman config"""

def config():
    config = "/etc/pacman.conf"
    try:
        with open(config, "r") as file:
            lines = file.readlines()
            logging.info(config)
    except Exception as err:
        logging.error(f"{config}: {err}")
        print(f"[-] Read {config}", err)
        sys.exit(1)

    lines.insert(36, f"ParallelDownloads=5\n")
    lines[37] = f"ILoveCandy\n"
    lines[38] = f"Color\n"

    try:
        with open(config, "w") as file:
            file.writelines(lines)
        logging.info(config)
        print(f":: [+] PACMAN: Write {config}")
    except Exception as err:
        logging.error(f"{config}: {err}")
        print(f":: [-] PACMAN: Write {config}", err)
        sys.exit(1)

def mirrorlist():
    cmd = f"reflector \
    --latest 25 \
    --protocol https \
    --connection-timeout 5 \
    --sort rate \
    --save /etc/pacman.d/mirrorlist"
    try:
        print(":: [i] PACMAN: Updating mirrorlist...")
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        logging.info(cmd)
        print(":: [+] PACMAN: Mirrorlist")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}: {err}")
        print(f":: [-] PACMAN: Mirrorlist {err}")
        sys.exit(1)


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
            logging.info(cmd)
            print(":: [+] PACMAN: Arch keyring update")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(":: [-] PACMAN: Arch keyring update", err)
            pass
