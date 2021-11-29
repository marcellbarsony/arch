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
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo

echo "Moving dotfiles to the HOME directory"
echo
git clone https://github.com/marcellbarsony/dotfiles.git $HOME/.config
clear

# --------------------------------------------------
# Install applications - Pacman
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo

grep -v "^#" pkg-list.txt | pacman -S --needed -
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
# Bitwarden
# --------------------------------------------------

echo "------------------------------"
echo "# Bitwarden"
echo "------------------------------"
echo

# RBW by doy - https://github.com/doy/rbw
# sudo pacman -S --noconfirm rbw

# read -p "? 2FA code: " bw2fa
# bwsession=`bw login --method 0 --code $bw2fa | grep "export BW_SESSION" | cut -c 3-`
# eval $bwsession
clear

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
echo "# Suckless"
echo "------------------------------"
echo

echo "Cloning 'dwm' repository"
echo
git clone https://github.com/marcellbarsony/dwm.git $HOME/.local/src/dwm
$wait
echo

echo "Cloning 'st' repository"
echo
git clone https://github.com/marcellbarsony/st.git $HOME/.local/src/st
$wait
echo

echo "Cloning 'dmenu' repository"
echo
git clone https://github.com/marcellbarsony/dmenu.git $HOME/.local/src/dmenu
$wait
echo

echo "Cloning 'slstatus' repository"
echo
git clone https://github.com/marcellbarsony/slstatus.git $HOME/.local/src/slstatus
$wait
clear

echo "Changing directory to ~/.local/src/dwm & compiling"
echo
cd $HOME/.local/src/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/st & compiling"
echo
cd $HOME/.local/src/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/dmenu & compiling"
echo
cd $HOME/.local/src/dmenu
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/slstatus & compiling"
echo
cd $HOME/.local/src/slstatus
sudo make clean install
$wait
clear

echo "--------------------------------------------------"
echo "# Cleaning up installation & HOME"
echo "--------------------------------------------------"
echo

echo "Cargo: Create directory"
mkdir $HOME/.local/share/cargo
copycheck
echo

echo "Cargo: Move ~/.cargo to ~/.local/share"
mv $HOME/.cargo $HOME/.local/share/cargo
copycheck
echo

echo "Bash: Removing files from HOME"
rm -rf $HOME/.bash*
copycheck
echo

echo "Dotfiles: Removing files from root (/)"
sudo rm -rf /dotfiles
copycheck
echo

echo "Installation scrip: Removing  script from root (/)"
sudo rm -rf /arch
copycheck
$wait
clear

# --------------------------------------------------
# REBOOT
# --------------------------------------------------

# $wait
# sudo reboot now
