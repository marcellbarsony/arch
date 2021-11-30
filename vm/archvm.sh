#!/bin/bash

# --------------------------------------------------
# Arch Linux installation script
# WARNING: script is under development & hard-coded
# WARNING: this script is designed for VM installation
# https://wiki.archlinux.org/
# by Marcell Barsony
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

newline="\n"
read -p "Enter the amount of sleep time in seconds: " waitseconds
wait="sleep ${waitseconds}"
$wait
clear

# --------------------------------------------------
# Disk partitioning
# --------------------------------------------------

# echo "Checking for available disk"
# $wait
# echo -ne $newline
# disk=$(lsblk -d -p -n -l -o NAME -e 7,11)
# echo "The current disk is ${disk}"
# $wait
# echo -ne $newline
# echo "Formatting disk with <fdisk> manually"
# $wait

fdisk /dev/sda

clear

# --------------------------------------------------
# Formatting disks
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting disks"
echo "------------------------------"
echo -ne $newline

echo "Formatting & mounting BOOT: /dev/sda1 (FAT32)"
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
echo -ne $newline

echo "Formatting & mounting ROOT: /dev/sda2 (ext4)"
# mkfs.ext4 /dev/sda2
# mount /dev/sda2 /mnt
# $wait
# echo -ne $newline

echo "Checking mountpoints"
lsblk
$wait
clear

echo "------------------------------"
echo "# fstab"
echo "------------------------------"
echo -ne $newline

echo "Creating fstab directory"
mkdir /mnt/etc/
$wait
echo -ne $newline

echo "Generating fstab config"
genfstab -U /mnt >> /mnt/etc/fstab
$wait
echo -ne $newline

echo "Checking fstab"
cat /mnt/etc/fstab
$wait
clear

# --------------------------------------------------
# Kernel
# --------------------------------------------------

echo "------------------------------"
echo "# Kernel"
echo "------------------------------"
echo -ne $newline

echo "Installing essential packages"
$wait
echo -ne $newline
pacstrap /mnt base linux linux-firmware linux-headers base-devel virtualbox-guest-utils git nano vim
$wait
clear

# --------------------------------------------------
# Chroot
# --------------------------------------------------

echo "------------------------------"
echo "# Chroot"
echo "------------------------------"
echo -ne $newline

echo "Changing root to the new Arch system"
$wait
clear

arch-chroot /mnt
