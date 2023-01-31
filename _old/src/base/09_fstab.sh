# Fstab

errorcheck() {
  if [ "$1" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
    read -n 1 -p "Press any key to continue" answer
    exit $1
  fi
}

echo -n "[${CYAN} FSTAB ${RESTORE}] Creating directory ... "
mkdir /mnt/etc/ &>/dev/null
errorcheck $?

echo -n "[${CYAN} FSTAB ${RESTORE}] Generating fstab file ... "
genfstab -U /mnt >>/mnt/etc/fstab
errorcheck $?

clear
