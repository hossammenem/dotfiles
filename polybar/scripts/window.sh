#!/bin/bash

# echo $(xprop -id $(xdotool getwindowfocus) WM_CLASS | awk -F'"' '{print $4}');


if [[ $(xprop -id $(xdotool getwindowfocus) WM_CLASS | awk -F'"' '{print $4}') ]]; then
  echo $(xprop -id $(xdotool getwindowfocus) WM_CLASS | awk -F'"' '{print $4}');
else
  echo " ";
fi
