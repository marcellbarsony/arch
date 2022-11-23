# Filesystem setup: BTRFS

root_partition() (

  echo -n "Root: Formatting" && sleep 1
  mkfs.btrfs --quiet -L system /dev/mapper/cryptroot && echo "[${CYAN}OK${RESTORE}]"

  echo -n "Root: Mounting" && sleep 1
  mount /dev/mapper/cryptroot /mnt && echo "[${CYAN}OK${RESTORE}]"

  clear && btrfs_filesystem

)

btrfs_filesystem() (

  echo "\nBTRFS: Creating subvolumes" && sleep 1
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@var
  btrfs subvolume create /mnt/@snapshots

  umount -R /mnt
  #btrfs subvolume list .

  echo "\nBTRFS: Mounting subvolumes" && sleep 1
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
  # Optional:ssd
  # dmesg | grep "BTRFS"

  mkdir -p /mnt/{efi,boot,home,var,.snapshots}
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

  #df -hT

  clear && efi_partition

)

efi_partition() (

  echo "EFI: Formatting (F32)" && sleep 1
  mkfs.fat -F32 ${efidevice}

  echo "EFI: Mounting" && sleep 1
  efimountdir="/mnt/boot" #/mnt/efi
  mount ${efidevice} ${efimountdir}

  clear

)

root_partition
