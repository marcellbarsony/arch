**Arch Linux installation script**

## Feature list

- UEFI
- GRUB2 (password locked)
- dm-crypt
- Linux-hardened
- Btrfs (w/Snapper)
- SSH service

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

