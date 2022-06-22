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

| Partition      | Partition Name | Partition Size | Filesystem type    |
| -------------- | -------------- | -------------- | ------------------ |
| Partition 1    | EFI System     | (min. 512MB)   | [EFI System]       |
| Partition 2    | Root           |                | [Linux Filesystem] |
| Root subvolume | @              |                |                    |
| Root subvolume | @/home         |                |                    |
| Root subvolume | @/var          |                |                    |

### Encrypted ext4

| Partition No.  | Partition Name | Partition Size | Filesystem type  |
| -------------- | -------------- | -------------- | ---------------- |
| Partition 1    | EFI System     | (min. 512MB)   | [EFI System]     |
| Partition 2    | Root           |                | [Linux LVM]      |
| Root subvolume | cryptroot      |                |                  |
| Root subvolume | crypthome      |                |                  |

### Plain Btrfs

| Partition No.  | Partition Name | Partition Size | Filesystem type    |
| -------------- | -------------- | -------------- | ------------------ |
| Partition 1    | EFI System     | (min. 512MB)   | [EFI System]       |
| Partition 2    | Root           |                | [Linux Filesystem] |
| Root subvolume | @              |                |                    |
| Root subvolume | @/home         |                |                    |
| Root subvolume | @/var          |                |                    |

### Plain ext4

| Partition No. | Partition Name | Partition Size | Filesystem type  |
| ------------- | -------------- | -------------- | ---------------- |
| Partition 1   | EFI System     | (min. 512MB)   | [EFI System]     |
| Partition 2   | Root           |                | [Linux LVM]      |
