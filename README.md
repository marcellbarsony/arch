**Personal Arch Linux installation script**

For the documentation please refer to the [Wiki](https://github.com/marcellbarsony/arch/wiki "Wiki - Installation script").

## Objective

The main objective is to create an automated Arch Linux installation script with as less interactions as possible.

## Installation guide

### Base system

1.) Download the [Arch ISO](https://archlinux.org/download/)

2.) Verify the GPG signature

3.) Create a bootable media and boot the live environment

4.) Install Git
```
pacman -Sy git
```
5.) Clone this repository
```
git clone https://github.com/marcellbarsony/arch.git
```
6.) Change to arch directory
```
cd arch
```
7.) Launch the installation script
```
./main.sh
```

### Chroot environment

1.) Clone this repository
```
git clone https://github.com/marcellbarsony/arch.git
```
2.) Change to arch directoy
```
cd arch
```
2.) Launch the chroot script
```
sh arch_chroot.sh
```
### Post-installation

1.) Reboot the machine and detach the installation disk

2.) Log in as a normal user

3.) Change to arch directory
```
cd arch
```
4.) Launch the post script
```
sh arch_post.sh
```
