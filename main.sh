#!/bin/bash

# Dependencies
dependencies(){
  if ! [ -x "$(command -v dialog)" ]
    then
      echo "Installing dependencies"
      sudo pacman -Sy --noconfirm dialog
      dependencies
    else
      echo "Dependencies installed"
      bootmode
  fi
}

# Boot mode
bootmode(){
  if [ -d /sys/firmware/efi/efivars ]
    then
      note
    else
      echo "System is booted in BIOS mode."
      exit 1
  fi
}

# Note
note(){
  dialog --title "Important note" --defaultno --yesno "Proceed with the installation?" 8 50 3>&1 1>&2 2>&3
  case $? in
    0)
      echo "Yes chosen."
      keyboardlayout
      ;;
    1)
      echo "No chosen."
      ;;
    255)
      echo "Esc pressed."
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac
}

# Keyboard Layout
keyboardlayout(){
  options=("us" "Default")
  items=$(localectl list-keymaps)
  for item in $items
    do
      options+=("${item}" "---")
    done
  keymap=$(dialog --title "Keymap" --menu "menu" 20 78 10 ${options[@]} 3>&1 1>&2 2>&3)
  case $? in
    0)
      echo "Slected keymap: $keymap"
      #localectl set-keymap --no-convert $keymap
      ;;
    1)
      echo "CANCEL pressed."
      ;;
    255)
      echo "ESC pressed."
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac
}

# Select Disk
diskselect(){
  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  IFS_ORIG=$IFS
  IFS=$'\n'
  for item in ${items}
    do
      options+=("${item}" "")
    done
  IFS=$IFS_ORIG
  disk=$(dialog --title "Diskselect" --menu "menu" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
  if [ "$?" != "0" ]
    then
      return 1
  fi
    echo ${disk%%\ *}
    return 0
}

# Disk Partitioning
#diskpartmenu(){
#  device=$(diskselect "(GPT, EFI)"
#}

# -------------------------------
# -------------------------------

# Script Info
while (( "$#" ));
do
	case ${1} in
		--help)
      echo "------"
      echo "Arch installation script"
      echo "------"
      exit 0
    ;;
    --info)
      echo "Author: Marcell Barsony"
      echo "Important note: This script is under development"
      exit 0
    ;;
    *)
      echo "Available options:"
      echo "Help --help"
      echo "Info --info"
  esac
  shift
done

dependencies
