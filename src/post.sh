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
    dialogrc=${script_dir}/cfg/dialogrc
    pacmanconf=${script_dir}/cfg/pacman.conf
    package_data=${script_dir}/cfg/packages.json

    configs

  }

  configs() {

    cp -f ${dialogrc} /etc/dialogrc

    main_dialogs

  }

  check_dependencies

)

main_dialog() (

  bitwarden_email() {

    bw_email=$(dialog --cancel-label "Exit" --inputbox "Bitwarden e-mail" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      echo "The script has terminated"
      exit ${exitcode}
    fi

    if [ ! ${bw_email} ]; then
      dialog --title " ERROR " --msgbox "\nE-mail cannot be empty [Bitwarden]" 13 50
      bitwarden_email
    fi

    github_email

  }

  github_email() {

    gh_email=$(dialog --cancel-label "Back" --inputbox "GitHub e-mail" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      bitwarden_email
    fi

    if [ ! ${gh_email} ]; then
      dialog --title " ERROR " --msgbox "\nE-mail cannot be empty [GitHub]" 13 50
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
      dialog --title " ERROR " --msgbox "GitHub username cannot be empty." 13 50
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
      dialog --title " ERROR " --msgbox "\nGitHub SSH key name cannot be empty." 13 50
      github_pubkey
    fi

    ssh_passphrase

  }

  ssh_passphrase() {

    ssh_passphrase=$(dialog --passwordbox "SSH passphrase" --cancel-label "Back" 8 45 3>&1 1>&2 2>&3)
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

    main_install

  }

  bitwarden_email

)

main_install() (

  aur() {

    aur_helper=( grep -o '"package": "[^"]*' ${package_data} | grep -o '[^"]*$' )

    aurdir="${HOME}/.local/src/${aur_helper}"

    if [ -d "${aurdir}" ]; then
      rm -rf ${aurdir}
    fi

    git clone https://aur.archlinux.org/${aur_helper_package}.git ${aurdir}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot clone ${aur_helper} repository to ${aurdir}\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        aur
        ;;
      1)
        exit 1
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    cd ${aurdir}

    makepkg -si --noconfirm
    local exitcode2=$?

    if [ "${exitcode2}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot make package [${aur_helper-package}]\nExit status: ${exitcode2}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        aur
        ;;
      1)
        exit 1
        ;;
      *)
        echo "Exit status ${exitcode2}"
        ;;
      esac
    fi

    cd ${HOME}

    pacinstall

  }

  pacinstall() {

    grep -o '"package": "[^"]*' ${package_data} | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm -
    # Overwrite .xinitrc

    bitwarden

  }

  aur

)

main_bitwarden() (

  bitwarden_register() {

    # E-mail
    rbw config set email ${bw_email}
    local exitcode=$?

    # Register
    error=$(rbw register 2>&1)
    local exitcode2=$?

    if [ "${exitcode}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\n
      Exit status [rbw e-mail]: ${exitcode}\n
      Exit status [rbw register]: ${exitcode2}\n
      ${error}" 18 78
      exit 1
    fi

    bitwarden_login

  }

  bitwarden_login() {

    error=$(rbw sync 2>&1)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\n
      Exit status [rbw sync]: ${exitcode}\n
      ${error}" 18 78
      exit 1
    fi

    # GitHub PAT
    ghpat=$(rbw get GitHub_PAT)

    main_openssh

  }

  bitwarden_register

)

main_openssh() {

  openssh_client() {

    # Start SSH agent
    eval "$(ssh-agent -s)"
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --yesno "Cannot start SSH client.\nExit status: ${exitcode}" --yes-label "Retry" --no-label "Exit" 18 78
      case ${exitcode} in
      0)
        openssh_client
        ;;
      1)
        exit ${exitcode}
        ;;
      *)
        echo "Exit status ${exitcode}"
        ;;
      esac
    fi

    main_github

  }

  openssh_client

}

main_github() {

  gh_ssh_keygen() {

    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f ${HOME}/.ssh/id_ed25519.pub
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot generate SSH key.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    clear

    ssh-add ${HOME}/.ssh/id_ed25519
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot add SSH key to SSH agent.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    gh_login

  }

  gh_login() {

    set -u
    cd ${HOME}
    echo "$ghpat" >.ghpat
    unset ghpat
    gh auth login --with-token <.ghpat
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot authenticate github with token [.ghpat].\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
      0)
        gh_install_login
        ;;
      1)
        clear
        exit ${exitcode}
        ;;
      *)
        echo "Exit status $?"
        ;;
      esac
    fi

    rm .ghpat
    gh auth status
    sleep 5

    gh_pubkey

  }

  gh_pubkey() {

    gh ssh-key add $HOME/.ssh/id_ed25519.pub -t ${gh_pubkeyname}
    local exitcode=$?

    ssh -T git@github.com

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GitHub SSH authentication unsuccessfull.\nExit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    main_dotfiles

  }

  gh_ssh_keygen

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

    main_shell

  }

  dotfiles_fetch

)

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

    whiptail --title "SUCCESS" --msgbox "Arch installation has finished." 8 78
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
