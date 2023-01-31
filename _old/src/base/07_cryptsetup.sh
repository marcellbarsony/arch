# Cryptsetup

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

echo -n "[${CYAN} CRYPTSETUP ${RESTORE}] Create ... "
echo ${cryptpassword} | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat ${rootdevice}
errorcheck $?

echo -n "[${CYAN} CRYPTSETUP ${RESTORE}] Open ... "
echo ${cryptpassword} | cryptsetup open --type luks2 ${rootdevice} cryptroot
errorcheck $?
