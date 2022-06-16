#!/bin/bash

paru(){

  git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
  cd $HOME/.local/src/paru
  makepkg -si --noconfirm
  cd $HOME

  rbw

}

rbw(){

  paru -S --noconfirm --quiet rbw
  sudo pacman -S --noconfirm github-cli

}
