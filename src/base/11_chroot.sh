# Chroot

echo "Exporting variables ..."

export keymap
export nodename
export username
export user_password
export root_password
export grubpw
export dmi

cp -f ${dialogrc} /mnt/etc/dialogrc
cp -f ${pacmanconf} /mnt/etc/pacman.conf
cp -f ${script_dir}/src/chroot/chroot.sh /mnt

chmod +x /mnt/chroot.sh

arch-chroot /mnt ./chroot.sh

if [ ${?} != "0" ]; then
  dialog --title " ERROR " --msgbox "\nArch-chroot [/mnt] failed.\n\n
  Exitcode: ${exitcode}" 13 50
fi

umount -l /mnt

clear && exit 1
