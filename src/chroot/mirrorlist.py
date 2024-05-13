import shutil
import subprocess
import sys


"""
Update & back-up mirrolist
https://wiki.archlinux.org/title/Reflector
"""

def backup():
    src = "/etc/pacman.d/mirrorlist"
    dst = "/etc/pacman.d/mirrorlist.bak"
    shutil.copy2(src, dst)

def update():
    cmd = f"sudo reflector \
        --latest 25 \
        --protocol https \
        --connection-timeout 5 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist"
    try:
        print(":: [i] REFLECTOR: Updating Pacman mirrorlist...")
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] REFLECTOR: Mirrorlist update")
    except subprocess.CalledProcessError as err:
        print(":: [-] REFLECTOR: Mirorlist update", err)
        sys.exit(1)