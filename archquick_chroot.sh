#!/bin/zsh

# Boot loader

echo "Install GRUB and other tools"
pacman -S grub efibootmgr dosfstools os-prober mtools

echo "Creating EFI directory for boot"
mkdir /boot/EFI

echo "Mounting EFI partition"
mount /dev/nvme0n1p1 /boot/EFI

sleep 3
clear

echo "Installing grub on the MBR"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

echo "\n"
echo "Checking if local grub directory exists on boot"
ls -l /boot/grub

sleep 3
clear

echo "Copying GRUB config"
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

echo "Opening the config file"