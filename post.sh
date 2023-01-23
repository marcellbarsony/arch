#!/bin/bash

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
srcdir="src/post"

source ${script_dir}/${srcdir}/01_variables.sh
source ${script_dir}/${srcdir}/02_setup.sh
source ${script_dir}/${srcdir}/03_dialog.sh
source ${script_dir}/${srcdir}/04_aur.sh
source ${script_dir}/${srcdir}/05_bitwarden.sh
echo "SSH" && sleep 5
source ${script_dir}/${srcdir}/06_ssh.sh
echo "GIT" && sleep 5
source ${script_dir}/${srcdir}/07_git.sh
echo "REPOSITORIES" && sleep 5
source ${script_dir}/${srcdir}/08_repositories.sh
echo "INSTALL" && sleep 5
source ${script_dir}/${srcdir}/09_install.sh
echo "SHELL" && sleep 5
source ${script_dir}/${srcdir}/10_shell.sh
echo "SERVICES" && sleep 5
source ${script_dir}/${srcdir}/11_services.sh
echo "CUSTOMIZATION" && sleep 5
source ${script_dir}/${srcdir}/12_customization.sh

while (("$#")); do
  case ${1} in
  --help)
    echo "------"
    echo "Arch installation script"
    echo "------"
    echo
    echo "Options:"
    echo "--help    - Get help"
    echo "--info    - Additional information"
    echo
    exit 0
    ;;
  --info)
    echo "Author: Marcell Barsony"
    echo "Repository: https://github.com/marcellbarsony/arch"
    exit 0
    ;;
  *)
    echo "Available options:"
    echo "Help --help"
    echo "Info --info"
    ;;
  esac
  shift
done
