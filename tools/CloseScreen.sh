#! /bin/bash

# close extend screen linked by HDMI
# if has extra HDMI screen, close laptop's one
status=$(xrandr | grep -i "HDMI")

if [ status != "" ];then
	xrandr --output eDP-1 --off
fi
