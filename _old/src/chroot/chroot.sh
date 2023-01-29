#!/bin/bash

srcdir="/temporary"

source ${srcdir}/01_sysadmin.sh
source ${srcdir}/02_initramfs.sh
source ${srcdir}/03_grub.sh
source ${srcdir}/04_services.sh
source ${srcdir}/05_btrfs.sh

exit 69
