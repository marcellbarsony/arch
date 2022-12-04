# Filesystem setup: BTRFS

root_partition() (

  echo "[${CYAN} ROOT ${RESTORE}] Formatting ... "
  mkfs.btrfs --quiet -L system /dev/mapper/cryptroot

  echo -n "[${CYAN} ROOT ${RESTORE}] Mounting ... "
  mount /dev/mapper/cryptroot /mnt && echo "[${GREEN}OK${RESTORE}]"

  sleep 2 && btrfs_filesystem

)

btrfs_filesystem() (

  echo "[${CYAN} BTRFS ${RESTORE}] Creating subvolumes ... "
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@var
  btrfs subvolume create /mnt/@snapshots

  umount -R /mnt
  #btrfs subvolume list .

  echo "[${CYAN} BTRFS ${RESTORE}] Mounting subvolumes ... "
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
  # Optional:ssd
  # dmesg | grep "BTRFS"

  mkdir -p /mnt/{efi,boot,home,var,.snapshots}
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var /dev/mapper/cryptroot /mnt/var
  mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

  #df -hT

  efi_partition

)

efi_partition() (

  echo "[${CYAN} EFI ${RESTORE}] Formatting (F32) ... "
  mkfs.fat -F32 ${efidevice}

  echo -n "[${CYAN} EFI ${RESTORE}] Mounting ... "
  mount ${efidevice} /mnt/boot && echo "[${GREEN}OK${RESTORE}]" #/mnt/efi

  sleep 5 && clear

)

root_partition
