#!/bin/bash

precheck()(

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
    ls /sys/firmware/efi/efivars 2>&1 >/dev/null

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
    pacman -Sy --noconfirm libnewt dialog 2>&1 >/dev/null

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

  network

)

keymap(){

  items=$(localectl list-keymaps)
  options=()
  options+=("us" "[Default]")
    for item in ${items}; do
      options+=("${item}" "")
    done

  keymap=$(whiptail --title "Keyboard layout" --menu "" --nocancel 30 50 20 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then

    loadkeys ${keymap} &>/dev/null
    localectl set-keymap --no-convert ${keymap} &>/dev/null # Systemd reads from /etc/vconsole.conf

  fi

  partition

}

partition()(

  warning(){

    if (whiptail --title "WARNING" --yesno "Everything not backed up will be lost." --yes-button "Proceed" --no-button "Exit" 8 60); then
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
    options+=("cfdisk" "")
    options+=("fdisk" "")
    options+=("gdisk" "")
    options+=("sgdisk" "")

    diskpart_tool=$(whiptail --title "Diskpart" --menu "" --noitem --default-item "sgdisk" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

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
        "sgdisk")
          sgdisk_partition
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

  sgdisk_partition()(

    sgdisk_create(){

      sgdisk -o ${disk}
      local exitcode1=$?

      sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:efi ${disk}
      local exitcode2=$?

      #sgdisk -n 0:0:+1GiB -t 0:8300 -c 0:boot ${disk}
      #local exitcode3=$?

      sgdisk -n 0:0:0 -t 0:8e00 -c 0:lvm ${disk}
      local exitcode4=$?

      if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode4}" != "0" ] ; then
        whiptail --title "ERROR" --msgbox "Create.\n
        Exit status [GPT]: ${exitcode1}\n
        Exit status [/efi]: ${exitcode2}\n
        Exit status [/root]: ${exitcode4}" 18 78
        exit 1
      fi

      sgdisk_check

    }

    sgdisk_check(){

      items=$( gdisk -l ${disk} | tail -4 )

      if (whiptail --title "Confirm partitions" --yesno "${items}" 18 78); then
          filesystem
        else
          sgdisk --zap-all ${disk}
          partition
      fi

    }

    sgdisk_sketch(){

      # List partitions
      gdisk -l ${disk}

      # Partition info
      #sgdisk -i <partition_no> ${disk}

    }

    sgdisk_create

  )

  diskpart_check(){

    items=$(lsblk -p -n -l -o NAME -e 7,11)

    if (whiptail --title "Confirm partitions" --yesno "${items}" 18 78); then
        filesystem
      else
        partition
    fi

  }

  warning

)

filesystem()(

  filesystem_dialog()(

    select_efi(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      efidevice=$(whiptail --title "Partition" --menu "Select partition [EFI]" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          select_root
          ;;
        1)
          partition
          ;;
        *)
          whiptail --title "ERROR" --msgbox "Error status: ${?}" 8 78
          ;;
      esac

    }

    select_boot(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      bootdevice=$(whiptail --title "Partition" --menu "Select partition [Boot]" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          select_root
          ;;
        1)
          select_efi
          ;;
        *)
          whiptail --title "ERROR" --msgbox "Error status: ${?}" 8 78
          ;;
      esac

    }

    select_root(){

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      rootdevice=$(whiptail --title "Partition" --menu "Select partition [Root]" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
        0)
          select_filesystem
          ;;
        1)
          select_efi
          ;;
        *)
          whiptail --title "ERROR" --msgbox "Error status: ${?}" 8 78
          ;;
      esac

    }

    select_filesystem(){

      options=()
      options+=("Btrfs" "[-]")
      options+=("ext4" "[-]")

      filesystem=$(whiptail --title "File System" --menu "Select file system" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

      if [ "$?" = "0" ]; then
          case ${filesystem} in
            "Btrfs")
              filesystem="btrfs"
              sgdisk -t 2:8300 ${disk}
              ;;
          esac
          encryption_dialog
        else
          case $? in
            1)
              select_root
              ;;
            *)
              whiptail --title "ERROR" --msgbox "Error status: ${?}" 8 78
              ;;
          esac
      fi

    }

    select_efi

  )

  encryption_dialog()(

    crypt_password(){

      cryptpassword=$(whiptail --passwordbox "Encryption passphrase" 8 78 --title "Crypt" 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_password_confirm
          ;;
        1)
          filesystem
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

    }

    crypt_password_confirm(){

      cryptpassword_confirm=$(whiptail --passwordbox "Encryption passphrase [confirm]" 8 78 --title "Crypt" 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_file
          ;;
        1)
          crypt_password
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

    }

    crypt_file(){

      keydir=/root/luks.key
      keydir2=/root/luks.key2

      echo "$cryptpassword" > "$keydir"
      local exitcode1=$?

      echo "$cryptpassword_confirm" > "$keydir2"
      local exitcode2=$?

      if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "Key file [${keydir}] cannot be created.\n
          Exit status [File 1]: ${exitcode1}\n
          Exit status [File 2]: ${exitcode2}" 12 78
          exit 1
      fi

      # Password match
      if cmp --silent -- "$keydir" "$keydir2"; then
          encryption
        else
          whiptail --title "ERROR" --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
          crypt_password
      fi

    }

    select_root_size(){

      if [ ${filesystem} == "ext4" ]; then
          rootsize=$(whiptail --inputbox "Root size [GB]" 8 39 --title "Root filesystem" 3>&1 1>&2 2>&3)
          local exitcode=$?

          case $? in
            0)
              if [[ ${rootsize} ]] && [ ${rootsize} -eq ${rootsize} 2>/dev/null ]; then
                  encrypted
                else
                  whiptail --title "ERROR" --msgbox "Value is not an integer.\nExit status: ${?}" 8 78
                  select_root_size
              fi
              ;;
            1)
              crypt_password
              ;;
            *)
              echo "Exit status $?"
              ;;
          esac
      fi

      encryption

    }

    crypt_password

  )

  encryption()(

    mkfs.fat -F32 ${efidevice}

    cryptsetup_create(){

      cryptsetup --type luks2 --batch-mode luksFormat ${rootdevice} --key-file ${keydir}
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Encrypting [${rootdevice}] unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
      fi

      filesystem_select

    }

    filesystem_select(){

      case ${filesystem} in
        "btrfs")
          encrypted_btrfs
          ;;
        "ext4")
          encrypted_ext4
          ;;
      esac

    }

    encrypted_btrfs()(

      cryptsetup_open(){

        cryptsetup open --type luks2 ${rootdevice} cryptroot --key-file ${keydir}
        local exitcode=$?

        if [ ${exitcode} != "0" ]; then
          whiptail --title "ERROR" --msgbox "LVM device [${rootdevice}] cannot be opened.\nExit status: ${?}" 8 78
          exit ${exitcode}
        fi

        format_root

      }

      format_root(){

        mkfs.btrfs -L mylabel /dev/mapper/cryptroot
        local exitcode=$?

        if [ "${exitcode}" != "0" ]; then
            whiptail --title "ERROR" --msgbox "Formatting ${rootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
            exit ${exitcode}
        fi

        mount_root

      }

      mount_root(){

        mount /dev/mapper/cryptroot /mnt
        local exitcode=$?

        if [ "${exitcode}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "ROOT partition was not mounted\nExit status: ${exitcode}" 8 60
          exit ${exitcode}
        fi

        btrfs_subvolumes

      }

      btrfs_subvolumes(){

        btrfs subvolume create /mnt/@
        local exitcode1=$?

        btrfs subvolume create /mnt/@home
        local exitcode2=$?

        btrfs subvolume create /mnt/@var
        local exitcode3=$?

        btrfs subvolume create /mnt/@snapshots
        local exitcode4=$?

        umount /mnt
        local exitcode5=$?

        if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ] || [ "${exitcode5}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "An error occurred whilst creating subvolumes.\n
          Exit status [Create @]: ${exitcode1}\n
          Exit status [Create @home]: ${exitcode2}\n
          Exit status [Create @var]: ${exitcode3}\n
          Exit status [Create @snapshots]: ${exitcode4}\n
          Exit status [umount /mnt]: ${exitcode5}" 18 78
        fi

        btrfs_mount

      }

      btrfs_mount(){

        mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
        #Optional:ssd
        # dmesg | grep "BTRFS"
        local exitcode1=$?

        mkdir -p /mnt/{boot,home,var}

        mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
        #Optional:ssd
        # dmesg | grep "BTRFS"
        local exitcode2=$?

        mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var
        #Optional:ssd
        # dmesg | grep "BTRFS"
        local exitcode3=$?

        mount ${efidevice} /mnt/boot
        local exitcode4=$?

          if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ]; then
            whiptail --title "ERROR" --msgbox "An error occurred whilst mounting subvolumes.\n
            Exit status [Create @]: ${exitcode1}\n
            Exit status [Create @home]: ${exitcode2}\n
            Exit status [Create @var]: ${exitcode3}\n
            Exit status [Mount EFI]: ${exitcode4}" 18 78
          fi

        fstab

      }

      cryptsetup_open

    )

    encrypted_ext4()(

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
          whiptail --title "ERROR" --msgbox "HOME directory was not created.\nExit status: ${exitcode}" 8 60
          exit ${exitcode}
        fi

        mount /dev/volgroup0/crypthome /mnt/home
        local exitcode=$?

        if [ "${exitcode}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "HOME partition was not mounted.\nExit status: ${exitcode}" 8 60
          exit ${exitcode}
        fi

        boot_partition

      }

      cryptsetup_open

    )

    cryptsetup_create

  )

  boot_partition()(

    format_boot(){

      mkfs.${filesystem} ${bootdevice}
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${bootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
      fi

      mount_boot

    }

    mount_boot(){

      mount --mkdir ${efidevice} /mnt/boot
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
        exit ${exitcode}
      fi

      efi_partition

    }

    format_boot

  )

  efi_partition()(

    format_efi(){

      mkfs.fat -F32 ${efidevice}
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
      fi

      mount_efi

    }

    mount_efi(){

      mount --mkdir ${efidevice} /mnt/boot/efi
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
        exit ${exitcode}
      fi

      fstab

    }

    format_efi

  )

  filesystem_dialog

)

fstab(){

  mkdir /mnt/etc/ &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab directory was not created.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  genfstab -U /mnt >> /mnt/etc/fstab &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab config was not generated.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  mirrorlist

}

mirrorlist(){

  echo 0 | whiptail --gauge "Backing up mirrorlist..." 6 50 0
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Mirrorlist cannot be backed up.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  echo 33 | whiptail --gauge "Reflector: Update mirrorlist..." 6 50 0
  reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Cannot update mirrorlist.\n
    Exit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  clear

  pacman_conf

}

pacman_conf(){


  echo 0 | whiptail --gauge "Copying pacman.conf >> /etc/pacman.conf..." 6 50 0
  cp ~/arch/cfg/pacman.conf /etc/pacman.conf &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Cannot copy pacman.conf to /etc/pacman.conf\nExit status: ${exitcode}" 8 60
  fi

  echo 50 | whiptail --gauge "Copying pacman.conf >> /mnt/etc/pacman.conf..." 6 50 0
  cp ~/arch/cfg/pacman.conf /mnt/etc/pacman.conf &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Cannot copy pacman.conf to /mnt/etc/pacman.conf\nExit status: ${exitcode}" 8 60
  fi

  kernel

}

kernel(){

  echo 0 | whiptail --gauge "Pacstrap: Installing base packages..." 6 50 0
  clear
  pacstrap -C ~/arch/cfg/pacman.conf /mnt linux linux-firmware linux-headers base base-devel git vim libnewt
  # linux-hardened linux-hardened-headers
  local exitcode1=$?

  if [ ${dmi} == "VirtualBox" ] || [ ${dmi} == "VMware Virtual Platform" ]; then
    echo 0 | whiptail --gauge "Pacstrap: Installing ${dmi} packages..." 6 50 0
    sleep 1
    clear
    pacstrap /mnt virtualbox-guest-utils
    local exitcode2=$?
  fi

  # Hardened Kernel
  #Check if initramfs-linux-hardened.img and initramfs-linux-hardened-fallback.img exists.
  #ls -lsha /boot

  if [ "${filesystem}" == "ext4" ]; then
    echo 0 | whiptail --gauge "Pacstrap: Installing lvm2..." 6 50 0
    sleep 1
    clear
    pacstrap /mnt lvm2
    local exitcode3=$?
  fi

  if [ ${filesystem} == "btrfs" ]; then
    echo 0 | whiptail --gauge "Pacstrap: Installing Btrfs progs..." 6 50 0
    pacstrap /mnt btrfs-progs grub-btrfs
    local exitcode4=$?
  fi

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] || [ "${exitcode4}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "An error occurred whilst installing packages.\n
    Exit status [Main packages]: ${exitcode1}\n
    Exit status [DMI packages]: ${exitcode2}\n
    Exit status [Crypt packages]: ${exitcode3}\n
    Exit status [Btrfs packages]: ${exitcode4}" 18 78
  fi

  chroot

}

chroot(){

  echo 0 | whiptail --gauge "Copy chroot script to /mnt..." 6 50 0
  cp /root/arch/src/chroot.sh /mnt
  local exitcode1=$?

  echo 33 | whiptail --gauge "Chmod chroot script..." 6 50 0
  chmod +x /mnt/chroot.sh
  local exitcode2=$?

  echo 66 | whiptail --gauge "Chroot into /mnt..." 6 50 0
  arch-chroot /mnt ./chroot.sh
  local exitcode3=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Arch-chroot [/mnt] failed.\n
    Exit status [copy]: ${exitcode1}\n
    Exit status [chmod]: ${exitcode2}\n
    Exit status [chroot]: ${exitcode3}" 18 78
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
