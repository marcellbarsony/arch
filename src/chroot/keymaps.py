import logging
import textwrap


def x11_keymaps():
    """
    Docstring for X11 Keymaps
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
        print(":: [+] X11: Keyboard configuration")
        logging.info(conf)
    except Exception as err:
        print(":: [-] X11: Keyboard configuration", err)
        logging.error(f"{conf}\n{err}")
