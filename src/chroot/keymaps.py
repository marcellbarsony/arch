import sys
import textwrap


def keymaps():
    """
    Docstring for Keymaps
    https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration
    """
    conf = "/etc/X11/xorg.conf.d/00-keyboard.conf"
    content = textwrap.dedent( """\
        # Written by systemd-localed(8), read by systemd-localed and Xorg. It's
        # probably wise not to edit this file manually. Use localectl(1) to
        # update this file.
        Section "InputClass"
                Identifier "system-keyboard"
                MatchIsKeyboard "on"
                Option "XkbLayout" "us"
                Option "XkbVariant" "colemak_dh"
                Option "XkbOptions" "caps:capslock"
        EndSection
    """ )
    try:
        with open(conf, "w") as file:
            file.write(content)
        print("[+] Keyboard configuration")
    except Exception as err:
        print("[-] Keyboard configuration", err)
        sys.exit(1)
