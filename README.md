**Arch Linux installation script**

For the documentation please refer to the [Wiki](https://github.com/marcellbarsony/arch/wiki "Wiki - Installation script").

## Objective

The main objective is to create an automated Arch Linux installation script with as few interactions as possible.

## Installation guide

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
