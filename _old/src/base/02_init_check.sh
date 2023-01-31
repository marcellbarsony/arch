# Initial checks

logs() {

  echo -n ${info_logs} && sleep 1

  if [ ! -f "${error_log}" ] || [ ! -f "${script_log}" ]; then
    touch ${error_log} && touch ${script_log}
  else
    >${error_log} && >${script_log}
  fi

  echo "[${CYAN}OK${RESTORE}]"
  network

}

network() {

  echo -n ${info_network}
  ping -q -c 3 archlinux.org &>/dev/null

  if [ "$?" != "0" ]; then
    echo "[${RED}ERROR${RESTORE}]"
    echo "Please check network connection."
    echo "Exit status $?"
  fi

  echo "[${CYAN}OK${RESTORE}]"
  bootmode

}

bootmode() {

  echo -n ${info_bootmode} && sleep 1
  ls /sys/firmware/efi/efivars &>/dev/null

  if [ "$?" != "0" ]; then
    echo "[${RED}ERROR${RESTORE}]"
    echo "Please verify the boot mode - Exit status $?"
    echo "https://wiki.archlinux.org/title/installation_guide#Verify_the_boot_mode"
  fi

  echo "[${CYAN}OK${RESTORE}]"
  dmidata

}

dmidata() {

  echo -n ${info_dmidata} && sleep 1
  dmi=$(dmidecode -s system-product-name)

  if [ ${dmi} == "VirtualBox" ] || ${dmi} == "VMware Virtual Platform" ]; then
    echo "[${CYAN}VM${RESTORE}]"
  else
    echo "[${CYAN}PM${RESTORE}]"
  fi

  systemclock

}

systemclock() {

  echo -n ${info_systemclock} && sleep 1
  timedatectl set-ntp true --no-ask-password

  if [ "$?" != "0" ]; then
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status $?"
  fi

  echo "[${CYAN}OK${RESTORE}]"
  keymap

}

keymap() {

  echo -n ${info_keymap} && sleep 1
  loadkeys us &>/dev/null
  localectl set-keymap --no-convert us &>/dev/null # Systemd reads from /etc/vconsole.conf

  if [ "$?" != "0" ]; then
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status $?"
  fi

  echo "[${CYAN}OK${RESTORE}]"
  configs

}

configs() {

  echo -n ${info_configs} && sleep 1
  cp -f ${dialogrc} ${HOME}/.dialogrc
  cp -f ${pacmanconf} /etc/pacman.conf

  if [ "$?" != "0" ]; then
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status $?"
  fi

  echo "[${CYAN}OK${RESTORE}]"
  dependencies

}

dependencies() {

  echo -n ${info_dependencies}
  until pacman -Q dialog &>/dev/null; do
    until pacman -Sy --noconfirm dialog &>/dev/null; do
      echo "[${RED}ERROR${RESTORE}]"
      echo "Cannot install Dialog"
      echo "Run \`${WHITE}pacman -Sy archlinux-keyring${RESTORE}\` or \`${WHITE}reboot now${RESTORE}\`"
      exit 1
    done
  done

  echo "[${CYAN}OK${RESTORE}]" && sleep 1

}

logs
