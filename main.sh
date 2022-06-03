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
      systemclock
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

systemclock(){

  echo -n "Set system time with timedatectl..."
  sleep 1
  timedatectl set-ntp true --no-ask-password

  case $? in
    0)
      echo "[Done]"
      dependencies
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac

}

dependencies(){

  echo -n "Installing dependencies..."
  pacman -Sy --noconfirm libnewt dialog 2>&1 >/dev/null # reflector
  #pacman -Sy --noconfirm libnewt dialog 2>&1 >/dev/null # reflector

  case $? in
    0)
      echo "[Done]"
      keymap
      ;;
    *)
      echo "[ERROR]"
      echo "Exit status $?"
      ;;
  esac

}

keymap(){

  items=$(localectl list-keymaps)
  options=()
  options+=("us" "[Default]")
    for item in ${items}; do
      options+=("${item}" "")
    done

  keymap=$(whiptail --title "Keyboard Layout" --menu "" 30 50 20 "${options[@]}" 3>&1 1>&2 2>&3)
  #keymap=$(dialog --title "Keymap" --menu "menu" 20 50 10 ${options[@]} 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then
    clear
    echo "loadkeys ${keymap}"
    loadkeys ${keymap}
    localectl set-keymap --no-convert ${keymap} # Systemd - /etc/vconsole.conf
    warning
  fi

}

warning(){

  if (whiptail --title "WARNING" --yesno "All data will be erased - Proceed with the installation?" --defaultno 8 60); then
      diskselect
  else
      echo "Installation terminated"
      echo "Exit status $?"
  fi

}

diskselect(){

  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  for item in ${items}; do
    options+=("${item}" "")
  done

  disk=$(whiptail --title "Diskselect" --menu "menu" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

  if [ "$?" != "0" ]
    then
      echo "Exit status $?"
  fi
    echo ${disk%%\ *}
    echo "Exit status $?"
    sleep 2
    diskpart

}

diskpart(){

  options=()
  options+=("fdisk" "")
  options+=("cfdisk" "")

  sel=$(whiptail --backtitle "${apptitle}" --title "Diskpart" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    case ${sel} in
      "fdisk")
          fdisk ${disk}
          ;;
      "cfdisk")
          cfdisk ${disk}
          ;;
    esac

  diskpartmenu

  else
    case $? in
    1)
      echo "Cancel pressed"
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac

  fi

}

diskpartmenu(){

  options=()
  options+=("PM-1" "[GPT+EFI+Luks]")
  options+=("VM-1" "[GPT+EFI)")

  sel=$(whiptail --backtitle "${apptitle}" --title "Diskpartmenu" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    case ${sel} in
      "PM-1")
          echo "1st option"
      ;;
      "VM-1")
          echo "2nd option"
      ;;
    esac

  echo "Next item: ${sel}"

  else
    case $? in
    1)
      echo "Cancel pressed"
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac

  fi

}

diskpartconfirm(){
}

# -------------------------------
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
diskselect
#diskpartmenu
