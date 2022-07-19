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

### Ncurses

[x] Ncurses theme

## Chroot

## Kernel

[x] Hardened Linux kernel

## Script

[ ] Implement proper error handling
[ ] Suppress unnecessary command outputs
[ ] Wayland support

### AUR

[ ] AUR password dialog

### Bitwarden

[ ] [rbw](https://github.com/doy/rbw) support
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

  - Cryptsetup
    * cryptsetup luksFormat rootdevice
    * cryptsetup open rootdevice

  - Btrfs
    * Make: `mkfs.btrfs /dev/mapper/cryptroot`
    * Mount: `mount /dev/mapper/cryptroot /mnt`
    * Create subvolumes: {/mnt/@, /mnt/@home, /mnt/@var}
    * Unmount: umount /mnt
    * Mount: `mount -o`

    * Format cryptroot
    * Mount cryptroot

    * Format home
    * Mount home

# XDGBDS

[XDG Based Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) latest<br>
Linux [FHS - Filesystem Hierarchy Standard](https://www.pathname.com/fhs/pub/fhs-2.3.html#PURPOSE18)

| Variable            | Path                            | Description                                    |
| ------------------- | ------------------------------- | ---------------------------------------------- |
| `$XDG_DATA_HOME`    | `$HOME/.local/share`            | User-specific data                             |
| `$XDG_CONFIG_HOME`  | `$HOME/.config`                 | User configuration files                       |
| `$XDG_CACHE_HOME`   | `$HOME/.cache`                  | Cache files                                    |
| `$XDG_STATE_HOME`   | `$HOME/.local/state`            | State data between application restarts        |
| `$XDG_DATA_DIRS`    | `/usr/local/share/:/usr/share/` | Search for additional data files               |
| `$XDG_CONFIG_DIRS`  | `/etc/xdg`                      | Indicate where config files should be searched |
|                     | `$HOME/.local/bin`              | User-specific executable files                 |

- `$HOME/.local/bin` - Distributions should ensure this directory shows up in the UNIX $PATH environment variable, at an appropriate place.
- `$XDG_RUNTIME_DIR` - Communication and synchronization
  * The directory MUST be owned by the user, and he MUST be the only one having read and write access to it. Its Unix access mode MUST be 0700.
