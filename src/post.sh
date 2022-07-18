#!/bin/bash

main_check() (

  check_dependencies() {

    echo -n "Dependencies.................." && sleep 1
    pacman -Qi dialog >/dev/null
    if [ "$?" != "0" ]; then
      sudo pacman -S dialog
    fi

    echo "[OK]"

    check_root

  }

  check_root() {

    userid=(id -u)
    echo -n "Root.........................." && sleep 1
    if [ ${userid} == "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot run script as root [UID 0]" 13 50
      exit 1
    fi

    echo "[OK]"

    check_network

  }

  check_network() (

    network_test() {

      echo -n "Network connection............" && sleep 1

      ping -q -c 1 archlinux.org &>/dev/null
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        network_connect
      fi

      echo "[OK]"

      variables

    }

    network_connect() {

      nmcli radio wifi on

      # List WiFi devices: nmcli device wifi list

      ssid=$(dialog --nocancel --inputbox "Network SSID" --title "Network connection" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${network_password} ]; then
        dialog --title " ERROR " --msgbox "Network passphrase cannot be empty." 13 50
        network_connect
      fi

      network_password=$(dialog --nocancel --passwordbox "Network passphrase" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${network_password} ]; then
        dialog --title " ERROR " --msgbox "Network passphrase cannot be empty." 13 50
        network_connect
      fi

      nmcli device wifi connect ${ssid} password ${network_password}

      if [ "$?" != "0" ]; then
        dialog --title " ERROR " --msgbox "\nCannot connect to network: ${ssid}" 13 50
        network_connect
      fi

      clear

      network_test

    }

    network_test

  )

  variables() {

    script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

    # Logs
    script_log=${script_dir}/src/${script_name}.log
    error_log=${script_dir}/src/error.log

    # Configs
    dialogrc=${HOME}/.local/git/arch/cfg/dialogrc
    pacmanconf=${script_dir}/cfg/pacman.conf
    #package_data=${script_dir}/cfg/packages.json

    # Temporary
    TEMPORARY_package_data=${HOME}/arch/cfg/packages.json
    TEMPORARY_aurhelper="paru"

    configs

  }

  configs() {

    cp -f ${dialogrc} /etc/dialogrc

    main_dialog

  }

  check_dependencies

)

main_dialog() (

  github_email() {

    gh_email=$(dialog --cancel-label "Exit" --inputbox "GitHub e-mail" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      echo "The script has terminated"
      exit ${exitcode}
    fi

    if [ ! ${gh_email} ]; then
      dialog --title " ERROR " --msgbox "\nE-mail cannot be empty" 8 45
      github_email
    fi

    github_user

  }

  github_user() {

    gh_username=$(dialog --cancel-label "Back" --inputbox "GitHub username" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      github_email
    fi

    if [ ! ${gh_username} ]; then
      dialog --title " ERROR " --msgbox "GitHub username cannot be empty." 8 45
      github_user
    fi

    github_pubkey

  }

  github_pubkey() {

    gh_pubkeyname=$(dialog --cancel-label "Back" --inputbox "GitHub SSH Key" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      github_user
    fi

    if [ ! ${gh_pubkeyname} ]; then
      dialog --title " ERROR " --msgbox "\nGitHub SSH key name cannot be empty." 8 45
      github_pubkey
    fi

    ssh_passphrase

  }

  ssh_passphrase() {

    ssh_passphrase=$(dialog --cancel-label "Back" --passwordbox "SSH passphrase" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      github_pubkey
    fi

    ssh_passphrase_confirm=$(dialog --no-cancel --passwordbox "SSH passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

    if [ ! ${ssh_passphrase} ] || [ ! ${ssh_passphrase_confirm} ]; then
      dialog --title " ERROR " --msgbox "Passphrase cannot be empty." 8 45
      ssh_passphrase
    fi

    if [ ${ssh_passphrase} != ${ssh_passphrase_confirm} ]; then
      dialog --title " ERROR " --msgbox "Passphrase did not match." 8 45
      ssh_passphrase
    fi

    clear
    main_aur

  }

  github_email

)

main_aur() {

  aur_helper=$( grep -o '"aurhelper": "[^"]*' ${TEMPORARY_package_data} | grep -o '[^"]*$' )

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

  main_bitwarden

}

main_bitwarden() (

  bitwarden_install() {

    ${TEMPORARY_aurhelper} -S rbw --noconfirm
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot install rbw" 8 45
      exit ${exitcode}
    fi


    bitwarden_email

  }

  bitwarden_email() {

    bw_email=$(dialog --cancel-label "Exit" --inputbox "Bitwarden e-mail" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      echo "The script has terminated"
      exit ${exitcode}
    fi

    if [ ! ${bw_email} ]; then
      dialog --title " ERROR " --msgbox "\nE-mail cannot be empty" 8 45
      bitwarden_email
    fi

    rbw config set email ${bw_email}

    bitwarden_register

  }

  bitwarden_register() {

    # Register
    error=$(rbw register 2>&1)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nRBW register failed" 8 60
      case ${?} in
      0)
        bitwarden_email
        ;;
      1)
        echo "Installation terminated - $?"
        exit ${exitcode}
      ;;
      esac
    fi

    bitwarden_login

  }

  bitwarden_login() {

    error=$(rbw sync 2>&1)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nRBW sync failed\n${error}" 8 60
      case ${?} in
      0)
        bitwarden_email
        ;;
      1)
        echo "Installation terminated - $?"
        exit ${exitcode}
      ;;
      esac
    fi

    # GitHub PAT
    gh_pat=$(rbw get GitHub_PAT)

    main_ssh

  }

  bitwarden_install

)

main_ssh() (

  ssh_agent() {

    # SSH process kill
    sudo pkill -9 -f ssh

    # SSH client start
    eval "$(ssh-agent -s)"

    ssh_key

  }

  ssh_key() {

    # SSH key generate
    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f ${HOME}/.ssh/id_ed25519.pub
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot generate SSH key" 8 45
      exit ${exitcode}
    fi

    # SSH key add
    ssh-add ${HOME}/.ssh/id_ed25519.pub
    local exitcode2=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot add SSH key to agent" 8 45
      exit ${exitcode2}
    fi

    sleep 3 && clear
    main_github

  }

  ssh_agent

)

main_github() {

  gh_install() {

    sudo pacman -Sy github-cli --noconfirm

    clear

    gh_login

  }

  gh_login() {

    echo "GH: set \$gh_pat.............." && sleep 1
    gh_pat=$(rbw get GitHub_PAT)

    echo "GH: set token................." && sleep 1
    set -u
    cd ${HOME}
    echo "${gh_pat}" >.ghpat
    unset gh_pat

    echo "GH: authenticate with oken...." && sleep 1
    gh auth login --with-token <.ghpat
    local exitcode=$?
    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot authenticate GitHub with token [~/.ghpat]" 8 45
      exit ${exitcode}
    fi

    echo "GH: remove token.............." && sleep 1
    rm ${HOME}/.ghpat

    echo "GH: authentication status....." && sleep 1
    gh auth status && sleep 5

    gh_pubkey

  }

  gh_pubkey() {

    echo "GH: add ssh key..............." && sleep 1
    gh ssh-key add ${HOME}/.ssh/id_ed25519.pub -t ${gh_pubkeyname}
    local exitcode=$?
    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "GitHub SSH authentication usuccessfull" 8 45
      exit ${exitcode}
    fi

    echo "GH: ssh test.................." && sleep 1
    ssh -T git@github.com
    local exitcode2=$?
    if [ "${exitcode2}" != "0" ]; then
      dialog --title " ERROR " --msgbox "GitHub SSH test failed" 8 45
      exit ${exitcode2}
    fi

    sleep 3 && clear
    main_dotfiles

  }

  gh_install

}

main_dotfiles() (

  dotfiles_fetch() {

    git clone git@github.com:${gh_username}/dotfiles.git ${HOME}/.config

    cd ${HOME}/.config

    git remote set-url origin git@github.com:${gh_username}/dotfiles.git

    cd ${HOME}

    dotfiles_copy

  }

  dotfiles_copy() {

    sudo cp ${HOME}/.config/systemd/logind.conf /etc/systemd/

    sudo cp ${HOME}/.config/_system/pacman/pacman.conf /etc/

    main_install

  }

  dotfiles_fetch

)

main_install() {

  # Pacman
  grep -o '"package[^"]*": "[^"]*' ${TEMPORARY_package_data} | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm -

  # AUR
  grep -o '"aurinstall[^"]*": "[^"]*' ${TEMPORARY_package_data} | grep -o '[^"]*$' | ${TEMPORARY_aurhelper} -S --noconfirm -

  main_shell

}

main_shell() {

  # Change shell to ZSH
  chsh -s /usr/bin/zsh

  # Copy zshenv & zprofile
  sudo cp ${HOME}/.config/zsh/global/zshenv /etc/zsh/zshenv
  sudo cp ${HOME}/.config/zsh/global/zprofile /etc/zsh/zprofile

  # ZSH Autocomplete
  git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

  main_services

}

main_services() {

  sudo systemctl enable ly.service

  main_customization

}

main_customization() (

  spotify_tui() {

    spotify_password=$(rbw get Spotify)
    spotify_token=$(rbw get Spotify_TUI)

    sed -i "s/password = ""/password = \"${spotify_password}\"/g" ${HOME}/.config/spotifyd/spotifyd.conf
    sed -i "s/cache_path = "/home/username/.cache/spotifyd"/cache_path = "${HOME}/.cache/spotifyd"/g" ${HOME}/.config/spotifyd/spotifyd.conf

    sed -i '/^client_secret:/ s/$/ ${spotify_token}/' spotify-tui/client.yml

    wallpaper

  }

  wallpaper() {

    mkdir ${HOME}/Downloads

    # Fetch wallpapers
    curl -L -o ${HOME}/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"

    # Unzip
    unzip ${HOME}/Downloads/wallpapers.zip -d ${HOME}/Downloads/Wallpapers/ -x /

    cleanup

  }

  cleanup() {

    #Cargo
    mkdir ${HOME}/.local/share/cargo
    mv ${HOME}/.cargo ${HOME}/.local/share/cargo

    #Bash: Moving files
    mkdir ${HOME}/.local/share/bash
    mv ${HOME}/.bash* ${HOME}/.local/share/bash

    success

  }

  success() {

    dialog --msgbox "Arch installation has finished." 8 78
    exit 69

  }

  spotify_tui

)

while (("$#")); do
  case ${1} in
  --help)
    echo "------"
    echo "Arch installation script"
    echo "------"
    echo
    echo "Options:"
    echo "--help    - Get help"
    echo "--info    - Additional information"
    echo "--default - Run script with default settings"
    echo
    exit 0
    ;;
  --info)
    echo "Author: Marcell Barsony"
    echo "Repository: https://github.com/marcellbarsony/arch"
    echo "Important note: This script is under development"
    exit 0
    ;;
  --default)
    defaults="yes"
    ;;
  *)
    echo "Available options:"
    echo "Help --help"
    echo "Info --info"
    ;;
  esac
  shift
done

clear
main_check
