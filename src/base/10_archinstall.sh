# Arch install

echo "[${CYAN} REFLECTOR ${RESTORE}] Updating Pacman mirrorlist ... "
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist

echo "[${CYAN} PACMAN ${RESTORE}] Updating Arch Linux keyring ... "
until pacman -Sy --noconfirm archlinux-keyring; do
  echo "[${RED}ERROR${RESTORE}] - Arch Keyring installation failed. Retrying in 3 seconds..."
  sleep 3
done

echo "[${CYAN} PACSTRAP ${RESTORE}] Installing system ... "
until pacstrap -C ${pacmanconf} /mnt linux-hardened linux-hardened-headers linux-firmware base base-devel btrfs-progs dialog efibootmgr git github-cli grub networkmanager ntp openssh reflector snapper vim virtualbox-guest-utils; do
  echo "[${RED}ERROR${RESTORE}] - System installation failed. Retrying in 3 seconds..."
  sleep 3
done

echo "[${CYAN} PACSTRAP ${RESTORE}] Installing DMI packages ... "
pacstrap -C ${pacmancfg} /mnt virtualbox-guest-utils
case ${dmi} in
  "VirtualBox")
    ;;
  "VMware Virtual Platform")
    pacstrap -C ${pacmancfg} /mnt open-vm-tools
    ;;
esac
