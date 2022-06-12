#!/bin/bash

rootpassword(){

  root_password=$(whiptail --passwordbox "Root password" --nocancel 8 78 --title "ROOT" 3>&1 1>&2 2>&3)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --msgbox "Exit status: $?" 8 78
    exit $?
  fi

  root_password_confirm=$(whiptail --passwordbox "Root password confirm" --nocancel 8 78 --title "ROOT" 3>&1 1>&2 2>&3)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --msgbox "Exit status: $?" 8 78
    exit $?
  fi

  if [ ${root_password} == ${root_password_confirm} ]; then
      echo "root:${rootpassword}" | chpasswd
    else
      whiptail --title "ERROR" --msgbox "Root password did not match.\n
      Exit status: $?" 8 78
      rootpassword
  fi

}

rootpassword
