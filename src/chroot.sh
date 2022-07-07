#!/bin/bash

keymap(){

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

  fi

  system_administration

}

system_administration()(

  sysadmin_dialog()(

    # https://wiki.archlinux.org/title/General_recommendations#System_administration

    root_password(){

      root_password=$(dialog --nocancel --passwordbox "Root passphrase" 8 45 3>&1 1>&2 2>&3)

      root_password_confirm=$(dialog --nocancel --passwordbox "Root passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${root_password} ] || [ ! ${root_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nRoot passphrase cannot be empty." 8 45
        root_password
      fi

      if [ ${root_password} != ${root_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nRoot passphrase did not match." 8 45
        root_password
      fi

      user_account

    }

    user_account(){

      username=$(dialog --nocancel --inputbox "Username" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${username} ] || [ ${username} == "root" ]; then
        dialog --title " ERROR " --msgbox "\nUsername cannot be empty or [root]." 8 45
        user_account
      fi

      user_password

    }

    user_password(){

      user_password=$(dialog --nocancel --passwordbox "${username}'s passphrase" 8 45 3>&1 1>&2 2>&3)

      user_password_confirm=$(dialog --nocancel --passwordbox "${username}'s passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${user_password} ] || [ ! ${user_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nUser passphrase cannot be empty." 8 45
        user_password
      fi

      if [ ${user_password} != ${user_password_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nUser passphrase did not match." 8 45
        user_password
      fi

      domain_name

    }

    domain_name(){

      nodename=$(dialog --nocancel --inputbox "Hostname" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${nodename} ]; then
        dialog --title " ERROR " --msgbox "\nHostname cannot be empty." 8 45
        domain_name
      fi

      grub_password

    }

    grub_password(){

      grubpw=$(dialog --nocancel --passwordbox "GRUB passphrase" 8 45 3>&1 1>&2 2>&3)

      grubpw_confirm=$(dialog --nocancel --passwordbox "GRUB passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

      if [ ! ${grubpw} ] || [ ! ${grubpw_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nGRUB passphrase cannot be empty." 8 45
        grub_password
      fi

      if [ ${grubpw} != ${grubpw_confirm} ]; then
        dialog --title " ERROR " --msgbox "\nGRUB passphrase did not match." 8 45
        grub_password
      fi

      sysadmin

    }

    root_password

  )

  sysadmin()(

    root_password(){

      echo "root:${root_password}" | chpasswd 2>&1
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        dialog --title " ERROR " --msgbox "\nCannot set root password." 8 45
        exit ${exitcode}
      fi

      user_create

    }

    user_create(){

      useradd -m ${username}
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        dialog --title " ERROR " --msgbox "\nCannot create user account [${username}]" 8 45
        exit ${exitcode}
      fi

      user_password

    }

    user_password(){

      error=$( echo "${username}:${user_password}" | chpasswd 2>&1 )
      local exitcode=$?

      if [ ${exitcode} != "0" ]; then
        dialog --title " ERROR " --msgbox "\nCannot set user password [${username}]" 8 45
        exit ${exitcode}
      fi

      user_group

    }

    user_group(){

      usermod -aG wheel,audio,video,optical,storage ${username} 2>&1
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        dialog --title " ERROR " --msgbox "\nCannot add [${username}] to groups" 8 45
        exit ${exitcode}
      fi

      domain_name

    }

    domain_name(){

      hostnamectl set-hostname ${nodename}
      local exitcode=$?

      if [ "${exitcode}" != "0" ]; then
        dialog --title " ERROR " --msgbox "\nHostname [${nodename}] cannot be set" 8 45
        exit ${exitcode}
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

  sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  sed '72 i Defaults passwd_timeout=0' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  locale

}

locale(){

  sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  clear

  locale-gen
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nCannot generate locale [locale-gen]" 8 45
    exit ${exitcode}
  fi

  initramfs

}

initramfs(){

  sleep 1 && clear
  sed -i "s/MODULES=()/MODULES=(btrfs)/g" /etc/mkinitcpio.conf
  sed -i "s/block filesystems/block encrypt btrfs filesystems/g" /etc/mkinitcpio.conf

  #sed -i "s/BINARIES=()/BINARIES=(btrfsck)/g" /etc/mkinitcpio.conf
  #sed -i "s/block filesystems/block encrypt btrfs lvm2 filesystems/g" /etc/mkinitcpio.conf
  #sed -i "s/keyboard fsck/keyboard fsck grub-btrfs-overlayfs/g" /etc/mkinitcpio.conf

  mkinitcpio -p linux #linux-hardened
  #mkinitcpio -P

  grub

}

grub()(

  grub_password(){

    grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

    echo "cat << EOF" >> /etc/grub.d/00_header
    echo "set superusers=\"${username}\"" >> /etc/grub.d/00_header
    echo "password_pbkdf2 ${username} ${grubpass}" >> /etc/grub.d/00_header
    echo "EOF" >> /etc/grub.d/00_header

    grub_crypt
    #keyb0ardninja

  }

  keyb0ardninja()(

    grub_header(){

      luksuuid=$( blkid | grep /dev/sda2 | cut -d\" -f 2 | sed -e 's/-//g' )

      echo '#!/bin/sh' > /etc/grub.d/01_header
      echo -n "echo " >> /etc/grub.d/01_header
      echo -n `echo \"cryptomount -u ${luksuuid}\"` >> /etc/grub.d/01_header
      #chmod

      grub_btrfs

    }

    grub_btrfs(){

      sed -i '/#GRUB_BTRFS_GRUB_DIRNAME=/s/^#//g' /etc/default/grub-btrfs/config
      #sed -i 's/GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"/GRUB_BTRFS_GRUB_DIRNAME="/efi/grub"/g' /etc/grub-btrfs/config
      sed -i 's/boot\/grub2/efi\/grub/g' /etc/default/grub-btrfs/config
      #sed -i "s/GRUB_BTRFS_GRUB_DIRNAME=\"/boot/grub2\"/GRUB_BTRFS_GRUB_DIRNAME=\"/efi/grub\"/g" /etc/grub-btrfs/config

      systemctl enable --now grub-btrfs.path

      grub_crypt

    }

    grub_header

  )

  grub_crypt(){

    uuid=$( blkid | grep /dev/sda2 | cut -d\" -f 2 ) #Root disk UUID, not cryptroot UUID
    sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ cryptdevice=UUID=${uuid}:cryptroot:allow-discards\ root=/dev/mapper/cryptroot\ video=1920x1080\" /etc/default/grub
    sed -i /GRUB_PRELOAD_MODULES=/c\GRUB_PRELOAD_MODULES=\"part_gpt\ part_msdos\ luks2\" /etc/default/grub
    sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub

    #ext4
    #pacman -Qi lvm2 > /dev/null
    #if [ "$?" == "0" ]; then
      #sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=/dev/nvme0n1p3:volgroup0:allow-discards\ loglevel=3\ quiet\ video=1920x1080\" /etc/default/grub
      #sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub
    #fi

    grub_install

  }

  grub_install(){

    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
    #grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi --boot-directory=/efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nGRUB cannot be installed" 8 45
      exit ${exitcode}
    fi

    grub_config

  }

  grub_config(){

    grub-mkconfig -o /boot/grub/grub.cfg
    #grub-mkconfig -o /efi/grub/grub.cfg
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nGRUB config cannot be generated" 8 45
      exit ${exitcode}
    fi

    modules

  }

  #grub_customization(){

    # GRUB Theme
      # https://github.com/Patato777/dotfiles/tree/main/grub/themes/virtuaverse
      # http://wiki.rosalab.ru/en/index.php/Grub2_theme_tutorial

    # GRUB Config

    # GRUB Resolution
      # Get resolution: hwinfo --framebuffer
      # Change config: GRUB_GFXMODE=1024x768x32
      # Change config: GRUB_GFXPAYLOAD_LINUX=keep
      # Apply changes: grub-mkconfig -o /boot/grub/grub.cfg

  #}

  grub_password

)

packages(){

  pacman -S --noconfirm btrfs-progs snapper \
    networkmanager openssh \
    reflector dialog git neovim \
    intel-ucode \
    #efibootmgr dosfstools
    #pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber sof-audio
    #lvm2
    #xorg-server xorg-xinit xorg-prop xwallpaper arandr

  modules

}

modules()(

  # Virtual Box
  pacman -Qi virtualbox-guest-utils &> /dev/null
  if [ "$?" == "0" ]; then

    dmi="virtualbox"

    systemctl enable vboxservice.service
    local exitcode1=$?

    modprobe -a vboxguest vboxsf vboxvideo
    local exitcode2=$?

    VBoxClient-all
    local exitcode3=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ] ; then
      dialog --title " ERROR " --msgbox "\nCannot enable VirtualBox modules\n\n
      ${exitcode1} - Virtualbox Service [vboxservice.service]\n
      ${exitcode2} - VirtualBox kernel modules [modprobe -a]\n
      ${exitcode3} - VirtualBox Guest services [VBoxClient-all]" 13 45
      clear
    fi

  fi

  # VMware
  pacman -Qi open-vm-tools &> /dev/null
  if [ "$?" == "0" ]; then

    dmi="vmware"
    systemctl enable vmtoolsd.service
    local exitcode1=$?
    systemctl enable vmware-vmblock-fuse.service
    local exitcode2=$?

    if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot enable VMware modules\n\n
      ${exitcode1} - VMware tools.service\n
      ${exitcode2} - VMware vmblock-fuse" 8 45
      clear
    fi

  fi

  # OpenSSH
  systemctl enable sshd.service

  # Network Manager
  systemctl enable NetworkManager

  # Fstrim (SSD)
  systemctl enable fstrim.timer

  wathcdog_fix

)

watchdog_fix(){

    # Fix Watchdog error reports at shutdown
    sed -i /\#RebootWatchdogSec=10min/c\RebootWatchdogSec=0 /etc/systemd/system.conf

    clean_up

}


clean_up(){

  rm /chroot.sh

  exit 69

}

keymap
