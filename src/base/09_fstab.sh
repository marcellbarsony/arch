# Fstab

echo -n "Generating fstab file ..." && sleep 1

mkdir /mnt/etc/ &>/dev/null
local exitcode1=$?

genfstab -U /mnt >>/mnt/etc/fstab
local exitcode2=$?

if [ "${exitcode1}" == "0" ] && [ "${exitcode2}" == "0" ]; then
  echo "[${CYAN}OK${RESTORE}]" && sleep 1
  clear
else
  echo "[${RED}FAILED${RESTORE}]"
  echo "Exit code: ${exitcode1} [mkdir]"
  echo "Exit code: ${exitcode2} [genfstab]"
  exit 1
fi

clear
