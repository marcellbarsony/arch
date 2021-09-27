#!/bin/zsh

# --------------------------------------------------
# Arch Linux post script
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
# User creation
# --------------------------------------------------

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
$sleep
echo -ne $newline

read -p "Enter your username: " username
echo "Add new user ${username}"
useradd -m ${username}
$sleep
echo -ne $newline

echo "Enter the password of ${username}"
passwd ${username}
$sleep
clear

# --------------------------------------------------
# User group management
# --------------------------------------------------

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Adding ${username} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${username}
$sleep
echo -ne $newline

echo "Verifying group memebership"
id ${username}
$sleep
echo -ne $newline

echo "Visudo: Allowing standard users to run commands as root"
echo -ne $newline
$sleep
cp /linux/cfg/sudoers.tmp /etc/sudoers.tmp
copycheck
$sleep
echo -ne $newline

# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Window manager: DWM"
$sleep
echo -ne $newline
pacman -S dwm
clear

echo "dmenu"
$sleep
echo -ne $newline
pacman -S dmenu
clear

echo "Display server: Xorg-xinit"
$sleep
echo -ne $newline
pacman -S xorg-xinit
clear

echo "Display server: Xorg"
$sleep
echo -ne $newline
pacman -S xorg
clear

echo "Terminal emulator: st"
$sleep
echo -ne $newline
pacman -S st
clear

echo "Browser"
$sleep
echo -ne $newline
pacman -S firefox
clear

#echo "Sound tools: Alsa, Pulse, Sof"
#sleep 3
#echo -ne $newline
# Pulseaudio
	# pacman -S pulseaudio pulseaudio-alsa pavucontrol sof-firmware
# ALSA
	# pacman -S alsa alsa-utils alsa-firmware alsa-ucm-conf alsamixer
#clear

echo "Intel firmware"
$sleep
echo -ne $newline
pacman -S intel-ucode xf86-video-intel mesa
clear

echo "Additional tools"
$sleep
echo -ne $newline
pacman -S htop neofetch
clear

# --------------------------------------------------
# Xorg - xinit
# --------------------------------------------------

echo "------------------------------"
echo "# Xorg - xinit"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Copying xinitrc"
cp /etc/X11/xinit/xinitrc /home/marci/.xinitrc
if [ "$?" -eq "0" ]
	then
	    echo "Copying xinitrc - Successful"
	else
	    echo "Copying xinitrc - Unsuccessful: exit code $?"
fi
$sleep
echo -ne $newline

# --------------------------------------------------
# End of script
# --------------------------------------------------

echo "------------------------------"
echo "# End of script"
echo "------------------------------"
$sleep
echo -ne $newline

echo "Don't forget to edit the ~/.xinitrc file."
$sleep
echo "This is the end of the installation"
$sleep
echo "You can now reboot the system, login as a normal user and start the X server"
$sleep
