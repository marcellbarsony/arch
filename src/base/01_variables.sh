# Global Variables

echo -n "Global variables............." && sleep 1

# Script properties
script_name=$(basename $0)

# Logs
script_log=${script_dir}/src/${script_name}.log
error_log=${script_dir}/src/error.log

# Configs
dialogrc=${script_dir}/src/cfg/dialogrc
pacmanconf=${script_dir}/src/cfg/pacman.conf

# Colors
#https://gist.github.com/elucify/c7ccfee9f13b42f11f81
RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MAGENTA=$(echo -en '\033[00;35m')
PURPLE=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LIGHTGRAY=$(echo -en '\033[00;37m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LMAGENTA=$(echo -en '\033[01;35m')
LPURPLE=$(echo -en '\033[01;35m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')
#echo ${RED}RED${GREEN}GREEN${YELLOW}YELLOW${BLUE}BLUE${PURPLE}PURPLE${CYAN}CYAN${WHITE}WHITE${RESTORE}

# Script
info_logs="Log files ................... "
info_network="Network connection .......... "
info_bootmode="Boot mode ................... "
info_dmidata="DMI data .................... "
info_systemclock="System clock ................ "
info_keymap="Keymap ...................... "
info_configs="Configs ..................... "
info_dependencies="Dependencies ................ "

echo "[${CYAN}OK${RESTORE}]"
