import logging
import sys


"""
Docstring for Security
https://wiki.archlinux.org/title/security
"""

def sudoers():
    sudoers = "/etc/sudoers"
    try:
        with open(sudoers, "r") as file:
            lines = file.readlines()
    except Exception as err:
        print(":: [-] SUDOERS: Read", err)
        logging.error(f"Reading {sudoers}\n{err}")
        sys.exit(1)

    lines.insert(73, "Defaults:%wheel insults\n")
    lines.insert(74, "Defaults passwd_timeout=0\n")
    lines[86] = "%wheel ALL=(ALL:ALL) ALL\n"
    try:
        with open(sudoers, "w") as file:
            file.writelines(lines)
        print(":: [+] SUDOERS: Write")
        logging.info(sudoers)
    except Exception as err:
        print(":: [-] SUDOERS: Write", err)
        logging.error(f"{sudoers}\n{err}")
        sys.exit(1)

def login_delay(logindelay: str):
    """https://wiki.archlinux.org/title/security#Enforce_a_delay_after_a_failed_login_attempt"""
    system_login = "/etc/pam.d/system-login"
    try:
        with open(system_login, "r") as file:
            lines = file.readlines()
    except Exception as err:
            print(f":: [-] Read {system_login}", err)
            logging.error(f"Reading {system_login}\n{err}")
            sys.exit(1)

    lines.insert(5, f"auth optional pam_faildelay.so delay={logindelay}")
    try:
        with open(system_login, "w") as file:
            file.writelines(lines)
            print(f":: [+] Writing {system_login}")
            logging.info(system_login)
    except Exception as err:
            print(f":: [-] Writing {system_login}")
            logging.error(f"{system_login}\n{err}")
            sys.exit(1)
