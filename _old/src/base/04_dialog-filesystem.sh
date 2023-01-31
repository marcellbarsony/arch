# Dialog: File system

select_efi() {

  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  for item in ${items}; do
    options+=("${item}" "")
  done

  efidevice=$(dialog --title " Partition " --cancel-label "Exit" --menu "Select device [EFI]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

  case $? in
  0)
    select_root
    ;;
  1)
    exit 1
    ;;
  esac

}

select_boot() {

  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  for item in ${items}; do
    options+=("${item}" "")
  done

  BOOTDEVICE=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [Boot]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

  case $? in
  0)
    select_root
    ;;
  1)
    select_efi
    ;;
  esac

}

select_root() {

  options=()
  items=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
  for item in ${items}; do
    options+=("${item}" "")
  done

  rootdevice=$(dialog --title " Partition " --cancel-label "Back" --menu "Select device [Root]" 13 70 17 ${options[@]} 3>&1 1>&2 2>&3)

  case $? in
  1)
    select_efi
    ;;
  esac

}

select_efi
