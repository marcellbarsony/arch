import logging
import sys
import textwrap


"""
Docstring for DNS setup
https://wiki.archlinux.org/title/Domain_name_resolution
"""

def networkmanager():
    """https://wiki.archlinux.org/title/NetworkManager#Unmanaged_/etc/resolv.conf"""
    conf = "/etc/NetworkManager/conf.d/dns.conf"
    content = textwrap.dedent(
        """\
        [main]
        dns=none
        """
    )
    try:
        with open(conf, "w") as f:
            f.write(content)
        print(":: [+] NetworkManager: DNS conf")
        logging.info(conf)
    except Exception as err:
        print(":: [-] NetworkManager: DNS conf", err)
        logging.error(f"{conf}\n{err}")
        sys.exit(1)

def resolvconf():
    """https://wiki.archlinux.org/title/Domain_name_resolution#Overwriting_of_/etc/resolv.conf"""
    conf = "/etc/resolv.conf"
    content = textwrap.dedent(
        f"""\
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
        """
    )
    try:
        with open(conf, "w") as file:
            file.write(content)
        print(":: [+] DNS: /etc/resolv.conf")
        logging.info(conf)
    except Exception as err:
        print(":: [-] DNS: /etc/resolv.conf", err)
        logging.error(f"{conf}\n{err}")
        sys.exit(1)
