#!/usr/bin/bash

main_setup() (

  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  srcdir="src/base"

  source ${script_dir}/${srcdir}/01_variables.sh
  source ${script_dir}/${srcdir}/02_init_check.sh
  source ${script_dir}/${srcdir}/03_dialog-partitions.sh
  source ${script_dir}/${srcdir}/04_dialog-filesystem.sh
  source ${script_dir}/${srcdir}/05_dialog-encryption.sh
  source ${script_dir}/${srcdir}/06_dialog-sysadmin.sh
  source ${script_dir}/${srcdir}/07_cryptsetup.sh
  source ${script_dir}/${srcdir}/08_filesystem-btrfs.sh
  source ${script_dir}/${srcdir}/09_fstab.sh
  source ${script_dir}/${srcdir}/10_archinstall.sh
  source ${script_dir}/${srcdir}/11_chroot.sh

)

while (("$#")); do
  case ${1} in
  --help)
    echo "Options:"
    echo "--help - Get help"
    echo "--info - Additional information"
    exit 0
    ;;
  --info)
    echo "Author: Marcell Barsony"
    echo "Repository: https://github.com/marcellbarsony/arch"
    exit 0
    ;;
  *)
    echo "Available options:"
    echo "Help --help"
    echo "Info --info"
    ;;
  esac
  shift
done

clear && main_setup
