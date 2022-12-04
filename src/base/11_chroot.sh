# Chroot

errorcheck() {

  if [ "$1" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
  fi

  sleep 3

}

echo -n "[${CYAN} VARIABLES ${RESTORE}] Exporting variables ... "
export keymap
export nodename
export username
export user_password
export root_password
export grubpw
export dmi
export RESTORE
export RED
export GREEN
export YELLOW
export BLUE
export MAGENTA
export PURPLE
export CYAN
export LIGHTGRAY
export LRED
export LGREEN
export LYELLOW
export LBLUE
export LMAGENTA
export LPURPLE
export LCYAN
export WHITE
errorcheck $?

echo -n "[${CYAN} CONFIGS ${RESTORE}] Copying configs ... "
cp -fr ${script_dir}/src/chroot/ /mnt/temporary
cp -f ${dialogrc} /mnt/etc/dialogrc
cp -f ${pacmanconf} /mnt/etc/pacman.conf
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
