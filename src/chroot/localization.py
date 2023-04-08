import subprocess
import sys


class Locale():

    """Docstring for Locale"""

    @staticmethod
    def locale():
        locale_gen = '/etc/locale.gen'
        try:
            with open(locale_gen, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print(f'[-] Read {locale_gen}', err)
            sys.exit(1)

        lines[170] = "en_US.UTF-8 UTF-8\n"
        try:
            with open(locale_gen, 'w') as file:
                file.writelines(lines)
            print(f'[+] Set {locale_gen}')
        except Exception as err:
            print(f'[-] Set {locale_gen}', err)
            sys.exit(1)

    @staticmethod
    def localeConf():
        value = "LANG=en_US.UTF-8"
        locale_conf = '/etc/locale.conf'
        try:
            with open(locale_conf, 'w') as file:
                file.write(value)
            print(f'[+] Set {locale_conf}')
        except Exception as err:
            print(f'[-] Set {locale_conf}', err)
            sys.exit(1)

    @staticmethod
    def localeGen():
        cmd ='locale-gen'
        try:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL)
            print(f'[+] Locale-gen')
        except subprocess.CalledProcessError as err:
            print(f'[-] Locale-gen', err)
            sys.exit(1)
