#errorlog() {
#
#  local exitcode=${1}
#  local functionname=${2}
#  local lineno=${3}
#
#  echo "Directory - ${script_dir}" >${error_log}
#  echo "Script - ${script_name}" >>${error_log}
#  echo "Function - ${functionname}" >>${error_log}
#  echo "Line no. - ${lineno}" >>${error_log}
#  echo "Exit code - ${exitcode}" >>${error_log}
#
#  if (dialog --title " ERROR " --yes-label "View logs" --no-label "Exit" --yesno "\nAn error has occurred\nCheck the log file for details\nExit status: ${exitcode}" 10 60); then
#    vim ${error_log}
#    clear
#    exit ${exitcode}
#  else
#    clear
#    exit ${exitcode}
#  fi
#
#}
#
#set -o errtrace
#exec 2>>${error_log}
#
#trap 'errorlog ${?} ${FUNCNAME-main} ${LINENO}' ERR
#trap 'failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND"' ERR

# Note
# https://stackoverflow.com/questions/31201572/how-to-untrap-after-a-trap-command
# https://github.com/rtxx/arch-minimal-install/blob/main/install-script
# https://unix.stackexchange.com/questions/462156/how-do-i-find-the-line-number-in-bash-when-an-error-occured
# https://stackoverflow.com/questions/64786/error-handling-in-bash
# https://stackoverflow.com/questions/25378845/what-does-set-o-errtrace-do-in-a-shell-script
