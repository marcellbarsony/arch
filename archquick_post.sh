#!/bin/zsh

# User creation

echo "# User creation\n"

echo "Adding new user (marci)"
useradd -m marci

echo "Enter the password (marci)"
sleep 1
passwd marci

sleep 1
clear

# User group management

echo "# User group management\n"

sleep 1

echo "Adding <marci> to basic groups"
usermod -aG wheel,audio,video,optical,storage marci

echo "Verifying group memebership"
id marci

sleep 5
clear

# Visudo

echo "# Visudo\n"

sleep 1

echo "Adding <marci> to visudo"
sleep 3
EDITOR=nano visudo