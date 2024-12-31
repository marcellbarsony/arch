import logging
import os
import shutil
import subprocess
import sys


def copy(scr_src: str, scr_dst: str, cfg_src: str, cfg_dst: str):
    try:
        shutil.copytree(scr_src, scr_dst)
        shutil.copy(cfg_src, cfg_dst)
        os.chmod("/mnt/temporary/main.py", 0o755)
    except FileExistsError as err:
        logging.warning("File already exists:", err)
        pass
    except Exception as err:
        logging.error(err)
        print(":: [-] :: CHROOT :: Copy sources ::", err)
        sys.exit(1)
    else:
        logging.info(f"copytree: {scr_src} >> {scr_dst}")
        logging.info(f"copy: {scr_src} >> {scr_dst}")
        logging.info("chmod 0x755 /mnt/temporary/main.py")
        print(":: [+] :: CHROOT :: Copy script")

def chroot():
    os.system("clear")
    cmd = "arch-chroot /mnt ./temporary/main.py"
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: CHROOT ::", err)
        sys.exit(1)
    else:
        logging.info(cmd)
        print(":: [+] :: Installation successful")

def clear(scr_dst: str, cfg_dst: str):
    try:
        shutil.rmtree(scr_dst)
        os.remove(cfg_dst)
    except Exception as err:
        logging.error(err)
        print(":: [-] :: CLEAR-UP :: Copy sources ::", err)
        sys.exit(1)
    else:
        logging.info(f"rmtree {scr_dst}")
        logging.info(f"remove {cfg_dst}")
