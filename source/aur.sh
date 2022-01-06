#!/bin/sh

echo "------------------------------"
echo "# AUR helper - PARU"
echo "------------------------------"
echo

echo "# LeftWM"
echo
paru -S --noconfirm leftwm-git
clear

echo "# LibreWolf"
echo
paru -S --noconfirm librewolf-bin
clear

echo "# Polybar"
echo
paru -S --noconfirm polybar-git
clear

echo "# Starship prompt"
echo
cd $HOME/.local/src/
mkdir starship
cd starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
cd $HOME
clear

echo "# Dmenu-rs"
echo
paru -S --noconfirm dmenu-rs-git
clear

echo "# Bitwarden-rs"
echo
paru -S --noconfirm rbw
clear

echo "VS Codium"
echo
paru -S --noconfirm vscodium-bin
clear

echo "Spotify TUI"
echo
paru -S --noconfirm spotify-tui-bin
clear

# echo "Joplin"
# echo
# paru -S --noconfirm joplin-desktop
# clear
