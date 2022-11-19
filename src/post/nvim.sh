#!/bin/bash

clear

local plugins_start=$HOME/.local/share/nvim/site/pack/default/start
local plugins_opt=$HOME/.local/share/nvim/site/pack/default/opt

declare -a plugins(
    # Autocomplete
    "hrsh7th/nvim-cmp"
    "hrsh7th/cmp-buffer"
    "hrsh7th/cmp-cmdline"
    "hrsh7th/cmp-git"
    "hrsh7th/cmp-nvim-lsp"
    "hrsh7th/cmp-path"
    #"ms-jpq/coq_nvim"
    # File explorer
    "kyazdani42/nvim-tree.lua"
    #"md-jpq/chadtree"
    #"nvim-neo-tree/neo-tree.nvim"
    # Fold
    # Fuzzy
    #"lukas-reineke/cmp-rg"
    # Git
    "lewis6991/gitsigns.nvim"
    # LSP config
    "neovim/nvim-lspconfig"
    #"williamboman/nvim-lsp-installer"
    "jose-elias-alvarez/null-ls.nvim"
    "nvim-lua/plenary.nvim"
    # Shell
    #"tamago324/cmp-zsh"
    # Snippets
    # ultisnips
    "SirVer/ultisnips"
    "quangnguyen30192/cmp-nvim-ultisnips"
    "honza/vim-snippets"
    "onsails/lspkind.nvim"
    # vim-vsnip
    #"hrsh7th/cmp-vsnip"
    # Status line
    # Tabs
    "akinsho/bufferline.nvim"
    )

for repo in "{plugins[@]}"; do
    gh repo clone ${repo} ${plugins_start}
done

# Python plugin support
pip3 install pynvim

