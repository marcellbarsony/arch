#!/bin/bash

# --------------------------------------------------
# Arch Linux installation script
# by Marcell Barsony
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

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
echo

echo "Formatting partitions"
mkfs.fat -F32 /dev/sda1 # EFI
mkfs.ext4 /dev/sda2 # File system
echo

echo "Mounting partitions"
mount /dev/sda2 /mnt # File system
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi # EFI
echo

echo "Checking mountpoints"
lsblk
$wait
clear

# --------------------------------------------------
# fstab
# --------------------------------------------------

echo "------------------------------"
echo "# fstab"
echo "------------------------------"
echo

echo "Creating fstab directory"
mkdir /mnt/etc/
echo

echo "Generating fstab config"
genfstab -U /mnt >> /mnt/etc/fstab
echo

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
echo

echo "Installing essential packages"
echo
pacstrap /mnt base linux linux-firmware linux-headers base-devel virtualbox-guest-utils git nano vim
$wait
clear

# --------------------------------------------------
# Chroot
# --------------------------------------------------

echo "------------------------------"
echo "# Chroot"
echo "------------------------------"
echo

echo "Changing root to the new Arch system"
$wait
clear

arch-chroot /mnt
