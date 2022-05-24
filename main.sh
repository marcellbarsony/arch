#!/bin/bash

network(){

  echo -n "Checking network connection..."
  ping -q -c 3 archlinux.org 2>&1 >/dev/null

    case $? in
      0)
        echo "[Connected]"
        # dependencies
        test
        ;;
      1)
        echo "[Disconnected]"
        connection
        ;;
      *)
        echo "[Exit status $?]"
        ;;
    esac

}

connection(){
  echo -n "(R)etry / (W)i-Fi / (M)anual "
  read -s -n 1 keypress

    case $keypress in
      [rR])
        echo "[Retry]"
        clear
        network
        ;;
      [wW]  )
        echo "[Wi-Fi]"
        #wifi-m
        ;;
      [wW]  )
        echo "[Wi-Fi Manual]"
        #iwctl
        ;;
      *)
        echo "[Exit status $?]"
        connection
        ;;
    esac
}

wifi(){
  # Read SSID
  # Read Password
  # Connect
  iwctl --passphrase $passphrase station $device connect $SSID
}

wifi-manual(){

  iwctl

    case $? in
      0)
        echo "WIFI CONNECTION SUCCESFUL"
        # dependencies
        ;;
      1)
        echo "Not connected"
        network
        ;;
      *)
        echo "[Exit status $?]"
        ;;
    esac

}

dependencies(){

  echo "Checking dependencies..."
  sleep 3

  declare -a dependencies=("whiptail") #Array without comma separation

  for dependency in ${dependencies[@]}; do
    command -v ${dependency} 1> /dev/null
    if [ "$?" = "0" ];
      then
        echo "${dependency} [Installed]"
      else
        echo "Installing ${dependency}"
        sudo pacman -Sy ${dependency}
    fi
  done
  case $? in
    0)
      bootmode
      ;;
    *)
      echo "Exit status $? [Dependencies were not installed]"
      ;;
  esac
}

bootmode(){
  if [ -d /sys/firmware/efi/efivars ]
    then
      note
    else
      echo "System is booted in BIOS mode."
      exit 1
  fi
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
#  device=$(diskselect "(GPT, EFI)"
#}

# -------------------------------
# -------------------------------

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

network
