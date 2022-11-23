# Arch install

echo "Reflector: Updating Pacman mirrorlist ..."

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist

clear

echo "Pacman: Updating Arch Linux keyring ..."

pacman -Sy --noconfirm archlinux-keyring

clear

echo "Pacstrap: Installing system ..."

pacstrap -C ${pacmanconf} /mnt linux-hardened linux-hardened-headers linux-firmware base base-devel grub efibootmgr dialog vim

if [ ${dmi} == "VirtualBox" ] || [ ${dmi} == "VMware Virtual Platform" ]; then
  case ${dmi} in
  "VirtualBox")
    pacstrap -C ${pacmancfg} /mnt virtualbox-guest-utils
    ;;
  "VMware Virtual Platform")
    pacstrap -C ${pacmancfg} /mnt open-vm-tools
    ;;
  esac
fi

clear
