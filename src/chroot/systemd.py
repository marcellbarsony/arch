import logging
import re
import subprocess
import sys
import textwrap


"""
Docstring for Systemd
https://wiki.archlinux.org/title/systemd
"""

def logind():
    file = "/etc/systemd/logind.conf"
    pattern_1 = re.compile(r"^#HandleLidSwitch=ignore")
    pattern_2 = re.compile(r"^#HandleLidSwitchExternalPower=ignore")
    pattern_3 = re.compile(r"^#HandleLidSwitchDocked=ignore")

    with open(file, "r") as f:
        lines = f.readlines()

    updated_lines = []
    for line in lines:
        if pattern_1.match(line):
            updated_lines.append("HandleLidSwitch=ignore\n")
        elif pattern_2.match(line):
            updated_lines.append("HandleLidSwitchExternalPower=ignore\n")
        elif pattern_3.match(line):
            updated_lines.append("HandleLidSwitchDocked=ignore\n")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
             f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: SYSTEMD ::", err)
    else:
        logging.info(file)
        print(":: [+] :: SYSTEMD ::", file)

def services(dmi: str):
    cmds = [
        "systemctl enable dnscrypt-proxy.service",
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
            print(":: [-] :: SYSTEMD ::", err)
        else:
            logging.info(cmd)
            print(":: [+] :: SYSTEMD ::", cmd)

    if dmi == "vbox":
        cmd = "systemctl enable vboxservice.service"
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error(f"{cmd}\n{err}")
            print(":: [-] :: SYSTEMD ::", err)
            sys.exit(1)
        else:
            logging.info(cmd)
            print(":: [+] :: SYSTEMD ::", cmd)

def watchdog():
    """https://man.archlinux.org/man/systemd-system.conf.5.en"""
    file = "/etc/systemd/system.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print(f":: [-] :: SYSTEMD :: Read {file} ::", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

    pattern_1 = re.compile(r"^#RebootWatchdogec=0")

    updated_lines = []
    for line in lines:
        if pattern_1.match(line):
            updated_lines.append("RebootWatchdogSec=0\n")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: SYSTEMD ::", err)
    else:
        logging.info(file)
        print(":: [+] :: SYSTEMD ::", file)

def pc_speaker():
    """https://wiki.archlinux.org/title/PC_speaker#Globally"""
    file = "/etc/modprobe.d/nobeep.conf"
    content = textwrap.dedent(
        """\
        blacklist pcspkr
        blacklist snd_pcsp
        """
    )
    try:
        with open(file, "w") as f:
            f.write(content)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: SYSTEMD ::", err)
    else:
        logging.info(file)
        print(":: [+] :: SYSTEMD ::", file)
