#!/bin/bash

# --------------------------------------------------
# Arch Linux post script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
# Last major update: 9/28/2021
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
# Hostname
# --------------------------------------------------

echo "------------------------------"
echo "# Hostname"
echo "------------------------------"
echo -ne $newline

read -p "Enter hostname: " hostname
$wait
echo -ne $newline

echo "Setting hostname ${hostname}"
echo -ne $newline
hostnamectl set-hostname ${hostname}
$wait
echo -ne $newline

echo "Checking hostname"
echo -ne $newline
hostnamectl
$wait
clear

# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo -ne $newline

echo "Display server: Xorg"
$wait
echo -ne $newline
sudo pacman -S --noconfirm xorg-server xorg-xinit
clear

echo "Intel firmware"
$wait
echo -ne $newline
sudo pacman -S --noconfirm intel-ucode xf86-video-intel mesa
clear

echo "Additional tools"
$wait
echo -ne $newline
sudo pacman -S --noconfirm htop neofetch
clear

# echo "AUR helper: PARU"
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
# cd ~
# $wait
# clear

# Browser

echo "Sound system: ALSA"
wait
echo -ne $newline
# ALSA
	sudo pacman -S --noconfirm alsa alsa-utils alsa-firmware
# Pulseaudio, sof
	sudo pacman -S --noconfirm pulseaudio pulseaudio-alsa pavucontrol sof-firmware

clear

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "Cloning configs to /home/marci/dotfiles directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/dotfiles.git /home/marci/dotfiles
$wait
clear

echo "------------------------------"
echo "# Xorg - xinit"
echo "------------------------------"
echo -ne $newline

echo "Copying .xinitrc"
cp /home/marci/dotfiles/xorg/.xinitrc /home/marci
# cp /etc/X11/xinit/xinitrc ~/.xinitrc
copycheck
$wait
clear

echo "------------------------------"
echo "# Logind"
echo "------------------------------"
echo -ne $newline

echo "Copying logind.conf"
sudo cp /home/marci/dotfiles/logind/logind.conf /etc/systemd/
copycheck
$wait
clear

echo "------------------------------"
echo "# ZSH"
echo "------------------------------"
echo -ne $newline

echo "Changing shell to ZSH"
$wait
echo -ne $newline

chsh -s /usr/bin/zsh
$wait
echo -ne $newline

echo "Copying .zshrc"
cp /home/marci/dotfiles/zsh/.zshrc /home/marci/
copycheck
$wait
echo -ne $newline

echo "Copying .zlogin"
cp /home/marci/dotfiles/zsh/.zlogin /home/marci/
copycheck
$wait
clear

echo "------------------------------"
echo "# Pacman"
echo "------------------------------"
echo -ne $newline

echo "Copying pacman.conf"
sudo cp /home/marci/dotfiles/pacman/pacman.conf /etc/
copycheck
$wait
clear

echo "------------------------------"
echo "# Suckless software"
echo "------------------------------"
echo -ne $newline

echo "Create a .config directory"
mkdir ~/.config
$wait
echo -ne $newline
echo "Changing to .config directory"
cd ~/.config
$wait
echo -ne $newline

echo "Cloning 'DWM' repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/dwm
$wait
echo -ne $newline

echo "Cloning 'st' repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/st
$wait
echo -ne $newline

echo "Cloning 'dmenu' repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/dmenu
$wait
echo -ne $newline

echo "Changing directory to ~/.config/dwm & compiling"
echo -ne $newline
cd ~/.config/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/st & compiling"
echo -ne $newline
cd ~/.config/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/dmenu & compiling"
echo -ne $newline
cd ~/.config/dmenu
sudo make clean install
$wait
clear