import logging
import shutil
import subprocess
import textwrap


"""
Update & back-up mirrolist
https://wiki.archlinux.org/title/Reflector
"""

def backup():
    src = "/etc/pacman.d/mirrorlist"
    dst = "/etc/pacman.d/mirrorlist.bak"
    try:
        shutil.copy2(src, dst)
    except Exception as err:
        print(f":: [W] :: Cannot create backup ::", err)
        logging.warning(f"Copy {src} >> {dst}")
    else:
        logging.info(f"Copy {src} >> {dst}")

def update():
    print(":: [i] :: REFLECTOR :: Updating mirrorlist...")
    cmd = [
        "reflector",
        "--latest", "25",
        "--protocol", "https",
        "--connection-timeout", "5",
        "--sort", "rate",
        "--save", "/etc/pacman.d/mirrorlist"
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError as err:
        print(":: [-] :: REFLECTOR :: Mirorlist update ::", err)
        logging.error(f"{cmd}\n{err}")
    else:
        logging.info(cmd)
        print(":: [+] :: REFLECTOR :: Mirrorlist update")

def systemd():
    """
    Systemd service
    https://wiki.archlinux.org/title/Reflector#systemd_service
    """
    file = "/etc/xdg/reflector/reflector.conf"
    content = textwrap.dedent(
        """\
        # Reflector systemd service
        # https://wiki.archlinux.org/title/Reflector#systemd_service
        --save /etc/pacman.d/mirrorlist
        --country Hungary,Germany
        --protocol https
        --sort rate
        --latest 25
        """
    )
    try:
        with open(file, "w") as f:
            f.write(content)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: REFLECTOR ::", err)
    else:
        logging.info(file)
        print(":: [+] :: REFLECTOR ::", file)
