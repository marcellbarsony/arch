import logging
import subprocess
import sys


"""
Docstring for root user setup
https://man.archlinux.org/man/chpasswd.8.en
"""

def root_password(root_pw: str):
    cmd = f"chpasswd --crypt-method SHA512"
    try:
        subprocess.run(cmd, shell=True, check=True, input=f"root:{root_pw}".encode())
        print(":: [+] ROOT :: ", cmd)
        logging.info(f"root:{root_pw} | {cmd}")
    except subprocess.CalledProcessError as err:
        print(":: [-] ROOT :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)


"""
Docstring for user setup
https://wiki.archlinux.org/title/users_and_groups
"""

def user_add(user: str):
    cmd = f"useradd -m {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] USER :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] USER :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def user_password(user: str, user_pw: str):
    cmd = "chpasswd --crypt-method SHA512"
    try:
        subprocess.run(cmd, shell=True, check=True, input=f"{user}:{user_pw}".encode())
        print(":: [+] USER :: ", cmd)
        logging.info(f"{user}:{user_pw} | {cmd}")
    except subprocess.CalledProcessError as err:
        print(":: [-] USER :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def user_group(user: str, dmi: str):
    groups = "wheel,audio,video,optical,storage,vboxusers"
    if dmi == "vbox":
        groups += ",vboxsf"
    cmd = f"usermod -aG {groups} {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] USER :: ", cmd)
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] USER :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)
