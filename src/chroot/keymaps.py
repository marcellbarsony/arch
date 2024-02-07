import subprocess
import sys
import textwrap


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
        print("TODO: loadkeys")

    @staticmethod
    def keymaps():
        conf = "/etc/X11/xorg.conf.d/00-keyboard.conf"
        content = textwrap.dedent( """\
            # Written by systemd-localed(8), read by systemd-localed and Xorg. It's
            # probably wise not to edit this file manually. Use localectl(1) to
            # update this file.
            Section "InputClass"
                    Identifier "system-keyboard"
                    MatchIsKeyboard "on"
                    Option "XkbLayout" "us"
                    Option "XkbVariant" "colemak_dh"
                    Option "XkbOptions" "caps:capslock"
            EndSection
        """ )
        try:
            with open(conf, "w") as file:
                file.write(content)
            print("[+] /etc/resolv.conf")
        except Exception as err:
            print("[-] /etc/resolv.conf", err)
            sys.exit(1)
