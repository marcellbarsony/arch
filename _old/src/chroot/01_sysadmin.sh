# System administration

errorcheck() {
  if [ "$1" == "0" ]; then
    echo "[${GREEN}OK${RESTORE}]"
  else
    echo "[${RED}ERROR${RESTORE}]"
    echo "Exit status: $1"
    exit $1
  fi
}

echo -n "[${CYAN} KEYMAP ${RESTORE}] Set keymap [${keymap}] ... "
loadkeys ${keymap} &>/dev/null # Session
echo "KEYMAP=${keymap}" > /etc/vconsole.conf # Permanent
errorcheck "$?"

echo -n "[${CYAN} ACCOUNTS ${RESTORE}] Set password [/root] ... "
echo "root:${root_password}" | chpasswd 2>&1
errorcheck "$?"

echo -n "[${CYAN} ACCOUNTS ${RESTORE}] Add new user [${username}] ... "
useradd -m ${username}
errorcheck "$?"

echo -n "[${CYAN} ACCOUNTS ${RESTORE}] Set password [${username}] ... "
error=$(echo "${username}:${user_password}" | chpasswd 2>&1)
errorcheck "$?"

echo -n "[${CYAN} GROUPS ${RESTORE}] Add user to groups ... "
usermod -aG wheel,audio,video,optical,storage,vboxsf ${username} 2>&1
errorcheck "$?"

echo -n "[${CYAN} HOSTS ${RESTORE}] Set hostname [${nodename}]"
echo ${nodename} > /etc/hostname
#hostnamectl set-hostname ${nodename}
# System has not been booted with systemd as init system (PID 1)
errorcheck "$?"

echo -n "[${CYAN} HOSTS ${RESTORE}] Set hosts ..."
echo "127.0.0.1        localhost" >/etc/hosts &>/dev/null
echo "::1              localhost" >>/etc/hosts &>/dev/null
echo "127.0.1.1        ${nodename}" >>/etc/hosts &>/dev/null
errorcheck "$?"

echo "[${CYAN} SUDOERS ${RESTORE}] Uncomment wheel group ... "
sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers >/etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new

echo "[${CYAN} SUDOERS ${RESTORE}] Add insults ... "
sed '71 i Defaults:%wheel insults' /etc/sudoers >/etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new

echo "[${CYAN} SUDOERS ${RESTORE}] Set password timeout ... "
sed '72 i Defaults passwd_timeout=0' /etc/sudoers >/etc/sudoers.new
export EDITOR="cp /etc/sudoers.new"
visudo
rm /etc/sudoers.new
errorcheck "$?"

echo -n "[${CYAN} LOCALE ${RESTORE}] Generate Locale ... "
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
locale-gen &>/dev/null
errorcheck "$?"

echo -n "[${CYAN} FIX ${RESTORE}] Add delay after failed login attempt ... "
sed -i '6i auth       optional   pam_faildelay.so     delay=5000000' /etc/pam.d/system-login
errorcheck "$?"

echo -n "[${CYAN} FIX ${RESTORE}] Fix Watchdog error reports at shutdown ... "
sed -i /\#RebootWatchdogSec=10min/c\RebootWatchdogSec=0 /etc/systemd/system.conf
errorcheck "$?"

clear
