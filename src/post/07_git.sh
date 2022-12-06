# Git (GitHub)

gh_login () {

  echo "GH: set token..."
  set -u
  cd ${HOME}
  echo "${gh_pat}" >.ghpat
  unset gh_pat

  echo "GH: authenticate with token..."
  gh auth login --with-token <.ghpat
  if [ "${?}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Cannot authenticate GitHub with token [~/.ghpat]" 8 45
    exit ${?}
  fi

  echo "GH: remove token..."
  rm ${HOME}/.ghpat
  cd -

  echo "GH: authentication status..."
  gh auth status
  if [ "${?}" != "0" ]; then
    dialog --title " ERROR " --msgbox "Cannot verify authentication status" 8 45
    exit ${?}
  fi

  sleep 5

  add_pubkey

}

add_pubkey () {

  echo "GH: add ssh key..." && sleep 1
  gh ssh-key add ${HOME}/.ssh/id_ed25519.pub -t ${gh_pubkeyname}
  if [ "${?}" != "0" ]; then
    dialog --title " ERROR " --msgbox "GitHub SSH authentication unsuccessfull" 8 45
    exit ${?}
  fi

  gh_test

}

gh_test () {

  echo "GH: ssh test..."
  ssh -T git@github.com
  case ${?} in
  0)
    gh_known_hosts
    ;;
  *)
    echo "An error has occurred - ${?}"
    exit ${?}
    ;;
  esac

}

gh_known_hosts () {

echo "GH: applying fix.............."
ssh-keyscan github.com >> ~/.ssh/known_hosts

}

clear && gh_login
