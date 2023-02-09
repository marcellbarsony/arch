#!/bin/bash

# VENV
pip3 install virtualenv

# Install debugpy into a virtualenv
# https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#Python
mkdir ~/.virtualenvs
cd ~/.virtualenvs
python -m venv debugpy
debugpy/bin/python -m pip install debugpy
cd -

# Modules
declare -a modules=(
  'beautifulsoup4',
  'numpy',
  'python-nmap',
  'requests',
  'scapy'
)

for module in "${modules[@]}"; do
  pip install ${module}
done
