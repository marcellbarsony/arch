import sys
import textwrap


"""
Docstring for network network configuration
https://wiki.archlinux.org/title/Network_configuration
"""

def hostname(hostname: str):
    conf = "/etc/hostname"
    try:
        with open(conf, "w") as file:
            file.write(hostname)
        print("[+] /etc/hostname")
    except Exception as err:
        print("[-] /etc/hostname", err)
        sys.exit(1)

def hosts(hostname: str):
    conf = "/etc/hosts"
    content = textwrap.dedent(
        f"""\
        127.0.0.1        localhost
        ::1              localhost
        127.0.1.1        {hostname}
        """
    )
    try:
        with open(conf, "w") as file:
            file.write(content)
        print("[+] /etc/hosts")
    except Exception as err:
        print("[+] /etc/hosts", err)
        sys.exit(1)
