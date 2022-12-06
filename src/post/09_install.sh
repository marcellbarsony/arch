# Install


install_base() {

  pkgbase="~/arch/src/pkg"

  # Base
  grep -o '"pkg[^"]*": "[^"]*' ${pkgbase}/base.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # Pacman
  grep -o '"pkg[^"]*": "[^"]*' ${pkgbase}/pacman.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # AUR
  grep -o '"pkg[^"]*": "[^"]*' ${pkgbase}/aur.json | grep -o '[^"]*$' | paru -S --noconfirm - && clear

  clear && install_display

}

install_display() {

  pkgbase="~/arch/src/pkg"

  case ${displayprotocol} in
  X11)
    grep -o '"pkg_xorg[^"]*": "[^"]*' ${pkgbase}/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  Wayland)
    grep -o '"pkg_wayland[^"]*": "[^"]*' ${pkgbase}/display.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  esac

  clear && install_audio

}

install_audio() {

  pkgbase="~/arch/src/pkg"

  case ${audiobackend} in
  ALSA)
    grep -o '"pkg_alsa[^"]*": "[^"]*' ${pkgbase}/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  Pipewire)
    grep -o '"pkg_pipewire[^"]*": "[^"]*' ${pkgbase}/audio.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear
    ;;
  esac

  clear && install_fonts

}

install_fonts() {

  echo "Installing fonts..."

  pkgbase="~/arch/src/pkg"

  # Latin
  grep -o '"pkg_latin[^"]*": "[^"]*' ${pkgbase}/fonts.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear

  # Japanese
  #grep -o '"pkg_japanese[^"]*": "[^"]*' ${HOME}/arch/pkg/fonts.json | grep -o '[^"]*$' | sudo pacman -S --needed --noconfirm - && clear



  clear && main_shell

}

install_base
