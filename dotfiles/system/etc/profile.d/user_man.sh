#!/bin/sh

# Add user path to find man
if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/man" ]; then
    export MANPATH="${XDG_DATA_HOME:-$HOME/.local/share}/man:$MANPATH"
fi
