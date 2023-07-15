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
