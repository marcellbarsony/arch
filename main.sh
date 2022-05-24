#!/bin/bash

network(){

  echo -n "Checking network..."
  ping -q -c 3 archlinux.org 2>&1 >/dev/null

    case $? in
      0)
        echo "[Connected]"
        bootmode
        ;;
      1)
        echo "[DISCONNECTED]"
        exit 1
        ;;
      *)
        echo "[Exit status $?]"
        ;;
    esac

}

bootmode(){

  echo -n "Checking boot mode..."
  sleep 1

  if [ -d /sys/firmware/efi/efivars ]
    then
      echo "[UEFI]"
      dependencies
    else
      echo "[BIOS]"
      echo "https://wiki.archlinux.org/title/installation_guide#Verify_the_boot_mode"
      exit 1
  fi

}

dependencies(){

  echo -n "Checking dependencies..."
  sleep 1

  declare -a dependencies=("whiptail") #Array without comma separation

  for dependency in ${dependencies[@]}; do
    command -v ${dependency} 1> /dev/null
    case $? in
      0)
        echo "[Installed]"
        ;;
      1)
        echo "[Missing]"
        packages
        ;;
      *)
        echo "[ERROR] - Exit status $?"
        ;;
    esac
  done

}

packages(){

  echo -n "Installing packages..."
  sleep 1

  declare -a packages=("libnewt") #Array without comma separation

  for package in ${packages[@]}; do
    sudo pacman -Sy --noconfirm ${package} 2>&1 >/dev/null
    case $? in
      0)
        echo "[Done]"
        ;;
      *)
        echo "[ERROR] - Exit status $?"
        ;;
    esac
  done

}

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

keyboardlayout(){
  options=("us" "Default")
  items=$(localectl list-keymaps)
  for item in $items
    do
      options+=("${item}" "---")
    done
  keymap=$(whiptail --title "Keymap" --menu "menu" 20 78 10 ${options[@]} 3>&1 1>&2 2>&3)
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

#diskpartmenu(){
  #device=$(diskselect "(GPT, EFI)"
#}

# -------------------------------
# -------------------------------

while (( "$#" )); do
  case ${1} in
    --help)
      echo "------"
      echo "Arch installation script"
      echo "------"
      exit 0
    ;;
    --info)
      echo "Author: Marcell Barsony"
      echo "Repository: https://github.com/marcellbarsony/arch"
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

clear
network
