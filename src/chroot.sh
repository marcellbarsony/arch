#!/bin/bash

sysadmin() (

  setkeymap() {

    echo "Set keymap [${keymap}]..." && sleep 1

    loadkeys ${keymap} &>/dev/null
    localectl set-keymap --no-convert ${keymap} &>/dev/null # Systemd reads from /etc/vconsole.conf

    root_passphrase

  }

  root_passphrase() {

    echo "Set root password..." && sleep 1

    echo "root:${root_password}" | chpasswd 2>&1
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot set root password." 8 45
      exit ${exitcode}
    fi

    user_create

  }

  user_create() {

    echo "Add user [${username}]..." && sleep 1

    useradd -m ${username}

    user_passphrase

  }

  user_passphrase() {

    echo "Set ${username}'s password..." && sleep 1

    error=$(echo "${username}:${user_password}" | chpasswd 2>&1)
    local exitcode=$?

    if [ ${exitcode} != "0" ]; then
      dialog --title " ERROR " --msgbox "\nCannot set user password [${username}]" 8 45
      exit ${exitcode}
    fi

    user_group

  }

  user_group() {

    echo "Add ${username} to groups..." && sleep 1

    usermod -aG wheel,audio,video,optical,storage ${username} 2>&1

    domain_name

  }

  domain_name() {

    echo "Set hostname >> ${nodename}" && sleep 1

    echo ${nodename} > /etc/hostname
    hostnamectl set-hostname ${nodename}

    hosts

  }

  setkeymap

)

hosts() {

  echo "Set hosts..."

  echo "127.0.0.1        localhost" >/etc/hosts &>/dev/null
  echo "::1              localhost" >>/etc/hosts &>/dev/null
  echo "127.0.1.1        ${nodename}" >>/etc/hosts &>/dev/null

  sudoers

}

sudoers() {

  sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers >/etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  sed '71 i Defaults:%wheel insults' /etc/sudoers >/etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  sed '72 i Defaults passwd_timeout=0' /etc/sudoers >/etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  locale

}

locale() {

  sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
  echo "LANG=en_US.UTF-8" >/etc/locale.conf

  locale-gen

  clear && initramfs

}

initramfs() {

  sleep 1 && clear
  sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
  sed -i 's/block filesystems/block encrypt btrfs filesystems/g' /etc/mkinitcpio.conf

  #sed -i "s/BINARIES=()/BINARIES=(btrfsck)/g" /etc/mkinitcpio.conf
  #sed -i "s/block filesystems/block encrypt btrfs lvm2 filesystems/g" /etc/mkinitcpio.conf
  #sed -i "s/keyboard fsck/keyboard fsck grub-btrfs-overlayfs/g" /etc/mkinitcpio.conf

  mkinitcpio -p linux-hardened #-P

  security

}

security() {

  # Delay after a failed login attempt
  sed -i '6i auth       optional   pam_faildelay.so     delay=5000000' /etc/pam.d/system-login

  fixes

}

fixes() {

  # Watchdog error reports at shutdown
  sed -i /\#RebootWatchdogSec=10min/c\RebootWatchdogSec=0 /etc/systemd/system.conf
  #sed -i 's/RebootWatchdogSec=10min/RebootWatchdogSec=0/g' /etc/systemd/system.conf

  grub

}

grub() (

  grub_password() {

    grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

    echo "cat << EOF" >>/etc/grub.d/00_header
    echo "set superusers=\"${username}\"" >>/etc/grub.d/00_header
    echo "password_pbkdf2 ${username} ${grubpass}" >>/etc/grub.d/00_header
    echo "EOF" >>/etc/grub.d/00_header

    grub_crypt
    #keyb0ardninja

  }

  keyb0ardninja() (

    grub_header() {

      luksuuid=$(blkid | grep /dev/sda2 | cut -d\" -f 2 | sed -e 's/-//g')

      echo '#!/bin/sh' >/etc/grub.d/01_header
      echo -n "echo " >>/etc/grub.d/01_header
      echo -n $(echo \"cryptomount -u ${luksuuid}\") >>/etc/grub.d/01_header

      grub_btrfs

    }

    grub_btrfs() {

      sed -i '/#GRUB_BTRFS_GRUB_DIRNAME=/s/^#//g' /etc/default/grub-btrfs/config
      #sed -i 's/GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"/GRUB_BTRFS_GRUB_DIRNAME="/efi/grub"/g' /etc/grub-btrfs/config
      sed -i 's/boot\/grub2/efi\/grub/g' /etc/default/grub-btrfs/config
      #sed -i "s/GRUB_BTRFS_GRUB_DIRNAME=\"/boot/grub2\"/GRUB_BTRFS_GRUB_DIRNAME=\"/efi/grub\"/g" /etc/grub-btrfs/config

      systemctl enable --now grub-btrfs.path

      grub_crypt

    }

    grub_header

  )

  grub_crypt() {

    uuid=$(blkid | grep /dev/sda2 | cut -d\" -f 2) #Root disk UUID, not cryptroot UUID
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

  grub_install() {

    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
    #grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi --boot-directory=/efi
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nGRUB cannot be installed" 8 45
      exit ${exitcode}
    fi

    grub_config

  }

  grub_config() {

    grub-mkconfig -o /boot/grub/grub.cfg
    #grub-mkconfig -o /efi/grub/grub.cfg
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      dialog --title " ERROR " --msgbox "\nGRUB config cannot be generated" 8 45
      exit ${exitcode}
    fi

    clear && packages

  }

  #grub_customization() {

  # GRUB Config

  # GRUB Resolution
  # Get resolution: hwinfo --framebuffer
  # Change config: GRUB_GFXMODE=1024x768x32
  # Change config: GRUB_GFXPAYLOAD_LINUX=keep
  # Apply changes: grub-mkconfig -o /boot/grub/grub.cfg

  #}

  grub_password

)

packages() {

  pacman -S --noconfirm btrfs-progs snapper networkmanager openssh git github-cli reflector ntp
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nPacman: cannot install packages" 8 45
    exit ${exitcode}
  fi

  clear && services

}

services() (

  systemctl enable ntpd.service
  systemctl enable sshd.service
  systemctl enable NetworkManager
  systemctl enable fstrim.timer

  case ${dmi} in
  "VirtualBox")
    systemctl enable vboxservice.service
    modprobe -a vboxguest vboxsf vboxvideo
    VBoxClient-all
    ;;
  "VMware Virtual Platform")
    systemctl enable vmtoolsd.service
    systemctl enable vmware-vmblock-fuse.service
    ;;
  esac

  clear && btrfs_config

)

btrfs_config() {

  # https://wiki.archlinux.org/title/snapper
  # snapper -c config create-config /path/to/subvolume
  snapper -c home create-config /home

  clean_up

}

clean_up() {

  rm /chroot.sh && exit 69

}

clear && sysadmin
