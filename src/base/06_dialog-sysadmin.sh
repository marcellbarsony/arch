# Dialog: Sysadmin
# https://wiki.archlinux.org/title/General_recommendations#System_administration

workstation_name() {

  nodename=$(dialog --nocancel --inputbox "Hostname" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${nodename} ]; then
    dialog --title " ERROR " --msgbox "\nHostname cannot be empty." 8 45
    workstation_name
  fi

  user_account

}

user_account() {

  username=$(dialog --nocancel --inputbox "Username" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${username} ] || [ ${username} == "root" ]; then
    dialog --title " ERROR " --msgbox "\nUsername cannot be empty or [root]." 8 45
    user_account
  fi

  user_passphrase

}

user_passphrase() {

  user_password=$(dialog --nocancel --passwordbox "${username}'s passphrase" 8 45 3>&1 1>&2 2>&3)

  user_password_confirm=$(dialog --nocancel --passwordbox "${username}'s passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${user_password} ] || [ ! ${user_password_confirm} ]; then
    dialog --title " ERROR " --msgbox "\nUser passphrase cannot be empty." 8 45
    user_passphrase
  fi

  if [ ${user_password} != ${user_password_confirm} ]; then
    dialog --title " ERROR " --msgbox "\nUser passphrase did not match." 8 45
    user_passphrase
  fi

  root_passphrase

}

root_passphrase() {

  root_password=$(dialog --nocancel --passwordbox "Root passphrase" 8 45 3>&1 1>&2 2>&3)

  root_password_confirm=$(dialog --nocancel --passwordbox "Root passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${root_password} ] || [ ! ${root_password_confirm} ]; then
    dialog --title " ERROR " --msgbox "\nRoot passphrase cannot be empty." 8 45
    root_passphrase
  fi

  if [ ${root_password} != ${root_password_confirm} ]; then
    dialog --title " ERROR " --msgbox "\nRoot passphrase did not match." 8 45
    root_passphrase
  fi

  grub_password

}

grub_password() {

  grubpw=$(dialog --nocancel --passwordbox "GRUB passphrase" 8 45 3>&1 1>&2 2>&3)

  grubpw_CONFIRM=$(dialog --nocancel --passwordbox "GRUB passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${grubpw} ] || [ ! ${grubpw_CONFIRM} ]; then
    dialog --title " ERROR " --msgbox "\nGRUB passphrase cannot be empty." 8 45
    grub_password
  fi

  if [ ${grubpw} != ${grubpw_CONFIRM} ]; then
    dialog --title " ERROR " --msgbox "\nGRUB passphrase did not match." 8 45
    grub_password
  fi

  clear

}

workstation_name
