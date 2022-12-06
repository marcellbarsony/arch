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

# Zsh-Autocomplete
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${HOME}/.local/src/zsh-autocomplete/

# Zsh-Completions
git clone https://github.com/zsh-users/zsh-completions.git ${HOME}/.local/src/zsh-completions/

# Zsh-Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.local/src/zsh-autosuggestions/

# Notes
# https://zsh.sourceforge.io/Doc/Release/Files.html
# https://zsh.sourceforge.io/Intro/intro_3.html

clear && main_services
