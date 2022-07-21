#!/bin/bash

main_setup() (

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

    clear
    main_aur

  }

  github_pubkey

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

    bitwarden_data

  }

  bitwarden_data() {

    # Github
    gh_email=$( rbw get GitHub --full | grep "E-mail:" | cut -d " " -f 2 )
    gh_username=$( rbw get GitHub --full | grep "Username:" | cut -d " " -f 2 )
    gh_pat=$( rbw get GitHub --full | grep "Personal Access Token:" | cut -d " " -f 4 )

    # Spotify
    spotify_username=$( rbw get Spotify --full | grep "Username:" | cut -d " " -f 2 )
    spotify_username_tui=$( rbw get Spotify --full | grep "TUI Username:" | cut -d " " -f 3 )
    spotify_token=$( rbw get Spotify --full | grep "TUI Token:" | cut -d " " -f 3 )
    spotify_password=$( rbw get Spotify )

    clear

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
    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f ${HOME}/.ssh/id_ed25519
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot generate SSH key" 8 45
      exit ${exitcode}
    fi

    # SSH key add
    ssh-add ${HOME}/.ssh/id_ed25519
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

    echo "GH: set token................." && sleep 1
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
      dialog --title " ERROR " --msgbox "GitHub SSH authentication unsuccessfull" 8 45
      exit ${exitcode}
    fi

    gh_test

  }

  gh_test() {

    echo "GH: ssh test.................."
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

    clear && main_dotfiles

  }

  gh_fix() {

    echo "GH: applying fix.............."
    ssh-keyscan github.com >> ~/.ssh/known_hosts

    sleep 2

    gh_test

  }

  gh_install

}

main_dotfiles() (

  dotfiles_fetch() {

    echo "Dotfiles: fetching............"

    mv ${HOME}/.config/rbw /tmp && mv ${HOME}/.config/gh /tmp
    rm -rf ${HOME}/.config

    git clone git@github.com:${gh_username}/dotfiles.git ${HOME}/.config

    cd ${HOME}/.config

    git remote set-url origin git@github.com:${gh_username}/dotfiles.git

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

  dotfiles_fetch

)

main_install() {

  # Pacman
  grep -o '"package[^"]*": "[^"]*' ${TEMPORARY_package_data} | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # AUR
  grep -o '"aurinstall[^"]*": "[^"]*' ${TEMPORARY_package_data} | grep -o '[^"]*$' | ${TEMPORARY_aurhelper} -S --noconfirm - && clear

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
  sudo cp -f ${HOME}/.config/zsh/.zlogout /etc/zsh/zlogout

  # Zsh Autocomplete
  git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

  #main_services
  main_customization

}

main_services() {

  # ly
  sudo systemctl enable ly.service

  main_customization

}

main_customization() (

  wayland() {

    # Touchpad gestures
    # https://wiki.archlinux.org/title/Libinput
    sudo pacman -S wlroots pywlroots
    python-xkbcommon
    python-pywayland
    python-cffi
    cairo python-cairo python-cairo-cffi
    pango
    python-dbus-next

  }

  ly() {

    # Configuration
    # /etc/ly/config.ini

  }

  spotify_tui() {

    # Add Spotify password
    sed -i "s/password = ""/password = \"${spotify_password}\"/g" ${HOME}/.config/spotifyd/spotifyd.conf
    # Adjust cache directory to hostname
    sed -i "s/cache_path = "/home/username/.cache/spotifyd"/cache_path = "${HOME}/.cache/spotifyd"/g" ${HOME}/.config/spotifyd/spotifyd.conf
    # Add client secret
    sed -i "/^client_secret:/ s/$/ ${spotify_token}/" spotify-tui/client.yml

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

    mkdir ${HOME}/.local/src/{cargo,bash}

    #Cargo
    mv ${HOME}/.cargo ${HOME}/.local/src/cargo

    #Bash
    mv ${HOME}/.bash* ${HOME}/.local/src/bash

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
main_setup
