#!/bin/bash

# Partitioning
sgdisk -o /dev/sda # Clear partition data
sgdisk -n 0:0:+1GiB -t 0:ef00 -c 0:efi         /dev/sda #EFI
sgdisk -n 0:0:0     -t 0:8e00 -c 0:cryptsystem /dev/sda #System

# Cryptsetup
echo ${passphrase} | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat /dev/sda2 --key-file=-
echo ${passphrase} | cryptsetup open --type luks2 /dev/sda2 cryptroot --key-file=-

# Root partition
mkfs.btrfs -L system /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

# Btrfs subvolume - create
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@snapshots
umount -R /mnt

# Btrfs subvolume - mount
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{efi,boot,home,var,.snapshots}
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# EFI partition
mkfs.fat -F32 /dev/sda1
mount /dev/sda1 /mnt/efi

# Fstab
mkdir /mnt/etc/
genfstab -U /mnt >> /mnt/etc/fstab

# Mirrorlist
reflector --latest 20 --protocol https --connection-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist

# Pacstrap
pacstrap -C ~/arch/cfg/pacman.conf /mnt linux linux-firmware linux-headers base base-devel git vim libnewt intel-ucode # with custom pacman.conf

# Chroot
arch-chroot /mnt

# Root passphrase
echo "root:${root_passphrase}" | chpasswd

# User management
useradd -m ${username}
echo "${username}:${user_passphrase}" | chpasswd
usermod -aG wheel,audio,video,optical,storage ${username}

# Hostname
hostnamectl set-hostname ${nodename}

# Locale
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen # Uncomment the line
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

# Sudoers
sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers > /etc/sudoers.new #Uncomment wheel group
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new

sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new # Add insults
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new

# Initramfs
sed -i "s/MODULES=()/MODULES=(btrfs)/g" /etc/mkinitcpio.conf # Add Btrfs module
sed -i "s/block filesystems/block encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf # Add encrypt
mkinitcpio -p linux

# GRUB packages
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

# GRUB passphrase
grubpass=$(echo -e "${grubpw}\n${grubpw}" | grub-mkpasswd-pbkdf2 | cut -d " " -f7 | tr -d '\n')
echo "cat << EOF" >> /etc/grub.d/00_header
echo "set superusers=\"${username}\"" >> /etc/grub.d/00_header
echo "password_pbkdf2 ${username} ${grubpass}" >> /etc/grub.d/00_header
echo "EOF" >> /etc/grub.d/00_header

# GRUB header
luksuuid=$( blkid | grep /dev/sda2 | cut -d\" -f 2 | sed -e 's/-//g' )
echo '#!/bin/sh' > /etc/grub.d/01_header
echo -n "echo " >> /etc/grub.d/01_header
echo -n `echo \"cryptomount -u ${luksuuid}\"` >> /etc/grub.d/01_header #Kinda hacky for the time being, yet produces the desired file content

# GRUB Btrfs config
sed -i '/#GRUB_BTRFS_GRUB_DIRNAME=/s/^#//g' /etc/default/grub-btrfs/config #Uncomment the line
sed -i 's/boot\/grub2/efi\/grub/g' /etc/default/grub-btrfs/config #Change directory: boot/grub2 >> efi/grub
systemctl enable --now grub-btrfs.path

# GRUB crypt
uuid=$( blkid | grep /dev/sda2 | cut -d\" -f 2 ) #Root disk UUID, not cryptroot UUID
sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3\ quiet\ cryptdevice=UUID=${uuid}:cryptroot:allow-discards\ root=/dev/mapper/cryptroot\ video=1920x1080\" /etc/default/grub
sed -i /GRUB_PRELOAD_MODULES=/c\GRUB_PRELOAD_MODULES=\"part_gpt\ part_msdos\ luks2\" /etc/default/grub # Add luks2 to the end of the line

# GRUB install
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi --boot-directory=/efi

# GRUB config
grub-mkconfig -o /efi/grub/grub.cfg
