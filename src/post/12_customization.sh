# Customization

qtile_wayland() {

  echo "Qtile - Wayland"

  # Touchpad gestures
  # https://wiki.archlinux.org/title/Libinput

  # Desktop
  #/usr/qtile.desktop

  # Log
  #~/.local/share/qtile/qtile.log

  clear && ly_setup

}

ly_setup() {

  echo "ly"
  # Configuration
  # /etc/ly/config.ini

  clear && pacman_setup

}

pacman_setup() {

  # Explicitly installed: archlinux-keyring
  sudo pacman -D --asexplicit archlinux-keyring

  # Remove orphans amd their configuration files
  sudo pacman -Qtdq | pacman -Rns -

  clear && pipewire

}

pipewire() {

  # echo "Pipewire"
  # https://roosnaflak.com/tech-and-research/transitioning-to-pipewire/

  clear && spotify_client

}

spotify_client() {

  killall spotifyd

  # Spotifyd.conf
  sed -i "s/usr/${spotify_username}/g" ${HOME}/.config/spotifyd/spotifyd.conf
  sed -i "s/pswd/${spotify_password}/g" ${HOME}/.config/spotifyd/spotifyd.conf
  sed -i "s#cachedir#/home/${USER}/.cache/spotifyd/#g" ${HOME}/.config/spotifyd/spotifyd.conf

  # Client.yml
  sed -i "s/clientid/${spotify_client_id}/g" ${HOME}/.config/spotify-tui/client.yml
  sed -i "s/clientsecret/${spotify_client_secret}/g" ${HOME}/.config/spotify-tui/client.yml
  sed -i "s/deviceid/${spotify_device_id}/g" ${HOME}/.config/spotify-tui/client.yml

  clear && xdg_dirs

}

xdg_dirs() {

  # Generate XDG directories
  LC_ALL=C.UTF-8 xdg-user-dirs-update --force
  mkdir ${HOME}/.local/state
  mkdir ${HOME}/.local/share/{bash,cargo,Trash,vim}

  # Move files
  mv ${HOME}/.cargo ${HOME}/.local/share/cargo
  mv ${HOME}/.bash* ${HOME}/.local/share/bash
  mv ${HOME}/.viminfo* ${HOME}/.local/share/vim

  # Delete files
  rm -rf ${HOME}/{Desktop,Music,Public,Templates,Videos}
  rm -rf ${HOME}/arch

  clear && font_support

}

font_support() {

  # Japanese font support
  sudo sed -i '/#ja_JP.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
  sudo echo "LANG=ja_JP.UTF-8" >>/etc/locale.conf

  clear && wallpaper

}

wallpaper() {

  mkdir ${HOME}/Downloads

  # Fetch & unzip wallpapers
  curl -L -o ${HOME}/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"
  unzip ${HOME}/Downloads/wallpapers.zip -d ${HOME}/Pictures/Wallpapers/ -x /

  clear && success

}

success() {

  if (dialog --title " Success " --yes-label "Reboot" --no-label "Exit" --yesno "\nArch installation has finished.\nPlease reboot the machine." 10 50); then
    sudo reboot now
  else
    exit 69
  fi

}

qtile_wayland
