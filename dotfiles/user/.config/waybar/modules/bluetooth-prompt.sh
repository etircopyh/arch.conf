#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


if [ -x "$(command -v sk)" ]; then
    DEVICEPICKER=sk
    SKIM_DEFAULT_OPTIONS='--ansi --reverse --color=dark --height=96%'
else
    DEVICEPICKER=fzf
    FZF_DEFAULT_OPTS='--ansi --reverse --color=dark --height=96%'
fi


DEVICE=$(bluetoothctl devices | awk '{$1=""; print $0}' | $DEVICEPICKER | awk '{print $1}')

bluetoothctl connect "$DEVICE"
