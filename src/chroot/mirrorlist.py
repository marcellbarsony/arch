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
        logging.warning("Copy %s >> %s", src, dst)
    else:
        logging.info(f"Copy {src} >> {dst}")

def update():
    logging.info("updating mirrorlist ...")
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
        logging.error("%s\n%s", cmd, err)
    else:
        logging.info(cmd)

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
        logging.error("%s\n%s", file, err)
    else:
        logging.info(file)
