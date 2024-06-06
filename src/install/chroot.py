import logging
import os
import shutil
import subprocess
import sys


def copy_sources(scr_src: str, scr_dst: str, cfg_src: str, cfg_dst: str):
    try:
        shutil.copytree(scr_src, scr_dst)
        logging.info(f"copytree: {scr_src} >> {scr_dst}")
        shutil.copy(cfg_src, cfg_dst)
        logging.info(f"copy: {scr_src} >> {scr_dst}")
        os.chmod("/mnt/temporary/main.py", 0o755)
        print(":: [+] CHROOT :: Copy script")
        logging.info("chmod 0x755 /mnt/temporary/main.py")
    except FileExistsError as err:
        logging.warn("File already exists")
        pass
    except Exception as err:
        logging.error(err)
        print(":: [-] CHROOT :: Copy script :: ", err)
        sys.exit(1)

def chroot():
    os.system("clear")
    cmd = "arch-chroot /mnt ./temporary/main.py"
    try:
        subprocess.run(cmd, shell=True, check=True)
        print(":: [+] Installation successful")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] Chroot :: ", err)
        logging.error(f"{cmd}\n{err}")
        sys.exit(1)

def clear(scr_dst: str, cfg_dst: str):
    shutil.rmtree(scr_dst)
    logging.info(f"rmtree {scr_dst}")
    os.remove(cfg_dst)
    logging.info(f"remove {cfg_dst}")
