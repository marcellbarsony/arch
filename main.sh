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
      read -p "Continue installation? (Y/N)" yn

      case $yn in
        [Yy])
          systemclock
          ;;
        [Nn])
          exit
          ;;
        * )
          echo invalid response;
      esac
      ;;
    *)
      echo "[ERROR]"
      echo "Exit status $?"
      echo "https://wiki.archlinux.org/title/installation_guide#Verify_the_boot_mode"
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
      echo "\nExit status $?"
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

  disk=$(whiptail --title "Diskselect" --menu "Select disk to format" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

  if [ "$?" != "0" ]
    then
      echo "Exit status $?"
  fi
    echo ${disk%%\ *}
    diskpart

}

diskpart(){

  options=()
  options+=("fdisk" "")
  options+=("cfdisk" "")
  options+=("gdisk" "")
  #options+=("sgdisk" "") #https://man.archlinux.org/man/sgdisk.8

  sel=$(whiptail --backtitle "${apptitle}" --title "Diskpart" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    case ${sel} in
      "fdisk")
        clear
        fdisk ${disk}
        ;;
      "cfdisk")
        clear
        cfdisk ${disk}
        ;;
      "gdisk")
        clear
        gdisk ${disk}
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
  options+=("PM-1" "[GPT + EFI + LVM on Luks]")
  options+=("VM-1" "[GPT + EFI + No encryption]")

  sel=$(whiptail --backtitle "${apptitle}" --title "Diskpartmenu" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    case ${sel} in
      "PM-1")
        pm-1
        ;;
      "VM-1")
        vm-1
        ;;
    esac

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

pm-1()(

  fsselect(){

    options=()
    options+=("ext4" "[Default]")
    options+=("btrfs" "-")

    fsselect=$(whiptail --title "File System" --menu "Select file system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

        efiselect

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

  ### PARTITION SCHEME ###
  # Partition 1 | EFI System Partition | (min. 256MB) | [EFI System] ..... |
  # Partition 2 | Boot ............... | (min. 512MB) | [Linux Filesystem] |
  # Partition 3 | Root ............... | ............ | [Linux LVM] ...... |

  efiselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    efidevice=$(whiptail --title "[VM-1] EFI" --menu "EFI partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        efifilesystem
        ;;
      1)
        echo "Cancel pressed"
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  efiformat(){

    echo "Formatting: ${efidevice}"
    #mkfs.fat -F32 ${efidevice}
    local exitcode=$?

    if [ ${exitcode} = "0" ]; then
      echo "${efidevice} formatted"
      whiptail --title "EFI Formatting (FAT32)" --msgbox "Formatting ${efidevice} to FAT32 successful." 8 78
      rootselect
    else
      whiptail --title "EFI Formatting (FAT32)" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
      diskselect
    fi

  }

  rootselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    rootdevice=$(whiptail --title "Diskselect" --menu "Select ROOT drive" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
    0)
      echo "Selected ROOT device: ${rootdevice}"
      rootformat
      ;;
    1)
      echo "Cancel pressed"
      ;;
    *)
      echo "Exit status $?"
      ;;
    esac

  }

  rootformat(){

    # Mount point: /mnt
    # Partition: /dev/root_partition

    echo "Formatting: ${rootdevice}"
    #mkfs.ext4 ${rootdevice}
    local exitcode=$?

    if [ ${exitcode} = "0" ]; then
      echo "${rootdevice} formatted"
      whiptail --title "EFI Formatting (FAT32)" --msgbox "Formatting ${efidevice} to FAT32 successful." 8 78
      rootselect
    else
      whiptail --title "EFI Formatting (FAT32)" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
      diskselect
    fi

  }

  fsselect

)

vm-1()(

  fsselect(){

    options=()
    options+=("ext4" "[Default]")
    options+=("btrfs" "[ - ]")

    filesystem=$(whiptail --title "[VM-1] File System" --menu "File system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

      #  case ${filesystem} in
      #    "ext4")
      #       echo "EXT4 selected."
      #       ;;
      #    "btrfs")
      #       echo "BTRFS selected."
      #       ;;
      #  esac

      efiselect

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

  efiselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    efidevice=$(whiptail --title "[VM-1] EFI" --menu "EFI partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        efifilesystem
        ;;
      1)
        echo "Cancel pressed"
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  efifilesystem(){

    options=()
    options+=("FAT32" "[Default]")
    options+=("ext4" "[ - ]")
    options+=("ext3" "[ - ]")

    efifilesystem=$(whiptail --title "[VM-1] EFI" --menu "EFI file system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

        case ${efifilesystem} in
          "FAT32")
            efifs="fat -F32"
            ;;
          "ext4")
            echo "Not recommended"
            exit 1
            ;;
        esac

        efiformat

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

  efiformat(){

    #echo "Success [efiformat]"
    mkfs.${efifs} ${efidevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
        diskselect
    fi

    rootselect

  }

  rootselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    rootdevice=$(whiptail --title "[VM-1] ROOT" --menu "ROOT partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        rootformat
        ;;
      1)
        echo "Cancel pressed"
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  rootformat(){

    #echo "Success [rootformat]"
    mkfs.${filesystem} ${rootdevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${rootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        diskselect
    fi

    mountefi

  }

  mountefi(){

    #echo "Success [efidir]"
    mkdir /efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI directory was not created.\nExit status: ${exitcode}" 8 60
      diskpartmenu
    fi

    #echo "Success [efimount]"
    mount ${efidevice} /efi
    #mount --mkdir ${efidevice} /efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
      diskpartmenu
    fi

    mountroot

  }

  mountroot(){

    #echo "Success [rootmount]"
    mount ${rootdevice} /mnt
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT partition was not mounted\nExit status: ${exitcode}" 8 60
      diskpartmenu
    fi

    fstab

  }

  fsselect

)

fstab(){

  #echo "Success [fstab - dir]"
  mkdir /mnt/etc/
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab directory was not created.\nExit status: ${exitcode}" 8 60
    diskpartmenu
  fi

  #echo "Success [fstab - gen]"
  genfstab -U /mnt >> /mnt/etc/fstab
  #genfstab -L /mnt >> /mnt/etc/fstab
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab config was not generated.\nExit status: ${exitcode}" 8 60
    diskpartmenu
  fi

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
network
#diskselect
#diskpartconfirm
#diskpartmenu
#fsselect

# NOTES
# Secure boot: https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot
# Minimal Arch install by ML: https://gist.github.com/mattiaslundberg/8620837
# PM Encrypted UEFI Arch install: https://gist.github.com/HardenedArray/31915e3d73a4ae45adc0efa9ba458b07
# VM Encrypted UEFI Arch install: https://gist.github.com/HardenedArray/d5b70681eca1d4e7cfb88df32cc4c7e6
