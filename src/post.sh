#!/bin/bash

aurhelper()(

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
    cd $HOME/local/src/yay
    makepkg -fsri --noconfirm
    cd $HOME

  }

  aur_picaur(){

    git clone https://aur.archlinux.org/pikaur.git $HOME/local/src/picaur
    cd $HOME/local/src/picaur
    makepkg -fsri --noconfirm
    cd $HOME

  }

  aurselect

)

bitwarden()(

  bwclient_select(){

    options=()
    options+=("rbw" "[Rust]")
    options+=("Bitwarden CLI" "[TBA]")

    bwcli=$(whiptail --title "Bitwarden CLI" --menu "Select Bitwarden CLI" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" == "0" ]; then

        case ${bwcli} in
          "rbw")
            bwclient_install
            ;;
          "Bitwarden CLI")
            echo "Not yet supported."
            exit 1
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

installaps(){

  grep -v "^#" $HOME/arch/source/packages.txt | sudo pacman -S --needed --noconfirm

  # aur.sh

}

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
