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
      echo "[ERROR]"
      echo "Exit status $?"
      ;;
  esac

}

bootmode(){

  echo -n "Checking boot mode..."
  sleep 1
  ls /sys/firmware/efi/efivars 2>&1 >/dev/null

  case $? in
    0)
      echo "[UEFI]"
      dependencies
      ;;
    1)
      echo "[BIOS]"
      echo "https://wiki.archlinux.org/title/installation_guide#Verify_the_boot_mode"
      exit 1
      ;;
    *)
      echo "[ERROR]"
      echo "Exit status $?"
      ;;
  esac

}

dependencies(){

  echo -n "Installing dependencies..."
  sudo pacman -Sy --noconfirm libnewt dialog 2>&1 >/dev/null
  #pacman -Sy --noconfirm libnewt dialog 2>&1 >/dev/null

  case $? in
    0)
      echo "[Done]"
      keyboardlayout
      ;;
    *)
      echo "[ERROR]"
      echo "Exit status $?"
      ;;
  esac

}

setkeymap(){

  items=$(localectl list-keymaps)
  options=()
  for item in ${items}; do
    options+=("us" "")
    options+=("${item}" "")
  done

  keymap=$(whiptail --backtitle "${apptitle}" --title "${txtsetkeymap}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  #keymap=$(dialog --title "Keymap" --menu "menu" 20 50 10 ${options[@]} 3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "loadkeys ${keymap}"
    loadkeys ${keymap}
    pressanykey
  fi

}

keyboardlayout(){

  options=("us" "Default")
  items=$(localectl list-keymaps)

  for item in $item
  do
      options+=("${item}" "---")
  done

  keymap=$(whiptail --title "Keymap" --menu "menu" 20 50 10 ${options[@]} 3>&1 1>&2 2>&3)
  keymap=$(whiptail --title "Keymap" --menu "menu" 20 50 10 ${items[@]} 3>&1 1>&2 2>&3)
  #keymap=$(dialog --title "Keymap" --menu "menu" 20 50 10 ${options[@]} 3>&1 1>&2 2>&3)

  case $? in
    0)
      echo "Slected keymap: $keymap"
      #localectl set-keymap --no-convert $keymap
      ;;
    1)
      echo "CANCEL pressed"
      ;;
    255)
      echo "ESC pressed"
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac

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
#network
#keyboardlayout
setkeymap
