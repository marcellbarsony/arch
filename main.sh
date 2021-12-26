#!/bin/bash

diskselect(){
  disk=$(lsblk -p -n -l -o NAME 7,11)

}

mainmenu(){
	options=()
	options+=("Language")
  options+=("Cancel")
	options+=("Shutdown")
  whiptail --title "Arch Install Script" --menu "" 15 60 3 "${options[@]}" 3>&1 1>&2 2>&3
	#select=$(whiptail --title "Arch Install Script" 15 60 3 "${options[@]}" 3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${select} in
			"Language")
				echo "Select language"
				nextitem="Cancel"
			;;
      "Cancel")
        echo "Cancel"
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
	fi

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

mainmenu

