import logging
import os
import subprocess
import sys
import urllib.request
import zipfile


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Customization():

    """Docstring for Customization"""

    @staticmethod
    def background(user: str):
        # makedir
        dir = f'/home/{user}/Downloads/Wallpapers'
        if not os.path.exists(dir):
            os.makedirs(dir)

        # download
        url = 'https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1'
        out = f'{dir}/wallpapers.zip'
        urllib.request.urlretrieve(url, out)

        # unzip
        with zipfile.ZipFile(out, 'r') as zip_ref:
            zip_ref.extractall(dir)

    @staticmethod
    def pacman():
        commands = [
            # archlinux-keyring: make explicitly installed
            'sudo pacman -D --asexplicit archlinux-keyring',
            # Remove orphans and their configs
            'sudo pacman -Qtdq | pacman -Rns -'
            ]
        for cmd in commands:
            out = subprocess.run(cmd, shell=True, check=True)
            if out.returncode != 0:
                print(f'[-] Pacman customization [{cmd}]')
                sys.exit(out.returncode)

    @staticmethod
    def pipewire():
        print('[TODO] Pipewire')
        # echo "Pipewire"
        # https://roosnaflak.com/tech-and-research/transitioning-to-pipewire/
        pass

    @staticmethod
    def wayland():
        print('[TODO] Wayland')
        # Touchpad gestures
        # https://wiki.archlinux.org/title/Libinput

        # Desktop
        #/usr/qtile.desktop

        # Log
        #~/.local/share/qtile/qtile.log
        pass

    @staticmethod
    def spotify():
        print('[TODO] Spotify')
        # killall spotifyd

        # # Spotifyd.conf
        # sed -i "s/usr/${spotify_username}/g" ${HOME}/.config/spotifyd/spotifyd.conf
        # sed -i "s/pswd/${spotify_password}/g" ${HOME}/.config/spotifyd/spotifyd.conf
        # sed -i "s#cachedir#/home/${USER}/.cache/spotifyd/#g" ${HOME}/.config/spotifyd/spotifyd.conf

        # # Client.yml
        # sed -i "s/clientid/${spotify_client_id}/g" ${HOME}/.config/spotify-tui/client.yml
        # sed -i "s/clientsecret/${spotify_client_secret}/g" ${HOME}/.config/spotify-tui/client.yml
        # sed -i "s/deviceid/${spotify_device_id}/g" ${HOME}/.config/spotify-tui/client.yml
        pass

    @staticmethod
    def xdg_dirs(user: str):
        # Generate directories
        cmd = 'LC_ALL=C.UTF-8 xdg-user-dirs-update --force'
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info('Create XDG dirs')
        except Exception as err:
            logger.error('Create XDG dirs', err)
            sys.exit(1)

        # Remove directories
        parent = f'/home/{user}'
        dirs = ['Desktop', 'Documents', 'Music', 'Pictures', 'Public', 'Templates', 'Videos']
        for dir in dirs:
            try:
                path = os.path.join(parent, dir)
                os.rmdir(path)
                logger.info('Remove XDG dir', dir)
            except OSError as err:
                logger.error('Remove XDG dir', dir)
                sys.exit(1)
