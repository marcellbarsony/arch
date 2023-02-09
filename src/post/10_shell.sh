# Shell (ZSH)

# Change shell
chsh -s /usr/bin/zsh
if [ "${?}" != "0" ]; then
  echo "ERROR: Cannot change shell [${?}]"
  exit $?
fi

# Config
sudo cp -f ${HOME}/.config/zsh/global/zshenv /etc/zsh/zshenv
sudo cp -f ${HOME}/.config/zsh/global/zprofile /etc/zsh/zprofile

# zsh autocomplete
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

# zsh completions
git clone --depth 1 https://github.com/zsh-users/zsh-completions.git ${HOME}/.local/src/zsh-completions/

# zsh autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.local/src/zsh-autosuggestions/

# zsh prompt
git clone --depth 1 https://github.com/spaceship-prompt/spaceship-prompt ${HOME}/.local/src/spaceship/

clear
