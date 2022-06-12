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
          exit 1
          ;;
        * )
          echo invalid response
          bootmode
          ;;
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

  case $? in
    0)
      echo ${disk%%\ *}
      diskpart
      ;;
    1)
      keymap
      ;;
    *)
      echo "Exit status $?"
      ;;
  esac

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

    diskpartcheck

    else

    case $? in
      1)
        diskselect
        ;;
      *)
        echo "Exit status $?"
        ;;
      esac

  fi

}

diskpartcheck(){

  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)

  if (whiptail --title "Confirm partitions" --yesno "${items}" 18 78); then
      installscheme
    else
      diskselect
  fi

}

installscheme(){

  options=()
  options+=("Physical Machine 1" "[GPT+EFI+LVM on Luks]")
  options+=("Virtual Machine 1" "[GPT+EFI+No encryption]")

  installscheme=$(whiptail --title "Install scheme" --menu "Install scheme" 18 78 0 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    case ${installscheme} in
      "Physical Machine 1")
        pm-1
        ;;
      "Virtual Machine 1")
        vm-1
        ;;
    esac

    else
      case $? in
        1)
          diskselect
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

  fi

}

pm-1()(

  ### PARTITION SCHEME ###
  # Partition 1 | EFI System Partition | (min. 256MB) | [EFI System] ..... |
  # Partition 2 | Boot ............... | (min. 512MB) | [Linux Filesystem] |
  # Partition 3 | Root ............... | ............ | [Linux LVM] ...... |

  fsselect(){

    options=()
    options+=("ext4" "[Default]")
    options+=("btrfs" "[-]")

    filesystem=$(whiptail --title "[VM-1] File System" --menu "File system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

      efiselect

      else

        case $? in
          1)
            installscheme
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
        fsselect
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  efifilesystem(){

    options=()
    options+=("FAT32" "[Default]")

    efifilesystem=$(whiptail --title "[PM-1] EFI" --menu "EFI file system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

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
            efiselect
            ;;
          *)
            echo "Exit status $?"
            ;;
        esac

    fi

  }

  efiformat(){

    mkfs.${efifs} ${efidevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    bootselect

  }

  bootselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    bootdevice=$(whiptail --title "[PM-1] BOOT" --menu "BOOT partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        bootformat
        ;;
      1)
        efifilesystem
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  bootformat(){

    mkfs.${filesystem} ${bootdevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${bootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    lvmselect

  }

  lvmselect(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    lvmdevice=$(whiptail --title "[PM-1] LVM" --menu "LVM partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        cryptpassword
        ;;
      1)
        bootselect
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  cryptpassword(){

    cryptpassword=$(whiptail --passwordbox "Encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

    case $? in
      0)
        cryptpassword_confirm
        ;;
      1)
        lvmselect
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  cryptpassword_confirm(){

    cryptpassword_confirm=$(whiptail --passwordbox "Confirm encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

    case $? in
      0)
        cryptfile
        ;;
      1)
        cryptpassword
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  cryptfile(){

    echo "cryptfile" > /root/arch/log.txt
    keydir=/root/luks.key
    keydir2=/root/luks.key2

    echo "$cryptpassword" > "$keydir"
    local exitcode1=$?

    echo "$cryptpassword_confirm" > "$keydir2"
    local exitcode2=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Key file [${keydir}] could not be created.\nExit status 1: ${exitcode1}\nExit status 2: ${exitcode2}" 12 78
        exit 1
    fi

    # Password match
    if cmp --silent -- "$keydir" "$keydir2"; then
      cryptsetup_create
    else
      whiptail --title "ERROR" --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
      cryptpassword
    fi

  }

  cryptsetup_create(){

    echo "cryptsetup_create" >> /root/arch/log.txt
    cryptsetup -q --type luks2 luksFormat ${lvmdevice} --key-file ${keydir}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Encrypting [${lvmdevice}] unsuccessful.\nExit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    cryptsetup_open

  }

  cryptsetup_open(){

    echo "cryptsetup_open" >> /root/arch/log.txt
    cryptsetup open --type luks ${lvmdevice} cryptlvm --key-file ${keydir}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "LVM device [${lvmdevice}] could not be opened.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    physicalvolume

  }

  physicalvolume(){

    echo "physicalvolume" >> /root/arch/log.txt
    pvcreate /dev/mapper/cryptlvm
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Physical volume could not be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volumegroup

  }

  volumegroup(){

    echo "volumegroup" >> /root/arch/log.txt
    vgcreate volgroup0 /dev/mapper/cryptlvm
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Volume group [volgroup0] could not be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    rootsize

  }

  rootsize(){

    echo "rootsize" >> /root/arch/log.txt
    rootsize=$(whiptail --inputbox "Root size [GB]" 8 39 --title "ROOT filesystem" 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ ${exitcode} = 0 ]; then
        if [[ $rootsize ]] && [ $rootsize -eq $rootsize 2>/dev/null ]; then
          rootcreate
        else
          whiptail --title "ERROR" --msgbox "Value is not an integer.\nExit status: ${?}" 8 78
          rootsize
        fi
    else
        echo "Cancel selected"
    fi

    echo "(Exit status was $exitstatus)"

  }

  rootcreate(){

    echo "rootcreate" >> /root/arch/log.txt
    lvcreate -L ${rootsize}GB volgroup0 -n cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT filesystem [cryptroot] could not be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    homecreate

  }

  homecreate(){

    echo "homecreate" >> /root/arch/log.txt
    lvcreate -l 100%FREE volgroup0 -n crypthome
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "HOME filesystem [crypthome] could not be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    modprobe

  }

  modprobe(){

    echo "modprobe" >> /root/arch/log.txt
    modprobe dm_mod
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [modprobe dm_mod] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volgroup_scan

  }

  volgroup_scan(){

    echo "volgroup_scan" >> /root/arch/log.txt
    vgscan
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Scanning volume groups [vgscan] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volgroup_activate

  }

  volgroup_activate(){

    echo "volgroup_activate" >> /root/arch/log.txt
    vgchange -ay
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [vgchange -ay] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    rootformat

  }

  rootformat(){

    echo "rootformat" >> /root/arch/log.txt
    mkfs.${filesystem} /dev/volgroup0/cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting [/dev/volgroup0/cryptroot] to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    rootmount

  }

  rootmount(){

    echo "rootmount" >> /root/arch/log.txt
    mount /dev/volgroup0/cryptroot /mnt
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT partition [/dev/volgroup0/cryptroot] was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    bootmount

  }

  bootmount(){

    echo "bootmount" >> /root/arch/log.txt
    mkdir /mnt/boot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "BOOT directory was not created.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mount ${bootdevice} /mnt/boot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "BOOT partition was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    homeformat

  }

  homeformat(){

    echo "homeformat" >> /root/arch/log.txt
    mkfs.${filesystem} /dev/volgroup0/crypthome
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting [/dev/volgroup0/crypthome] to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    homemount

  }

  homemount(){

    echo "homemount" >> /root/arch/log.txt
    mkdir /mnt/home
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "HOME directory was not created.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mount /dev/volgroup0/crypthome /mnt/home
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "HOME partition was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    fstab

  }

  fsselect

)

vm-1()(

  fsselect(){

    options=()
    options+=("ext4" "[Default]")
    options+=("btrfs" "[-]")

    filesystem=$(whiptail --title "[VM-1] File System" --menu "File system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

      efiselect

      else

        case $? in
          1)
            installscheme
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
        fsselect
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  efifilesystem(){

    options=()
    options+=("FAT32" "[Default]")

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
            efiselect
            ;;
          *)
            echo "Exit status $?"
            ;;
        esac

    fi


  }

  efiformat(){

    mkfs.${efifs} ${efidevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to ${efifs} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
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
        efifilesystem
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  rootformat(){

    mkfs.${filesystem} ${rootdevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${rootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    mountefi

  }

  mountefi(){

    mkdir /efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI directory was not created.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mount ${efidevice} /efi
    #mount --mkdir ${efidevice} /efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mountroot

  }

  mountroot(){

    mount ${rootdevice} /mnt
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    fstab

  }

  fsselect

)

fstab(){

  mkdir /mnt/etc/
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab directory was not created.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  genfstab -U /mnt >> /mnt/etc/fstab
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab config was not generated.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  mirrorlist

}

mirrorlist(){

  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Mirrorlist could not be backed up.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  reflector --latest 25 --connection-timeout 3 --sort rate --save /etc/pacman.d/mirrorlist
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Mirrorlist could not be updated.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  kernel

}

kernel(){

  if [ "${installscheme}" = "Physical Machine 1" ]; then
      pacstrap /mnt base linux linux-firmware linux-headers base-devel git vim lvm2
      local exitcode=$?
    else
      pacstrap /mnt base linux linux-firmware linux-headers base-devel git vim virtualbox-guest-utils
      local exitcode=$?
  fi

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Packages were not installed.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  chroot

}

chroot (){

  arch-chroot /mnt
  # arch-chroot [options] chroot-dir [command]
  local exitcode=$?

  if [ "${?}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Could not chroot into /mnt.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

}

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
#keymap
#diskselect
#diskpartconfirm
#diskpartmenu
#diskpartcheck
#fsselect

# NOTES
# Secure boot: https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot
# Minimal Arch install by ML: https://gist.github.com/mattiaslundberg/8620837
# PM Encrypted UEFI Arch install: https://gist.github.com/HardenedArray/31915e3d73a4ae45adc0efa9ba458b07
# VM Encrypted UEFI Arch install: https://gist.github.com/HardenedArray/d5b70681eca1d4e7cfb88df32cc4c7e6
