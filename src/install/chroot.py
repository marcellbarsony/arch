import logging
import os
import shutil
import subprocess
import sys


class Chroot():

    """Change root into new system"""

    def __init__(self, current_dir: str):
        self.current_dir = current_dir
        self.cfg_src = f"{self.current_dir}/config.ini"
        self.scr_src = f"{self.current_dir}/src/"
        self.cfg_dst = "/mnt/config.ini"
        self.scr_dst = "/mnt/temporary"

    def copy_sources(self):
        try:
            shutil.copytree(self.scr_src, self.scr_dst)
            logging.info(f"copytree: {self.scr_src} >> {self.scr_dst}")
            shutil.copy(self.cfg_src, self.cfg_dst)
            logging.info(f"copy: {self.scr_src} >> {self.scr_dst}")
            os.chmod("/mnt/temporary/main.py", 0o755)
            logging.info("chmod 0x755 /mnt/temporary/main.py")
            print("[+] CHROOT: Copy script")
        except FileExistsError as err:
            logging.info("file already exists")
            pass
        except Exception as err:
            logging.error(err)
            print("[-] CHROOT: Copy script", err)
            sys.exit(1)

    @staticmethod
    def chroot():
        os.system("clear")
        cmd = "arch-chroot /mnt ./temporary/main.py"
        try:
            subprocess.run(cmd, shell=True, check=True)
            logging.info(cmd)
            print(f"[+] Installation successful")
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}: {err}")
            print(f"[-] Chroot", err)
            sys.exit(1)

    def clear(self):
        shutil.rmtree(self.scr_dst)
        logging.info(f"rmtree {self.scr_dst}")
        os.remove(self.cfg_dst)
        logging.info(f"remove {self.cfg_dst}")
