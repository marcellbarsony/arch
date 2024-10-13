import logging
import re
import sys


"""
Docstring for Security
https://wiki.archlinux.org/title/security
"""

def sudoers():
    file = "/etc/sudoers"
    pattern_1 = re.compile(r"^#\s%wheel\s+ALL=\(ALL:ALL\)\s+ALL")
    pattern_2 = re.compile(r"^##\s+Defaults\s+specification")

    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        print(":: [-] SUDOERS: Read", err)
        logging.error(f"Reading {file}\n{err}")
        sys.exit(1)

    updated_lines = []
    insert_lines = [
        "##\n",
        "## Enable insults\n",
        "Defaults:%wheel insults\n",
        "## Disable sudo password timeout\n",
        "Defaults passwd_timeout=0\n"
    ]

    for line in lines:
        if pattern_1.match(line):
            updated_lines.append("%wheel ALL=(ALL:ALL) ALL\n")
        else:
            updated_lines.append(line)

        if pattern_2.match(line):
            updated_lines.extend(insert_lines)

    try:
        with open(file, "w") as f:
            f.writelines(updated_lines)
    except Exception as err:
        logging.error(f"{file}\n{err}")
        print(":: [-] SUDOERS :: ", err)
        sys.exit(1)
    else:
        logging.info(file)
        print(":: [+] SUDOERS :: ", file)

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
