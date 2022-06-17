#!/bin/bash

network()(

  network_test(){

    for ((i = 0 ; i <= 100 ; i+=25)); do
        ping -q -c 1 archlinux.org &>/dev/null
        local exitcode=$?
        echo $i
        sleep 1
    done | whiptail --gauge "Checking network connection..." 6 50 0

    if [ "$?" != "0" ]; then
      whiptail --title "Network status" --msgbox "Network unreachable.\Exit status: ${?}" 8 78
    fi

    aur

  }

  network_connect(){

    nmcli radio wifi on

    nmcli device wifi list

    nmcli device wifi connect <SSID> password <password>

  }

  network_test

)

aur()(

  aurselect(){

    options=()
    options+=("PARU" "[Rust]")
    options+=("PICAUR" "[Python]")
    options+=("YAY" "[Go]")

    aurhelper=$(whiptail --title "AUR HELPER" --menu "Select AUR helper" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${aurhelper} in
          "PARU")
            aur_paru
            ;;
          "PICAUR")
            aur_picaur
            ;;
          "YAY")
            aur_yay
            ;;
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

    fi

  }

  aur_paru(){

    git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
    cd $HOME/.local/src/paru
    makepkg -fsri --noconfirm
    cd $HOME

  }

  aur_yay(){

    git clone https://aur.archlinux.org/yay.git $HOME/.local/src/yay
    cd $HOME/.local/src/yay
    makepkg -fsri --noconfirm
    cd $HOME

  }

  aur_picaur(){

    git clone https://aur.archlinux.org/pikaur.git $HOME/.local/src/picaur
    cd $HOME/.local/src/picaur
    makepkg -fsri --noconfirm
    cd $HOME

  }

  aurselect

)

bitwarden()(

  bwclient_select(){

    options=()
    options+=("Bitwarden CLI" "[Bitwarden]")
    options+=("rbw" "[Bitwarden]")

    bwcli=$(whiptail --title "Bitwarden CLI" --menu "Select Bitwarden CLI" --default-item "rbw" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${bwcli} in
          "Bitwarden CLI")
            whiptail --title "ERROR" --msgbox "The official Bitwarden CLI is not supported yet." 8 78
            bwclient_select
            ;;
          "rbw")
            bwclient_install
            ;;
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

    fi

  }

  bwclient_install(){

    ${aurhelper} -S --noconfirm --quiet ${bwcli}

    if [ ${bwcli} == "rbw" ]; then
        rbw_config
      else
        bwcli_config
    fi

  }

  rbw_config(){

    bw_email=$(whiptail --inputbox "BW CLI Config" --title "Bitwarden e-mail" 8 39 3>&1 1>&2 2>&3)

    if [ $? = 0 ]; then
        rbw config set e-mail ${bw_email}
      else
        exit 1
    fi

    # Register
    rbw register

    # Sync & Login
    rbw sync

    # GitHub PAT
    ghpat=$(rbw get GitHub_PAT)

    openssh

  }

  bwclient_select

)

openssh(){

  openssh_client(){

    eval "$(ssh-agent -s)"

  }

  openssh_client

}

github(){

  gh_install(){

    sudo pacman -S --noconfirm github-cli

  }

  gh_email(){

    gh_email=$(whiptail --inputbox "GitHub Login" --title "GitHub e-mail" 8 39 3>&1 1>&2 2>&3)

    if [ $? = 0 ]; then
        gh_sshkey
      else
        exit 1
    fi
  }

  gh_sshkey(){

    ssh-keygen -t ed25519 -C ${gh_email}

    ssh-add $HOME/.ssh/id_ed25519

    gh_login

  }

  gh_login(){

    set -u
    echo "$ghpat" > .ghpat
    unset ghpat
    gh auth login --with-token < .ghpat
    rm .ghpat
    gh auth status

    gh_pubkey

  }

  gh_pubkey(){

    gh_pubkeyname=$(whiptail --inputbox "GitHub SSH key" --title "GitHub SSH key name" 8 39 3>&1 1>&2 2>&3)

    gh ssh-key add $HOME/.ssh/id_ed25519.pub -t ${gh_pubkeyname}

    gh_sshtest


  }

  gh_sshtest(){

    ssh -T git@github.com

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GitHub SSH authentication unsuccessfull.\nExit status: $?" 8 78
    fi

    clean

  }

  clean(){

    rm $HOME/password.txt

    rm $HOME/token.txt

    configs

  }

  gh_install

}

configs(){

  git clone git@github.com:marcellbarsony/dotfiles.git $HOME/.config
  cd $HOME/.config

  git remote set-url origin git@github.com:marcellbarsony/dotfiles.git
  cd $HOME

}

install()(

  # aur.sh

  window_manager(){

    options=()
    options+=("dwm" "[C]")
    options+=("i3" "[C]")
    options+=("LeftWM" "[Rust]") # bar dependency
    options+=("OpenBox" "[C]") # bar dependency
    options+=("Qtile" "[Python]")
    options+=("None" "[-]")

    windowmanager=$(whiptail --title "Window Manager" --menu "Select a window manager" --default-item "Qtile" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${windowmanager} in
          "dwm")
            whiptail --title "ERROR" --msgbox "DWM is not supported yet." 8 60
            window_manager
            ;;
          "i3")
            sudo pacman -S --needed --noconfirm i3-wm
            # Overwrite .xinitrc
            ;;
          "LeftWM")
            ${aurhelper} -S --noconfirm leftwm
            # Overwrite .xinitrc
            ;;
          "OpenBox")
            sudo pacman -S --needed --noconfirm openbox tint2
            # Overwrite .xinitrc
            ;;
          "Qtile")
            sudo pacman -S --needed --noconfirm qtile
            # Overwrite .xinitrc
            ;;
          "None")
            browser
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  terminal(){

    options=()
    options+=("Alacritty" "[Rust]")
    options+=("kitty" "[Python]")
    options+=("None" "[-]")

    terminal_select=$(whiptail --title "Terminal" --menu "Select a terminal emulator" --default-item "Alacritty" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${terminal_select} in
          "Alacritty")
            sudo pacman -S alacritty
            ;;
          "kitty")
            sudo pacman -S kitty
            ;;
          "None")
            browser
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  browser(){

    options=()
    options+=("Chromium" "[Chromium]")
    options+=("LibreWolf" "[Firefox]")
    options+=("qutebrowser" "[qt5]")
    options+=("None" "[-]")

    browser_select=$(whiptail --title "Browser" --menu "Select a browser" --default-item "LibreWolf" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${browser_select} in
          "Chromium")
            pacman -S --noconfirm chromium
            ;;
          "LibreWolf")
            paru -S --noconfirm librewolf-bin
            ;;
          "qutebrowser")
            pacman -S --noconfirm qutebrowser
            ;;
          "None")
            ide
            ;;
        esac

        ide

      else

        case $? in
          1)
            window_manager
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  ide(){

    options=()
    options+=("Visual Studio Code [OSS]" "Visual Studio Code")
    options+=("VSCodium" "[Visual Studio Code]")
    options+=("None" "[-]")

    ide_select=$(whiptail --title "Browser" --menu "Select a browser" --default-item "VSCodium" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${ide_select} in
          "Visual Studio Code [OSS]")
            sudo pacman -S --noconfirm code
            ;;
          "VSCodium")
            ${aurhelper} -S --noconfirm vscodium-bin
            ;;
          "None")
            texteditor
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  texteditor(){

    options=()
    options+=("Emacs" "[Emacs]")
    options+=("Nano" "[Console]")
    options+=("Neovim" "[Vi]")
    options+=("Vi" "[Vi]")
    options+=("Vim" "[Vi]")
    options+=("None" "[-]")

    texteditor_select=$(whiptail --tite "Text editor" --menu "Select a text editor" --default-item "Neovim" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${texteditor_select} in
          "Emacs")
            sudo pacman -S --noconfirm emacs
            ;;
          "Nano")
            sudo pacman -S --noconfirm nano
            ;;
          "Neovim")
            sudo pacman -S --noconfirm neovim
            ;;
          "Vi")
            sudo pacman -S --noconfirm vi
            ;;
          "Vim")
            sudo pacman -S --noconfirm vim
            ;;
          "None")
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  application_launcher(){

    options=()
    options+=("dmenu" "[Suckless]")
    options+=("dmenu2" "[Suckless]")
    options+=("dmenu-rs" "[Shizcow]")
    options+=("rofi" "[davatorium]")
    options+=("None" "[-]")

    applauncher_select=$(whiptail --title "Application launcher" --menu "Select application launcher" --default-item "dmenu-rs" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    if [ "$?" == "0" ]; then

        case ${applauncher_select} in
          "dmenu")
            ${aurhelper} -S --noconfirm dmenu-git
            ;;
          "dmenu2")
            ${aurhelper} -S --noconfirm dmenu2
            ;;
          "dmenu-rs")
            ${aurhelper} -S --noconfirm dmenu-rs-git
            ;;
          "rofi")
            sudo pacman -S --noconfirm rofi
            ;;
          "None")
            texteditor
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  task_manager(){

    options=()
    options+=("bpytop" "[aristocratos]")
    options+=("htop" "[htop-dev]")
    options+=("None" "[-]")

    sysmonitor_select=$(whiptail --tite "Task manager" --menu "Select a task manager" --default-item "htop" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${taskmanager_select} in
          "bpytop")
            sudo pacman -S --noconfirm bpytop
            ;;
          "htop")
            sudo pacman -S --noconfirm htop
            ;;
          "None")
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  system_monitor(){

    options=()
    options+=("Conky" "[Emacs]")
    options+=("None" "[-]")

    texteditor_select=$(whiptail --tite "System monitor" --menu "Select a systemmonitor" --default-item "Conky" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${texteditor_select} in
          "Conky")
            sudo pacman -S --noconfirm conky
            ;;
          "None")
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  audio(){

    options=()
    options+=("ALSA" "[Advance Linux Sound Architecture]")
    options+=("PipeWire" "[PipeWire]")

    music_select=$(whiptail --title "Audio" --menu "Select audio backend" --default-item "PipWire" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    if [ "$?" == "0" ]; then

        case ${music_select} in
          "ALSA")
            sudo pacman -S --noconfirm alsa alsa-firmware alsa-utils sof-firmware
            ;;
          "PipWire")
            sudo pacman -S --noconfirm pipewire pipewire-alsa pavucontrol sof-firmware
            ;;
          "None")
            texteditor
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  music(){

    options=()
    options+=("Spotify" "[Spotify GmbH]")
    options+=("Spotify TUI" "[Spotifyd]")
    options+=("None" "[-]")

    music_select=$(whiptail --title "Music" --menu "Select music streaming client" --default-item "Spotify TUI" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    if [ "$?" == "0" ]; then

        case ${music_select} in
          "Spotify")
            ${aurhelper} -S --noconfirm spotify
            ;;
          "Spotify TUI")
            ${aurhelper} -S --noconfirm spotify-tui-bin spotifyd
            ;;
          "None")
            texteditor
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  x11(){

    # If Wayland is not implemented
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-prop xwallpaper arandr unclutter

  }

  zsh_prompt(){

    options=()
    options+=("Spaceship" "[spaceship-prompt]")
    options+=("Starship" "[Starship]")

    prompt_select=$(whiptail --title "ZSH prompt" --menu "Select ZSH prompt" --default-item "Starship" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    if [ "$?" == "0" ]; then

        case ${prompt_select} in
          "Spaceship")
            sudo pacman -S --noconfirm zsh zsh-syntax-highlighting
            ${aurhelper} -S --noconfirm spaceship-prompt
            ;;
          "Starship")
            sudo pacman -S --noconfirm zsh zsh-syntax-highlighting starship
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  man(){

    options=()
    options+=("man-db" "[cjwatson]")
    options+=("tldr" "[tldr-pages]")
    options+=("Both" "[cjwatson + tldr-pages]")
    options+=("None" "[-]")

    manpages_select=$(whiptail --tite "Text editor" --menu "Select additional man pages" --default-item "Both" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${manpages_select} in
          "man-db")
            sudo pacman -S --noconfirm man-db
            ;;
          "tldr")
            sudo pacman -S --noconfirm tldr
            ;;
          "Both")
            sudo pacman -S --noconfirm man-db tldr
            ;;
          "None")
            ;;
        esac

        texteditor

      else

        case $? in
          1)
            browser
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  microcode(){

    options=()
    options+=("AMD" "[Advanced Micro Devices]")
    options+=("Intel" "[Intel Corporation]")
    options+=("None" "[-]")

    microcode_select=$(whiptail --title "CPU microcode" --menu "Select CPU microcode" --default-item "Intel" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${microcode} in
          "AMD")
            sudo pacman -S --needed --noconfirm amd-ucode
            ;;
          "Intel")
            sudo pacman -S --needed --noconfirm intel-ucode xf-86-video-intel
            ;;
          "None")
            ;;
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  compositor(){

    options=()
    options+=("Picom" "[Picom]")
    options+=("None" "[-]")

    compositor_select=$(whiptail --title "Compositor" --menu "Select compositor" --default-item "Picom" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${compositor_select} in
          "Picom")
            sudo pacman -S --needed --noconfirm picom
            ;;
          "None")
            ;;
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac

  }

  languages(){

    options=()
    options+=("Python" "[Python]")
    options+=("Python + Rust" "[Python + Rust]")
    options+=("Rust" "[Rust]")
    options+=("None" "[-]")

    language_select=$(whiptail --title "Programming language" --menu "Select programming language" --default-item "Python + Rust" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${language_select} in
          "Python")
            sudo pacman -S --needed --noconfirm python python-pip
            ;;
          "Python + Rust")
            sudo pacman -S --needed --noconfirm python python-pip rust
            ;;
          "Rust")
            sudo pacman -S --needed --noconfirm rust
            ;;
          "None")
            ;;
        esac

      else

        case $? in
          1)
            exit 1
            ;;
          *)
            echo "Exit status $?"
            exit $?
            ;;
        esac


  }

  coreutils(){

    if (whiptail --title "Core utilities" --yesno "Install core utilities?\n[neofetch, unzip, zip]" 8 78); then
        sudo pacman -S --needed --noconfirm neofetch unzip zip
      else

    fi

  }

  coreutils_rust(){

    if (whiptail --title "Rust core utilities" --yesno "Install Rust core utilities?\n[bat, lsd, zoxide]" 8 78); then
        sudo pacman -S --needed --noconfirm bat lsd zoxide #exa
      else

    fi

  }



)

configs()(

  systemd(){

    sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/

  }

  pacman(){

    sudo cp $HOME/.config/_system/pacman/pacman.conf /etc/

  }

  zsh(){

    # Change shell to ZSH
    chsh -s /usr/bin/zsh

    # Copying zshenv
    sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv

    # Copy zprofile
    sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile
    copycheck

    # ZSH Autocomplete
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $HOME/.local/src/zsh-autocomplete/


  }

)

customization()(

  wallpaper(){

    mkdir $HOME/Downloads

    # Fetch wallpapers from Dropbox
    curl -L -o $HOME/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"

    # Unzip
    unzip $HOME/Downloads/wallpapers.zip -d $HOME/Downloads/Wallpapers/ -x /

  }

)

cleanup(){

  #Cargo: Create directory
  mkdir $HOME/.local/share/cargo

  #Cargo: Move ~/.cargo to ~/.local/share
  mv $HOME/.cargo $HOME/.local/share/cargo

  #Bash: Removing files from $HOME
  rm -rf $HOME/.bash*

  #Dotfiles: Removing unnecessary files from root (/)
  sudo rm -rf /dotfiles

  #echo Installation scrip: Removing  script from root (/)
  sudo rm -rf /arch

}


aurhelper
