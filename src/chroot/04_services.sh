# Systemd services

errorcheck() {
  if [ "$1" == "0" ]; then
    echo "[${CYAN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
    read -n 1 -p "Press any key to continue" answer
    exit $1
  fi
}

declare -a services=(
  "ntpd.service"
  "sshd.service"
  "NetworkManager"
  "fstrim.timer"
)

for service in "${services[@]}"; do
  echo "[${CYAN} SERVICES ${RESTORE}] Enable [${WHITE}${service}${RESTORE}] ... "
  systemctl enable ${service}
done

echo "[${CYAN} SERVICES ${RESTORE}] Enable [${WHITE}DMI${RESTORE}] ... "
case ${dmi} in
  "VirtualBox")
    systemctl enable vboxservice.service
    modprobe -a vboxguest vboxsf vboxvideo
    VBoxClient-all
    ;;
  "VMware Virtual Platform")
    systemctl enable vmtoolsd.service
    systemctl enable vmware-vmblock-fuse.service
    ;;
esac
