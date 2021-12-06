#!/bin/sh

echo "------------------------------"
echo "# Suckless"
echo "------------------------------"
echo

#echo "Cloning 'dwm' repository"
#echo
#git clone https://github.com/marcellbarsony/dwm.git $HOME/.local/src/dwm
#echo

#echo "Cloning 'st' repository"
#echo
#git clone https://github.com/marcellbarsony/st.git $HOME/.local/src/st
#echo

echo "Cloning 'dmenu' repository"
echo
git clone https://github.com/marcellbarsony/dmenu.git $HOME/.local/src/dmenu
echo

#echo "Cloning 'slstatus' repository"
#echo
#git clone https://github.com/marcellbarsony/slstatus.git $HOME/.local/src/slstatus
#clear

#echo "Changing directory to ~/.local/src/dwm & compiling"
#echo
#cd $HOME/.local/src/dwm
#sudo make clean install
#clear

#echo "Changing directory to ~/.local/src/st & compiling"
#echo
#cd $HOME/.local/src/st
#sudo make clean install
#clear

echo "Changing directory to ~/.local/src/dmenu & compiling"
echo
cd $HOME/.local/src/dmenu
sudo make clean install
clear

#echo "Changing directory to ~/.local/src/slstatus & compiling"
#echo
#cd $HOME/.local/src/slstatus
#sudo make clean install
#clear