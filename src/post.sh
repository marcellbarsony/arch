#!/bin/bash

main_setup() (

  arch_keyring() {

    echo "Update keyring................"
    sudo pacman -Sy --noconfirm archlinux-keyring
    if [ "$?" != "0" ]; then
      clear && echo "Cannot update archlinux-keyring - ${?}"
    fi

    clear && check_dependencies

  }

  time_date() {

    echo -n "Set Time & Date..............." && sleep 1
    sudo timedatectl set-timezone Europe/Amsterdam

    echo "[OK]"

  }

  check_dependencies() {

    echo -n "Dependencies.................." && sleep 1
    pacman -Qi dialog >/dev/null
    if [ "$?" != "0" ]; then
      sudo pacman -S dialog
      clear
    fi

    pacman -Qi github-cli >/dev/null
    if [ "$?" != "0" ]; then
      sudo pacman -S github-cli
      clear
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

  arch_keyring

)

main_dialog() (

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

    dialog --yes-label "Pipewire" --no-label "ALSA" --yesno "\nAudio backend" 8 45

    if [ ${?} == "0" ]; then
      audiobackend="Pipewire"
    else
      audiobackend="ALSA"
    fi

    github_pubkey

  }

  github_pubkey() {

    gh_pubkeyname=$(dialog --cancel-label "Exit" --inputbox "GitHub SSH Key" 8 45 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      exit ${exitcode}
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

    clear && main_aur

  }

  display_protocol

)

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

  clear && main_bitwarden

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

    error=$(rbw register 2>&1)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nRBW register failed\n${error}" 8 60
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

    bitwarden_data

  }

  bitwarden_data() {

    # Github
    gh_email=$( rbw get github --full | grep "E-mail:" | cut -d " " -f 2 )
    gh_username=$( rbw get github --full | grep "Username:" | cut -d " " -f 2 )
    gh_pat=$( rbw get github --full | grep "Personal Access Token:" | cut -d " " -f 4 )

    # Spotify
    spotify_email=$( rbw get spotify --full | grep "E-mail:" | cut -d " " -f 2 )
    spotify_username=$( rbw get spotify --full | grep "Username:" | cut -d " " -f 2 )
    spotify_password=$( rbw get spotify )
    spotify_client_id=$( rbw get spotify --full | grep "Client ID:" | cut -d " " -f 3 )
    spotify_device_id=$( rbw get spotify --full | grep "Device ID:" | cut -d " " -f 3 )
    spotify_client_secret=$( rbw get spotify --full | grep "Client Secret:" | cut -d " " -f 3 )

    clear && main_ssh

  }

  bitwarden_install

)

main_ssh() (

  ssh_agent() {

    # Kill process
    sudo pkill -9 -f ssh

    # Start client
    eval "$(ssh-agent -s)"

    clear && ssh_key

  }

  ssh_key() {

    # SSH key generate
    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f ${HOME}/.ssh/id_ed25519
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot generate SSH key" 8 45
      exit ${exitcode}
    fi

    sleep 1 && clear

    # SSH key add
    ssh-add ${HOME}/.ssh/id_ed25519
    local exitcode2=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot add SSH key to agent" 8 45
      exit ${exitcode2}
    fi
      if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nZSH: Cannot change shell" 8 60
    case ${?} in
    0)
      main_shell
      ;;
    1)
      echo "Installation terminated - $?"
      exit ${exitcode}
    ;;
    esac
  fi

    sleep 1 && clear && main_github

  }

  ssh_agent

)

main_github() {

  gh_login() {

    echo "GH: set token..." && sleep 1
    set -u
    cd ${HOME}
    echo "${gh_pat}" >.ghpat
    unset gh_pat

    echo "GH: authenticate with token..." && sleep 1
    gh auth login --with-token <.ghpat
    local exitcode=$?
    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot authenticate GitHub with token [~/.ghpat]" 8 45
      exit ${exitcode}
    fi

    echo "GH: remove token..." && sleep 1
    rm ${HOME}/.ghpat

    echo "GH: authentication status..." && sleep 1
    gh auth status && sleep 5

    gh_pubkey

  }

  gh_pubkey() {

    echo "GH: add ssh key..." && sleep 1
    gh ssh-key add ${HOME}/.ssh/id_ed25519.pub -t ${gh_pubkeyname}
    local exitcode=$?
    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "GitHub SSH authentication unsuccessfull" 8 45
      exit ${exitcode}
    fi

    gh_test

  }

  gh_test() {

    echo "GH: ssh test..."
    ssh -T git@github.com
    local exitcode=$?

    case ${exitcode} in
    0)
      main_dotfiles
      ;;
    1)
      main_dotfiles
      ;;
    *)
      echo "An error has occurred - ${exitcode}"
      exit ${exitcode}
      ;;
    esac

    main_repositories

  }

  gh_fix() {

    echo "GH: applying fix.............."
    ssh-keyscan github.com >> ~/.ssh/known_hosts

    sleep 2

    gh_test

  }

  gh_login

}

main_repositories() (

  dotfiles() {

    echo "Dotfiles: fetching..."

    mv ${HOME}/.config/rbw /tmp && mv ${HOME}/.config/gh /tmp
    rm -rf ${HOME}/.config

    git clone git@github.com:${gh_username}/dotfiles.git ${HOME}/.config
    cd ${HOME}/.config
    git remote set-url origin git@github.com:${gh_username}/dotfiles.git
    cd ${HOME}

    mv /tmp/rbw ${HOME}/.config && mv /tmp/gh ${HOME}/.config

    echo "Dotfiles: copying..."

    sudo cp ${HOME}/.config/systemd/logind.conf /etc/systemd/
    sudo cp ${HOME}/.config/_system/pacman/pacman.conf /etc/

    clear && scripts

  }

  scripts() {

    echo "Scripts: fetching..."

    local folder=${HOME}/.local/git/scripts

    git clone git@github.com:${gh_username}/scripts.git ${folder}
    cd ${folder}
    git remote set-url origin git@github.com:${gh_username}/scripts.git
    cd ${HOME}

    clear && main_install

  }

  clear && dotfiles

)

main_install() (

  install_base() {

    # Base
    grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/base.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

    # Pacman
    grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/pacman.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

    # AUR
    grep -o '"pkg[^"]*": "[^"]*' ${HOME}/arch/pkg/aur.json | grep -o '[^"]*$' | paru -S --noconfirm - && clear

    clear && install_display

  }

  install_display() {

    case ${displayprotocol} in
    X11)
      grep -o '"pkg_xorg[^"]*": "[^"]*' ${HOME}/arch/pkg/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
      ;;
    Wayland)
      grep -o '"pkg_wayland[^"]*": "[^"]*' ${HOME}/arch/pkg/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
      ;;
    esac

    clear && install_audio

  }

  install_audio() {

    case ${audiobackend} in
    ALSA)
      grep -o '"pkg_alsa[^"]*": "[^"]*' ${HOME}/arch/pkg/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
      ;;
    Pipewire)
      grep -o '"pkg_pipewire[^"]*": "[^"]*' ~/arch/pkg/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
      ;;
    esac

    clear && install_fonts

  }

  install_fonts() {

    echo "Installing fonts..."

    # Latin
    grep -o '"pkg_latin[^"]*": "[^"]*' ${HOME}/arch/pkg/fonts.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

    # Japanese
    #grep -o '"pkg_japanese[^"]*": "[^"]*' ${HOME}/arch/pkg/fonts.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear



    clear && main_shell

  }

  install_base

)

main_shell() {

  # Change shell
  chsh -s /usr/bin/zsh
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nZSH: Cannot change shell" 8 60
    case ${?} in
    0)
      main_shell
      ;;
    1)
      echo "Installation terminated - $?"
      exit ${exitcode}
    ;;
    esac
  fi

  # Config
  sudo cp -f ${HOME}/.config/zsh/global/zshenv /etc/zsh/zshenv
  sudo cp -f ${HOME}/.config/zsh/global/zprofile /etc/zsh/zprofile

  # Zsh-Autocomplete
  git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

  # Zsh-Completions
  git clone https://github.com/zsh-users/zsh-completions.git ${HOME}/.local/src/zsh-completions/

  # Zsh-Autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.local/src/zsh-autosuggestions/

  # Notes
  # https://zsh.sourceforge.io/Doc/Release/Files.html
  # https://zsh.sourceforge.io/Intro/intro_3.html

  clear && main_services

}

main_services() {

  #sudo systemctl enable ly.service
  sudo systemctl enable spotifyd.service

  clear && main_customization

}

main_customization() (

  qtile_wayland() {

    echo "Qtile - Wayland"

    # Touchpad gestures
    # https://wiki.archlinux.org/title/Libinput

    # Desktop
    #/usr/qtile.desktop

    # Log
    #~/.local/share/qtile/qtile.log

   clear && neovim_setup

  }

  neovim_setup(){

    local plugins_start=$HOME/.local/share/nvim/site/pack/default/start
    local plugins_opt=$HOME/.local/share/nvim/site/pack/default/opt
    local clone='gh repo clone'

    # Python
      # Plugin support
        pip3 install pynvim
      # Autocomplete (coq.nvim)
        ${clone} ms-jpq/coq_nvim ${plugins_start}
      # File explorer
        ${clone} md-jpq/chadtree ${plugins_start}
      # LSP config
        ${clone} neovim/nvim-lspconfig ${plugins_start}
        #${clone} williamboman/nvim-lsp-installer ${plugins_start}

    # Lua
      # Autocomplete (nvim-cmp)
        ${clone} hrsh7th/nvim-cmp ${plugins_start}
        ${clone} hrsh7th/cmp-buffer ${plugins_start}
        ${clone} hrsh7th/cmp-cmdline ${plugins_start}
        ${clone} hrsh7th/cmp-git ${plugins_start}
        ${clone} hrsh7th/cmp-nvim-lsp ${plugins_start}
        ${clone} hrsh7th/cmp-path ${plugins_start}
      # File explorer
        ${clone} kyazdani42/nvim-tree.lua ${plugins_start}
        #${clone} nvim-neo-tree/neo-tree.nvim ${plugins_start}
      # Git
        ${clone} lewis6991/gitsigns.nvim ${plugins_start}
      # LSP config
        ${clone} neovim/nvim-lspconfig ${plugins_start}
        #${clone} williamboman/nvim-lsp-installer ${plugins_start}

    # Fold

    # Fuzzy
      # cmp-rg
        #${clone} lukas-reineke/cmp-rg ${plugins_start}

    # Shell
      #${clone} tamago324/cmp-zsh ${plugins_start}

    # Snippets
      # ultisnips
        ${clone} SirVer/ultisnips ${plugins_start}
        ${clone} quangnguyen30192/cmp-nvim-ultisnips ${plugins_start}
        ${clone} honza/vim-snippets ${plugins_start}
        ${clone} onsails/lspkind.nvim ${plugins_start} # Snippet icons
      # vim-vsnip
        # https://github.com/hrsh7th/cmp-vsnip

    # Status line

    # Tabs

    clear && ly_setup

  }

  ly_setup() {

    echo "ly"
    # Configuration
    # /etc/ly/config.ini

    clear && pacman_setup

  }

  pacman_setup() {

    # Marking archlinux-keyring as explicitly installed
    sudo pacman -D --asexplicit archlinux-keyring

    # Remove orphans amd their configuration files
    sudo pacman -Qtdq | pacman -Rns -

    clear && pipewire

  }

  pipewire() {

    echo "Pipewire"
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

clear && main_setup
