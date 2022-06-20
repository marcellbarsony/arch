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

    sel=$(whiptail --title "Diskpart" --menu "" --noitem 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)

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

    items=$(lsblk -p -n -l -o NAME -e 7,11)

    if (whiptail --title "Confirm partitions" --yesno "${items}" --defaultno 18 78); then
        #installscheme
        install_test
      else
        diskselect
    fi

  }

  installscheme(){

    if [ ${dmi} == "VirtualBox" ] || ${dmi} == "VMware Virtual Platform" ]; then
        vm_1
      else
        pm_1
    fi

  }

  warning

)

pm_1()(



  test(){

    ### PARTITION SCHEME ###
    # Partition 1 | EFI System Partition | (min. 256MB) | [EFI System] ..... |
    # Partition 2 | Root file system.... | ............ | [Linux Filesystem] |


    mkfs.fat -F32 ${efidisk}

    cryptsetup luksFormat -sha512 ${rootdisk}

    cryptsetup luksOpen ${rootdisk} cryptroot

    mkfs.btrfs /dev/mapper/cryptroot
    # mkfs.btrfs -L mylabel /dev/partition

    mount /dev/mapper/cryptroot /mnt

    cd /mnt

    btrfs subvolume create @

    btrfs subvolume create @home

    cd

    umount /mnt

    mount -o noatime,compress=zstd,space_cache,dicard=async,subvol=@ /dev/mapper/cryptroot /mnt

    mkdir /mnt/home

    mount -o noatime,compress=zstd,space_cache,dicard=async,subvol=@home /dev/mapper/cryptroot /mnt/home

    mkdir /mnt/efi #/mnt/boot

    mount ${efidisk} /mnt/efi #/mnt/boot

    #GRUB

    grub-install --target==x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

  }

  ### PARTITION SCHEME ###
  # Partition 1 | EFI System Partition | (min. 256MB) | [EFI System] ..... |
  # Partition 2 | Boot ............... | (min. 512MB) | [Linux Filesystem] |
  # Partition 3 | Root ............... | ............ | [Linux LVM] ...... |

  select_efi(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    efidevice=$(whiptail --title "[VM-1] EFI" --menu "EFI partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        #select_boot
        select_lvm
        ;;
      1)
        fsselect
        partition
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  select_boot(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    bootdevice=$(whiptail --title "[PM-1] BOOT" --menu "BOOT partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        select_lvm
        ;;
      1)
        select_efi
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  select_lvm(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    lvmdevice=$(whiptail --title "[PM-1] LVM" --menu "LVM partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      0)
        select_filesystem
        ;;
      1)
        select_boot
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  select_filesystem(){

    options=()
    options+=("ext4" "[Default]")
    options+=("btrfs" "[-]")

    filesystem=$(whiptail --title "[VM-1] File System" --menu "File system" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    case $? in
      1)
        installscheme
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

      select_root_size

  }

  select_root_size(){

    rootsize=$(whiptail --inputbox "Root size [GB]" 8 39 --title "ROOT filesystem" 3>&1 1>&2 2>&3)
    local exitcode=$?

    case $? in
      0)
        if [[ $rootsize ]] && [ $rootsize -eq $rootsize 2>/dev/null ]; then
            crypt_password
          else
            whiptail --title "ERROR" --msgbox "Value is not an integer.\nExit status: ${?}" 8 78
            select_root_size
        fi
        ;;
      1)
        select_filesystem
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  crypt_password(){

    cryptpassword=$(whiptail --passwordbox "Encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

    case $? in
      0)
        crypt_password_confirm
        ;;
      1)
        lvmselect
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  crypt_password_confirm(){

    cryptpassword_confirm=$(whiptail --passwordbox "Confirm encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

    case $? in
      0)
        crypt_file
        ;;
      1)
        cryptpassword
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac

  }

  crypt_file(){

    echo "cryptfile" > /root/arch/log.txt
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
      format_efi
    else
      whiptail --title "ERROR" --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
      crypt_password
    fi

  }

  format_efi(){

    mkfs.fat -F32 ${efidevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    cryptsetup_create

  }

  format_boot(){

    mkfs.${filesystem} ${bootdevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${bootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    cryptsetup_create

  }

  cryptsetup_create(){

    cryptsetup --type luks2 --batch-mode luksFormat ${lvmdevice} --key-file ${keydir}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Encrypting [${lvmdevice}] unsuccessful.\nExit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    cryptsetup_open

  }

  cryptsetup_open(){

    cryptsetup open --type luks2 ${lvmdevice} cryptlvm --key-file ${keydir}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "LVM device [${lvmdevice}] cannot be opened.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_physical

  }

  volume_physical(){

    pvcreate /dev/mapper/cryptlvm
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Physical volume cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group

  }

  volume_group(){

    vgcreate volgroup0 /dev/mapper/cryptlvm
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Volume group [volgroup0] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_create_root

  }

  volume_create_root(){

    lvcreate -L ${rootsize}GB volgroup0 -n cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT filesystem [cryptroot] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_create_home

  }

  volume_create_home(){

    lvcreate -l 100%FREE volgroup0 -n crypthome
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "HOME filesystem [crypthome] cannot be created.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_kernel_module

  }

  volume_kernel_module(){

    modprobe dm_mod
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [modprobe dm_mod] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group_scan

  }

  volume_group_scan(){

    vgscan
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Scanning volume groups [vgscan] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    volume_group_activate

  }

  volume_group_activate(){

    vgchange -ay
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      whiptail --title "ERROR" --msgbox "Activating volume groups [vgchange -ay] failed.\nExit status: ${?}" 8 78
      exit ${exitcode}
    fi

    format_root

  }

  format_root(){

    mkfs.${filesystem} /dev/volgroup0/cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
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

  mount_boot(){


    mount --mkdir ${bootdevice} /mnt/efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "BOOT partition was not mounted.\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    format_home

  }

  format_home(){

    mkfs.${filesystem} /dev/volgroup0/crypthome
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
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

    fstab

  }

  select_efi

)

vm_1()(

  select_efi(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    efidevice=$(whiptail --title "[VM-1] EFI" --menu "EFI partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

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

  select_root(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    rootdevice=$(whiptail --title "[VM-1] ROOT" --menu "ROOT partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

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

    filesystem=$(whiptail --title "[VM-1] File System" --menu "File system" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

      case ${fsselect} in
        "Btrfs")
        filesystem="btrfs"
        ;;
      esac

      format_efi

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

  format_efi(){

    echo 20 | whiptail --gauge "Formatting ${efidevice} to ${efifs}..." 6 50 0
    mkfs.fat -F32 ${efidevice} &> /dev/null
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to ${efifs} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    format_root

  }

  format_root(){

    echo 30 | whiptail --gauge "Format ${rootdevice} to ${filesystem}..." 6 50 0
    mkfs.${filesystem} ${rootdevice} &>/dev/null
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${rootdevice} to ${filesystem} unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    mount_efi

  }

  mount_efi(){

    echo 40 | whiptail --gauge "Mount ${efidevice} to /mnt/efi..." 6 50 0
    mount --mkdir ${efidevice} /mnt/efi &>/dev/null # Arch wiki: /mnt/boot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    mount_root

  }

  mount_root(){

    echo 50 | whiptail --gauge "Mount ${rootdevice} to /mnt..." 6 50 0
    mount ${rootdevice} /mnt &>/dev/null
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "ROOT partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    if [ "${filesystem}" == "btrfs" ]; then
      btrfs_subvolumes
    fi

    fstab

  }

  btrfs_subvolumes(){

    #cd /mnt

    # Subvolume root
    btrfs subvolume create /mnt/@

    # Subvolume home
    btrfs subvolume create /mnt/@home

    # Subvolume var
    btrfs subvolume create /mnt/@var

    #cd

    umount /mnt

    btfs_mount

  }

  btrfs_mount(){

    mkdir /mnt/{boot,home,var}

    # Mount subvolume root
    mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@ ${rootdevice} /mnt

    # Mount subvolume home
    mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@home ${rootdevice} /mnt/home

    # Mount subvolume var
    mount -o noatime,compress=zstd,space_cache,discard=async,subvol=@var ${rootdevice} /mnt/var

    # Mount efi
    mount ${efidevice} /mnt/boot #change GRUB install to /boot

    fstab

  }

  efiselect

)

install_test()(

  select_efi(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    efidevice=$(whiptail --title "[Test] EFI partition" --menu "Select EFI partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

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

  select_root(){

    options=()
    items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
    for item in ${items}; do
      options+=("${item}" "")
    done

    rootdevice=$(whiptail --title "[Test] ROOT partition" --menu "ROOT partition" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

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

    filesystem=$(whiptail --title "[Test] File System" --menu "Select file system" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then

        case ${filesystem} in
          "Btrfs")
            filesystem="btrfs"
            select_filesystem
            ;;
          "ext4")
            ext4_cryptsetup
            ;;
        esac

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

  ext4_cryptsetup()(

    select_root_size(){

      rootsize=$(whiptail --inputbox "Root size [GB]" 8 39 --title "ROOT filesystem" 3>&1 1>&2 2>&3)
      local exitcode=$?

      case $? in
        0)
          if [[ $rootsize ]] && [ $rootsize -eq $rootsize 2>/dev/null ]; then
              crypt_password
            else
              whiptail --title "ERROR" --msgbox "Value is not an integer.\nExit status: ${?}" 8 78
              select_root_size
          fi
          ;;
        1)
          install_test
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

    }

    crypt_password(){

      cryptpassword=$(whiptail --passwordbox "Encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_password_confirm
          ;;
        1)
          select_root_size
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac

    }

    crypt_password_confirm(){

      cryptpassword_confirm=$(whiptail --passwordbox "Confirm encryption password" 8 78 --title "LUKS" 3>&1 1>&2 2>&3)

      case $? in
        0)
          crypt_file
          ;;
        1)
          cryptpassword
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
        cryptsetup_create
      else
        whiptail --title "ERROR" --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
        crypt_password
      fi

    }

    cryptsetup_create(){

      cryptsetup --type luks2 --batch-mode luksFormat ${rootdevice} --key-file ${keydir}
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Encrypting [${rootdevice}] unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
      fi

      cryptsetup_open

    }

    cryptsetup_open(){

      cryptsetup open --type luks2 ${rootdevice} cryptlvm --key-file ${keydir}
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "LVM device [${rootdevice}] cannot be opened.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_physical

    }

    volume_physical(){

      pvcreate /dev/mapper/cryptlvm
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Physical volume cannot be created.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_group

    }

    volume_group(){

      vgcreate volgroup0 /dev/mapper/cryptlvm
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Volume group [volgroup0] cannot be created.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_create_root

    }

    volume_create_root(){

      lvcreate -L ${rootsize}GB volgroup0 -n cryptroot
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "ROOT filesystem [cryptroot] cannot be created.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_create_home

    }

    volume_create_home(){

      lvcreate -l 100%FREE volgroup0 -n crypthome
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "HOME filesystem [crypthome] cannot be created.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_kernel_module

    }

    volume_kernel_module(){

      modprobe dm_mod
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Activating volume groups [modprobe dm_mod] failed.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_group_scan

    }

    volume_group_scan(){

      vgscan
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Scanning volume groups [vgscan] failed.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      volume_group_activate

    }

    volume_group_activate(){

      vgchange -ay
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Activating volume groups [vgchange -ay] failed.\nExit status: ${?}" 8 78
        exit ${exitcode}
      fi

      format_efi

    }

    select_root_size

  )

  format_efi(){

    mkfs.fat -F32 ${efidevice}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
        whiptail --title "ERROR" --msgbox "Formatting ${efidevice} to FAT32 unsuccessful.\nExit status: ${exitcode}" 8 78
        exit ${exitcode}
    fi

    cryptsetup_create

  }

  mount_efi(){

    echo 40 | whiptail --gauge "Mount ${efidevice} to /mnt/efi..." 6 50 0
    mount --mkdir ${efidevice} /mnt/efi &>/dev/null # Arch wiki: /mnt/boot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "EFI partition was not mounted\nExit status: ${exitcode}" 8 60
      exit ${exitcode}
    fi

    format_root

  }

  format_root(){

    mkfs.${filesystem} /dev/volgroup0/cryptroot
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
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

    if [ ${exitcode} != "0" ]; then
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

    fstab

  }

  select_efi

)

fstab(){

  echo 60 | whiptail --gauge "Create fstab directory..." 6 50 0
  mkdir /mnt/etc/ &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab directory was not created.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  echo 70 | whiptail --gauge "Create fstab config..." 6 50 0
  genfstab -U /mnt >> /mnt/etc/fstab &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "fstab config was not generated.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  mirrorlist

}

mirrorlist(){

  echo 80 | whiptail --gauge "Backing up mirrorlist..." 6 50 0
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Mirrorlist cannot be backed up.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  echo 90 | whiptail --gauge "Updating Pacman mirrorlist with reflector..." 6 50 0
  reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Mirrorlist cannot be updated.\nExit status: ${exitcode}" 8 60
    exit ${exitcode}
  fi

  kernel

}

kernel(){

  pacstrap /mnt linux linux-firmware linux-headers base base-devel git vim libnewt

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Main packages were not installed.\nExit status: ${exitcode}" 8 60
  fi

  if [ ${dmi} == "VirtualBox" ] || ${dmi} == "VMware Virtual Platform" ]; then
      pacstrap /mnt virtualbox-guest-utils
    else
      pacstrap /mnt lvm2
  fi

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "DMI packages were not installed.\nExit status: ${exitcode}" 8 60
  fi

  if [ ${filesystem} == "btrfs" ]; then
    pacstrap /mnt btrfs-progs grub-btrfs
      case $? in
        0)
          whiptail --title "Info" --msgbox "Btrfs packages were successfully installed.\nExit status: ${exitcode}" 8 60
          ;;
        *)
          whiptail --title "ERROR" --msgbox "Cannot install Btrfs packages.\nExit status: ${exitcode}" 8 60
          ;;
      esac
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
#precheck

install_test
