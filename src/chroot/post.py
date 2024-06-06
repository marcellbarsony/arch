import logging
import subprocess


def clone(user: str):
    cmd = f"git clone https://github.com/marcellbarsony/arch-post /home/{user}/arch-post"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] POST :: Script clone")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] POST :: Script clone")
        logging.error(f"{cmd}\n{err}")

def chown(user: str):
    cmd = f"sudo chown -R {user}:{user} /home/{user}/arch-post"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] POST :: Script chown")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] POST :: Script chown")
        logging.error(f"{cmd}\n{err}")
