import logging
import shutil


"""SSH setup"""

def bashrc(user: str):
    src = "/temporary/ssh/.bashrc"
    dst = f"/home/{user}/.bashrc"
    shutil.copy2(src, dst)
    logging.info(f"Copy {src} >> {dst}")
