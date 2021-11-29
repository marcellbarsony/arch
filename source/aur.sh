#!/bin/sh

echo "------------------------------"
echo "# AUR helper - PARU"
echo "------------------------------"
echo

git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
cd $HOME/.local/src/paru
makepkg -si --noconfirm
cd $HOME
clear

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