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

## File system

### Encrypted Btrfs

| Partition      | Partition Name | Partition Size | Filesystem type    | Mount point     |
| -------------- | -------------- | -------------- | ------------------ | --------------- |
| Partition 1    | EFI System     | 512MiB         | ef00               | /mnt/boot/      |
| Partition 2    | Root           |                | 8300               |                 |
| Root subvolume | @              |                |                    | /mnt            |
| Root subvolume | @/home         |                |                    | /mnt/home       |
| Root subvolume | @/var          |                |                    | /mnt/var        |
| Root subvolume | @/.snapshots   |                |                    | /mnt/.snapshots |

### Encrypted ext4

| Partition No.  | Partition Name | Partition Size | Filesystem type  | Mount point    |
| -------------- | -------------- | -------------- | ---------------- | -------------- |
| Partition 1    | EFI System     | 512MiB         | ef00             | /mnt/boot      |
| Partition 2    | Root           |                | 8e00             |                |
| Root subvolume | cryptroot      |                |                  | /mnt           |
| Root subvolume | crypthome      |                |                  | /mnt/home      |
