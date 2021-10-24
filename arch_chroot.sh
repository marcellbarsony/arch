#!/binbash

# --------------------------------------------------
# Arch Linux chroot script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
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
			echo "Successful"
			$wait
		else
			echo "Unsuccessful - exit code $?"
			$wait
	fi
}

# --------------------------------------------------
# Cloning git repo
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "Cloning dotfiles to /dotfiles directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/dotfiles.git /dotfiles
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

pacman -S --noconfirm lvm2
$wait
clear

echo "------------------------------"
echo "# Mkinitcpio & Initramfs"
echo "------------------------------"
echo -ne $newline

echo "Copying mkinitcpio.conf"
$wait
cp /dotfiles/mkinitcpio/mkinitcpio.conf /etc/mkinitcpio.conf
copycheck
$wait
echo -ne $newline

echo "Initramfs"
echo -ne $newline
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
echo -ne $newline

echo "Copying hosts"
cp /dotfiles/hosts/hosts /etc/hosts
copycheck
$wait

echo "Copying hostname"
cp /dotfiles/hosts/hostname /etc/hostname
copycheck
$wait

read -p "Enter hostname: " hostname
$wait
echo -ne $newline

echo "Setting hostname ${hostname}"
echo -ne $newline
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
pacman -S --noconfirm networkmanager
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
copycheck
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
cp /dotfiles/locale/locale.gen /etc/locale.gen
copycheck
echo -ne $newline

echo "Copying locale.conf"
cp /dotfiles/locale/locale.conf /etc/locale.conf
copycheck
echo -ne $newline

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
echo -ne $newline

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
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
copycheck
$wait
echo -ne $newline

echo "Copying GRUB config"
cp /dotfiles/grub/grub /etc/default/grub
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

passwd
clear

# --------------------------------------------------
# User creation
# --------------------------------------------------

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
echo -ne $newline

read -p "Enter your username: " username
echo -ne $newline
useradd -m ${username}
echo -ne $newline

echo "Enter the password of ${username}"
passwd ${username}
$wait
clear

# --------------------------------------------------
# User group management
# --------------------------------------------------

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
echo -ne $newline

echo "Adding ${username} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${username}
echo -ne $newline
$wait

echo "Verifying group memebership"
id ${username}
echo -ne $newline
$wait
clear

# --------------------------------------------------
# Sudoers
# --------------------------------------------------

echo "------------------------------"
echo "# Sudoers"
echo "------------------------------"
echo -ne $newline

echo "Uncomment %wheel group"
echo -ne $newline
sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new
$wait

echo "Add insults"
echo -ne $newline
sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new
$wait
clear

# --------------------------------------------------
# Exit chroot environment
# --------------------------------------------------

echo "------------------------------"
echo "# Exit chroot & reboot"
echo "------------------------------"
echo -ne $newline

$wait
reboot now

# echo "------------------------------"
# echo "# Umount & Reboot"
# echo "------------------------------"
# $wait
# echo -ne $newline

# echo "Umount partitions"
# umount -l /mnt
# $wait

# reboot now
