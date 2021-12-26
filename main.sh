#!/bin/bash

diskselect(){
  disk=$(lsblk -p -n -l -o NAME 7,11)

}

mainmenu(){
	options=()
	options+=("Language")
  options+=("Cancel")
	options+=("Shutdown")
	sel=$(whiptail --title "Arch Install Script" --menu "" --cancel-button "Cancel" --default-item "${nextitem}" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	if [ "$?" = "0" ]; then
		case ${sel} in
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

