# BTRFS Snapper
echo "[${CYAN} BTRFS ${RESTORE}] Create Snapper config ... "
snapper --no-dbus -c home create-config /home

# Clean-up
rm -rf /temporary
