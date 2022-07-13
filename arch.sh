#!/bin/bash

pre() (

  variables() (

    echo -n "Global variables............. " && sleep 1

    infos() {

      info_logs="Log files.................... "
      info_network="Network connection........... "
      info_bootmode="Boot mode.................... "
      info_dmidata="DMI data..................... "
      info_systemclock="System clock................. "
      info_keymap="Keymap....................... "
      info_configs="Configs...................... "
      info_dependencies="Dependencies................. "

      script_vars

    }

    script_vars() {

      # Script properties
      script_name=$(basename $0)
      script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

      # Logs
      script_log=${script_dir}/src/${script_name}.log
      error_log=${script_dir}/src/error.log

      # Configs
      dialogrc=${script_dir}/cfg/dialogrc
      pacmanconf=${script_dir}/cfg/pacman.conf

      colors

    }

    colors() {

      #https://gist.github.com/elucify/c7ccfee9f13b42f11f81

      RESTORE=$(echo -en '\033[0m')
      RED=$(echo -en '\033[00;31m')
      GREEN=$(echo -en '\033[00;32m')
      YELLOW=$(echo -en '\033[00;33m')
      BLUE=$(echo -en '\033[00;34m')
      MAGENTA=$(echo -en '\033[00;35m')
      PURPLE=$(echo -en '\033[00;35m')
      CYAN=$(echo -en '\033[00;36m')
      LIGHTGRAY=$(echo -en '\033[00;37m')
      LRED=$(echo -en '\033[01;31m')
      LGREEN=$(echo -en '\033[01;32m')
      LYELLOW=$(echo -en '\033[01;33m')
      LBLUE=$(echo -en '\033[01;34m')
      LMAGENTA=$(echo -en '\033[01;35m')
      LPURPLE=$(echo -en '\033[01;35m')
      LCYAN=$(echo -en '\033[01;36m')
      WHITE=$(echo -en '\033[01;37m')

      # Test
      #echo ${RED}RED${GREEN}GREEN${YELLOW}YELLOW${BLUE}BLUE${PURPLE}PURPLE${CYAN}CYAN${WHITE}WHITE${RESTORE}

      echo "[OK]"

      logs

    }

    infos

  )

  logs() {

    echo -n ${info_logs} && sleep 1

    if [ ! -f "${error_log}" ] || [ ! -f "${script_log}" ]; then
      touch ${error_log} && touch ${script_log}
    else
      >${error_log} && >${script_log}
    fi

    echo "[OK]"

    network

  }

  network() {

    echo -n ${info_network}
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

  bootmode() {

    echo -n ${info_bootmode} && sleep 1
    ls /sys/firmware/efi/efivars &>/dev/null

    case $? in
    0)
      echo "[OK]"
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

  dmidata() {

    echo -n ${info_dmidata} && sleep 1
    dmi=$(dmidecode -s system-product-name)

    if [ ${dmi} == "VirtualBox" ] || ${dmi} == "VMware Virtual Platform" ]; then
      echo "[VM]"
    else
      echo "[Physical Machine]"
    fi

    systemclock

  }

  systemclock() {

    echo -n ${info_systemclock} && sleep 1
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

  keymap() {

    echo -n ${info_keymap} && sleep 1
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

  configs() {

    echo -n ${info_configs} && sleep 1
    cp -f ${dialogrc} $HOME/.dialogrc &>/dev/null
    cp -f ${pacmanconf} /etc/pacman.conf &>/dev/null

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

  dependencies() {

    echo -n ${info_dependencies} && sleep 1
    pacman -Sy --noconfirm dialog &>/dev/null

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

  variables

)

errorlog() {

  local exitcode=${1}
  local functionname=${2}
  local lineno=${3}

  echo "Directory - ${script_dir}" >${error_log}
  echo "Script - ${script_name}" >>${error_log}
  echo "Function - ${functionname}" >>${error_log}
  echo "Line no. - ${lineno}" >>${error_log}
  echo "Exit code - ${exitcode}" >>${error_log}

  if (dialog --title " ERROR " --yes-label "View logs" --no-label "Exit" --yesno "\nAn error has occurred\nCheck the log file for details\nExit status: ${exitcode}" 10 60); then
    vim ${error_log}
    clear
    exit ${exitcode}
  else
    clear
    exit ${exitcode}
  fi

}

set -o errtrace
exec 2>>${error_log}

trap 'errorlog ${?} ${FUNCNAME-main} ${LINENO}' ERR
#trap 'failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND"' ERR

# Note
# https://stackoverflow.com/questions/31201572/how-to-untrap-after-a-trap-command
# https://github.com/rtxx/arch-minimal-install/blob/main/install-script
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
# https://stackoverflow.com/questions/64786/error-handling-in-bash
# https://stackoverflow.com/questions/25378845/what-does-set-o-errtrace-do-in-a-shell-script

partition() (

  keymap() {

    items=$(localectl list-keymaps)
    options=()
    options+=("us" "[Default]")
    for item in ${items}; do
      options+=("${item}" "")
    done

    keymap=$(dialog --title " Keyboard layout " --nocancel --menu "" 30 50 20 "${options[@]}" 3>&1 1>&2 2>&3)

    if [ "$?" = "0" ]; then
      loadkeys ${keymap} &>/dev/null
      localectl set-keymap --no-convert ${keymap} &>/dev/null # Systemd reads from /etc/vconsole.conf
    else
      exit 1

    fi

    warning

  }

  warning() {

    if (dialog --title " WARNING " --yes-label "Proceed" --no-label "Exit" --yesno "\nEverything not backed up will be lost." 8 60); then
      diskselect || true
    else
      echo "Installation terminated - $?"
    fi

  }

  diskselect() {

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
      warning
      exit 1
      ;;
    *)
      echo "Exit status $?"
      ;;
    esac

  }

  sgdisk_partition() {

    sgdisk -o ${disk}
    local exitcode1=$?

    sgdisk -n 0:0:+750MiB -t 0:ef00 -c 0:efi ${disk}
    local exitcode2=$?

    #sgdisk -n 0:0:+1GiB -t 0:8300 -c 0:boot ${disk}
    #local exitcode3=$?

    sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem ${disk}
    local exitcode4=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode4}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nSgdisk: cannot create partitions\n\n
      Exit status [clear ]: ${exitcode1}\n
      Exit status [/efi  ]: ${exitcode2}\n
      Exit status [/boot ]: ${exitcode3}\n
      Exit status [/     ]: ${exitcode4}" 13 55
      exit 1
    fi

    diskpart_check

  }

  diskpart_check() {

    items=$(gdisk -l ${disk} | tail -4)

    if (dialog --title " Partitions " --yes-label "Confirm" --no-label "Manual" --yesno "\nConfirm partitions:\n\n${items}" 15 60); then
      dialogs || true
    else
      sgdisk --zap-all ${disk}
      diskpart_manual
    fi

  }

  diskpart_manual() {

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

  keymap

)

dialogs() (

  filesystem_dialog() (

    select_efi() {

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      EFIDEVICE=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [EFI]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
      0)
        select_root
        ;;
      1)
        partition
        ;;
      esac

    }

    select_boot() {

      options=()
      items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
      for item in ${items}; do
        options+=("${item}" "")
      done

      BOOTDEVICE=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [Boot]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

      case $? in
      0)
        select_root
        ;;
      1)
        select_efi
        ;;
      esac

    }

    select_root() {

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
      esac

    }

    select_efi

  )

  encryption_dialog() (

    crypt_password() {

      cryptpassword=$(dialog --nocancel --passwordbox "LUKS encryption passphrase" 8 45 3>&1 1>&2 2>&3)

      case $? in
      0)
        crypt_password_confirm
        ;;
      *)
        echo "Exit status: $?"
        ;;
      esac

    }

    crypt_password_confirm() {

      cryptpassword_confirm=$(dialog --nocancel --passwordbox "LUKS encryption passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      case $? in
      0)
        crypt_password_check
        ;;
      *)
        echo "Exit status $?"
        ;;
      esac

    }

    crypt_password_check() {

      if [ ! ${cryptpassword} ] || [ ! ${cryptpassword_confirm} ]; then
        dialog --title " ERROR " --msgbox "Encryption passphrase cannot be empty." 8 45
        crypt_password
      fi

      if [[ "${cryptpassword}" != "${cryptpassword_confirm}" ]]; then
        dialog --title " ERROR " --msgbox "Encryption passphrase did not match." 8 45
        crypt_password
      fi

      sysadmin_dialog

    }

    key_file() {

      keydir=/root/luks.key
      keydir2=/root/luks.key2

      echo "$cryptpassword" >"$keydir"
      local exitcode1=$?

      echo "$cryptpassword_confirm" >"$keydir2"
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

  sysadmin_dialog() (

    workstation_name() {

      nodename=$(dialog --nocancel --inputbox "Hostname" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${nodename} ]; then
        dialog --title " ERROR " --msgbox "\nHostname cannot be empty." 8 45
        workstation_name
      fi

      user_account

    }

    user_account() {

      username=$(dialog --nocancel --inputbox "Username" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${username} ] || [ ${username} == "root" ]; then
        dialog --title " ERROR " --msgbox "\nUsername cannot be empty or [root]." 8 45
        user_account
      fi

      user_passphrase

    }

    user_passphrase() {

      user_password=$(dialog --nocancel --passwordbox "${username}'s passphrase" 8 45 3>&1 1>&2 2>&3)

      user_password_confirm=$(dialog --nocancel --passwordbox "${username}'s passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${user_password} ] || [ ! ${user_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nUser passphrase cannot be empty." 8 45
        user_passphrase
      fi

      if [ ${user_password} != ${user_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nUser passphrase did not match." 8 45
        user_passphrase
      fi

      root_passphrase

    }

    root_passphrase() {

      root_password=$(dialog --nocancel --passwordbox "Root passphrase" 8 45 3>&1 1>&2 2>&3)

      root_password_confirm=$(dialog --nocancel --passwordbox "Root passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${root_password} ] || [ ! ${root_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nRoot passphrase cannot be empty." 8 45
        root_passphrase
      fi

      if [ ${root_password} != ${root_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nRoot passphrase did not match." 8 45
        root_passphrase
      fi

      grub_password

    }

    grub_password() {

      grubpw=$(dialog --nocancel --passwordbox "GRUB passphrase" 8 45 3>&1 1>&2 2>&3)

      grubpw_CONFIRM=$(dialog --nocancel --passwordbox "GRUB passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${grubpw} ] || [ ! ${grubpw_CONFIRM} ]; then
        dialog --title " ERROR " --msgbox "\nGRUB passphrase cannot be empty." 8 45
        grub_password
      fi

      if [ ${grubpw} != ${grubpw_CONFIRM} ]; then
        dialog --title " ERROR " --msgbox "\nGRUB passphrase did not match." 8 45
        grub_password
      fi

      crypt_setup

    }

    workstation_name

    # https://wiki.archlinux.org/title/General_recommendations#System_administration

  )

  filesystem_dialog

)

crypt_setup() (

  cryptsetup_create() {

    echo ${cryptpassword} | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat ${rootdevice}

    #https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Keyfiles

    # Check keyslots
    # cryptsetup luksDump /dev/sda

    cryptsetup_open

  }

  cryptsetup_open() {

    echo ${cryptpassword} | cryptsetup open --type luks2 ${rootdevice} cryptroot

    filesystem

  }

  cryptsetup_create

)

filesystem() (

  root_partition() (

    root_format() {

      mkfs.btrfs -L system /dev/mapper/cryptroot

      root_mount

    }

    root_mount() {

      mount /dev/mapper/cryptroot /mnt

      btrfs_filesystem

    }

    root_format

  )

  btrfs_filesystem() (

    btrfs_subvolumes() {

      btrfs subvolume create /mnt/@

      btrfs subvolume create /mnt/@home

      btrfs subvolume create /mnt/@var

      btrfs subvolume create /mnt/@snapshots

      umount -R /mnt

      #btrfs subvolume list .

      btrfs_mount

    }

    btrfs_mount() {

      mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
      # Optional:ssd
      # dmesg | grep "BTRFS"

      mkdir -p /mnt/{efi,boot,home,var,.snapshots}

      mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home

      mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var

      mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

      #df -hT

      efi_partition

    }

    btrfs_subvolumes

  )

  efi_partition() (

    efi_format() {

      mkfs.fat -F32 ${EFIDEVICE}

      efi_mount

    }

    efi_mount() {

      efimountdir="/mnt/boot" #/mnt/efi

      mount ${EFIDEVICE} ${efimountdir}

      fstab

    }

    efi_format

  )

  ext4() (

    cryptsetup_open() {

      cryptsetup open --type luks2 ${rootdevice} cryptlvm --key-file ${keydir}

    }

    volume_physical() {

      pvcreate /dev/mapper/cryptlvm

      volume_group

    }

    volume_group() {

      vgcreate volgroup0 /dev/mapper/cryptlvm

      volume_create_root

    }

    volume_create_root() {

      lvcreate -L ${rootsize}GB volgroup0 -n cryptroot

      volume_create_home

    }

    volume_create_home() {

      lvcreate -l 100%FREE volgroup0 -n crypthome

      volume_kernel_module

    }

    volume_kernel_module() {

      modprobe dm_mod

      volume_group_scan

    }

    volume_group_scan() {

      vgscan

      volume_group_activate

    }

    volume_group_activate() {

      vgchange -ay

      format_root

    }

    format_root() {

      mkfs.${filesystem} /dev/volgroup0/cryptroot

      mount_root

    }

    mount_root() {

      mount /dev/volgroup0/cryptroot /mnt

      format_home

    }

    format_home() {

      mkfs.${filesystem} /dev/volgroup0/crypthome

      mount_home

    }

    mount_home() {

      mkdir /mnt/home

      mount /dev/volgroup0/crypthome /mnt/home

      boot_partition

    }

    cryptsetup_open
  )

  root_partition

)

fstab() {

  mkdir /mnt/etc/ &>/dev/null

  genfstab -U /mnt >>/mnt/etc/fstab

  archinstall

}

archinstall() (

  mirrorlist() {

    echo "Reflector: Updating Pacman mirrorlist..."

    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist

    clear

    packages

  }

  packages() {

    pacstrap -C ~/arch/cfg/pacman.conf /mnt linux-hardened linux-firmware linux-hardened-headers base base-devel grub efibootmgr dialog vim

    if [ ${dmi} == "VirtualBox" ] || [ ${dmi} == "VMware Virtual Platform" ]; then
      case ${dmi} in
      "VirtualBox")
        pacstrap -C ~/arch/cfg/pacman.conf /mnt virtualbox-guest-utils
        ;;
      "VMware Virtual Platform")
        pacstrap -C ~/arch/cfg/pacman.conf /mnt open-vm-tools
        ;;
      esac
    fi

    chroot

  }

  mirrorlist

)

chroot() {

  export keymap
  export nodename
  export username
  export user_password
  export root_password
  export grubpw
  export dmi

  cp -f ${dialogrc} /mnt/etc/dialogrc
  cp -f ${pacmanconf} /mnt/etc/pacman.conf
  cp -f /root/arch/src/chroot.sh /mnt
  chmod +x /mnt/chroot.sh

  arch-chroot /mnt ./chroot.sh
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nArch-chroot [/mnt] failed.\n\n
    ${exitcode} - arch-chroot /mnt ./chroot.sh" 13 50
  fi

  #umount -l /mnt

  clear
  exit 1

}

while (("$#")); do
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
    ;;
  esac
  shift
done

clear
pre
