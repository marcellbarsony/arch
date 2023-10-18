import sys


class Bugfix():

    """Docstring for Bugfix"""

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
            print(f"[-] Disable PC speaker {err}")
            pass

