# Dialog: Partition

keymap() {

  items=$(localectl list-keymaps)
  options=()
  options+=("us" "[Default]")
  for item in ${items}; do
    options+=("${item}" "")
  done

  keymap=$(dialog --title " Keyboard layout " --nocancel --menu "" 30 50 20 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then
    loadkeys ${keymap} &>/dev/null
    localectl set-keymap --no-convert ${keymap} &>/dev/null # Systemd reads from /etc/vconsole.conf
  else
    exit $?
  fi

  warning

}

warning() {

  if (dialog --title " WARNING " --yes-label "Proceed" --no-label "Exit" --yesno "\nEverything not backed up will be lost." 8 60); then
    diskselect || true
  else
    echo "Installation terminated - $?"
  fi

}

diskselect() {

  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  for item in ${items}; do
    options+=("${item}" "")
  done

  disk=$(dialog --title " Disk " --menu "Select disk to format" 15 70 17 ${options[@]} 3>&1 1>&2 2>&3)

  case $? in
  0)
    echo ${disk%%\ *}
    clear
    sgdisk_partition
    ;;
  1)
    warning
    exit 1
    ;;
  *)
    echo "Exit status $?"
    ;;
  esac

}

sgdisk_partition() {

  echo "[${CYAN} GPT ${RESTORE}] creating partitions (sgdisk) ... "

  sgdisk -o ${disk}
  local exitcode1=$?

  sgdisk -n 0:0:+750MiB -t 0:ef00 -c 0:efi ${disk}
  local exitcode2=$?

  #sgdisk -n 0:0:+1GiB -t 0:8300 -c 0:boot ${disk}
  #local exitcode3=$?

  sgdisk -n 0:0:0 -t 0:8e00 -c 0:cryptsystem ${disk}
  local exitcode4=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ] || [ "${exitcode4}" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nSgdisk: cannot create partitions\n\n
    Exit status [clear ]: ${exitcode1}\n
    Exit status [/efi  ]: ${exitcode2}\n
    Exit status [/boot ]: ${exitcode3}\n
    Exit status [/     ]: ${exitcode4}" 13 55
    exit 1
  fi

  diskpart_confirm

}

diskpart_confirm() {

  items=$(gdisk -l ${disk} | tail -3)

  if (dialog --title " Partitions " --yes-label "Confirm" --no-label "Manual" --yesno "\nConfirm partitions:\n\n${items}" 15 60); then
    dialogs || true
  else
    sgdisk --zap-all ${disk}
    diskpart_manual
  fi

}

diskpart_manual() {

  options=()
  options+=("cfdisk" "")
  options+=("fdisk" "")
  options+=("gdisk" "")

  diskpart_tool=$(dialog --title " Diskpart " --menu "" 10 30 3 "${options[@]}" 3>&1 1>&2 2>&3)

  if [ "$?" = "0" ]; then
    case ${diskpart_tool} in
    "cfdisk")
      clear
      cfdisk ${disk}
      diskpart_check
      ;;
    "fdisk")
      clear
      fdisk ${disk}
      diskpart_check
      ;;
    "gdisk")
      clear
      gdisk ${disk}
      diskpart_check
      ;;
    esac
  else
    case $? in
    1)
      diskselect
      ;;
    *)
      echo "Exit status: $?"
      ;;
    esac
  fi

}

keymap
