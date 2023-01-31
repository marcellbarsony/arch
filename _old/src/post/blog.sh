#!/bin/bash

check_ruby() {

    sudo pacman -Q ruby >/dev/null
    if [ "$?" != 0 ]; then
        sudo pacman -S ruby
    fi

    clear && install_gems

}

install_gems() {

    cd ${HOME}/.local/git/blog
    gem update
    gem install jekyll bundler
    bundle update
    cd ${HOME}

}

clear && check_ruby
