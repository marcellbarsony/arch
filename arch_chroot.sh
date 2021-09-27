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
echo -p "Enter the amount of sleep in seconds: " sleep
clear

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

copycheck () {}
	if [ "$?" -eq "0" ]
		then
			echo "Copying process successful"
		else
			echo "Copying process successful - exit code $?"
	fi
}

# --------------------------------------------------
# Cloning git repo
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
$sleep
echo -ne $newline
git clone https://github.com/marcellbarsony/linux.git
$sleep
clear

# --------------------------------------------------
# LVM support
# --------------------------------------------------

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Installing lvm2"
$sleep
echo -ne $newline

pacman -S lvm2
$sleep
clear

echo "------------------------------"
echo "# Mkinitcpio & Initramfs"
echo "------------------------------"
echo -ne $newline

echo "Copying mkinitcpio.conf"
echo -ne $newline
$sleep
cp /linux/cfg/mkinitcpio.conf /etc/mkinitcpio.conf
copycheck
$sleep
echo -ne $newline

echo "Initramfs"
mkinitcpio -p linux
$sleep
clear

# --------------------------------------------------
# Network configuration
# --------------------------------------------------

echo "------------------------------"
echo "# Hosts & Hostname"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Copying hosts file"
cp /linux/cfg/hosts /etc/hosts
if [ "$?" -eq "0" ]
	then
	    echo "Copying hosts file - Successful"
	else
	    echo "Copying hosts file - Unsuccessful: exit code $?"
fi
$sleep
echo -ne $newline

echo "Setting hostname (arch)"
hostnamectl set-hostname arch
$sleep
echo -ne $newline

echo "Checking hostname"
echo -ne $newline
hostnamectl
$sleep
clear

echo "------------------------------"
echo "# Network tools"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Network tools"
$sleep
echo -ne $newline
pacman -S networkmanager
# pacman -S wpa_supplicant
# pacman -S wireless_tools
# pacman -S netctl
# pacman -S dialog
$sleep
clear

echo "Enabling Network manager"
echo -ne $newline
$sleep
systemctl enable NetworkManager
if [ "$?" -eq "0" ]
	then
	    echo "Network manager has been enabled"
	else
	    echo "Failed to enable Network manager: exit code $?"
fi
$sleep
clear

# --------------------------------------------------
# Locale
# --------------------------------------------------

echo "------------------------------"
echo "# Locale"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Copying locale.gen"
echo -ne $newline
cp /linux/cfg/locale.gen /etc/locale.gen
copycheck
$sleep
echo -ne $newline

echo "Copying locale.conf"
echo -ne $newline
cp /linux/cfg/locale.conf /etc/locale.conf
copycheck
$sleep
echo -ne $newline

echo "Generating locale"
echo -ne $newline
locale-gen
$sleep
clear

# --------------------------------------------------
# Boot loader
# --------------------------------------------------

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
$sleep
echo -ne $newline

pacman -S grub efibootmgr dosfstools os-prober mtools
$sleep
clear

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Creating EFI directory for boot"
mkdir /boot/EFI
$sleep
echo -ne $newline

echo "Mounting EFI partition"
mount /dev/nvme0n1p1 /boot/EFI
$sleep
echo -ne $newline

echo "Installing grub on the MBR"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
$sleep
echo -ne $newline

echo "Copying GRUB config snippet"
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
$sleep
echo -ne $newline

echo "Copying GRUB config"
cp /linux/cfg/grub /etc/default/grub
copycheck
$sleep
echo -ne $newline

echo "Creating a GRUB config file"
echo -ne $newline
grub-mkconfig -o /boot/grub/grub.cfg
$sleep
clear

# --------------------------------------------------
# Root password
# --------------------------------------------------

echo "------------------------------"
echo "# Root password"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Set root password"
$sleep
echo -ne $newline
passwd
clear

# --------------------------------------------------
# Exit chroot environment
# --------------------------------------------------

echo "------------------------------"
echo "# Exit chroot environment"
echo "------------------------------"
$sleep
echo -ne $newline

exit

# --------------------------------------------------
# Umount & Reboot
# --------------------------------------------------

echo "------------------------------"
echo "# Umount & Reboot"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Umount partitions"
umount -l /mnt
$sleep

echo "Reboot in 5..."
sleep 1
echo "Reboot in 4..."
sleep 1
echo "Reboot in 3..."
sleep 1
echo "Reboot in 2..."
sleep 1
echo "Reboot in 1..."
sleep 1

reboot
