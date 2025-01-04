# sound
# /usr/bin/pipewire &
# /usr/bin/pipewire-pulse &
# /usr/bin/pipewire-media-session &

# picom
killall -q picom
pgrep -x picom > /dev/null
picom -f &

# mouse sense and idk
xinput set-prop 'SINOWEALTH Game Mouse' 'libinput Accel Profile Enabled' 1, 0  # Enable flat acceleration
xinput set-prop 'SINOWEALTH Game Mouse' 'libinput Accel Speed' 1  # Max speed, adjust between 0 and 1

xinput set-prop 'SINOWEALTH Game Mouse' 'libinput Accel Speed' -0.6
xsetroot -cursor_name left_ptr

# important keybinds
setxkbmap -layout us,ara -option grp:ctrl_space_toggle
setxkbmap -option caps:swapescape

# screen tearing
xrandr --output HDMI-1 --set TearFree on
