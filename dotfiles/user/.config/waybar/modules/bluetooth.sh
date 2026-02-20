#!/usr/bin/env bash

set -o pipefail

exec 2> /dev/null


command -v jq grep sed busctl pactl pw-dump &> /dev/null || printf "\033[0;31mYour system does not satisfy the script requirements.\033[0m\n"


macfile=/tmp/bt-mac.txt

if [ ! -s "$macfile" ]; then
    devicemac=$(busctl --json=short --no-pager call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects | jq --unbuffered -r '.. | select(.Connected.data == true?) | .Address.data | select( . != null)' | sed 's/:/_/g')
else
    [ "$devicemac" ] && echo "$devicemac" > "$macfile"
    devicemac=$(< $macfile)
fi


function get-prop() {
    busctl --json=short --no-pager get-property org.bluez "/org/bluez/hci0/dev_$devicemac" "org.bluez.$1" "$2" | jq --unbuffered -r '.data'
}

function get-bluez-prop() {
    if [ "$pw_audio" ]; then
        pw-dump -N | jq --unbuffered -r ".[].info.props[\"api.bluez5.$1\"] | select( . != null)" | head -1
    elif [ "$pa_audio" ]; then
        pactl --format=json list sinks | jq --unbuffered -r ".[] | select(.name | contains(\"bluez_sink\")) | .properties[\"$1\"]" | head -1
    fi
}

pw_audio=$(pgrep -x pipewire)
pa_audio=$(pgrep -x pulseaudio)


bt_audio=$(pactl list sinks | grep -q 'bluez_[output|sink]' && echo 'true')
if [ "$devicemac" ]; then
    connected=$(get-prop Device1 Connected)
    devicetype=$(get-prop Device1 Icon)
    devicename=$(get-prop Device1 Alias)
fi


if [ "$bt_audio" ]; then
    if [ "$pw_audio" ]; then
        batterylevel=$(get-prop Battery1 Percentage | awk '{print $0"%"}')
        profile=$(get-bluez-prop profile)
        codec=$(get-bluez-prop codec | sed -e 's/^/[/;s/$/]/; s/_/-/; s/\(.*\)/\U\1/')
    elif [ "$pa_audio" ]; then
        profile=$(get-bluez-prop bluetooth.protocol)
        codec=$(get-bluez-prop bluetooth.codec | sed -e 's/^/[/; s/$/]/; s/\(.*\)/\U\1/')
    fi
    if [[ "$devicetype" =~ audio-head ]] && [ "$profile" = "a2dp-sink" ]; then
        devicetype="audio-headphones"
    else
        devicetype="audio-headset"
    fi
fi


if [ "$connected" = true ]; then
    echo "{\"text\": \"$devicename $codec $batterylevel\", \"class\": \"$devicetype\", \"alt\": \"$devicetype\"}"
elif [ ! "$connected" ] || [ "$connected" = false ] || [ ! "$devicemac" ]; then
    [ -s "$macfile" ] && rm $macfile
    echo "{\"text\": \"OFF\", \"class\": \"bt-off\", \"alt\": \"disconnected\"}"
fi
