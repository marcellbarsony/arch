# Chroot

errorcheck() {

  if [ "$1" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
  fi

}

declare -a variables=(
  "keymap"
  "nodename"
  "username"
  "user_password"
  "root_password"
  "grubpw"
  "dmi"
  "RESTORE"
  "RED"
  "GREEN"
  "YELLOW"
  "BLUE"
  "MAGENTA"
  "PURPLE"
  "CYAN"
  "LIGHTGRAY"
  "LRED"
  "LGREEN"
  "LYELLOW"
  "LBLUE"
  "LMAGENTA"
  "LPURPLE"
  "LCYAN"
  "WHITE"
)

for variable in "${variables[@]}"; do
  echo -n "[${CYAN} VARIABLES ${RESTORE}] Exporting ${variable} ... "
  export ${variable}
  errorcheck $?
done

echo -n "[${CYAN} SCRIPT ${RESTORE}] Copying script files ... "
cp -fr ${script_dir}/src/chroot/ /mnt/temporary
errorcheck $?

echo -n "[${CYAN} SCRIPT ${RESTORE}] Chmod on chroot.sh ... "
chmod +x /mnt/temporary/chroot.sh
errorcheck $?

echo -n "[${CYAN} CONFIGS ${RESTORE}] dialogrc ... "
cp -f ${dialogrc} /mnt/etc/dialogrc
chown ${username} /mnt/etc/dialogrc
errorcheck $?

echo -n "[${CYAN} CONFIGS ${RESTORE}] pacman.conf ... "
cp -f ${pacmanconf} /mnt/etc/pacman.conf
chown ${username} /mnt/etc/pacman.conf
errorcheck $?

echo -n "[${CYAN} CHMOD ${RESTORE}] Chmod ... "
chmod +x /mnt/temporary/chroot.sh
errorcheck $?

echo -n "[${CYAN} CHROOT ${RESTORE}] Chroot in 3 seconds ... " && sleep 3
arch-chroot /mnt ./temporary/chroot.sh
#exitcode="$?"

#if [ ${exitcode} != "0" ]; then
#  dialog --title " ERROR " --msgbox "\nArch-chroot [/mnt] failed.\n\n
#  Exitcode: ${exitcode}" 13 50
#fi

#umount -l /mnt

#clear && exit 1
