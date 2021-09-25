#!/bin/zsh

clear

# Variables

newline="\n"

# Formatting disks I.

echo "# Formatting disks I."
sleep 5
echo -ne $newline

echo "Formatting P1: /dev/nvme0n1p1 (FAT32)"
mkfs.fat -F32 /dev/nvme0n1p1
sleep 5
echo -ne $newline

echo "Formatting P2: /dev/nvme0n1p2 (ext4)"
mkfs.ext4 /dev/nvme0n1p2
sleep 5
clear

# Encrypted container

echo "# Encrypted container"
sleep 5
echo -ne $newline

echo "Creating LUKS container on P3: /dev/nvme0n1p3"
cryptsetup luksFormat /dev/nvme0n1p3
    # Enter encryption password

echo -ne $newline
echo "Unlocking the encrypted container (cryptlvm)"
cryptsetup open --type luks /dev/nvme0n1p3 cryptlvm
    # Enter encryption password
sleep 5
clear

# Logical volumes

echo "# Logical volumes"
sleep 5
echo -ne $newline

echo "Creating physical volume on the top of the opened LUKS container"

pvcreate /dev/mapper/cryptlvm
sleep 5
echo -ne $newline

echo "Creating root filesystem: 30GBs - volgroup 0 - cryptroot"

lvcreate -L 30GB volgroup0 -n cryptroot
sleep 5
echo -ne $newline

echo "Creating Home filesystem: 100%FREE - volgroup 0 - crypthome"
lvcreate -l 100%FREE volgroup0 -n crypthome
echo -ne $newline

echo "Activating volume groups (modrprobe dm_mod)"
modprobe dm_mod
sleep 5
echo -ne $newline

echo "Scanning for available volume groups"
vgscan
sleep 5
echo -ne $newline


echo "Activating volume groups"
vgchange -ay
sleep 5
clear

# Formatting disks II.

echo "# Formatting disks II."
sleep 5
echo -ne $newline


echo "Formatting /ROOT"
sleep 5
echo -ne $newline

echo "Formatting ROOT file system logical volume (ext4 - /dev/volgroup0/cryptroot)"
mkfs.ext4 /dev/volgroup0/cryptroot
sleep 5
echo -ne $newline

echo "Mounting cryptroot to /mnt"
mount /dev/volgroup0/cryptroot /mnt
sleep 5
echo -ne $newline

echo "Formatting /BOOT"
sleep 5
echo -ne $newline

echo "Creating directory"
mkdir /mnt/boot
sleep 5
echo -ne $newline

echo "Mounting EFI partition"
mount /dev/nvme0n1p2 /mnt/boot
sleep 5
echo -ne $newline

echo "formatting /HOME"
mkfs.ext4 /dev/volgroup0/crypthome
sleep 5
echo -ne $newline

echo "Creating mount directory for /home"
mkdir /mnt/home
sleep 5
echo -ne $newline

echo "Mounting /home"
mount /dev/volgroup0/crypthome /mnt/home
sleep 5
clear

# fstab

echo "# fstab"
sleep 5
echo -ne $newline

echo "Creating fstab directory: /mnt/etc"
mkdir /mnt/etc
echo -ne $newline

echo "Generating fstab config"
genfstab -U -p /mnt >> /mnt/etc/fstab
echo -ne $newline

echo "Checking fstab"
cat /mnt/etc/fstab
sleep 5
clear

# Kernel

echo "# Kernel"
sleep 5
echo -ne $newline

echo "Installing essential packages"
pacstrap -i /mnt base linux linux-firmware bash-completion linux-headers base-devel
sleep 5
clear

# Chroot

echo "# Chroot"
sleep 5
echo -ne $newline

echo "Changing root to the new Arch system"
sleep 5
arch-chroot /mnt