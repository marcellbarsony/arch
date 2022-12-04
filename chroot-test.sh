#!/usr/bin/bash

cp -f /media/sf_arch/src/chroot/chroot.sh /mnt
chmod +x /mnt/chroot.sh
arch-chroot /mnt ./chroot.sh
exitcode="$?"

if [ ${exitcode} != "0" ]; then
  dialog --title " ERROR " --msgbox "\nArch-chroot [/mnt] failed.\n\n
  Exitcode: ${exitcode}" 13 50
fi
