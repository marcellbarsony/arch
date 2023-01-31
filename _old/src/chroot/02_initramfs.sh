# Initramfs

errorcheck() {
  if [ "$1" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
    read -n 1 -p "Press any key to continue" answer
    exit $1
  fi
}

echo -n "[${CYAN} MKINITCPIO ${RESTORE}] Add btrfs module to config... "
sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
errorcheck $?

echo -n "[${CYAN} MKINITCPIO ${RESTORE}] Add encrypt & btrfs to config ... "
sed -i 's/block filesystems/block encrypt btrfs filesystems/g' /etc/mkinitcpio.conf
errorcheck $?

#sed -i "s/BINARIES=()/BINARIES=(btrfsck)/g" /etc/mkinitcpio.conf
#sed -i "s/block filesystems/block encrypt btrfs lvm2 filesystems/g" /etc/mkinitcpio.conf
#sed -i "s/keyboard fsck/keyboard fsck grub-btrfs-overlayfs/g" /etc/mkinitcpio.conf

echo -n "[${CYAN} INITRAMFS ${RESTORE}] mkinitcpio ... "
mkinitcpio -p linux-hardened
errorcheck "$?"
clear
