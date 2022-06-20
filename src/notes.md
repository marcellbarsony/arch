# Notes

- [Minimal Arch install gist by ML](https://gist.github.com/mattiaslundberg/8620837)
- [PM Encrypted UEFI Arch install](https://gist.github.com/HardenedArray/31915e3d73a4ae45adc0efa9ba458b07)
- [VM Encrypted UEFI Arch install](https://gist.github.com/HardenedArray/d5b70681eca1d4e7cfb88df32cc4c7e6)

# Features TBA

## Base system

### Boot

[ ] [Secure boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
[ ] Encrypted `/boot` partition
[ ] [GRUB Passphrase](https://wiki.archlinux.org/title/GRUB/Tips_and_tricks#Password_protection_of_GRUB_menu)
[ ] GRUB Theme

### File system

[ ] Partition menu
[ ] [BTRFS](https://wiki.archlinux.org/title/btrfs)

### Libnewt

[ ] Libnewt theme

## Chroot

[ ] Locale - Additional options

## Post

[ ] Implement proper error handling
[ ] Suppress unnecessary command outputs
[ ] Wayland support

### AUR

[ ] AUR password dialog

### Bitwarden

[ ] [Bitwarden CLI](https://bitwarden.com/help/cli/) support

# Install sequence sketch

  ## User dialog

  1. Select EFI
  2. Select /boot [Optional]
  3. Select root (lvm)

  - Select filesystem (ext4/btfs)

  - ext4
    * Enter root (lvm) size (GB)
    * Enter crypt password
    * Enter crypt password confirm
    * Create crypt file

  - Btrfs

  ## Install sequence

  - ext4
    * cryptsetup luksFormat rootdevice
    * cryptsetup open rootdevice
    * pvcreate /dev/mapper/cryptlvm
    * vgcreate volgroup0 /dev/mapper/cryptlvm
    * lvcreate -L 30GB volgroup0 -n cryptroot
    * lvcreate -L 100%FREE volgroup0 -n crypthome
    * modprobe dm_mod
    * vgscan
    * vgchange -ay

  1. Format EFI
  2. Mount EFI

  1. Format /boot [Optional]
  2. Mount /boot [Optional]

  1. Format root (lvm)
  2. Mount root (lvm)

  - ext4
    * Format home
    * Mount home
