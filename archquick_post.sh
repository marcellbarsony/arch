#!/bin/zsh

# Variables

newline="\n"

# User creation

echo "# User creation"
sleep 5
echo -ne $newline


echo "Adding new user (marci)"
useradd -m marci
sleep 5
echo -ne $newline

echo "Enter the password (marci)"
passwd marci
sleep 5

sleep 5
clear

# User group management

echo "# User group management"
sleep 5
echo -ne $newline

echo "Adding <marci> to basic groups"
usermod -aG wheel,audio,video,optical,storage marci
sleep 5
echo -ne $newline

echo "Verifying group memebership"
id marci

sleep 5
clear

# Visudo

echo "# Visudo\n"
sleep 5
echo -ne $newline

echo "Adding <marci> to visudo"
sleep 5
EDITOR=nano visudo