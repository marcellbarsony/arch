# Cryptsetup

echo -n "Encryption setup..." && sleep 1

# Cryptsetup - Create
echo ${cryptpassword} | cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 256 --pbkdf pbkdf2 --batch-mode luksFormat ${rootdevice}
local exitcode1=$?

# Cryptsetup - Open
echo ${cryptpassword} | cryptsetup open --type luks2 ${rootdevice} cryptroot
local exitcode2=$?

# Error check
if [ "${exitcode1}" == "0" ] && [ "${exitcode2}" == "0" ]; then
  echo "[${CYAN}OK${RESTORE}]" && sleep 1 && clear
else
  echo "[${RED}FAILED${RESTORE}]"
  echo "Cryptsetup - Create: ${exitcode1}"
  echo "Cryptsetup - Create: ${exitcode2}"
  exit 1
fi
