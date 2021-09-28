#!/bin/zsh

# --------------------------------------------------
# Arch Linux post script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
# Last major update: 9/27/2021
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
			echo "Copying process successful"
			$wait
		else
			echo "Copying unsuccessful - exit code $?"
			$wait
	fi
}

# --------------------------------------------------
# User creation
# --------------------------------------------------

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
echo -ne $newline

read -p "Enter your username: " username
echo -ne $newline
echo "Add new user ${username}"
useradd -m ${username}
echo -ne $newline
$wait

echo "Enter the password of ${username}"
passwd ${username}
$wait
clear

# --------------------------------------------------
# User group management
# --------------------------------------------------

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
echo -ne $newline

echo "Adding ${username} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${username}
echo -ne $newline
$wait

echo "Verifying group memebership"
id ${username}
echo -ne $newline
$wait

echo "Visudo: Allowing standard users to run commands as root"
echo -ne $newline
$wait
cp /linux/cfg/sudoers.tmp /etc/sudoers.tmp
copycheck
$wait

# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo -ne $newline

echo "Suckless software - dwm & dmenu & st"
$wait
#echo -ne $newline
#pacman -S dwm dmenu st
#clear

echo "dmenu"
#$wait
#echo -ne $newline
#pacman -S dmenu
#clear

echo "Display server: Xorg-xinit"
$wait
echo -ne $newline
pacman -S xorg-xinit
clear

echo "Display server: Xorg"
$wait
echo -ne $newline
pacman -S xorg
clear

echo "Browser"
$wait
echo -ne $newline
pacman -S firefox
clear

#echo "Sound tools: Alsa, Pulse, Sof"
#wait
#echo -ne $newline
# Pulseaudio
	# pacman -S pulseaudio pulseaudio-alsa pavucontrol sof-firmware
# ALSA
	# pacman -S alsa alsa-utils alsa-firmware alsa-ucm-conf alsamixer
#clear

echo "Intel firmware"
$wait
echo -ne $newline
pacman -S intel-ucode xf86-video-intel
clear

echo "Mesa"
$wait
echo -ne $newline
pacman -S mesa
clear

echo "AUR helper: PARU"
# https://github.com/Morganamilo/paru
$wait
echo -ne $newline
echo"Cloning Git repository"
echo -ne $newline
git clone https://aur.archlinux.org/paru.git
$wait
echo"Changing directoy to paru"
cd paru
$wait
echo "Building package"
echo -ne $newline
makepkg -si
$wait
cd ~
$wait
clear

echo "Additional tools"
$wait
echo -ne $newline
pacman -S htop neofetch
clear

# --------------------------------------------------
# Xorg - xinit
# --------------------------------------------------

echo "------------------------------"
echo "# Xorg - xinit"
echo "------------------------------"
echo -ne $newline

echo "Copying xinitrc"
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc
if [ "$?" -eq "0" ]
	then
	    echo "Copying xinitrc - Successful"
	else
	    echo "Copying xinitrc - Unsuccessful: exit code $?"
fi
$wait
echo -ne $newline

# --------------------------------------------------
# Suckless software
# --------------------------------------------------

# SRC: https://www.chrisatmachine.com/Linux/07-dwm/
# SRC: https://wiki.archlinux.org/title/dwm

#echo "Create a config directory"
#mkdir ~./config
#$wait
#clear

# echo "Cloning DWM repository"
# $wait
# git clone git://git.suckless.org/dwm ~/.config/dwm
# clear

#echo "Cloning st repository"
#$wait
#git clone git://git.suckless.org/st ~/.config/st
#clear

#echo "Cloning dmenu repository"
#$wait
#git clone git://git.suckless.org/dmenu ~/.config/dmenu
#clear

# echo "Changing directory to ~/.config/dwm & installing"
# cd ~/.config/dwm && make install
# # makepkg -si
# $wait
# clear

#echo "Changing directory to ~/.config/st & installing"
#cd ~/.config/st && make install
## makepkg -si
#$wait
#clear

#echo "Changing directory to ~/.config/dmenu & installing"
#cd ~/.config/dmenu && make install
## makepkg -si
#$wait
#clear