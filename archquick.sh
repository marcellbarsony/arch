#!/bin/zsh

clear

# --------------------------------------------------
# Variables
# --------------------------------------------------

newline="\n"

# --------------------------------------------------
# Formatting disks I.
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting disks"
echo "------------------------------"
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

# --------------------------------------------------
# Encrypted container
# --------------------------------------------------

echo "------------------------------"
echo "# Encrypted container"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Creating LUKS container on P3: /dev/nvme0n1p3"
cryptsetup luksFormat /dev/nvme0n1p3

    # LUKS container setup interactive menu

echo -ne $newline
echo "Unlocking the encrypted container (cryptlvm)"
cryptsetup open --type luks /dev/nvme0n1p3 cryptlvm

    # Enter encryption password

sleep 5
clear

# --------------------------------------------------
# Logical volumes (LVM)
# --------------------------------------------------

echo "------------------------------"
echo "# Logical volumes"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Creating physical volume on the top of the opened LUKS container"
pvcreate /dev/mapper/cryptlvm
sleep 5
echo -ne $newline

echo "Creating volume gorup: volgroup0"
vgcreate volgroup0 /dev/mapper/cryptlvm
sleep 5
echo -ne $newline

echo "Creating ROOT filesystem: 30GBs - volgroup 0 - cryptroot"
lvcreate -L 30GB volgroup0 -n cryptroot
sleep 5
echo -ne $newline

echo "Creating HOME filesystem: 100%FREE - volgroup 0 - crypthome"
lvcreate -l 100%FREE volgroup0 -n crypthome
echo -ne $newline

echo "Activating volume groups (modprobe)"
modprobe dm_mod
sleep 5
echo -ne $newline

echo "Scanning available volume groups"
vgscan
sleep 5
echo -ne $newline

echo "Activating volume groups"
vgchange -ay
sleep 5
clear

# --------------------------------------------------
# Formatting & Mounting LVM
# --------------------------------------------------

echo "------------------------------"
echo "# Formatting & Mounting /ROOT"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Formatting /ROOT (ext4 - /dev/volgroup0/cryptroot)"
mkfs.ext4 /dev/volgroup0/cryptroot
sleep 5
echo -ne $newline

echo "Mounting cryptroot >> /mnt"
mount /dev/volgroup0/cryptroot /mnt
sleep 5
clear

echo "------------------------------"
echo "# Formatting & Mounting /BOOT"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Creating mountpoint directory for /boot"
mkdir /mnt/boot
sleep 5
echo -ne $newline

echo "Mounting EFI partition >> /mnt/boot"
mount /dev/nvme0n1p2 /mnt/boot
sleep 5
clear

echo "------------------------------"
echo "# Formatting & Mounting /HOME"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Formatting /HOME logical volume (ext4 - /dev/volgroup0/crypthome)"
mkfs.ext4 /dev/volgroup0/crypthome
sleep 5

echo "Creating mount directory for /home"
mkdir /mnt/home
sleep 5
echo -ne $newline

echo "Mounting crypthome >> /mnt/home"
mount /dev/volgroup0/crypthome /mnt/home
sleep 5
clear

# --------------------------------------------------
# fstab
# --------------------------------------------------

echo "------------------------------"
echo "# fstab"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Creating fstab directory: /mnt/etc"
mkdir /mnt/etc
sleep 5
echo -ne $newline

echo "Generating fstab config"
genfstab -U -p /mnt >> /mnt/etc/fstab
sleep 5
echo -ne $newline

echo "Checking fstab"
cat /mnt/etc/fstab
sleep 5
clear

# --------------------------------------------------
# Kernel
# --------------------------------------------------

echo "------------------------------"
echo "# Kernel"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Installing essential packages"
pacstrap -i /mnt base linux linux-firmware bash-completion linux-headers base-devel git nano
sleep 5
clear


# --------------------------------------------------
# Chroot
# --------------------------------------------------

echo "------------------------------"
echo "# Chroot"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Changing root to the new Arch system"
sleep 5
arch-chroot /mnt