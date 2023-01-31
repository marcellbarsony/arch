# GRUB password

grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')

echo "cat << EOF" >>/etc/grub.d/00_header
echo "set superusers=\"${username}\"" >>/etc/grub.d/00_header
echo "password_pbkdf2 ${username} ${grubpass}" >>/etc/grub.d/00_header
echo "EOF" >>/etc/grub.d/00_header

#keyb0ardninja() {
#
#  # GRUB header
#  luksuuid=$(blkid | grep /dev/sda2 | cut -d\" -f 2 | sed -e 's/-//g')
#
#  echo '#!/bin/sh' >/etc/grub.d/01_header
#  echo -n "echo " >>/etc/grub.d/01_header
#  echo -n $(echo \"cryptomount -u ${luksuuid}\") >>/etc/grub.d/01_header
#
#  # GRUB Btrfs
#  sed -i '/#GRUB_BTRFS_GRUB_DIRNAME=/s/^#//g' /etc/default/grub-btrfs/config
#  #sed -i 's/GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"/GRUB_BTRFS_GRUB_DIRNAME="/efi/grub"/g' /etc/grub-btrfs/config
#  sed -i 's/boot\/grub2/efi\/grub/g' /etc/default/grub-btrfs/config
#  #sed -i "s/GRUB_BTRFS_GRUB_DIRNAME=\"/boot/grub2\"/GRUB_BTRFS_GRUB_DIRNAME=\"/efi/grub\"/g" /etc/grub-btrfs/config
#
#  systemctl enable --now grub-btrfs.path
#
#
#}

#keyb0ardninja

# GRUB crypt (BTRFS)
uuid=$(blkid | grep /dev/sda2 | cut -d\" -f 2) # Root disk UUID, not cryptroot UUID
sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ cryptdevice=UUID=${uuid}:cryptroot:allow-discards\ root=/dev/mapper/cryptroot\ video=1920x1080\" /etc/default/grub
sed -i /GRUB_PRELOAD_MODULES=/c\GRUB_PRELOAD_MODULES=\"part_gpt\ part_msdos\ luks2\" /etc/default/grub
sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub

# GRUB crypt (EXT4)
#pacman -Qi lvm2 > /dev/null
#if [ "$?" == "0" ]; then
#sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=/dev/nvme0n1p3:volgroup0:allow-discards\ loglevel=3\ quiet\ video=1920x1080\" /etc/default/grub
#sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub
#fi

echo "[${WHITE} GRUB ${RESTORE}] Install ... "
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
# /u/keyb0ardninja: grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi --boot-directory=/efi

echo "[${WHITE} GRUB ${RESTORE}] Config ... "
grub-mkconfig -o /boot/grub/grub.cfg
# /u/keyb0ardninja: grub-mkconfig -o /efi/grub/grub.cfg

# GRUB customization
# Get resolution: hwinfo --framebuffer
# Change config: GRUB_GFXMODE=1024x768x32
# Change config: GRUB_GFXPAYLOAD_LINUX=keep
# Apply changes: grub-mkconfig -o /boot/grub/grub.cfg

clear
