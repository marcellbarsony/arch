import logging
import re
import sys


"""
Security
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
        logging.warning("%s\n%s", file, err)
        return

    updated_lines = []
    insert_lines = [
        "##\n",
        "## Enable insults\n",
        "Defaults:%wheel insults\n",
        "##\n",
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
        logging.error("%s\n%s", file, err)
        sys.exit(1)
    else:
        logging.info(file)

def login_delay():
    """
    Enforce a delay after a failed login attempt
    https://wiki.archlinux.org/title/security#Enforce_a_delay_after_a_failed_login_attempt
    """
    file = "/etc/pam.d/system-login"
    try:
        with open(file, "r") as f:
            lines = f.readlines()
    except Exception as err:
        logging.error("%s\n%s", file, err)
        sys.exit(1)

    lines.insert(5, f"auth optional pam_faildelay.so delay=5000000")

    try:
        with open(file, "w") as f:
            f.writelines(lines)
    except Exception as err:
        logging.warning("%s\n%s", file, err)
        return
    else:
        logging.info(file)
