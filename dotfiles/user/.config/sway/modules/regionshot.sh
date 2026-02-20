#!/bin/sh

FILE=$HOME/Media/Screenshots/$(date +'%Y-%m-%d-%H:%M:%S_regionshot').png

#if [ "${FLOCKER}" != "$0" ]; then
    #exec env FLOCKER="$0" flock -en "$0" "$0" "$@"
#else
    #:
#fi


grim -g "$(slurp -c '#990000FF' -s '#2F4F4F28' -b '#00000046' -d)" "$FILE"

wl-copy -t image/png < "$FILE"

wl-paste -t image/png | swappy -f -
wait
if [ -f "$FILE" ]; then
    notify-send "Regionshot has been saved to $FILE"
fi
