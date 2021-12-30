**Arch Linux installation script**

For the documentation please refer to the [Wiki](https://github.com/marcellbarsony/arch/wiki "Wiki - Installation script").

## Important note

This script is currently **under development**.

## Installation guide

### Base system

1.) Download the [Arch ISO](https://archlinux.org/download/) and create a bootable media

2.) Verify the GPG signature and boot the live environment

3.) Establish internet connection

4.) Install Git

```sh
pacman -Sy git
```

5.) Clone this repository

```sh
git clone https://github.com/marcellbarsony/arch.git --branch dev
```

6.) Change to arch directory

```sh
cd arch
```

7.) Launch the installation script

```sh
sh main.sh
```

