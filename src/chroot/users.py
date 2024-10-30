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
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: ROOT :: ", err)
        sys.exit(1)
    else:
        logging.info(f"root:{root_pw} | {cmd}")
        print(":: [+] :: ROOT :: ", cmd)


"""
Docstring for user setup
https://wiki.archlinux.org/title/users_and_groups
"""

def user_add(user: str):
    cmd = f"useradd -m {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: USER :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: USER :: ", cmd)

def user_password(user: str, user_pw: str):
    cmd = "chpasswd --crypt-method SHA512"
    try:
        subprocess.run(cmd, shell=True, check=True, input=f"{user}:{user_pw}".encode())
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: USER :: ", err)
        sys.exit(1)
    else:
        logging.info(f"{user}:{user_pw} | {cmd}")
        print(":: [+] :: USER :: ", cmd)

def user_group(user: str):
    groups = "wheel,audio,video,optical,storage,vboxusers,vboxsf"
    cmd = f"usermod -aG {groups} {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: USER :: ", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: USER :: ", cmd)
