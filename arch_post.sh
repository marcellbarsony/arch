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

newline="\n"
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
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo -ne $newline

echo "# ZSH"
echo -ne $newline
sudo pacman -S --noconfirm zsh zsh-syntax-highlighting
$wait
clear

echo "# X11 - Xorg"
echo -ne $newline
sudo pacman -S --noconfirm xorg-server xorg-xinit arandr
$wait
clear

echo "# Browser"
echo -ne $newline
sudo pacman -S --noconfirm firefox
$wait
clear

echo "# Intel firmware"
echo -ne $newline
sudo pacman -S --noconfirm intel-ucode xf86-video-intel
$wait
clear

echo "# OpenSSH"
echo -ne $newline
sudo pacman -S --noconfirm openssh
$wait
clear

echo "# CLI Tools"
echo -ne $newline
sudo pacman -S --noconfirm github-cli bitwarden-cli
$wait
clear

echo "# Sound system - ALSA & Pulseaudio & Sof"
echo -ne $newline
# ALSA
	sudo pacman -S --noconfirm alsa alsa-utils alsa-firmware
# Pulseaudio, sof
	sudo pacman -S --noconfirm pulseaudio pulseaudio-alsa pavucontrol sof-firmware
$wait
clear

echo "# Additional tools"
echo -ne $newline
sudo pacman -S --noconfirm htop neofetch man-db python-pywal
$wait
clear

# echo "# AUR helper - PARU"
# # https://github.com/Morganamilo/paru
# $wait
# echo -ne $newline
# echo "Cloning Git repository"
# echo -ne $newline
# git clone https://aur.archlinux.org/paru.git
# $wait
# echo"Changing directoy to paru"
# cd paru
# $wait
# echo "Building package"
# echo -ne $newline
# makepkg -si
# $wait
# cd $HOME
# $wait
# clear

# --------------------------------------------------
# Bitwarden
# --------------------------------------------------

echo "------------------------------"
echo "# Bitwarden"
echo "------------------------------"
echo -ne $newline

read -p "Bitwarden - Enter 2FA code: " bw2fa
bwsession=`bw login --method 0 --code bw2fa | grep "BW_SESSION"`
$bwsession

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "Moving dotfiles to the HOME directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/dotfiles.git $HOME/.config
clear

echo "------------------------------"
echo "# Systemd"
echo "------------------------------"
echo -ne $newline

echo "Copying logind.conf"
sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/
copycheck
$wait
clear

echo "------------------------------"
echo "# ZSH"
echo "------------------------------"
echo -ne $newline

echo "Changing shell to ZSH"
echo -ne $newline

chsh -s /usr/bin/zsh
$wait
echo -ne $newline

echo "Copying .zshrc"
cp $HOME/.config/zsh/.zshrc $HOME
copycheck
$wait
echo -ne $newline

echo "Copying .zshenv"
sudo cp $HOME/.config/zsh/.zshenv /usr/local/etc
copycheck
$wait
echo -ne $newline

echo "Copying .zprofile"
sudo cp $HOME/.config/zsh/.zprofile /etc/zsh/zprofile
copycheck
$wait
echo -ne $newline

echo "Copying .zlogout"
cp $HOME/.config/zsh/.zlogout $HOME
copycheck
$wait
clear

echo "------------------------------"
echo "# Pacman"
echo "------------------------------"
echo -ne $newline

echo "Copying pacman.conf"
sudo cp $HOME/.config/pacman/pacman.conf /etc/
copycheck
$wait
clear

echo "------------------------------"
echo "# VIM"
echo "------------------------------"

echo "Copying .vimrc"
cp $HOME/.config/vim/.vimrc $HOME
copycheck
$wait
clear

echo "------------------------------"
echo "# Suckless"
echo "------------------------------"
echo -ne $newline

echo "Cloning 'dwm' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/dwm.git $HOME/.local/src/dwm
$wait
echo -ne $newline

echo "Cloning 'st' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/st.git $HOME/.local/src/st
$wait
echo -ne $newline

echo "Cloning 'dmenu' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/dmenu.git $HOME/.local/src/dmenu
$wait
echo -ne $newline

echo "Cloning 'slstatus' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/slstatus.git $HOME/.local/src/slstatus
$wait
echo -ne $newline
clear

echo "Changing directory to ~/.local/src/dwm & compiling"
echo -ne $newline
cd $HOME/.local/src/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/st & compiling"
echo -ne $newline
cd $HOME/.local/src/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/dmenu & compiling"
echo -ne $newline
cd $HOME/.local/src/dmenu
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/slstatus & compiling"
echo -ne $newline
cd $HOME/.local/src/slstatus
sudo make clean install
$wait
clear

echo "--------------------------------------------------"
echo "# Cleaning up installation"
echo "--------------------------------------------------"
echo -ne $newline

echo "Removing dotfiles from /ROOT"
sudo rm -rf /dotfiles
copycheck
$wait

echo "Removing installation script from /ROOT"
sudo rm -rf /arch
copycheck
$wait
clear

# echo "------------------------------"
# echo "# Bash files"
# echo "------------------------------"
# echo -ne $newline

# echo "Moving .bash_history"
# mv $HOME/.bash_history $HOME/.config/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Moving .bash_logout"
# mv $HOME/.bash_logout $HOME/.config/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Removing .bash_profile"
# mv $HOME/.bash_profile $HOME/.config/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Removing .bashrc"
# mv $HOME/.bashrc $HOME/.config/_legacy/bash
# copycheck
# echo -ne $newline

# --------------------------------------------------
# REBOOT
# --------------------------------------------------

# $wait
# sudo reboot now
