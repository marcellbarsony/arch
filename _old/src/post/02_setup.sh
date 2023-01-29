# Setup

# Root
echo -n "[${CYAN} ROOT ${RESTORE}] ... "
id -u &>/dev/null
if [ "$?" == "0" ]; then
  echo "[OK]"
else
  dialog --title " ERROR " --msgbox "\nCannot run script as root [UID 0]" 13 50
  exit 1
fi

# Arch Linux Keyring
echo "[${CYAN} UPDATE ${RESTORE}] Keyring ... "
sudo pacman -Sy --noconfirm archlinux-keyring &>/dev/null && echo "[OK]"

# Time & Date
echo -n "[${CYAN} TIME & DATE ${RESTORE}] ... "
timedatectl set-timezone Europe/Amsterdam && echo "[OK]"

# Dependencies
declare -a dependencies=(
  "dialog"
  "github-cli"
  "rbw"
)

for dependency in "${dependencies[@]}"; do
  echo -n "[${CYAN} DEPENDENCY ${RESTORE}] ${dependency} ... "
  until pacman -Qi ${dependency}>/dev/null; do
    sudo pacman -S ${dependency} --noconfirm &>/dev/null
  done
  echo "[OK]"
done

network () {

  echo -n "[${CYAN} NETWORK ${RESTORE}] Checking connection ... "
  ping -q -c 3 archlinux.org &>/dev/null

  if [ "$?" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Please check network connection."
    echo "Exit status $?"
    network_connect
  fi

}

network_connect() {

  nmcli radio wifi on

  # List WiFi devices: nmcli device wifi list

  ssid=$(dialog --nocancel --title "Network connection" --inputbox "Network SSID" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${ssid} ]; then
    dialog --title " ERROR " --msgbox "Network SSID cannot be empty." 13 50
    network_connect
  fi

  network_password=$(dialog --nocancel --passwordbox "Network passphrase" 8 45 3>&1 1>&2 2>&3)

  if [ ! ${network_password} ]; then
    dialog --title " ERROR " --msgbox "Network passphrase cannot be empty." 13 50
    network_connect
  fi

  nmcli device wifi connect ${ssid} password ${network_password}

  if [ "$?" != "0" ]; then
    dialog --title " ERROR " --msgbox "\nCannot connect to network: ${ssid}" 13 50
    network_connect
  fi

  network

}

network

#cp -f ${dialogrc} /etc/dialogrc
