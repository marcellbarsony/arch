import logging
import re
import subprocess
import sys
import textwrap


"""
Systemd
https://wiki.archlinux.org/title/systemd
"""

def logind():
    file = "/etc/systemd/logind.conf"
    pattern_1 = re.compile(r"^#HandleLidSwitch=.*")
    pattern_2 = re.compile(r"^#HandleLidSwitchExternalPower=.*")
    pattern_3 = re.compile(r"^#HandleLidSwitchDocked=.*")

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
        logging.error("%s\n%s", file, err)
        pass
    else:
        logging.info(file)

def services(dmi: str):
    cmds = [
        ["systemctl", "enable", "dnscrypt-proxy.service"],
        ["systemctl", "enable", "earlyoom"],
        ["systemctl", "enable", "fstrim.timer"],
        ["systemctl", "enable", "NetworkManager.service"],
        ["systemctl", "enable", "nftables.service"],
        ["systemctl", "enable", "ntpd.service"],
        ["systemctl", "enable", "ntpdate.service"],
        ["systemctl", "enable", "reflector.service"],
        ["systemctl", "enable", "snapper-cleanup.timer"],
        ["systemctl", "enable", "snapper-timeline.timer"]
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error("%s\n%s", cmd, err)
            pass
        else:
            logging.info(cmd)

    if dmi == "vbox":
        cmd = ["systemctl", "enable", "vboxservice.service"]
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as err:
            logging.error("%s\n%s", cmd, err)
            pass
        else:
            logging.info(cmd)

def watchdog():
    """https://man.archlinux.org/man/systemd-system.conf.5.en"""
    file = "/etc/systemd/system.conf"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error("%s\n%s", file, err)
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
        logging.error("%s\n%s", file, err)
        pass
    else:
        logging.info(file)

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
        logging.error("%s\n%s", file, err)
        pass
    else:
        logging.info(file)
