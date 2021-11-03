#!/bin/bash

# --------------------------------------------------
# Arch Linux installation script
# WARNING: script is under development & hard-coded
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

fdisk /dev/nvme0n1

clear

# --------------------------------------------------
# Formatting disks I.
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting disks"
echo "------------------------------"
echo -ne $newline

echo "Formatting EFI: /dev/nvme0n1p1 (FAT32)"
mkfs.fat -F32 /dev/nvme0n1p1
$wait
echo -ne $newline

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
echo -ne $newline

echo "Creating LUKS container on LVM: /dev/nvme0n1p3"
cryptsetup luksFormat /dev/nvme0n1p3

    # LUKS container setup interactive menu

echo -ne $newline
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
echo -ne $newline

echo "Creating physical volume on the top of the opened LUKS container"
pvcreate /dev/mapper/cryptlvm
$wait
echo -ne $newline

echo "Creating volume gorup: volgroup0"
vgcreate volgroup0 /dev/mapper/cryptlvm
$wait
echo -ne $newline

echo "Creating ROOT filesystem: 30GBs - volgroup 0 - cryptroot"
lvcreate -L 30GB volgroup0 -n cryptroot
$wait
echo -ne $newline

echo "Creating HOME filesystem: 100%FREE - volgroup 0 - crypthome"
lvcreate -l 100%FREE volgroup0 -n crypthome
$wait
echo -ne $newline

echo "Activating volume groups (modprobe)"
modprobe dm_mod
$wait
echo -ne $newline

echo "Scanning available volume groups"
vgscan
$wait
echo -ne $newline

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
echo -ne $newline

echo "Formatting /ROOT (ext4 - /dev/volgroup0/cryptroot)"
mkfs.ext4 /dev/volgroup0/cryptroot
$wait
echo -ne $newline

echo "Mounting cryptroot >> /mnt"
mount /dev/volgroup0/cryptroot /mnt
$wait
clear

echo "------------------------------"
echo "# Formatting & Mounting /BOOT"
echo "------------------------------"
echo -ne $newline

echo "Creating mountpoint directory for /boot"
mkdir /mnt/boot
$wait
echo -ne $newline

echo "Mounting BOOT >> /mnt/boot"
mount /dev/nvme0n1p2 /mnt/boot
$wait
clear

echo "------------------------------"
echo "# Formatting & Mounting /HOME"
echo "------------------------------"
echo -ne $newline

echo "Formatting /HOME logical volume (ext4 - /dev/volgroup0/crypthome)"
mkfs.ext4 /dev/volgroup0/crypthome
$wait
echo -ne $newline

echo "Creating mount directory for /home"
mkdir /mnt/home
$wait
echo -ne $newline

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
echo -ne $newline

echo "Creating fstab directory: /mnt/etc"
mkdir /mnt/etc
$wait
echo -ne $newline

echo "Generating fstab config"
genfstab -U -p /mnt >> /mnt/etc/fstab
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
pacstrap /mnt base linux linux-firmware bash-completion linux-headers base-devel git nano vim
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
