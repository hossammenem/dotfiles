#!/bin/bash

vim_bg=$(nvim -c 'echo synIDattr(hlID("Normal"), "bg")' -c 'q!' | tr -d '\n\r\033\007' | grep -E -o '#.{6}' | head -n 1)
sed -i "s/background: '.*'/background: '$vim_bg'/" ~/.config/alacritty/alacritty.yml
