import sys


class Initramfs():

    """Docstring for Initramfs"""

    @staticmethod
    def initramfs():
        conf = '/etc/mkinitcpio.conf'
        try:
            with open(conf, 'r') as file:
                lines = file.readlines()
        except Exception as err:
            print(f'[-] Read {conf}', err)
            sys.exit(1)

        lines[6] = "MODULES=(btrfs)\n"
        lines[51] = "HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)\n"

        try:
            with open(conf, 'w') as file:
                file.writelines(lines)
            print(f'[+] Mkinitcpio.conf {conf}')
        except Exception as err:
            print(f'[-] Mkinitcpio.conf {conf}', err)
            sys.exit(1)
