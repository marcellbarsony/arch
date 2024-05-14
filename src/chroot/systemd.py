import logging
import subprocess
import sys


"""Docstring for Systemd"""

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
        print(":: [+] ACPI events")
        logging.info(file)
    except Exception as err:
        print(":: [-] ACPI events", err)
        logging.error(f"{file}\n{err}")

def services(dmi: str):
    cmds = [
        "systemctl enable earlyoom",
        "systemctl enable fstrim.timer",
        "systemctl enable NetworkManager.service",
        "systemctl enable nftables.service",
        # "systemctl enable ntpd.service",
        "systemctl enable ntpdate.service",
        "systemctl enable reflector.service"
    ]

    for cmd in cmds:
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(":: [+]", cmd)
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(":: [-]", err)
            logging.error(f"{cmd}\n{err}")

    if dmi == "vbox":
        cmd = "systemctl enable vboxservice.service"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f":: [+] User group [DMI]")
            logging.info(cmd)
        except subprocess.CalledProcessError as err:
            print(f":: [-] User group [DMI]", err)
            logging.error(f"{cmd}\n{err}")
            sys.exit(1)

def watchdog():
    system_conf = "/etc/systemd/system.conf"
    try:
        with open(system_conf, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(f":: [-] Read {system_conf}", err)
        logging.error(f"{system_conf}\n{err}")
        sys.exit(1)

    lines[34] = "RebootWatchdogSec=0\n"
    try:
        with open(system_conf, "w") as file:
            file.writelines(lines)
        print(f":: [+] Write {system_conf}")
        logging.info(system_conf)
    except Exception as err:
        print(f":: [-] Write {system_conf}", err)
        logging.error(f"{system_conf}\n{err}")

def pc_speaker():
    """https://wiki.archlinux.org/title/PC_speaker#Globally"""
    file = "/etc/modprobe.d/nobeep.conf"
    conf = "blacklist pcspkr\nblacklist snd_pcsp"
    try:
        with open(file, "w") as f:
            f.write(conf)
        print(":: [+] Disable PC speaker")
        logging.info(file)
    except IOError as err:
        print(":: [-] Disable PC speaker", err)
        logging.error(f"{conf}\n{err}")
