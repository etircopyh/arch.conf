#!/bin/bash
kbdlayout=$(swaymsg -r -t get_inputs | awk '/1:1:AT_Translated_Set_2_keyboard/;/xkb_active_layout_name/' | grep -A1 '\b1:1:AT_Translated_Set_2_keyboard\b' | grep "xkb_active_layout_name" | awk -F '"' '{print $4}')

if [ "$kbdlayout" = "English (US)" ]; then
	echo US
elif [ "$kbdlayout" = "Russian" ]; then
	echo RU
else
	echo UA
fi
