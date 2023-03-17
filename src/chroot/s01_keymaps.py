import subprocess
import sys


class Keymaps():

    """Docstring for Setup"""

    @staticmethod
    def loadkeys(keymap):
        cmd = f'sudo loadkeys {keymap}'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] Loadkeys {keymap}')
        except subprocess.CalledProcessError as err:
            print(f'[-] Loadkeys {keymap}', err)
            sys.exit(1)

    @staticmethod
    def keymap(keymap):
        conf = '/etc/vconsole.conf'
        content = f"KEYMAP={keymap}"
        try:
            # TODO check
            with open(conf, 'r') as file:
                print(f'[+] {conf} already exists')
        except FileNotFoundError:
            with open(conf, 'w') as file:
                file.write(content)
