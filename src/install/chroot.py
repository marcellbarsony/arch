import logging
import os
import shutil
import subprocess
import sys


"""Change root into new system"""

def copy_sources(scr_src: str, scr_dst: str, cfg_src: str, cfg_dst: str):
    try:
        shutil.copytree(scr_src, scr_dst)
        logging.info(f"copytree: {scr_src} >> {scr_dst}")
        shutil.copy(cfg_src, cfg_dst)
        logging.info(f"copy: {scr_src} >> {scr_dst}")
        os.chmod("/mnt/temporary/main.py", 0o755)
        logging.info("chmod 0x755 /mnt/temporary/main.py")
        print(":: [+] CHROOT: Copy script")
    except FileExistsError as err:
        logging.info("file already exists")
        pass
    except Exception as err:
        logging.error(err)
        print(":: [-] CHROOT: Copy script", err)
        sys.exit(1)

def chroot():
    os.system("clear")
    cmd = "arch-chroot /mnt ./temporary/main.py"
    try:
        subprocess.run(cmd, shell=True, check=True)
        logging.info(cmd)
        print(":: [+] Installation successful")
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] Chroot", err)
        sys.exit(1)

def clear(scr_dst: str, cfg_dst: str):
    shutil.rmtree(scr_dst)
    logging.info(f"rmtree {scr_dst}")
    os.remove(cfg_dst)
    logging.info(f"remove {cfg_dst}")
