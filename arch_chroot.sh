#!/bin/zsh

# --------------------------------------------------
# Arch Linux chroot script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
# Last major update: 9/27/2021
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

newline="\n"
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
			echo "Copying process successful"
			$wait
		else
			echo "Copying unsuccessful - exit code $?"
			$wait
	fi
}

# --------------------------------------------------
# Cloning git repo
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
$wait
echo -ne $newline
git clone https://github.com/marcellbarsony/linux.git
$wait
clear

# --------------------------------------------------
# LVM support
# --------------------------------------------------

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
echo -ne $newline

echo "Installing lvm2"
$wait
echo -ne $newline

pacman -S lvm2
$wait
clear

echo "------------------------------"
echo "# Mkinitcpio & Initramfs"
echo "------------------------------"
echo -ne $newline

echo "Copying mkinitcpio.conf"
echo -ne $newline
$wait
cp /linux/cfg/mkinitcpio.conf /etc/mkinitcpio.conf
copycheck
$wait
echo -ne $newline

echo "Initramfs"
mkinitcpio -p linux
$wait
clear

# --------------------------------------------------
# Network configuration
# --------------------------------------------------

echo "------------------------------"
echo "# Hosts & Hostname"
echo "------------------------------"
echo -ne $newline

echo "Copying hosts file"
cp /linux/cfg/hosts /etc/hosts
if [ "$?" -eq "0" ]
	then
	    echo "Copying hosts file - Successful"
	else
	    echo "Copying hosts file - Unsuccessful: exit code $?"
fi
$wait
echo -ne $newline

read -p "Enter hostname: " hostname
$wait
echo -ne $newline

echo "Setting hostname ${hostname}"
hostnamectl set-hostname ${hostname}
$wait
echo -ne $newline

echo "Checking hostname"
echo -ne $newline
hostnamectl
$wait
clear

echo "------------------------------"
echo "# Network tools"
echo "------------------------------"
echo -ne $newline

echo "Network tools"
$wait
echo -ne $newline
pacman -S networkmanager
# pacman -S wpa_supplicant
# pacman -S wireless_tools
# pacman -S netctl
# pacman -S dialog
$wait
clear

echo "Enabling Network manager"
echo -ne $newline
$wait
systemctl enable NetworkManager
if [ "$?" -eq "0" ]
	then
	    echo "Network manager has been enabled"
	else
	    echo "Failed to enable Network manager: exit code $?"
fi
$wait
clear

# --------------------------------------------------
# Locale
# --------------------------------------------------

echo "------------------------------"
echo "# Locale"
echo "------------------------------"
echo -ne $newline

echo "Copying locale.gen"
$wait
echo -ne $newline
cp /linux/cfg/locale.gen /etc/locale.gen
copycheck
echo -ne $newline

echo "Copying locale.conf"
echo -ne $newline
cp /linux/cfg/locale.conf /etc/locale.conf
copycheck
echo -ne $newline

echo "Generating locale"
echo -ne $newline
locale-gen
$wait
clear

# --------------------------------------------------
# Boot loader
# --------------------------------------------------

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
$wait
echo -ne $newline

pacman -S grub efibootmgr dosfstools os-prober mtools
$wait
clear

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
echo -ne $newline

echo "Creating EFI directory for boot"
mkdir /boot/EFI
$wait
echo -ne $newline

echo "Mounting EFI partition"
mount /dev/nvme0n1p1 /boot/EFI
$wait
echo -ne $newline

echo "Installing grub on the MBR"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
$wait
echo -ne $newline

echo "Copying GRUB config snippet"
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
$wait
echo -ne $newline

echo "Copying GRUB config"
cp /linux/cfg/grub /etc/default/grub
copycheck
$wait
echo -ne $newline

echo "Creating a GRUB config file"
echo -ne $newline
grub-mkconfig -o /boot/grub/grub.cfg
$wait
clear

# --------------------------------------------------
# Root password
# --------------------------------------------------

echo "------------------------------"
echo "# Root password"
echo "------------------------------"
echo -ne $newline

echo "Set root password"
$wait
echo -ne $newline
passwd
clear

# --------------------------------------------------
# Exit chroot environment
# --------------------------------------------------

echo "------------------------------"
echo "# Exit chroot environment"
echo "------------------------------"
$wait
echo -ne $newline

exit

# --------------------------------------------------
# Umount & Reboot
# --------------------------------------------------

# echo "------------------------------"
# echo "# Umount & Reboot"
# echo "------------------------------"
# $wait
# echo -ne $newline

# echo "Umount partitions"
# umount -l /mnt
# $wait

# echo "Reboot in 5..."
# wait
# echo "Reboot in 4..."
# wait
# echo "Reboot in 3..."
# wait
# echo "Reboot in 2..."
# wait
# echo "Reboot in 1..."
# wait

# reboot
