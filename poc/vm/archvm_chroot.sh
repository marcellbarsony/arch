#!/binbash

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

echo "------------------------------"
echo "# Root password"
echo "------------------------------"
echo

passwd
clear

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
echo

read -p "Enter your username: " username
useradd -m ${username}
HOME=/home/$username
echo

echo "Enter the password of ${username}"
passwd ${username}
$wait
clear

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
echo

echo "Adding ${username} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${username}
echo
$wait

echo "Verifying group memebership"
id ${username}
echo
$wait
clear

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

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo

git clone https://github.com/marcellbarsony/dotfiles.git $HOME/.config
cd /home/$username
chown -R marci:marci .config
$wait
clear

echo "Initramfs"
echo
mkinitcpio -p linux
$wait
clear

echo "------------------------------"
echo "# Hosts & Hostname"
echo "------------------------------"
echo
# https://man.archlinux.org/man/machine-info.5
# /etc/machine-info

echo "Copying hosts"
cp $HOME/.config/_system/hosts/hosts /etc/hosts
copycheck
echo

echo "Copying hostname"
cp $HOME/.config/_system/hosts/hostname /etc/hostname
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

echo "Network tools"
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

echo "------------------------------"
echo "# VirtualBox kernel modules"
echo "------------------------------"
echo

echo "Enable vboxservice.service"
systemctl enable vboxservice.service
$copycheck
$wait

echo "Modproble vboxguest vboxsf vboxvideo"
modprobe -a vboxguest vboxsf vboxvideo
$copycheck
$wait

echo "------------------------------"
echo "# Locale"
echo "------------------------------"
echo

echo "Copying locale.gen"
cp $HOME/.config/_system/locale/locale.gen /etc/locale.gen
copycheck
echo

echo "Copying locale.conf"
cp $HOME/.config/_system/locale/locale.conf /etc/locale.conf
copycheck
echo

echo "Generating locale"
locale-gen
$wait
clear

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

echo "Mounting /dev/sda1 >> /boot/EFI"
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
copycheck
echo

echo "Installing grub to x86_64-efi"
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
copycheck
echo

echo "Creating a GRUB config file"
echo
grub-mkconfig -o /boot/grub/grub.cfg
$wait
clear

echo "------------------------------"
echo "# Exit chroot & reboot"
echo "------------------------------"
echo

$wait
reboot now

# echo "------------------------------"
# echo "# Umount & Reboot"
# echo "------------------------------"
# $wait
# echo

# echo "Umount partitions"
# umount -l /mnt
# $wait

# reboot now
