#!/bin/zsh

# --------------------------------------------------
# Cloning git repo
# --------------------------------------------------

echo "# Fetching configs"
sleep 5
echo -ne $newline
git clone https://github.com/marcellbarsony/linux.git
sleep 5
clear

# --------------------------------------------------
# LVM support
# --------------------------------------------------

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Installing lvm2"
sleep 5
echo -ne $newline

pacman -S lvm2
sleep 5
clear

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
echo -ne $newline

echo "Copying mkinitcpio.conf"
cp /linux/cfg/mkinitcpio.conf /etc/mkinitcpio.conf
sleep 5
echo -ne $newline

echo "Initramfs"
mkinitcpio -p linux
sleep 5
clear

# --------------------------------------------------
# Network configuration
# --------------------------------------------------

echo "------------------------------"
echo "# Enable LVM support"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Copying hosts file"
cp /linux/cfg/hosts /etc/hosts
sleep 5
echo -ne $newline

echo "Setting host name: arch"
hostnamectl set-hostname arch
sleep 5
echo -ne $newline

echo "Checking hostname"
hostnamectl set-hostname arch
sleep 5
clear

# --------------------------------------------------
# Locale
# --------------------------------------------------

echo "------------------------------"
echo "# Locale"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Copying locale.gen"
cp /linux/cfg/locale.gen /etc/locale.gen
sleep 5
echo -ne $newline

echo "Copying locale.conf"
cp /linux/cfg/locale.conf /etc/locale.conf
sleep 5
echo -ne $newline

echo "Generating locale"
locale-gen
sleep 5
clear

# --------------------------------------------------
# Boot loader
# --------------------------------------------------

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
echo -ne $newline
pacman -S grub efibootmgr dosfstools os-prober mtools
sleep 5
clear

echo "------------------------------"
echo "# Install GRUB and other tools"
echo "------------------------------"
echo -ne $newline

echo "Creating EFI directory for boot"
mkdir /boot/EFI
sleep 5
echo -ne $newline

echo "Mounting EFI partition"
mount /dev/nvme0n1p1 /boot/EFI
sleep 5
echo -ne $newline

echo "Installing grub on the MBR"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sleep 5
echo -ne $newline

echo "Copying GRUB config snippet"
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
sleep 5
echo -ne $newline

echo "Copying GRUB config"
cp /linux/cfg/grub /etc/default/grub
sleep 5
echo -ne $newline

echo "Creating a GRUB config file"
echo -ne $newline
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5
clear

# --------------------------------------------------
# Root password
# --------------------------------------------------

echo "------------------------------"
echo "# Root password"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Set root password"
sleep 5
echo -ne $newline
passwd
clear

# --------------------------------------------------
# Exit chroot environment
# --------------------------------------------------

echo "------------------------------"
echo "# Exit chroot environment"
echo "------------------------------"
sleep 5
echo -ne $newline

exit
sleep 3
clear

# --------------------------------------------------
# Umount & Reboot
# --------------------------------------------------

echo "------------------------------"
echo "# Umount & Reboot"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Umount partitions"
umount -l /mnt
sleep 5

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