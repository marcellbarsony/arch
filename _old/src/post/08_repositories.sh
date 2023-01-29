# Repositories

dotfiles() {

  echo "Dotfiles: moving files ... "
  mv ${HOME}/.config/rbw /tmp
  mv ${HOME}/.config/gh /tmp
  rm -rf ${HOME}/.config

  echo "Dotfiles: fetching ... "
  git clone git@github.com:${gh_username}/dotfiles.git ${HOME}/.config

  echo "Dotfiles: Set remote URL for dotfiles ..."
  cd ${HOME}/.config
  git remote set-url origin git@github.com:${gh_username}/dotfiles.git
  cd -

  echo "Dotfiles: moving back files ... "
  mv /tmp/rbw ${HOME}/.config
  mv /tmp/gh ${HOME}/.config

  echo "Dotfiles: copying..."
  sudo cp ${HOME}/.config/systemd/logind.conf /etc/systemd/

  sleep 5 && clear && repos

}

repos() {

  repositories=[ 'arch', 'blog', 'notes', 'scripts' ]

  for repo in repositories; do

    local folder=${HOME}/.local/git/${repo}

    echo "Cloning repository: ${repo}"
    git clone git@github.com:${gh_username}/${repo}.git ${folder}

    echo "Changing remote URL: ${repo}"
    cd ${folder}
    git remote set-url origin git@github.com:${gh_username}/${repo}.git
    cd -

  done

  sleep 5 && clear

}

clear && dotfiles
