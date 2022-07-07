#!/bin/bash

precheck()(

  network(){

    echo -n "Checking network connection..."
    ping -q -c 3 archlinux.org &>/dev/null

    case $? in
      0)
        echo "[OK]"
        bootmode
        ;;
      1)
        echo "[DISCONNECTED]"
        echo "Please connect to a network and try again."
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
    ls /sys/firmware/efi/efivars &>/dev/null

    case $? in
      0)
        echo "[UEFI]"
        dmidata
        ;;
      1)
        echo "[BIOS]"
        echo "BIOS is not supported."
        exit 1
        ;;
      *)
        echo "[ERROR]"
        echo "Exit status $?"
        echo "https://wiki.archlinux.org/title/installation_guide#Verify_the_boot_mode"
        ;;
    esac

  }

  dmidata(){

    echo -n "Fetching DMI data..."
    sleep 1
    dmi=$(dmidecode -s system-product-name)

    if [ ${dmi} == "VirtualBox" ] || ${dmi} == "VMware Virtual Platform" ]; then
        echo "[Virtual Machine]"
      else
        echo "[Physical Machine]"
    fi

    systemclock

  }

  systemclock(){

    echo -n "Updating system clock..."
    sleep 1
    timedatectl set-ntp true --no-ask-password

    case $? in
      0)
        echo "[OK]"
        keymap
        ;;
      *)
        echo "\nExit status $?"
        ;;
    esac

  }

  keymap(){

    echo -n "Setting US keymap..."
    loadkeys us &>/dev/null
    localectl set-keymap --no-convert us &>/dev/null # Systemd reads from /etc/vconsole.conf

    case $? in
      0)
        echo "[OK]"
        dependencies
        ;;
      *)
        echo "[ERROR]"
        echo "Exit status $?"
        ;;
    esac

  }

  dependencies(){

    echo -n "Installing dependencies..."
    pacman -Sy --noconfirm dialog &>/dev/null #libnewt
    DIALOGRC=/root/arch/cfg/dialogrc

    case $? in
      0)
        echo "[OK]"
        configs
        ;;
      *)
        echo "[ERROR]"
        echo "Exit status $?"
        ;;
    esac

  }

  configs(){

    echo -n "Getting configs ready..."
    sleep 1
    cp $HOME/arch/cfg/dialogrc $HOME/.dialogrc

    case $? in
      0)
        echo "[OK]"
        partition
        ;;
      *)
        echo "[ERROR]"
        echo "Exit status $?"
        ;;
    esac

  }

  network

)

partition()(

  warning(){

    if (dialog --title " WARNING " --yes-label "Proceed" --no-label "Exit" --yesno "\nEverything not backed up will be lost." 8 60); then
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

    disk=$(dialog --title " Disk " --menu "Select disk to format" 15 70 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        echo ${disk%%\ *}
        clear
        sgdisk_partition
        ;;
      1)
        keymap
        exit 1
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  sgdisk_partition(){

    sgdisk -o ${disk}
    local exitcode1=$?

    sgdisk -n 0:0:+750MiB -t 0:ef00 -c 0:efi ${disk}
    local exitcode2=$?

    #sgdisk -n 0:0:+1GiB -t 0:8300 -c 0:boot ${disk}
    #local exitcode3=$?

    sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem ${disk}
    local exitcode4=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode4}" != "0" ] ; then
      dialog --title " ERROR " --msgbox "\nSgdisk: cannot create partitions\n\n
      Exit status [clear ]: ${exitcode1}\n
      Exit status [/efi  ]: ${exitcode2}\n
      Exit status [/boot ]: ${exitcode3}\n
      Exit status [/     ]: ${exitcode4}" 13 55
      exit 1
    fi

    diskpart_check

  }

  diskpart_check(){

    items=$( gdisk -l ${disk} | tail -4 )

    if (dialog --title " Partitions " --yes-label "Confirm" --no-label "Manual" --yesno "\nConfirm partitions:\n\n${items}" 15 60); then
        setup_dialog
      else
        sgdisk --zap-all ${disk}
        diskpart_manual
    fi

  }

  diskpart_manual(){

    options=()
    options+=("cfdisk" "")
    options+=("fdisk" "")
    options+=("gdisk" "")

    diskpart_tool=$(dialog --title " Diskpart " --menu "" 10 30 3 "${options[@]}" 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

      case ${diskpart_tool} in
        "cfdisk")
          clear
          cfdisk ${disk}
          diskpart_check
          ;;
        "fdisk")
          clear
          fdisk ${disk}
          diskpart_check
          ;;
        "gdisk")
          clear
          gdisk ${disk}
          diskpart_check
          ;;
      esac
      else

      case $? in
        1)
          diskselect
          ;;
        *)
          echo "Exit status: $?"
          ;;
        esac

    fi

  }

  warning

)

setup_dialog()(

  filesystem_dialog()(

    select_efi(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      efidevice=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [EFI]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          select_root
          ;;
        1)
          partition
          ;;
        *)
          dialog --title " ERROR " --msgbox "Error status: ${?}" 8 78
          exit $?
          ;;
      esac

    }

    select_boot(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      bootdevice=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [Boot]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          select_root
          ;;
        1)
          select_efi
          ;;
        *)
          whiptail --title " ERROR " --msgbox "Error status: ${?}" 8 78
          ;;
      esac

    }

    select_root(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      rootdevice=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [Root]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          encryption_dialog
          ;;
        1)
          select_efi
          ;;
        *)
          whiptail --title " ERROR " --msgbox "Error status: ${?}" 8 78
          ;;
      esac

    }

    select_efi

  )

  encryption_dialog()(

    crypt_password(){

      cryptpassword=$(dialog --nocancel --passwordbox "Encryption passphrase" 8 45 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_password_confirm
          ;;
        *)
          echo "Exit status: $?"
          ;;
      esac

    }

    crypt_password_confirm(){

      cryptpassword_confirm=$(dialog --nocancel --passwordbox "Encryption passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_password_check
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

    }

    crypt_password_check(){

      if [ ! ${cryptpassword} ] || [ ! ${cryptpassword_confirm} ]; then
        dialog --title " ERROR " --msgbox "Encryption passphrase cannot be empty." 8 45
        crypt_password
      fi

      if [[ "${cryptpassword}" != "${cryptpassword_confirm}" ]]; then
        dialog --title " ERROR " --msgbox "Encryption passphrase did not match." 8 45
        crypt_password
      fi


      crypt_setup

    }

    key_file(){

      keydir=/root/luks.key
      keydir2=/root/luks.key2

      echo "$cryptpassword" > "$keydir"
      local exitcode1=$?

      echo "$cryptpassword_confirm" > "$keydir2"
      local exitcode2=$?

      if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
          dialog --title "ERROR" --msgbox "Key file [${keydir}] cannot be created.\n
          Exit status [File 1]: ${exitcode1}\n
          Exit status [File 2]: ${exitcode2}" 12 78
          exit 1
      fi

      # Password match
      if cmp --silent -- "$keydir" "$keydir2"; then
          crypt_setup
        else
          dialog --title " ERROR " --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
          crypt_password
      fi

    }

    crypt_password

  )

  filesystem_dialog

)

crypt_setup()(

  cryptsetup_create(){

    echo ${cryptpassword} | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat ${rootdevice}
    local exitcode=$?

    #https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Keyfiles

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Encrypting [${rootdevice}] unsuccessful.\nExit status: ${exitcode}" 7 50
      exit ${exitcode}
    fi

    # Check keyslots
    # cryptsetup luksDump /dev/sda

    cryptsetup_open

  }

  cryptsetup_open(){

    echo ${cryptpassword} | cryptsetup open --type luks2 ${rootdevice} cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "LVM device [${rootdevice}] cannot be opened.\nExit status: ${exitcode}" 7 50
      exit ${exitcode}
    fi

    root_partition

  }

  cryptsetup_create

)

root_partition()(

  root_format(){

    mkfs.btrfs -L system /dev/mapper/cryptroot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Formatting ${rootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 7 60
      exit ${exitcode}
    fi

    root_mount

  }

  root_mount(){

    mount /dev/mapper/cryptroot /mnt
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "ROOT partition was not mounted\nExit status: ${exitcode}" 7 50
      exit ${exitcode}
    fi

    btrfs_system

  }

  root_format

)

btrfs_system()(

  btrfs_subvolumes(){

    btrfs subvolume create /mnt/@
    local exitcode1=$?

    btrfs subvolume create /mnt/@home
    local exitcode2=$?

    btrfs subvolume create /mnt/@var
    local exitcode3=$?

    btrfs subvolume create /mnt/@snapshots
    local exitcode4=$?

    umount -R /mnt
    local exitcode5=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ] || [ "${exitcode5}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nAn error occurred whilst creating subvolumes.\n\n
      ${exitcode1} - Create @\n
      ${exitcode2} - Create @home\n
      ${exitcode3} - Create @var\n
      ${exitcode4} - Create @snapshots\n
      ${exitcode5} - Unmount /mnt" 13 78
    fi

    #btrfs subvolume list .

    btrfs_mount

  }

  btrfs_mount(){

    mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
    local exitcode1=$?
    # Optional:ssd
    # dmesg | grep "BTRFS"

    mkdir -p /mnt/{efi,boot,home,var}
    mkdir -p /mnt/.snapshots

    mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
    local exitcode2=$?
    # Optional:ssd
    # dmesg | grep "BTRFS"

    mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var
    local exitcode3=$?
    # Optional:ssd
    # dmesg | grep "BTRFS"

    mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
    local exitcode4=$?
    # Optional:ssd
    # dmesg | grep "BTRFS"

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nAn error occurred whilst mounting subvolumes.\n\n
      ${exitcode1} - Create @\n
      ${exitcode2} - Create @home\n
      ${exitcode3} - Create @var\n
      ${exitcode4} - Create @snapshots" 13 78
      exit 1
    fi

    #df -hT

    efi_partition

  }

  btrfs_subvolumes

)

efi_partition()(

  efi_format(){

    mkfs.fat -F32 ${efidevice}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot format ESP [${efidevice}] to FAT32.\nExit status: ${exitcode}" 8 50
      exit ${exitcode}
    fi

    efi_mount

  }

  efi_mount(){

    efimountdir="/mnt/boot"
    #efimountdir="/mnt/efi"

    mount ${efidevice} ${efimountdir}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot mount ESP [${efidevice}] to ${efimountdir}.\nExit status: ${exitcode}" 8 50
      exit ${exitcode}
    fi

    fstab

  }

  efi_format

)

boot_partition()(

  boot_format(){

    mkfs.ext4 ${bootdevice}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Formatting ${bootdevice} to ext4 unsuccessful.\nExit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    boot_mount

  }

  boot_mount(){

    mount --mkdir ${bootdevice} /mnt/efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Boot partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    clear

    fstab

  }

  boot_format

)

ext4()(

  cryptsetup_open(){

  cryptsetup open --type luks2 ${rootdevice} cryptlvm --key-file ${keydir}
  local exitcode=$?

  if [ ${exitcode} != "0" ]; then
    whiptail --title "ERROR" --msgbox "LVM device [${rootdevice}] cannot be opened.\nExit status: ${?}" 8 78
    exit ${exitcode}
  fi

  }

  volume_physical(){

    pvcreate /dev/mapper/cryptlvm
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Physical volume cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group

  }

  volume_group(){

    vgcreate volgroup0 /dev/mapper/cryptlvm
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Volume group [volgroup0] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_create_root

  }

  volume_create_root(){

    lvcreate -L ${rootsize}GB volgroup0 -n cryptroot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT filesystem [cryptroot] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_create_home

  }

  volume_create_home(){

    lvcreate -l 100%FREE volgroup0 -n crypthome
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "HOME filesystem [crypthome] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_kernel_module

  }

  volume_kernel_module(){

    modprobe dm_mod
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [modprobe dm_mod] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group_scan

  }

  volume_group_scan(){

    vgscan
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Scanning volume groups [vgscan] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group_activate

  }

  volume_group_activate(){

    vgchange -ay
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [vgchange -ay] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    format_root

  }

  format_root(){

    mkfs.${filesystem} /dev/volgroup0/cryptroot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting [/dev/volgroup0/cryptroot] to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    mount_root

  }

  mount_root(){

    mount /dev/volgroup0/cryptroot /mnt
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT partition [/dev/volgroup0/cryptroot] was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    format_home

  }

  format_home(){

    mkfs.${filesystem} /dev/volgroup0/crypthome
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting [/dev/volgroup0/crypthome] to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    mount_home

  }

  mount_home(){

    mkdir /mnt/home
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title " ERROR " --msgbox "HOME directory was not created.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mount /dev/volgroup0/crypthome /mnt/home
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title " ERROR " --msgbox "HOME partition was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    boot_partition

  }

  cryptsetup_open
)

fstab(){

  mkdir /mnt/etc/ &>/dev/null
  local exitcode1=$?

  genfstab -U /mnt >> /mnt/etc/fstab
  local exitcode2=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nCannot create fstab configuration.\n\n
    ${exitcode1} - fstab directory\n
    ${exitcode2} - fstab configuration" 10 50
    exit 1
  fi

  sysinstall

}

sysinstall()(

  mirrorlist(){

    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &>/dev/null
    local exitcode1=$?

    reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
    local exitcode2=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot update mirrorlist.\n\n
      ${exitcode1} - Mirrorlist backup\n
      ${exitcode2} - Mirrorlist update" 10 50
    fi

    clear

    pacman_config

  }

  pacman_config(){

    cp ~/arch/cfg/pacman.conf /etc/pacman.conf &>/dev/null
    local exitcode1=$?

    cp ~/arch/cfg/pacman.conf /mnt/etc/pacman.conf &>/dev/null
    local exitcode2=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      dialog --title " ERROR " --msgbox "Cannot copy pacman.conf.\n\n
      ${exitcode1} - pacman.conf >> /etc/pacman.conf\n
      ${exitcode2} - pacman.conf >> /mnt/etc/pacman.conf" 10 50
      exit 1
    fi

    packages

  }

  packages(){

    #pacstrap -C ~/arch/cfg/pacman.conf /mnt linux linux-firmware linux-headers base base-devel grub grub-btrfs efibootmgr dialog
    pacstrap -C ~/arch/cfg/pacman.conf /mnt linux-hardened linux-firmware linux-hardened-headers base base-devel grub efibootmgr dialog
    local exitcode1=$?

    # Hardened Kernel
    # pacstrap: linux-hardened linux-hardened-headers
    # Check if initramfs-linux-hardened.img and initramfs-linux-hardened-fallback.img exists.
    # ls -lsha /boot

    if [ ${dmi} == "VirtualBox" ] || [ ${dmi} == "VMware Virtual Platform" ]; then
      case ${dmi} in
        "VirtualBox")
          pacstrap -C ~/arch/cfg/pacman.conf /mnt virtualbox-guest-utils
          local exitcode2=$?
          ;;
        "VMware Virtual Platform")
          pacstrap -C ~/arch/cfg/pacman.conf /mnt open-vm-tools
          local exitcode2=$?
          ;;
      esac
    fi

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ]; then
      dialog --title " ERROR " --msgbox "An error occurred whilst installing packages.\n
      ${exitcode1} - [ Main packages  ]\n
      ${exitcode4} - [ DMI packages ]" 13 78
    fi

    chroot

  }

  mirrorlist

)

chroot(){

  cp $HOME/arch/cfg/dialogrc /mnt/etc/dialogrc
  local exitcode1=$?

  cp /root/arch/src/chroot.sh /mnt
  local exitcode2=$?

  chmod +x /mnt/chroot.sh
  local exitcode3=$?

  arch-chroot /mnt ./chroot.sh
  local exitcode4=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Arch-chroot [/mnt] failed.\n\n
    ${exitcode1} - cp ~/arch/cfg/dialogrc  >> /mnt/etc/dialogrc\n
    ${exitcode2} - cp ~/arch/src/chroot.sh >> /mnt\n
    ${exitcode3} - chmod +x /mnt/chroot.sh\n
    ${exitcode4} - arch-chroot /mnt ./chroot.sh" 13 50
  fi

  #umount -l /mnt

  clear
  exit 1

}

while (( "$#" )); do
  case ${1} in
    --help)
      echo "------"
      echo "Arch installation script"
      echo "------"
      echo "Options:"
      echo "--help - Get help"
      echo "--info - Additional information"
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
precheck
