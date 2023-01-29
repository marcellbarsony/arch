# Filesystem setup: Ext4

  ext4() (

    cryptsetup_open() {

      cryptsetup open --type luks2 ${rootdevice} cryptlvm --key-file ${keydir}

    }

    volume_physical() {

      pvcreate /dev/mapper/cryptlvm

      volume_group

    }

    volume_group() {

      vgcreate volgroup0 /dev/mapper/cryptlvm

      volume_create_root

    }

    volume_create_root() {

      lvcreate -L ${rootsize}GB volgroup0 -n cryptroot

      volume_create_home

    }

    volume_create_home() {

      lvcreate -l 100%FREE volgroup0 -n crypthome

      volume_kernel_module

    }

    volume_kernel_module() {

      modprobe dm_mod

      volume_group_scan

    }

    volume_group_scan() {

      vgscan

      volume_group_activate

    }

    volume_group_activate() {

      vgchange -ay

      format_root

    }

    format_root() {

      mkfs.${filesystem} /dev/volgroup0/cryptroot

      mount_root

    }

    mount_root() {

      mount /dev/volgroup0/cryptroot /mnt

      format_home

    }

    format_home() {

      mkfs.${filesystem} /dev/volgroup0/crypthome

      mount_home

    }

    mount_home() {

      mkdir /mnt/home

      mount /dev/volgroup0/crypthome /mnt/home

      boot_partition

    }

    cryptsetup_open
  )
