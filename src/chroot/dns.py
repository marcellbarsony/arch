import logging
import sys
import textwrap


"""
Docstring for DNS setup
https://wiki.archlinux.org/title/Domain_name_resolution
"""

def networkmanager():
    """https://wiki.archlinux.org/title/NetworkManager#Unmanaged_/etc/resolv.conf"""
    file = "/etc/NetworkManager/conf.d/dns.conf"
    content = textwrap.dedent(
        """\
        [main]
        dns=none
        systemd-resolved=false
        """
    )
    try:
        with open(file, "w") as f:
            f.write(content)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] DNS :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] DNS :: ", file)

def resolvconf():
    file = "/etc/resolv.conf"
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
        with open(file, "w") as f:
            f.write(content)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] DNS :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] DNS :: ", file)
