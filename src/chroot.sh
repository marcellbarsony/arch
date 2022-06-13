#!/bin/bash

rootpassword(){

  password=$(whiptail --passwordbox "Root password" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "Root password confirm" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password empty." 8 78
      rootpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password did not match." 8 78
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

  username=$(whiptail --inputbox "" --title "User account" --nocancel 8 39 3>&1 1>&2 2>&3)

  if [ ! ${username} ] || [ ${username} == "root" ]; then
    whiptail --title "ERROR" --msgbox "Username cannot be empty or [root]." 8 78
    useraccount
  fi

  useradd -m ${username}
  userpassword

}

userpassword(){

  password=$(whiptail --passwordbox "User password [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "User password confirm [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password empty." 8 78
      userpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password did not match." 8 78
      userpassword
  fi

  error=$(echo "${username}:${password}" | chpasswd 2>&1 )

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

  membership=$(groups ${username})

  whiptail --title "Example Dialog" --msgbox "${username} has been added to the following groups:\n${membership}" 8 78

  domainname

}

domainname(){

  nodename=$(whiptail --inputbox "" --title "Hostname" --nocancel 8 39 3>&1 1>&2 2>&3)

  if [ ! ${nodename} ]; then
    whiptail --title "ERROR" --msgbox "Hostname cannot be empty." 8 78
    nodename
  fi

  hostnamectl set-hostname ${nodename}

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Hostname cannot be set.\nExit status: $?" 8 78
  fi

  hosts

}

hosts(){

  echo "127.0.0.1        localhost" > /etc/hosts
  echo "::1              localhost" >> /etc/hosts
  echo "127.0.1.1        ${nodename}" >> /etc/hosts

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Hosts file cannot be changed." 8 78
    exit 1
  fi

  sudoers

}

sudoers(){

  # Uncomment %wheel group
  sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  # Insults
  sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  configs

}

configs(){

  git clone https://github.com/marcellbarsony/dotfiles.git /home/${username}/.config
  cd /home/${username}
  chown -R ${username}:${username} .config

}

initramfs(){

  echo "Mkinitcpio"
  mkinitcpio -p linux
  cp /home/${username}/.config/_system/mkinitcpio/mkinitcpio.conf /etc/mkinitcpio.conf

}

locale(){

  echo "Copying locale.gen"
  cp $HOME/.config/_system/locale/locale.gen /etc/locale.gen

  echo "Copying locale.conf"
  cp $HOME/.config/_system/locale/locale.conf /etc/locale.conf

  # locale configuration files
  # - locale.gen
  # - locale.conf
  locale-gen

}

grub(){

  pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

  # GRUB - Install
  grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

  # GRUB - Generate config
  grub-mkconfig -o /boot/grub/grub.cfg

  #mkdir /boot/EFI
  #mount /dev/sda1 /boot/EFI #VM
  #mount /dev/nvme0n1p1 /boot/EFI #PM


}

vboxkernelmodules(){

  systemctl enable vboxservice.service

  modprobe -a vboxguest vboxsf vboxvideo

}

supportpackages(){

  # Install packages
  pacman -S --noconfirm lvm2 networkmanager openssh

  # Network Manager
  systemctl enable NetowrkManager

  # Open SSH
  systemctl enable sshd.service

}


rootpassword
