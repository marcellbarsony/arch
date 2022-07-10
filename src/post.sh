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

    if [ ${defaults} == "yes" ]; then
      defaults
    else
      dialog
    fi

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

  network_test

)

root() {

  if [ id -u == "0" ]; then
    whiptail "Not allowed to run as sudo."
  fi

}

dialog() (

  aur() {

    options=()
    options+=("Paru" "[Rust]")
    options+=("Pikaur" "[Python]")
    options+=("Yay" "[Go]")

    aur_helper=$(dialog --default-item "Paru" --cancel-label "Exit" --title " AUR helper " --menu "Select AUR helper" 15 70 17 ${options[@]} 3>&1 1>&2 2>&3)
    aur_helper=$(whiptail --title "AUR helper" --menu "Select AUR helper" --default-item "Paru" --noitem --cancel-button "Exit" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" == "0" ]; then
      case ${aur_helper} in
      "Paru")
        aur_helper="paru"
        aur_helper_package="paru-bin"
        ;;
      "Pikaur")
        aur_helper="pikaur"
        aur_helper_package="pikaur"
        ;;
      "Yay")
        aur_helper="yay"
        aur_helper_package="yay-bin"
        ;;
      esac
      bw_client
    else
      case ${exitcode} in
      1)
        clear
        exit ${exitcode}
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

  }

  bw_client() {

    options=()
    options+=("bitwarden_cli" "[Bitwarden]")
    options+=("rbw" "[Bitwarden]")

    bitwarden_cli=$(whiptail --title "Bitwarden CLI" --menu "Select Bitwarden CLI" --default-item "rbw" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" == "0" ]; then
      case ${bwcli} in
      "bitwarden_cli")
        whiptail --title "ERROR" --msgbox "The official Bitwarden CLI is not supported yet." 8 78
        bw_client
        ;;
      esac
      bw_email
    else
      case ${exitcode} in
      1)
        aur
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

  }

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

    windowmanager

  }

  windowmanager() {

    options=()
    options+=("dwm" "[C]")
    options+=("i3" "[C]")
    options+=("LeftWM" "[Rust]") # bar dependency
    options+=("OpenBox" "[C]")   # bar dependency
    options+=("Qtile" "[Python]")

    window_manager=$(whiptail --title "Window Manager" --menu "Select a window manager" --default-item "Qtile" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        github_email
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit $?
        ;;
      esac
    fi

    terminal

  }

  terminal() {

    options=()
    options+=("Alacritty" "[Rust]")
    options+=("kitty" "[Python]")
    options+=("st" "[C]")

    terminal_select=$(whiptail --title "Terminal" --menu "Select a terminal emulator" --default-item "Alacritty" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        windowmanager
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    browser

  }

  browser() {

    options=()
    options+=("Chromium" "[Chromium]")
    options+=("LibreWolf" "[Firefox]")
    options+=("qutebrowser" "[qt5]")
    options+=("None" "[-]")

    browser_select=$(whiptail --title "Browser" --menu "Select a browser" --default-item "LibreWolf" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        terminal
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    ide

  }

  ide() {

    options=()
    options+=("Visual_Studio_Code" "[Visual_Studio_Code]")
    options+=("VSCodium" "[Visual_Studio_Code]")
    options+=("None" "[-]")

    ide_select=$(whiptail --title "IDE" --menu "Select an IDE" --default-item "VSCodium" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        browser
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    texteditor

  }

  texteditor() {

    options=()
    options+=("Emacs" "[Emacs]")
    options+=("Nano" "[Console]")
    options+=("Neovim" "[Vi]")
    options+=("Vi" "[Vi]")
    options+=("Vim" "[Vi]")

    texteditor_select=$(whiptail --title "Text editor" --menu "Select a text editor" --default-item "Neovim" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        ide
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    application_launcher

  }

  application_launcher() {

    options=()
    options+=("dmenu" "[Suckless]")
    options+=("dmenu2" "[Suckless]")
    options+=("dmenu-rs" "[Shizcow]")
    options+=("rofi" "[davatorium]")
    options+=("None" "[-]")

    applauncher_select=$(whiptail --title "Application launcher" --menu "Select application launcher" --default-item "dmenu-rs" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        texteditor
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    task_manager

  }

  task_manager() (

    options=()
    options+=("bpytop" "[aristocratos]")
    options+=("htop" "[htop-dev]")
    options+=("None" "[-]")

    taskmanager_select=$(whiptail --title "Task manager" --menu "Select a task manager" --default-item "htop" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        application_launcher
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    system_monitor

  )

  system_monitor() (

    options=()
    options+=("Conky" "[Emacs]")
    options+=("None" "[-]")

    systemmonitor_select=$(whiptail --title "System monitor" --menu "Select a systemmonitor" --default-item "Conky" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        task_manager
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    music

  )

  music() {

    options=()
    options+=("Spotify" "[Spotify_GmbH]")
    options+=("Spotify_TUI" "[Spotifyd]")
    options+=("None" "[-]")

    music_select=$(whiptail --title "Music" --menu "Select music streaming client" --default-item "Spotify TUI" --noitem 25 78 17 --cancel-button "Back" ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        audio
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    zsh_prompt

  }

  zsh_prompt() {

    options=()
    options+=("Spaceship" "[spaceship-prompt]")
    options+=("Starship" "[Starship]")

    prompt_select=$(whiptail --title "ZSH prompt" --menu "Select ZSH prompt" --default-item "Starship" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        music
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    manpages

  }

  manpages() {

    options=()
    options+=("All" "[-]")
    options+=("man-db" "[man-db]")
    options+=("texinfo" "[GNU]")
    options+=("tldr" "[tldr]")
    options+=("None" "[-]")

    manpages_select=$(whiptail --title "Man pages" --menu "Select additional manpages" --default-item "All" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        zsh_prompt
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcodemanpages}
        ;;
      esac
    fi

    microcode

  }

  compositor() {

    options=()
    options+=("Picom" "[Picom]")
    options+=("None" "[-]")

    compositor_select=$(whiptail --title "Compositor" --menu "Select compositor" --default-item "Picom" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        microcode
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    languages

  }

  languages() {

    options=()
    options+=("All" "[-]")
    options+=("Python" "[Python]")
    options+=("Rust" "[Rust]")
    options+=("None" "[-]")

    language_select=$(whiptail --title "Programming language" --menu "Select programming language" --default-item "All" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
      1)
        compositor
        ;;
      *)
        echo "Exit status ${exitcode}"
        exit ${exitcode}
        ;;
      esac
    fi

    coreutils

  }

  coreutils() {

    if (whiptail --title "Core utilities" --yesno "Install core utilities\n[cmatrix, neofetch, unzip, zip]" 8 78); then
      coreutils_install="yes"
    else
      coreutils_rust
    fi

    coreutils_rust

  }

  coreutils_rust() {

    if (whiptail --title "Core utilities [Rust]" --yesno "Install core utilities [Rust]\n[bat, lsd, zoxide]" 8 78); then
      coreutils_install_rust="yes"
    else
      configs
    fi

    install

  }

  aur

)

defaults() {

  aur_helper="paru"
  aur_helper_package="paru-bin"
  bitwarden_cli="rbw"
  xwaylan='xorg-wayland'
  diaplay_manager=
  #https://wiki.archlinux.org/title/Display_manager#List_of_display_managers
  #sudo systemctl enable ly.service
  file_manager=
  # https://wiki.archlinux.org/title/List_of_applications/Utilities#File_managers
  # xplr - https://github.com/sayanarijit/xplr
  # joshuto - https://github.com/kamiyaa/joshuto
  # felix - https://github.com/kyoheiu/felix
  window_manager="qtile"
  terminal_select="alacritty"
  browser_select="librewolf"
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

    bwclient

  )

  bwclient() {

    sudo pacman -S --noconfirm --quiet ${bitwarden_cli}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install package [${bitwarden_cli}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        bwclient
        ;;
      1)
        exit 1
        ;;
      *)
        echo "Exit status ${exitcode}"
        ;;
      esac
    fi

    github_cli

  }

  github_cli() {

    sudo pacman -S --noconfirm github-cli
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install package [github-cli]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        github_cli
        ;;
      1)
        exit 1
        ;;
      *)
        echo "Exit status ${exitcode}"
        ;;
      esac
    fi

    window_manager

  }

  window_manager() {

    case ${window_manager} in
    "dwm")
      git clone git://git.suckless.org/dwm $HOME/.local/src/dwm
      cd $HOME/.local/src/dwm
      make
      make install
      local exitcode=$?
      cd $HOME
      ;;
    "i3")
      sudo pacman -S --needed --noconfirm i3-wm
      local exitcode=$?
      # Overwrite .xinitrc
      ;;
    "LeftWM")
      ${aur_helper} -S --noconfirm leftwm
      local exitcode=$?
      # Overwrite .xinitrc
      # Bar dependency
      ;;
    "OpenBox")
      sudo pacman -S --needed --noconfirm openbox tint2
      local exitcode=$?
      # Overwrite .xinitrc
      # Bar dependency
      ;;
    "Qtile")
      sudo pacman -S --needed --noconfirm qtile
      local exitcode=$?
      # Overwrite .xinitrc
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${window_manager}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        window_manager
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    terminal

  }

  terminal() {

    case ${terminal_select} in
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
      whiptail --title "ERROR" --yesno "Cannot install [${terminal_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
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

    case ${browser_select} in
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
      whiptail --title "ERROR" --yesno "Cannot install [${browser_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
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

  texteditor() {

    case ${texteditor_select} in
    "Emacs")
      sudo pacman -S --noconfirm emacs
      local exitcode=$?
      ;;
    "Nano")
      sudo pacman -S --noconfirm nano
      local exitcode=$?
      ;;
    "Neovim")
      sudo pacman -S --noconfirm neovim
      local exitcode=$?
      ;;
    "Vi")
      sudo pacman -S --noconfirm vi
      local exitcode=$?
      ;;
    "Vim")
      sudo pacman -S --noconfirm vim
      local exitcode=$?
      ;;
    "None")
      application_launcher
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${texteditor_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    application_launcher

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

  task_manager() {

    case ${taskmanager_select} in
    "bpytop")
      sudo pacman -S --noconfirm bpytop
      local exitcode=$?
      ;;
    "htop")
      sudo pacman -S --noconfirm htop
      local exitcode=$?
      ;;
    "None")
      system_monitor
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${taskmanager_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    system_monitor

  }

  system_monitor() {

    case ${systemmonitor_select} in
    "Conky")
      sudo pacman -S --noconfirm conky
      local exitcode=$?
      ;;
    "None")
      audio
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${systemmonitor_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    audio

  }

  audio() {

    case ${audio_select} in
    "ALSA")
      sudo pacman -S --noconfirm alsa alsa-firmware alsa-utils sof-firmware
      local exitcode=$?
      ;;
    "PipWire")
      sudo pacman -S --noconfirm pipewire pipewire-alsa pavucontrol sof-firmware
      local exitcode=$?
      ;;
    "None")
      texteditor
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${audio_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
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

  music() {

    case ${music_select} in
    "Spotify")
      ${aur_helper} -S --noconfirm spotify
      local exitcode=$?
      ;;
    "Spotify_TUI")
      ${aur_helper} -S --noconfirm spotify-tui-bin spotifyd
      local exitcode=$?
      ;;
    "None")
      x11
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${music_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    zsh_prompt

  }

  #x11

  zsh_prompt() {

    sudo pacman -S --noconfirm zsh zsh-syntax-highlighting

    case ${prompt_select} in
    "Spaceship")
      ${aur_helper} -S --noconfirm spaceship-prompt
      local exitcode=$?
      ;;
    "Starship")
      sudo pacman -S --noconfirm starship
      local exitcode=$?
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${prompt_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    man

  }

  man() {

    case ${manpages_select} in
    "All")
      sudo pacman -S --noconfirm man-db tldr
      local exitcode=$?
      ;;
    "man-db")
      sudo pacman -S --noconfirm man-db
      local exitcode=$?
      ;;
    "tldr")
      sudo pacman -S --noconfirm tldr
      local exitcode=$?
      ;;
    "None")
      microcode
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${manpages_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    microcode

  }

  microcode() {

    case ${microcode} in
    "AMD")
      sudo pacman -S --needed --noconfirm amd-ucode
      local exitcode=$?
      ;;
    "Intel")
      sudo pacman -S --needed --noconfirm intel-ucode xf-86-video-intel
      local exitcode=$?
      ;;
    "None")
      compositor
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${microcode}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    compositor

  }

  compositor() {

    case ${compositor_select} in
    "Picom")
      sudo pacman -S --needed --noconfirm picom
      local exitcode=$?
      ;;
    "None")
      languages
      local exitcode=$?
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${compositor_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    languages

  }

  languages() {

    case ${language_select} in
    "All")
      sudo pacman -S --needed --noconfirm python python-pip rust
      local exitcode=$?
      ;;
    "Python")
      sudo pacman -S --needed --noconfirm python python-pip
      local exitcode=$?
      ;;
    "Rust")
      sudo pacman -S --needed --noconfirm rust
      local exitcode=$?
      ;;
    "None")
      coreutils
      ;;
    esac

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot install [${language_select}]\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
      0)
        browser
        ;;
      1)
        exit 1
        ;;
      esac
    fi

    coreutils

  }

  coreutils() {

    if [ ${coreutils_install} == "yes" ]; then
      sudo pacman -S --needed --noconfirm cmatrix neofetch unzip zip
    fi

    if [ ${coreutils_install_rust} == "yes" ]; then
      sudo pacman -S --needed --noconfirm bat lsd zoxide #exa
    fi

    bitwarden

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

  bwclient_select

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

    customization

  }

)

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

network
