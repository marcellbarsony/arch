import logging
import sys


"""
Docstring for Security
https://wiki.archlinux.org/title/security
"""

def sudoers():
    file = "/etc/sudoers"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print(":: [-] SUDOERS: Read", err)
        logging.error(f"Reading {file}\n{err}")
        sys.exit(1)

    lines.insert(73, "Defaults:%wheel insults\n")
    lines.insert(74, "Defaults passwd_timeout=0\n")
    lines[109] = "%wheel ALL=(ALL:ALL) ALL\n"
    try:
        with open(file, "w") as f:
            f.writelines(lines)
        print(":: [+] SUDOERS :: ", file)
        logging.info(file)
    except Exception as err:
        print(":: [-] SUDOERS :: ", err)
        logging.error(f"{file}\n{err}")
        sys.exit(1)

# def login_delay(logindelay: str):
#     """https://wiki.archlinux.org/title/security#Enforce_a_delay_after_a_failed_login_attempt"""
#     system_login = "/etc/pam.d/system-login"
#     try:
#         with open(system_login, "r") as file:
#             lines = file.readlines()
#     except Exception as err:
#             print(f":: [-] Read {system_login}", err)
#             logging.error(f"Reading {system_login}\n{err}")
#             sys.exit(1)
#
#     lines.insert(5, f"auth optional pam_faildelay.so delay={logindelay}")
#     try:
#         with open(system_login, "w") as file:
#             file.writelines(lines)
#             print(f":: [+] Writing {system_login}")
#             logging.info(system_login)
#     except Exception as err:
#             print(f":: [-] Writing {system_login}")
#             logging.error(f"{system_login}\n{err}")
#             sys.exit(1)
