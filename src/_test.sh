#!/bin/bash

    curl -L -o ${HOME}/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"
    # Fetch & unzip wallpapers
    unzip ${HOME}/Downloads/wallpapers.zip -d ${HOME}/Downloads/Wallpapers/ -x /
