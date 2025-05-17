import logging
import shutil


"""
OpenSSH setup
https://wiki.archlinux.org/title/OpenSSH
"""

def bashrc(user: str):
    src = "/temporary/ssh/.bashrc"
    dst = f"/home/{user}/.bashrc"
    shutil.copy2(src, dst)
    logging.info(f"Copy {src} >> {dst}")
