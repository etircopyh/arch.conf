#!/usr/bin/env bash

VIM_PLUG="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/plugged"
if [ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload" ]; then
    command mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload"
    echo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload directory has been created"
fi

if [ ! -f "$VIM_PLUG" ] || [ "$(command diff "$VIM_PLUG" <(curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim))" ]; then
    echo 'Installing/Updating vim-plug...'
    exec curl -fLo "$VIM_PLUG" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
elif [ ! -d "$PLUGINS_DIR" ] || [ ! "$(command ls -A "$PLUGINS_DIR")" ]; then
    echo 'Installing plugins...'
    exec nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
else
    echo 'vim-plug is up-to-date'
fi
