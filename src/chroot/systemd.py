import logging
import subprocess
import sys


"""
Docstring for Systemd
https://wiki.archlinux.org/title/systemd
"""

def logind():
    file = "/etc/systemd/logind.conf"
    with open(file, "r") as f:
        lines = f.readlines()

    # ACPI events
    lines[27] = "HandleLidSwitch=ignore\n"
    lines[28] = "HandleLidSwitchExternalPower=ignore\n"
    lines[29] = "HandleLidSwitchDocked=ignore\n"
    try:
        with open(file, "w") as f:
             f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] SYSTEMD :: ", err)
    else:
        logging.info(file)
        print(":: [+] SYSTEMD :: ", file)

def services(dmi: str):
    cmds = [
        "systemctl enable earlyoom",
        "systemctl enable fstrim.timer",
        "systemctl enable NetworkManager.service",
        "systemctl enable nftables.service",
        "systemctl enable ntpd.service",
        "systemctl enable ntpdate.service",
        "systemctl enable reflector.service"
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] SYSTEMD :: ", err)
        else:
            logging.info(cmd)
            print(":: [+] SYSTEMD :: ", cmd)

    if dmi == "vbox":
        cmd = "systemctl enable vboxservice.service"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] SYSTEMD :: ", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(":: [+] SYSTEMD :: ", cmd)

def watchdog():
    """https://man.archlinux.org/man/systemd-system.conf.5.en"""
    file = "/etc/systemd/system.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print(f":: [-] SYSTEMD :: Read {file} :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

    lines[36] = "RebootWatchdogSec=0\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] SYSTEMD :: ", err)
    else:
        logging.info(file)
        print(":: [+] SYSTEMD :: ", file)

def pc_speaker():
    """https://wiki.archlinux.org/title/PC_speaker#Globally"""
    file = "/etc/modprobe.d/nobeep.conf"
    conf = "blacklist pcspkr\nblacklist snd_pcsp"
    try:
        with open(file, "w") as f:
            f.write(conf)
    except IOError as err:
        logging.error(f"{conf}\n{err}")
        print(":: [-] SYSTEMD :: ", err)
    else:
        logging.info(file)
        print(":: [+] SYSTEMD :: ", file)
