import subprocess
import sys
from .dmi import DMI


class Systemd():

    """Docstring for Systemd"""

    @staticmethod
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
            print("[+] ACPI events")
        except Exception as err:
            print("[-] ACPI events", err)

    @staticmethod
    def services():
        cmds = [
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
                print("[+]", cmd)
            except subprocess.CalledProcessError as err:
                print("[-]", err)

        if DMI.check() == "vbox":
            cmd = "systemctl enable vboxservice.service"
            try:
                subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
                print(f"[+] User group [DMI]")
            except subprocess.CalledProcessError as err:
                print(f"[-] User group [DMI]", err)
                sys.exit(1)

    @staticmethod
    def watchdog():
        system_conf = "/etc/systemd/system.conf"
        try:
            with open(system_conf, "r") as file:
                lines = file.readlines()
        except Exception as err:
            print(f"[-] Read {system_conf}", err)
            sys.exit(1)
        lines[34] = "RebootWatchdogSec=0\n"
        try:
            with open(system_conf, "w") as file:
                file.writelines(lines)
            print(f"[+] Write {system_conf}")
        except Exception as err:
            print(f"[-] Write {system_conf}", err)
            sys.exit(1)

    @staticmethod
    def pc_speaker():
        """https://wiki.archlinux.org/title/PC_speaker#Globally"""
        file = "/etc/modprobe.d/nobeep.conf"
        conf = "blacklist pcspkr\nblacklist snd_pcsp"
        try:
            with open(file, "w") as f:
                f.write(conf)
            print("[+] Disable PC speaker")
        except IOError as err:
            print("[-] Disable PC speaker", err)
            sys.exit(1)
