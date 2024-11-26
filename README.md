**The Chad Stack installation script**

## The Chad Stack

- UEFI
- GRUB2
- dm-crypt (luks2)
- Linux-hardened
- Btrfs + Snapper
- DNS over HTTPS
- SSH service
- Wayland

## Installation

Install Git
```
pacman -S git
```

Clone the repository
```
git clone https://github.com/marcellbarsony/arch.git
```

Change to the directory
```
cd arch
```

Edit the configuration file
```
vim config.ini
```

Launch the script
```
./main.py
```
