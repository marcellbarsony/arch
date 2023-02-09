# Bitwarden (rbw)
# https://github.com/doy/rbw

bitwarden_email() {

  bw_email=$(dialog --cancel-label "Exit" --inputbox "Bitwarden e-mail" 8 45 3>&1 1>&2 2>&3)
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    echo "The script has terminated"
    exit ${exitcode}
  fi

  if [ ! ${bw_email} ]; then
    dialog --title " ERROR " --msgbox "\nE-mail cannot be empty" 8 45
    bitwarden_email
  fi

  rbw config set email ${bw_email}

  bitwarden_register

}

bitwarden_register() {

  error=$(rbw register 2>&1)
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nRBW register failed\n${error}" 8 60
    case ${?} in
    0)
      bitwarden_email
      ;;
    1)
      echo "Installation terminated - $?"
      exit ${exitcode}
    ;;
    esac
  fi

  bitwarden_login

}

bitwarden_login() {

  error=$(rbw sync 2>&1)
  local exitcode=$?

  if [ "${exitcode}" != "0" ]; then
    dialog --title " ERROR " --yes-label "Retry" --no-label "Exit" --yesno "\nRBW sync failed\n${error}" 8 60
    case ${?} in
    0)
      bitwarden_email
      ;;
    1)
      echo "Installation terminated - $?"
      exit ${exitcode}
    ;;
    esac
  fi

  bitwarden_data

}

bitwarden_data() {

  # Github
  gh_email=$( rbw get github --full | grep "E-mail:" | cut -d " " -f 2 )
  gh_username=$( rbw get github --full | grep "Username:" | cut -d " " -f 2 )
  gh_pat=$( rbw get github --full | grep "Personal Access Token:" | cut -d " " -f 4 )

  # Spotify
  spotify_email=$( rbw get spotify --full | grep "E-mail:" | cut -d " " -f 2 )
  spotify_username=$( rbw get spotify --full | grep "Username:" | cut -d " " -f 2 )
  spotify_password=$( rbw get spotify )
  spotify_client_id=$( rbw get spotify --full | grep "Client ID:" | cut -d " " -f 3 )
  spotify_device_id=$( rbw get spotify --full | grep "Device ID:" | cut -d " " -f 3 )
  spotify_client_secret=$( rbw get spotify --full | grep "Client Secret:" | cut -d " " -f 3 )

  clear

}

bitwarden_email
