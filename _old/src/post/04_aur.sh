# AUR (pikaur)

aur_helper=$( grep -o '"aurhelper": "[^"]*' ${script_dir}/src/pkg/base.json | grep -o '[^"]*$' )
aurdir="${HOME}/.local/src/${aur_helper}"

if [ -d "${aurdir}" ]; then
  rm -rf ${aurdir}
fi

git clone https://aur.archlinux.org/${aur_helper}.git ${aurdir}
if [ "${?}" != "0" ]; then
  dialog --title " ERROR " --msgbox "Cannot clone ${aur_helper} repository" 8 45
  exit ${?}
fi

clear

cd ${aurdir}
makepkg -si --noconfirm
if [ "${?}" != "0" ]; then
  dialog --title " ERROR " --msgbox "Cannot make ${aur_helper} package" 8 45
  exit ${?}
fi
cd ${script_dir}
