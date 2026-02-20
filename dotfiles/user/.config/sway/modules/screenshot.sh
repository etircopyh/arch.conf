#!/bin/sh
FILE=$HOME/Media/Screenshots/$(date +'%Y-%m-%d-%H:%M:%S_screenshot').png

grim "$FILE"

wl-copy -t image/png < "$FILE"

wl-paste -t image/png | swappy -f -
wait
if [ -f "$FILE" ]; then
    notify-send "Screenshot has been saved to $FILE"
fi
