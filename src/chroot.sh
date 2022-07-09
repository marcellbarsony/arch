#!/bin/bash

sysadmin()(

  keymap(){

    echo "Set keymap [${KEYMAP}]..."
    sleep 1

    loadkeys ${KEYMAP} &>/dev/null
    localectl set-keymap --no-convert ${KEYMAP} &>/dev/null # Systemd reads from /etc/vconsole.conf

    root_password

  }

  root_password(){

    echo "Set root password..."
    sleep 1

    echo "root:${ROOT_PASSWORD}" | chpasswd 2>&1
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot set root password." 8 45
      exit ${exitcode}
    fi

    user_create

  }

  user_create(){

    echo "Add user [${USERNAME}]..."
    sleep 1

    useradd -m ${USERNAME}
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot create user account [${USERNAME}]" 8 45
      exit ${exitcode}
    fi

    USER_PASSWORD

  }

  user_password(){

    echo "Set ${USERNAME} password..."
    sleep 1

    error=$( echo "${USERNAME}:${USER_PASSWORD}" | chpasswd 2>&1 )
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot set user password [${USERNAME}]" 8 45
      exit ${exitcode}
    fi

    user_group

  }

  user_group(){

    echo "Add ${USERNAME} to groups..."
    sleep 1

    usermod -aG wheel,audio,video,optical,storage ${USERNAME} 2>&1
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot add [${USERNAME}] to groups" 8 45
      exit ${exitcode}
    fi

    domain_name

  }

  domain_name(){

    echo "Set hostname >> ${NODENAME}"
    sleep 1

    hostnamectl set-hostname ${NODENAME}
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nHostname [${NODENAME}] cannot be set" 8 45
      exit ${exitcode}
    fi

    hosts

  }

  keymap

)

hosts(){

  echo "Set hosts..."

  echo "127.0.0.1        localhost" > /etc/hosts &>/dev/null
  echo "::1              localhost" >> /etc/hosts &>/dev/null
  echo "127.0.1.1        ${NODENAME}" >> /etc/hosts &>/dev/null

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

  mkinitcpio -p linux-hardened
  #mkinitcpio -P

  security

}

security(){

  # Delay after a failed login attempt
  sed -i '6i auth       optional   pam_faildelay.so delay=5000000' > /etc/pam.d/system-login

  fixes

}

fixes(){

  # Fix Watchdog error reports at shutdown
  sed -i /\#RebootWatchdogSec=10min/c\RebootWatchdogSec=0 /etc/systemd/system.conf

  grub

}

grub()(

  grub_password(){

    grubpass=$(echo -e "${GRUBPW}\n${GRUBPW}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

    echo "cat << EOF" >> /etc/grub.d/00_header
    echo "set superusers=\"${USERNAME}\"" >> /etc/grub.d/00_header
    echo "password_pbkdf2 ${USERNAME} ${grubpass}" >> /etc/grub.d/00_header
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

    packages

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
    zsh zsh-completions \
    networkmanager openssh \
    reflector git neovim \
    intel-ucode \
    reflector
    #pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber sof-audio
    #xorg-server xorg-xinit xorg-prop xwallpaper arandr
    #lvm2 dosfstools
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nPacman: cannot install packages" 8 45
      exit ${exitcode}
    fi

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
  local exitcode1=$?

  # Network Manager
  systemctl enable NetworkManager
  local exitcode2=$?

  # Fstrim (SSD)
  systemctl enable fstrim.timer
  local exitcode3=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode3}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Systemctl: Cannot enable services\n\n
    ${exitcode1} - sshd.service\n
    ${exitcode2} - NetworkManager\n
    ${exitcode3} - fstrim.timer" 13 50
  fi

  clean_up

)

clean_up(){

  rm /chroot.sh

  exit 69

}

sysadmin
