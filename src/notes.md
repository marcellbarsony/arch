# Notes

- [Minimal Arch install gist by ML](https://gist.github.com/mattiaslundberg/8620837)
- [PM Encrypted UEFI Arch install](https://gist.github.com/HardenedArray/31915e3d73a4ae45adc0efa9ba458b07)
- [VM Encrypted UEFI Arch install](https://gist.github.com/HardenedArray/d5b70681eca1d4e7cfb88df32cc4c7e6)

# Features TBA

## Base system

### Boot

[ ] [Secure boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
[ ] Encrypted `/boot` partition
[x] [GRUB Passphrase](https://wiki.archlinux.org/title/GRUB/Tips_and_tricks#Password_protection_of_GRUB_menu)
[ ] GRUB Theme

### File system

[x] Partition menu
[x] [BTRFS](https://wiki.archlinux.org/title/btrfs)
[ ] [Snapper](https://wiki.archlinux.org/title/snapper)
[ ] [Timeshift]()

### Libnewt

[ ] Libnewt theme

## Chroot

[ ] Locale - Additional options

## Kernel

[ ] Hardened Linux kernel

## Script

[ ] Implement proper error handling
[ ] Suppress unnecessary command outputs
[ ] Wayland support

### AUR

[ ] AUR password dialog

### Bitwarden

[ ] [Bitwarden CLI](https://bitwarden.com/help/cli/) support

# Install sequence sketch

  ## Sgdisk dialog

  - EFI size (512MiB)
  - Boot size (512MiB)

  - Create EFI
  - Create boot
  - Create /

  ## User dialog

  - Select EFI
  - [Optional] Select /boot
  - Select /

  - Select filesystem (ext4/btrfs)
  - Select encryption (true/false)

  - Select crypt setup
    * Enter crypt password
    * Enter crypt password confirm
    * Create crypt file
    * Enter root (lvm) size (GB) (btrfs?)

  ## Install sequence

  - Format EFI
  - Mount EFI mnt/boot/efi

  - Format Boot
  - Mount Boot /mnt/boot

  - Btrfs [Plain]
    * Make: `mkfs.btrfs ${rootdevice}"`
    * Mount: `mount ${rootdevice} /mnt`
    * Create subvolumes: {/mnt/@, /mnt/@home, /mnt/@var or /mtn@var_log}
    * Unmount: umount /mnt
    * Mount: `mount -o`

  - ext4 [Plain]
    * Make: `mkfs.ext4 ${rootdevice}`
    * Mount: `mount ${rootdevice} /mnt`

  - Btrfs & ext4 [Encrypted]
    * cryptsetup luksFormat rootdevice
    * cryptsetup open rootdevice

  - Btrfs [Encrypted]
    * Make: `mkfs.btrfs /dev/mapper/cryptroot`
    * Mount: `mount /dev/mapper/cryptroot /mnt`
    * Create subvolumes: {/mnt/@, /mnt/@home, /mnt/@var}
    * Unmount: umount /mnt
    * Mount: `mount -o`

  - ext4 [Encrypted]
    * pvcreate /dev/mapper/cryptlvm
    * vgcreate volgroup0 /dev/mapper/cryptlvm
    * lvcreate -L 30GB volgroup0 -n cryptroot
    * lvcreate -L 100%FREE volgroup0 -n crypthome
    * modprobe dm_mod
    * vgscan
    * vgchange -ay

    * Format cryptroot
    * Mount cryptroot

    * Format home
    * Mount home
