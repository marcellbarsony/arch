import logging
import sys
import textwrap


"""
Docstring for host configuration
https://wiki.archlinux.org/title/Network_configuration
"""

def hostname(hostname: str):
    file = "/etc/hostname"
    try:
        with open(file, "w") as f:
            f.write(hostname)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: HOST :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] :: HOST :: ", file)

def hosts(hostname: str):
    file = "/etc/hosts"
    content = textwrap.dedent(
        f"""\
        127.0.0.1        localhost
        ::1              localhost
        127.0.1.1        {hostname}
        """
    )
    try:
        with open(file, "w") as f:
            f.write(content)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] :: HOST :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] :: HOST :: ", file)
