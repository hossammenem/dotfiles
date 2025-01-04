#!/bin/zsh

exec > /tmp/zen-launch.log 2>&1

launch () {
	local app="$1"
	local process_name="$2"
	if ! pgrep -x "$process_name" > /dev/null; then
		echo "Launching $app with process name $process_name"

		$app &
		# Add a small delay to give the app time to start
		sleep 2

		# Verify if the process actually started
		if ! pgrep -x "$process_name" > /dev/null; then
			echo "Failed to launch $app"
		fi

	fi
}

move () {
	local window_class="$1"
	local desktop="$2"

	window_id=$(xdotool search --class "$window_class" | head -n 1)

	if [ -n "$window_id" ]; then
		bspc node "$window_id" -d "$desktop"
	fi
}

# some delay to wait for some processes to start
sleep 5

launch "alacritty" "alacritty"
launch "discord" "Discord"
launch "/home/longassarchad/Downloads/zen/zen" "zen"

sleep 30 # wait for apps to start then move

move "zen-alpha" "^1"
move "Alacritty" "^2"
move "discord" "^3"
