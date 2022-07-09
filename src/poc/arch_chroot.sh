#!/bin/bash

# --------------------------------------------------
# Arch Linux chroot script
# by Marcell Barsony
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

read -p "Enter the amount of wait time in seconds: " waitseconds
wait="sleep ${waitseconds}"
$wait
clear

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

copycheck(){
	if [ "$?" -eq "0" ]
		then
			echo "Successful"
			$wait
		else
			echo "Unsuccessful - exit code $?"
			$wait
	fi
}

# --------------------------------------------------
# Root password
# --------------------------------------------------

echo "------------------------------"
echo "# Root password"
echo "------------------------------"
echo

passwd
clear

# --------------------------------------------------
# User creation
# --------------------------------------------------

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
echo

read -p "Enter your USERNAME: " USERNAME
echo
useradd -m ${USERNAME}

echo "Enter the password of ${USERNAME}"
passwd ${USERNAME}
$wait
clear

# --------------------------------------------------
# User group management
# --------------------------------------------------

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
echo

echo "Adding ${USERNAME} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${USERNAME}
echo
$wait

echo "Verifying group memebership"
id ${USERNAME}
echo
$wait
clear

# --------------------------------------------------
# Sudoers
# --------------------------------------------------

echo "------------------------------"
echo "# Sudoers"
echo "------------------------------"
echo

echo "Uncomment %wheel group"
echo
sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new

echo "Add insults"
echo
sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new
$wait
clear

# --------------------------------------------------
# Cloning git repo
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo

echo "Cloning dotfiles to /dotfiles directory"
echo
git clone https://github.com/marcellbarsony/dotfiles.git /dotfiles
$wait
clear

# --------------------------------------------------
# LVM support
# --------------------------------------------------

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
echo

pacman -S --noconfirm lvm2
$wait
clear

echo "------------------------------"
echo "# Mkinitcpio & Initramfs"
echo "------------------------------"
echo

echo "Copying mkinitcpio.conf"
cp /dotfiles/_system/mkinitcpio/mkinitcpio.conf /etc/mkinitcpio.conf
copycheck
$wait
echo

echo "Initramfs"
echo
mkinitcpio -p linux
$wait
clear

# --------------------------------------------------
# Network configuration
# --------------------------------------------------
# https://man.archlinux.org/man/machine-info.5
# /etc/machine-info

echo "------------------------------"
echo "# Hosts & Hostname"
echo "------------------------------"
echo

echo "Copying hosts"
cp /dotfiles/_system/hosts/hosts /etc/hosts
copycheck
echo

echo "Copying hostname"
cp /dotfiles/_system/hosts/hostname /etc/hostname
copycheck
echo

read -p "Enter hostname: " hostname
echo

echo "Setting hostname ${hostname}"
hostnamectl set-hostname ${hostname}
echo

echo "Checking hostname"
echo
hostnamectl
$wait
clear

echo "------------------------------"
echo "# Network tools"
echo "------------------------------"
echo

pacman -S --noconfirm networkmanager
# pacman -S wpa_supplicant
# pacman -S wireless_tools
# pacman -S netctl
# pacman -S dialog
$wait
clear

echo "Enabling Network manager"
echo
systemctl enable NetworkManager
copycheck
$wait
clear

echo "------------------------------"
echo "# Open SSH"
echo "------------------------------"
echo

pacman -S --noconfirm openssh
$wait
clear

echo "Enabling OpenSSH"
echo
systemctl enable sshd.service
copycheck
$wait
clear

# --------------------------------------------------
# Locale
# --------------------------------------------------

echo "------------------------------"
echo "# Locale"
echo "------------------------------"
echo

echo "Copying locale.gen"
cp /dotfiles/_system/locale/locale.gen /etc/locale.gen
copycheck
echo

echo "Copying locale.conf"
cp /dotfiles/_system/locale/locale.conf /etc/locale.conf
copycheck
echo

echo "Generating locale"
locale-gen
$wait
clear

# --------------------------------------------------
# GRUB boot loader
# --------------------------------------------------

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
echo

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
$wait
clear

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
echo

echo "Creating EFI directory for boot"
mkdir /boot/EFI
echo

echo "Mounting EFI partition"
mount /dev/nvme0n1p1 /boot/EFI
echo

echo "Installing grub on the MBR"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
echo

echo "Copying GRUB config snippet"
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
copycheck
echo

echo "Copying GRUB config"
cp /dotfiles/_system/grub/grub /etc/default/grub
copycheck
echo

echo "Creating a GRUB config file"
echo
grub-mkconfig -o /boot/grub/grub.cfg
$wait
clear

# --------------------------------------------------
# Exit chroot environment
# --------------------------------------------------

echo "------------------------------"
echo "# Exit chroot & reboot"
echo "------------------------------"
echo

$wait
reboot now
