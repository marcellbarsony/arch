# Dialogs

# Display protocol
dialog --yes-label "X11" --no-label "Wayland" --yesno "\nDisplay protocol" 8 45
if [ ${?} == "0" ]; then
  displayprotocol="X11"
else
  displayprotocol="Wayland"
fi

# Audio backend
dialog --yes-label "Pipewire" --no-label "ALSA" --yesno "\nAudio backend" 8 45
if [ ${?} == "0" ]; then
  audiobackend="Pipewire"
else
  audiobackend="ALSA"
fi

github_pubkey() {

  gh_pubkeyname=$(dialog --cancel-label "Exit" --inputbox "GitHub SSH Key" 8 45 'ArchLinux' 3>&1 1>&2 2>&3)

  if [ "$?" != "0" ]; then
    exit ${?}
  fi

  if [ ! ${gh_pubkeyname} ]; then
    dialog --title " ERROR " --msgbox "\nGitHub SSH key name cannot be empty." 8 45
    github_pubkey
  fi

  ssh_passphrase

}

ssh_passphrase() {

  ssh_passphrase=$(dialog --cancel-label "Back" --passwordbox "SSH passphrase" 8 45 3>&1 1>&2 2>&3)
  if [ "$?" != "0" ]; then
    github_pubkey
  fi

  ssh_passphrase_confirm=$(dialog --no-cancel --passwordbox "SSH passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${ssh_passphrase} ] || [ ! ${ssh_passphrase_confirm} ]; then
    dialog --title " ERROR " --msgbox "Passphrase cannot be empty." 8 45
    ssh_passphrase
  fi

  if [ ${ssh_passphrase} != ${ssh_passphrase_confirm} ]; then
    dialog --title " ERROR " --msgbox "Passphrase did not match." 8 45
    ssh_passphrase
  fi

  clear

}

github_pubkey
