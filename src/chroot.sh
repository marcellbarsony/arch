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

  sysadmin_dialog()(

    # https://wiki.archlinux.org/title/General_recommendations#System_administration

    root_password(){

      root_password=$(whiptail --passwordbox "Root passphrase" --title "Root passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

      root_password_confirm=$(whiptail --passwordbox "Root passphrase confirm" --title "Root passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

      if [ ! ${root_password} ] || [ ! ${root_password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "Root passphrase cannot be empty." 8 78
        root_password
      fi

      if [ ${root_password} != ${root_password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "Root passphrase did not match." 8 78
        root_password
      fi

      user_account

    }

    user_account(){

      username=$(whiptail --inputbox "" --title "User account" --nocancel 8 39 3>&1 1>&2 2>&3)

      if [ ! ${username} ] || [ ${username} == "root" ]; then
        whiptail --title "ERROR" --msgbox "Username cannot be empty or [root]." 8 78
        user_account
      fi

      user_password

    }

    user_password(){

      user_password=$(whiptail --passwordbox "User passphrase [${username}]" --title "User passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

      user_password_confirm=$(whiptail --passwordbox "User passphrase confirm [${username}]" --title "User passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

      if [ ! ${user_password} ] || [ ! ${user_password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "User passphrase cannot be empty." 8 78
        user_password
      fi

      if [ ${user_password} != ${user_password_confirm} ]; then
        whiptail --title "ERROR" --msgbox "User passphrase did not match." 8 78
        user_password
      fi

      domain_name

    }

    domain_name(){

      nodename=$(whiptail --inputbox "" --title "Hostname" --nocancel 8 39 3>&1 1>&2 2>&3)

      if [ ! ${nodename} ]; then
        whiptail --title "ERROR" --msgbox "Hostname cannot be empty." 8 78
        domain_name
      fi

      grub_password

    }

    grub_password(){

      grubpw=$(whiptail --passwordbox "GRUB Passphrase" --title "GRUB Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)
      grubpw_confirm=$(whiptail --passwordbox "GRUB Passphrase [confirm]" --title "GRUB Passphrase" --nocancel 8 78 3>&1 1>&2 2>&3)

      if [ ! ${grubpw} ] || [ ! ${grubpw_confirm} ]; then
        whiptail --title "ERROR" --msgbox "GRUB passphrase cannot be empty." 8 78
        grub_password
      fi

      if [ ${grubpw} != ${grubpw_confirm} ]; then
        whiptail --title "ERROR" --msgbox "GRUB passphrase did not match." 8 78
        grub_password
      fi

      sysadmin

    }

    root_password

  )

  sysadmin()(

    root_password(){

      error=$( echo "root:${root_password}" | chpasswd 2>&1 )

      if [ $? != "0" ]; then
        whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
        case $? in
          0)
            root_password
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

      user_create

    }

    user_create(){

      useradd -m ${username}

      if [ $? != "0" ]; then
        whiptail --title "ERROR" --yesno "Cannot create user account [${username}].\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
        case $? in
          0)
            user_create
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

      user_password

    }

    user_password(){

      error=$( echo "${username}:${user_password}" | chpasswd 2>&1 )

      if [ $? != "0" ]; then
        whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
        case $? in
          0)
            user_password
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

      user_group


    }

    user_group(){

      usermod -aG wheel,audio,video,optical,storage ${username} 2>&1

      if [ "$?" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Cannot add ${username} to groups.\nExit status: $?" 8 78
      fi

      domain_name

    }

    domain_name(){

      hostnamectl set-hostname ${nodename}

      if [ "$?" != "0" ]; then
        whiptail --title "ERROR" --msgbox "Hostname [${nodename}] cannot be set.\nExit status: $?" 8 78
      fi

      hosts

    }

    root_password

  )

  sysadmin_dialog

)

hosts(){

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

  echo 33 | whiptail --gauge "Add insults..." 6 50 0
  sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  echo 66 | whiptail --gauge "Disable password prompt timeout..." 6 50 0
  sed '72 i Defaults passwd_timeout=0' /etc/sudoers > /etc/sudoers.new
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
    sleep 1
  fi

  pacman -Qi btrfs-progs > /dev/null
  if [ "$?" == "0" ]; then
    echo 0 | whiptail --gauge "Add LVM support to mkinitcpio..." 6 50 0
    #MODULES=(btrfs)
    sed -i "s/MODULES=()/MODULES=(btrfs)/g" /etc/mkinitcpio.conf
    sed -i "s/block filesystems/block encrypt filesystems/g" /etc/mkinitcpio.conf
    sleep 1
  fi

  mkinitcpio -p linux

  locale

}

btrfs()(

  btrfs_uuid(){

    blkid

    # UUID of ${rootdisk}
    # UUID="123456

    vim /etc/default/grub

  }

)

locale(){

  echo 50 | whiptail --gauge "Set locale.gen... [en_US.UTF-8 UTF-8]" 6 50 0
  sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

  echo 100 | whiptail --gauge "Set locale.conf... [LANG=en_US.UTF-8]" 6 50 0
  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  locale-gen

  #efimount
  grub

}

grub()(

  grub_packages(){

    clear
    pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GRUB packages were not installed.\nExit status: ${exitcode}" 8 78
    fi

    grub_password

  }

  grub_password(){

    grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

    echo "cat << EOF" >> /etc/grub.d/00_header
    echo "set superusers=\"${username}\"" >> /etc/grub.d/00_header
    echo "password_pbkdf2 ${username} ${grubpass}" >> /etc/grub.d/00_header
    echo "EOF" >> /etc/grub.d/00_header

    grub_install

  }

  grub_install(){

    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GRUB cannot be installed to [/boot/efi].\nExit status: ${exitcode}" 8 78
    fi

    grub_crypt

  }

  grub_crypt(){

    pacman -Qi lvm2 > /dev/null

    if [ "$?" == "0" ]; then
      sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=/dev/nvme0n1p3:volgroup0:allow-discards\ loglevel=3\ quiet\ video=1920x1080\" /etc/default/grub
      sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub
    fi

    pacman -Qi btrfs-progs > /dev/null

    if [ "$?" == "0" ]; then
      uuid=( blkid | grep ${rootdevice} | cut -d\" -f 2 ) #Root disk UUID, not cryptroot
      sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ cryptdevice=UUID=${uuid}:cryptroot root=/dev/mapper/cryptroot:allow-discards\ video=1920x1080\" /etc/default/grub
      sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub
    fi

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
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Grub config cannot be generated.\nExit status: ${exitcode}" 8 78
    fi

    modules

  }

  grub_packages

)

modules()(

  virtualmodules(){

    pacman -Qi virtualbox-guest-utils > /dev/null
    if [ "$?" == "0" ]; then

      systemctl enable vboxservice.service
      local exitcode=$?

        if [ "${exitcode}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "VirtualBox service cannot be enabled.\nExit status: ${exitcode}" 8 78
        fi

      modprobe -a vboxguest vboxsf vboxvideo
      local exitcode2=$?

        if [ "${exitcode2}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "VirtualBox kernel modules cannot be loaded.\nExit status: ${exitcode2}" 8 78
        fi

      VBoxClient-all
      local exitcode3=$?

        if [ "${exitcode3}" != "0" ]; then
          whiptail --title "ERROR" --msgbox "VirtualBox guest services cannot be enabled.\nExit status: ${exitcode3}" 8 78
        fi

    fi

    openssh

  }

  openssh(){

    pacman -S --noconfirm networkmanager openssh

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "OpenSSH cannot be installed.\nExit status: $?" 8 78
      fi

    systemctl enable sshd.service

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "OpenSSH cannot be enabled.\nExit status: $?" 8 78
      fi

    networkmanager

  }

  networkmanager(){

    pacman -S --noconfirm networkmanager

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network Manager cannot be installed.\nExit status: $?" 8 78
      fi

    systemctl enable NetworkManager

      if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network Manager cannot be enabled.\nExit status: $?" 8 78
      fi

    exit 69

  }

  fstrim(){

    systemctl enable fstrim.timer

  }

  watchdog(){

    # Fix Watchdog error reports at shutdown
    sed -i /\#RebootWatchdogSec=10min/c\RebootWatchdogSec=0 /etc/systemd/system.conf

  }

  virtualmodules

)

keymap
