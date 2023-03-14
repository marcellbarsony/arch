import sys
import textwrap


class Host():

    @staticmethod
    def set_hostname(hostname):
        conf = '/etc/hostname'
        try:
            with open(conf, 'w') as file:
                file.write(hostname)
            print(f'[+] /etc/hostname [{hostname}]')
        except Exception as err:
            print(f'[-] /etc/hostname [{hostname}]', err)
            sys.exit(1)

    @staticmethod
    def hosts(hostname):
        conf = '/etc/hosts'
        content = textwrap.dedent(f"""\
                    127.0.0.1        localhost
                    ::1              localhost
                    127.0.1.1        {hostname}""")
        try:
            with open(conf, 'w') as file:
                file.write(content)
            print('[+] /etc/hosts')
        except Exception as err:
            print('[+] /etc/hosts', err)
            sys.exit(1)
