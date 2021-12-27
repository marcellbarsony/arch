#!/bin/bash

diskselect(){
  disk=$(lsblk -p -n -l -o NAME 7,11)

}

mainmenu(){
  NEWT_COLORS='
  window=,red
  border=white,red
  textbox=white,red
  button=black,white
' \
# https://askubuntu.com/questions/776831/whiptail-change-background-color-dynamically-from-magenta/781062#781062

	options=()
	options+=("Language" "$selectedlang")
  options+=("Layout" "$selectedlayout")
  options+=("Disk" "$selecteddisk")
  select=$(whiptail --title "Main menu" --menu "" 25 78 16 ${options[@]} 3>&1 1>&2 2>&3)
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
				selectedlang="en_US"
        mainmenu
				nextitem="English"
			;;
		esac
		mainmenu "${nextitem}"
	else
		echo "$?"
    echo "${options[@]}"
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

