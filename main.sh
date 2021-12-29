#!/bin/bash

dependencies(){
  if ! [ -x "$(command -v dialog)" ]
    then
      echo "Dialog NOT installed"
      sudo pacman -Sy --noconfirm dialog
      dependencies
    else
      echo "Dialog is installed"
      mainmenu
  fi
}

mainmenu(){
#  NEWT_COLORS='
#  window=,red
#  border=white,red
#  textbox=white,red
#  button=black,white
#  ' \
#  https://askubuntu.com/questions/776831/whiptail-change-background-color-dynamically-from-magenta/781062#781062

  choice1="English"
  options=($choice1 "" Choice2 "" Choice3 "" Choice4 "")
#	 options=()
#  options+=(Language $sellanguage)
#  options+=(Layout "test")
#  options+=(Disk "test")
  select=$(dialog --title "Main menu" --menu "menu" --cancel-button "Exit" 25 78 16 ${options[@]} 3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${select} in
			"Language")
				language
				nextitem="Layout"
			;;
      "Layout")
        echo "Keyboard Layout"
        nextitem="Shutdown"
      ;;
			"Shutdown")
				shutdown now
				nextitem="Language"
			;;
		esac
      mainmenu "${nextitem}"
	else
		echo "$?"
    echo "${options[@]}"
	fi
}

language(){
  options=()
	options+=("English" "(US)")
  select=$(whiptail --title "Language" --menu "" 25 78 16 ${options[@]} 3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${select} in
			"English")
				choice1="en_US"
			;;
		esac
		mainmenu "${nextitem}"
	else
		echo "$?"
    echo "${options[@]}"
	fi
}

diskselect(){
  disk=$(lsblk -p -n -l -o NAME 7,11)

}

# -------------------------------
# -------------------------------

while (( "$#" ));
do
	case ${1} in
		--help)
			echo "------"
			echo "Arch installation script"
			echo "------"
			exit 0
    ;;
    --info)
      echo "Author: Marcell Barsony"
      echo "Important note: This script is under development"
      exit 0
	esac
	shift
done


#mainmenu
dependencies
