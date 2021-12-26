#!/bin/bash

# --------------------------------------------------
# Arch Linux post script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

read -p "Enter the amount of sleep time in seconds: " waitseconds
wait="sleep ${waitseconds}"
$wait
clear

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

copycheck(){
	if [ "$?" -eq "0" ]
		then
			echo "Successful"
		else
			echo "Unsuccessful: exit code $?"
	fi
}

# --------------------------------------------------
# SSH setup
# --------------------------------------------------

. $HOME/arch/source/rbw.sh
#. $HOME/arch/source/ssh.sh
clear

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo

# Moving BW and GH to $HOME
#mv $HOME/.config/gh $HOME
#mv $HOME/.config/Bitwarden\ CLI/ $HOME
#rm -rf $HOME/.config

# Fetching configs
#git clone git@github.com:marcellbarsony/dotfiles.git $HOME/.config
cd $HOME/.config
git remote set-url origin git@github.com:marcellbarsony/dotfiles.git
cd $HOME

# Moving BW and GH to .config
#mv $HOME/gh $HOME/.config/
#mv $HOME/Bitwarden\ CLI/ $HOME/.config/

# --------------------------------------------------
# Install applications
# --------------------------------------------------
# https://wiki.archlinux.org/title/List_of_applications

grep -v "^#" $HOME/arch/source/packages.txt | sudo pacman -S --needed --noconfirm -
clear

# --------------------------------------------------
# AUR helper - PARU
# --------------------------------------------------

. $HOME/arch/source/aur.sh
clear

# --------------------------------------------------
# Suckless
# --------------------------------------------------

#. $HOME/arch/source/suckless.sh
#clear

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Systemd"
echo "------------------------------"
echo

echo "Copying logind.conf"
sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/
copycheck
$wait
clear

echo "------------------------------"
echo "# Pacman"
echo "------------------------------"
echo

echo "Copying pacman.conf"
sudo cp $HOME/.config/_system/pacman/pacman.conf /etc/
copycheck
$wait
clear

echo "------------------------------"
echo "# ZSH"
echo "------------------------------"
echo

echo "Changing shell to ZSH"
echo
chsh -s /usr/bin/zsh
echo

echo "Copying zshenv"
sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv
copycheck
echo

echo "Copying zprofile"
sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile
copycheck

echo "ZSH Autocomplete"
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $HOME/.local/src/zsh-autocomplete
copycheck
$wait
clear

# --------------------------------------------------
# Time zone
# --------------------------------------------------

timedatectl set-timezone Europe/Budapest

# --------------------------------------------------
# Wallpaper
# --------------------------------------------------

echo "Create Downloads directory"
echo
mkdir $HOME/Downloads

echo "Fetch wallpapers from Dropbox"
echo
curl -L -o $HOME/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"

echo "Unzip wallpapers"
echo
unzip $HOME/Downloads/wallpapers.zip -d $HOME/Downloads/Wallpapers -x /

$wait
clear

# --------------------------------------------------
# Clean up
# --------------------------------------------------

. $HOME/arch/source/cleanup.sh
clear
