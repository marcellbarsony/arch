**A personal Arch Linux installation script**

For the documentation please refer to the [Wiki](https://github.com/marcellbarsony/linux/wiki "Wiki - Installation script").

## Important note

This script is currently **under development** and it is **not production-ready**. It is recommended to not to use it in its current state.

Please note that this script is **hard-coded** for the time being.

## Philosophy

This automated installation sequence follows the [Arch Installation guide](https://wiki.archlinux.org/title/installation_guide) and the [Arch Principles](https://wiki.archlinux.org/title/Arch_Linux#Principles). 

Designed to ship a minimal, lightweight, privacy and security-focused Arch system.

## Installation guide

### Base system

1.) Download the [Arch ISO](https://archlinux.org/download/) and create a bootable media

2.) Verify the signature and boot the live environment

3.) Install Git   
```
pacman -Sy git
```
4.) Clone this repository
```
git clone https://github.com/marcellbarsony/arch.git
```
5.) Launch the installation script
```
bash arch.sh
```

### Chroot environment

1.) Clone this repository
```
git clone https://github.com/marcellbarsony/arch.git
```
2.) Launch the chroot script
```
bash arch_chroot.sh
```
### Post-installation

1.) Reboot the machine and detach the installation disk

2.) Log in as a normal user

3.) Launch the post-installation script
```
bash arch_post.sh
```

## Features

- UEFI
- GRUB
- Systemd
- LVM on LUKS
- Xorg
- Network Manager
- Vim & Neovim
- TBA: _Hardened kernel_
