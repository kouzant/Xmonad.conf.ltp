#!/bin/bash
#Load resources
xrdb -merge .Xresources

#Composite manager
xcompmgr -c &

#keyboard options
setxkbmap -model dell -layout us,gr -variant ,extended -option terminate:ctrl_alt_bksp,grp:alt_shift_toggle &

#cursor
xsetroot -cursor_name left_ptr &

#Initialize volume plugin
if [ -x /home/antonis/.xmobarVolFifo ] ; then
    rm /home/antonis/.xmobarVolFifo
fi
mkfifo /home/antonis/.xmobarVolFifo &
vol=$(amixer -c 0 get Master | awk -F'[]%[]' '/%/ {if ($7 == "off") { print "MM" } else { print $2 }}' | head -n 1)
echo "<fc=#e3170d>Vol:</fc> $vol" > /home/antonis/.xmobarVolFifo &

sleep 0.5

#Set Wallpaper
feh --bg-fill ~/wallpapers/debian_0.jpg &

#urvtd deamon
urxvtd -q -o -f &

#Set up an icon tray
trayer --edge top --align right --SetDockType true --SetPartialStrut true \
--expand true --width 3 --transparent true --tint 0xededed --height 15 &
#stalonetray -i 16 --window-type normal --geometry 1x1+0-0 --window-strut none --background black --icon-gravity NE &
#Fire up apps
xscreensaver -no-splash &
synclient VertEdgeScroll=1
synclient TapButton1=1
synclient TapButton2=2
synclient TapButton3=3
synclient HorizEdgeScroll=1
synclient HorizTwoFingerScroll=1

#lock current tty

exec xmonad
exec vlock
