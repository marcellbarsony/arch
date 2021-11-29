#!/bin/sh

sudo pacman -S --noconfirm bitwarden-cli github-cli
clear

# Bitwarden

  # Login
    key=$(bw login | grep "export BW_SESSION" | cut -d '"' -f 2)
    echo
    #read -p "? 2FA code: " bw2fa
    #key=`bw login --method 0 --code $bw2fa | grep "export BW_SESSION" | cut -d \" -f2`

  # Sync vault
    echo "Syncing vault with session key:"
    bw sync --session $key
    echo
  
  # Set master password to file
    echo "Unlock vault"
    read -s -p "? Master password: " pass
    echo $pass >> $HOME/password.txt # !!!
    echo
  
  # Unlock vault
    session=`bw unlock --passwordfile $HOME/password.txt | grep "export BW_SESSION" | cut -d '"' -f 2`
    echo

  # Set BW_SESSION variable
    export BW_SESSION="${session}"

  # GitHub personal access token
    bw get password GitHub_PAT >> $HOME/token.txt

# OPENSSH
  
  # Install OpenSSH
    echo "Install OpenSSH"
    sudo pacman -S --noconfirm openssh
    clear

  # Start SSH client
    echo "Start SSH client"
    eval "$(ssh-agent -s)"
    echo

  # Gerenate key
    read -p "GitHub e-mail: " email
    echo
    ssh-keygen -t ed25519 -C "${email}"
    clear

  # Add GitHub private key
    echo "Add SSH private key"
    ssh-add $HOME/.ssh/id_ed25519

  # Login to GitHub
    gh auth login --with-token < $HOME/token.txt
    echo
    gh auth status
    sleep 5

  # Add GitHub public key
    echo "GitHub - Add SSH public key"
    read -p "Public key name: " pubkeyname
    gh ssh-key add $HOME/.ssh/id_ed25519.pub -t $pubkeyname
    echo

  # Test SSH connection
    ssh -T git@github.com
    echo
    sleep 3

  # Clone GitHub repository
    git clone git@github.com:marcellbarsony/dotfiles.git $HOME/.config


# CLEAN-UP

  # Bitwarden logout
    #bw logout
    #echo

  # GitHub logout
    #gh auth logout
    #echo

  # Remove password.txt
    rm $HOME/password.txt

  # Remove token.txt
    rm $HOME/token.txt

  # Remove GitHub keys
    #rm $HOME/.ssh/id_ed25519*

  # Uninstall Openssh
    #sudo pacman -Rs --noconfirm openssh