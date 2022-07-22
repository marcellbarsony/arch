#!/bin/bash

TEMPORARY_aurhelper="paru"

display_protocol() {

  dialog --yes-label "X11" --no-label "Wayland" --yesno "\nDisplay protocol" 8 45

  if [ ${?} == "0" ]; then
    displayprotocol="X11"
  else
    displayprotocol="Wayland"
  fi

  audio_backend

}

audio_backend() {

  dialog --yes-label "ALSA" --no-label "Pipewire" --yesno "\nAudio backend" 8 45

  if [ ${?} == "0" ]; then
    audiobackend="ALSA"
  else
    audiobackend="Pipewire"
  fi

  clear && main_aur

}

main_aur() {

  aur_helper=$( grep -o '"aurhelper": "[^"]*' ${HOME}/arch/pkg/base.json | grep -o '[^"]*$' )

  aurdir="${HOME}/.local/src/${aur_helper}"

  if [ -d "${aurdir}" ]; then
    rm -rf ${aurdir}
  fi

  git clone https://aur.archlinux.org/${aur_helper}.git ${aurdir}
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Cannot clone ${aur_helper} repository" 8 45
    exit ${exitcode}
  fi

  cd ${aurdir}

  makepkg -si --noconfirm
  local exitcode2=$?

  if [ "${exitcode2}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Cannot make ${aur_helper} package" 8 45
    exit ${exitcode2}
  fi

  cd ${HOME}

  dotfiles_fetch

}

  dotfiles_fetch() {

    echo "Dotfiles: fetching............"

    mv ${HOME}/.config/rbw /tmp && mv ${HOME}/.config/gh /tmp
    rm -rf ${HOME}/.config

    git clone git@github.com:marcellbarsony/dotfiles.git ${HOME}/.config

    cd ${HOME}/.config

    git remote set-url origin git@github.com:marcellbarsony/dotfiles.git

    cd ${HOME}

    mv /tmp/rbw ${HOME}/.config && mv /tmp/gh ${HOME}/.config

    dotfiles_copy

  }

  dotfiles_copy() {

    echo "Dotfiles: copying............."

    sudo cp ${HOME}/.config/systemd/logind.conf /etc/systemd/

    sudo cp ${HOME}/.config/_system/pacman/pacman.conf /etc/

    clear && main_install

  }


main_install() {

  # Base
  grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/base.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # Pacman
  grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/pacman.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # AUR
  grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/aur.json | grep -o '[^"]*$' | ${TEMPORARY_aurhelper} -S --noconfirm - && clear

  # Audio backend
  case ${audiobackend} in
  ALSA)
    grep -o '"pkg_alsa[^"]*": "[^"]*' ${HOME}/arch/pkg/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  Pipewire)
    grep -o '"pkg_pipewire[^"]*": "[^"]*' ~/arch/pkg/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  esac

  # Display protocol
  case ${displayprotocol} in
  X11)
    grep -o '"pkg_xorg[^"]*": "[^"]*' ${HOME}/arch/pkg/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  Wayland)
    grep -o '"pkg_wayland[^"]*": "[^"]*' ${HOME}/arch/pkg/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  esac

  main_shell

}

main_shell() {

  echo "Shell: changing shell........."

  # Change shell to Zsh
  chsh -s /usr/bin/zsh

  # Copy Zsh files
  # https://web.cs.elte.hu/zsh-manual/zsh_4.html
  # https://zsh.sourceforge.io/Intro/intro_3.html
  sudo cp -f ${HOME}/.config/zsh/global/zshenv /etc/zsh/zshenv
  sudo cp -f ${HOME}/.config/zsh/global/zprofile /etc/zsh/zprofile
  sudo cp -f ${HOME}/.config/zsh/global/zlogin /etc/zsh/zlogin
  sudo cp -f ${HOME}/.config/zsh/.zlogout /etc/zsh/zlogout

  # Zsh Autocomplete
  #git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

  #main_services
  main_customization

}

  display_protocol
