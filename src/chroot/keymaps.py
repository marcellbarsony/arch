import subprocess
import sys


class Keymaps():

    """
    Docstring for Keymaps
    https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration
    """

    def __init__(self, keys: str):
        self.keys = keys

    def loadkeys(self):
        # cmd = f"sudo loadkeys {self.keys}"
        # try:
        #     subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
        #     print(f"[+] Loadkeys {self.keys}")
        # except subprocess.CalledProcessError as err:
        #     print(f"[-] Loadkeys {self.keys}", err)
        #     sys.exit(1)
        print("something")

    def keymap(self):
        conf = "/etc/vconsole.conf"
        content = f"KEYMAP={self.keys}"
        try:
            # TODO check
            with open(conf, "r") as file:
                print(f"[+] {conf} already exists")
        except FileNotFoundError:
            with open(conf, "w") as file:
                file.write(content)
