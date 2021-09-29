#!/bin/zsh

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

# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo -ne $newline

echo "Display server: Xorg-xinit"
$wait
echo -ne $newline
sudo pacman -S xorg-xinit xorg
clear

echo "Intel firmware"
$wait
echo -ne $newline
sudo pacman -S intel-ucode xf86-video-intel mesa
clear

echo "Additional tools"
$wait
echo -ne $newline
sudo pacman -S htop neofetch
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

# echo "Browser"
# $wait
# echo -ne $newline
# sudo pacman -S firefox
# clear

#echo "Sound tools: Alsa, Pulse, Sof"
#wait
#echo -ne $newline
# Pulseaudio
	# sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol sof-firmware
# ALSA
	# sudo pacman -S alsa alsa-utils alsa-firmware alsa-ucm-conf alsamixer
#clear

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
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "mkdir /config"
$wait
echo -ne $newline

echo "Cloning configs to /home/marci/configs directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/linux.git /home/marci/configs
$wait
clear

# --------------------------------------------------
# Xorg - xinit config
# --------------------------------------------------

echo "------------------------------"
echo "# Xorg - xinit"
echo "------------------------------"
echo -ne $newline

echo "Copying .xinitrc"
cp /home/marci/configs/xinit/.xinitrc /home/marci
# cp /etc/X11/xinit/xinitrc ~/.xinitrc
if [ "$?" -eq "0" ]
	then
	    echo "Copying .xinitrc - Successful"
	else
	    echo "Copying .xinitrc - Unsuccessful: exit code $?"
fi
$wait
echo -ne $newline

# --------------------------------------------------
# Suckless software
# --------------------------------------------------

echo "------------------------------"
echo "# Suckless software"
echo "------------------------------"
echo -ne $newline

echo "Create a config directory"
mkdir ~/.config
$wait
echo -ne $newline
echo "Changing to .config directory"
cd ~/.config
$wait
echo -ne $newline

echo "Cloning DWM repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/dwm
$wait
echo -ne $newline

echo "Cloning st repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/st
$wait
echo -ne $newline

echo "Cloning dmenu repository"
$wait
echo -ne $newline
git clone https://git.suckless.org/dmenu
$wait
echo -ne $newline

echo "Changing directory to ~/.config/dwm & installing"
cd ~/.config/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/st & installing"
cd ~/.config/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/dmenu & installing"
cd ~/.config/dmenu
sudo make clean install
$wait
clear