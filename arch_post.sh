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
sudo pacman -S --noconfirm htop neofetch man-db
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
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "Moving dotfiles to the HOME directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/dotfiles.git $HOME/dotfiles
$wait
clear

echo "------------------------------"
echo "# Systemd"
echo "------------------------------"
echo -ne $newline

echo "Copying logind.conf"
sudo cp $HOME/dotfiles/systemd/logind.conf /etc/systemd/
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
cp $HOME/dotfiles/zsh/.zshrc $HOME
copycheck
$wait
echo -ne $newline

# echo "Copying .zlogin"
# cp $HOME/dotfiles/zsh/.zlogin $HOME
# copycheck
# $wait

echo "Copying .zprofile"
sudo cp $HOME/dotfiles/zsh/.zprofile /etc/zsh/zprofile
copycheck
$wait

echo "Copying .zlogout"
cp $HOME/dotfiles/zsh/.zlogout $HOME
copycheck
$wait

clear

echo "------------------------------"
echo "# Pacman"
echo "------------------------------"
echo -ne $newline

echo "Copying pacman.conf"
sudo cp $HOME/dotfiles/pacman/pacman.conf /etc/
copycheck
$wait
clear

echo "------------------------------"
echo "# VIM"
echo "------------------------------"

echo "Copying .vimrc"
cp $HOME/dotfiles/vim/.vimrc $HOME
copycheck
$wait
clear

echo "------------------------------"
echo "# Suckless software"
echo "------------------------------"
echo -ne $newline

echo "Create a .config directory"
mkdir $HOME/.config
$wait
echo -ne $newline

# echo "Cloning 'DWM' repository"
# echo -ne $newline
# git clone https://github.com/marcellbarsony/dwm.git $HOME/.config/dwm
# $wait
# echo -ne $newline

echo "Cloning 'DWM - flexipatch' repository"
echo -ne $newline
git clone https://github.com/bakkeby/dwm-flexipatch.git $HOME/.config/dwm_flexipatch

echo "Cloning 'st' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/st.git $HOME/.config/st
$wait
echo -ne $newline

echo "Cloning 'dmenu' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/dmenu.git $HOME/.config/dmenu
$wait
echo -ne $newline

echo "Cloning 'slstatus' repository"
echo -ne $newline
git clone https://git.suckless.org/slstatus $HOME/.config/slstatus
$wait
echo -ne $newline
clear

echo "Changing directory to ~/.config/dwm & compiling"
echo -ne $newline
cd $HOME/.config/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/st & compiling"
echo -ne $newline
cd $HOME/.config/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/dmenu & compiling"
echo -ne $newline
cd $HOME/.config/dmenu
sudo make clean install
$wait
clear

echo "Changing directory to ~/.config/slstatus & compiling"
echo -ne $newline
cd $HOME/.config/slstatus
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
# mv $HOME/.bash_history $HOME/dotfiles/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Moving .bash_logout"
# mv $HOME/.bash_logout $HOME/dotfiles/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Removing .bash_profile"
# mv $HOME/.bash_profile $HOME/dotfiles/_legacy/bash
# copycheck
# echo -ne $newline

# echo "Removing .bashrc"
# mv $HOME/.bashrc $HOME/dotfiles/_legacy/bash
# copycheck
# echo -ne $newline

# --------------------------------------------------
# REBOOT
# --------------------------------------------------

# $wait
# sudo reboot now
