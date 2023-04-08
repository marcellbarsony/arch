import sys
import textwrap


class Host():

    """Docstring for Host"""

    def __init__(self, hostname: str):
        self.hostname = hostname

    def setHostname(self):
        conf = '/etc/hostname'
        try:
            with open(conf, 'w') as file:
                file.write(self.hostname)
            print(f'[+] /etc/hostname [{self.hostname}]')
        except Exception as err:
            print(f'[-] /etc/hostname [{self.hostname}]', err)
            sys.exit(1)

    def hosts(self):
        conf = '/etc/hosts'
        content = textwrap.dedent(f"""\
                    127.0.0.1        localhost
                    ::1              localhost
                    127.0.1.1        {self.hostname}""")
        try:
            with open(conf, 'w') as file:
                file.write(content)
            print('[+] /etc/hosts')
        except Exception as err:
            print('[+] /etc/hosts', err)
            sys.exit(1)
