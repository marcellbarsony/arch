# SSH setup

# Kill process
sudo pkill -9 -f ssh

# Start client
eval "$(ssh-agent -s)"

sleep 1 && clear

# SSH key generate
ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f ${HOME}/.ssh/id_ed25519
if [ "${?}" != "0" ]; then
  dialog --title " ERROR " --msgbox "Cannot generate SSH key" 8 45
  exit ${?}
fi

sleep 1 && clear

# SSH key add
ssh-add ${HOME}/.ssh/id_ed25519
if [ "${?}" != "0" ]; then
  dialog --title " ERROR " --msgbox "Cannot add SSH key to agent" 8 45
  exit ${?}
fi

sleep 1 && clear
