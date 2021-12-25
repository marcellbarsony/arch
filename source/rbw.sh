#!/bin/sh

echo "------------------------------"
echo "# SSH setup"
echo "------------------------------"
echo

# TEST
# PARU needs to be installed
paru -S --noconfirm rbw
clear

# Bitwarden

  # Configuration
    # E-mail
    read -p "Bitwarden e-mail: " rbwmail
    rbw config set email $rbwmail

  # Register
  rbw register

  # Sync and login
  rbw sync

  # GitHub PAT
  ghpat=$(rbw get GitHub_PAT)


# OPENSSH
  
  # Install OpenSSH
    echo "Install OpenSSH"
    sudo pacman -S --noconfirm openssh

  # Start SSH client
    echo "Start SSH client"
    eval "$(ssh-agent -s)"
    clear

  # Gerenate key
    read -p "GitHub e-mail: " email
    echo
    ssh-keygen -t ed25519 -C "${email}"
    echo

  # Add GitHub private key
    echo "OpenSSH - Add SSH private key"
    ssh-add $HOME/.ssh/id_ed25519

  # Login to GitHub
    set -u
    echo "$ghpat" > .ghpat
    unset ghpat
    gh auth login --with-token < .ghpat
    rm .ghpat
    gh auth status
    sleep 5
    clear

  # Add GitHub public key
    echo "GitHub - Add SSH public key"
    read -p "Public key name: " pubkeyname
    gh ssh-key add $HOME/.ssh/id_ed25519.pub -t $pubkeyname
    echo

  # Test SSH connection
    ssh -T git@github.com
    echo
    sleep 3
