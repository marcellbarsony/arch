#!/bin/bash

errorlog() {

  local exitcode=${1}
  local functionname=${2}
  local lineno=${3}

  echo "Exit code - ${exitcode}" >${SCRIPT_LOG}
  echo "Function - ${functionname}" >>${SCRIPT_LOG}
  echo "Line no. - ${lineno}" >>${SCRIPT_LOG}

  if (dialog --title " ERROR " --yes-label "View logs" --no-label "Exit" --yesno "\nAn error has occurred\nExit code: ${exitcode}\nFunction: ${functionname}\nLine no.: ${lineno}" 10 60); then
    vim ${SCRIPT_LOG}
    clear
    exit ${exitcode}
  else
    clear
    exit ${exitcode}
  fi

}

set -o errtrace

trap 'errorlog ${?} ${FUNCNAME-main} ${LINENO}' ERR

network() (

  root() (

    if [ id -u == "0" ]; then
      whiptail "Not allowed to run as sudo."
      exit 1
    fi

    network_test

  )

  network_test() {

    for ((i = 0; i <= 100; i += 25)); do
      ping -q -c 1 archlinux.org &>/dev/null
      local exitcode=$?
      echo $i
      sleep 1
    done | whiptail --gauge "Checking network connection..." 6 50 0

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network unreachable.\Exit status: ${?}" 8 78
      network_connect
    fi

    dialog || true

  }

  network_connect() {

    nmcli radio wifi on

    # List WiFi devices: nmcli device wifi list

    ssid=$(whiptail --inputbox "Network SSID" --title "Network connection" 8 39 3>&1 1>&2 2>&3)

    if [ $? != "0" ]; then
      whiptail --title "ERROR" --msgbox "Invalid network SSID.\Exit status: ${?}" 8 78
      network_connect
    fi

    password=$(whiptail --passwordbox "Network passphrase" 8 78 --title "Network connection" 3>&1 1>&2 2>&3)

    if [ $? != "0" ]; then
      whiptail --title "ERROR" --msgbox "Invalid network password.\Exit status: ${?}" 8 78
      network_connect
    fi

    nmcli device wifi connect ${ssid} password ${password}

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "cannot connect to network.\nExit status: ${?}" 8 78
      exit $1
    fi

    clear
    network_test

  }

  root

)

dialog() (

  bw_email() {

    bw_email=$(whiptail --inputbox "Bitwarden e-mail" --title "Bitwarden CLI" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        bw_client
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit $?
        ;;
      esac
    fi

    if [ ! ${bw_email} ]; then
      whiptail --title "ERROR" --msgbox "Bitwarden e-mail cannot be empty." 8 78
      bw_email
    fi

    github_email

  }

  github_email() {

    gh_email=$(whiptail --inputbox "GitHub e-mail" --title "GitHub" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        bw_email
        ;;
      *)
        echo "Exit status $?"
        exit $?
        ;;
      esac
    fi

    if [ ! ${gh_email} ]; then
      whiptail --title "ERROR" --msgbox "GitHub e-mail cannot be empty." 8 78
      github_email
    fi

    github_user

  }

  github_user() {

    github_username=$(whiptail --inputbox "GitHub username" --title "GitHub" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        github_email
        ;;
      *)
        echo "Exit status $?"
        exit $?
        ;;
      esac
    fi

    if [ ! ${github_username} ]; then
      whiptail --title "ERROR" --msgbox "GitHub username cannot be empty." 8 78
      github_user
    fi

    github_pubkey

  }

  github_pubkey() {

    gh_pubkeyname=$(whiptail --inputbox "GitHub SSH Key" --title "GitHub" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        github_email
        ;;
      *)
        echo "Exit status $?"
        exit $?
        ;;
      esac
    fi

    if [ ! ${gh_pubkeyname} ]; then
      whiptail --title "ERROR" --msgbox "GitHub SSH key name cannot be empty." 8 78
      github_pubkey
    fi

    ssh_passphrase

  }

  ssh_passphrase() {

    ssh_passphrase=$(whiptail --passwordbox "SSH passphrase" --title "SSH" --nocancel 8 78 3>&1 1>&2 2>&3)

    ssh_passphrase_confirm=$(whiptail --passwordbox "SSH passphrase [confirm]" --title "SSH" --nocancel 8 78 3>&1 1>&2 2>&3)

    if [ ! ${ssh_passphrase} ] || [ ! ${ssh_passphrase_confirm} ]; then
      whiptail --title "ERROR" --msgbox "SSH passphrase cannot be empty." 8 78
      ssh_passphrase
    fi

    if [ ${ssh_passphrase} != ${ssh_passphrase_confirm} ]; then
      whiptail --title "ERROR" --msgbox "SSH passphrase did not match." 8 78
      ssh_passphrase
    fi

    variables

  }

  aur

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

  aur_helper="paru"
  aur_helper_package="paru-bin"
  bitwarden_cli="rbw"
  xwaylan='xorg-wayland'
  diaplay_manager=
  #https://wiki.archlinux.org/title/Display_manager#List_of_display_managers
  file_manager=
  # https://wiki.archlinux.org/title/List_of_applications/Utilities#File_managers
  # xplr - https://github.com/sayanarijit/xplr
  # joshuto - https://github.com/kamiyaa/joshuto
  # felix - https://github.com/kyoheiu/felix
  window_manager="qtile"
  terminal="alacritty"
  browser="librewolf"
  ide="vscodium-bin"
  text_editor="neovim"
  application_launcher="dmenu-rs"
  task_manager="htop"
  system_monitor="conky"
  music="spotify-tui"
  zsh_prmopt="starship"
  manpages="tldr"
  compositor="picom"
  languages=
  coreutils=
  coreutils_rust=

  install

}

install() (

  reflector() {

    pacman -Qi reflector >/dev/null

    if [ "$?" != "0" ]; then
      sudo pacman -S reflector
    fi

    mirrorlist

  }

  mirrorlist() {

    echo 50 | whiptail --gauge "Backing up mirrorlist..." 6 50 0
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &>/dev/null
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Mirrorlist cannot be backed up.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    echo 100 | whiptail --gauge "Reflector: Update mirrorlist..." 6 50 0
    sudo reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Mirrorlist cannot be updated.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    aur

  }

  aur() (

    aur_helper=(grep -o '"package": "[^"]*' ${package_data} | grep -o '[^"]*$' )

    aurdir="$HOME/.local/src/${aur_helper}"

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

    cd $HOME

    github_cli

  )

  pacinstall() {

    grep -o '"package": "[^"]*' ${package_data} | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm -
    # Overwrite .xinitrc

  }

  compile() {

      git clone git://git.suckless.org/dwm $HOME/.local/src/dwm
      cd $HOME/.local/src/dwm
      make
      make install
      local exitcode=$?
      cd $HOME

  }

  terminal() {

    case ${terminal} in
    "Alacritty")
      sudo pacman -S --noconfirm alacritty
      local exitcode=$?
      ;;
    "kitty")
      sudo pacman -S --noconfirm kitty
      local exitcode=$?
      ;;
    "st")
      ${aur_helper} -S --noconfirm st
      local exitcode=$?
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${terminal}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        terminal
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    browser

  }

  browser() {

    case ${browser} in
    "Chromium")
      pacman -S --noconfirm chromium
      local exitcode=$?
      ;;
    "LibreWolf")
      paru -S --noconfirm librewolf-bin
      local exitcode=$?
      ;;
    "qutebrowser")
      pacman -S --noconfirm qutebrowser
      local exitcode=$?
      ;;
    "None")
      ide
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${browser}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    ide

  }

  ide() {

    case ${ide_select} in
    "Visual_Studio_Code")
      sudo pacman -S --noconfirm code
      local exitcode=$?
      ;;
    "VSCodium")
      ${aur_helper} -S --noconfirm vscodium-bin
      local exitcode=$?
      ;;
    "None")
      texteditor
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${ide_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    texteditor

  }

  application_launcher() {

    case ${applauncher_select} in
    "dmenu")
      sudo pacman -S dmenu
      local exitcode=$?
      ;;
    "dmenu2")
      ${aur_helper} -S --noconfirm dmenu2
      local exitcode=$?
      ;;
    "dmenu-rs")
      ${aur_helper} -S --noconfirm dmenu-rs
      local exitcode=$?
      ;;
    "rofi")
      sudo pacman -S --noconfirm rofi
      local exitcode=$?
      ;;
    "None")
      task_manager
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${applauncher_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    task_manager

  }


  mirrorlist

)

bitwarden() (

  rbw_register() {

    # E-mail
    rbw config set email ${bw_email}
    local exitcode=$?

    # Register
    error=$(rbw register 2>&1)
    local exitcode2=$?

    if [ "${exitcode}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\n
      Exit status [rbw e-mail]: ${exitcode}\n
      Exit status [rbw register]: ${exitcode2}"
      --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
      0)
        rbw_register
        ;;
      1)
        clear
        echo "${error}"
        exit 1
        ;;
      *)
        clear
        echo "${error}"
        echo "Exit status $?"
        ;;
      esac
    fi

    rbw_login

  }

  rbw_login() {

    error=$(rbw sync 2>&1)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
      0)
        rbw_login
        ;;
      1)
        exit ${exitcode}
        ;;
      *)
        echo "Exit status ${exitcode}"
        ;;
      esac
    fi

    # GitHub PAT
    ghpat=$(rbw get GitHub_PAT)

    openssh

  }

  bwclient_register

)

openssh() {

  openssh_client() {

    # Start SSH agent
    eval "$(ssh-agent -s)"
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot start SSH client.\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
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

    github

  }

  openssh_client

}

github() {

  gh_ssh_keygen() {

    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f $HOME/.ssh/id_ed25519.pub
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot generate SSH key.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    clear

    ssh-add $HOME/.ssh/id_ed25519
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot add SSH key to SSH agent.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    gh_login

  }

  gh_login() {

    set -u
    cd $HOME
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

    configs

  }

  gh_ssh_keygen

}

configs() (

  clone() {

    git clone git@github.com:${github_username}/dotfiles.git $HOME/.config

    cd $HOME/.config

    git remote set-url origin git@github.com:${github_username}/dotfiles.git

    cd $HOME

    copy_configs

  }

  copy_configs() {

    sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/

    sudo cp $HOME/.config/_system/pacman/pacman.conf /etc/

    zsh

  }

  zsh() {

    # Change shell to ZSH
    chsh -s /usr/bin/zsh

    # Copy zshenv & zprofile
    sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv
    sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile

    # ZSH Autocomplete
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $HOME/.local/src/zsh-autocomplete/

    services

  }

)

services() {

  pacman -Qi ${diaplay_manager} >/dev/null
  if [ "$?" != "0" ]; then
    sudo systemctl enable ly.service
  fi

  customization

}

customization() (

  spotify_tui() {

    spotify_password=$(rbw get Spotify)
    spotify_token=$(rbw get Spotify_TUI)

    sed -i "s/password = ""/password = \"${spotify_password}\"/g" ${HOME}/.config/spotifyd/spotifyd.conf
    sed -i "s/cache_path = "/home/username/.cache/spotifyd"/cache_path = "/home/${USER}/.cache/spotifyd"/g" ${HOME}/.config/spotifyd/spotifyd.conf

    sed -i '/^client_secret:/ s/$/ ${spotify_token}/' spotify-tui/client.yml

    wallpaper

  }

  wallpaper() {

    mkdir $HOME/Downloads

    # Fetch wallpapers from Dropbox
    curl -L -o $HOME/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"

    # Unzip
    unzip $HOME/Downloads/wallpapers.zip -d $HOME/Downloads/Wallpapers/ -x /

    cleanup

  }

  cleanup() {

    #Cargo
    mkdir $HOME/.local/share/cargo
    mv $HOME/.cargo $HOME/.local/share/cargo

    #Bash: Removing files from $HOME
    mkdir $HOME/.local/share/bash
    mv $HOME/.bash* $HOME/.local/share/bash

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

network || true
