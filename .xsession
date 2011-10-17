#!/bin/bash
#Load resources
xrdb -merge .Xresources

#Composite manager
xcompmgr -c &

#keyboard options
setxkbmap -model pc105 -layout us,gr -variant ,extended -option terminate:ctrl_alt_bksp,grp:alt_shift_toggle,grp_led:scroll &

#cursor
xsetroot -cursor_name left_ptr &

#Initialize volume plugin
if [ -x /home/antonis/.xmobarVolFifo ] ; then
    rm /home/antonis/.xmobarVolFifo
fi
mkfifo /home/antonis/.xmobarVolFifo &
vol=$(amixer -c 0 get Master | awk -F'[]%[]' '/%/ {if ($7 == "off") { print "MM" } else { print $2 }}' | head -n 1)
echo "<fc=#e3170d>Vol:</fc> $vol" > /home/antonis/.xmobarVolFifo &

#Set Wallpaper
feh --bg-fill ~/wallpapers/debian_0.jpg &

#urvtd deamon
urxvtd -q -o -f &

#Set up an icon tray
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --tint 0xededed --height 14 &

#Fire up apps
xscreensaver -no-splash &

exec xmonad
