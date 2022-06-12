#!/bin/bash

rootpassword(){

  password=$(whiptail --passwordbox "Root password" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "Root password confirm" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password empty." 8 78
      rootpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password did not match." 8 78
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
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  useraccount

}

useraccount(){

  username=$(whiptail --inputbox "" --title "User account" --nocancel 8 39 3>&1 1>&2 2>&3)
  exitstatus=$?

  if [ ! ${username} ] || [ ${username} == "root" ]; then
    whiptail --title "ERROR" --msgbox "Username cannot be empty or [root]." 8 78
    useraccount
  fi

  useradd -m ${username}
  userpassword

}

userpassword(){

  password=$(whiptail --passwordbox "User password [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "User password confirm [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password empty." 8 78
      userpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password did not match." 8 78
      userpassword
  fi

  error=$(echo "${username}:${password}" | chpasswd 2>&1 )

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        userpassword
        ;;
      1)
        exit 1
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  usergroup

}

usergroup(){

  error=$(usermod -aG wheel,audio,video,optical,storage ${username} 2>&1)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        usergroup
        ;;
      1)
        exit 1
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  membership=$(id ${username})

  whiptail --title "Example Dialog" --msgbox "${username} has been added to the following groups:\n${membership}" 8 78
  exit 1

  #sudoers

}

rootpassword
