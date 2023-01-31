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
  "vboxservice.service"
)

for service in "${services[@]}"; do
  systemctl enable ${service}
  if [ $? == "0" ]; then
    echo "[${CYAN} SERVICES ${RESTORE}] Enable [${WHITE}${service}${RESTORE}] ... [${GREEN}OK${RESTORE}]"
  else
    echo "[${CYAN} SERVICES ${RESTORE}] Enable [${WHITE}${service}${RESTORE}] ... [${RED}FAILED${RESTORE}]"
done

echo "[${CYAN} SERVICES ${RESTORE}] Enable [${WHITE}DMI${RESTORE}] ... "
case ${dmi} in
  "VirtualBox")
    modprobe -a vboxguest vboxsf vboxvideo
    VBoxClient-all
    ;;
  "VMware Virtual Platform")
    systemctl enable vmtoolsd.service
    systemctl enable vmware-vmblock-fuse.service
    ;;
esac
