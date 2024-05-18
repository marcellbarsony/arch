import logging
import subprocess


def clone(user: str):
    cmd = f"git clone https://github.com/marcellbarsony/arch-post /home/{user}/arch-post"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] POST :: Cloning post script")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] POST :: Cloning post script")
        logging.error(f"{cmd}\n{err}")

def chown(user: str):
    cmd = f"sudo chown -R {user}:{user} /home/{user}/arch-post"
    try:
        subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        print(":: [+] POST :: Cloning post script")
        logging.info(cmd)
    except subprocess.CalledProcessError as err:
        print(":: [-] POST :: Cloning post script")
        logging.error(f"{cmd}\n{err}")
