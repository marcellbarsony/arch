import logging
import re
import textwrap


"""
DNS (DoH with DNSCrypt proxy)
https://wiki.archlinux.org/title/Domain_name_resolution
https://wiki.archlinux.org/title/Dnscrypt-proxy
https://wiki.archlinux.org/title/DNS-over-HTTPS
"""

def networkmanager():
    """
    Stop NetworkManager from touching `/etc/resolv.conf`
    https://wiki.archlinux.org/title/NetworkManager#Unmanaged_/etc/resolv.conf
    """
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
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)

def resolvconf():
    file = "/etc/resolv.conf"
    content = textwrap.dedent(
        f"""\
        # DNSCrypt
        nameserver ::1
        nameserver 127.0.0.1
        options edns0

        # NextDNS
        # nameserver 45.90.28.25
        # nameserver 45.90.30.25
        # nameserver 2a07:a8c0::f2:ef5e
        # nameserver 2a07:a8c1::f2:ef5e

        # Cloudflare
        # nameserver 1.1.1.1
        # nameserver 1.0.0.1
        # nameserver 2606:4700:4700::1111
        # nameserver 2606:4700:4700::1001

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
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)

def doh(nextdns_profile: str):
    """
    DNSCrypt-proxy configuration
    https://wiki.archlinux.org/title/Dnscrypt-proxy#Configuration
    """
    file = "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    pattern_1 = re.compile(r"^#\sserver_names\s=?")
    pattern_2 = re.compile(r"^bootstrap_resolvers\s=?")
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return

    updated_lines = []
    for line in lines:
        if pattern_1.match(line):
            updated_lines.append(f"server_names = ['NextDNS-{nextdns_profile}']")
        elif pattern_2.match(line):
            updated_lines.append("bootstrap_resolvers = ['9.9.9.11:53', '1.1.1.1:53']")
        else:
            updated_lines.append(line)

    try:
        with open(file, "w") as f:
            f.writelines(updated_lines)
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)
