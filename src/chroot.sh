#!/bin/bash

rootpassword(){

  password=$(whiptail --passwordbox "Root password" 8 78 --title "ROOT" 3>&1 1>&2 2>&3)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --msgbox "Exit status: $?" 8 78
    exit $?
  fi

  password_confirm=$(whiptail --passwordbox "Root password confirm" --nocancel 8 78 --title "ROOT" 3>&1 1>&2 2>&3)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --msgbox "Exit status: $?" 8 78
    exit $?
  fi

  if [ ${password} != ${password_confirm} ] || [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password did not match or empty.\n
      Exit status: $?" 8 78
      rootpassword
  fi

  error=$(echo "root:${password}" | chpasswd 2>&1 )

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        rootpassword
        ;;
      1)
        exit 1
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

}

rootpassword
