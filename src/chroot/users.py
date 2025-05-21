import logging
import subprocess
import sys


"""
Root user setup
https://man.archlinux.org/man/chpasswd.8.en
"""

def root_password(root_pw: str):
    cmd = ["chpasswd", "--crypt-method", "SHA512"]
    try:
        subprocess.run(cmd, check=True, input=f"root:{root_pw}".encode())
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(f"root:%s | %s ", root_pw, cmd)


"""
User setup
https://wiki.archlinux.org/title/users_and_groups
"""

def user_add(user: str):
    cmd = ["useradd", "-m", user]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def user_password(user: str, user_pw: str):
    cmd = ["chpasswd", "--crypt-method", "SHA512"]
    try:
        subprocess.run(cmd, check=True, input=f"{user}:{user_pw}".encode())
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info("%s:%s | %s", user, user_pw, cmd)

def user_group_create():
    cmd = ["groupadd", "vboxusers"]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def user_group_add(user: str):
    groups = "wheel,audio,video,optical,storage,vboxusers"
    cmd = ["usermod", "-aG", groups, user]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)
