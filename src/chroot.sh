#!/bin/bash

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

  system_administration

}

system_administration()(

  # https://wiki.archlinux.org/title/General_recommendations#System_administration

  rootpassword(){

    password=$(whiptail --passwordbox "Root passphrase" --title "ROOT Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

    password_confirm=$(whiptail --passwordbox "Root passphrase confirm" --title "ROOT Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

    if [ ! ${password} ] || [ ! ${password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "Root passphrase cannot be empty." 8 78
        rootpassword
    fi

    if [ ${password} != ${password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "Root passphrase did not match." 8 78
        rootpassword
    fi

    error=$(echo "root:${password}" | chpasswd 2>&1 )

    if [ $? != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
        0)
          rootpassword
          ;;
        1)
          exit 1
          clear
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac
    fi

    useraccount

  }

  useraccount(){

    username=$(whiptail --inputbox "" --title "USER Account" --nocancel 8 39 3>&1 1>&2 2>&3)

    if [ ! ${username} ] || [ ${username} == "root" ]; then
      whiptail --title "ERROR" --msgbox "Username cannot be empty or [root]." 8 78
      useraccount
    fi

    useradd -m ${username}
    userpassword

  }

  userpassword(){

    password=$(whiptail --passwordbox "User passphrase [${username}]" --title "USER Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

    password_confirm=$(whiptail --passwordbox "User passphrase confirm [${username}]" --title "USER Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

    if [ ! ${password} ] || [ ! ${password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "User passphrase cannot be empty." 8 78
        userpassword
    fi

    if [ ${password} != ${password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "User passphrase did not match." 8 78
        userpassword
    fi

    echo 0 | whiptail --gauge "Set ${username}'s password..." 6 50 0
    error=$( echo "${username}:${password}" | chpasswd 2>&1 )

    if [ $? != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
        0)
          userpassword
          ;;
        1)
          exit 1
          clear
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac
    fi

    usergroup

  }

  usergroup(){

    echo 0 | whiptail --gauge "Add ${username} to groups..." 6 50 0
    error=$(usermod -aG wheel,audio,video,optical,storage ${username} 2>&1)

    if [ $? != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
      case $? in
        0)
          usergroup
          ;;
        1)
          exit 1
          clear
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac
    fi

    domainname

  }

  domainname(){

    nodename=$(whiptail --inputbox "" --title "Hostname" --nocancel 8 39 3>&1 1>&2 2>&3)

    if [ ! ${nodename} ]; then
      whiptail --title "ERROR" --msgbox "Hostname cannot be empty." 8 78
      nodename
    fi

    echo 0 | whiptail --gauge "Set hostname..." 6 50 0
    hostnamectl set-hostname ${nodename}

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Hostname cannot be set.\nExit status: $?" 8 78
    fi

    hosts

  }

  rootpassword

)

hosts(){

  echo 0 | whiptail --gauge "Update hosts file..." 6 50 0
  echo "127.0.0.1        localhost" > /etc/hosts &>/dev/null
  echo "::1              localhost" >> /etc/hosts &>/dev/null
  echo "127.0.1.1        ${nodename}" >> /etc/hosts &>/dev/null

  sudoers

}

sudoers(){

  echo 0 | whiptail --gauge "Uncomment %wheel group..." 6 50 0
  sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  echo 0 | whiptail --gauge "Add insults..." 6 50 0
  sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  initramfs

}

initramfs(){

  pacman -Qi lvm2 > /dev/null
  if [ "$?" == "0" ]; then
    echo 0 | whiptail --gauge "Add LVM support to mkinitcpio..." 6 50 0
    sed -i "s/block filesystems/block encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
  fi

  #Btrfs
    MODULES=(btrfs)
    sed -i "s/block filesystems/block encrypt filesystems/g" /etc/mkinitcpio.conf

  mkinitcpio -p linux

  locale

}

btrfs_uuid(){

  blkid

  # UUID of ${rootdisk}
  # UUID="123456

  vim /etc/default/grub



}

locale(){

  echo 0 | whiptail --gauge "Set locale.gen... [en_US.UTF-8 UTF-8]" 6 50 0
  sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

  echo 50 | whiptail --gauge "Set locale.conf... [LANG=en_US.UTF-8]" 6 50 0
  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  locale-gen

  efimount

}

efimount(){

  efimountpoint="/boot/efi"
  echo 0 | whiptail --gauge "Mount EFI to ${efimountpoint}..." 6 50 0

  pacman -Qi virtualbox-guest-utils > /dev/null
  if [ "$?" == "0" ]; then
      mount --mkdir /dev/sda1 ${efimountpoint}
    else
      mount --mkdir /dev/nvme0n1p3 ${efimountpoint}
  fi

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "ESP cannot be mounted to [/boot/efi].\nExit status: $?" 8 78
  fi

  grub

}

grub()(

  grub_packages(){

    clear
    pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GRUB packages were not installed.\nExit status: $?" 8 78
    fi

    grub_password

  }

  grub_password(){

    grubpw=$(whiptail --passwordbox "GRUB Passphrase" --title "GRUB Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)
    grubpw_confirm=$(whiptail --passwordbox "GRUB Passphrase [confirm]" --title "GRUB Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

    if [ ! ${grubpw} ] || [ ! ${grubpw_confirm} ]; then
        whiptail --title "ERROR" --msgbox "GRUB passphrase cannot be empty." 8 78
        userpassword
    fi

    if [ ${grubpw} != ${grubpw_confirm} ]; then
        whiptail --title "ERROR" --msgbox "GRUB passphrase did not match." 8 78
        userpassword
    fi

    grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

    # 00_header
      echo "cat << EOF" >> /etc/grub.d/00_header
      echo "set superusers=\"${username}\"" >> /etc/grub.d/00_header
      echo "password_pbkdf2 ${username} ${grubpass}" >> /etc/grub.d/00_header
      echo "EOF" >> /etc/grub.d/00_header

    grub_install

  }

  grub_install(){

    echo 0 | whiptail --gauge "GRUB install to /boot..." 6 50 0
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck #/boot/efi /boot

    if [ "$?" == "0" ]; then
      whiptail --title "ERROR" --msgbox "GRUB has been installed to [/mnt/boot/efi].\nExit status: $?" 8 78
    fi

    grub_lvm

  }

  grub_lvm(){

    pacman -Qi lvm2 > /dev/null
    if [ "$?" == "0" ]; then
      sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=/dev/nvme0n1p3:volgroup0:allow-discards\ loglevel=3\ quiet\ video=1920x1080\" /etc/default/grub
      sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub
    fi

    #Btrfs
    #sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ cryptdevice=\"${UUID="123}:cryptroot root=/dev/mapper/cryptroot video=1920x1080\" /etc/default/grub

    grub_config

  }

  #grub_customization(){

    # GRUB Theme
      # https://github.com/Patato777/dotfiles/tree/main/grub/themes/virtuaverse
      # http://wiki.rosalab.ru/en/index.php/Grub2_theme_tutorial

    # grub_config

  #}

  grub_config(){

    grub-mkconfig -o /boot/grub/grub.cfg

    if [ "$?" == "0" ]; then
      whiptail --title "ERROR" --msgbox "Grub config has been generated.\nExit status: $?" 8 78
    fi

    modules

  }

  grub_packages

)

modules()(

  virtualmodules(){

    pacman -Qi virtualbox-guest-utils > /dev/null
    if [ "$?" == "0" ]; then

      echo 0 | whiptail --gauge "Enable VirtualBox serice..." 6 50 0
      systemctl enable vboxservice.service

        if [ "$?" != "0" ]; then
        whiptail --title "ERROR" --msgbox "VirtualBox service cannot be enabled.\nExit status: $?" 8 78
        fi

      echo 0 | whiptail --gauge "Load VirtualBox kernel modules [modprobe]..." 6 50 0
      modprobe -a vboxguest vboxsf vboxvideo

        if [ "$?" != "0" ]; then
        whiptail --title "ERROR" --msgbox "VirtualBox kernel modules cannot be loaded.\nExit status: $?" 8 78
        fi

      echo 0 | whiptail --gauge "Enable VirtualBox guest services..." 6 50 0
      VBoxClient-all

        if [ "$?" != "0" ]; then
        whiptail --title "ERROR" --msgbox "VirtualBox guest services cannot be enabled.\nExit status: $?" 8 78
        fi

    fi

    openssh

  }

  openssh(){

    echo 0 | whiptail --gauge "Installing OpenSSH..." 6 50 0
    pacman -S --noconfirm networkmanager openssh

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "OpenSSH cannot be installed.\nExit status: $?" 8 78
      fi

    echo 50 | whiptail --gauge "Enable OpenSSH..." 6 50 0
    systemctl enable sshd.service

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "OpenSSH cannot be enabled.\nExit status: $?" 8 78
      fi

    networkmanager

  }

  networkmanager(){

    echo 0 | whiptail --gauge "Installing Network Manager" 6 50 0
    pacman -S --noconfirm networkmanager

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network Manager cannot be installed.\nExit status: $?" 8 78
      fi

    echo 50 | whiptail --gauge "Enable Network Manager..." 6 50 0
    systemctl enable NetworkManager

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network Manager cannot be enabled.\nExit status: $?" 8 78
      fi

    exit 69

  }

  virtualmodules

)

keymap
