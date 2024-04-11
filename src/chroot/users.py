import subprocess
import sys
import dmi


"""Docstring for root user setup"""

def root_password(root_pw: str):
    cmd = f"chpasswd --crypt-method SHA512"
    try:
        subprocess.run(cmd, shell=True, check=True, input=f"root:{root_pw}".encode())
        print("[+] Root password")
    except subprocess.CalledProcessError as err:
        print("[-] Root password", err)
        sys.exit(1)


"""
Docstring for user setup
https://wiki.archlinux.org/title/users_and_groups
"""

def user_add(user: str):
    cmd = f"useradd -m {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(f"[+] User add {user}")
    except subprocess.CalledProcessError as err:
        print(f"[-] User add {user}", err)
        sys.exit(1)

def user_password(user: str, user_pw: str):
    cmd = "chpasswd --crypt-method SHA512"
    try:
        subprocess.run(cmd, shell=True, check=True, input=f"{user}:{user_pw}".encode())
        print(f"[+] User password [{user}]")
    except subprocess.CalledProcessError as err:
        print(f"[-] User password [{user}]", err)
        sys.exit(1)

def user_group(user: str):
    groups = "wheel,audio,video,optical,storage,vboxusers"
    if dmi.check() == "vbox":
        groups += ",vboxsf"
    cmd = f"usermod -aG {groups} {user}"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print("[+] User group")
    except subprocess.CalledProcessError as err:
        print("[-] User group", err)
        sys.exit(1)
