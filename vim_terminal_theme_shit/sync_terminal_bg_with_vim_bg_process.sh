#!/bin/bash

theme_file='/home/hossammenem/.config/nvim/lua/custom/chadrc.lua'
last_modified=$(stat -c %Y "$theme_file")

update_terminal_bg() {
  vim_bg=$(nvim -c 'echo synIDattr(hlID("Normal"), "bg")' -c 'q!' | tr -d '\n\r\033\007' | grep -E -o '#.{6}' | head -n 1)
  sed -i "s/background: '.*'/background: '$vim_bg'/" ~/.config/alacritty/alacritty.yml
}

while true; do
  current_modefied=$(stat -c %Y "$theme_file")

  if [ "$current_modefied" -ne "$last_modified" ]; then
    last_modified="$current_modefied" 
    update_terminal_bg
  fi

  sleep .25
done


#cleanup() {
#    echo "Cleaning up..."
#    kill -TERM $bg_process_pid
#    exit 0
#}

#bg_process_pid=$!

## Set up trap to call cleanup function when the script receives a signal to terminate
#trap cleanup EXIT
