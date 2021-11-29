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

. $HOME/arch/source/ssh.sh
clear

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo

# Moving BW and GH to $HOME
mv $HOME/.config/gh $HOME
mv $HOME/.config/Bitwarden\ CLI/ $HOME
rm -rf $HOME/.config

# Fetching configs
git clone git@github.com:marcellbarsony/dotfiles.git $HOME/.config

# Moving BW and GH to .config
mv $HOME/gh $HOME/.config/
mv $HOME/Bitwarden\ CLI/ $HOME/.config/

# --------------------------------------------------
# Install applications
# --------------------------------------------------
# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo

grep -v "^#" $HOME/arch/packages/packages.txt | sudo pacman -S --needed --noconfirm -
$wait
clear

# --------------------------------------------------
# AUR helper - PARU
# --------------------------------------------------

echo "# AUR helper - PARU"
# https://github.com/Morganamilo/paru
echo
git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
cd $HOME/.local/src/paru
makepkg -si --noconfirm
cd $HOME
clear

echo "Fonts"

echo "# Starship prompt"
echo
cd $HOME/.local/src/
mkdir starship
cd starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

#echo "# Spaceship prompt"
#echo
#paru -S --noconfirm spacehip-prompt-git
#$wait
#clear

# echo "VS Codium"
# echo
# paru -S --noconfirm vscodium
# clear

# echo "Joplin"
# echo
# paru -S --noconfirm joplin-desktop
# clear

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
sudo cp $HOME/.config/pacman/pacman.conf /etc/
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
$wait
echo

echo "Copying zshenv"
sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv
copycheck
$wait
echo

echo "Copying zprofile"
sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile
copycheck
$wait
clear

# --------------------------------------------------
# Suckless
# --------------------------------------------------

. $HOME/arch/source/suckless.sh
clear

# --------------------------------------------------
# Clean up
# --------------------------------------------------

. $HOME/arch/source/cleanup.sh
clear
