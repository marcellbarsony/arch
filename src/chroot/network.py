import sys
import textwrap


class Host():

    """
    Docstring for network network configuration
    https://wiki.archlinux.org/title/Network_configuration
    """

    def __init__(self, hostname: str):
        self.hostname = hostname

    def set_hostname(self):
        conf = "/etc/hostname"
        try:
            with open(conf, "w") as file:
                file.write(self.hostname)
            print("[+] /etc/hostname")
        except Exception as err:
            print("[-] /etc/hostname", err)
            sys.exit(1)

    def hosts(self):
        conf = "/etc/hosts"
        content = textwrap.dedent(
            f"""\
            127.0.0.1        localhost
            ::1              localhost
            127.0.1.1        {self.hostname}
            """
        )
        try:
            with open(conf, "w") as file:
                file.write(content)
            print("[+] /etc/hosts")
        except Exception as err:
            print("[+] /etc/hosts", err)
            sys.exit(1)


class DomainNameSystem():

    """
    Docstring for DNS setup
    https://wiki.archlinux.org/title/Domain_name_resolution
    """

    @staticmethod
    def networkmanager():
        """https://wiki.archlinux.org/title/NetworkManager#Unmanaged_/etc/resolv.conf"""
        conf = "/etc/NetworkManager/conf.d/dns.conf"
        content = textwrap.dedent( """\
            [main]
            dns=none
        """ )
        try:
            with open(conf, "w") as f:
                f.write(content)
            print("[+] NetworkManager DNS conf")
        except Exception as err:
            print("[-] NetworkManager DNS conf", err)
            sys.exit(1)

    @staticmethod
    def resolvconf():
        """https://wiki.archlinux.org/title/Domain_name_resolution#Overwriting_of_/etc/resolv.conf"""
        conf = "/etc/resolv.conf"
        content = textwrap.dedent( """\
            # Cloudflare
            nameserver 1.1.1.1
            nameserver 1.0.0.1
            nameserver 2606:4700:4700::1111
            nameserver 2606:4700:4700::1001

            # Quad9
            # nameserver 9.9.9.9
            # nameserver 149.112.112.112
            # nameserver 2620:fe::fe
            # nameserver 2620:fe::9
        """ )
        try:
            with open(conf, "w") as file:
                file.write(content)
            print("[+] /etc/resolv.conf")
        except Exception as err:
            print("[-] /etc/resolv.conf", err)
            sys.exit(1)
