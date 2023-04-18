import sys

class Security():

    """Docstring for Security"""

    @staticmethod
    def sudoers():
        sudoers = '/etc/sudoers'
        try:
            with open(sudoers, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print('[-] SUDOERS: Read', err)
            sys.exit(1)

        lines.insert(73, "Defaults:%wheel insults\n")
        lines.insert(74, "Defaults passwd_timeout=0\n")
        lines[86] = "%wheel ALL=(ALL:ALL) ALL\n"
        try:
            with open(sudoers, 'w') as file:
                file.writelines(lines)
            print('[+] SUDOERS: Write')
        except Exception as err:
            print('[-] SUDOERS: Write', err)
            sys.exit(1)

    @staticmethod
    def loginDelay(logindelay: str):
        system_login = '/etc/pam.d/system-login'
        try:
            with open(system_login, 'r') as file:
                lines = file.readlines()
        except Exception as err:
                print(f'[+] Read {system_login}', err)
                sys.exit(1)

        lines.insert(5, f'auth       optional   pam_faildelay.so     delay={logindelay}')
        try:
            with open(system_login, 'w') as file:
                file.writelines(lines)
                print(f'[+] Write {system_login}')
        except Exception as err:
                print(f'[-] Write {system_login}')
                sys.exit(1)

    @staticmethod
    def automaticLogout():
        print('[TODO]: automatic_logout')
        # file = '/etc/profile.d/shell-timeout.sh'
        # cmd = 'TMOUT="$(( 60*10 ))"; [ -z "DISPLAY" ] && export TMOUT; case $( /usr/bin/tty ) in /dev/tty[0-9]*) export TMOUT;; esac'
