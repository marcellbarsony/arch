# archquick
Simple Arch Linux install script

## Important note

This script is **under development** and it is **not production-ready**. It is recommended to not to use it in its current state.

Please note that this script is **hard-coded** for the time being.

## Installation guide

### Base system

1.) Create a bootable Arch Linux media

2.) Boot into the live environment

3.) Format the disk

4.) Install git   

`pacman -Sy git`

5.) Clone this repository

`git clone https://github.com/marcellbarsony/archquick.git`

6.) Change directory to the arch folder

`cd archquick`

7.) Launch the installation script

`bash archquick.sh`

### Chroot environment

1.) Clone this repository

`git clone https://github.com/marcellbarsony/archquick.git`

2.) Change directory to the arch folder

`cd archquick`

3.) Launch the chroot script

`bash archquick_chroot.sh`

### Post-installation

1.) Reboot the machine and detach the installation disk

2.) Log in the system as root

3.) Launch the post-installation script to finish the installation

`bash archquick_post.sh`
