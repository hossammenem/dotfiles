#!/bin/bash

base_color="%{F#f5e0dc}"

pctl() {
  playerctl -p spotify $1
}

pctlcmd() {
  echo "playerctl -p spotify $1"
}

previous_icon=

play_pause_icon= 

if [[ $(pctl "status") = "Paused" ]]; then
  play_pause_icon=
fi

next_icon=

loop_icon="%{F#f38ba8}$base_color"
loop_command=`pctlcmd "loop playlist"`

if [[ $(pctl "loop") = "Playlist" ]]; then
  loop_icon=
  loop_command=`pctlcmd "loop track"`
elif [[ $(pctl "loop") = "Track" ]]; then
  loop_icon="%{F#a6e3a1}$base_color"
  loop_command=`pctlcmd "loop none"`
fi

shuffle_icon="%{F#f38ba8}"
shuffle_command=`pctlcmd "shuffle on"`

if [[ $(pctl "shuffle") = "On" ]]; then
  shuffle_icon=
  shuffle_command=`pctlcmd "shuffle off"`
fi

echo "%{A1:`pctlcmd "previous"`:}$previous_icon%{A}  %{A1:`pctlcmd "play-pause"`:}$play_pause_icon%{A}  %{A1:`pctlcmd "next"`:}$next_icon%{A}  %{A1:$loop_command:}$loop_icon%{A}  %{A1:$shuffle_command:}$shuffle_icon%{A}"
