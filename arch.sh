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

fdisk /dev/nvme0n1

clear

# --------------------------------------------------
# Formatting disks I.
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting disks"
echo "------------------------------"
echo

echo "Formatting EFI: /dev/nvme0n1p1 (FAT32)"
mkfs.fat -F32 /dev/nvme0n1p1
echo

echo "Formatting BOOT: /dev/nvme0n1p2 (ext4)"
mkfs.ext4 /dev/nvme0n1p2
$wait
clear

# --------------------------------------------------
# Encrypted container
# --------------------------------------------------

echo "------------------------------"
echo "# Encrypted container"
echo "------------------------------"
echo

echo "Creating LUKS container on LVM: /dev/nvme0n1p3"
cryptsetup luksFormat /dev/nvme0n1p3

    # LUKS container setup interactive menu

echo
echo "Unlocking the encrypted container (cryptlvm)"
cryptsetup open --type luks /dev/nvme0n1p3 cryptlvm

    # Enter encryption password

$wait
clear

# --------------------------------------------------
# Logical volumes (LVM)
# --------------------------------------------------

echo "------------------------------"
echo "# Logical volumes"
echo "------------------------------"
echo

echo "Creating physical volume on the top of the opened LUKS container"
pvcreate /dev/mapper/cryptlvm
echo

echo "Creating volume gorup: volgroup0"
vgcreate volgroup0 /dev/mapper/cryptlvm
echo

echo "Creating ROOT filesystem: 30GBs - volgroup 0 - cryptroot"
lvcreate -L 30GB volgroup0 -n cryptroot
echo

echo "Creating HOME filesystem: 100%FREE - volgroup 0 - crypthome"
lvcreate -l 100%FREE volgroup0 -n crypthome
echo

echo "Activating volume groups (modprobe)"
modprobe dm_mod
echo

echo "Scanning available volume groups"
vgscan
echo

echo "Activating volume groups"
vgchange -ay
$wait
clear

# --------------------------------------------------
# Formatting & Mounting LVM
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting & Mounting /ROOT"
echo "------------------------------"
echo

echo "Formatting /ROOT (ext4 - /dev/volgroup0/cryptroot)"
mkfs.ext4 /dev/volgroup0/cryptroot
echo

echo "Mounting cryptroot >> /mnt"
mount /dev/volgroup0/cryptroot /mnt
$wait
clear

echo "------------------------------"
echo "# Formatting & Mounting /BOOT"
echo "------------------------------"
echo

echo "Creating mountpoint directory for /boot"
mkdir /mnt/boot
echo

echo "Mounting BOOT >> /mnt/boot"
mount /dev/nvme0n1p2 /mnt/boot
$wait
clear

echo "------------------------------"
echo "# Formatting & Mounting /HOME"
echo "------------------------------"
echo

echo "Formatting /HOME logical volume (ext4 - /dev/volgroup0/crypthome)"
mkfs.ext4 /dev/volgroup0/crypthome
echo

echo "Creating mount directory for /home"
mkdir /mnt/home
echo

echo "Mounting crypthome >> /mnt/home"
mount /dev/volgroup0/crypthome /mnt/home
$wait
clear

# --------------------------------------------------
# fstab
# --------------------------------------------------

echo "------------------------------"
echo "# fstab"
echo "------------------------------"
echo

echo "Creating fstab directory: /mnt/etc"
mkdir /mnt/etc
echo

echo "Generating fstab config"
genfstab -U -p /mnt >> /mnt/etc/fstab
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
pacstrap /mnt base linux linux-firmware linux-headers base-devel git nano vim
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
