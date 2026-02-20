#!/bin/sh
FILE=$HOME/Media/Screenshots/$(date +'%Y-%m-%d-%H:%M:%S_windowshot').png

grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible? and .focused == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" "$FILE"

wl-copy -t image/png < "$FILE"

wl-paste -t image/png | swappy -f -
wait
if [ -f "$FILE" ]; then
    notify-send "Windowshot has been saved to $FILE"
fi
