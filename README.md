**A personal Arch Linux installation script**

For the documentation please refer to the [Wiki](https://github.com/marcellbarsony/arch/wiki "Wiki - Installation script").

## Important note

This script is currently **under development** and it is **not production-ready**. It is recommended to not to use it in its current state.

Please note that this script is **hard-coded** for the time being.

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
5.) Change to arch directory
```
cd arch
```
6.) Launch the installation script
```
sh arch.sh
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
