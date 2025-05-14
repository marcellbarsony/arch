import logging
import subprocess


def clone(user: str):
    cmd = [
        "git",
        "clone",
        "https://github.com/marcellbarsony/arch-post",
        f"/home/{user}/arch-post"
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: POST :: Script clone")
    else:
        logging.info(cmd)
        print(":: [+] :: POST :: Script clone")

def chown(user: str):
    cmd = [
        "chown",
        "-R", f"{user}:{user}",
        f"/home/{user}/arch-post"
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        logging.error(f"{cmd}\n{err}")
        print(":: [-] :: POST :: Script chown")
    else:
        logging.info(cmd)
        print(":: [+] :: POST :: Script chown")
