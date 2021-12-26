#!/bin/bash

mainmenu(){
	if [ "${1}" = "" ]; then
		nextitem="."
	else
		nextitem=${1}
	fi
	options=()
	options+=("Language" "English")
	options+=("Shutdown" "-s")
	sel=$(whiptail --backtitle "Back title" --title "Arch Install Script" --menu "" --cancel-button "Cancel" --default-item "${nextitem}" 0 0 0 \
		"${options[@]}" \
		3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${sel} in
			"Language")
				echo "Select language"
				nextitem="Shutdown"
			;;
			"Shutdown")
				shutdown now
				nextitem="Language"
			;;
		esac
		mainmenu "${nextitem}"
	else
		clear
	fi

}

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

mainmenu

