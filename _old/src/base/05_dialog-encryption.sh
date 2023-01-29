# Dialog: Encryption

crypt_password() {

  cryptpassword=$(dialog --nocancel --passwordbox "LUKS encryption passphrase" 8 45 3>&1 1>&2 2>&3)

  case $? in
  0)
    crypt_password_confirm
    ;;
  *)
    echo "Exit status: $?"
    ;;
  esac

}

crypt_password_confirm() {

  cryptpassword_confirm=$(dialog --nocancel --passwordbox "LUKS encryption passphrase [confirm]" 8 45 3>&1 1>&2 2>&3)

  case $? in
  0)
    crypt_password_check
    ;;
  *)
    echo "Exit status $?"
    ;;
  esac

}

crypt_password_check() {

  if [ ! ${cryptpassword} ] || [ ! ${cryptpassword_confirm} ]; then
    dialog --title " ERROR " --msgbox "Encryption passphrase cannot be empty." 8 45
    crypt_password
  fi

  if [[ "${cryptpassword}" != "${cryptpassword_confirm}" ]]; then
    dialog --title " ERROR " --msgbox "Encryption passphrase did not match." 8 45
    crypt_password
  fi

}

key_file() {

  # https://wiki.archlinux.org/title/dm-crypt/Device_encryption#Keyfiles

  keydir=/root/luks.key
  keydir2=/root/luks.key2

  echo "$cryptpassword" >"$keydir"
  local exitcode1=$?

  echo "$cryptpassword_confirm" >"$keydir2"
  local exitcode2=$?

  if [ "${exitcode1}" != "0" ] || [ "${exitcode2}" != "0" ]; then
    dialog --title "ERROR" --msgbox "Key file [${keydir}] cannot be created.\n
      Exit status [File 1]: ${exitcode1}\n
      Exit status [File 2]: ${exitcode2}" 12 78
    exit 1
  fi

  # Password match
  if cmp --silent -- "$keydir" "$keydir2"; then
    crypt_setup
  else
    dialog --title " ERROR " --msgbox "Encryption password did not match.\nExit status: ${exitcode}" 8 78
    crypt_password
  fi

}

crypt_password
