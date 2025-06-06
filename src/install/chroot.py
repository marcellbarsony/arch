import logging
import os
import shutil
import subprocess
import sys


def copy(scr_src: str, scr_dst: str, cfg_src: str, cfg_dst: str):
    """
    Copy files for chroot phrase
    """
    try:
        shutil.copytree(scr_src, scr_dst)
        shutil.copy(cfg_src, cfg_dst)
        os.chmod("/mnt/temporary/main.py", 0o755)
    except FileExistsError as err:
        logging.warning(err)
        pass
    except Exception as err:
        logging.error(err)
        sys.exit(1)
    else:
        logging.info(f"copytree: %s >> %s", scr_src, scr_dst)
        logging.info(f"copy: %s >> %s", scr_src, scr_dst)
        logging.info("chmod 0x755 /mnt/temporary/main.py")

def chroot():
    """
    Chroot into the new system & Launch chroot script
    https://wiki.archlinux.org/title/Installation_guide#Chroot
    """
    os.system("clear")
    cmd = ["arch-chroot", "/mnt", "./temporary/main.py"]
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as err:
        logging.error("%s\n%s", cmd, err)
        sys.exit(1)
    else:
        logging.info(cmd)

def clear(scr_dst: str, cfg_dst: str):
    try:
        shutil.rmtree(scr_dst)
        os.remove(cfg_dst)
    except Exception as err:
        logging.warning(err)
        return
    else:
        logging.info(f"rmtree {scr_dst}")
        logging.info(f"remove {cfg_dst}")
