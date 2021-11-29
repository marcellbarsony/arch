#!/bin/sh

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